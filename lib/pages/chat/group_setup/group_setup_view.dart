import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hugeicons/hugeicons.dart';

import 'group_setup_logic.dart';
import '../../../widgets/base_page.dart';

class GroupSetupPage extends StatelessWidget {
  final logic = Get.find<GroupSetupLogic>();

  GroupSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      title: StrRes.groupChatSetup,
      centerTitle: false,
      showLeading: true,
      body: Obx(() => Column(
            children: [
              // Content Container
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9CA3AF).withOpacity(0.08),
                        offset: const Offset(0, 0),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: AnimationLimiter(
                    child: SingleChildScrollView(
                      child: Column(
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 400),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            verticalOffset: 40.0,
                            curve: Curves.easeOutCubic,
                            child: FadeInAnimation(
                              curve: Curves.easeOutCubic,
                              child: widget,
                            ),
                          ),
                          children: [
                            20.verticalSpace,

                            // Member View
                            if (logic.isJoinedGroup.value) _buildMemberView(),

                            if (logic.isJoinedGroup.value) 18.verticalSpace,

                            // Profile Card
                            if (logic.isJoinedGroup.value) _buildProfileCard(),

                            18.verticalSpace,

                            // Content Search Section
                            _buildContentSearchSection(),

                            18.verticalSpace,

                            // Group Info Section
                            _buildGroupInfoSection(),

                            18.verticalSpace,

                            // Member Settings Section
                            _buildMemberSettingsSection(),

                            18.verticalSpace,

                            // Chat Settings Section
                            _buildChatSettingsSection(),

                            18.verticalSpace,

                            // Actions Section
                            _buildActionsSection(),

                            24.verticalSpace,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF9FAFB),
            Color(0xFFF3F4F6),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.07),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34.r),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.1),
                  offset: const Offset(0, 0),
                  blurRadius: 8,
                ),
              ],
            ),
            child: AvatarView(
              width: 68.w,
              height: 68.h,
              url: logic.groupInfo.value.faceURL,
              file: logic.avatar.value,
              text: logic.groupInfo.value.groupName,
              textStyle: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              isGroup: true,
              isCircle: true,
              onTap: logic.isOwnerOrAdmin ? logic.modifyGroupAvatar : null,
            ),
          ),

          16.horizontalSpace,

          // Group Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: logic.isOwnerOrAdmin
                      ? () => logic
                          .modifyGroupName(logic.conversationInfo.value.faceURL)
                      : null,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          logic.groupInfo.value.groupName ?? '',
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (logic.isOwnerOrAdmin) ...[
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedEdit02,
                          size: 16.w,
                          color: const Color(0xFF6B7280),
                        ),
                        15.horizontalSpace,
                      ],
                    ],
                  ),
                ),
                6.verticalSpace,
                Row(
                  children: [
                    Text(
                      '${StrRes.idLabel} ${logic.groupInfo.value.groupID}',
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    4.horizontalSpace,
                    GestureDetector(
                      onTap: logic.copyGroupID,
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedCopy01,
                        size: 14.w,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                if (logic.showMemberCount) ...[
                  4.verticalSpace,
                  Text(
                    '${logic.groupInfo.value.memberCount ?? 0} ${StrRes.members}',
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // QR Code button
          GestureDetector(
            onTap: logic.viewGroupQrcode,
            child: Container(
              width: 30.w,
              height: 30.h,
              decoration: BoxDecoration(
                color: const Color(0xFF4F42FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: const HugeIcon(
                icon: HugeIcons.strokeRoundedQrCode01,
                color: AppColor.iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberView() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.06),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF3F4F6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Text(
              StrRes.groupMembers,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
                letterSpacing: 0.3,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logic.length(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 6.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.75,
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
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24.r),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF9CA3AF)
                                            .withOpacity(0.1),
                                        offset: const Offset(0, 0),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: AvatarView(
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
                                ),
                                // Group owner indicator (only show if member is online)
                                if (logic.shouldShowOnlineIndicator(info) &&
                                    logic.groupInfo.value.ownerUserID ==
                                        info.userID)
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4.w, vertical: 1.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFBBF24),
                                        borderRadius:
                                            BorderRadius.circular(6.r),
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
                            Expanded(
                              child: Container(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  info.nickname ?? '',
                                  style: TextStyle(
                                    fontFamily: 'FilsonPro',
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF6B7280),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
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
                                  color:
                                      const Color(0xFF34D399).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(24.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF9CA3AF)
                                          .withOpacity(0.06),
                                      offset: const Offset(0, 2),
                                      blurRadius: 6,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: const Color(0xFFF3F4F6),
                                    width: 1,
                                  ),
                                ),
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedAdd01,
                                  size: 24.w,
                                  color: const Color(0xFF34D399),
                                ),
                              ),
                              4.verticalSpace,
                              Expanded(
                                child: Container(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    StrRes.addMember,
                                    style: TextStyle(
                                      fontFamily: 'FilsonPro',
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF6B7280),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
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
                                    color: const Color(0xFFF87171)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(24.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF9CA3AF)
                                            .withOpacity(0.06),
                                        offset: const Offset(0, 2),
                                        blurRadius: 6,
                                      ),
                                    ],
                                    border: Border.all(
                                      color: const Color(0xFFF3F4F6),
                                      width: 1,
                                    ),
                                  ),
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedRemove01,
                                    size: 24.w,
                                    color: const Color(0xFFF87171),
                                  ),
                                ),
                                4.verticalSpace,
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      StrRes.delMember,
                                      style: TextStyle(
                                        fontFamily: 'FilsonPro',
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF6B7280),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox());
              },
            ),
          ),
          if (logic.showMemberCount) ...[
            Divider(
              height: 1,
              thickness: 1,
              color: const Color(0xFFF3F4F6),
              indent: 20.w,
              endIndent: 20.w,
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => logic.viewGroupMembers(isShowEveryone: false),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  children: [
                    Text(
                      sprintf(StrRes.viewAllGroupMembers,
                          [logic.groupInfo.value.memberCount]),
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    const Spacer(),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      size: 20.w,
                      color: const Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContentSearchSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFFFFFFF),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.08),
            offset: const Offset(0, 3),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF0F4F8),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Text(
              StrRes.chatContent,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF374151),
                letterSpacing: 0.3,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 0.5),
                    blurRadius: 1,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              bottom: 20.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildContentSearchItem(
                  hugeIcon: HugeIcons.strokeRoundedSearch01,
                  text: StrRes.search,
                  color: const Color(0xFF4F42FF),
                  onTap: logic.searchChatHistory,
                ),
                _buildContentSearchItem(
                  hugeIcon: HugeIcons.strokeRoundedImage02,
                  text: StrRes.picture,
                  color: const Color(0xFF34D399),
                  onTap: logic.searchChatHistoryPicture,
                ),
                _buildContentSearchItem(
                  hugeIcon: HugeIcons.strokeRoundedVideoReplay,
                  text: StrRes.video,
                  color: const Color(0xFFF87171),
                  onTap: logic.searchChatHistoryVideo,
                ),
                _buildContentSearchItem(
                  hugeIcon: HugeIcons.strokeRoundedFile02,
                  text: StrRes.file,
                  color: const Color(0xFFFBBF24),
                  onTap: logic.searchChatHistoryFile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSearchItem({
    required List<List<dynamic>> hugeIcon,
    required String text,
    required Color color,
    Function()? onTap,
  }) {
    color = AppColor.iconColor;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.08),
                  offset: const Offset(0, 3),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.95),
                  offset: const Offset(0, -1),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(
                color: const Color(0xFFF3F4F6),
                width: 0.5,
              ),
            ),
            child: Container(
              margin: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.12),
                    color.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Center(
                child: HugeIcon(
                  icon: hugeIcon,
                  size: 24.w,
                  color: color,
                ),
              ),
            ),
          ),
          8.verticalSpace,
          Text(
            text,
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
              shadows: [
                Shadow(
                  offset: const Offset(0, 0.5),
                  blurRadius: 1,
                  color: Colors.white.withOpacity(0.8),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupInfoSection() {
    return _buildMenuSection(
      title: StrRes.groupInformation,
      items: [
        _buildMenuItem(
          hugeIcon: HugeIcons.strokeRoundedEdit02,
          text: StrRes.groupName,
          value: logic.groupInfo.value.groupName,
          color: const Color(0xFF4F42FF),
          hideArrow: true,
        ),
        _buildMenuItem(
          hugeIcon: HugeIcons.strokeRoundedCopy01,
          text: StrRes.groupID,
          value: logic.groupInfo.value.groupID,
          color: const Color(0xFF34D399),
          onTap: logic.copyGroupID,
          hideArrow: true,
        ),
        _buildMenuItem(
          hugeIcon: HugeIcons.strokeRoundedMessageMultiple01,
          text: StrRes.groupAc,
          color: const Color(0xFFFBBF24),
          onTap: logic.editGroupAnnouncement,
          isLast: !logic.showGroupManagement,
        ),
        if (logic.showGroupManagement)
          _buildMenuItem(
            hugeIcon: HugeIcons.strokeRoundedSettings01,
            text: StrRes.groupManage,
            color: const Color(0xFFF9A8D4),
            onTap: logic.groupManage,
            isLast: true,
          ),
      ],
    );
  }

  Widget _buildMemberSettingsSection() {
    return _buildMenuSection(
      title: StrRes.nicknameInGroup,
      items: [
        _buildMenuItem(
          hugeIcon: HugeIcons.strokeRoundedUser,
          text: StrRes.myGroupMemberNickname,
          value: logic.myGroupMembersInfo.value.nickname,
          color: const Color(0xFF2DD4BF),
          onTap: logic.modifyMyGroupNickname,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildChatSettingsSection() {
    return _buildMenuSection(
      title: StrRes.chatSettings,
      items: [
        _buildMenuItem(
          hugeIcon: HugeIcons.strokeRoundedPin,
          text: StrRes.topChat,
          color: const Color(0xFFFB923C),
          switchOn: logic.isPinned,
          onChanged: (_) => logic.toggleTopChat(),
        ),
        _buildMenuItem(
          hugeIcon: HugeIcons.strokeRoundedNotificationOff02,
          text: StrRes.messageNotDisturb,
          color: const Color(0xFFA78BFA),
          switchOn: logic.isNotDisturb,
          onChanged: (_) => logic.toggleNotDisturb(),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return _buildMenuSection(
      title: StrRes.actions,
      items: [
        _buildMenuItem(
          hugeIcon: HugeIcons.strokeRoundedFlag01,
          text: StrRes.report,
          color: const Color(0xFF34D399),
          onTap: logic.startReport,
        ),
        _buildMenuItem(
          hugeIcon: HugeIcons.strokeRoundedDelete02,
          text: StrRes.clearChatHistory,
          color: const Color(0xFFF87171),
          textStyle: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFF87171),
          ),
          onTap: logic.clearChatHistory,
          hideArrow: true,
          isLast: logic.isOwner, // Last if owner (no exit/dismiss button)
        ),
        if (!logic.isOwner)
          _buildMenuItem(
            hugeIcon: HugeIcons.strokeRoundedLogout01,
            text: logic.isJoinedGroup.value ? StrRes.exitGroup : StrRes.delete,
            color: const Color(0xFFF87171),
            textStyle: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFF87171),
            ),
            onTap: logic.quitGroup,
            hideArrow: true,
            isLast: true,
          ),
        if (logic.isOwner)
          _buildMenuItem(
            hugeIcon: HugeIcons.strokeRoundedCancelCircle,
            text: StrRes.dismissGroup,
            color: const Color(0xFFF87171),
            textStyle: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFF87171),
            ),
            onTap: logic.quitGroup,
            hideArrow: true,
            isLast: true,
          ),
      ],
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
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
        ),
        // Menu Container
        Container(
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
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required List<List<dynamic>> hugeIcon,
    required String text,
    required Color color,
    String? value,
    TextStyle? textStyle,
    bool switchOn = false,
    bool hideArrow = false,
    bool isLast = false,
    ValueChanged<bool>? onChanged,
    Function()? onTap,
  }) {
    final bool isWarning = color == const Color(0xFFF87171);

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
                    icon: hugeIcon,
                    size: 20.w,
                    color: isWarning
                        ? const Color(0xFFF87171)
                        : AppColor.iconColor,
                  ),
                  16.horizontalSpace,
                  Expanded(
                    child: Text(
                      text,
                      style: textStyle ??
                          TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: isWarning
                                ? const Color(0xFFF87171)
                                : const Color(0xFF374151),
                          ),
                    ),
                  ),

                  // Value text
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

                  // Switch
                  if (onChanged != null) ...[
                    8.horizontalSpace,
                    CupertinoSwitch(
                      value: switchOn,
                      activeColor: const Color(0xFF4F42FF),
                      onChanged: onChanged,
                    ),
                  ],

                  // Arrow - only show if no switch and not hideArrow
                  if (!hideArrow && onChanged == null) ...[
                    8.horizontalSpace,
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      size: 18.w,
                      color: const Color(0xFF6B7280),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        // Divider like MinePage
        if (!isLast)
          Padding(
            padding: EdgeInsets.only(left: 52.w),
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
