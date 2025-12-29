import 'dart:ui' show window;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';

import '../../../widgets/custom_bottom_sheet.dart';
import '../../../widgets/settings_menu.dart';
import '../unlock_setup/unlock_setup_logic.dart';

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

    // When enabling DND mode, automatically disable sound and vibration
    if (status == 2) {
      // Disable sound if currently enabled
      if (isAllowBeep) {
        await ChatApis.updateUserInfo(
          allowBeep: 2, // 2 = disabled
          userID: OpenIM.iMManager.userID,
        );
        imLogic.userInfo.update((val) {
          val?.allowBeep = 2;
        });
      }
      // Disable vibration if currently enabled
      if (isAllowVibration) {
        await ChatApis.updateUserInfo(
          allowVibration: 2, // 2 = disabled
          userID: OpenIM.iMManager.userID,
        );
        imLogic.userInfo.update((val) {
          val?.allowVibration = 2;
        });
      }
    }
  }

  void toggleBeep() async {
    final allowBeep = !isAllowBeep ? 1 : 2;
    // 1 = enabled, 2 = disabled
    await LoadingView.singleton.wrap(
      asyncFunction: () => ChatApis.updateUserInfo(
        allowBeep: allowBeep,
        userID: OpenIM.iMManager.userID,
      ),
    );
    imLogic.userInfo.update((val) {
      val?.allowBeep = allowBeep;
    });

    // When enabling sound, automatically disable DND mode
    if (allowBeep == 1 && isGlobalNotDisturb) {
      await OpenIM.iMManager.userManager.setSelfInfo(globalRecvMsgOpt: 0);
      imLogic.userInfo.update((val) {
        val?.globalRecvMsgOpt = 0;
      });
    }
  }

  void toggleVibration() async {
    final allowVibration = !isAllowVibration ? 1 : 2;
    // 1 = enabled, 2 = disabled
    await LoadingView.singleton.wrap(
      asyncFunction: () => ChatApis.updateUserInfo(
        allowVibration: allowVibration,
        userID: OpenIM.iMManager.userID,
      ),
    );
    imLogic.userInfo.update((val) {
      val?.allowVibration = allowVibration;
    });

    // When enabling vibration, automatically disable DND mode
    if (allowVibration == 1 && isGlobalNotDisturb) {
      await OpenIM.iMManager.userManager.setSelfInfo(globalRecvMsgOpt: 0);
      imLogic.userInfo.update((val) {
        val?.globalRecvMsgOpt = 0;
      });
    }
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

  void blacklist() => _showBlacklistBottomSheet();

  void _showBlacklistBottomSheet() async {
    // Get blacklist
    final blacklist = <BlacklistInfo>[].obs;
    final list = await OpenIM.iMManager.friendshipManager.getBlacklist();
    blacklist.addAll(list);

    CustomBottomSheet.show(
      title: StrRes.blacklist,
      icon: CupertinoIcons.nosign,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtitle with count
          Container(
            margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
            alignment: Alignment.centerLeft,
            child: Obx(() => Text(
                  '${blacklist.length} ${StrRes.blockedContacts}',
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9CA3AF),
                  ),
                )),
          ),

          // Blacklist content
          Container(
            constraints: BoxConstraints(maxHeight: 0.5.sh),
            child: Obx(() => blacklist.isEmpty
                ? Container(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.person_crop_circle_badge_xmark,
                          size: 60.w,
                          color: const Color(0xFFD1D5DB),
                        ),
                        16.verticalSpace,
                        Text(
                          StrRes.blacklistEmpty,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 14.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: blacklist.length,
                    itemBuilder: (context, index) {
                      final info = blacklist[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9CA3AF).withOpacity(0.06),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Row(
                            children: [
                              AvatarView(
                                url: info.faceURL,
                                text: info.nickname,
                                width: 48.w,
                                height: 48.h,
                                isCircle: true,
                              ),
                              12.horizontalSpace,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      info.nickname ?? '',
                                      style: TextStyle(
                                        fontFamily: 'FilsonPro',
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1F2937),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    4.verticalSpace,
                                    Text(
                                      'ID: ${info.userID ?? ''}',
                                      style: TextStyle(
                                        fontFamily: 'FilsonPro',
                                        fontSize: 12.sp,
                                        color: const Color(0xFF9CA3AF),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await OpenIM.iMManager.friendshipManager
                                      .removeBlacklist(
                                    userID: info.userID!,
                                  );
                                  blacklist.remove(info);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    StrRes.remove,
                                    style: TextStyle(
                                      fontFamily: 'FilsonPro',
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFDC2626),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )),
          ),
        ],
      ),
    );
  }

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
        IMViews.showToast(StrRes.clearSuccessfully, type: 1);
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
    await _showLanguageBottomSheet();
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

  void unlockSetup() => _showUnlockBottomSheet();

  void _loadTeenModeState() {
    teenModePassword = DataSp.getTeenModePassword();
    teenModeEnabled.value = teenModePassword != null;
  }

  void changePwd() => _showChangePasswordBottomSheet();

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

  // Language Setup Bottom Sheet
  Future<void> _showLanguageBottomSheet() async {
    final selectedLanguage = Rx<int>(DataSp.getLanguage() ?? 0);

    await CustomBottomSheet.show(
      title: StrRes.languageSetup,
      icon: CupertinoIcons.globe,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        child: Obx(() => SettingsMenuSection(
              items: [
                SettingsMenuItem(
                  iconWidget: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Get.theme.primaryColor.withOpacity(0.1),
                          Get.theme.primaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      CupertinoIcons.device_phone_portrait,
                      size: 20.w,
                      color: Get.theme.primaryColor,
                    ),
                  ),
                  label: StrRes.followSystem,
                  onTap: () {
                    selectedLanguage.value = 0;
                    _switchLanguage(0);
                  },
                  showArrow: false,
                  valueWidget: selectedLanguage.value == 0
                      ? Icon(
                          Icons.check_circle,
                          color: Get.theme.primaryColor,
                          size: 24.w,
                        )
                      : null,
                ),
                SettingsMenuItem(
                  iconWidget: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Get.theme.primaryColor.withOpacity(0.1),
                          Get.theme.primaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      CupertinoIcons.textformat,
                      size: 20.w,
                      color: Get.theme.primaryColor,
                    ),
                  ),
                  label: StrRes.chinese,
                  onTap: () {
                    selectedLanguage.value = 1;
                    _switchLanguage(1);
                  },
                  showArrow: false,
                  valueWidget: selectedLanguage.value == 1
                      ? Icon(
                          Icons.check_circle,
                          color: Get.theme.primaryColor,
                          size: 24.w,
                        )
                      : null,
                ),
                SettingsMenuItem(
                  iconWidget: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Get.theme.primaryColor.withOpacity(0.1),
                          Get.theme.primaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      CupertinoIcons.globe,
                      size: 20.w,
                      color: Get.theme.primaryColor,
                    ),
                  ),
                  label: StrRes.english,
                  onTap: () {
                    selectedLanguage.value = 2;
                    _switchLanguage(2);
                  },
                  showArrow: false,
                  showDivider: false,
                  valueWidget: selectedLanguage.value == 2
                      ? Icon(
                          Icons.check_circle,
                          color: Get.theme.primaryColor,
                          size: 24.w,
                        )
                      : null,
                ),
              ],
            )),
      ),
    );
  }

  void _switchLanguage(int index) async {
    await DataSp.putLanguage(index);
    switch (index) {
      case 1:
        Get.updateLocale(const Locale('zh', 'CN'));
        break;
      case 2:
        Get.updateLocale(const Locale('en', 'US'));
        break;
      default:
        Get.updateLocale(window.locale);
        break;
    }
  }

  // Unlock Setup Bottom Sheet
  void _showUnlockBottomSheet() {
    // Get or create UnlockSetupLogic
    UnlockSetupLogic unlockLogic;
    if (Get.isRegistered<UnlockSetupLogic>()) {
      unlockLogic = Get.find<UnlockSetupLogic>();
    } else {
      unlockLogic = Get.put(UnlockSetupLogic());
    }

    CustomBottomSheet.show(
      title: StrRes.unlockSettings,
      icon: CupertinoIcons.lock,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        child: Obx(() {
          List<Widget> items = [];

          items.add(
            SettingsMenuItem(
              icon: CupertinoIcons.lock,
              label: StrRes.password,
              hasSwitch: true,
              switchValue: unlockLogic.passwordEnabled.value,
              onSwitchChanged: (value) {
                unlockLogic.togglePwdLock();
              },
              showDivider: unlockLogic.passwordEnabled.value &&
                  (unlockLogic.isSupportedBiometric.value &&
                      unlockLogic.canCheckBiometrics.value),
            ),
          );

          if (unlockLogic.passwordEnabled.value &&
              (unlockLogic.isSupportedBiometric.value &&
                  unlockLogic.canCheckBiometrics.value)) {
            items.add(
              SettingsMenuItem(
                iconWidget: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Get.theme.primaryColor.withOpacity(0.1),
                        Get.theme.primaryColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    CupertinoIcons.hand_raised,
                    size: 20.w,
                    color: Get.theme.primaryColor,
                  ),
                ),
                label: StrRes.biometrics,
                hasSwitch: true,
                switchValue: unlockLogic.biometricsEnabled.value,
                onSwitchChanged: (value) {
                  unlockLogic.toggleBiometricLock();
                },
                showDivider: false,
              ),
            );
          }

          return SettingsMenuSection(items: items);
        }),
      ),
    );
  }

  // Change Password Bottom Sheet
  void _showChangePasswordBottomSheet() {
    final oldPwdCtrl = TextEditingController();
    final newPwdCtrl = TextEditingController();
    final againPwdCtrl = TextEditingController();

    final oldPwdObscure = true.obs;
    final newPwdObscure = true.obs;
    final againPwdObscure = true.obs;

    void confirm() async {
      if (oldPwdCtrl.text.isEmpty) {
        IMViews.showToast(StrRes.plsEnterOldPwd);
        return;
      }
      if (!IMUtils.isValidPassword(newPwdCtrl.text)) {
        IMViews.showToast(StrRes.wrongPasswordFormat);
        return;
      }
      if (newPwdCtrl.text.isEmpty) {
        IMViews.showToast(StrRes.plsEnterNewPwd);
        return;
      }
      if (againPwdCtrl.text.isEmpty) {
        IMViews.showToast(StrRes.plsEnterConfirmPwd);
        return;
      }
      if (newPwdCtrl.text != againPwdCtrl.text) {
        IMViews.showToast(StrRes.twicePwdNoSame);
        return;
      }

      final result = await LoadingView.singleton.wrap(
        asyncFunction: () => GatewayApi.changePassword(
          newPassword: newPwdCtrl.text,
          currentPassword: oldPwdCtrl.text,
        ),
      );
      if (result) {
        Get.back(); // Close bottom sheet
        IMViews.showToast(StrRes.changedSuccessfully, type: 1);
        await LoadingView.singleton.wrap(asyncFunction: () async {
          await OpenIM.iMManager.logout();
          await DataSp.removeLoginCertificate();
          pushLogic.logout();
          trtcLogic.logout();
        });
        AppNavigator.startInviteCode();
      }
    }

    CustomBottomSheet.show(
      title: StrRes.changePassword,
      icon: CupertinoIcons.lock_rotation,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        child: SettingsMenuSection(
          items: [
            _buildPasswordField(
              label: StrRes.oldPwd,
              controller: oldPwdCtrl,
              obscureRx: oldPwdObscure,
              icon: CupertinoIcons.lock,
            ),
            _buildPasswordField(
              label: StrRes.newPwd,
              controller: newPwdCtrl,
              obscureRx: newPwdObscure,
              icon: CupertinoIcons.lock_rotation,
            ),
            _buildPasswordField(
              label: StrRes.confirmNewPwd,
              controller: againPwdCtrl,
              obscureRx: againPwdObscure,
              icon: CupertinoIcons.checkmark_shield,
              showDivider: false,
            ),
          ],
        ),
      ),
      onConfirm: confirm,
      confirmText: StrRes.confirm,
      isDismissible: true,
    ).then((_) {
      // Add delay to ensure bottom sheet is fully closed before disposing
      Future.delayed(const Duration(milliseconds: 300), () {
        oldPwdCtrl.dispose();
        newPwdCtrl.dispose();
        againPwdCtrl.dispose();
      });
    });
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required RxBool obscureRx,
    required IconData icon,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  size: 22.w,
                  color: Colors.black,
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: Obx(
                    key: ValueKey('password_field_$label'),
                    () => Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: controller,
                                  obscureText: obscureRx.value,
                                  style: TextStyle(
                                    fontFamily: 'FilsonPro',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF374151),
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    hintText: label,
                                    hintStyle: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ),
                              ),
                              6.horizontalSpace,
                              GestureDetector(
                                onTap: () => obscureRx.value = !obscureRx.value,
                                child: Icon(
                                  obscureRx.value
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  size: 22.w,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        )),
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            margin: EdgeInsets.only(left: 68.w),
            height: 1,
            color: const Color(0xFFF3F4F6),
          ),
      ],
    );
  }
}
