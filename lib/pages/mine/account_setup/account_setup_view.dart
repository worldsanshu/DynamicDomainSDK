// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../../widgets/gradient_scaffold.dart';
import '../../../widgets/settings_menu.dart';
import '../../../widgets/section_title.dart';
import 'account_setup_logic.dart';

class AccountSetupPage extends StatelessWidget {
  final logic = Get.find<AccountSetupLogic>();

  AccountSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: StrRes.accountSetup,
      showBackButton: true,
      scrollable: true,
      bodyColor: const Color(0xFFF8F9FA),
      body: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Settings Section
            SectionTitle(title: StrRes.notificationSettings),
            SettingsMenuSection(
              items: [
                SettingsMenuItem(
                  icon: CupertinoIcons.bell_slash,
                  label: StrRes.notDisturbMode,
                  hasSwitch: true,
                  switchValue: logic.isGlobalNotDisturb,
                  onSwitchChanged: (_) => logic.toggleNotDisturbMode(),
                  showArrow: false,
                ),
                SettingsMenuItem(
                  icon: CupertinoIcons.music_note,
                  label: StrRes.allowRing,
                  hasSwitch: true,
                  switchValue: logic.isAllowBeep,
                  onSwitchChanged: (_) => logic.toggleBeep(),
                  showArrow: false,
                ),
                SettingsMenuItem(
                  icon: CupertinoIcons.device_phone_portrait,
                  label: StrRes.allowVibrate,
                  hasSwitch: true,
                  switchValue: logic.isAllowVibration,
                  onSwitchChanged: (_) => logic.toggleVibration(),
                  showDivider: false,
                  showArrow: false,
                ),
              ],
            ),

            20.verticalSpace,

            // Privacy Settings Section
            SectionTitle(title: StrRes.privacySettings),
            SettingsMenuSection(
              items: [
                SettingsMenuItem(
                  icon: CupertinoIcons.person_add,
                  label: StrRes.allowAddMeFried,
                  hasSwitch: true,
                  switchValue: logic.isAllowAddFriend,
                  onSwitchChanged: (_) => logic.toggleForbidAddMeToFriend(),
                  showArrow: false,
                ),
                SettingsMenuItem(
                  icon: CupertinoIcons.nosign,
                  label: StrRes.blacklist,
                  onTap: logic.blacklist,
                ),
                SettingsMenuItem(
                  icon: CupertinoIcons.globe,
                  label: StrRes.languageSetup,
                  value: logic.curLanguage.value,
                  onTap: logic.languageSetting,
                  showDivider: false,
                ),
              ],
            ),

            20.verticalSpace,

            // Security Settings Section
            SectionTitle(title: StrRes.securitySettings),
            SettingsMenuSection(
              items: [
                SettingsMenuItem(
                  icon: CupertinoIcons.lock,
                  label: StrRes.unlockSettings,
                  onTap: logic.unlockSetup,
                ),
                SettingsMenuItem(
                  icon: CupertinoIcons.lock_rotation,
                  label: StrRes.changePassword,
                  onTap: logic.changePwd,
                ),
                SettingsMenuItem(
                  icon: CupertinoIcons.person_crop_circle_badge_exclam,
                  label: StrRes.teenMode,
                  hasSwitch: true,
                  switchValue: logic.teenModeEnabled.value,
                  onSwitchChanged: (_) => logic.toggleTeenMode(),
                  showDivider: false,
                  showArrow: false,
                ),
              ],
            ),

            20.verticalSpace,

            // Danger Zone Section
            SectionTitle(
              title: StrRes.dangerZone,
              color: const Color(0xFFEF4444),
            ),
            SettingsMenuSection(
              items: [
                SettingsMenuItem(
                  icon: CupertinoIcons.trash,
                  label: StrRes.clearChatHistory,
                  onTap: logic.clearChatHistory,
                  isWarning: true,
                ),
                SettingsMenuItem(
                  icon: CupertinoIcons.person_badge_minus,
                  label: StrRes.deleteAccount,
                  onTap: logic.deleteAccount,
                  isWarning: true,
                  showDivider: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
