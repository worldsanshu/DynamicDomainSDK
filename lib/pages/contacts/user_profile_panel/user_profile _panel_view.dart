// ignore_for_file: deprecated_member_use

import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../../widgets/custom_buttom.dart';
import 'user_profile _panel_logic.dart';

class UserProfilePanelPage extends StatelessWidget {
  final logic = Get.find<UserProfilePanelLogic>(tag: GetTags.userProfile);

  UserProfilePanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Stack(
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
                    primaryColor.withOpacity(0.7),
                    primaryColor,
                    primaryColor.withOpacity(0.9),
                  ],
                ),
              ),
            ),

            // 2. Main Content Card
            Container(
              margin: EdgeInsets.only(top: 120.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Obx(() => Column(
                    children: [
                      SizedBox(height: 60.h), // Space for avatar

                      // User Info
                      Text(
                        logic.getShowName(),
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      8.verticalSpace,
                      if (!logic.isGroupMemberPage ||
                          logic.isGroupMemberPage &&
                              !logic.notAllowAddGroupMemberFriend.value)
                        GestureDetector(
                          onTap: logic.copyID,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                logic.userInfo.value.userID ?? '',
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              6.horizontalSpace,
                              Icon(
                                CupertinoIcons.doc_on_doc,
                                size: 14.sp,
                                color: const Color(0xFF6B7280),
                              ),
                            ],
                          ),
                        ),

                      24.verticalSpace,

                      // Action Buttons Row
                      if (!logic.isMyself)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (logic.showAudioAndVideoCall) ...[
                                _buildActionButtonWithCustomButtom(
                                  context: context,
                                  icon: CupertinoIcons.phone,
                                  label: StrRes.audioCall,
                                  onTap: () => logic.trtcLogic
                                      .callAudio(logic.userInfo.value.userID!),
                                ),
                                _buildActionButtonWithCustomButtom(
                                  context: context,
                                  icon: CupertinoIcons.videocam,
                                  label: StrRes.videoCall,
                                  onTap: () => logic.trtcLogic
                                      .callVideo(logic.userInfo.value.userID!),
                                ),
                              ],
                              _buildActionButtonWithCustomButtom(
                                context: context,
                                icon: CupertinoIcons.chat_bubble,
                                label: StrRes.sendMessage,
                                onTap: logic.toChat,
                              ),
                            ],
                          ),
                        ),

                      if (!logic.isMyself &&
                          logic.isAllowAddFriend &&
                          !logic.isFriendship &&
                          (!logic.isGroupMemberPage ||
                              logic.isGroupMemberPage &&
                                  !logic.notAllowAddGroupMemberFriend.value) &&
                          !logic.isBlacklist) ...[
                        24.verticalSpace,
                        _buildAddFriendButton(context),
                      ],

                      24.verticalSpace,
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),

                      // Menu List
                      if (logic.isGroupMemberPage) ...[
                        _buildSectionTitle(StrRes.groupInformation),
                        _buildGroupInfoSection(),
                      ],
                      if (!logic.isMyself) ...[
                        _buildSectionTitle(StrRes.actions),
                        _buildActionsSection(),
                      ],

                      40.verticalSpace,
                    ],
                  )),
            ),

            // 3. Avatar (Overlapping)
            Positioned(
              top: 70.h,
              child: Obx(() => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: AvatarView(
                      url: logic.userInfo.value.faceURL,
                      text: logic.getShowName(),
                      width: 100.w,
                      height: 100.w,
                      textStyle:
                          TextStyle(fontSize: 32.sp, color: Colors.white),
                      isCircle: true,
                      enabledPreview: true,
                    ),
                  )),
            ),

            // 4. Custom AppBar (Back Button & Actions)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                actions: []
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonWithCustomButtom({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      children: [
        CustomButton(
          onTap: onTap,
          icon: icon,
          colorButton: primaryColor.withOpacity(0.15),
          colorIcon: primaryColor,
          padding: EdgeInsets.all(16.w),
        ),
        8.verticalSpace,
        Text(
          label,
          style: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildAddFriendButton(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: logic.addFriend,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.person_add, color: Colors.white, size: 20.w),
            8.horizontalSpace,
            Text(
              StrRes.add,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 24.w, top: 24.h, bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'FilsonPro',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF9CA3AF),
        ),
      ),
    );
  }

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
            isLast: false,
          ),
        if (logic.iHasMutePermissions.value && logic.groupMembersInfo != null)
          _buildMenuItem(
            icon: CupertinoIcons.mic_slash,
            iconColor: const Color(0xFFF87171),
            label: StrRes.setMute,
            value: IMUtils.emptyStrToNull(logic.mutedTime.value),
            onTap: logic.setMute,
            isLast: false,
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
            isLast: false,
          ),
          _buildToggleMenuItem(
            icon: CupertinoIcons.nosign,
            iconColor: const Color(0xFFFBBF24),
            label: StrRes.addToBlacklist,
            isOn: logic.userInfo.value.isBlacklist == true,
            onChanged: (_) => logic.toggleBlacklist(),
            isLast: false,
          ),
        // Friend Setup features
        if (logic.isFriendship) ...[
          _buildMenuItem(
            icon: CupertinoIcons.pencil,
            iconColor: const Color(0xFF4F42FF),
            label: StrRes.setupRemark,
            onTap: logic.setFriendRemark,
            isLast: false,
          ),
          _buildMenuItem(
            icon: CupertinoIcons.person_add,
            iconColor: const Color(0xFF34D399),
            label: StrRes.recommendToFriend,
            onTap: logic.recommendToFriend,
            isLast: false,
          ),
          _buildDeleteFriendMenuItem(),
        ],
      ]);

  Widget _buildMenuSection(List<Widget> children) {
    if (children.isEmpty) return const SizedBox();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
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
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Row(
            children: [
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
                        color: const Color(0xFF1F2937),
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
                  Icons.arrow_forward_ios,
                  size: 14.w,
                  color: const Color(0xFF9CA3AF),
                ),
            ],
          ),
        ),
      );

  Widget _buildToggleMenuItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool isOn,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) =>
      InkWell(
        onTap: () => onChanged(!isOn),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              _buildToggleSwitch(isOn: isOn, onChanged: onChanged),
            ],
          ),
        ),
      );

  Widget _buildDeleteFriendMenuItem() => InkWell(
        onTap: logic.deleteFromFriendList,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.person_badge_minus,
                size: 20.w,
                color: const Color(0xFFF87171),
              ),
              16.horizontalSpace,
              Expanded(
                child: Text(
                  StrRes.unfriend,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFF87171),
                  ),
                ),
              ),
            ],
          ),
        ),
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
}
