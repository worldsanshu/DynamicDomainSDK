// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim_common/openim_common.dart';

import 'friend_setup_logic.dart';
import '../../../../widgets/base_page.dart';

class FriendSetupPage extends StatelessWidget {
  final logic = Get.find<FriendSetupLogic>();

  FriendSetupPage({super.key});

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
            StrRes.friendSetup,
            style: const TextStyle(
              fontFamily: 'FilsonPro',
              fontWeight: FontWeight.w500,
              fontSize: 23,
              color: Colors.black,
            ).copyWith(fontSize: 23.sp),
          ),
          Text(
            StrRes.friendSettingsPrivacy,
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
        child: AnimationLimiter(
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
                _buildSectionTitle(StrRes.settings),
                _buildFriendSettingsSection(),
                18.verticalSpace,
                _buildSectionTitle(StrRes.privacySettings),
                _buildPrivacySection(),
                18.verticalSpace,
                _buildSectionTitle(StrRes.dangerZone),
                _buildDangerZoneSection(),
                24.verticalSpace,
              ],
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

  Widget _buildFriendSettingsSection() {
    return _buildSectionContainer(
      children: [
        _buildMenuItem(
          label: StrRes.setupRemark,
          icon: HugeIcons.strokeRoundedEdit02,
          iconColor: const Color(0xFF4F42FF),
          showRightArrow: true,
          onTap: logic.setFriendRemark,
        ),
        _buildDivider(),
        _buildMenuItem(
          label: StrRes.recommendToFriend,
          icon: HugeIcons.strokeRoundedUserAdd01,
          iconColor: const Color(0xFF34D399),
          showRightArrow: true,
          onTap: logic.recommendToFriend,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return _buildSectionContainer(
      children: [
        Obx(() => _buildMenuItem(
              label: StrRes.addToBlacklist,
              icon: HugeIcons.strokeRoundedUserBlock02,
              iconColor: const Color(0xFFFBBF24),
              showSwitchButton: true,
              switchOn:
                  logic.userProfilesLogic.userInfo.value.isBlacklist == true,
              onChanged: (_) => logic.toggleBlacklist(),
              isLast: true,
            )),
      ],
    );
  }

  Widget _buildDangerZoneSection() {
    return _buildSectionContainer(
      children: [
        _buildDeleteFriendButton(),
      ],
    );
  }

  Widget _buildSectionContainer({required List<Widget> children}) => Container(
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
        child: Column(children: children),
      );

  Widget _buildMenuItem({
    required String label,
    required dynamic icon, // Changed to dynamic to support HugeIcons
    required Color iconColor,
    bool showRightArrow = false,
    bool showSwitchButton = false,
    bool switchOn = false,
    bool isLast = false,
    ValueChanged<bool>? onChanged,
    Function()? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: isLast
                ? BorderRadius.only(
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  )
                : null,
          ),
          child: Row(
            children: [
              // Icon container
              HugeIcon(
                icon: icon,
                size: 20.w,
                color: AppColor.iconColor, //iconColor,
              ),

              16.horizontalSpace,

              // Label
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),

              // Right actions
              if (showRightArrow)
                HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  size: 20.w,
                  color: AppColor.iconColor,
                ),
              if (showSwitchButton)
                CupertinoSwitch(
                  value: switchOn,
                  onChanged: onChanged,
                  activeColor: const Color(0xFF4F42FF),
                  trackColor: const Color(0xFFE5E7EB),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteFriendButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: logic.deleteFromFriendList,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 42.w,
                height: 42.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF87171).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFFF87171).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  CupertinoIcons.person_badge_minus,
                  size: 20.w,
                  color: const Color(0xFFF87171),
                ),
              ),

              16.horizontalSpace,

              Expanded(
                child: Text(
                  StrRes.unfriend,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF87171),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.only(left: 72.w),
      child: const Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFF3F4F6),
      ),
    );
  }
}
