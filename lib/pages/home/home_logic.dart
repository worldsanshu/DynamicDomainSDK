import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:local_auth/local_auth.dart';
import 'package:openim/core/controller/client_config_controller.dart';
import 'package:openim/core/controller/gateway_config_controller.dart';
import 'package:openim/pages/contacts/add_by_search/add_by_search_logic.dart';
import 'package:openim/utils/upgrade_manager.dart';
import 'package:openim_common/openim_common.dart';
import 'package:rxdart/rxdart.dart';

import '../../core/controller/app_controller.dart';
import '../../core/controller/im_controller.dart';
import '../../core/controller/push_controller.dart';
import '../../core/im_callback.dart';
import '../../core/controller/trtc_controller.dart';
import '../../routes/app_navigator.dart';
import '../../widgets/screen_lock_title.dart';
import '../contacts/friend_list_logic.dart';

class HomeLogic extends SuperController with UpgradeManger {
  var list = <ConversationInfo>[].obs;
  final pushLogic = Get.find<PushController>();
  final imLogic = Get.find<IMController>();
  final cacheLogic = Get.find<CacheController>();
  final initLogic = Get.find<AppController>();
  final merchantLogic = Get.find<MerchantController>();
  final gatewayDomainLogic = Get.find<GatewayDomainController>();
  final friendListLogic = Get.find<FriendListLogic>();
  final trtcLogic = Get.find<TRTCController>();
  final index = 0.obs;
  final unreadMsgCount = 0.obs;
  final unhandledFriendApplicationCount = 0.obs;
  final unhandledGroupApplicationCount = 0.obs;
  final unhandledCount = 0.obs;
  String? _lockScreenPwd;
  bool _isShowScreenLock = false;
  bool? _isAutoLogin;
  final auth = LocalAuthentication();
  final _errorController = PublishSubject<String>();
  var conversationsAtFirstPage = <ConversationInfo>[];

  final clientConfigLogic = Get.find<ClientConfigController>();
  final gatewayConfigController = Get.find<GatewayConfigController>();

  String get discoverPageURL => clientConfigLogic.discoverPageURL;

  late StreamSubscription kickedOfflineSub;

  Function()? onScrollToUnreadMessage;

  switchTab(index) {
    this.index.value = index;
    if (index == 0) {
      imLogic.switchConversationStream.add(true);
    }
  }

  scrollToUnreadMessage(index) {
    onScrollToUnreadMessage?.call();
  }

  /// 获取消息未读数
  _getUnreadMsgCount() {
    // OpenIM.iMManager.conversationManager.getAllConversationList().then((list) {
    //   initLogic.showBadge(
    //       list.where((conversation) => conversation.unreadCount > 0).length);
    // });

    OpenIM.iMManager.conversationManager.getTotalUnreadMsgCount().then((value) {
      unreadMsgCount.value = int.tryParse(value.toString()) ?? 0;
      initLogic.showBadge(unreadMsgCount.value);
    });
  }

  /// 获取好友申请未处理数
  /// 浏览过得不再计入红点
  void getUnhandledFriendApplicationCount() async {
    var i = 0;
    var list = await OpenIM.iMManager.friendshipManager
        .getFriendApplicationListAsRecipient();
    var haveReadList = DataSp.getHaveReadUnHandleFriendApplication();
    haveReadList ??= <String>[];
    for (var info in list) {
      var id = IMUtils.buildFriendApplicationID(info);
      if (!haveReadList.contains(id)) {
        if (info.handleResult == 0) i++;
      }
    }
    unhandledFriendApplicationCount.value = i;
    unhandledCount.value = unhandledGroupApplicationCount.value + i;
  }

  /// 获取群申请未处理数
  void getUnhandledGroupApplicationCount() async {
    var i = 0;
    var list = await OpenIM.iMManager.groupManager
        .getGroupApplicationListAsRecipient();
    var haveReadList = DataSp.getHaveReadUnHandleGroupApplication();
    haveReadList ??= <String>[];
    for (var info in list) {
      var id = IMUtils.buildGroupApplicationID(info);
      if (!haveReadList.contains(id)) {
        if (info.handleResult == 0) i++;
      }
    }
    unhandledGroupApplicationCount.value = i;
    unhandledCount.value = unhandledFriendApplicationCount.value + i;
  }

  Future<void> ensureFriendListLoaded() async {
    // Wait for SDK sync to complete before loading friend list
    try {
      // Check if sync is already completed
      final currentStatus = await imLogic.imSdkStatusPublishSubject.first
          .timeout(const Duration(seconds: 2), onTimeout: () {
        return (
          status: IMSdkStatus.syncEnded,
          reInstall: false,
          progress: null
        );
      });

      // If sync is in progress, wait for it to complete
      if (currentStatus.status == IMSdkStatus.syncProgress ||
          currentStatus.status == IMSdkStatus.syncStart) {
        Logger.print('Waiting for SDK sync to complete...');
        await imLogic.imSdkStatusPublishSubject
            .firstWhere((status) =>
                status.status == IMSdkStatus.syncEnded ||
                status.status == IMSdkStatus.syncFailed)
            .timeout(const Duration(seconds: 30));
        Logger.print('SDK sync completed');
      }
    } catch (e) {
      Logger.print('Error waiting for sync: $e');
    }

    // Add a small delay to ensure data is ready
    await Future.delayed(const Duration(milliseconds: 500));

    // Try to load friend list with retries
    for (int i = 0; i < 3; i++) {
      final result = await friendListLogic.refreshFriendList();
      if (result == true) {
        Logger.print('Friend list loaded successfully on attempt ${i + 1}');
        return;
      }
      await Future.delayed(const Duration(seconds: 1));
    }

    Logger.print('Failed to load friend list after 3 attempts');
  }

