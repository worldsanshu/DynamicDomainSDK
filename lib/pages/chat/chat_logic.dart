// ignore_for_file: unused_element, unused_field, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:common_utils/common_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mime/mime.dart';
import 'package:openim/core/controller/client_config_controller.dart';
import 'package:openim_common/openim_common.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_browser/photo_browser.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_compress/video_compress.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import '../../core/controller/app_controller.dart';
import '../../core/controller/im_controller.dart';
import '../../core/im_callback.dart';
import 'dart:math' as math;
import '../../core/controller/trtc_controller.dart';
import '../../routes/app_navigator.dart';
import '../../routes/app_pages.dart';
import '../contacts/select_contacts/select_contacts_logic.dart';
import '../conversation/conversation_logic.dart';
import 'group_setup/group_member_list/group_member_list_logic.dart';

import 'package:scroll_to_index/scroll_to_index.dart';

import 'message_frequency_logic.dart';

class ChatLogic extends SuperController with FullLifeCycleMixin {
  final imLogic = Get.find<IMController>();
  final appLogic = Get.find<AppController>();
  final clientConfigLogic = Get.find<ClientConfigController>();
  final messageFrequencyController = Get.find<MessageFrequencyController>();
  final conversationLogic = Get.find<ConversationLogic>();
  final cacheLogic = Get.find<CacheController>();
  final downloadLogic = Get.find<DownloadController>();
  final onlineInfoLogic = Get.find<OnlineInfoController>();
  final trtcLogic = Get.find<TRTCController>();

  final inputCtrl = TextEditingController();
  final focusNode = FocusNode();
  final scrollController = AutoScrollController();
  final refreshController = RefreshController();
  final browserController = PhotoBrowserController();
  late GlobalKey chatInputBoxStateKey;
  bool playOnce = false; // 点击的当前视频只能播放一次
  final isInputFocused = false.obs;
  // final clickSubject = PublishSubject<Message>();
  final forceCloseToolbox = PublishSubject<bool>();
  final forceCloseMenuSub = PublishSubject<bool>();
  final sendStatusSub = PublishSubject<MsgStreamEv<bool>>();
  final sendProgressSub = BehaviorSubject<MsgStreamEv<int>>();
  final downloadProgressSub = PublishSubject<MsgStreamEv<double>>();
  final favoriteEmojiList = <String>[].obs;

  final keyboardHeight = 300.h.obs;

  late ConversationInfo conversationInfo;
  Message? searchMessage;
  final nickname = ''.obs;
  final faceUrl = ''.obs;
  Timer? typingTimer;
  final typing = false.obs;
  final intervalSendTypingMsg = IntervalDo();
  Message? quoteMsg;
  final messageList = <Message>[].obs;
  final quoteContent = "".obs;
  final multiSelMode = false.obs;
  final multiSelList = <Message>[].obs;
  bool get hasFailedMessageSelected =>
      multiSelList.any((e) => e.status == MessageStatus.failed);
  final atUserNameMappingMap = <String, String>{};
  final atUserInfoMappingMap = <String, UserInfo>{};
  final curMsgAtUser = <String>[];
  var _lastCursorIndex = -1;
  final onlineStatus = false.obs;
  final onlineStatusDesc = StrRes.offline.obs;
  Timer? onlineStatusTimer;
  final favoriteList = <String>[].obs;
  final scaleFactor = Config.textScaleFactor.obs;
  final background = "".obs;
  final memberUpdateInfoMap = <String, GroupMembersInfo>{};
  final groupMessageReadMembers = <String, List<String>>{};
  final groupMutedStatus = 0.obs;
  final groupMemberRoleLevel = 1.obs;
  final muteEndTime = 0.obs;
  GroupInfo? groupInfo;
  GroupMembersInfo? groupMembersInfo;
  List<GroupMembersInfo> ownerAndAdmin = [];

  // sdk的isNotInGroup不能用
  final isInGroup = true.obs;
  final memberCount = 0.obs;
  final privateMessageList = <Message>[];
  final isInBlacklist = false.obs;
  final _audioPlayer = AudioPlayer();
  final _currentPlayClientMsgID = "".obs;
  final isShowPopMenu = false.obs;

  // final _showMenuCacheMessageList = <Message>[];
  final scrollingCacheMessageList = <Message>[].obs;
  final announcement = ''.obs;
  late StreamSubscription conversationSub;
  late StreamSubscription memberAddSub;
  late StreamSubscription memberDelSub;
  late StreamSubscription joinedGroupAddedSub;
  late StreamSubscription joinedGroupDeletedSub;
  late StreamSubscription memberInfoChangedSub;
  late StreamSubscription groupInfoUpdatedSub;
  late StreamSubscription friendInfoChangedSub;
  StreamSubscription? userStatusChangedSub;
  StreamSubscription? selfInfoUpdatedSub;

  late StreamSubscription connectionSub;
  final syncStatus = IMSdkStatus.syncEnded.obs;

  // late StreamSubscription signalingMessageSub;

  /// super group
  int? lastMinSeq;
  final showCallingMember = false.obs;

  /// 同步中收到了新消息
  bool _isReceivedMessageWhenSyncing = false;
  bool _isStartSyncing = false;
  bool _isFirstLoad = true;
  bool _isInitialized = false;

  final copyTextMap = <String?, String?>{};
  final revokedTextMessage = <String, String>{};

  String? groupOwnerID;

  /// GlobalKey to access voice recording state for navigation confirmation
  final voiceRecordKey = GlobalKey<ChatVoiceRecordLayoutState>();

  final _pageSize = 40;
  String? get userID => conversationInfo.userID;

  String? get groupID => conversationInfo.groupID;

  bool get isSingleChat => null != userID && userID!.trim().isNotEmpty;

  bool get isGroupChat => null != groupID && groupID!.trim().isNotEmpty;

  bool get isInitialized => _isInitialized;

  String get memberStr {
    final canShowCount = isGroupChat &&
        clientConfigLogic.shouldShowMemberCount(
          roleLevel: groupMemberRoleLevel.value,
        );
    return canShowCount ? '($memberCount)' : '';
  }

  String? get senderName => isSingleChat
      ? OpenIM.iMManager.userInfo.nickname
      : groupMembersInfo?.nickname;

  bool get isAdminOrOwner =>
      groupMemberRoleLevel.value == GroupRoleLevel.admin ||
      groupMemberRoleLevel.value == GroupRoleLevel.owner;
  bool get isOwner => groupMemberRoleLevel.value == GroupRoleLevel.owner;

  /// 是当前聊天窗口
  bool isCurrentChat(Message message) {
    var senderId = message.sendID;
    var receiverId = message.recvID;
    var groupId = message.groupID;
    // var sessionType = message.sessionType;
    var isCurSingleChat = message.isSingleChat &&
        isSingleChat &&
        (senderId == userID ||
            // 其他端当前登录用户向uid发送的消息
            senderId == OpenIM.iMManager.userID && receiverId == userID);
    var isCurGroupChat =
        message.isGroupChat && isGroupChat && groupID == groupId;
    return isCurSingleChat || isCurGroupChat;
  }

