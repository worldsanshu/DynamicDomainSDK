// ignore_for_file: deprecated_member_use

import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../../widgets/custom_buttom.dart';
import '../../../widgets/gradient_scaffold.dart';
import '../../../widgets/settings_menu.dart';
import 'user_profile _panel_logic.dart';

class UserProfilePanelPage extends StatelessWidget {
  final logic = Get.find<UserProfilePanelLogic>(tag: GetTags.userProfile);

  UserProfilePanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: StrRes.profile,
      showBackButton: true,
      scrollable: true,
      avatar: _buildAvatar(),
      body: Obx(() => Column(
            children: [
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
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),

              24.verticalSpace,

              // Action Buttons Row
              if (!logic.isMyself && logic.isFriendship)
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
              if (logic.isGroupMemberPage&& !logic.isMyself ) ...[
                _buildSectionTitle(StrRes.groupInformation),
                _buildGroupInfoSection(),
              ],
              if (!logic.isMyself) ...[
                if (logic.isFriendship || logic.isBlacklist) ...[
                  _buildSectionTitle(StrRes.actions),
                ],
                _buildActionsSection(),
              ],

              40.verticalSpace,
            ],
          )),
    );
  }

  Widget _buildAvatar() {
    return Obx(() => Container(
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
            textStyle: TextStyle(fontSize: 32.sp, color: Colors.white),
            isCircle: true,
            enabledPreview: true,
          ),
        ));
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
          color: primaryColor,
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
    return Obx(() {
      final isPending = logic.hasPendingFriendRequest.value;
      return GestureDetector(
        onTap: isPending ? null : logic.addFriend,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isPending
                ? const Color(0xFFD1D5DB)
                : primaryColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: (isPending
                        ? const Color(0xFFD1D5DB)
                        : primaryColor)
                    .withOpacity(0.3),
                offset: const Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPending
                    ? CupertinoIcons.clock
                    : CupertinoIcons.person_add,
                color: Colors.white,
                size: 20.w,
              ),
              8.horizontalSpace,
              Text(
                isPending ? StrRes.requested : StrRes.add,
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
    });
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
          _buildMenuItem(
            icon: CupertinoIcons.shield,
            iconColor: const Color(0xFF3B82F6),
            label: StrRes.setAsAdmin,
            onTap: logic.toggleAdmin,
          ),
        if (logic.iHasMutePermissions.value && logic.groupMembersInfo != null)
          _buildMenuItem(
            icon: CupertinoIcons.mic_slash,
            iconColor: const Color(0xFFF87171),
            label: StrRes.setMute,
            value: IMUtils.emptyStrToNull(logic.mutedTime.value),
            onTap: logic.setMute,
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
          ),
        if ((!logic.isMyself && logic.isFriendship) || logic.isBlacklist)
          SettingsMenuItem(
            icon: CupertinoIcons.hand_raised,
            color: const Color(0xFFB98610),
            label: StrRes.addToBlacklist,
            onSwitchChanged: (_) => logic.toggleBlacklist(),
            switchValue: logic.isBlacklist,
            hasSwitch: true,
            showArrow: false,
            showDivider: false,
            isRow: true,
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
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: SettingsMenuSection(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        items: children,
      ),
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
      SettingsMenuItem(
        icon: icon,
        label: label,
        value: value,
        onTap: onTap,
        showArrow: onTap != null,
        showDivider: !isLast,
        color: iconColor,
        isRow: true,
      );

  Widget _buildDeleteFriendMenuItem() => SettingsMenuItem(
        icon: CupertinoIcons.person_badge_minus,
        label: StrRes.unfriend,
        onTap: logic.deleteFromFriendList,
        showArrow: true,
        showDivider: false,
        color: const Color(0xFFF87171),
        isWarning: true,
        isRow: true,
      );
}
