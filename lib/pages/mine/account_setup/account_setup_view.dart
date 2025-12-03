import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../widgets/base_page.dart';
import 'account_setup_logic.dart';

class AccountSetupPage extends StatelessWidget {
  final logic = Get.find<AccountSetupLogic>();

  AccountSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      centerTitle: false,
      showLeading: true,
      customAppBar: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StrRes.accountSetup,
            style: const TextStyle(
              fontFamily: 'FilsonPro',
              fontWeight: FontWeight.w500,
              fontSize: 23,
              color: Colors.black,
            ).copyWith(fontSize: 23.sp),
          ),
          Text(
            StrRes.settingsAndPrivacy,
            style: const TextStyle(
              fontFamily: 'FilsonPro',
              fontWeight: FontWeight.w400,
              color: Color(0xFFBDBDBD),
            ).copyWith(fontSize: 12.sp),
          ),
        ],
      ),
      body: _buildContentContainer(),
    );
  }

  Widget _buildContentContainer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 20.h),
        child: Obx(
          () => AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 450),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  curve: Curves.easeOutQuart,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  20.verticalSpace,

                  // Notification Settings Section
                  _buildSectionTitle(StrRes.notificationSettings),
                  _buildMenuSection([
                    _buildMenuItem(
                      icon: HugeIcons.strokeRoundedNotificationOff02,
                      label: StrRes.notDisturbMode,
                      hasSwitch: true,
                      switchValue: logic.isGlobalNotDisturb,
                      onSwitchChanged: (_) => logic.toggleNotDisturbMode(),
                      showDivider: true,
                    ),
                    _buildMenuItem(
                      icon: HugeIcons.strokeRoundedMusicNote01,
                      label: StrRes.allowRing,
                      hasSwitch: true,
                      switchValue: logic.isAllowBeep,
                      onSwitchChanged: (_) => logic.toggleBeep(),
                      showDivider: true,
                    ),
                    _buildMenuItem(
                      icon: HugeIcons.strokeRoundedSmartPhone01,
                      label: StrRes.allowVibrate,
                      hasSwitch: true,
                      switchValue: logic.isAllowVibration,
                      onSwitchChanged: (_) => logic.toggleVibration(),
                      showDivider: false,
                    ),
                  ]),

                  18.verticalSpace,

                  // Privacy Settings Section
                  _buildSectionTitle(StrRes.privacySettings),
                  _buildMenuSection([
                    _buildMenuItem(
                      icon: HugeIcons.strokeRoundedUserAdd01,
                      label: StrRes.allowAddMeFried,
                      hasSwitch: true,
                      switchValue: logic.isAllowAddFriend,
                      onSwitchChanged: (_) => logic.toggleForbidAddMeToFriend(),
                      showDivider: true,
                    ),
                    _buildMenuItem(
                      icon: HugeIcons.strokeRoundedUserBlock01,
                      label: StrRes.blacklist,
                      onTap: logic.blacklist,
                      showDivider: true,
                    ),
                    Obx(() => _buildMenuItem(
                          icon: HugeIcons.strokeRoundedGlobe02,
                          label: StrRes.languageSetup,
                          value: logic.curLanguage.value,
                          onTap: logic.languageSetting,
                          showDivider: false,
                        )),
                  ]),

                  18.verticalSpace,

                  // Security Settings Section
                  _buildSectionTitle(StrRes.securitySettings),
                  _buildMenuSection([
                    _buildMenuItem(
                      icon: HugeIcons.strokeRoundedLockPassword,
                      label: StrRes.unlockSettings,
                      onTap: logic.unlockSetup,
                      showDivider: true,
                    ),
                    _buildMenuItem(
                      icon: HugeIcons.strokeRoundedKeyframeAlignHorizontal,
                      label: StrRes.changePassword,
                      onTap: logic.changePwd,
                      showDivider: true,
                    ),
                    _buildMenuItem(
                      icon: HugeIcons.strokeRoundedKid,
                      label: StrRes.teenMode,
                      hasSwitch: true,
                      switchValue: logic.teenModeEnabled.value,
                      onSwitchChanged: (_) => logic.toggleTeenMode(),
                      showDivider: false,
                    ),
                  ]),

                  18.verticalSpace,

                  // Danger Zone Section
                  _buildSectionTitle(StrRes.dangerZone),
                  _buildMenuSection([
                    _buildMenuItem(
                      icon: HugeIcons.strokeRoundedDelete02,
                      label: StrRes.clearChatHistory,
                      onTap: logic.clearChatHistory,
                      isWarning: true,
                      showDivider: true,
                    ),
                    _buildMenuItem(
                      icon: HugeIcons.strokeRoundedUserRemove01,
                      label: StrRes.deleteAccount,
                      onTap: logic.deleteAccount,
                      isWarning: true,
                      showDivider: false,
                    ),
                  ]),

                  24.verticalSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'FilsonPro',
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF212121),
          shadows: [
            Shadow(
              color: Colors.white.withOpacity(0.9),
              offset: const Offset(0.5, 0.5),
              blurRadius: 0.5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(List<Widget> items) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.06),
            offset: const Offset(0, 2),
            blurRadius: 6.r,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF3F4F6),
          width: 1,
        ),
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildMenuItem({
    required List<List<dynamic>> icon,
    required String label,
    String? value,
    bool hasSwitch = false,
    bool? switchValue,
    Function(bool)? onSwitchChanged,
    VoidCallback? onTap,
    bool isWarning = false,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  HugeIcon(
                    icon: icon,
                    size: 20.w,
                    color: isWarning
                        ? const Color(0xFFF87171)
                        : const Color(0xFF424242),
                  ),
                  16.horizontalSpace,
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: isWarning
                            ? const Color(0xFFF87171)
                            : const Color(0xFF374151),
                      ),
                    ),
                  ),

                  // Value or Switch or Arrow
                  if (hasSwitch && switchValue != null)
                    CupertinoSwitch(
                      value: switchValue,
                      onChanged: onSwitchChanged,
                      activeColor: const Color(0xFF4F42FF),
                    )
                  else if (value != null)
                    Row(
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        8.horizontalSpace,
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ],
                    )
                  else if (onTap != null)
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(left: 70.w),
            child: const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF3F4F6),
            ),
          ),
      ],
    );
  }
}