  void onChanged(newList) {
    if (newList is List<ConversationInfo>) {
      _getUnreadMsgCount();
    }
  }

  _localAuth() async {
    final didAuthenticate = await IMUtils.checkingBiometric(auth);
    if (didAuthenticate) {
      Get.back();
    }
  }

  _showLockScreenPwd() async {
    if (_isShowScreenLock) return;
    _lockScreenPwd = DataSp.getLockScreenPassword();
    if (null != _lockScreenPwd) {
      final isEnabledBiometric = DataSp.isEnabledBiometric() == true;
      bool enabled = false;
      if (isEnabledBiometric) {
        final isSupportedBiometrics = await auth.isDeviceSupported();
        final canCheckBiometrics = await auth.canCheckBiometrics;
        enabled = isSupportedBiometrics && canCheckBiometrics;
      }
      _isShowScreenLock = true;
      screenLock(
        context: Get.context!,
        correctString: _lockScreenPwd!,
        maxRetries: 3,
        title: ScreenLockTitle(stream: _errorController.stream),
        canCancel: false,
        customizedButtonChild:
            enabled ? const Icon(Ionicons.finger_print) : null,
        customizedButtonTap: enabled ? () async => await _localAuth() : null,
        // onOpened: enabled ? () async => await _localAuth() : null,
        onUnlocked: () {
          _isShowScreenLock = false;
          Get.back();
        },
        onMaxRetries: (_) async {
          Get.back();
          await LoadingView.singleton.wrap(asyncFunction: () async {
            await imLogic.logout();
            await DataSp.removeLoginCertificate();
            await DataSp.clearLockScreenPassword();
            await DataSp.closeBiometric();
            pushLogic.logout();
          });
          AppNavigator.startInviteCode();
        },
        onError: (retries) {
          _errorController.sink.add(
            retries.toString(),
          );
        },
      );
    }
  }

  var checking = false;
  void checkClipboard() async {
    if (checking == true) return;
    checking = true;
    await Future.delayed(const Duration(milliseconds: 500));
    final confirm = await gatewayDomainLogic.trySwitchToClipboardDomain();
    if (confirm == true) {
      imLogic.logout();
      await DataSp.removeLoginCertificate();
      pushLogic.logout();
      IMViews.showToast('已更换域名，请重新登录');
      AppNavigator.startInviteCode();
    }
    checking = false;
  }

  void _handleClipboardDomainCheck() {
    if (gatewayConfigController.enableClipboardDomainCheck) {
      checkClipboard();
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
        var confirm = await CustomDialog.show(
          title: StrRes.realNameAuthRequiredForGroup,
          rightText: StrRes.goToRealNameAuth,
        );
        if (confirm == true) AppNavigator.startRealNameAuth();
        return;
      }
    } catch (e) {
      var confirm = await CustomDialog.show(
        title: StrRes.realNameAuthRequiredForGroup,
        rightText: StrRes.goToRealNameAuth,
      );
      if (confirm == true) AppNavigator.startRealNameAuth();
      return;
    }

    AppNavigator.startCreateGroup();
  }

  addGroup() =>
      AppNavigator.startAddContactsBySearch(searchType: SearchType.group);

  void kickedOffline({String? tips}) async {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }

    IMViews.showToast(tips ?? StrRes.accountException, type: 2);
    await DataSp.removeLoginCertificate();
    pushLogic.logout();
    trtcLogic.logout();
    AppNavigator.startInviteCode();
  }

  @override
  void onInit() {
    _isAutoLogin = Get.arguments != null ? Get.arguments['isAutoLogin'] : false;
    if (_isAutoLogin == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showLockScreenPwd());
    }
    // conversationsAtFirstPage = Get.arguments['conversations'] ?? [];
    conversationsAtFirstPage = Get.arguments?['conversations'] ?? [];
    imLogic.unreadMsgCountEventSubject.listen((value) {
      unreadMsgCount.value = value;
    });
    imLogic.friendApplicationChangedSubject.listen((value) {
      getUnhandledFriendApplicationCount();
    });
    imLogic.groupApplicationChangedSubject.listen((value) {
      getUnhandledGroupApplicationCount();
    });
    imLogic.imSdkStatusPublishSubject.listen((value) {
      if (value.status == IMSdkStatus.connectionSucceeded) {}
    });

    kickedOfflineSub = imLogic.onKickedOfflineSubject.listen((value) {
      if (value == KickoffType.userTokenInvalid) {
        kickedOffline(tips: StrRes.tokenInvalid);
      } else if (value.index == 2) {
        kickedOffline(tips: StrRes.passwordChanged);
      } else {
        kickedOffline();
      }
    });

    Apis.kickoffController.stream.listen((event) {
      DataSp.removeLoginCertificate();
      Get.find<PushController>().logout();
      AppNavigator.startInviteCode();
    });

    super.onInit();
  }

  @override
  void onReady() {
    ensureFriendListLoaded();
    trtcLogic.ensureTRTCReady();
    _getUnreadMsgCount();
    getUnhandledFriendApplicationCount();
    getUnhandledGroupApplicationCount();
    cacheLogic.initCallRecords();
    cacheLogic.initFavoriteEmoji();

    // Clear pending group application updates on app restart
    DataSp.clearGroupApplicationPendingUpdates();

    super.onReady();
    checkUpdate();
    _handleClipboardDomainCheck();
  }

  @override
  void onClose() {
    _errorController.close();
    kickedOfflineSub.cancel();
    super.onClose();
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  @override
  void onResumed() {
    _handleClipboardDomainCheck();
  }

  @override
  void onHidden() {}
}
