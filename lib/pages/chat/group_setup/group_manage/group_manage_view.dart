// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim/widgets/gradient_scaffold.dart';

import 'group_manage_logic.dart';

class GroupManagePage extends StatelessWidget {
  final logic = Get.find<GroupManageLogic>();

  GroupManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: StrRes.groupManage,
      subtitle: StrRes.groupSettingsPrivacy,
      showBackButton: true,
      trailing: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.admin_panel_settings_outlined,
          color: Colors.white,
          size: 22.w,
        ),
      ),
      scrollable: true,
      body: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30.r),
        ),
        child: Container(
          color: const Color(0xFFF9FAFB),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 24.h),
            child: Obx(
              () => AnimationLimiter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 30.0,
                      curve: Curves.easeOutCubic,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      20.verticalSpace,

                      // Group Control Section
                      _buildSectionTitle(
                        StrRes.groupControl,
                        Icons.volume_off_outlined,
                        const Color(0xFFEF4444),
                      ),
                      8.verticalSpace,
                      _buildMenuSection([
                        _buildMenuItem(
                          icon: CupertinoIcons.bell_slash,
                          label: StrRes.muteAllMember,
                          hasSwitch: true,
                          switchValue: logic.groupInfo.value.status == 3,
                          onSwitchChanged: (_) => logic.toggleGroupMute(),
                          showDivider: false,
                        ),
                      ]),

                      20.verticalSpace,

                      // Member Settings Section
                      _buildSectionTitle(
                        StrRes.memberSettings,
                        Icons.people_outline_rounded,
                        const Color(0xFF3B82F6),
                      ),
                      8.verticalSpace,
                      _buildMenuSection([
                        _buildMenuItem(
                          icon: CupertinoIcons.nosign,
                          label: StrRes.notAllowSeeMemberProfile,
                          hasSwitch: true,
                          switchValue: logic.allowLookProfiles,
                          onSwitchChanged: (_) => logic.toggleMemberProfiles(),
                          showDivider: true,
                        ),
                        _buildMenuItem(
                          icon: CupertinoIcons.person_add,
                          label: StrRes.notAllAddMemberToBeFriend,
                          hasSwitch: true,
                          switchValue: logic.allowAddFriend,
                          onSwitchChanged: (_) =>
                              logic.toggleAddMemberToFriend(),
                          showDivider: true,
                        ),
                        _buildMenuItem(
                          icon: CupertinoIcons.gear,
                          label: StrRes.joinGroupSet,
                          value: logic.joinGroupOption,
                          onTap: logic.modifyJoinGroupSet,
                          showDivider: false,
                        ),
                      ]),

                      if (logic.isOwner) ...[
                        20.verticalSpace,

                        // Owner Settings Section
                        _buildSectionTitle(
                          StrRes.ownerSettings,
                          Icons.swap_horiz_rounded,
                          const Color(0xFFF59E0B),
                        ),
                        8.verticalSpace,
                        _buildMenuSection([
                          _buildMenuItem(
                            icon: CupertinoIcons.arrow_right_arrow_left,
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
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              size: 22.w,
              color: color,
            ),
          ),
          10.horizontalSpace,
          Text(
            title,
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(List<Widget> items) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
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
            borderRadius: !showDivider
                ? BorderRadius.vertical(bottom: Radius.circular(16.r))
                : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: isWarning
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 22.w,
                        color: isWarning
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: isWarning
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF374151),
                      ),
                    ),
                  ),

                  // Value or Switch or Arrow
                  if (hasSwitch && switchValue != null)
                    CupertinoSwitch(
                      value: switchValue,
                      onChanged: onSwitchChanged,
                      activeColor: const Color(0xFF4F46E5),
                    )
                  else if (value != null) ...[
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9CA3AF),
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    8.horizontalSpace,
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 16.w,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ] else if (onTap != null)
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 16.w,
                      color: const Color(0xFF9CA3AF),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(left: 64.w),
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
