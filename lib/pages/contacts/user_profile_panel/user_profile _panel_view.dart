import 'dart:ui';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim/widgets/base_page.dart';
import 'package:openim_common/openim_common.dart';

import '../../../widgets/custom_buttom.dart';
import 'user_profile _panel_logic.dart';

class UserProfilePanelPage extends StatelessWidget {
  final logic = Get.find<UserProfilePanelLogic>(tag: GetTags.userProfile);

  UserProfilePanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BasePage(
        showAppBar: true,
        centerTitle: false,
        showLeading: true,
        customAppBar: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StrRes.profile,
              style: const TextStyle(
                fontFamily: 'FilsonPro',
                fontWeight: FontWeight.w500,
                fontSize: 23,
                color: Colors.black,
              ).copyWith(fontSize: 23.sp),
            ),
          ],
        ),
        actions: [
          if (logic.isFriendship)
            CustomButtom(
              margin: const EdgeInsets.only(right: 10),
              onPressed: logic.friendSetup,
              icon: CupertinoIcons.ellipsis,
              colorButton: const Color(0xFF4F42FF).withOpacity(0.1),
              colorIcon: const Color(0xFF4F42FF),
            ),
        ],
        body: _buildContentContainer(),
      ),
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
                _buildProfileCard(),
                // if (logic.isGroupMemberPage) ...[
                //   _buildSectionTitle(StrRes.groupInformation),
                //   _buildGroupInfoSection(),
                //   18.verticalSpace,
                // ],
                if (!logic.isMyself) ...[
                  _buildSectionTitle(StrRes.actions),
                  _buildActionsSection(),
                  18.verticalSpace,
                ],
                if ((logic.isFriendship || logic.allowSendMsgNotFriend) &&
                    !logic.isMyself) ...[
                  _buildSectionTitle(StrRes.quickActions),
                  _buildQuickActionsSection(),
                ],
                24.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() => Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(-1, -1),
              blurRadius: 4,
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 1.5,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              const Color(0xFFF8FAFC),
            ],
            stops: const [0.05, 0.3],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar với style MinePage
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1.5.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9CA3AF).withOpacity(0.1),
                          blurRadius: 8.r,
                        ),
                      ],
                    ),
                    child: AvatarView(
                      url: logic.userInfo.value.faceURL,
                      text: logic.getShowName(),
                      width: 68.w,
                      height: 68.h,
                      textStyle: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      isCircle: true,
                      enabledPreview: true,
                    ),
                  ),
                  16.horizontalSpace,
                  // Profile info
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nickname
                              Text(
                                logic.getShowName(),
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF374151),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              5.verticalSpace,
                              // User ID với copy function
                              if (!logic.isGroupMemberPage ||
                                  logic.isGroupMemberPage &&
                                      !logic.notAllowAddGroupMemberFriend.value)
                                GestureDetector(
                                  onTap: logic.copyID,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 0.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${StrRes.userIdLabel}${logic.userInfo.value.userID ?? ''}',
                                          style: TextStyle(
                                            fontFamily: 'FilsonPro',
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF6B7280),
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        4.horizontalSpace,
                                        Icon(
                                          CupertinoIcons.doc_on_doc,
                                          size: 14.w,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Add friend button hoặc action icon
                        if (!logic.isMyself &&
                            logic.isAllowAddFriend &&
                            !logic.isFriendship &&
                            (!logic.isGroupMemberPage ||
                                logic.isGroupMemberPage &&
                                    !logic
                                        .notAllowAddGroupMemberFriend.value) &&
                            !logic.isBlacklist)
                          _buildAddFriendButton()
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildAddFriendButton() => GestureDetector(
        onTap: logic.addFriend,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.25),
                offset: const Offset(0, 2),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.person_add,
                size: 14.w,
                color: Colors.white,
              ),
              6.horizontalSpace,
              Text(
                StrRes.add,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildSectionTitle(String title) => Padding(
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

  Widget _buildGroupInfoSection() => _buildMenuSection([
        if (logic.showJoinGroupTime)
          _buildMenuItem(
            icon: CupertinoIcons.calendar,
            iconColor: const Color(0xFF10B981),
            label: StrRes.joinGroupDate,
            value: DateUtil.formatDateMs(
              logic.joinGroupTime.value,
              format: DateFormats.zh_y_mo_d,
            ),
            isLast: !logic.showJoinGroupMethod,
          ),
        if (logic.showJoinGroupMethod)
          _buildMenuItem(
            icon: CupertinoIcons.arrow_right_square,
            iconColor: const Color(0xFF3B82F6),
            label: StrRes.joinGroupMethod,
            value: logic.joinGroupMethod.value,
            isLast: true,
          ),
      ]);

  Widget _buildActionsSection() => _buildMenuSection([
        if (logic.iAmOwner.value && logic.groupMembersInfo != null)
          _buildToggleMenuItem(
            icon: CupertinoIcons.shield,
            iconColor: const Color(0xFF3B82F6),
            label: StrRes.setAsAdmin,
            isOn: logic.hasAdminPermission.value,
            onChanged: (_) => logic.toggleAdmin(),
            isLast: !(logic.iHasMutePermissions.value ||
                logic.isFriendship ||
                logic.isMyself ||
                logic.isGroupMemberPage &&
                    !logic.notAllowLookGroupMemberProfiles.value),
          ),
        if (logic.iHasMutePermissions.value && logic.groupMembersInfo != null)
          _buildMenuItem(
            icon: CupertinoIcons.mic_slash,
            iconColor: const Color(0xFFF87171),
            label: StrRes.setMute,
            value: IMUtils.emptyStrToNull(logic.mutedTime.value),
            onTap: logic.setMute,
            isLast: !(logic.isFriendship ||
                logic.isMyself ||
                logic.isGroupMemberPage &&
                    !logic.notAllowLookGroupMemberProfiles.value),
          ),
        if (logic.isFriendship ||
            logic.isMyself ||
            logic.isGroupMemberPage &&
                !logic.notAllowLookGroupMemberProfiles.value)
          _buildMenuItem(
            icon: CupertinoIcons.person,
            iconColor: const Color(0xFF10B981),
            label: StrRes.personalInfo,
            onTap: logic.viewPersonalInfo,
            isLast: true,
          ),
      ]);

  Widget _buildQuickActionsSection() => _buildMenuSection([
        _buildMenuItem(
          icon: CupertinoIcons.chat_bubble,
          iconColor: const Color(0xFF3B82F6),
          label: StrRes.sendMessage,
          onTap: logic.toChat,
          isLast: !logic.showAudioAndVideoCall,
        ),
        if (logic.showAudioAndVideoCall)
          _buildMenuItem(
            icon: CupertinoIcons.phone,
            iconColor: const Color(0xFF10B981),
            label: StrRes.audioAndVideoCall,
            onTap: logic.toCall,
            isLast: true,
          ),
      ]);

  Widget _buildMenuSection(List<Widget> children) => Container(
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
}

Widget _buildMenuItem({
  required IconData icon,
  required Color iconColor,
  required String label,
  String? value,
  VoidCallback? onTap,
  bool isLast = false,
}) =>
    Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  _buildIconContainer(icon: icon, color: iconColor),
                  16.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF374151),
                          ),
                        ),
                        if (value != null) ...[
                          4.verticalSpace,
                          Text(
                            value,
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      CupertinoIcons.right_chevron,
                      size: 16.w,
                      color: const Color(0xFF9CA3AF),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
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

Widget _buildToggleMenuItem({
  required IconData icon,
  required Color iconColor,
  required String label,
  required bool isOn,
  required ValueChanged<bool> onChanged,
  bool isLast = false,
}) =>
    Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(!isOn),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  _buildIconContainer(icon: icon, color: iconColor),
                  16.horizontalSpace,
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
                  _buildToggleSwitch(isOn: isOn, onChanged: onChanged),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
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

Widget _buildIconContainer({
  required IconData icon,
  required Color color,
}) =>
    Icon(
      icon,
      size: 20.w,
      color: AppColor.iconColor, //color,
    );

Widget _buildToggleSwitch({
  required bool isOn,
  required ValueChanged<bool> onChanged,
}) =>
    GestureDetector(
      onTap: () => onChanged(!isOn),
      child: Container(
        width: 52.w,
        height: 30.h,
        decoration: BoxDecoration(
          color: isOn ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64748B).withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: AnimatedAlign(
          alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: Container(
            width: 26.w,
            height: 26.h,
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF64748B).withOpacity(0.15),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
