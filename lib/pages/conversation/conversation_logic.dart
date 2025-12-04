import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:openim/core/controller/auth_controller.dart';
import 'package:openim/core/controller/client_config_controller.dart';
import 'package:openim/core/controller/gateway_config_controller.dart';
import 'package:openim/pages/contacts/friend_list_logic.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../core/controller/app_controller.dart';
import '../../core/controller/im_controller.dart';
import '../../core/im_callback.dart';
import '../../routes/app_navigator.dart';
import '../contacts/add_by_search/add_by_search_logic.dart';
import '../home/home_logic.dart';

class ConversationLogic extends SuperController {
  @override
  void onDetached() {
    // Add any custom logic here if needed
  }

  @override
  void onHidden() {
    // Add any custom logic here if needed
  }

  @override
  void onInactive() {
    // Add any custom logic here if needed
  }

  @override
  void onPaused() {
    // Add any custom logic here if needed
  }
  final authController = Get.find<AuthController>();
  final gatewayConfigController = Get.find<GatewayConfigController>();
  final list =
      <ConversationInfo>[].obs; // Single list containing ALL conversations
  final imLogic = Get.find<IMController>();
  final clientConfigLogic = Get.find<ClientConfigController>();
  final homeLogic = Get.find<HomeLogic>();
  final appLogic = Get.find<AppController>();
  final friendListLogic = Get.find<FriendListLogic>();
  final refreshController = RefreshController();
  final tempDraftText = <String, String>{};
  final scrollController = ScrollController();
  final RxInt unreadConversationCount = 0.obs;

  final isInChina = false.obs;
  final RxInt conversationCount = 0.obs;

  final imStatus = IMSdkStatus.connectionSucceeded.obs;
  bool reInstall = false;

  bool _hasLoadedOnce = false;

  final announcement = Rx<Announcement?>(null);
  final systemAnnouncementList = <Announcement>[].obs;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  int scrollIndex = -1;

  final RxBool isConnected = true.obs;
  late final StreamSubscription _subscription;

  // AI Chat variables
  final RxBool isAIChatMode = false.obs;
  final RxBool isAIThinking = false.obs;
  final RxList<Map<String, dynamic>> aiChatMessages =
      <Map<String, dynamic>>[].obs;
  final aiTextController = TextEditingController();
  final aiFocusNode = FocusNode();
  final aiScrollController = ScrollController();

  // Store online status for users
  final Map<String, bool> userOnlineStatusMap = <String, bool>{};
  StreamSubscription? _userOnlineStatusChangedSub;

  // Tab filter variables
  final RxInt selectedTabIndex = 0.obs; // 0: All, 1: Unread
  List<String> get tabTitles => [StrRes.globalSearchAll, StrRes.unread];

  // String get selfNickName => imLogic.userInfo.value.nickname!;

  // Friends list for horizontal display
  List<ISUserInfo> get friendList => friendListLogic.friendList;

  // Filtered conversation list
  RxList<ConversationInfo> get filteredList {
    if (selectedTabIndex.value == 0) {
      // All conversations
      return list;
    } else {
      // Unread conversations only
      return list
          .where((conversation) => conversation.unreadCount > 0)
          .toList()
          .obs;
    }
  }

  String get getUnreadText =>
      '${StrRes.unreadConversations}: ${unreadConversationCount.value} '
      '· ${StrRes.unreadMessages}: ${homeLogic.unreadMsgCount.value}';

  // Switch tab method
  void switchTab(int index) {
    selectedTabIndex.value = index;
  }

