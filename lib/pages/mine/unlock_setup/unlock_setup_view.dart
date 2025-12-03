import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hugeicons/hugeicons.dart';

import 'unlock_setup_logic.dart';
import '../../../widgets/base_page.dart';

class UnlockSetupPage extends StatelessWidget {
  final logic = Get.find<UnlockSetupLogic>();

  UnlockSetupPage({super.key});

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
            StrRes.unlockSettings,
            style: const TextStyle(
              fontFamily: 'FilsonPro',
              fontWeight: FontWeight.w500,
              fontSize: 23,
              color: Colors.black,
            ).copyWith(fontSize: 23.sp),
          ),
          Text(
            StrRes.securityAndPrivacy,
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
      child: AnimationLimiter(
        child: Column(
          children: [
            18.verticalSpace,
            AnimationConfiguration.staggeredList(
              position: 0,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                curve: Curves.easeOutCubic,
                verticalOffset: 40.0,
                child: FadeInAnimation(
                  child: _buildSecuritySection(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Obx(() {
      List<Widget> items = [];

      // Password item - always show
      items.add(_buildSecurityItem(
        label: StrRes.password,
        icon: HugeIcons.strokeRoundedLockPassword,
        iconColor: AppColor.iconColor,
        switchOn: logic.passwordEnabled.value,
        onChanged: (_) => logic.togglePwdLock(),
        isFirst: true,
        showDivider: logic.passwordEnabled.value &&
            (logic.isSupportedBiometric.value &&
                logic.canCheckBiometrics.value),
      ));

      // Biometrics item - only show if password is enabled and biometrics is supported
      if (logic.passwordEnabled.value &&
          (logic.isSupportedBiometric.value &&
              logic.canCheckBiometrics.value)) {
        items.add(_buildSecurityItem(
          label: StrRes.biometrics,
          icon: HugeIcons.strokeRoundedFingerPrint,
          iconColor: AppColor.iconColor,
          switchOn: logic.biometricsEnabled.value,
          onChanged: (_) => logic.toggleBiometricLock(),
          isLast: true,
          showDivider: false,
        ));
      }

      return _buildMenuSection(items);
    });
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

  Widget _buildSecurityItem({
    required String label,
    required List<List<dynamic>> icon,
    required Color iconColor,
    required bool switchOn,
    required ValueChanged<bool> onChanged,
    bool isFirst = false,
    bool isLast = false,
    bool showDivider = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SizedBox(
            height: 64.h,
            child: Row(
              children: [
                HugeIcon(
                  icon: icon,
                  color: iconColor,
                  size: 20.w,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ),
                CupertinoSwitch(
                  value: switchOn,
                  onChanged: onChanged,
                  activeColor: const Color(0xFF4F42FF),
                ),
              ],
            ),
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