  void scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }
    });
  }

  void onScrollBottom() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  // Query multimedia messages and prepare for large image browsing.
  Future<List<Message>> searchMediaMessage() async {
    final messageList = await OpenIM.iMManager.messageManager
        .searchLocalMessages(
            conversationID: conversationInfo.conversationID,
            messageTypeList: [MessageType.picture, MessageType.video],
            count: 500);
    return messageList.searchResultItems?.first.messageList?.reversed
            .toList() ??
        [];
  }

  @override
  void onReady() {
    _readDraftText();
    _queryUserOnlineStatus();
    _resetGroupAtType();
    _getInputState();
    _clearUnreadCount();
    _loadFavoriteEmojis();

    if (isSingleChat && userID != null) {
      final cachedStatus = conversationLogic.userOnlineStatusMap[userID!];
      if (cachedStatus != null) {
        onlineStatus.value = cachedStatus;
        onlineStatusDesc.value = cachedStatus ? StrRes.online : StrRes.offline;
      }
    }

    scrollController.addListener(() {
      focusNode.unfocus();
    });
    super.onReady();
  }

  @override
  void onInit() {
    // timeDilation = 10.0;
    chatInputBoxStateKey = GlobalKey();
    var arguments = Get.arguments;
    print('=== ChatLogic.onInit ===');
    print('Arguments received: $arguments');
    final convInfo = arguments?['conversationInfo'];
    if (convInfo == null) {
      Logger.print('ERROR: conversationInfo is null in ChatLogic.onInit()');
      print('=== ChatLogic.onInit ERROR ===');
      print('arguments: $arguments');
      // Initialize with a placeholder to prevent LateInitializationError during build
      conversationInfo = ConversationInfo(conversationID: '');
      _isInitialized = false;
      // Schedule navigation back after build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        IMViews.showToast('Failed to open chat: conversation not found');
        Get.back();
      });
      return;
    }
    _isInitialized = true;
    conversationInfo = convInfo;
    // Defer clear() to after build phase to prevent "setState during build" error
    // because clear() modifies RxList which triggers Obx rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onlineInfoLogic.clear();
    });
    searchMessage = arguments['searchMessage'];
    nickname.value = conversationInfo.showName ?? '';
    faceUrl.value = conversationInfo.faceURL ?? '';
    _initChatConfig();
    _initPlayListener();
    _setSdkSyncDataListener();

    conversationSub = imLogic.conversationChangedSubject.listen((value) {
      final obj = value.firstWhereOrNull(
          (e) => e.conversationID == conversationInfo.conversationID);

      if (obj != null) {
        conversationInfo = obj;
      }
    });

    // 新增消息监听
    imLogic.onRecvNewMessage = (Message message) async {
      if (isCurrentChat(message)) {
        if (message.contentType == MessageType.typing) {
        } else {
          if (!messageList.contains(message) &&
              !scrollingCacheMessageList.contains(message)) {
            _isReceivedMessageWhenSyncing = true;
            _parseAnnouncement(message);
            if (isShowPopMenu.value ||
                (scrollController.hasClients && scrollController.offset != 0)) {
              scrollingCacheMessageList.add(message);
            } else {
              messageList.add(message);
              scrollBottom();
            }
            if (message.sendID != OpenIM.iMManager.userID &&
                scrollController.hasClients) {
              _markMessageAsRead(message, isNewMessage: true);
            }
            // ios 退到后台再次唤醒消息乱序
            // messageList.sort((a, b) {
            //   if (a.sendTime! > b.sendTime!) {
            //     return 1;
            //   } else if (a.sendTime! > b.sendTime!) {
            //     return -1;
            //   } else {
            //     return 0;
            //   }
            // });
          }
        }
      }
    };

    // 已被撤回消息监听（新版本）
    imLogic.onRecvMessageRevoked = (RevokedInfo info) async {
      print('=== onRecvMessageRevoked ===');
      print('Revoked data: ${jsonEncode(info)}');
      print('Current Playing ID: ${_currentPlayClientMsgID.value}');
      print('Revoked clientMsgID: ${info.clientMsgID}');

      if (info.clientMsgID != null &&
          _currentPlayClientMsgID.value.trim() == info.clientMsgID!.trim()) {
        print('=== Stopping Audio Player (matched ID) ===');
        await _audioPlayer.stop();
        _currentPlayClientMsgID.value = "";
      }
      var message = messageList
          .firstWhereOrNull((e) => e.clientMsgID == info.clientMsgID);
      message?.notificationElem = NotificationElem(detail: jsonEncode(info));
      message?.contentType = MessageType.revokeMessageNotification;
      // message?.content = jsonEncode(info);
      // message?.contentType = MessageType.advancedRevoke;
      formatQuoteMessage(info.clientMsgID!);

      if (null != message) {
        messageList.refresh();
      }
    };
    // 消息已读回执监听
    imLogic.onRecvC2CReadReceipt = (List<ReadReceiptInfo> list) {
      try {
        for (var readInfo in list) {
          if (readInfo.userID == userID) {
            for (var e in messageList) {
              if (readInfo.msgIDList?.contains(e.clientMsgID) == true) {
                e.isRead = true;
                e.hasReadTime = _timestamp;
              }
            }
          }
        }
        messageList.refresh();
      } catch (e) {}
    };

    // 消息发送进度
    imLogic.onMsgSendProgress = (String msgId, int progress) {
      sendProgressSub.addSafely(
        MsgStreamEv<int>(id: msgId, value: progress),
      );
    };

    joinedGroupAddedSub = imLogic.joinedGroupAddedSubject.listen((event) {
      if (event.groupID == groupID) {
        isInGroup.value = true;
        _queryGroupInfo();
      }
    });

    joinedGroupDeletedSub = imLogic.joinedGroupDeletedSubject.listen((event) {
      if (event.groupID == groupID) {
        isInGroup.value = false;
        inputCtrl.clear();
      }
    });

    // 有新成员进入
    memberAddSub = imLogic.memberAddedSubject.listen((info) {
      var groupId = info.groupID;
      if (groupId == groupID) {
        _putMemberInfo([info]);
      }
    });

    memberDelSub = imLogic.memberDeletedSubject.listen((info) {
      if (info.groupID == groupID && info.userID == OpenIM.iMManager.userID) {
        isInGroup.value = false;
        inputCtrl.clear();
      }
    });

    // 成员信息改变
    memberInfoChangedSub = imLogic.memberInfoChangedSubject.listen((info) {
      if (info.groupID == groupID) {
        if (info.userID == OpenIM.iMManager.userID) {
          muteEndTime.value = info.muteEndTime ?? 0;
          groupMemberRoleLevel.value = info.roleLevel ?? GroupRoleLevel.member;
          groupMembersInfo = info;
          _mutedClearAllInput();
        }
        _putMemberInfo([info]);

        final index = ownerAndAdmin
            .indexWhere((element) => element.userID == info.userID);
        if (info.roleLevel == GroupRoleLevel.member) {
          if (index > -1) {
            ownerAndAdmin.removeAt(index);
          }
        } else if (info.roleLevel == GroupRoleLevel.admin ||
            info.roleLevel == GroupRoleLevel.owner) {
          if (index == -1) {
            ownerAndAdmin.add(info);
          } else {
            ownerAndAdmin[index] = info;
          }
        }

        for (var msg in messageList) {
          if (msg.sendID == info.userID) {
            msg.senderFaceUrl = info.faceURL;
            msg.senderNickname = info.nickname;
          }
        }

        messageList.refresh();
      }
    });

    // 群信息变化
    groupInfoUpdatedSub = imLogic.groupInfoUpdatedSubject.listen((value) {
      if (groupID == value.groupID) {
        groupInfo = value;
        nickname.value = value.groupName ?? '';
        faceUrl.value = value.faceURL ?? '';
        groupMutedStatus.value = value.status ?? 0;
        _checkGroupBlockInfo();
        memberCount.value = value.memberCount ?? 0;
        _mutedClearAllInput();
      }
    });

    // 好友信息变化
    friendInfoChangedSub = imLogic.friendInfoChangedSubject.listen((value) {
      if (userID == value.userID) {
        nickname.value = value.getShowName();
        faceUrl.value = value.faceURL ?? '';

        for (var msg in messageList) {
          if (msg.sendID == value.userID) {
            msg.senderFaceUrl = value.faceURL;
            msg.senderNickname = value.nickname;
          }
        }

        messageList.refresh();
      }
    });

    selfInfoUpdatedSub = imLogic.selfInfoUpdatedSubject.listen((value) {
      Logger.print('======selfInfoUpdated: $value');
      for (var msg in messageList) {
        if (msg.sendID == value.userID) {
          msg.senderFaceUrl = value.faceURL;
          msg.senderNickname = value.nickname;
        }
      }

      messageList.refresh();
    });
    // 自定义消息点击事件
    // clickSubject.listen((Message message) {
    //   parseClickEvent(message);
    // });

    // 输入框监听
    inputCtrl.addListener(() {
      intervalSendTypingMsg.run(
        fuc: () => sendTypingMsg(focus: true),
        milliseconds: 2000,
      );

      final text = inputCtrl.text;
      if (text.contains('@')) {
        _parseAtMentionsFromPastedText(text);
      }

      clearCurAtMap();
      _updateDartText(createDraftText());
    });

    // 输入框聚焦
    focusNode.addListener(() {
      _lastCursorIndex = inputCtrl.selection.start;
      focusNodeChanged(focusNode.hasFocus);
    });

    imLogic.inputStateChangedSubject.listen((value) {
      if (value.conversationID == conversationInfo.conversationID &&
          value.userID == userID) {
        typing.value = value.platformIDs?.isNotEmpty == true;
      }
    });

    super.onInit();
  }

  void _loadFavoriteEmojis() {
    try {
      final savedEmojis =
          SpUtil().getStringList('favorite_emojis_${DataSp.userID}');
      if (savedEmojis != null && savedEmojis.isNotEmpty) {
        favoriteEmojiList.addAll(savedEmojis);
      }
    } catch (e) {
      Logger.print('Error loading favorite emojis: $e');
    }
  }

  void formatQuoteMessage(String focusClientMsgID) {
    var quotes = messageList
        .where(
            (element) => element.quoteMessage?.clientMsgID == focusClientMsgID)
        .toList();
    for (var element in quotes) {
      element.quoteMessage?.contentType = MessageType.text;
      element.quoteMessage?.textElem =
          TextElem(content: StrRes.quoteContentBeRevoked);
      element.quoteMessage?.soundElem = null;
      element.quoteMessage?.pictureElem = null;
      element.quoteMessage?.videoElem = null;
      element.quoteMessage?.fileElem = null;
    }
  }

  void chatSetup() {
    if (isBanned) {
      return;
    }
    // Cancel voice recording before navigating to settings
    _cancelVoiceRecordingIfActive();

    isSingleChat
        ? AppNavigator.startChatSetup(conversationInfo: conversationInfo)
        : AppNavigator.startGroupChatSetup(conversationInfo: conversationInfo);
  }

  void viewGroupOnlineInfo() {
    if (groupInfo != null) {
      AppNavigator.startGroupOnlineInfo(
        groupInfo: groupInfo!,
        isOwnerOrAdmin: isAdminOrOwner,
      );
    }
  }

  void clearCurAtMap() {
    curMsgAtUser.removeWhere((uid) {
      final nickname = atUserNameMappingMap[uid];
      if (nickname != null) {
        return !inputCtrl.text.contains('@$uid ') &&
            !inputCtrl.text.contains('@$nickname ');
      }
      return !inputCtrl.text.contains('@$uid ');
    });
  }

  void _parseAtMentionsFromPastedText(String text) {
    final atPattern = RegExp(r'@([^\s]+)\s');
    final matches = atPattern.allMatches(text);

    for (final match in matches) {
      final mentionText = match.group(1)!;

      String? userID;

      if (atUserInfoMappingMap.containsKey(mentionText)) {
        userID = mentionText;
      } else {
        atUserNameMappingMap.forEach((id, nickname) {
          if (nickname == mentionText) {
            userID = id;
            return;
          }
        });
      }

      if (userID != null && !curMsgAtUser.contains(userID!)) {
        curMsgAtUser.add(userID!);

        if (!atUserNameMappingMap.containsKey(userID!)) {
          _setAtMapping(
            userID: userID!,
            nickname: mentionText,
            faceURL: null,
          );
        }
      }
    }
  }

  /// 记录群成员信息
  void _putMemberInfo(List<GroupMembersInfo>? list) {
    list?.forEach((member) {
      _setAtMapping(
        userID: member.userID!,
        nickname: member.nickname!,
        faceURL: member.faceURL,
      );
      memberUpdateInfoMap[member.userID!] = member;
    });
    // 更新群成员信息
    messageList.refresh();
    atUserNameMappingMap[OpenIM.iMManager.userID] = StrRes.you;
    atUserInfoMappingMap[OpenIM.iMManager.userID] = OpenIM.iMManager.userInfo;

    // DataSp.putAtUserMap(groupID!, atUserNameMappingMap);
  }

  /// 发送文字内容，包含普通内容，引用回复内容，@内容
  void sendTextMsg() async {
    var content = IMUtils.safeTrim(inputCtrl.text);
    if (content.isEmpty) return;
    Message message;
    if (curMsgAtUser.isNotEmpty) {
      createAtInfoByID(id) => AtUserInfo(
            atUserID: id,
            groupNickname: atUserNameMappingMap[id],
          );

      // 发送 @ 消息
      if (curMsgAtUser.length > 10) {
        // Selection screen enforces max selection and shows a toast.
        // Keep the guard here but do not show toast at send time.
        return;
      }

      message = await OpenIM.iMManager.messageManager.createTextAtMessage(
        text: content,
        atUserIDList: curMsgAtUser,
        atUserInfoList: curMsgAtUser.map(createAtInfoByID).toList(),
        quoteMessage: quoteMsg,
      );
    } else if (quoteMsg != null) {
      // 发送引用消息
      message = await OpenIM.iMManager.messageManager.createQuoteMessage(
        text: content,
        quoteMsg: quoteMsg!,
      );
    } else {
      // 发送普通消息
      message = await OpenIM.iMManager.messageManager.createTextMessage(
        text: content,
      );
    }

    _sendMessage(message);
  }

  /// 发送图片
  Future<void> sendPicture({required String path}) async {
    final file = await IMUtils.compressImageAndGetFile(File(path));

    var message =
        await OpenIM.iMManager.messageManager.createImageMessageFromFullPath(
      imagePath: file!.path,
    );
    _sendMessage(message);
  }

  /// 发送语音
  void sendVoice(int duration, String path) async {
    var message =
        await OpenIM.iMManager.messageManager.createSoundMessageFromFullPath(
      soundPath: path,
      duration: duration,
    );
    _sendMessage(message);
  }

  ///  发送视频
  Future<void> sendVideo({
    required String videoPath,
    required String mimeType,
    required int duration,
    required String thumbnailPath,
  }) async {
    // 插件有bug，有些视频长度*1000
    var d = duration > 1000.0 ? duration / 1000.0 : duration;
    var message =
        await OpenIM.iMManager.messageManager.createVideoMessageFromFullPath(
      videoPath: videoPath,
      videoType: mimeType,
      duration: d.toInt(),
      snapshotPath: thumbnailPath,
    );
    _sendMessage(message);
  }

  /// 发送文件
  Future<void> sendFile(
      {required String filePath, required String fileName}) async {
    var message =
        await OpenIM.iMManager.messageManager.createFileMessageFromFullPath(
      filePath: filePath,
      fileName: fileName,
    );
    _sendMessage(message);
  }

  /// 转发内容的备注信息
  Future<Message> sendForwardRemarkMsg(
    String content, {
    String? userId,
    String? groupId,
    bool addToUI = true,
  }) async {
    final message = await OpenIM.iMManager.messageManager.createTextMessage(
      text: content,
    );
    _sendMessage(message, userId: userId, groupId: groupId, addToUI: addToUI);
    return message;
  }

  /// 转发
  Future<Message> sendForwardMsg(
    Message originalMessage, {
    String? userId,
    String? groupId,
    bool addToUI = true,
  }) async {
    var message = await OpenIM.iMManager.messageManager.createForwardMessage(
      message: originalMessage,
    );
    _sendMessage(message, userId: userId, groupId: groupId, addToUI: addToUI);
    return message;
  }

  /// 合并转发
  Future<void> sendMergeMsg({
    String? userId,
    String? groupId,
  }) async {
    var summaryList = <String>[];
    String title;
    for (var msg in multiSelList) {
      summaryList.add(IMUtils.createSummary(msg));
      if (summaryList.length >= 4) break;
    }
    if (isGroupChat) {
      title = "${StrRes.groupChat}${StrRes.chatRecord}";
    } else {
      var partner1 = OpenIM.iMManager.userInfo.getShowName();
      var partner2 = nickname.value;
      title = "$partner1${StrRes.and}$partner2${StrRes.chatRecord}";
    }
    var message = await OpenIM.iMManager.messageManager.createMergerMessage(
      messageList: multiSelList,
      title: title,
      summaryList: summaryList,
    );
    _sendMessage(message, userId: userId, groupId: groupId);
  }

  /// 提示对方正在输入
  void sendTypingMsg({bool focus = false}) async {
    if (isSingleChat) {
      OpenIM.iMManager.conversationManager.changeInputStates(
          conversationID: conversationInfo.conversationID, focus: focus);
    }
  }

  /// 发送名片
  void sendCarte({
    required String userID,
    String? nickname,
    String? faceURL,
  }) async {
    var message = await OpenIM.iMManager.messageManager.createCardMessage(
      userID: userID,
      nickname: nickname!,
      faceURL: faceURL,
    );
    _sendMessage(message);
  }

  /// 发送自定义消息
  void sendCustomMsg({
    required String data,
    required String extension,
    required String description,
  }) async {
    var message = await OpenIM.iMManager.messageManager.createCustomMessage(
      data: data,
      extension: extension,
      description: description,
    );
    _sendMessage(message);
  }

  void _sendMessage(
    Message message, {
    String? userId,
    String? groupId,
    bool addToUI = true,
    bool createFailedHint = true,
  }) {
    final maxMessagesPerInterval = clientConfigLogic.maxMessagesPerInterval;
    if (maxMessagesPerInterval != -1) {
      // 检查当前是否可以发送消息
      if (isGroupChat &&
          !messageFrequencyController
              .canSendMessage(conversationInfo.conversationID)) {
        IMViews.showToast(StrRes.sendTooFrequent);
        return;
      }
    }

    log('send : ${json.encode(message)}');
    userId = IMUtils.emptyStrToNull(userId);
    groupId = IMUtils.emptyStrToNull(groupId);
    if (null == userId && null == groupId ||
        userId == userID && userId != null ||
        groupId == groupID && groupId != null) {
      if (addToUI) {
        // 失败重复不需要添加到ui
        messageList.add(message);
        scrollBottom();
      }
    }
    Logger.print('uid:$userID userId:$userId gid:$groupID groupId:$groupId');
    _reset(message);
    // 借用当前聊天窗口，给其他用户或群发送信息，如合并转发，分享名片。
    bool useOuterValue = null != userId || null != groupId;
    OpenIM.iMManager.messageManager
        .sendMessage(
          message: message,
          userID: useOuterValue ? userId : userID,
          groupID: useOuterValue ? groupId : groupID,
          offlinePushInfo: Config.offlinePushInfo,
        )
        .then((value) {
          if (maxMessagesPerInterval != -1) {
            // 记录当前时间戳
            if (isGroupChat) {
              messageFrequencyController.addTimestamp(
                  conversationInfo.conversationID,
                  messageFrequencyController.currentTimestamp);
            }
          }
          return _sendSucceeded(message, value);
        })
        .catchError((error, _) async => await _senFailed(
            message, groupId, error, _,
            createFailedHint: createFailedHint))
        .whenComplete(() => _completed());
  }

  /// Recommend a friend card to current chat (or to specified user/group)
  Future<void> recommendFriendCarte(UserInfo userInfo,
      {String? userId, String? groupId, String? customEx}) async {
    try {
      // If custom text provided, send it first
      if (customEx != null && customEx.isNotEmpty) {
        final textMsg = await OpenIM.iMManager.messageManager
            .createTextMessage(text: customEx);
        _sendMessage(textMsg, userId: userId, groupId: groupId);
      }

      // Create and send card message
      final cardMsg = await OpenIM.iMManager.messageManager.createCardMessage(
        userID: userInfo.userID!,
        nickname: userInfo.nickname ?? '',
        faceURL: userInfo.faceURL,
      );
      _sendMessage(cardMsg, userId: userId, groupId: groupId);
    } catch (e) {
      print('recommendFriendCarte error: $e');
    }
  }

  ///  消息发送成功
  void _sendSucceeded(Message oldMsg, Message newMsg) {
    Logger.print('message send success----');
    // message.status = MessageStatus.succeeded;
    oldMsg.update(newMsg);
    sendStatusSub.addSafely(MsgStreamEv<bool>(
      id: oldMsg.clientMsgID!,
      value: true,
    ));
  }

  ///  消息发送失败
  Future<void> _senFailed(Message message, String? groupId, error, stack,
      {bool createFailedHint = true}) async {
    Logger.print('message send failed e :$error  $stack');
    message.status = MessageStatus.failed;
    sendStatusSub.addSafely(MsgStreamEv<bool>(
      id: message.clientMsgID!,
      value: false,
    ));
    if (error is PlatformException) {
      int code = int.tryParse(error.code) ?? 0;
      if (isSingleChat) {
        int? customType;
        if (code == SDKErrorCode.hasBeenBlocked) {
          customType = CustomMessageType.blockedByFriend;
        } else if (code == SDKErrorCode.notFriend) {
          customType = CustomMessageType.deletedByFriend;
        }
        if (null != customType) {
          final existingHint = messageList.firstWhereOrNull((msg) {
            if (msg.contentType == MessageType.custom) {
              try {
                final data = json.decode(msg.customElem?.data ?? '{}');
                return data['customType'] == customType;
              } catch (e) {
                return false;
              }
            }
            return false;
          });
          if (existingHint == null || createFailedHint) {
            final hintMessage = (await OpenIM.iMManager.messageManager
                .createFailedHintMessage(type: customType))
              ..status = 2
              ..isRead = true;
            messageList.add(hintMessage);
            await OpenIM.iMManager.messageManager
                .insertSingleMessageToLocalStorage(
              message: hintMessage,
              receiverID: userID,
              senderID: OpenIM.iMManager.userID,
            );
          }
        }
      } else {
        if ((code == SDKErrorCode.userIsNotInGroup ||
                code == SDKErrorCode.groupDisbanded) &&
            null == groupId) {
          final status = groupInfo?.status;
          final hintMessage = (await OpenIM.iMManager.messageManager
              .createFailedHintMessage(
                  type: status == 2
                      ? CustomMessageType.groupDisbanded
                      : CustomMessageType.removedFromGroup))
            ..status = 2
            ..isRead = true;
          messageList.add(hintMessage);
          await OpenIM.iMManager.messageManager
              .insertGroupMessageToLocalStorage(
            message: hintMessage,
            groupID: groupID,
            senderID: OpenIM.iMManager.userID,
          );
        }
      }
    }
  }

  void _reset(Message message) {
    if (message.contentType == MessageType.text ||
        message.contentType == MessageType.atText ||
        message.contentType == MessageType.quote) {
      inputCtrl.clear();
      setQuoteMsg(null);
    }
    closeMultiSelMode();
  }

  /// todo
  void _completed() {
    messageList.refresh();
    _loadHistoryForSyncEnd();
    // setQuoteMsg(-1);
    // closeMultiSelMode();
    // inputCtrl.clear();
  }

  /// 设置被回复的消息体
  void setQuoteMsg(Message? message) {
    if (message == null) {
      quoteMsg = null;
      quoteContent.value = '';
    } else {
      quoteMsg = message;
      var name = quoteMsg!.senderNickname;
      quoteContent.value =
          "$name：${IMUtils.parseMsg(quoteMsg!, replaceIdToNickname: true)}";
      focusNode.requestFocus();
    }
  }

  /// 删除消息
  void deleteMsg(Message message) async {
    LoadingView.singleton.wrap(asyncFunction: () {
      stopVoice();
      return _deleteMessage(message);
    });
  }

  /// 批量删除
  void _deleteMultiMsg() async {
    await LoadingView.singleton.wrap(asyncFunction: () async {
      for (var e in multiSelList) {
        await _deleteMessage(e);
      }
    });
    closeMultiSelMode();
  }

  _deleteMessage(Message message) async {
    try {
      await OpenIM.iMManager.messageManager
          .deleteMessageFromLocalAndSvr(
            conversationID: conversationInfo.conversationID,
            clientMsgID: message.clientMsgID!,
          )
          .then((value) => privateMessageList.remove(message))
          .then((value) => messageList.remove(message));
    } catch (e) {
      await OpenIM.iMManager.messageManager
          .deleteMessageFromLocalStorage(
            conversationID: conversationInfo.conversationID,
            clientMsgID: message.clientMsgID!,
          )
          .then((value) => privateMessageList.remove(message))
          .then((value) => messageList.remove(message));
    }
  }

  /// 合并转发
  // void mergeForward() async {
  //   final result = await AppNavigator.startSelectContacts(
  //     action: SelAction.forward,
  //     ex: sprintf(StrRes.mergeForwardHint, [multiSelList.length]),
  //   );
  //   if (null != result) {
  //     final customEx = result['customEx'];
  //     final checkedList = result['checkedList'];
  //     for (var info in checkedList) {
  //       final userID = IMUtils.convertCheckedToUserID(info);
  //       final groupID = IMUtils.convertCheckedToGroupID(info);
  //       if (customEx is String && customEx.isNotEmpty) {
  //         sendForwardRemarkMsg(customEx, userId: userID, groupId: groupID);
  //       }
  //       sendMergeMsg(userId: userID, groupId: groupID);
  //     }
  //   }
  // }

  /// 转发
  void forward(Message? message) async {
    final result = await AppNavigator.startSelectContacts(
      action: SelAction.forward,
      ex: null != message
          ? IMUtils.parseMsg(message, replaceIdToNickname: true)
          : sprintf(StrRes.mergeForwardHint, [multiSelList.length]),
    );
    if (null != result) {
      final customEx = result['customEx'];
      final checkedList = result['checkedList'];

      // Show loading to prevent visual flickering
      LoadingView.singleton.show();
      try {
        for (var info in checkedList) {
          final targetUserID = IMUtils.convertCheckedToUserID(info);
          final targetGroupID = IMUtils.convertCheckedToGroupID(info);

          // Check if forwarding to current conversation
          final isSameConversation =
              (targetUserID == userID && targetUserID != null) ||
                  (targetGroupID == groupID && targetGroupID != null);

          // Collect messages to add to UI together
          final List<Message> messagesToAdd = [];

          // Send the forwarded message first (don't add to UI yet if same conversation)
          Message? forwardedMsg;
          if (null != message) {
            forwardedMsg = await sendForwardMsg(
              message,
              userId: targetUserID,
              groupId: targetGroupID,
              addToUI:
                  !isSameConversation, // Add to UI only if different conversation
            );
            if (isSameConversation) {
              messagesToAdd.add(forwardedMsg);
            }
          } else {
            await sendMergeMsg(userId: targetUserID, groupId: targetGroupID);
          }

          // Send the remark message after (if any)
          if (customEx is String && customEx.isNotEmpty) {
            final remarkMsg = await sendForwardRemarkMsg(
              customEx,
              userId: targetUserID,
              groupId: targetGroupID,
              addToUI:
                  !isSameConversation, // Add to UI only if different conversation
            );
            if (isSameConversation) {
              messagesToAdd.add(remarkMsg);
            }
          }

          // Batch add to UI if same conversation (both messages appear together)
          if (isSameConversation && messagesToAdd.isNotEmpty) {
            messageList.addAll(messagesToAdd);
            scrollBottom();
          }
        }
      } finally {
        LoadingView.singleton.dismiss();
      }

      await Future.delayed(const Duration(milliseconds: 300));
      IMViews.showToast(StrRes.sendSuccessfully, type: 1);
    }
  }

  /// 大于1000为通知类消息
  /// 语音消息必须点击才能视为已读
  void markMessageAsRead(Message message, bool visible) async {
    if (visible &&
        message.contentType! < 1000 &&
        message.contentType! != MessageType.voice) {
      var data = IMUtils.parseCustomMessage(message);
      if (null != data && data['viewType'] == CustomMessageType.call) {
        return;
      }
      _markMessageAsRead(message);
    }
  }

  /// 标记消息为已读
  _markMessageAsRead(Message message, {bool isNewMessage = false}) async {
    Logger.print('mark as read：${message.clientMsgID!} ${message.isRead}');
    if (!message.isRead! && message.sendID != OpenIM.iMManager.userID) {
      Logger.print('mark as read：${message.clientMsgID!} ${message.isRead}');
      // 多端同步问题
      try {
        // Cloud fei
        // if (conversationInfo.unreadCount == 0) {
        //   return;
        // }
        if (isNewMessage && message.isVoiceType) {
          return;
        }
        if (isGroupChat) {
          await OpenIM.iMManager.messageManager.markMessagesAsReadByMsgID(
              conversationID: conversationInfo.conversationID,
              messageIDList: [message.clientMsgID!]);
        } else {
          await OpenIM.iMManager.conversationManager
              .markConversationMessageAsRead(
                  conversationID: conversationInfo.conversationID);
        }
      } catch (_) {}
      message.isRead = true;
      message.hasReadTime = _timestamp;
      messageList.refresh();
      // message.attachedInfoElem!.hasReadTime = _timestamp;
    }
  }

  _clearUnreadCount() {
    if (conversationInfo.unreadCount > 0) {
      OpenIM.iMManager.conversationManager.markConversationMessageAsRead(
          conversationID: conversationInfo.conversationID);
    }
  }

  void _getInputState() async {
    if (conversationInfo.isSingleChat) {
      final result = await OpenIM.iMManager.conversationManager
          .getInputStates(conversationInfo.conversationID, userID!);
      typing.value = result?.isNotEmpty == true;
    }
  }

  void _changeInputStatus(bool focus) async {
    if (conversationInfo.isSingleChat) {
      await OpenIM.iMManager.conversationManager.changeInputStates(
          conversationID: conversationInfo.conversationID, focus: focus);
    }
  }

  /// 多选删除
  void mergeDelete() => _deleteMultiMsg();

  void multiSelMsg(Message message, bool checked) {
    if (checked) {
      // 合并最多20条限制
      if (multiSelList.length >= 20) {
        CustomDialog.show(
          title: StrRes.forwardMaxCountHint,
          showCancel: false,
          rightText: StrRes.confirm,
        );
      } else {
        multiSelList.add(message);
        multiSelList.sort((a, b) {
          if (a.createTime! > b.createTime!) {
            return 1;
          } else if (a.createTime! < b.createTime!) {
            return -1;
          } else {
            return 0;
          }
        });
      }
    } else {
      multiSelList.remove(message);
      if (multiSelList.isEmpty) {
        closeMultiSelMode();
      }
    }
  }

  void openMultiSelMode(Message message) {
    multiSelMode.value = true;
    multiSelMsg(message, true);
  }

  void closeMultiSelMode() {
    multiSelMode.value = false;
    multiSelList.clear();
  }

  /// 触摸其他地方强制关闭工具箱
  void closeToolbox() {
    forceCloseToolbox.addSafely(true);
  }

  /// 打开相册
  void onTapAlbum() async {
    final maxImageSendCount = clientConfigLogic.maxImageSendCount;
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(Get.context!,
        pickerConfig: AssetPickerConfig(
            maxAssets: maxImageSendCount,
            limitedPermissionOverlayPredicate: (state) => false,
            selectPredicate: (_, entity, isSelected) async {
              if (entity.type == AssetType.image) {
                if (await allowSendImageType(entity)) {
                  return true;
                }

                IMViews.showToast(StrRes.supportsTypeHint);

                return false;
              }
              // 视频限制5分钟的时长
              if (entity.videoDuration > const Duration(seconds: 5 * 60)) {
                IMViews.showToast(
                    sprintf(StrRes.selectVideoLimit, [5]) + StrRes.minute);
                return false;
              }
              return true;
            }));
    if (null != assets) {
      // Process assets sequentially to avoid concurrent video compression issues on iOS
      for (var asset in assets) {
        await _handleAssets(asset);
      }
    }
  }

  /// 打开相机
  void onTapCamera() async {
    final AssetEntity? entity = await CameraPicker.pickFromCamera(
      Get.context!,
      locale: Get.locale,
      pickerConfig: CameraPickerConfig(
        enableAudio: await Permission.microphone.isGranted,
        enableRecording: true,
        enableScaledPreview: true,
        maximumRecordingDuration: 60.seconds,
        shouldDeletePreviewFile: true,
        onMinimumRecordDurationNotMet: () {
          IMViews.showToast(StrRes.tapTooShort);
        },
        onError: (Object error, StackTrace? stackTrace) {
          Permissions.photos(null);
        },
      ),
    );
    _handleAssets(entity);
  }

  /// 打开系统文件浏览器
  void onTapFile() async {
    await FilePicker.platform.clearTemporaryFiles();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      // type: FileType.custom,
      // allowedExtensions: ['jpg', 'pdf', 'doc'],
    );

    if (result != null) {
      for (var file in result.files) {
        // String? mimeType = IMUtils.getMediaType(file.name);
        String? mimeType = lookupMimeType(file.name);
        if (mimeType != null) {
          if (IMUtils.allowImageType(mimeType)) {
            sendPicture(path: file.path!);
            continue;
          } else if (mimeType.contains('video/')) {
            try {
              final videoPath = file.path!;
              final mediaInfo = await VideoCompress.getMediaInfo(videoPath);
              var thumbnailFile = await VideoCompress.getFileThumbnail(
                videoPath,
                quality: 60,
              );
              sendVideo(
                videoPath: videoPath,
                mimeType: mimeType,
                duration: mediaInfo.duration!.toInt(),
                thumbnailPath: thumbnailFile.path,
              );
              continue;
            } catch (e, s) {
              Logger.print('e :$e  s:$s');
            }
          }
        }
        sendFile(filePath: file.path!, fileName: file.name);
      }
    } else {
      // User canceled the picker
    }
  }

  Future<bool> allowSendImageType(AssetEntity entity) async {
    final mimeType = await entity.mimeTypeAsync;

    return IMUtils.allowImageType(mimeType);
  }

  /// 名片
  void onTapCarte() async {
    var result = await AppNavigator.startSelectContacts(
      action: SelAction.carte,
      showRadioButton: true,
    );
    if (result is List<UserInfo> || result is FriendInfo) {
      if (result is List<UserInfo>) {
        for (var element in result) {
          sendCarte(
            userID: element.userID!,
            nickname: element.nickname,
            faceURL: element.faceURL,
          );
        }
      } else {
        sendCarte(
          userID: result.userID!,
          nickname: result.nickname,
          faceURL: result.faceURL,
        );
      }

      // sendCarte(
      //   userID: result.userID!,
      //   nickname: result.nickname,
      //   faceURL: result.faceURL,
      // );
    }
  }

  Future<void> _handleAssets(AssetEntity? asset) async {
    if (null != asset) {
      Logger.print('--------assets type-----${asset.type}');
      // Use originFile first, fallback to file for limited photo access compatibility
      final file = await asset.originFile ?? await asset.file;
      if (file == null) {
        Logger.print('--------assets file is null, cannot process');
        IMViews.showToast(StrRes.sendFailed);
        return;
      }
      final path = file.path;
      Logger.print('--------assets path-----$path');
      switch (asset.type) {
        case AssetType.image:
          sendPicture(path: path);
          break;
        case AssetType.video:
          var thumbnailFile = await IMUtils.getVideoThumbnail(File(path));
          LoadingView.singleton.show();
          final compressedFile =
              await IMUtils.compressVideoAndGetFile(File(path));
          LoadingView.singleton.dismiss();

          sendVideo(
            videoPath: compressedFile!.path,
            mimeType: asset.mimeType ?? IMUtils.getMediaType(path) ?? '',
            duration: asset.duration,
            // duration: mediaInfo.duration?.toInt() ?? 0,
            thumbnailPath: thumbnailFile.path,
          );
          // sendVoice(duration: asset.duration, path: path);
          break;
        default:
          break;
      }
    }
  }

  Future<void> _handleFile(File? file) async {
    if (null != file) {
      Logger.print('--------xFile path-----${file.path}');
      final path = file.path;
      final mimeType = lookupMimeType(path);

      Logger.print('--------xFile mimeType-----$mimeType');

      if (mimeType != null) {
        if (IMUtils.allowImageType(mimeType)) {
          await sendPicture(path: path);
        } else if (mimeType.contains('video/')) {
          try {
            var thumbnailFile = await IMUtils.getVideoThumbnail(File(path));
            final file = await IMUtils.compressVideoAndGetFile(File(path));

            final mediaInfo = await VideoCompress.getMediaInfo(path);

            await sendVideo(
              videoPath: file!.path,
              mimeType: mimeType,
              duration: mediaInfo.duration?.toInt() ?? 0,
              thumbnailPath: thumbnailFile.path,
            );
          } catch (e, s) {
            Logger.print('Error processing video: $e  $s');
            LoadingView.singleton.dismiss();
          }
        } else {
          await sendFile(filePath: path, fileName: file.uri.pathSegments.last);
        }
      } else {
        await sendFile(filePath: path, fileName: file.uri.pathSegments.last);
      }
    }
  }

  /// 处理消息点击事件
  void parseClickEvent(Message msg) async {
    log('parseClickEvent:${jsonEncode(msg)}');
    if (msg.contentType == MessageType.custom) {
      var data = msg.customElem!.data;
      var map = json.decode(data!);
      var customType = map['customType'];
      if (CustomMessageType.call == customType && !isInBlacklist.value) {
      } else if (CustomMessageType.tag == customType) {
        final data = map['data'];
        if (null != data['soundElem']) {
          final soundElem = SoundElem.fromJson(data['soundElem']);
          msg.soundElem = soundElem;
          _playVoiceMessage(msg);
        }
      }
      return;
    }
    if (msg.contentType == MessageType.voice) {
      _playVoiceMessage(msg);
      // 收听则为已读
      _markMessageAsRead(msg);
      return;
    }
    if (msg.contentType == MessageType.groupInfoSetAnnouncementNotification) {
      AppNavigator.startEditGroupAnnouncement(
        groupID: groupInfo!.groupID,
      );
      return;
    }

    IMUtils.parseClickEvent(
      msg,
      messageList: messageList,
      onViewUserInfo: viewUserInfo,
      groupInfo: groupInfo,
      groupID: groupID,
    );
  }

  /// 点击引用消息
  void onTapQuoteMsg(Message message) {
    Message? quoteMessage;
    if (message.contentType == MessageType.quote) {
      quoteMessage = message.quoteElem?.quoteMessage;
    } else if (message.contentType == MessageType.atText) {
      quoteMessage = message.atTextElem?.quoteMessage;
    }

    // Fallback if quoteMessage is not found in the element
    if (quoteMessage == null) {
      parseClickEvent(message);
      return;
    }

    Get.toNamed(AppRoutes.previewChatHistory, arguments: {
      'message': quoteMessage,
      'conversationInfo': conversationInfo,
    });
  }

  void onLongPressQuoteMsg(Message message) {
    Message? quoteMessage;
    if (message.contentType == MessageType.quote) {
      quoteMessage = message.quoteElem?.quoteMessage;
    } else if (message.contentType == MessageType.atText) {
      quoteMessage = message.atTextElem?.quoteMessage;
    }

    if (quoteMessage == null) return;

    if (quoteMessage.contentType == MessageType.picture ||
        quoteMessage.contentType == MessageType.video) {
      Get.bottomSheet(
        _buildMediaBottomSheet(quoteMessage),
        isScrollControlled: false,
      );
    }
  }

  Widget _buildMediaBottomSheet(Message message) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      padding: EdgeInsets.only(bottom: 20.h, top: 10.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          10.verticalSpace,
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Icon(Icons.info_outline, color: Color(0xFF4F42FF)),
            ),
            title: Text(
              StrRes.selectAction,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4F42FF),
              ),
            ),
          ),
          Divider(color: const Color(0xFFF3F4F6), thickness: 1.h),
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Icon(Icons.forward, color: Color(0xFF6B7280)),
            ),
            title: const Text("Forward"),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            onTap: () {
              Get.back();
              forward(message);
            },
          ),
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Icon(Icons.download, color: Color(0xFF6B7280)),
            ),
            title: Text(StrRes.download),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            onTap: () {
              Get.back();
              _saveMedia(message);
            },
          ),
        ],
      ),
    );
  }

  void _saveMedia(Message message) {
    Permissions.storage(() async {
      if (message.contentType == MessageType.picture) {
        var url = message.pictureElem?.sourcePicture?.url ??
            message.pictureElem?.snapshotPicture?.url;
        if (url != null) await HttpUtil.saveUrlPicture(url);
      } else if (message.contentType == MessageType.video) {
        var url = message.videoElem?.videoUrl;
        if (url != null) await HttpUtil.saveUrlVideo(url);
      }
    });
  }

  /// 群聊天长按头像为@用户
  void onLongPressLeftAvatar(Message message) {
    if (isMuted || isInvalidGroup) return;
    if (isGroupChat) {
      // 不查询群成员列表
      _setAtMapping(
        userID: message.sendID!,
        nickname: message.senderNickname!,
        faceURL: message.senderFaceUrl,
      );
      var uid = message.sendID!;
      // var uname = msg.senderNickName;
      if (curMsgAtUser.contains(uid)) return;
      curMsgAtUser.add(uid);
      // 在光标出插入内容
      // 先保存光标前和后内容
      var cursor = inputCtrl.selection.base.offset;
      if (!focusNode.hasFocus) {
        focusNode.requestFocus();
        cursor = _lastCursorIndex;
      }
      if (cursor < 0) cursor = 0;
      // 光标前面的内容
      var start = inputCtrl.text.substring(0, cursor);
      // 光标后面的内容
      var end = inputCtrl.text.substring(cursor);
      var at = '@$uid ';
      inputCtrl.text = '$start$at$end';
      Logger.print('start:$start end:$end  at:$at  content:${inputCtrl.text}');
      inputCtrl.selection = TextSelection.collapsed(offset: '$start$at'.length);
      // inputCtrl.selection = TextSelection.fromPosition(TextPosition(
      //   offset: '$start$at'.length,
      // ));
      _lastCursorIndex = inputCtrl.selection.start;
    }
  }

  void onTapLeftAvatar(Message message) {
    viewUserInfo(UserInfo()
      ..userID = message.sendID
      ..nickname = message.senderNickname
      ..faceURL = message.senderFaceUrl);
  }

  void onTapRightAvatar() {
    viewUserInfo(OpenIM.iMManager.userInfo);
  }

  void clickAtText(id) async {
    var tag = await OpenIM.iMManager.conversationManager.getAtAllTag();
    if (id == tag) return;
    if (null != atUserInfoMappingMap[id]) {
      viewUserInfo(atUserInfoMappingMap[id]!);
    } else {
      viewUserInfo(UserInfo(userID: id));
    }
  }

  void viewUserInfo(UserInfo userInfo) {
    final isSelf = userInfo.userID == OpenIM.iMManager.userID;
    final isFriend = imLogic.friendIDMap.containsKey(userInfo.userID);
    if (isGroupChat &&
        !isSelf &&
        groupInfo?.lookMemberInfo == 1 &&
        !isAdminOrOwner &&
        !isFriend) {
      IMViews.showToast(StrRes.cannotViewMemberProfile);
      return;
    }

    AppNavigator.startUserProfilePane(
      userID: userInfo.userID!,
      nickname: userInfo.nickname,
      faceURL: userInfo.faceURL,
      groupID: groupID,
      offAllWhenDelFriend: isSingleChat,
    );
  }

  void clickLinkText(url, type) async {
    Logger.print('--------link  type:$type-------url: $url---');
    if (type == PatternType.at) {
      clickAtText(url);
      return;
    }
    if (await canLaunch(url)) {
      await launch(url);
    }
    // await canLaunch(url) ? await launch(url : throw 'Could not launch $url';
  }

  /// 读取草稿
  void _readDraftText() {
    var draftText = Get.arguments['draftText'];
    Logger.print('readDraftText:$draftText');
    if (null != draftText && "" != draftText) {
      var map = json.decode(draftText!);
      String text = map['text'];
      Map<String, dynamic> atMap = map['at'];
      Logger.print('text:$text  atMap:$atMap');
      atMap.forEach((key, value) {
        if (!curMsgAtUser.contains(key)) curMsgAtUser.add(key);
        atUserNameMappingMap.putIfAbsent(key, () => value);
      });
      inputCtrl.text = text;
      inputCtrl.selection = TextSelection.fromPosition(TextPosition(
        offset: text.length,
      ));
      if (text.isNotEmpty) {
        focusNode.requestFocus();
      }
    }
  }

  /// 生成草稿draftText
  String createDraftText() {
    var atMap = <String, dynamic>{};
    for (var uid in curMsgAtUser) {
      atMap[uid] = atUserNameMappingMap[uid];
    }
    if (inputCtrl.text.isEmpty) {
      return "";
    }
    return json.encode({'text': inputCtrl.text, 'at': atMap});
  }

  /// 退出界面前处理
  exit() async {
    if (multiSelMode.value) {
      closeMultiSelMode();
      return false;
    }
    if (isShowPopMenu.value) {
      forceCloseMenuSub.add(true);
      return false;
    }
    Get.back(result: createDraftText());
    return true;
  }

  /// Handle back button press from GradientScaffold
  /// Always navigates back to conversation list
  void onBackPressed() async {
    print('=== onBackPressed called ===');

    // Cancel voice recording if active (no confirmation needed)
    _cancelVoiceRecordingIfActive();

    // Close multi-select mode if active (but still navigate)
    if (multiSelMode.value) {
      closeMultiSelMode();
    }

    // Close pop menu if showing (but still navigate)
    if (isShowPopMenu.value) {
      forceCloseMenuSub.add(true);
    }

    // Always navigate back to conversation list (home screen)
    final draftText = createDraftText();
    print('Navigating back to home...');
    Get.until((route) {
      print('Checking route: ${route.settings.name}');
      return route.settings.name == AppRoutes.home;
    });
    print('Navigation completed');

    // Save draft text after navigation
    if (draftText.isNotEmpty) {
      conversationLogic.setConversationDraft(
        cid: conversationInfo.conversationID,
        draftText: draftText,
      );
    }
  }

  /// Check if voice recording is active via ChatInputBox
  bool _isVoiceRecordingActive() {
    final inputBoxState = chatInputBoxStateKey.currentState;
    if (inputBoxState != null) {
      // Access via dynamic since _ChatInputBoxState is private
      try {
        return (inputBoxState as dynamic).isRecordingVoice ?? false;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  /// Cancel voice recording if active
  void _cancelVoiceRecordingIfActive() {
    final inputBoxState = chatInputBoxStateKey.currentState;
    if (inputBoxState != null) {
      try {
        (inputBoxState as dynamic).cancelVoiceRecording();
      } catch (e) {
        // Ignore if method doesn't exist
      }
    }
  }

  void _updateDartText(String text) {
    conversationLogic.updateDartText(
      text: text,
      conversationID: conversationInfo.conversationID,
    );
  }

  void focusNodeChanged(bool hasFocus) {
    isInputFocused.value = hasFocus;
    _changeInputStatus(hasFocus);
    if (hasFocus) {
      Logger.print('focus:$hasFocus');
    }
  }

  void copy(Message message) {
    String? content;
    final textElem = message.tagContent?.textElem;
    if (null != textElem) {
      content = textElem.content;
    } else {
      content = copyTextMap[message.clientMsgID] ?? message.textElem?.content;
    }
    if (message.isNoticeType) {
      content = message.noticeContent;
    }
    if (null != content) {
      IMUtils.copy(text: content);
    }
  }

  Message indexOfMessage(int index, {bool calculate = true}) =>
      IMUtils.calChatTimeInterval(
        messageList,
        calculate: calculate,
      ).reversed.elementAt(index);

  ValueKey itemKey(Message message) => ValueKey(message.clientMsgID!);

  @override
  void onClose() {
    // Force hide message overlay if it's showing
    try {
      MessageOverlayHelper.hide();
    } catch (e) {
      Logger.print('Error hiding message overlay: $e');
    }

    // Skip cleanup if initialization failed
    if (!_isInitialized) {
      inputCtrl.dispose();
      focusNode.dispose();
      super.onClose();
      return;
    }

    sendTypingMsg();
    _clearUnreadCount();
    // ChatGetTags.caches.removeLast();
    inputCtrl.dispose();
    focusNode.dispose();
    _audioPlayer.dispose();
    // clickSubject.close();
    forceCloseToolbox.close();
    conversationSub.cancel();
    sendStatusSub.close();
    sendProgressSub.close();
    downloadProgressSub.close();
    memberAddSub.cancel();
    memberDelSub.cancel();
    memberInfoChangedSub.cancel();
    groupInfoUpdatedSub.cancel();
    friendInfoChangedSub.cancel();
    userStatusChangedSub?.cancel();
    selfInfoUpdatedSub?.cancel();
    // signalingMessageSub?.cancel();
    forceCloseMenuSub.close();
    joinedGroupAddedSub.cancel();
    joinedGroupDeletedSub.cancel();
    connectionSub.cancel();
    // onlineStatusTimer?.cancel();
    // destroyMsg();
    super.onClose();
  }

  @override
  void onDetached() {
    // Handle logic when the app is detached
  }

  @override
  void onHidden() {
    // Handle logic when the app is hidden
  }

  @override
  void onInactive() {
    // Handle logic when the app is inactive
  }

  @override
  void onPaused() {
    // Handle logic when the app is paused
  }

  @override
  void onResumed() {
    // Handle logic when the app is resumed
  }

  String? getShowTime(Message message) {
    if (message.exMap['showTime'] == true) {
      return IMUtils.getChatTimeline(message.sendTime!);
    }
    return null;
  }

  void clearAllMessage() {
    messageList.clear();
  }

  void onStartVoiceInput() {
    // SpeechToTextUtil.instance.startListening((result) {
    //   inputCtrl.text = result.recognizedWords;
    // });
  }

  void onStopVoiceInput() {
    // SpeechToTextUtil.instance.stopListening();
  }

  /// 添加表情
  void onAddEmoji(String emoji) {
    var input = inputCtrl.text;
    if (_lastCursorIndex != -1 && input.isNotEmpty) {
      var part1 = input.substring(0, _lastCursorIndex);
      var part2 = input.substring(_lastCursorIndex);
      inputCtrl.text = '$part1$emoji$part2';
      _lastCursorIndex = _lastCursorIndex + emoji.length;
    } else {
      inputCtrl.text = '$input$emoji';
      _lastCursorIndex = emoji.length;
    }
    inputCtrl.selection = TextSelection.fromPosition(TextPosition(
      offset: _lastCursorIndex,
    ));
  }

  /// 删除表情
  void onDeleteEmoji() {
    final input = inputCtrl.text;
    final regexEmoji = emojiFaces.keys
        .toList()
        .join('|')
        .replaceAll('[', '\\[')
        .replaceAll(']', '\\]');
    final list = [regexAt, regexEmoji];
    final pattern = '(${list.toList().join('|')})';
    final atReg = RegExp(regexAt);
    final emojiReg = RegExp(regexEmoji);
    var reg = RegExp(pattern);
    var cursor = _lastCursorIndex;
    if (cursor == 0) return;
    Match? match;
    if (reg.hasMatch(input)) {
      for (var m in reg.allMatches(input)) {
        var matchText = m.group(0)!;
        var start = m.start;
        var end = start + matchText.length;
        if (end == cursor) {
          match = m;
          break;
        }
      }
    }
    var matchText = match?.group(0);
    if (matchText != null) {
      var start = match!.start;
      var end = start + matchText.length;
      if (atReg.hasMatch(matchText)) {
        String id = matchText.replaceFirst("@", "").trim();
        if (curMsgAtUser.remove(id)) {
          inputCtrl.text = input.replaceRange(start, end, '');
          cursor = start;
        } else {
          inputCtrl.text = input.replaceRange(cursor - 1, cursor, '');
          --cursor;
        }
      } else if (emojiReg.hasMatch(matchText)) {
        inputCtrl.text = input.replaceRange(start, end, "");
        cursor = start;
      } else {
        inputCtrl.text = input.replaceRange(cursor - 1, cursor, '');
        --cursor;
      }
    } else {
      inputCtrl.text = input.replaceRange(cursor - 1, cursor, '');
      --cursor;
    }
    _lastCursorIndex = cursor;
  }

  String get subTitle {
    if (isSingleChat) {
      return typing.value ? StrRes.typing : onlineStatusDesc.value;
    }

    final onlineCount = onlineInfoLogic.onlineUserId.length;
    if (!showGroupOnlineInfo || onlineCount == 0) {
      return '';
    }

    final locale = Get.locale?.languageCode ?? 'en';

    switch (locale) {
      case 'zh':
      case 'zh-CN':
      case 'zh-TW':
        return '($onlineCount)在线';
      default: // English
        return '($onlineCount)online';
    }
  }

  bool get showGroupOnlineInfo {
    final result = isGroupChat &&
        clientConfigLogic.shouldShowGroupOnlineInfo(groupMemberRoleLevel.value);
    return result;
  }

  /// 处理输入框输入@字符
  String? openAtList() {
    if (groupInfo != null) {
      var cursor = inputCtrl.selection.baseOffset;

      final hasEveryone = curMsgAtUser.contains(imLogic.atAllTag);

      final currentUserCount =
          curMsgAtUser.where((uid) => uid != imLogic.atAllTag).length;
      final maxCount = 10 - currentUserCount - (hasEveryone ? 1 : 0);

      final defaultUserIDs = List<String>.from(curMsgAtUser);

      AppNavigator.startGroupMemberList(
        groupInfo: groupInfo!,
        opType: GroupMemberOpType.at,
        defaultCheckedUserIDs: defaultUserIDs,
        maxSelectCount: maxCount,
      )?.then((list) async {
        if (list == null) return;
        if (list is List &&
            list.isNotEmpty &&
            list.first.nickname == StrRes.everyone) {
          // Add @everyone to curMsgAtUser (keep existing users if any)
          if (!curMsgAtUser.contains(imLogic.atAllTag)) {
            curMsgAtUser.add(imLogic.atAllTag);
          }
          // Add nickname mapping for SDK to recognize @everyone
          atUserNameMappingMap[imLogic.atAllTag] = StrRes.everyone;

          // Insert @Everyone at cursor position instead of overwriting
          final currentText = inputCtrl.text;
          final cursor = inputCtrl.selection.baseOffset < 0
              ? currentText.length
              : inputCtrl.selection.baseOffset;

          // Check if the character before cursor is replacing '@'
          final replaceStart = (cursor > 0 && currentText[cursor - 1] == '@')
              ? cursor - 1
              : cursor;

          final atText = '@${StrRes.everyone} ';
          final newText = currentText.substring(0, replaceStart) +
              atText +
              currentText.substring(cursor);
          inputCtrl.text = newText;
          inputCtrl.selection = TextSelection.fromPosition(
            TextPosition(offset: replaceStart + atText.length),
          );
          return;
        }

        // Convert returned list to member objects and extract IDs/nicknames robustly
        final returned = List.from(list as List);
        List<String> newSelectedIDs = [];
        final Map<String, dynamic> idToMember = {};
        for (var item in returned) {
          String? uid;
          String? nick;
          String? face;
          if (item is GroupMembersInfo) {
            uid = item.userID;
            nick = item.nickname;
            face = item.faceURL;
          } else if (item is Map) {
            uid = item['userID']?.toString();
            nick = item['nickname']?.toString();
            face = item['faceURL']?.toString();
          } else {
            try {
              // Fallback dynamic access
              uid = (item.userID ?? item['userID'])?.toString();
              nick = (item.nickname ?? item['nickname'])?.toString();
              face = (item.faceURL ?? item['faceURL'])?.toString();
            } catch (_) {
              uid = null;
            }
          }
          if (uid != null) {
            newSelectedIDs.add(uid);
            idToMember[uid] = {
              'userID': uid,
              'nickname': nick ?? '',
              'faceURL': face
            };
          }
        }

        // Rebuild the mention list robustly: compute the final selected IDs
        // (preserve order from returned list) and replace mention tokens
        // in the input with the new mentions. This avoids index/cursor
        // issues when removing then adding in-place.
        final finalSelectedIDs = newSelectedIDs;

        // Update mappings for all final selected IDs
        for (var uid in finalSelectedIDs) {
          final member = idToMember[uid];
          final nick = member?['nickname'] ?? '';
          final face = member?['faceURL'];
          _setAtMapping(userID: uid, nickname: nick, faceURL: face);
        }

        // Replace curMsgAtUser with finalSelectedIDs (preserve atAll tag if present)
        final hasAtAll = curMsgAtUser.contains(imLogic.atAllTag);
        curMsgAtUser.clear();
        if (hasAtAll) curMsgAtUser.add(imLogic.atAllTag);
        curMsgAtUser.addAll(finalSelectedIDs);

        // Get current text and remove the trigger '@' at cursor position
        var text = inputCtrl.text;
        var insertPos = cursor;

        // Remove the '@' that triggered the selection
        // Check at cursor position first (cursor captured before '@' was added by formatter)
        // Then check at cursor-1 (cursor captured after '@' was typed)
        if (cursor >= 0 && cursor < text.length && text[cursor] == '@') {
          text = text.substring(0, cursor) + text.substring(cursor + 1);
          insertPos = cursor;
        } else if (cursor > 0 &&
            cursor <= text.length &&
            text[cursor - 1] == '@') {
          text = text.substring(0, cursor - 1) + text.substring(cursor);
          insertPos = cursor - 1;
        }

        // Build mention string for newly selected members only
        var mentionStr = '';
        final newIDs = finalSelectedIDs
            .where((id) => !defaultUserIDs.contains(id))
            .toList();
        if (newIDs.isNotEmpty) {
          mentionStr = newIDs.map((id) => '@$id').join(' ') + ' ';
        }

        // Insert mention at cursor position (preserving text before and after)
        var before = text.substring(0, insertPos);
        var after = text.substring(insertPos);
        inputCtrl.text = '$before$mentionStr$after';
        inputCtrl.selection = TextSelection.fromPosition(TextPosition(
          offset: before.length + mentionStr.length,
        ));
        _lastCursorIndex = inputCtrl.selection.start;
      });
      return "@";
    }
    return null;
  }

  int count = 500;

  Future<List<GroupMembersInfo>> _getGroupMembers() async {
    final result = await OpenIM.iMManager.groupManager.getGroupMemberList(
      groupID: groupInfo!.groupID,
      count: count,
      filter: 0,
    );
    return result;
  }

  _handleAtMemberList(memberList, cursor) {
    if (memberList is List<GroupMembersInfo>) {
      var buffer = StringBuffer();
      for (var e in memberList) {
        _setAtMapping(
          userID: e.userID!,
          nickname: e.nickname ?? '',
          faceURL: e.faceURL,
        );
        if (!curMsgAtUser.contains(e.userID)) {
          curMsgAtUser.add(e.userID!);
          buffer.write('@${e.userID} ');
        }
      }
      if (cursor < 0) cursor = 0;
      // 光标前面的内容
      var start = inputCtrl.text.substring(0, cursor);
      // 光标后面的内容
      var end = inputCtrl.text.substring(cursor + 1);
      inputCtrl.text = '$start$buffer$end';
      inputCtrl.selection = TextSelection.fromPosition(TextPosition(
        offset: '$start$buffer'.length,
      ));
      _lastCursorIndex = inputCtrl.selection.start;
    } else {}
  }

  void favoriteManage() => AppNavigator.startFavoriteMange();

  void openEmojiPicker() {
    Get.dialog(
      AlertDialog(
        title: Text(StrRes.selectEmoji),
        content: SizedBox(
          width: 300,
          height: 400,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0, // Ensure square cells
            ),
            itemCount: _commonEmojis.length,
            itemBuilder: (context, index) {
              return _EmojiPickerButton(
                emoji: _commonEmojis[index],
                onSelected: () {
                  addEmojiToFavorites(_commonEmojis[index]);
                  Get.back();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void addEmojiToFavorites(String emoji) {
    if (!favoriteEmojiList.contains(emoji)) {
      favoriteEmojiList.add(emoji);
      _saveFavoriteEmojis();
      // Force UI update without changing tab
      favoriteEmojiList.refresh();
      // Trigger rebuild of ChatEmojiView
      update();
    }
  }

  void _saveFavoriteEmojis() {
    try {
      SpUtil()
          .putStringList('favorite_emojis_${DataSp.userID}', favoriteEmojiList);
    } catch (e) {
      Logger.print('Error saving favorite emojis: $e');
    }
  }

  void addEmoji(Message message) {
    if (message.contentType == MessageType.picture) {
      var url = message.pictureElem?.sourcePicture?.url;
      var width = message.pictureElem?.sourcePicture?.width;
      var height = message.pictureElem?.sourcePicture?.height;
      cacheLogic.addFavoriteFromUrl(url, width, height);
      IMViews.showToast(StrRes.addSuccessfully, type: 1);
    } else if (message.contentType == MessageType.customFace) {
      var index = message.faceElem?.index;
      var data = message.faceElem?.data;
      if (-1 != index) {
      } else if (null != data) {
        var map = json.decode(data);
        var url = map['url'];
        var width = map['width'];
        var height = map['height'];
        cacheLogic.addFavoriteFromUrl(url, width, height);
        IMViews.showToast(StrRes.addSuccessfully, type: 1);
      }
    }
  }

  /// 发送自定表情
  void sendFavoritePic(int index, String url) async {
    var emoji = cacheLogic.favoriteList.elementAt(index);
    var message = await OpenIM.iMManager.messageManager.createFaceMessage(
      data: json.encode(
          {'url': emoji.url, 'width': emoji.width, 'height': emoji.height}),
    );
    _sendMessage(message);
  }

  void _initChatConfig() async {
    scaleFactor.value = DataSp.getChatFontSizeFactor();
    var path = DataSp.getChatBackground(otherId) ?? '';
    if (path.isNotEmpty && (await File(path).exists())) {
      background.value = path;
    }
  }

  /// 正在显示封禁提示
  var _blockDialogShowFlag = false;

  /// 正在获取封禁信息
  var _checkGroupBlockFlag = false;

  /// 检查群封禁状态
  void _checkGroupBlockInfo() async {
    if (!isBanned && _blockDialogShowFlag) {
      _blockDialogShowFlag = false;
      Get.back();
      return;
    }
    if (isBanned && !_blockDialogShowFlag && !_checkGroupBlockFlag) {
      _checkGroupBlockFlag = true;
      final result = await ChatApis.getGroupBlockInfo(groupID!);
      _checkGroupBlockFlag = false;
      if (result is List && result.isNotEmpty) {
        final firstItem = result.first;
        if (firstItem is Map<String, dynamic>) {
          _blockDialogShowFlag = true;
          CustomDialog.show(
            title: '群组已被封停',
            content: '因：${firstItem['reason']} 已被封停，不能使用',
            showCancel: false,
          );
          _blockDialogShowFlag = false;
          return;
        }
      }
    }
  }

  /// 修改聊天字体
  changeFontSize(double factor) async {
    await DataSp.putChatFontSizeFactor(factor);
    scaleFactor.value = factor;
    IMViews.showToast(StrRes.setSuccessfully, type: 1);
  }

  /// 修改聊天背景
  changeBackground(String path) async {
    await DataSp.putChatBackground(otherId, path);
    background.value = path;
  }

  String get otherId => isSingleChat ? userID! : groupID!;

  /// 清除聊天背景
  clearBackground() async {
    await DataSp.clearChatBackground(otherId);
    background.value = '';
  }

  /// 拨视频或音频
  void call() async {}

  bool get showAudioAndVideoCall {
    if (isSingleChat) {
      return clientConfigLogic.showAudioAndVideoCall;
    }
    // Temporarily hide call buttons in group chat
    return false;
  }

  /// 音频通话
  void onTapAudioCall() async {
    if (null == groupInfo) {
      final id = conversationInfo.userID;
      if (id == null || id.isEmpty) {
        return;
      }
      trtcLogic.callAudio(id);
    } else {
      await AppNavigator.startGroupMemberList(
        groupInfo: groupInfo!,
        opType: GroupMemberOpType.call,
      )?.then((list) async {
        if (list.isEmpty) {
          return;
        }

        final selectedMembers = list as List<GroupMembersInfo>;
        final onlineUserIds = onlineInfoLogic.onlineUserId;

        // Separate online and offline members
        final onlineMembers = selectedMembers
            .where((m) => onlineUserIds.contains(m.userID))
            .toList();
        final offlineMembers = selectedMembers
            .where((m) => !onlineUserIds.contains(m.userID))
            .toList();

        // If all selected members are offline
        if (onlineMembers.isEmpty) {
          final offlineNames = offlineMembers
              .map((m) => m.nickname ?? m.userID ?? 'Unknown')
              .join(', ');
          IMViews.showToast('${StrRes.allMembersOffline}: $offlineNames');
          return;
        }

        // If some members are offline, show toast and proceed with online members
        if (offlineMembers.isNotEmpty) {
          final offlineNames = offlineMembers
              .map((m) => m.nickname ?? m.userID ?? 'Unknown')
              .join(', ');
          IMViews.showToast('${StrRes.membersOffline}: $offlineNames');
        }

        // Proceed with online members only
        final ids = onlineMembers.map((v) => v.userID!).toList();
        ids.insert(0, imLogic.userInfo.value.userID!);
        int randomRoomId = math.Random().nextInt(90000000) + 10000000;
        trtcLogic.callGroupAudio(ids, randomRoomId, groupInfo!.groupID);
      });
    }
  }

  /// 视频通话
  void onTapVideoCall() async {
    if (null == groupInfo) {
      final id = conversationInfo.userID;
      if (id == null || id.isEmpty) {
        return;
      }
      trtcLogic.callVideo(id);
    } else {
      await AppNavigator.startGroupMemberList(
        groupInfo: groupInfo!,
        opType: GroupMemberOpType.call,
      )?.then((list) async {
        if (list.isEmpty) {
          return;
        }

        final selectedMembers = list as List<GroupMembersInfo>;
        final onlineUserIds = onlineInfoLogic.onlineUserId;

        // Separate online and offline members
        final onlineMembers = selectedMembers
            .where((m) => onlineUserIds.contains(m.userID))
            .toList();
        final offlineMembers = selectedMembers
            .where((m) => !onlineUserIds.contains(m.userID))
            .toList();

        // If all selected members are offline
        if (onlineMembers.isEmpty) {
          final offlineNames = offlineMembers
              .map((m) => m.nickname ?? m.userID ?? 'Unknown')
              .join(', ');
          IMViews.showToast('${StrRes.allMembersOffline}: $offlineNames');
          return;
        }

        // If some members are offline, show toast and proceed with online members
        if (offlineMembers.isNotEmpty) {
          final offlineNames = offlineMembers
              .map((m) => m.nickname ?? m.userID ?? 'Unknown')
              .join(', ');
          IMViews.showToast('${StrRes.membersOffline}: $offlineNames');
        }

        // Proceed with online members only
        final ids = onlineMembers.map((v) => v.userID!).toList();
        ids.insert(0, imLogic.userInfo.value.userID!);
        int randomRoomId = math.Random().nextInt(90000000) + 10000000;
        trtcLogic.callGroupVideo(ids, randomRoomId, groupInfo!.groupID);
      });
    }
  }

  /// 失败重发
  void failedResend(Message message) {
    Logger.print('failedResend: ${message.clientMsgID}');
    if (message.status == MessageStatus.sending) {
      return;
    }
    sendStatusSub.addSafely(MsgStreamEv<bool>(
      id: message.clientMsgID!,
      value: true,
    ));

    Logger.print('failedResending: ${message.clientMsgID}');
    _sendMessage(message..status = MessageStatus.sending,
        addToUI: false, createFailedHint: false);
  }

  /// 计算这条消息应该被阅读的人数
  // int getNeedReadCount(Message message) {
  //   if (isSingleChat) return 0;
  //   return groupMessageReadMembers[message.clientMsgID!]?.length ??
  //       _calNeedReadCount(message);
  // }

  /// 1，排除自己
  /// 2，获取比消息发送时间早的入群成员数
  // int _calNeedReadCount(Message message) {
  //   memberList.values.forEach((element) {
  //     if (element.userID != OpenIM.iMManager.uid) {
  //       if ((element.joinTime! * 1000) < message.sendTime!) {
  //         var list = groupMessageReadMembers[message.clientMsgID!] ?? [];
  //         if (!list.contains(element.userID)) {
  //           groupMessageReadMembers[message.clientMsgID!] = list
  //             ..add(element.userID!);
  //         }
  //       }
  //     }
  //   });
  //   return groupMessageReadMembers[message.clientMsgID!]?.length ?? 0;
  // }

  int readTime(Message message) {
    var isPrivate = message.attachedInfoElem?.isPrivateChat ?? false;
    var burnDuration = message.attachedInfoElem?.burnDuration ?? 30;
    burnDuration = burnDuration > 0 ? burnDuration : 30;
    if (isPrivate) {
      // var hasReadTime = message.attachedInfoElem!.hasReadTime ?? 0;
      var hasReadTime = message.hasReadTime ?? 0;
      if (hasReadTime > 0) {
        var end = hasReadTime + (burnDuration * 1000);

        var diff = (end - _timestamp) ~/ 1000;

        if (diff > 0) {
          privateMessageList.addIf(
              () => !privateMessageList.contains(message), message);
        }
        return diff < 0 ? 0 : diff;
      }
    }
    return 0;
  }

  static int get _timestamp => DateTime.now().millisecondsSinceEpoch;

  /// 退出页面即把所有当前已展示的私聊消息删除
  void destroyMsg() {
    for (var message in privateMessageList) {
      OpenIM.iMManager.messageManager.deleteMessageFromLocalAndSvr(
        conversationID: conversationInfo.conversationID,
        clientMsgID: message.clientMsgID!,
      );
    }
  }

  /// 获取个人群资料
  Future _queryMyGroupMemberInfo() async {
    if (!isGroupChat) {
      return;
    }
    var list = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
      groupID: groupID!,
      userIDList: [OpenIM.iMManager.userID],
    );
    groupMembersInfo = list.firstOrNull;
    groupMemberRoleLevel.value =
        groupMembersInfo?.roleLevel ?? GroupRoleLevel.member;
    muteEndTime.value = groupMembersInfo?.muteEndTime ?? 0;
    if (null != groupMembersInfo) {
      memberUpdateInfoMap[OpenIM.iMManager.userID] = groupMembersInfo!;
    }

    if (clientConfigLogic
        .shouldShowGroupOnlineInfo(groupMemberRoleLevel.value)) {
      onlineInfoLogic.refreshGroupMemberOnlineInfo(groupID!);
    }
    _mutedClearAllInput();

    return;
  }

  Future _queryOwnerAndAdmin() async {
    if (isGroupChat) {
      ownerAndAdmin = await OpenIM.iMManager.groupManager
          .getGroupMemberList(groupID: groupID!, filter: 5, count: 20);
    }
    return;
  }

  void _isJoinedGroup() async {
    if (!isGroupChat) {
      return;
    }
    isInGroup.value = await OpenIM.iMManager.groupManager.isJoinedGroup(
      groupID: groupID!,
    );
    if (!isInGroup.value) {
      return;
    }
    _queryGroupInfo();
    _queryOwnerAndAdmin();
  }

  /// 获取群资料
  void _queryGroupInfo() async {
    if (!isGroupChat) {
      return;
    }
    _queryMyGroupMemberInfo();
    _queryGroupCallingInfo();
    _checkGroupBlockInfo();
    var list = await OpenIM.iMManager.groupManager.getGroupsInfo(
      groupIDList: [groupID!],
    );
    groupInfo = list.firstOrNull;
    groupOwnerID = groupInfo?.ownerUserID;
    if (_isExitUnreadAnnouncement()) {
      announcement.value = groupInfo?.notification ?? '';
    }
    groupMutedStatus.value = groupInfo?.status ?? 0;
    if (null != groupInfo?.memberCount) {
      memberCount.value = groupInfo!.memberCount!;
    }
  }

  /// 禁言权限
  /// 1普通成员, 2群主，3管理员
  bool get havePermissionMute =>
      isGroupChat &&
      (groupInfo?.ownerUserID ==
          OpenIM.iMManager
              .userID /*||
          groupMembersInfo?.roleLevel == 2*/
      );

  /// 通知类型消息
  bool isNotificationType(Message message) => message.contentType! >= 1000;

  Map<String, String> getAtMapping(Message message) {
    return {};
  }

  void _queryUserOnlineStatus() {
    if (isSingleChat) {
      final cachedStatus = conversationLogic.userOnlineStatusMap[userID!];
      if (cachedStatus != null) {
        onlineStatus.value = cachedStatus;
        onlineStatusDesc.value = cachedStatus ? StrRes.online : StrRes.offline;
      }

      conversationLogic.ensureUserStatusSubscribed(userID!);
      userStatusChangedSub = imLogic.userStatusChangedSubject.listen((value) {
        if (value.userID == userID) {
          _configUserStatusChanged(value);
        }
      });
    }
  }

  void _configUserStatusChanged(UserStatusInfo? status) {
    if (status != null) {
      final isOnline = status.status == 1;
      onlineStatus.value = isOnline;

      if (isOnline &&
          status.platformIDs != null &&
          status.platformIDs!.isNotEmpty) {
        // Show platform names when online
        final platformDesc = _onlineStatusDes(status.platformIDs!);
        onlineStatusDesc.value =
            platformDesc.isNotEmpty ? platformDesc : StrRes.online;
      } else {
        onlineStatusDesc.value = StrRes.offline;
      }

      if (userID != null) {
        conversationLogic.userOnlineStatusMap[userID!] = isOnline;
      }
    }
  }

  String _onlineStatusDes(List<int> plamtforms) {
    var des = <String>[];
    for (final platform in plamtforms) {
      switch (platform) {
        case 1:
          des.add('iOS');
          break;
        case 2:
          des.add('Android');
          break;
        case 3:
          des.add('Windows');
          break;
        case 4:
          des.add('Mac');
          break;
        case 5:
          des.add('Web');
          break;
        case 6:
          des.add('mini_web');
          break;
        case 7:
          des.add('Linux');
          break;
        case 8:
          des.add('Android_pad');
          break;
        case 9:
          des.add('iPad');
          break;
        default:
      }
    }

    return des.join('/');
  }

  void _checkInBlacklist() async {
    if (userID != null) {
      var list = await OpenIM.iMManager.friendshipManager.getBlacklist();
      var user = list.firstWhereOrNull((e) => e.userID == userID);
      isInBlacklist.value = user != null;
    }
  }

  void _setAtMapping({
    required String userID,
    required String nickname,
    String? faceURL,
  }) {
    atUserNameMappingMap[userID] = nickname;
    atUserInfoMappingMap[userID] = UserInfo(
      userID: userID,
      nickname: nickname,
      faceURL: faceURL,
    );
    // DataSp.putAtUserMap(groupID!, atUserNameMappingMap);
  }

  /// 未超过24小时
  bool isExceed24H(Message message) {
    int milliseconds = message.sendTime!;
    return !DateUtil.isToday(milliseconds);
  }

  bool isPlaySound(Message message) {
    return _currentPlayClientMsgID.value == message.clientMsgID!;
  }

  void _initPlayListener() {
    _audioPlayer.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
        case ProcessingState.loading:
        case ProcessingState.buffering:
        case ProcessingState.ready:
          break;
        case ProcessingState.completed:
          _currentPlayClientMsgID.value = "";
          break;
      }
    });
  }

  /// 播放语音消息
  void _playVoiceMessage(Message message) async {
    var isClickSame = _currentPlayClientMsgID.value == message.clientMsgID;
    if (_audioPlayer.playerState.playing) {
      _currentPlayClientMsgID.value = "";
      _audioPlayer.stop();
    }
    if (!isClickSame) {
      bool isValid = await _initVoiceSource(message);
      if (isValid) {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.play();
        _currentPlayClientMsgID.value = message.clientMsgID!;
      }
    }
  }

  void stopVoice() {
    if (_audioPlayer.playerState.playing) {
      _currentPlayClientMsgID.value = '';
      _audioPlayer.stop();
    }
  }

  /// 语音消息资源处理
  Future<bool> _initVoiceSource(Message message) async {
    bool isReceived = message.sendID != OpenIM.iMManager.userID;
    String? path = message.soundElem?.soundPath;
    String? url = message.soundElem?.sourceUrl;
    bool isExistSource = false;
    if (isReceived) {
      if (null != url && url.trim().isNotEmpty) {
        isExistSource = true;
        _audioPlayer.setUrl(url);
      }
    } else {
      bool existFile = false;
      if (path != null && path.trim().isNotEmpty) {
        var file = File(path);
        existFile = await file.exists();
      }
      if (existFile) {
        isExistSource = true;
        _audioPlayer.setFilePath(path!);
      } else if (null != url && url.trim().isNotEmpty) {
        isExistSource = true;
        _audioPlayer.setUrl(url);
      }
    }
    return isExistSource;
  }

  /// 显示菜单屏蔽消息插入
  void onPopMenuShowChanged(show) {
    isShowPopMenu.value = show;
    if (!show && scrollingCacheMessageList.isNotEmpty) {
      messageList.addAll(scrollingCacheMessageList);
      scrollingCacheMessageList.clear();
    }
  }

  String? getNewestNickname(Message message) {
    if (isSingleChat) null;
    // return memberUpdateInfoMap[message.sendID]?.nickname;
    if (imLogic.userRemarkMap[message.sendID] != null &&
        imLogic.userRemarkMap[message.sendID]!.isNotEmpty) {
      return '${imLogic.userRemarkMap[message.sendID]}';
    }
    return message.senderNickname;
  }

  String? getQuoteMsgSenderNickname(Message message) {
    if (!message.isQuoteType) {
      return null;
    }
    final quoteMessage = message.quoteMessage;
    if (quoteMessage == null) {
      return null;
    }
    final quoteSendID = quoteMessage.sendID;
    final isSender = quoteSendID == OpenIM.iMManager.userID;
    if (isSingleChat) {
      if (isSender) {
        return OpenIM.iMManager.userInfo.nickname;
      }
      return nickname.value;
    }
    if (isSender) {
      return OpenIM.iMManager.userInfo.nickname;
    }
    if (quoteSendID != null &&
        imLogic.userRemarkMap[quoteSendID]?.isNotEmpty == true) {
      return imLogic.userRemarkMap[quoteSendID];
    }
    return quoteMessage.senderNickname;
  }

  String? getNewestFaceURL(Message message) {
    // if (isSingleChat) return faceUrl.value;
    // return memberUpdateInfoMap[message.sendID]?.faceURL;
    return message.senderFaceUrl;
  }

  /// 存在未读的公告
  bool _isExitUnreadAnnouncement() =>
      conversationInfo.groupAtType == GroupAtType.groupNotification;

  /// 是公告消息
  bool isAnnouncementMessage(message) => _getAnnouncement(message) != null;

  String? _getAnnouncement(Message message) {
    if (message.contentType! ==
        MessageType.groupInfoSetAnnouncementNotification) {
      final elem = message.notificationElem!;
      final map = json.decode(elem.detail!);
      final notification = GroupNotification.fromJson(map);
      if (notification.group?.notification != null &&
          notification.group!.notification!.isNotEmpty) {
        return notification.group!.notification!;
      }
    }
    return null;
  }

  /// 新消息为公告
  void _parseAnnouncement(Message message) {
    var ac = _getAnnouncement(message);
    if (null != ac) {
      announcement.value = ac;
      groupInfo?.notification = ac;
    }
  }

  /// 预览公告
  void previewGroupAnnouncement() async {
    if (null != groupInfo) {
      announcement.value = '';
      await AppNavigator.startEditGroupAnnouncement(
          groupID: groupInfo!.groupID);
    }
  }

  void closeGroupAnnouncement() {
    if (null != groupInfo) {
      announcement.value = '';
    }
  }

  bool get isInvalidGroup => !isInGroup.value && isGroupChat;

  /// 禁言条件；全员禁言，单独禁言，拉入黑名单
  bool get isMuted => isGroupMuted || isUserMuted /* || isInBlacklist.value*/;

  bool get isBanned => groupMutedStatus.value == 1;

  /// 群开启禁言，排除群组跟管理员
  bool get isGroupMuted =>
      groupMutedStatus.value == 3 &&
      groupMemberRoleLevel.value == GroupRoleLevel.member;

  /// 单独被禁言
  bool get isUserMuted =>
      muteEndTime.value > DateTime.now().millisecondsSinceEpoch;

  /// 禁言提示
  String? get hintText =>
      isMuted ? (isGroupMuted ? StrRes.groupMuted : StrRes.youMuted) : null;

  /// 禁言后 清除所有状态
  void _mutedClearAllInput() {
    if (isMuted) {
      inputCtrl.clear();
      setQuoteMsg(null);
      closeMultiSelMode();
    }
  }

  /// 清除所有强提醒
  void _resetGroupAtType() {
    // 删除所有@标识/公告标识
    if (conversationInfo.groupAtType != GroupAtType.atNormal) {
      OpenIM.iMManager.conversationManager.resetConversationGroupAtType(
        conversationID: conversationInfo.conversationID,
      );
    }
  }

  /// 消息撤回（新版本）
  void revokeMsgV2(Message message) async {
    late bool canRevoke;
    if (isGroupChat) {
      // 撤回自己的消息
      if (message.sendID == OpenIM.iMManager.userID) {
        canRevoke = true;
      } else {
        // 群组或管理员撤回群成员的消息
        var list = await LoadingView.singleton.wrap(
            asyncFunction: () => OpenIM.iMManager.groupManager
                .getGroupOwnerAndAdmin(groupID: groupID!));
        var sender = list.firstWhereOrNull((e) => e.userID == message.sendID);
        var revoker =
            list.firstWhereOrNull((e) => e.userID == OpenIM.iMManager.userID);

        if (revoker != null && sender == null) {
          // 撤回者是管理员或群主 可以撤回
          canRevoke = true;
        } else if (revoker == null && sender != null) {
          // 撤回者是普通成员，但发送者是管理员或群主 不可撤回
          canRevoke = false;
        } else if (revoker != null && sender != null) {
          if (revoker.roleLevel == sender.roleLevel) {
            // 同级别 不可撤回
            canRevoke = false;
          } else if (revoker.roleLevel == GroupRoleLevel.owner) {
            // 撤回者是群主  可撤回
            canRevoke = true;
          } else {
            // 不可撤回
            canRevoke = false;
          }
        } else {
          // 都是成员 不可撤回
          canRevoke = false;
        }
      }
    } else {
      // 撤回自己的消息
      if (message.sendID == OpenIM.iMManager.userID) {
        canRevoke = true;
      }
    }
    if (canRevoke) {
      if (message.contentType == MessageType.voice) {
        stopVoice();
      }

      try {
        await LoadingView.singleton.wrap(
          asyncFunction: () => OpenIM.iMManager.messageManager.revokeMessage(
            conversationID: conversationInfo.conversationID,
            clientMsgID: message.clientMsgID!,
          ),
        );
        message.contentType = MessageType.revokeMessageNotification;
        message.notificationElem =
            NotificationElem(detail: jsonEncode(_buildRevokeInfo(message)));
        formatQuoteMessage(message.clientMsgID!);
        messageList.refresh();
      } catch (e) {
        IMViews.showToast(e.toString());
      }
    } else {
      IMViews.showToast(StrRes.noPermissionToRevoke);
    }
  }

  RevokedInfo _buildRevokeInfo(Message message) {
    return RevokedInfo.fromJson({
      'revokerID': OpenIM.iMManager.userInfo.userID,
      'revokerRole': 0,
      'revokerNickname': OpenIM.iMManager.userInfo.nickname,
      'clientMsgID': message.clientMsgID,
      'revokeTime': 0,
      'sourceMessageSendTime': 0,
      'sourceMessageSendID': message.sendID,
      'sourceMessageSenderNickname': message.senderNickname,
      'sessionType': message.sessionType,
    });
  }

  /// 复制菜单
  bool showCopyMenu(Message message) {
    return message.isTextType ||
        message.isAtTextType ||
        message.isTagTextType ||
        message.isQuoteType ||
        message.isNoticeType;
  }

  /// 删除菜单
  bool showDelMenu(Message message) {
    return !message.isPrivateType;
  }

  /// 转发菜单
  bool showForwardMenu(Message message) {
    if (message.status != MessageStatus.succeeded) {
      return false;
    }
    if (message.isNotificationType ||
        message.isPrivateType ||
        message.isCallType ||
        message.isTagVoiceType) {
      return false;
    }
    return true;
  }

  /// 回复菜单
  bool showReplyMenu(Message message) {
    if (message.status != MessageStatus.succeeded) {
      return false;
    }

    // 群聊时，普通成员如果被禁言，则不能回复
    if (isGroupChat && isMuted) {
      // 群主和管理员不受禁言影响
      if (groupMemberRoleLevel.value == GroupRoleLevel.owner ||
          groupMemberRoleLevel.value == GroupRoleLevel.admin) {
        return true;
      }
      return false;
    }

    return message.isTextType ||
        message.isVideoType ||
        message.isPictureType ||
        message.isFileType ||
        message.isQuoteType ||
        message.isCardType ||
        message.isAtTextType ||
        message.isTagTextType ||
        message.isVoiceType ||
        message.isMergerType;
  }

  /// 是否显示撤回消息菜单
  bool showRevokeMenu(Message message) {
    if (message.status != MessageStatus.succeeded ||
        message.isNotificationType ||
        message.isCallType ||
        isExceed24H(message) && isSingleChat) {
      return false;
    }
    if (isGroupChat) {
      // for (var element in ownerAndAdmin) {
      //   printInfo(
      //       info: 'show revoke menu : ${element.nickname} - ${element.userID}');
      // }
      // 群主或管理员
      if (groupMemberRoleLevel.value == GroupRoleLevel.owner ||
          (groupMemberRoleLevel.value == GroupRoleLevel.admin &&
              ownerAndAdmin.firstWhereOrNull(
                      (element) => element.userID == message.sendID) ==
                  null)) {
        return true;
      }
      if (isMuted) {
        return false;
      }
    }
    if (message.sendID == OpenIM.iMManager.userID) {
      if (DateTime.now().millisecondsSinceEpoch - (message.sendTime ??= 0) <
          (1000 * 60 * 5)) {
        return true;
      }
    }
    return false;
  }

  /// 多选菜单
  bool showMultiMenu(Message message) {
    if (message.status != MessageStatus.succeeded) {
      return false;
    }
    if (message.isNotificationType ||
        message.isPrivateType ||
        message.isCallType) {
      return false;
    }
    return true;
  }

  /// 添加表情菜单
  bool showAddEmojiMenu(Message message) {
    if (message.isPrivateType) {
      return false;
    }
    return message.contentType == MessageType.picture ||
        message.contentType == MessageType.customFace;
  }

  bool showCheckbox(Message message) {
    if (message.isNotificationType ||
        message.isPrivateType ||
        message.isCallType ||
        message.status != MessageStatus.succeeded) {
      return false;
    }
    return multiSelMode.value;
  }

  WillPopCallback? willPop() {
    return multiSelMode.value || isShowPopMenu.value
        ? () async => exit()
        : null;
  }

  void expandCallingMemberPanel() {
    showCallingMember.value = !showCallingMember.value;
  }

  void _queryGroupCallingInfo() async {}

  void joinGroupCalling() async {}

  /// 当滚动位置处于底部时，将新镇的消息放入列表里
  void onScrollToTop() {
    if (scrollingCacheMessageList.isNotEmpty) {
      messageList.addAll(scrollingCacheMessageList);
      scrollingCacheMessageList.clear();
    }
  }

  String get markText {
    String? phoneNumber = imLogic.userInfo.value.phoneNumber;
    if (phoneNumber != null) {
      int start = phoneNumber.length > 4 ? phoneNumber.length - 4 : 0;
      final sub = phoneNumber.substring(start);
      return "${OpenIM.iMManager.userInfo.nickname!}$sub";
    }
    return OpenIM.iMManager.userInfo.nickname ?? '';
  }

  bool isFailedHintMessage(Message message) {
    if (message.contentType == MessageType.custom) {
      var data = message.customElem!.data;
      var map = json.decode(data!);
      var customType = map['customType'];
      return customType == CustomMessageType.deletedByFriend ||
          customType == CustomMessageType.blockedByFriend;
    }
    return false;
  }

  void sendFriendVerification() =>
      AppNavigator.startSendVerificationApplication(userID: userID);

  void _setSdkSyncDataListener() {
    connectionSub = imLogic.imSdkStatusPublishSubject.listen((value) {
      syncStatus.value = value.status;
      // -1 链接失败 0 铊接中 1 链接成功 2 同步开始 3 同步结束 4 同步错误
      if (value.status == IMSdkStatus.syncStart) {
        _isStartSyncing = true;
      } else if (value.status == IMSdkStatus.syncEnded) {
        if (/*_isReceivedMessageWhenSyncing &&*/ _isStartSyncing) {
          _isReceivedMessageWhenSyncing = false;
          _isStartSyncing = false;
          _isFirstLoad = true;
          _loadHistoryForSyncEnd();
        }
      } else if (value.status == IMSdkStatus.syncFailed) {
        _isReceivedMessageWhenSyncing = false;
        _isStartSyncing = false;
      }
    });
  }

  bool get isSyncFailed => syncStatus.value == IMSdkStatus.syncFailed;

  String? get syncStatusStr {
    switch (syncStatus.value) {
      case IMSdkStatus.syncStart:
      case IMSdkStatus.synchronizing:
        return StrRes.synchronizing;
      case IMSdkStatus.syncFailed:
        return StrRes.syncFailed;
      default:
        return null;
    }
  }

  bool showBubbleBg(Message message) {
    return !isNotificationType(message) &&
        !isFailedHintMessage(message) &&
        !isRevokeMessage(message);
  }

  bool isRevokeMessage(Message message) {
    return message.contentType == MessageType.revokeMessageNotification;
  }

  void markRevokedMessage(Message message) {
    if (message.contentType == MessageType.text ||
        message.contentType == MessageType.atText ||
        message.isQuoteType) {
      revokedTextMessage[message.clientMsgID!] = jsonEncode(message);
    }
  }

  bool canEditMessage(Message message) =>
      revokedTextMessage.containsKey(message.clientMsgID);

  void reEditMessage(Message message) {
    final value = revokedTextMessage[message.clientMsgID!]!;
    final json = jsonDecode(value);
    final old = Message.fromJson(json);
    String? content;
    if (old.contentType == MessageType.atText) {
      final atElem = old.atTextElem;
      content = atElem?.text;
      final list = atElem?.atUsersInfo;
      if (null != list) {
        for (final u in list) {
          _setAtMapping(
            userID: u.atUserID!,
            nickname: u.groupNickname!,
          );
          var uid = u.atUserID!;
          if (curMsgAtUser.contains(uid)) return;
          curMsgAtUser.add(uid);
        }
      }
    } else if (old.contentType == MessageType.quote) {
      content = old.quoteElem!.text;
      setQuoteMsg(old.quoteMessage);
    } else {
      content = old.textElem!.content;
    }
    inputCtrl.text = content ?? '';
    focusNode.requestFocus();
    inputCtrl.selection = TextSelection.fromPosition(TextPosition(
      offset: content?.length ?? 0,
    ));
  }

  Future<AdvancedMessage> _requestHistoryMessage() {
    Logger.print(
        '==========_requestHistoryMessage: is first load: $_isFirstLoad, last min seq: $lastMinSeq, last client id: ${_isFirstLoad ? null : messageList.firstOrNull?.clientMsgID}');
    return OpenIM.iMManager.messageManager.getAdvancedHistoryMessageList(
      conversationID: conversationInfo.conversationID,
      count: _pageSize,
      startMsg: _isFirstLoad ? null : messageList.firstOrNull,
    );
  }

  Future<bool> onScrollToBottomLoad() async {
    late List<Message> list;
    final result = await _requestHistoryMessage();
    if (result.messageList == null || result.messageList!.isEmpty) {
      _getGroupInfoAfterLoadMessage();

      return false;
    }
    list = result.messageList!;
    lastMinSeq = result.lastMinSeq;
    if (_isFirstLoad) {
      _isFirstLoad = false;
      // remove the message that has been timed down
      list.removeWhere((msg) => _isBeDeleteMessage(msg));
      messageList.assignAll(list);

      // Mark private messages as read immediately when entering ChatPage
      _markPrivateMessagesAsRead();

      scrollBottom();

      _getGroupInfoAfterLoadMessage();
    } else {
      list.removeWhere((msg) => _isBeDeleteMessage(msg));
      messageList.insertAll(0, list);
    }
    var list2Count = 0;
    // There is currently a bug on the server side. If the number obtained once is less than one page, get it again.
    if (list.isNotEmpty && list.length < _pageSize) {
      final result = await _requestHistoryMessage();
      if (result.messageList?.isNotEmpty == true) {
        final list2 = result.messageList!;
        lastMinSeq = result.lastMinSeq;
        list2.removeWhere((msg) => _isBeDeleteMessage(msg));
        list2Count = list2.length;
        messageList.insertAll(0, list2);
      }
    }

    return list.length + list2Count >= _pageSize;
  }

  void _getGroupInfoAfterLoadMessage() {
    if (isGroupChat && ownerAndAdmin.isEmpty) {
      _isJoinedGroup();
    } else {
      _checkInBlacklist();
    }
  }

  Future<void> _loadHistoryForSyncEnd([bool scrollToBottom = true]) async {
    final result =
        await OpenIM.iMManager.messageManager.getAdvancedHistoryMessageList(
      conversationID: conversationInfo.conversationID,
      count: messageList.isEmpty ? _pageSize : messageList.length,
      startMsg: null,
    );
    if (result.messageList == null || result.messageList!.isEmpty) return;
    final list = result.messageList!;
    lastMinSeq = result.lastMinSeq;
    list.removeWhere((msg) => _isBeDeleteMessage(msg));
    messageList.assignAll(list);
    if (scrollToBottom) {
      scrollBottom();
    }
  }

  bool _isBeDeleteMessage(Message message) {
    final isPrivate = message.attachedInfoElem?.isPrivateChat ?? false;
    final hasReadTime = message.hasReadTime ?? 0;
    if (isPrivate && hasReadTime > 0) {
      return readTime(message) <= 0;
    }
    return false;
  }

  /// Mark all private messages from others as read when entering ChatPage
  void _markPrivateMessagesAsRead() {
    for (var message in messageList) {
      // Only mark messages from others (not sent by me)
      if (message.sendID != OpenIM.iMManager.userID) {
        final isPrivate = message.attachedInfoElem?.isPrivateChat ?? false;
        if (isPrivate && !message.isRead!) {
          message.isRead = true;
          message.hasReadTime = _timestamp;
        }
      }
    }
    messageList.refresh();
  }

  /// Determine if we should show the nickname above a message on the left side (received msgs)
  /// Rules:
  /// - Single chat: never show
  /// - Group chat: hide for my own messages
  /// - Group chat: for others, show only when the previous message (older one)
  ///   is from a different sender or the time gap is greater than 2 minutes
  bool shouldShowLeftNicknameAt(int index) {
    if (isSingleChat) return false;

    final list = IMUtils.calChatTimeInterval(messageList).reversed.toList();
    if (index < 0 || index >= list.length) return false;

    final msg = list[index];
    // Never show nickname for own messages
    if (msg.sendID == OpenIM.iMManager.userID) return false;

    // If there is no previous (older) message in the list, show
    final int prevIndex = index + 1;
    if (prevIndex >= list.length) return true;

    final prev = list[prevIndex];
    // If previous message is system/notification, treat as a break
    if (prev.isNotificationType) return true;

    // If different sender, show
    if (prev.sendID != msg.sendID) return true;

    // If same sender but time gap > 2 minutes, show
    final curTime = msg.sendTime ?? 0;
    final prevTime = prev.sendTime ?? 0;
    return (curTime - prevTime).abs() > 2 * 60 * 1000;
  }

  /// In group chat, do not show nickname for messages I send
  bool shouldShowRightNicknameAt(int index) {
    if (isSingleChat) return false;
    return false;
  }

  final List<String> _commonEmojis = [
    '😀',
    '😃',
    '😄',
    '😁',
    '😆',
    '😅',
    '😂',
    '🤣',
    '😊',
    '😇',
    '🙂',
    '🙃',
    '😉',
    '😌',
    '😍',
    '🥰',
    '😘',
    '😗',
    '😙',
    '😚',
    '😋',
    '😛',
    '😝',
    '😜',
    '🤪',
    '🤨',
    '🧐',
    '🤓',
    '😎',
    '🤩',
    '🥳',
    '😏',
    '😒',
    '😞',
    '😔',
    '😟',
    '😕',
    '🙁',
    '☹️',
    '😣',
    '😖',
    '😫',
    '😩',
    '🥺',
    '😢',
    '😭',
    '😤',
    '😠',
    '😡',
    '🤬',
    '🤯',
    '😳',
    '🥵',
    '🥶',
    '😱',
    '😨',
    '😰',
    '😥',
    '😓',
    '🤗',
    '🤔',
    '🤭',
    '🤫',
    '🤥',
    '😶',
    '😐',
    '😑',
    '😯',
    '😦',
    '😧',
    '😮',
    '😲',
    '😴',
    '🤤',
    '😪',
    '😵',
    '🤐',
    '🥴',
    '🤢',
    '🤮',
    '🤧',
    '😷',
    '🤒',
    '🤕',
    '🤑',
    '🤠',
    '💩',
    '👻',
    '💀',
    '☠️',
    '👽',
    '👾',
    '🤖',
    '😺',
    '😸',
    '😹',
    '😻',
    '😼',
    '😽',
    '🙀',
    '😿',
    '😾',
    '🙈',
    '🙉',
    '🙊',
    '🐵',
    '🐒',
    '🦍',
    '🦧',
    '🐶',
    '🐕',
    '🐩',
    '🐺',
    '🦊',
    '🦝',
    '🐱',
    '🐈',
    '🦁',
    '🐯',
    '🐅',
    '🐆',
    '🐎',
    '🐖',
    '🐏',
    '🐑',
    '🐐',
    '🦌',
    '🐕',
    '🐩',
    '🐺',
    '🦊',
    '🦝',
    '🐱',
    '🐈',
    '🦁',
    '🐯',
  ];

  // Define isMessageHidden method
  bool isMessageHidden(dynamic message) {
    if (message is Message) {
      return clientConfigLogic.isMessageHidden(
          message, groupMemberRoleLevel.value);
    }
    return false;
  }

  // Define onClickTitle getter
  VoidCallback get onClickTitle => () {
        // Add logic for handling title click
      };
}

/// Emoji picker button widget with hover animation
class _EmojiPickerButton extends StatefulWidget {
  final String emoji;
  final VoidCallback onSelected;

  const _EmojiPickerButton({
    required this.emoji,
    required this.onSelected,
  });

  @override
  State<_EmojiPickerButton> createState() => _EmojiPickerButtonState();
}

class _EmojiPickerButtonState extends State<_EmojiPickerButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: _isHovered
                    ? const Color(0xFFF3F4F6)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? const Color(0x149CA3AF)
                        : const Color(0x0F9CA3AF),
                    offset: const Offset(0, 2),
                    blurRadius: _isHovered ? 6 : 4,
                  ),
                ],
                border: Border.all(
                  color: _isHovered
                      ? const Color(0xFFD1D5DB)
                      : const Color(0xFFF3F4F6),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: widget.onSelected,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        widget.emoji,
                        style: const TextStyle(
                          fontSize: 24,
                          fontFamily: 'Apple Color Emoji',
                          fontFamilyFallback: ["Noto Emoji"],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