  @override
  void onInit() {
    // Clear friends list immediately when initializing to prevent showing old data
    userOnlineStatusMap.clear();

    checkIsInChina();
    getConversationFirstPage();
    imLogic.conversationAddedSubject.listen(onChanged);
    imLogic.conversationChangedSubject.listen(onChanged);
    homeLogic.onScrollToUnreadMessage = scrollTo;
    imLogic.imSdkStatusSubject.listen((value) async {
      final status = value.status;
      final appReInstall = value.reInstall;
      final progress = value.progress;
      imStatus.value = status;

      if (status == IMSdkStatus.syncStart) {
        reInstall = appReInstall;
        // As soon as sync starts for a (re)login/account switch, hide carousel and clear stale data
        if (reInstall) {
          EasyLoading.showProgress(0, status: StrRes.synchronizing);
        }
      }

      Logger.print(
          'IM SDK Status: $status, reinstall: $reInstall, progress: $progress');

      if (status == IMSdkStatus.syncProgress && reInstall) {
        final p = (progress!).toDouble() / 100.0;

        EasyLoading.showProgress(p,
            status: '${StrRes.synchronizing}(${(p * 100.0).truncate()}%)');
      } else if (status == IMSdkStatus.syncEnded ||
          status == IMSdkStatus.syncFailed) {
        EasyLoading.dismiss();
        onRefresh();
        // Refresh friends list when sync is completed (after login)
      }
    });
    _initNetworkListener();

    if (gatewayConfigController.enableNetworkCheckAndFallback) {
      monitorIMFailures();
    }

    debounce(list, (newList) {
      Logger.print(
          'debounce ConversationList changed: ${newList.length} items');
      handleListChange(newList);
    }, time: const Duration(seconds: 1));

    super.onInit();
  }

  @override
  void onResumed() {
    Future.delayed(const Duration(seconds: 1), () {
      if (list.isEmpty && !_hasLoadedOnce) {
        onRefresh();
      }
    });
  }

  Future<void> checkIsInChina() async {
    try {
      final isChina = await _checkWithIpApi() ?? await _checkWithIpInfo();
      print('isChina111: $isChina');
      isInChina.value = isChina ?? false;
      if (!isInChina.value) {
        _loadAIChatMessages();
      }
    } catch (e) {
      debugPrint('Error checking if in China: $e');
    }
  }

