import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/core/controller/app_controller.dart';
import 'package:openim/core/controller/client_config_controller.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';

import '../conversation/conversation_logic.dart';

class GlobalSearchLogic extends CommonSearchLogic {
  final conversationLogic = Get.find<ConversationLogic>();
  final textMessageRefreshCtrl = RefreshController();
  final fileMessageRefreshCtrl = RefreshController();
  final contactsList = <dynamic>[].obs;
  final groupList = <GroupInfo>[].obs;
  final groupRoleLevelMap = <String, int>{}.obs; // Map groupID -> roleLevel
  final textSearchResultItems = <SearchResultItems>[].obs;

  final appLogic = Get.find<AppController>();
  final clientConfigLogic = Get.find<ClientConfigController>();

  // final fileSearchResultItems = <SearchResultItems>[].obs;
  final fileMessageList = <Message>[].obs;
  final index = 0.obs;
  final tabs = [
    StrRes.globalSearchAll,
    StrRes.globalSearchContacts,
    StrRes.globalSearchGroup,
    StrRes.globalSearchChatHistory,
    StrRes.globalSearchChatFile,
  ];

  int textMessagePageIndex = 1;
  int fileMessagePageIndex = 1;
  int count = 20;

  // Track if user has searched at least once
  final hasSearched = false.obs;

  switchTab(int index) {
    this.index.value = index;
    // Callback để thông báo cho view cập nhật TabController
    if (onTabChanged != null) {
      onTabChanged!(index);
    }
  }

  // Callback function để view có thể đăng ký
  Function(int)? onTabChanged;

  @override
  void clearList() {
    contactsList.clear();
    groupList.clear();
    groupRoleLevelMap.clear();
    textSearchResultItems.clear();
    fileMessageList.clear();
  }

  // Clear search and reset to initial state
  void clearSearch() {
    searchCtrl.clear();
    clearList();
    hasSearched.value = false;
    focusNode.requestFocus();
  }

  bool get isSearchNotResult =>
      searchKey.isNotEmpty &&
      contactsList.isEmpty &&
      groupList.isEmpty &&
      textSearchResultItems.isEmpty &&
      fileMessageList.isEmpty;

  search() async {
    final isInviteCode = IMUtils.isValidInviteCode(searchKey);

    if (isInviteCode) {
      try {
        final merchant = await LoadingView.singleton.wrap(
          asyncFunction: () => GatewayApi.searchMerchant(
            code: searchKey,
            showErrorToast: false,
          ),
        );

        final confirm = await CustomDialog.show(
          title: '绑定企业',
          content: merchant.name,
        );

        if (confirm == true) {
          await LoadingView.singleton.wrap(
            asyncFunction: () async {
              await GatewayApi.bindMerchant(code: searchKey);
              IMViews.showToast(StrRes.bindSuccess);
              AppNavigator.startMerchantList();
            },
          );
        }
        return;
      } catch (e, s) {
        debugPrint('search merchant error: $e\n$s');
      }
    }

    // Mark that user has searched at least once
    hasSearched.value = true;

    final result = await LoadingView.singleton.wrap(
      asyncFunction: () => Future.wait(
        [
          searchFriendWithSDK(),
          searchGroup(),
          searchTextMessage(
            pageIndex: textMessagePageIndex = 1,
            count: count,
          ),
          searchFileMessage(
            pageIndex: fileMessagePageIndex = 1,
            count: count,
          ),
        ],
      ),
    );
    final friendList = (result[0] as List<FriendInfo>).map(
      (e) => UserInfo(
        userID: e.userID,
        nickname: e.nickname,
        remark: e.remark,
        faceURL: e.faceURL,
      ),
    );
    final gList = result[1] as List<GroupInfo>;
    final textMessageResult = (result[2] as SearchResult).searchResultItems;
    final fileMessageResult = (result[3] as SearchResult).searchResultItems;

    clearList();
    contactsList.assignAll(friendList);
    groupList.assignAll(gList);

    // Fetch roleLevel for each group
    for (var group in gList) {
      try {
        final memberInfoList =
            await OpenIM.iMManager.groupManager.getGroupMembersInfo(
          groupID: group.groupID,
          userIDList: [OpenIM.iMManager.userID],
        );
        if (memberInfoList.isNotEmpty) {
          groupRoleLevelMap[group.groupID] =
              memberInfoList.first.roleLevel ?? 1;
        }
      } catch (e) {
        // Default to member role if error
        groupRoleLevelMap[group.groupID] = 1;
      }
    }

    textSearchResultItems.assignAll(textMessageResult ?? []);
    fileMessageList.clear();
    if (null != fileMessageResult && fileMessageResult.isNotEmpty) {
      for (var element in fileMessageResult) {
        fileMessageList.addAll(element.messageList!);
      }
    }
    if ((textMessageResult ?? []).length < count) {
      textMessageRefreshCtrl.loadNoData();
    } else {
      textMessageRefreshCtrl.loadComplete();
    }
    if ((fileMessageResult ?? []).length < count) {
      fileMessageRefreshCtrl.loadNoData();
    } else {
      fileMessageRefreshCtrl.loadComplete();
    }
  }

