import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:get/get.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';

import '../../../core/controller/im_controller.dart';
import '../../../core/controller/push_controller.dart';
import '../../../core/controller/trtc_controller.dart';
import '../../conversation/conversation_logic.dart';

class AccountSetupLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final curLanguage = "".obs;
  final pushLogic = Get.find<PushController>();
  final trtcLogic = Get.find<TRTCController>();

  final teenModeEnabled = false.obs;
  String? teenModePassword;

  @override
  void onReady() {
    _updateLanguage();
    _loadTeenModeState();
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  @override
  void onInit() {
    _queryMyFullInfo();
    super.onInit();
  }

  /// 全局免打扰 0：正常；1：不接受消息；2：接受在线消息不接受离线消息；
  bool get isGlobalNotDisturb => imLogic.userInfo.value.globalRecvMsgOpt == 2;

  bool get isAllowAddFriend => imLogic.userInfo.value.allowAddFriend == 1;

  bool get isAllowBeep => imLogic.userInfo.value.allowBeep == 1;

  bool get isAllowVibration => imLogic.userInfo.value.allowVibration == 1;

  void _queryMyFullInfo() async {
    final data = await LoadingView.singleton.wrap(
      asyncFunction: () => ChatApis.queryMyFullInfo(),
    );
    if (data is UserFullInfo) {
      final userInfo = UserFullInfo.fromJson(data.toJson());
      imLogic.userInfo.update((val) {
        val?.allowAddFriend = userInfo.allowAddFriend;
        val?.allowBeep = userInfo.allowBeep;
        val?.allowVibration = userInfo.allowVibration;
      });
    }
  }

  void toggleNotDisturbMode() async {
    var status = isGlobalNotDisturb ? 0 : 2;
    await LoadingView.singleton.wrap(
        asyncFunction: () =>
            OpenIM.iMManager.userManager.setSelfInfo(globalRecvMsgOpt: status));
    imLogic.userInfo.update((val) {
      val?.globalRecvMsgOpt = status;
    });
  }

  void toggleBeep() async {
    final allowBeep = !isAllowBeep ? 1 : 2;
    // 1关闭 2开启
    await LoadingView.singleton.wrap(
      asyncFunction: () => ChatApis.updateUserInfo(
        allowBeep: allowBeep,
        userID: OpenIM.iMManager.userID,
      ),
    );
    imLogic.userInfo.update((val) {
      val?.allowBeep = allowBeep;
    });
  }

  void toggleVibration() async {
    final allowVibration = !isAllowVibration ? 1 : 2;
    // 1关闭 2开启
    await LoadingView.singleton.wrap(
      asyncFunction: () => ChatApis.updateUserInfo(
        allowVibration: allowVibration,
        userID: OpenIM.iMManager.userID,
      ),
    );
    imLogic.userInfo.update((val) {
      val?.allowVibration = allowVibration;
    });
  }

  void toggleForbidAddMeToFriend() async {
    final allowAddFriend = !isAllowAddFriend ? 1 : 2;
    // 1关闭 2开启
    await LoadingView.singleton.wrap(
      asyncFunction: () => ChatApis.updateUserInfo(
        allowAddFriend: allowAddFriend,
        userID: OpenIM.iMManager.userID,
      ),
    );
    imLogic.userInfo.update((val) {
      val?.allowAddFriend = allowAddFriend;
    });
  }

  void blacklist() => AppNavigator.startBlacklist();

  void clearChatHistory() async {
    var confirm = await Get.dialog(
        barrierColor: Colors.transparent,
        CustomDialog(
          title: StrRes.confirmClearChatHistory,
        ));
    if (confirm == true) {
      try {
        await LoadingView.singleton.wrap(asyncFunction: () async {
          await OpenIM.iMManager.messageManager.deleteAllMsgFromLocalAndSvr();
          await OpenIM.iMManager.conversationManager.hideAllConversations();
          await Future.delayed(const Duration(milliseconds: 100), () {
            if (Get.isRegistered<ConversationLogic>()) {
              Get.find<ConversationLogic>().onRefresh();
            }
          });
        });
        IMViews.showToast(StrRes.clearSuccessfully);
      } catch (e) {
        Logger.print('Clear chat history error: $e');
        IMViews.showToast(e.toString());
      }
    }
  }

  void deleteAccount() async {
    var confirm = await Get.dialog(
        barrierColor: Colors.transparent,
        CustomDialog(
          title: StrRes.confirmDeleteAccount,
          content: StrRes.confirmDeleteAccountContent,
        ));
    if (confirm == true) {
      await Get.dialog(
          barrierColor: Colors.transparent,
          CustomDialog(
            title: StrRes.confirmDeleteAccountTipsTitle,
            content: StrRes.confirmDeleteAccountTipsContent,
            showCancel: false,
          ));
      try {
        await LoadingView.singleton.wrap(asyncFunction: () async {
          await imLogic.logout();
          await DataSp.removeLoginCertificate();
          pushLogic.logout();
          trtcLogic.logout();
        });
        AppNavigator.startInviteCode();
      } catch (e) {
        IMViews.showToast('e:$e');
      }
    }
  }

  Future<void> languageSetting() async {
    await AppNavigator.startLanguageSetup();
    _updateLanguage();
  }

  void _updateLanguage() {
    var index = DataSp.getLanguage() ?? 0;
    switch (index) {
      case 1:
        curLanguage.value = StrRes.chinese;
        break;
      case 2:
        curLanguage.value = StrRes.english;
        break;
      default:
        curLanguage.value = StrRes.followSystem;
        break;
    }
  }

  void unlockSetup() => AppNavigator.startUnlockSetup();

  void _loadTeenModeState() {
    teenModePassword = DataSp.getTeenModePassword();
    teenModeEnabled.value = teenModePassword != null;
  }

  void changePwd() => AppNavigator.startChangePassword();

  void toggleTeenMode() async {
    if (teenModeEnabled.value) {
      final confirm = await Get.dialog(
        barrierColor: Colors.transparent,
        CustomDialog(
          title: StrRes.disableTeenMode,
          content: StrRes.confirmDisableTeenMode,
        ),
      );

      if (confirm == true) {
        _disableTeenMode();
      }
    } else {
      final confirm = await Get.dialog(
        barrierColor: Colors.transparent,
        CustomDialog(
          title: StrRes.enableTeenMode,
          content: StrRes.confirmEnableTeenMode,
        ),
      );

      if (confirm == true) {
        _enableTeenMode();
      }
    }
  }

  void _disableTeenMode() {
    screenLock(
      context: Get.context!,
      correctString: teenModePassword!,
      title: StrRes.enterPasswordToDisableTeenMode.toText
        ..style = Styles.ts_FFFFFF_17sp,
      onUnlocked: () async {
        await DataSp.clearTeenModePassword();
        teenModeEnabled.value = false;
        teenModePassword = null;
        Get.back();
      },
    );
  }

  void _enableTeenMode() {
    final controller = InputController();
    screenLockCreate(
      context: Get.context!,
      inputController: controller,
      title: StrRes.enterTeenModePassword.toText..style = Styles.ts_FFFFFF_17sp,
      confirmTitle: StrRes.plsConfirmPasswordAgain.toText
        ..style = Styles.ts_FFFFFF_17sp,
      cancelButton: StrRes.cancel.toText..style = Styles.ts_FFFFFF_17sp,
      onConfirmed: (matchedText) async {
        teenModePassword = matchedText;
        await DataSp.putTeenModePassword(matchedText);
        teenModeEnabled.value = true;
        Get.back();
      },
      footer: TextButton(
        onPressed: () {
          controller.unsetConfirmed();
        },
        child: StrRes.resetInput.toText..style = Styles.ts_0089FF_17sp,
      ),
    );
  }
}
