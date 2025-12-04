// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../widgets/settings_menu.dart';
import '../../../widgets/section_title.dart';
import 'account_setup_logic.dart';

class AccountSetupPage extends StatelessWidget {
  final logic = Get.find<AccountSetupLogic>();

  AccountSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 1. Header Background
          Container(
            height: 180.h,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.8),
                  primaryColor,
                  primaryColor.withOpacity(0.95),
                ],
              ),
            ),
            child: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          color: Colors.transparent,
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20.w,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          StrRes.accountSetup,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontWeight: FontWeight.w700,
                            fontSize: 20.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 36.w), // Balance the back button
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Main Content
          Container(
            margin: EdgeInsets.only(top: 100.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: 24.h, bottom: 40.h),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification Settings Section
                    SectionTitle(title: StrRes.notificationSettings),
                    SettingsMenuSection(
                      items: [
                        _buildMenuItem(
                          icon: HugeIcons.strokeRoundedNotificationOff02,
                          label: StrRes.notDisturbMode,
                          hasSwitch: true,
                          switchValue: logic.isGlobalNotDisturb,
                          onSwitchChanged: (_) => logic.toggleNotDisturbMode(),
                        ),
                        _buildMenuItem(
                          icon: HugeIcons.strokeRoundedMusicNote01,
                          label: StrRes.allowRing,
                          hasSwitch: true,
                          switchValue: logic.isAllowBeep,
                          onSwitchChanged: (_) => logic.toggleBeep(),
                        ),
                        _buildMenuItem(
                          icon: HugeIcons.strokeRoundedSmartPhone01,
                          label: StrRes.allowVibrate,
                          hasSwitch: true,
                          switchValue: logic.isAllowVibration,
                          onSwitchChanged: (_) => logic.toggleVibration(),
                          showDivider: false,
                        ),
                      ],
                    ),

                    20.verticalSpace,

                    // Privacy Settings Section
                    SectionTitle(title: StrRes.privacySettings),
                    SettingsMenuSection(
                      items: [
                        _buildMenuItem(
                          icon: HugeIcons.strokeRoundedUserAdd01,
                          label: StrRes.allowAddMeFried,
                          hasSwitch: true,
                          switchValue: logic.isAllowAddFriend,
                          onSwitchChanged: (_) =>
                              logic.toggleForbidAddMeToFriend(),
                        ),
                        _buildMenuItem(
                          icon: HugeIcons.strokeRoundedUserBlock01,
                          label: StrRes.blacklist,
                          onTap: logic.blacklist,
                        ),
                        _buildMenuItem(
                          icon: HugeIcons.strokeRoundedGlobe02,
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
                        _buildMenuItem(
                          icon: HugeIcons.strokeRoundedLockPassword,
                          label: StrRes.unlockSettings,
                          onTap: logic.unlockSetup,
                        ),
                        _buildMenuItem(
                          icon: HugeIcons.strokeRoundedKeyframeAlignHorizontal,
                          label: StrRes.changePassword,
                          onTap: logic.changePwd,
                        ),
                        _buildMenuItem(
                          icon: HugeIcons.strokeRoundedKid,
                          label: StrRes.teenMode,
                          hasSwitch: true,
                          switchValue: logic.teenModeEnabled.value,
                          onSwitchChanged: (_) => logic.toggleTeenMode(),
                          showDivider: false,
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
                        _buildMenuItem(
                          icon: HugeIcons.strokeRoundedDelete02,
                          label: StrRes.clearChatHistory,
                          onTap: logic.clearChatHistory,
                          isWarning: true,
                        ),
                        _buildMenuItem(
                          icon: HugeIcons.strokeRoundedUserRemove01,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required dynamic icon,
    required String label,
    String? value,
    bool hasSwitch = false,
    bool? switchValue,
    Function(bool)? onSwitchChanged,
    VoidCallback? onTap,
    bool isWarning = false,
    bool showDivider = true,
  }) {
    return SettingsMenuItem(
      iconWidget: _buildIconContainer(icon, isWarning: isWarning),
      label: label,
      value: value,
      hasSwitch: hasSwitch,
      switchValue: switchValue,
      onSwitchChanged: onSwitchChanged,
      onTap: onTap,
      isWarning: isWarning,
      showDivider: showDivider,
      showArrow: !hasSwitch && onTap != null,
    );
  }

  Widget _buildIconContainer(dynamic icon, {bool isWarning = false}) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: isWarning
            ? const Color(0xFFEF4444).withOpacity(0.1)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Center(
        child: HugeIcon(
          icon: icon,
          size: 20.w,
          color: isWarning ? const Color(0xFFEF4444) : const Color(0xFF424242),
        ),
      ),
    );
  }
}