  void loadTextMessage() async {
    final result = await searchTextMessage(
        pageIndex: ++textMessagePageIndex, count: count);
    final textMessageResult = result.searchResultItems;
    textSearchResultItems.addAll(textMessageResult ?? []);
    if ((textMessageResult ?? []).length < count) {
      textMessageRefreshCtrl.loadNoData();
    } else {
      textMessageRefreshCtrl.loadComplete();
    }
  }

  void loadFileMessage() async {
    final result = await searchFileMessage(
        pageIndex: ++fileMessagePageIndex, count: count);
    final fileMessageResult = result.searchResultItems;
    if (null != fileMessageResult && fileMessageResult.isNotEmpty) {
      for (var element in fileMessageResult) {
        fileMessageList.addAll(element.messageList!);
      }
    }
    if ((fileMessageResult ?? []).length < count) {
      fileMessageRefreshCtrl.loadNoData();
    } else {
      fileMessageRefreshCtrl.loadComplete();
    }
  }

  /// 最多显示2条
  List<T> subList<T>(List<T> list) =>
      list.sublist(0, list.length > 2 ? 2 : list.length).toList();

  String calContent(Message message) => IMUtils.calContent(
        content: IMUtils.parseMsg(message, replaceIdToNickname: true),
        key: searchKey,
        style: Styles.ts_8E9AB0_14sp,
        usedWidth: 80.w + 26.w,
      );

  void viewUserProfile(UserInfo info) => AppNavigator.startUserProfilePane(
        userID: info.userID!,
        nickname: info.nickname,
        faceURL: info.faceURL,
      );

  void viewFile(Message message) => IMUtils.previewFile(message);

  void viewGroup(GroupInfo groupInfo) {
    conversationLogic.toChat(
      groupID: groupInfo.groupID,
      nickname: groupInfo.groupName,
      faceURL: groupInfo.faceURL,
      sessionType: groupInfo.sessionType,
    );
  }

  void viewMessage(SearchResultItems item) {
    if (item.messageCount! > 1) {
      AppNavigator.startExpandChatHistory(
        searchResultItems: item,
        defaultSearchKey: searchKey,
      );
    } else {
      AppNavigator.startPreviewChatHistory(
        conversationInfo: ConversationInfo(
          conversationID: item.conversationID!,
          showName: item.showName,
          faceURL: item.faceURL,
        ),
        message: item.messageList!.first,
      );
    }
  }

  bool shouldShowMemberCount(String groupID) {
    final roleLevel = groupRoleLevelMap[groupID];
    return clientConfigLogic.shouldShowMemberCount(roleLevel: roleLevel);
  }
}

abstract class CommonSearchLogic extends GetxController {
  final searchCtrl = TextEditingController();
  final focusNode = FocusNode();

  void clearList();

  @override
  void onInit() {
    // Remove auto-clear listener to keep results until user submits new search
    // searchCtrl.addListener(_clearInput);
    super.onInit();
  }

  @override
  void onClose() {
    focusNode.dispose();
    searchCtrl.dispose();
    super.onClose();
  }

  // Removed auto-clear on text change
  // User must submit search to clear/update results
  // _clearInput() {
  //   if (searchKey.isEmpty) {
  //     clearList();
  //   }
  // }

  String get searchKey => searchCtrl.text.trim();

  Future<List<FriendInfo>> searchFriend() =>
      ChatApis.searchFriendInfo(searchCtrl.text.trim()).then(
          (list) => list.map((e) => FriendInfo.fromJson(e.toJson())).toList());

  Future<List<SearchFriendsInfo>> searchFriendWithSDK() =>
      OpenIM.iMManager.friendshipManager.searchFriends(
          keywordList: [searchCtrl.text.trim()],
          isSearchNickname: true,
          isSearchRemark: true,
          isSearchUserID: true);

