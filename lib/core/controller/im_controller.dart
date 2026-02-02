import 'dart:async';

import 'package:dynamic_domain/dynamic_domain.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../im_callback.dart';

class IMController extends GetxController
    with IMCallback, WidgetsBindingObserver {
  late Rx<UserFullInfo> userInfo;
  late String atAllTag;
  Map<String, String> userRemarkMap = <String, String>{};
  Map<String, bool> friendIDMap = <String, bool>{};

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    // OpenIM.iMManager.unInitSDK();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 当应用回到前台时，主动检查并修复隧道连接
      _handleConnectFailed();
    }
  }

  Future<dynamic> unInitOpenIM() async {
    return OpenIM.iMManager.unInitSDK();
  }

  void initOpenIM({String? apiAddr, String? wsAddr}) async {
    final initialized = await OpenIM.iMManager.initSDK(
      platformID: IMUtils.getPlatform(),
      apiAddr: apiAddr?.trim() ?? '',
      wsAddr: wsAddr?.trim() ?? '',
      dataDir: Config.cachePath,
      logLevel: Config.logLevel,
      logFilePath: Config.cachePath,
      isExternalProxy: Config.proxyUrl != null,
      proxyAddr: Config.proxyUrl,
      listener: OnConnectListener(
        onConnecting: () {
          print('-------------------onConnecting-------------------');
          imSdkStatus(IMSdkStatus.connecting);
        },
        onConnectFailed: (code, error) {
          print('-------------------onConnectFailed-------------------');
          imSdkStatus(IMSdkStatus.connectionFailed);
          _handleConnectFailed();
        },
        onConnectSuccess: () {
          print('-------------------onConnectSuccess-------------------');
          imSdkStatus(IMSdkStatus.connectionSucceeded);
        },
        onKickedOffline: kickedOffline,
        onUserTokenExpired: kickedOffline,
        onUserTokenInvalid: userTokenInvalid,
      ),
    );
    // Set listener
    OpenIM.iMManager
      ..setUploadLogsListener(
          OnUploadLogsListener(onUploadProgress: uploadLogsProgress))
      //
      ..userManager.setUserListener(OnUserListener(
          onSelfInfoUpdated: (u) {
            selfInfoUpdated(u);

            userInfo.update((val) {
              val?.nickname = u.nickname;
              val?.faceURL = u.faceURL;
              // val?.gender = u.gender;
              // val?.birth = u.birth;
              // val?.email = u.email;
              val?.remark = u.remark;
              val?.ex = u.ex;
              val?.globalRecvMsgOpt = u.globalRecvMsgOpt;
            });
            // _queryMyFullInfo();
          },
          onUserStatusChanged: userStausChanged))
      // Add message listener (remove when not in use)
      ..messageManager.setAdvancedMsgListener(OnAdvancedMsgListener(
          onRecvC2CReadReceipt: recvC2CMessageReadReceipt,
          onRecvNewMessage: recvNewMessage,
          onNewRecvMessageRevoked: recvMessageRevoked,
          onRecvOfflineNewMessage: recvOfflineMessage))

      // Set up message sending progress listener
      ..messageManager.setMsgSendProgressListener(OnMsgSendProgressListener(
        onProgress: progressCallback,
      ))
      ..messageManager.setCustomBusinessListener(OnCustomBusinessListener(
        onRecvCustomBusinessMessage: recvCustomBusinessMessage,
      ))
      // Set up friend relationship listener
      ..friendshipManager.setFriendshipListener(OnFriendshipListener(
        onBlackAdded: blacklistAdded,
        onBlackDeleted: blacklistDeleted,
        onFriendApplicationAccepted: friendApplicationAccepted,
        onFriendApplicationAdded: friendApplicationAdded,
        onFriendApplicationDeleted: friendApplicationDeleted,
        onFriendApplicationRejected: friendApplicationRejected,
        onFriendInfoChanged: handleFriendInfoChanged,
        onFriendAdded: friendAdded,
        onFriendDeleted: friendDeleted,
      ))

      // Set up conversation listener
      ..conversationManager.setConversationListener(OnConversationListener(
          onConversationChanged: conversationChanged,
          onNewConversation: newConversation,
          onTotalUnreadMessageCountChanged: totalUnreadMsgCountChanged,
          onInputStatusChanged: inputStateChanged,
          onSyncServerFailed: (reInstall) {
            imSdkStatus(IMSdkStatus.syncFailed, reInstall: reInstall ?? false);
          },
          onSyncServerFinish: (reInstall) async {
            imSdkStatus(IMSdkStatus.syncEnded, reInstall: reInstall ?? false);
          },
          onSyncServerStart: (reInstall) {
            imSdkStatus(IMSdkStatus.syncStart, reInstall: reInstall ?? false);
          },
          onSyncServerProgress: (progress) {
            imSdkStatus(IMSdkStatus.syncProgress, progress: progress);
          }))

      // Set up group listener
      ..groupManager.setGroupListener(OnGroupListener(
        onGroupApplicationAccepted: groupApplicationAccepted,
        onGroupApplicationAdded: groupApplicationAdded,
        onGroupApplicationDeleted: groupApplicationDeleted,
        onGroupApplicationRejected: groupApplicationRejected,
        onGroupInfoChanged: groupInfoChanged,
        onGroupMemberAdded: groupMemberAdded,
        onGroupMemberDeleted: groupMemberDeleted,
        onGroupMemberInfoChanged: groupMemberInfoChanged,
        onJoinedGroupAdded: joinedGroupAdded,
        onJoinedGroupDeleted: joinedGroupDeleted,
        onGroupDismissed: onGroupDismissed,
      ));

    initializedSubject.sink.add(initialized);
  }

  Future login(String userID, String token) async {
    try {
      var user = await OpenIM.iMManager.login(
        userID: userID,
        token: token,
        defaultValue: () async => UserInfo(userID: userID),
      );
      userInfo = UserFullInfo.fromJson(user.toJson()).obs;
      _queryMyFullInfo();
      _queryAtAllTag();
      Future.delayed(const Duration(milliseconds: 500), () {
        initUserRemarkMap();
      });
    } catch (e, s) {
      Logger.print('e: $e  s:$s');
      await _handleLoginRepeatError(e);
      // rethrow;
      return Future.error(e, s);
    }
  }

  Future logout() {
    return OpenIM.iMManager.logout();
  }

  /// @所有人ID
  void _queryAtAllTag() async {
    atAllTag = OpenIM.iMManager.conversationManager.atAllTag;
    // atAllTag = await OpenIM.iMManager.conversationManager.getAtAllTag();
  }

  void _queryMyFullInfo() async {
    final data = await ChatApis.queryMyFullInfo();
    if (data is UserFullInfo) {
      userInfo.update((val) {
        val?.allowAddFriend = data.allowAddFriend;
        val?.allowBeep = data.allowBeep;
        val?.allowVibration = data.allowVibration;
        val?.nickname = data.nickname;
        val?.faceURL = data.faceURL;
        val?.phoneNumber = data.phoneNumber;
        val?.email = data.email;
        val?.birth = data.birth;
        val?.gender = data.gender;
      });
    }
  }

  Future<void> initUserRemarkMap() async {
    const int initialBatchSize = 10000;
    const int subsequentBatchSize = 1000;
    int offset = 0;
    int batchSize = initialBatchSize;
    List<FriendInfo> allFriends = [];

    while (true) {
      final currentBatch =
          await OpenIM.iMManager.friendshipManager.getFriendListPage(
        offset: offset,
        count: batchSize,
        filterBlack: true,
      );

      if (currentBatch.isEmpty) break;

      allFriends.addAll(currentBatch);
      offset += currentBatch.length;
      batchSize = subsequentBatchSize;
    }

    userRemarkMap = {
      for (var friend in allFriends)
        if (friend.remark?.isNotEmpty ?? false) friend.userID!: friend.remark!
    };
    friendIDMap = {for (var friend in allFriends) friend.userID!: true};
  }

  void handleFriendInfoChanged(FriendInfo u) {
    friendInfoChanged(u);
    if (u.remark?.isNotEmpty ?? false) {
      userRemarkMap[u.userID!] = u.remark!;
    } else {
      userRemarkMap.remove(u.userID);
    }
  }

  void _handleConnectFailed() async {
    // 如果连接失败，检查隧道状态
    try {
      final dynamicDomain = DynamicDomain();
      bool isHealthy = await dynamicDomain.isConnectionHealthy();
      if (!isHealthy) {
        print('Dynamic Domain 隧道连接不健康，尝试重连隧道...');
        final config =
            await dynamicDomain.fetchRemoteConfig(Config.dynamicDomainAppId);
        await dynamicDomain.startTunnel(config);
        final proxy = dynamicDomain.getProxyConfig();
        if (proxy != null) {
          await proxy.applyToEnvironment();
        }
        // 隧道重连后，OpenIM 会自动尝试重连（或手动调用 login/reconnect）
      }
    } catch (e) {
      print('检查隧道状态失败: $e');
    }
  }

  _handleLoginRepeatError(e) async {
    if (e is PlatformException && e.code == "13002") {
      await logout();
      await DataSp.removeLoginCertificate();
    }
  }
}
