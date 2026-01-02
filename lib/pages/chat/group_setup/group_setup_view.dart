// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';
import '../../../widgets/custom_buttom.dart';
import '../../../widgets/gradient_scaffold.dart';
import '../../../widgets/settings_menu.dart';
import '../../../widgets/section_title.dart';
import 'group_setup_logic.dart';

class GroupSetupPage extends StatelessWidget {
  final logic = Get.find<GroupSetupLogic>();

  GroupSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return GradientScaffold(
      title: StrRes.groupChatSetup,
      showBackButton: true,
      scrollable: false, // Disable full scroll
      trailing: CustomButton(
        color: Colors.white,
        icon: CupertinoIcons.qrcode,
        onTap: logic.viewGroupQrcode,
      ),
      avatar: _buildAvatar(),
      body: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ===== FIXED HEADER SECTION =====
              // Group Name
              GestureDetector(
                onTap: logic.isOwnerOrAdmin
                    ? () => logic
                        .modifyGroupName(logic.conversationInfo.value.faceURL)
                    : null,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
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
                    )),
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
                      color: primaryColor,
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
                    CustomButton(
                      icon: CupertinoIcons.search,
                      label: StrRes.search,
                      onTap: logic.searchChatHistory,
                      color: primaryColor,
                    ),
                    CustomButton(
                      icon: CupertinoIcons.photo,
                      label: StrRes.picture,
                      onTap: logic.searchChatHistoryPicture,
                      color: primaryColor,
                    ),
                    CustomButton(
                      icon: CupertinoIcons.play,
                      label: StrRes.video,
                      onTap: logic.searchChatHistoryVideo,
                      color: primaryColor,
                    ),
                    CustomButton(
                      icon: CupertinoIcons.doc,
                      label: StrRes.file,
                      onTap: logic.searchChatHistoryFile,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),

              24.verticalSpace,
              const Divider(height: 1, color: Color(0xFFF3F4F6)),

              // ===== SCROLLABLE SECTION =====
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Group Members Section
                      if (logic.isJoinedGroup.value) ...[
                        SectionTitle(title: StrRes.groupMembers),
                        _buildGroupMembersGrid(),
                        24.verticalSpace,
                        const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      ],

                      // Menu Sections
                      SectionTitle(title: StrRes.groupInformation),
                      SettingsMenuSection(
                        items: [
                          SettingsMenuItem(
                            icon: CupertinoIcons.bell,
                            label: StrRes.groupAc,
                            onTap: logic.editGroupAnnouncement,
                          ),
                          if (logic.isOwnerOrAdmin)
                            SettingsMenuItem(
                              icon: CupertinoIcons.person_2,
                              label: StrRes.onlineInfo,
                              onTap: logic.viewGroupOnlineInfo,
                            ),
                          if (logic.showGroupManagement)
                            SettingsMenuItem(
                              icon: CupertinoIcons.settings,
                              label: StrRes.groupManage,
                              onTap: logic.groupManage,
                              showDivider: false,
                            ),
                        ],
                      ),

                      SectionTitle(title: StrRes.nicknameInGroup),
                      SettingsMenuSection(
                        items: [
                          SettingsMenuItem(
                            icon: CupertinoIcons.person,
                            label: StrRes.myGroupMemberNickname,
                            value: logic.myGroupMembersInfo.value.nickname,
                            onTap: logic.modifyMyGroupNickname,
                            isRow: false,
                            showDivider: false,
                          ),
                        ],
                      ),

                      SectionTitle(title: StrRes.chatSettings),
                      SettingsMenuSection(
                        items: [
                          SettingsMenuItem(
                            label: StrRes.topChat,
                            hasSwitch: true,
                            switchValue: logic.isPinned,
                            onSwitchChanged: (_) => logic.toggleTopChat(),
                            showArrow: false,
                          ),
                          SettingsMenuItem(
                            label: StrRes.messageNotDisturb,
                            hasSwitch: true,
                            switchValue: logic.isNotDisturb,
                            onSwitchChanged: (_) => logic.toggleNotDisturb(),
                            showArrow: false,
                            showDivider: false,
                          ),
                        ],
                      ),

                      SectionTitle(title: StrRes.appearance),
                      SettingsMenuSection(
                        items: [
                          SettingsMenuItem(
                            icon: CupertinoIcons.textformat,
                            label: StrRes.fontSize,
                            onTap: logic.setFontSize,
                            showDivider: false,
                          ),
                        ],
                      ),

                      SectionTitle(title: StrRes.actions),
                      SettingsMenuSection(
                        items: [
                          SettingsMenuItem(
                            icon: CupertinoIcons.flag,
                            label: StrRes.report,
                            onTap: logic.startReport,
                            isWarning: true,
                          ),
                          SettingsMenuItem(
                            icon: CupertinoIcons.delete,
                            label: StrRes.clearChatHistory,
                            onTap: logic.clearChatHistory,
                            isDestroy: true,
                            showDivider: !(!logic.isOwner &&
                                logic.isJoinedGroup.value == false &&
                                !logic.isOwner),
                          ),
                          if (!logic.isOwner)
                            SettingsMenuItem(
                              icon: CupertinoIcons.square_arrow_left,
                              label: logic.isJoinedGroup.value
                                  ? StrRes.exitGroup
                                  : StrRes.delete,
                              onTap: logic.quitGroup,
                              isDestroy: true,
                              showDivider: false,
                            ),
                          if (logic.isOwner)
                            SettingsMenuItem(
                              icon: CupertinoIcons.xmark_circle,
                              label: StrRes.dismissGroup,
                              onTap: logic.quitGroup,
                              isDestroy: true,
                              showDivider: false,
                            ),
                        ],
                      ),

                      40.verticalSpace,
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildAvatar() {
    return Obx(() => ProfileHeaderAvatar(
          url: logic.groupInfo.value.faceURL,
          text: logic.groupInfo.value.groupName,
          onTap: logic.modifyGroupAvatar,
          isGroup: true,
          showEditIcon: logic.isOwnerOrAdmin,
          enabled: logic.isOwnerOrAdmin,
        ));
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
                          text: logic.getDisplayName(info),
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
                      logic.getDisplayName(info),
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
                      CustomButton(
                        color: Theme.of(context).primaryColor,
                        icon: CupertinoIcons.add,
                        iconSize: 26,
                      ),
                      6.verticalSpace,
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
                            CustomButton(
                              color: Colors.red,
                              icon: CupertinoIcons.minus,
                              iconSize: 26,
                            ),
                            6.verticalSpace,
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
}