  // Future<List<MemberUser>> searchDeptMember() =>
  //     OApis.searchDeptMember(keyword: searchKey)
  //         .then((value) => value.members ?? []);

  Future<List<GroupInfo>> searchGroup() =>
      OpenIM.iMManager.groupManager.searchGroups(
          keywordList: [searchCtrl.text.trim()],
          isSearchGroupName: true,
          isSearchGroupID: true);

  Future<SearchResult> searchTextMessage({
    int pageIndex = 1,
    int count = 20,
  }) async {
    final result = await OpenIM.iMManager.messageManager.searchLocalMessages(
      keywordList: [searchKey],
      messageTypeList: [
        MessageType.text,
        MessageType.atText,
        MessageType.quote
      ],
      pageIndex: pageIndex,
      count: count,
    );

    // Filter results to include reply messages - search BOTH reply text and quoted message content
    if (result.searchResultItems != null &&
        result.searchResultItems!.isNotEmpty) {
      for (var item in result.searchResultItems!) {
        if (item.messageList != null) {
          final filteredMessages = item.messageList!.where((msg) {
            final keyword = searchKey.toLowerCase();
            if (msg.contentType == MessageType.text) {
              final content = (msg.textElem?.content ?? '').toLowerCase();
              return content.contains(keyword);
            }
            if (msg.contentType == MessageType.atText) {
              final content = (msg.atTextElem?.text ?? '').toLowerCase();
              return content.contains(keyword);
            }
            if (msg.contentType == MessageType.quote) {
              // Check reply text (the wrapper message)
              final replyText = (msg.quoteElem?.text ?? '').toLowerCase();
              if (replyText.contains(keyword)) return true;

              // Check quoted message content
              final quotedMsg = msg.quoteElem?.quoteMessage;
              if (quotedMsg != null) {
                if (quotedMsg.contentType == MessageType.text) {
                  final quotedText =
                      (quotedMsg.textElem?.content ?? '').toLowerCase();
                  if (quotedText.contains(keyword)) return true;
                }
                if (quotedMsg.contentType == MessageType.atText) {
                  final quotedText =
                      (quotedMsg.atTextElem?.text ?? '').toLowerCase();
                  if (quotedText.contains(keyword)) return true;
                }
              }
              return false;
            }
            return false;
          }).toList();
          item.messageList = filteredMessages;
          // Update message count to reflect filtered results
          item.messageCount = filteredMessages.length;
        }
      }
      // Remove items with empty message lists
      result.searchResultItems!
          .removeWhere((item) => item.messageList?.isEmpty ?? true);
    }

    return result;
  }

  Future<SearchResult> searchFileMessage({
    int pageIndex = 1,
    int count = 20,
  }) =>
      OpenIM.iMManager.messageManager.searchLocalMessages(
        keywordList: [searchKey],
        messageTypeList: [MessageType.file],
        pageIndex: pageIndex,
        count: count,
      );

  String? parseID(e) {
    if (e is ConversationInfo) {
      return e.isSingleChat ? e.userID : e.groupID;
    } else if (e is GroupInfo) {
      return e.groupID;
    } else if (e is UserInfo) {
      return e.userID;
    } else if (e is FriendInfo) {
      return e.userID;
    } else {
      return null;
    }
  }

  String? parseNickname(e) {
    if (e is ConversationInfo) {
      return e.showName;
    } else if (e is GroupInfo) {
      return e.groupName;
    } else if (e is UserInfo) {
      return e.remark != null && e.remark != '' ? e.remark : e.nickname;
    } else if (e is FriendInfo) {
      return e.remark != null && e.remark != '' ? e.remark : e.nickname;
    } else {
      return null;
    }
  }

  String? parseFaceURL(e) {
    if (e is ConversationInfo) {
      return e.faceURL;
    } else if (e is GroupInfo) {
      return e.faceURL;
    } else if (e is UserInfo) {
      return e.faceURL;
    } else if (e is FriendInfo) {
      return e.faceURL;
    } else {
      return null;
    }
  }

  String? getNickname(e) {
    return (e.remark != null && e.remark.isNotEmpty) ? e.remark : e.nickname;
  }

  String? getItemContent(e) {
    return (e.remark != null && e.remark.isNotEmpty && e.remark != e.nickname)
        ? e.nickname
        : null;
  }
}
