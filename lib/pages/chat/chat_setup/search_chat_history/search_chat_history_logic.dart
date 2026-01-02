// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';

import '../../../../routes/app_navigator.dart';
import 'multimedia/multimedia_logic.dart';

class SearchChatHistoryLogic extends GetxController {
  final refreshController = RefreshController();
  final searchCtrl = TextEditingController();
  final focusNode = FocusNode();
  final messageList = <Message>[].obs;
  late ConversationInfo conversationInfo;
  final searchKey = "".obs;
  final dateTime = DateTime(0).obs;
  int pageIndex = 1;
  int pageSize = 50;

  @override
  void onInit() {
    conversationInfo = Get.arguments['conversationInfo'];
    // searchCtrl.addListener(_changedSearch);
    super.onInit();
  }

  void updateSearchTime(DateTime newDateTime) {
    dateTime.value = newDateTime;
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void onChanged(String value) {
    searchKey.value = value;
    if (value.trim().isNotEmpty) {
      search();
    }
  }

  clearDateTime() {
    dateTime.value = DateTime(0);
    messageList.clear();
  }

  clearInput() {
    searchKey.value = "";
    focusNode.requestFocus();
    if(!isNotDate){
      searchByTime();
    }else{
      messageList.clear();
    }
  }

  bool get isSearchNotResult => (messageList.isEmpty);

  bool get isNotKey => searchKey.value.isEmpty;
  bool get isNotDate => dateTime.value.secondsSinceEpoch <= 0;

  void searchByTime() async {
    try {
      // Use a local variable for search calculation, don't modify the stored date
      final searchDate = dateTime.value.add(const Duration(days: 1));
      // 获取0时的时间戳
      var dateZeroTime =
          DateTime(searchDate.year, searchDate.month, searchDate.day)
              .secondsSinceEpoch;
      var timeDiff = DateTime.now().secondsSinceEpoch - dateZeroTime;
      var result = await OpenIM.iMManager.messageManager.searchLocalMessages(
        conversationID: conversationInfo.conversationID,
        //Start time point for searching. Defaults to 0, meaning searching from now. UTC timestamp, in seconds
        searchTimePosition: dateZeroTime,
        // 搜索多久时间，秒为单位
        searchTimePeriod: 24 * 60 * 60,
        pageIndex: pageIndex = 1,
        count: pageSize,
        messageTypeList: [
          MessageType.text,
          MessageType.atText,
          MessageType.quote
        ],
      );
      if (result.totalCount == 0) {
        messageList.clear();
      } else {
        var item = result.searchResultItems!.first;
        messageList.assignAll(item.messageList!);
      }
    } finally {
      if (messageList.length < pageIndex * pageSize) {
        refreshController.loadNoData();
      } else {
        refreshController.loadComplete();
      }
    }
  }

  void search() async {
    try {
      final page = await _getMessageSearchPage(1);
      pageIndex = 1;
      messageList.assignAll(page.messages);
    } finally {
      if (messageList.length < pageSize) {
        refreshController.loadNoData();
      } else {
        refreshController.loadComplete();
      }
    }
  }

  void load() async {
    try {
      final nextPageIndex = pageIndex + 1;
      final page = await _getMessageSearchPage(nextPageIndex);
      pageIndex = nextPageIndex;

      if (page.messages.isNotEmpty) {
        final existingIds = _collectMessageIds(messageList);
        final newMessages = page.messages.where((msg) {
          final id = _messageId(msg);
          return id == null || !existingIds.contains(id);
        }).toList();

        if (newMessages.isNotEmpty) {
          messageList.addAll(newMessages);
        }
      }
    } finally {
      if (messageList.length < (pageSize * pageIndex)) {
        refreshController.loadNoData();
      } else {
        refreshController.loadComplete();
      }
    }
  }

  /// Fetch a page of search results, including a manual fallback for quote replies.
  Future<_SearchPageResult> _getMessageSearchPage(int pageIndex) async {
    final lowerQuery = searchKey.value.toLowerCase();
    final result = await OpenIM.iMManager.messageManager.searchLocalMessages(
      conversationID: conversationInfo.conversationID,
      keywordList: searchKey.value.isNotEmpty ? [searchKey.value] : [],
      messageTypeList: const [
        MessageType.text,
        MessageType.atText,
        MessageType.quote,
      ],
      pageIndex: pageIndex,
      count: pageSize,
    );

    var sdkMessages = (result.searchResultItems?.isNotEmpty == true)
        ? (result.searchResultItems!.first.messageList ?? [])
        : <Message>[];
    final sdkHasMore = (result.totalCount ?? 0) > pageIndex * pageSize;

    // Filter out quote results that only match the quoted/original text.
    if (lowerQuery.isNotEmpty) {
      sdkMessages = sdkMessages
          .where((msg) => _messageMatchesQuery(msg, lowerQuery))
          .toList();
    }

    // SDK currently doesn't index quote message text for keyword search.
    // When a keyword is present, run a manual fallback to keep replies searchable.
    if (searchKey.value.isEmpty) {
      return _SearchPageResult(messages: sdkMessages, hasMore: sdkHasMore);
    }

    final quoteResult = await _searchQuoteMessagesFallback(
      query: searchKey.value,
      pageIndex: pageIndex,
      excludeMessageIds: _collectMessageIds(sdkMessages),
    );

    final merged = _mergeAndSortMessages(sdkMessages, quoteResult.messages);
    final pageMessages = merged.take(pageSize).toList();
    final hasMore =
        sdkHasMore || quoteResult.hasMore || merged.length > pageSize;

    return _SearchPageResult(messages: pageMessages, hasMore: hasMore);
  }

  /// Manual quote search to work around SDK indexing bug.
  Future<_QuoteSearchResult> _searchQuoteMessagesFallback({
    required String query,
    required int pageIndex,
    required Set<String> excludeMessageIds,
  }) async {
    final lowerQuery = query.toLowerCase();
    final targetStart = (pageIndex - 1) * pageSize;

    final matches = <Message>[];
    var skipped = 0;
    var fetchPage = 1;
    var hasMoreSource = true;

    while (hasMoreSource && matches.length < pageSize) {
      final result = await OpenIM.iMManager.messageManager.searchLocalMessages(
        conversationID: conversationInfo.conversationID,
        keywordList: const [], // Avoid SDK keyword bug for quote text
        messageTypeList: const [MessageType.quote],
        pageIndex: fetchPage,
        count: pageSize,
      );

      final quotes = (result.searchResultItems?.isNotEmpty == true)
          ? (result.searchResultItems!.first.messageList ?? [])
          : <Message>[];

      if (quotes.isEmpty) {
        hasMoreSource = false;
        break;
      }

      for (final message in quotes) {
        final id = _messageId(message);
        if (id != null && excludeMessageIds.contains(id)) continue;
        if (!_quoteMatchesQuery(message, lowerQuery)) continue;

        if (skipped < targetStart) {
          skipped++;
          continue;
        }

        matches.add(message);
        if (matches.length >= pageSize) {
          break;
        }
      }

      hasMoreSource = quotes.length >= pageSize;
      fetchPage++;
    }

    matches.sort((a, b) => (b.sendTime ?? 0).compareTo(a.sendTime ?? 0));
    final hasMore = hasMoreSource || matches.length >= pageSize;
    return _QuoteSearchResult(messages: matches, hasMore: hasMore);
  }

  List<Message> _mergeAndSortMessages(
      List<Message> first, List<Message> second) {
    final merged = <Message>[];
    final seenIds = <String>{};

    void addIfNew(Message msg) {
      final id = _messageId(msg);
      if (id != null) {
        if (seenIds.contains(id)) return;
        seenIds.add(id);
      }
      merged.add(msg);
    }

    for (final msg in first) {
      addIfNew(msg);
    }
    for (final msg in second) {
      addIfNew(msg);
    }

    merged.sort((a, b) => (b.sendTime ?? 0).compareTo(a.sendTime ?? 0));
    return merged;
  }

  Set<String> _collectMessageIds(Iterable<Message> messages) {
    final ids = <String>{};
    for (final msg in messages) {
      final id = _messageId(msg);
      if (id != null) ids.add(id);
    }
    return ids;
  }

  String? _messageId(Message message) =>
      message.clientMsgID ?? message.serverMsgID;

  bool _messageMatchesQuery(Message message, String lowerQuery) {
    String? ownText;
    if (message.contentType == MessageType.quote) {
      ownText = message.quoteElem?.text;
    } else if (message.contentType == MessageType.atText) {
      ownText = message.atTextElem?.text;
    } else {
      ownText = message.textElem?.content;
    }

    return ownText != null && ownText.toLowerCase().contains(lowerQuery);
  }

  bool _quoteMatchesQuery(Message message, String lowerQuery) {
    final text = message.quoteElem?.text;
    return text != null && text.toLowerCase().contains(lowerQuery);
  }

  String calContent(Message message) {
    String content = IMUtils.parseMsg(message, replaceIdToNickname: true);
    // 左右间距+头像跟名称的间距+头像dax
    var usedWidth = 16.w * 2 + 10.w + 44.w;
    return IMUtils.calContent(
      content: content,
      key: searchKey.value,
      style: Styles.ts_0C1C33_17sp,
      usedWidth: usedWidth,
    );
  }

  void searchChatHistoryPicture() =>
      AppNavigator.startSearchChatHistoryMultimedia(
        conversationInfo: conversationInfo,
      );

  void searchChatHistoryByTime(DateTime dateTime) => {
        AppNavigator.startSearchChatHistoryTime(
            conversationInfo: conversationInfo, dateTime: dateTime)
      };

  void searchChatHistoryVideo() =>
      AppNavigator.startSearchChatHistoryMultimedia(
        conversationInfo: conversationInfo,
        multimediaType: MultimediaType.video,
      );

  void searchChatHistoryFile() => AppNavigator.startSearchChatHistoryFile(
        conversationInfo: conversationInfo,
      );

  void previewMessageHistory(Message message) =>
      AppNavigator.startPreviewChatHistory(
        conversationInfo: conversationInfo,
        message: message,
      );
}

class _SearchPageResult {
  final List<Message> messages;
  final bool hasMore;

  const _SearchPageResult({
    required this.messages,
    required this.hasMore,
  });
}

class _QuoteSearchResult {
  final List<Message> messages;
  final bool hasMore;

  const _QuoteSearchResult({
    required this.messages,
    required this.hasMore,
  });
}