  Future<bool?> _checkWithIpApi() async {
    try {
      final response = await http
          .get(
            Uri.parse(
                'http://ip-api.com/json/?fields=status,country,countryCode'),
          )
          .timeout(const Duration(seconds: 5));

      debugPrint('ip-api.com response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final countryCode = data['countryCode'] as String?;
          final isChina =
              countryCode == 'CN' || countryCode == 'HK' || countryCode == 'TW';
          debugPrint('ip-api.com: countryCode=$countryCode, isChina=$isChina');
          return isChina;
        }
      }
    } catch (e) {
      debugPrint('ip-api.com error: $e');
    }
    return null;
  }

  Future<bool?> _checkWithIpInfo() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://ipinfo.io/json'),
          )
          .timeout(const Duration(seconds: 5));

      debugPrint('ipinfo.io response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final country = data['country'] as String?;
        final isChina = country == 'CN';
        debugPrint('ipinfo.io: country=$country, isChina=$isChina');
        return isChina;
      }
    } catch (e) {
      debugPrint('ipinfo.io error: $e');
    }
    return null;
  }

  /// Check if user is online (for single chat)
  bool isUserOnline(ConversationInfo info) {
    if (info.isSingleChat && info.userID != null) {
      return userOnlineStatusMap[info.userID] ?? false;
    }
    return false;
  }

  /// Check if friend is online
  bool isFriendOnline(ISUserInfo friend) {
    return userOnlineStatusMap[friend.userID] ?? false;
  }

  /// Start chat with friend from friends carousel
  void chatWithFriend(ISUserInfo friend) {
    toChat(
      userID: friend.userID,
      nickname: friend.showName,
      faceURL: friend.faceURL,
      sessionType: ConversationType.single,
    );
  }

  void _refreshAnnouncement() async {
    final result = await ChatApis.getAnnouncement();
    systemAnnouncementList.value = result['systemAnnouncements']!;
    final popupAnnouncements = result['popupAnnouncements']!;
    for (var announcement in popupAnnouncements) {
      await viewAnnouncement(announcement);
    }
  }

  Future<void> markAnnouncementAsRead(Announcement announcement) async {
    await ChatApis.readAnnouncement(announcement.id);
    systemAnnouncementList.removeWhere((a) => a.id == announcement.id);
  }

  viewAnnouncement(Announcement announcement) async {
    markAnnouncementAsRead(announcement);
    return await Get.dialog(CustomDialog(
      title: announcement.title,
      content: announcement.content,
      showCancel: false,
      scrollable: true,
    ));
  }

  @override
  void onClose() {
    reInstall = false;
    _subscription.cancel();
    userOnlineStatusMap.clear();
    _userOnlineStatusChangedSub?.cancel();
    aiTextController.dispose();
    aiFocusNode.dispose();
    aiScrollController.dispose();
    scrollController.dispose();

    super.onClose();
  }

  void _initNetworkListener() async {
    final result = await Connectivity().checkConnectivity();
    isConnected.value = !result.contains(ConnectivityResult.none);
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      isConnected.value = !result.contains(ConnectivityResult.none);
    });
  }

  /// 会话列表通过回调更新
  void onChanged(newList) {
    Logger.print('======== conversation changed: ${newList.length} ========');

    int removedCount = 0;
    int unreadStatusChanges = 0;

    for (var newValue in newList) {
      // Check if conversation exists in list
      final existingConv = list
          .firstWhereOrNull((c) => c.conversationID == newValue.conversationID);

      if (existingConv != null) {
        // Existing conversation - remove it first
        list.removeWhere((c) => c.conversationID == newValue.conversationID);
        removedCount++;

        // Check if unread STATUS changed
        final hadUnread = existingConv.unreadCount > 0;
        final hasUnread = newValue.unreadCount > 0;

        if (!hadUnread && hasUnread) {
          unreadStatusChanges++;
          Logger.print(
              'Conversation ${newValue.showName} changed to UNREAD (${existingConv.unreadCount} → ${newValue.unreadCount})');
        } else if (hadUnread && !hasUnread) {
          unreadStatusChanges--;
          Logger.print(
              'Conversation ${newValue.showName} changed to READ (${existingConv.unreadCount} → ${newValue.unreadCount})');
        } else if (hadUnread && hasUnread) {
          Logger.print(
              'Conversation ${newValue.showName} still UNREAD (${existingConv.unreadCount} → ${newValue.unreadCount})');
        }
      } else {
        // New conversation
        if (newValue.unreadCount > 0) {
          unreadStatusChanges++;
          Logger.print(
              'New conversation ${newValue.showName} with UNREAD (${newValue.unreadCount})');
        }
      }
    }

    // Add all new/updated conversations
    list.addAll(newList);
    _sortConversationList();

    if (newList is List<ConversationInfo>) {
      conversationCount.value =
          (conversationCount.value + newList.length - removedCount);

      unreadConversationCount.value =
          (unreadConversationCount.value + unreadStatusChanges)
              .clamp(0, double.infinity)
              .toInt();
    }
  }

  /// 提示音
  void promptSoundOrNotification(ConversationInfo info) {
    if (imLogic.userInfo.value.globalRecvMsgOpt == 0 &&
        info.recvMsgOpt == 0 &&
        info.unreadCount > 0 &&
        info.latestMsg?.sendID != OpenIM.iMManager.userID) {
      // appLogic.promptSoundOrNotification(info.latestMsg!.seq!);
    }
  }

  @override
  void onReady() {
    onRefresh();
    _refreshAnnouncement();
    super.onReady();
  }

  void handleListChange(List<ConversationInfo> newList) {
    _subscribeToNewUsers(newList);
  }

  /// Subscribe to new users' status
  final Set<String> _subscribedUserIDs = {};

  void _subscribeToNewUsers(List<ConversationInfo> newList) async {
    final newSingleChatUserIDs = newList
        .where((info) => info.isSingleChat && info.userID != null)
        .map((info) => info.userID!)
        .toSet();

    final toSubscribe = newSingleChatUserIDs.difference(_subscribedUserIDs);

    if (toSubscribe.isNotEmpty) {
      final aggregate = _subscribedUserIDs.union(toSubscribe).toList();
      await OpenIM.iMManager.userManager.subscribeUsersStatus(aggregate).then(
        (userStatusInfoList) {
          for (var info in userStatusInfoList) {
            if (info.userID != null) {
              userOnlineStatusMap[info.userID!] = info.status == 1;
            }
          }
          _subscribedUserIDs.addAll(toSubscribe);
          list.refresh();
          friendListLogic.friendListRefresh();
        },
      );

      // Listen to user status changes
      _userOnlineStatusChangedSub =
          imLogic.userStatusChangedSubject.listen((userStatus) {
        if (userStatus.userID != null) {
          userOnlineStatusMap[userStatus.userID!] = userStatus.status == 1;
          // Refresh the list to update online indicators
          list.refresh();
          friendListLogic.friendListRefresh();
        }
      });
    }
  }

  Future<void> ensureUserStatusSubscribed(String userID) async {
    if (_subscribedUserIDs.contains(userID)) return;
    final aggregate = _subscribedUserIDs.union({userID}).toList();
    await OpenIM.iMManager.userManager.subscribeUsersStatus(aggregate).then(
      (userStatusInfoList) {
        for (var info in userStatusInfoList) {
          if (info.userID != null) {
            userOnlineStatusMap[info.userID!] = info.status == 1;
          }
        }
        _subscribedUserIDs.add(userID);
        list.refresh();
        friendListLogic.friendListRefresh();
      },
    );
  }

  String getConversationID(ConversationInfo info) {
    return info.conversationID;
  }

  /// 标记会话已读
  void markMessageHasRead(ConversationInfo info) {
    _markMessageHasRead(info);
  }

  /// 置顶会话
  void pinConversation(ConversationInfo info) async {
    OpenIM.iMManager.conversationManager.pinConversation(
      conversationID: info.conversationID,
      isPinned: !info.isPinned!,
    );
  }

  /// 删除会话
  void deleteConversation(ConversationInfo info) async {
    await OpenIM.iMManager.conversationManager
        .deleteConversationAndDeleteAllMsg(
      conversationID: info.conversationID,
    );
    final removed = list.remove(info);
    if (removed) {
      conversationCount.value =
          (conversationCount.value - 1).clamp(0, double.infinity).toInt();

      // Only decrement unread count if the deleted conversation had unread messages
      if (info.unreadCount > 0) {
        unreadConversationCount.value = (unreadConversationCount.value - 1)
            .clamp(0, double.infinity)
            .toInt();
      }
    }
  }

  /// 根据id移除会话
  void removeConversation(String id) {
    // Find conversations to be removed and count how many have unread messages
    final conversationsToRemove =
        list.where((e) => e.conversationID == id).toList();
    final removedUnreadCount =
        conversationsToRemove.where((c) => c.unreadCount > 0).length;

    final initialLength = list.length;
    list.removeWhere((e) => e.conversationID == id);
    final removedCount = initialLength - list.length;

    if (removedCount > 0) {
      conversationCount.value = (conversationCount.value - removedCount)
          .clamp(0, double.infinity)
          .toInt();

      // Only subtract the number of removed conversations that had unread messages
      unreadConversationCount.value =
          (unreadConversationCount.value - removedUnreadCount)
              .clamp(0, double.infinity)
              .toInt();
    }
  }

  /// 设置草稿
  void setConversationDraft({required String cid, required String draftText}) {
    OpenIM.iMManager.conversationManager.setConversationDraft(
      conversationID: cid,
      draftText: draftText,
    );
  }

  /// 会话前缀标签
  String? getPrefixTag(ConversationInfo info) {
    String? prefix;
    try {
      // 草稿
      if (null != info.draftText && '' != info.draftText) {
        var map = json.decode(info.draftText!);
        String text = map['text'];
        if (text.isNotEmpty) {
          prefix = '[${StrRes.draftText}]';
        }
      } else {
        switch (info.groupAtType) {
          case GroupAtType.atAll:
            prefix = '[@${StrRes.everyone}]';
            break;
          case GroupAtType.atAllAtMe:
            prefix = '[@${StrRes.everyone} @${StrRes.you}]';
            break;
          case GroupAtType.atMe:
            prefix = '[${StrRes.someoneMentionYou}]';
            break;
          case GroupAtType.atNormal:
            break;
          case GroupAtType.groupNotification:
            prefix = '[${StrRes.groupAc}]';
            break;
        }
      }
    } catch (e, s) {
      Logger.print('e: $e  s: $s');
    }

    return prefix;
  }

  /// 解析消息内容
  String getContent(ConversationInfo info) {
    try {
      final draft = _parseDraft(info.draftText);
      if (draft != null) return draft;

      final msg = info.latestMsg;
      if (msg == null) return '';

      bool isGroup = info.isGroupChat;
      if (isGroup) {
        if (clientConfigLogic.isMessageHidden(msg)) {
          return '-';
        }
      }

      final parsedNtf = IMUtils.parseNtf(msg, isConversation: true);
      if (parsedNtf != null) return parsedNtf;

      final isMySingleChat =
          info.isSingleChat || msg.sendID == OpenIM.iMManager.userID;
      if (isMySingleChat) {
        return IMUtils.parseMsg(info.latestMsg!,
            isConversation: true, replaceIdToNickname: true);
      }

      final renderName =
          imLogic.userRemarkMap[msg.sendID] ?? msg.senderNickname;
      final parsedMsg = IMUtils.parseMsg(msg, isConversation: true);
      return '$renderName: $parsedMsg';
    } catch (e, s) {
      Logger.print('------e:$e s:$s');
    }
    return '[${StrRes.unsupportedMessage}]';
  }

  String? _parseDraft(String? draftText) {
    if (draftText?.isEmpty ?? true) return null;
    try {
      final map = json.decode(draftText!);
      final text = map['text'];
      return text?.isNotEmpty == true ? text : null;
    } catch (_) {
      return null;
    }
  }

  Map<String, String> getAtUserMap(ConversationInfo info) {
    if (null != info.draftText && '' != info.draftText!.trim()) {
      var map = json.decode(info.draftText!);
      var atMap = map['at'];
      if (atMap.isNotEmpty && atMap is Map) {
        var v = <String, String>{};
        atMap.forEach((key, value) {
          v.addAll({'$key': "$value"});
        });
        return v;
      }
    }
    if (info.isGroupChat) {
      final map = <String, String>{};
      var message = info.latestMsg;
      if (message?.contentType == MessageType.atText) {
        var list = message!.atTextElem!.atUsersInfo;
        list?.forEach((e) {
          map[e.atUserID!] = e.groupNickname ?? e.atUserID!;
        });
      }
      return map;
    }
    return {};
  }

  /// 头像
  String? getAvatar(ConversationInfo info) {
    return info.faceURL;
  }

  bool isGroupChat(ConversationInfo info) {
    return info.isGroupChat;
  }

  /// 显示名
  String getShowName(ConversationInfo info) {
    if (info.showName == null || info.showName.isBlank!) {
      return info.userID!;
    }
    return info.showName!;
  }

  /// 时间
  String getTime(ConversationInfo info) {
    return IMUtils.getChatTimeline(info.latestMsgSendTime!);
  }

  /// 未读数
  int getUnreadCount(ConversationInfo info) {
    return info.unreadCount;
  }

  bool existUnreadMsg(ConversationInfo info) {
    return getUnreadCount(info) > 0;
  }

  /// 判断置顶
  bool isPinned(ConversationInfo info) {
    return info.isPinned!;
  }

  bool isNotDisturb(ConversationInfo info) {
    return info.recvMsgOpt != 0;
  }

  bool isUserGroup(int index) => list.elementAt(index).isGroupChat;

  /// 草稿
  /// 聊天页调用，不通过onWillPop事件返回，因为该事件会拦截ios的左滑返回上一页。
  void updateDartText({
    String? conversationID,
    required String text,
  }) {
    if (null != conversationID) tempDraftText[conversationID] = text;
  }

  /// 清空未读消息数
  void _markMessageHasRead(
    ConversationInfo conversation,
  ) {
    if (conversation.unreadCount == 0) {
      return;
    }

    OpenIM.iMManager.conversationManager.markConversationMessageAsRead(
      conversationID: conversation.conversationID,
    );
  }

  /// 设置草稿
  void _setupDraftText({
    required String conversationID,
    required String oldDraftText,
    required String newDraftText,
  }) {
    if (oldDraftText.isEmpty && newDraftText.isEmpty) {
      return;
    }

    /// 保存草稿
    Logger.print('draftText:$newDraftText');
    OpenIM.iMManager.conversationManager.setConversationDraft(
      conversationID: conversationID,
      draftText: newDraftText,
    );
  }

  String? get imSdkStatus {
    switch (imStatus.value) {
      case IMSdkStatus.syncStart:
      case IMSdkStatus.synchronizing:
      case IMSdkStatus.syncProgress:
        return StrRes.synchronizing;
      case IMSdkStatus.syncFailed:
        return StrRes.syncFailed;
      case IMSdkStatus.connecting:
        return StrRes.connecting;
      case IMSdkStatus.connectionFailed:
        return StrRes.connectionFailed;
      case IMSdkStatus.connectionSucceeded:
      case IMSdkStatus.syncEnded:
        return null;
    }
  }

  bool get isLoadingStatus =>
      imStatus.value == IMSdkStatus.syncStart ||
      imStatus.value == IMSdkStatus.connecting ||
      imStatus.value == IMSdkStatus.syncProgress ||
      imStatus.value == IMSdkStatus.synchronizing;

  bool get isFailedSdkStatus =>
      imStatus.value == IMSdkStatus.connectionFailed ||
      imStatus.value == IMSdkStatus.syncFailed;

  bool get showLoading => !reInstall && isLoadingStatus;

  String get titleText {
    if (showLoading) return '连接中';
    if (imSdkStatus != null) {
      return imSdkStatus!;
    }
    // return selfNickName;
    return StrRes.conversations;
  }

  /// 自定义会话列表排序规则
  void _sortConversationList() =>
      OpenIM.iMManager.conversationManager.simpleSort(list);

  void onRefresh() async {
    Logger.print('======== onRefresh: Reloading all conversations ========');

    try {
      // Load all conversations
      final allConversations =
          await OpenIM.iMManager.conversationManager.getAllConversationList();
      list.assignAll(allConversations);
      _sortConversationList();

      // Update counts
      conversationCount.value = list.length;
      unreadConversationCount.value =
          list.where((conversation) => conversation.unreadCount > 0).length;

      _hasLoadedOnce = true;

      refreshController.loadNoData(); // No pagination, so no more data to load

      Logger.print('Loaded ${list.length} total conversations');
    } catch (e) {
      Logger.print('Error in onRefresh: $e');
      refreshController.loadFailed();
    } finally {
      refreshController.refreshCompleted();
    }
  }

  void getConversationFirstPage() async {
    try {
      // Load all conversations
      final allConversations =
          await OpenIM.iMManager.conversationManager.getAllConversationList();
      list.assignAll(allConversations);
      handleListChange(allConversations);
      _sortConversationList();

      // Update counts
      conversationCount.value = list.length;
      unreadConversationCount.value =
          list.where((conversation) => conversation.unreadCount > 0).length;

      _hasLoadedOnce = true;

      Logger.print('Initialized with ${list.length} total conversations');
    } catch (e) {
      Logger.print('Error loading conversations: $e');
      list.clear();
    }
  }

  Future<bool> checkIfUserInGroup(ConversationInfo conv) async {
    try {
      final isInGroup = await OpenIM.iMManager.groupManager.isJoinedGroup(
        groupID: conv.groupID!,
      );

      if (!isInGroup) {
        _removeConversation(conv);
        return false;
      }

      var list = await OpenIM.iMManager.groupManager.getGroupsInfo(
        groupIDList: [conv.groupID!],
      );

      final groupInfo = list.firstOrNull;
      if (groupInfo != null) {
        bool isDismissed = groupInfo.status == 2;
        bool isOwner = groupInfo.creatorUserID == OpenIM.iMManager.userID;

        if (isDismissed && !isOwner) {
          _removeConversation(conv);
          return false;
        }
      }
      return true;
    } catch (e) {
      print('Error checking user in group: $e');
      return true;
    }
  }

  void _removeConversation(ConversationInfo conv) async {
    // 删除群会话
    await OpenIM.iMManager.conversationManager
        .deleteConversationAndDeleteAllMsg(
      conversationID: conv.conversationID,
    );

    removeConversation(conv.conversationID);
  }

  bool isValidConversation(ConversationInfo info) {
    return info.isValid;
  }

  void scrollTo() {
    if (list.isEmpty) return;

    // Find first unread conversation
    var currentIndex = 0;
    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      if (item.unreadCount > 0) {
        currentIndex = i;
        break;
      }
    }

    scrollIndex = currentIndex;

    // Calculate scroll position (each item ~90.h height)
    final itemHeight = 90.0; // Approximate item height
    final scrollPosition = currentIndex * itemHeight;

    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  static Future<ConversationInfo> _createConversation({
    required String sourceID,
    required int sessionType,
  }) =>
      LoadingView.singleton.wrap(
          asyncFunction: () =>
              OpenIM.iMManager.conversationManager.getOneConversation(
                sourceID: sourceID,
                sessionType: sessionType,
              ));

  /// 打开系统通知页面
  Future<bool> _jumpOANtf(ConversationInfo info) async {
    if (info.conversationType == ConversationType.notification) {
      // 系统通知
      await AppNavigator.startOANtfList(info: info);
      // 标记已读
      _markMessageHasRead(info);
      return true;
    }
    return false;
  }

  static const int _failureThreshold = 15;
  int _failureCount = 0;

  static const int _connectingTimeoutSeconds = 40;
  bool _connectingAlertShown = false;
  Timer? _connectingTimer;

  void monitorIMFailures() {
    imLogic.imSdkStatusSubject.listen((value) async {
      final status = value.status;

      // ------------------ 失败次数统计 ------------------
      if (status == IMSdkStatus.connectionFailed ||
          status == IMSdkStatus.syncFailed) {
        _failureCount++;

        if (_failureCount >= _failureThreshold) {
          _failureCount = 0;
          await _showAlert('系统提示', '连接失败次数过多，请检查网络或稍后重试');
        }
        return;
      }

      // ------------------ 长时间 connecting ------------------
      if (status == IMSdkStatus.connecting) {
        _connectingTimer ??=
            Timer(const Duration(seconds: _connectingTimeoutSeconds), () async {
          if (!_connectingAlertShown) {
            _connectingAlertShown = true;
            await _showAlert('系统提示', '长时间连接中，请检查网络或稍后重试');
          }
        });
        return;
      }

      // ------------------ 非 connecting 状态 ------------------
      _failureCount = 0;
      _connectingAlertShown = false;

      _connectingTimer?.cancel();
      _connectingTimer = null;
    });
  }

  final MerchantController merchantController = Get.find<MerchantController>();

  IMServerInfo get currentIMServerInfo =>
      merchantController.currentIMServerInfo.value;

  List<IMServerInfo> get fallbackIMServerInfoList =>
      merchantController.fallbackServerInfoList;

  Future<void> _showAlert(String title, String content) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasNetwork = !connectivityResult.contains(ConnectivityResult.none);
    if (hasNetwork) {
      await Get.dialog(CustomDialog(
        title: title,
        content: content,
        showCancel: false,
      ));
      final merchant =
          await GatewayApi.searchMerchantByID(currentIMServerInfo.merchantID);
      final merchantServers = MerchantServers.fromApiJson(merchant.toJson());
      if (_needReInit(currentIMServerInfo, merchantServers.main)) {
        authController.refreshIm(imServerInfo: merchantServers.main);
      } else if (fallbackIMServerInfoList.isNotEmpty) {
        authController.refreshIm(imServerInfo: fallbackIMServerInfoList.first);
      }
    }
  }

  bool _needReInit(IMServerInfo oldS, IMServerInfo newS) {
    return oldS.apiAddr != newS.apiAddr ||
        oldS.wsAddr != newS.wsAddr ||
        oldS.chatAddr != newS.chatAddr;
  }

  /// 进入聊天页面
  void toChat({
    bool offUntilHome = true,
    String? userID,
    String? groupID,
    String? nickname,
    String? faceURL,
    int? sessionType,
    ConversationInfo? conversationInfo,
    Message? searchMessage,
  }) async {
    // 获取会话信息，若不存在则创建
    conversationInfo ??= await _createConversation(
      sourceID: userID ?? groupID!,
      sessionType: userID == null ? sessionType! : ConversationType.single,
    );

    // 标记已读
    // _markMessageHasRead(conversationID: conversationInfo.conversationID);

    // 如果是系统通知
    if (await _jumpOANtf(conversationInfo)) return;

    // 保存旧草稿
    updateDartText(
      conversationID: conversationInfo.conversationID,
      text: conversationInfo.draftText ?? '',
    );

    // 打开聊天窗口，关闭返回草稿
    /*var newDraftText = */
    await AppNavigator.startChat(
      offUntilHome: offUntilHome,
      draftText: conversationInfo.draftText,
      conversationInfo: conversationInfo,
      searchMessage: searchMessage,
    );

    // 读取草稿
    var newDraftText = tempDraftText[conversationInfo.conversationID];

    // 标记已读
    _markMessageHasRead(conversationInfo);

    // 记录草稿
    _setupDraftText(
      conversationID: conversationInfo.conversationID,
      oldDraftText: conversationInfo.draftText ?? '',
      newDraftText: newDraftText!,
    );

    // 回到会话列表
    // homeLogic.switchTab(0);

    bool equal(e) => e.conversationID == conversationInfo?.conversationID;
    // 删除所有@标识/公告标识
    var groupAtType = list.firstWhereOrNull(equal)?.groupAtType;
    if (groupAtType != GroupAtType.atNormal) {
      // ignore: deprecated_member_use
      OpenIM.iMManager.conversationManager.resetConversationGroupAtType(
        conversationID: conversationInfo.conversationID,
      );
    }
  }

  scan() => AppNavigator.startScan();

  addFriend() =>
      AppNavigator.startAddContactsBySearch(searchType: SearchType.user);

  Future<void> createGroup() async {
    try {
      final result = await GatewayApi.getRealNameAuthInfo();
      final status = result['status'] ?? 0;
      if (status != 2) {
        var confirm = await Get.dialog(CustomDialog(
          title: StrRes.realNameAuthRequiredForGroup,
          rightText: StrRes.goToRealNameAuth,
        ));
        if (confirm == true) AppNavigator.startRealNameAuth();
        return;
      }
    } catch (e) {
      var confirm = await Get.dialog(CustomDialog(
        title: StrRes.realNameAuthRequiredForGroup,
        rightText: StrRes.goToRealNameAuth,
      ));
      if (confirm == true) AppNavigator.startRealNameAuth();
      return;
    }

    AppNavigator.startCreateGroup(
        defaultCheckedList: [OpenIM.iMManager.userInfo]);
  }

  addGroup() =>
      AppNavigator.startAddContactsBySearch(searchType: SearchType.group);

  void globalSearch() => AppNavigator.startGlobalSearch();

  // AI Chat Methods
  void toggleAIChatMode() {
    isAIChatMode.value = !isAIChatMode.value;
    if (isAIChatMode.value) {
      aiFocusNode.requestFocus();
      // Scroll to bottom after opening AI chat
      _scrollToBottom();
      _loadAIChatMessages();
    } else {
      aiFocusNode.unfocus();
      aiTextController.clear();
    }
  }

  void exitAIChatMode() {
    isAIChatMode.value = false;
    aiFocusNode.unfocus();
    aiTextController.clear();
  }

  // Scroll to bottom of AI chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (aiScrollController.hasClients) {
        aiScrollController.animateTo(
          aiScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessageToAI() async {
    final message = aiTextController.text.trim();
    if (message.isEmpty) return;

    // Add user message to chat
    aiChatMessages.add({
      'isUser': true,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });

    aiTextController.clear();
    isAIThinking.value = true;

    // Scroll to bottom after adding user message
    _scrollToBottom();

    // Save messages after adding user message
    await _saveAIChatMessages();

    try {
      // Prepare chat history (exclude the current message we just added)
      final chatHistory = aiChatMessages
          .where((msg) => msg['isError'] != true) // Exclude error messages
          .take(aiChatMessages.length - 1) // Exclude the current message
          .toList();

      // Call Gemini API with chat history for context
      final response = await GatewayApi.sendMessageToGemini(
        message: message,
        chatHistory: chatHistory.isNotEmpty ? chatHistory : null,
      );

      // Add AI response to chat
      aiChatMessages.add({
        'isUser': false,
        'message': response,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Scroll to bottom after adding AI response
      _scrollToBottom();

      // Save messages after adding AI response
      await _saveAIChatMessages();
    } catch (e) {
      // Add error message
      aiChatMessages.add({
        'isUser': false,
        'message': 'Sorry, I encountered an error: ${e.toString()}',
        'timestamp': DateTime.now().toIso8601String(),
        'isError': true,
      });

      // Scroll to bottom after adding error message
      _scrollToBottom();

      // Save messages even on error
      await _saveAIChatMessages();
    } finally {
      isAIThinking.value = false;
    }
  }

  // Load AI chat messages from SharedPreferences
  void _loadAIChatMessages() {
    try {
      final savedMessages = DataSp.getAIChatMessages();
      if (savedMessages.isNotEmpty) {
        aiChatMessages.assignAll(savedMessages);
      }
    } catch (e) {
      Logger.print('Error loading AI chat messages: $e');
    }
  }

  // Save AI chat messages to SharedPreferences
  Future<void> _saveAIChatMessages() async {
    try {
      final messagesToSave = aiChatMessages.map((msg) {
        return {
          'isUser': msg['isUser'],
          'message': msg['message'],
          'timestamp': msg['timestamp'] is DateTime
              ? (msg['timestamp'] as DateTime).toIso8601String()
              : msg['timestamp'],
          if (msg['isError'] == true) 'isError': true,
        };
      }).toList();

      await DataSp.putAIChatMessages(messagesToSave);
    } catch (e) {
      Logger.print('Error saving AI chat messages: $e');
    }
  }

  // Clear AI chat history
  Future<void> clearAIChatHistory() async {
    aiChatMessages.clear();
    await DataSp.clearAIChatMessages();
  }
}
