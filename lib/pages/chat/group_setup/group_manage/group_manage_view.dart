// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim/widgets/base_page.dart';

import 'group_manage_logic.dart';

class GroupManagePage extends StatelessWidget {
  final logic = Get.find<GroupManageLogic>();

  GroupManagePage({super.key});

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
            StrRes.groupManage,
            style: const TextStyle(
              fontFamily: 'FilsonPro',
              fontWeight: FontWeight.w500,
              fontSize: 23,
              color: Colors.black,
            ).copyWith(fontSize: 23.sp),
          ),
          Text(
            StrRes.groupSettingsPrivacy,
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

                  // Group Control Section
                  _buildSectionTitle(StrRes.groupControl),
                  _buildMenuSection([
                    _buildMenuItem(
                      icon: HugeIcons.strokeRoundedNotificationOff02,
                      label: StrRes.muteAllMember,
                      hasSwitch: true,
                      switchValue: logic.groupInfo.value.status == 3,
                      onSwitchChanged: (_) => logic.toggleGroupMute(),
                      showDivider: false,
                    ),
                  ]),

                  18.verticalSpace,

                  // Member Settings Section
                  _buildSectionTitle(StrRes.memberSettings),
                  _buildMenuSection([
                    _buildMenuItem(
                      icon: HugeIcons.strokeRoundedUserBlock01,
                      label: StrRes.notAllowSeeMemberProfile,
                      hasSwitch: true,
                      switchValue: logic.allowLookProfiles,
                      onSwitchChanged: (_) => logic.toggleMemberProfiles(),
                      showDivider: true,
                    ),
                    _buildMenuItem(
                      icon: HugeIcons.strokeRoundedUserAdd01,
                      label: StrRes.notAllAddMemberToBeFriend,
                      hasSwitch: true,
                      switchValue: logic.allowAddFriend,
                      onSwitchChanged: (_) => logic.toggleAddMemberToFriend(),
                      showDivider: true,
                    ),
                    _buildMenuItem(
                      icon: HugeIcons.strokeRoundedSettings02,
                      label: StrRes.joinGroupSet,
                      value: logic.joinGroupOption,
                      onTap: logic.modifyJoinGroupSet,
                      showDivider: false,
                    ),
                  ]),

                  if (logic.isOwner) ...[
                    18.verticalSpace,

                    // Owner Settings Section
                    _buildSectionTitle(StrRes.ownerSettings),
                    _buildMenuSection([
                      _buildMenuItem(
                        icon:
                            HugeIcons.strokeRoundedArrowDataTransferHorizontal,
                        label: StrRes.transferGroupOwnerRight,
                        onTap: logic.transferGroupOwnerRight,
                        isWarning: true,
                        showDivider: false,
                      ),
                    ]),
                  ],

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
          fontSize: 24.sp,
          fontWeight: FontWeight.w500,
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
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              value,
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          8.horizontalSpace,
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowRight01,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ],
                      ),
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
