// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import '../../../widgets/custom_buttom.dart';
import 'group_setup_logic.dart';

class GroupSetupPage extends StatelessWidget {
  final logic = Get.find<GroupSetupLogic>();

  GroupSetupPage({super.key});

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

                      // Group Name
                      GestureDetector(
                        onTap: logic.isOwnerOrAdmin
                            ? () => logic.modifyGroupName(
                                logic.conversationInfo.value.faceURL)
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                logic.groupInfo.value.groupName ?? '',
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (logic.isOwnerOrAdmin) ...[
                              8.horizontalSpace,
                              Icon(
                                Icons.edit,
                                size: 16.sp,
                                color: const Color(0xFF6B7280),
                              ),
                            ],
                          ],
                        ),
                      ),
                      8.verticalSpace,
                      // Group ID
                      GestureDetector(
                        onTap: logic.copyGroupID,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              logic.groupInfo.value.groupID,
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

                      // Action Buttons Row (Search Content)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButtonWithCustomButtom(
                              context: context,
                              icon: CupertinoIcons.search,
                              label: StrRes.search,
                              onTap: logic.searchChatHistory,
                            ),
                            _buildActionButtonWithCustomButtom(
                              context: context,
                              icon: CupertinoIcons.photo,
                              label: StrRes.picture,
                              onTap: logic.searchChatHistoryPicture,
                            ),
                            _buildActionButtonWithCustomButtom(
                              context: context,
                              icon: CupertinoIcons.video_camera,
                              label: StrRes.video,
                              onTap: logic.searchChatHistoryVideo,
                            ),
                            _buildActionButtonWithCustomButtom(
                              context: context,
                              icon: CupertinoIcons.doc,
                              label: StrRes.file,
                              onTap: logic.searchChatHistoryFile,
                            ),
                          ],
                        ),
                      ),

                      24.verticalSpace,
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),

                      // Group Members Section
                      if (logic.isJoinedGroup.value) ...[
                        _buildSectionTitle(StrRes.groupMembers),
                        _buildGroupMembersGrid(),
                        24.verticalSpace,
                        const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      ],

                      // Menu Sections
                      _buildSectionTitle(StrRes.groupInformation),
                      _buildMenuItem(
                        icon: CupertinoIcons.qrcode,
                        label: StrRes.qrcode,
                        onTap: logic.viewGroupQrcode,
                      ),
                      _buildMenuItem(
                        icon: CupertinoIcons.bell,
                        label: StrRes.groupAc,
                        onTap: logic.editGroupAnnouncement,
                      ),
                      if (logic.showGroupManagement)
                        _buildMenuItem(
                          icon: CupertinoIcons.settings,
                          label: StrRes.groupManage,
                          onTap: logic.groupManage,
                        ),

                      _buildSectionTitle(StrRes.nicknameInGroup),
                      _buildMenuItem(
                        icon: CupertinoIcons.person,
                        label: StrRes.myGroupMemberNickname,
                        value: logic.myGroupMembersInfo.value.nickname,
                        onTap: logic.modifyMyGroupNickname,
                      ),

                      _buildSectionTitle(StrRes.chatSettings),
                      _buildToggleMenuItem(
                        label: StrRes.topChat,
                        isOn: logic.isPinned,
                        onChanged: (_) => logic.toggleTopChat(),
                      ),
                      _buildToggleMenuItem(
                        label: StrRes.messageNotDisturb,
                        isOn: logic.isNotDisturb,
                        onChanged: (_) => logic.toggleNotDisturb(),
                      ),

                      _buildSectionTitle(StrRes.actions),
                      _buildMenuItem(
                        icon: CupertinoIcons.flag,
                        label: StrRes.report,
                        onTap: logic.startReport,
                        textColor: Colors.amber,
                      ),
                      _buildMenuItem(
                        icon: CupertinoIcons.delete,
                        label: StrRes.clearChatHistory,
                        onTap: logic.clearChatHistory,
                        textColor: const Color(0xFFF87171),
                      ),
                      if (!logic.isOwner)
                        _buildMenuItem(
                          icon: CupertinoIcons.square_arrow_left,
                          label: logic.isJoinedGroup.value
                              ? StrRes.exitGroup
                              : StrRes.delete,
                          onTap: logic.quitGroup,
                          textColor: const Color(0xFFF87171),
                        ),
                      if (logic.isOwner)
                        _buildMenuItem(
                          icon: CupertinoIcons.xmark_circle,
                          label: StrRes.dismissGroup,
                          onTap: logic.quitGroup,
                          textColor: const Color(0xFFF87171),
                        ),

                      40.verticalSpace,
                    ],
                  )),
            ),

            // 3. Avatar (Overlapping)
            Positioned(
              top: 70.h,
              child: Obx(() => GestureDetector(
                    onTap:
                        logic.isOwnerOrAdmin ? logic.modifyGroupAvatar : null,
                    child: Container(
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
                        url: logic.groupInfo.value.faceURL,
                        text: logic.groupInfo.value.groupName,
                        width: 100.w,
                        height: 100.w,
                        textStyle:
                            TextStyle(fontSize: 32.sp, color: Colors.white),
                        isCircle: true,
                        isGroup: true,
                      ),
                    ),
                  )),
            ),

            // 4. Custom AppBar
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
        CustomButtom(
          onPressed: onTap,
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

  Widget _buildGroupMembersGrid() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logic.length(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              return logic.itemBuilder(
                index: index,
                builder: (info) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AvatarView(
                          width: 48.w,
                          height: 48.h,
                          url: info.faceURL,
                          text: info.nickname,
                          textStyle: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          isCircle: true,
                          onTap: () => logic.viewMemberInfo(info),
                        ),
                        if (logic.shouldShowOnlineIndicator(info) &&
                            logic.groupInfo.value.ownerUserID == info.userID)
                          Positioned(
                            bottom: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBBF24),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                StrRes.groupOwner,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 7.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                    4.verticalSpace,
                    Text(
                      info.nickname ?? '',
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                addButton: () => GestureDetector(
                  onTap: logic.addMember,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add,
                            color: const Color(0xFF6B7280), size: 24.w),
                      ),
                      4.verticalSpace,
                      Text(
                        StrRes.addMember,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                delButton: () => logic.isOwnerOrAdmin
                    ? GestureDetector(
                        onTap: logic.removeMember,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 48.w,
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.remove,
                                  color: const Color(0xFF6B7280), size: 24.w),
                            ),
                            4.verticalSpace,
                            Text(
                              StrRes.delMember,
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),
              );
            },
          ),
        ),
        if (logic.showMemberCount) ...[
          12.verticalSpace,
          GestureDetector(
            onTap: () => logic.viewGroupMembers(isShowEveryone: false),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  sprintf(StrRes.viewAllGroupMembers,
                      [logic.groupInfo.value.memberCount]),
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12.w,
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMenuItem({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
    String? value,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20.w,
                color: textColor ?? const Color(0xFF1F2937),
              ),
              12.horizontalSpace,
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? const Color(0xFF1F2937),
                ),
              ),
            ),
            if (value != null) ...[
              8.horizontalSpace,
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 150.w),
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            Icon(
              Icons.arrow_forward_ios,
              size: 14.w,
              color: const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleMenuItem({
    required String label,
    required bool isOn,
    required ValueChanged<bool> onChanged,
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
