import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';
import 'package:openim/widgets/base_page.dart';
import 'package:openim/widgets/custom_buttom.dart';

import 'group_member_list_logic.dart';

class GroupMemberListPage extends StatelessWidget {
  final logic = Get.find<GroupMemberListLogic>(
      tag: (Get.arguments['opType'] as GroupMemberOpType).name);

  GroupMemberListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => BasePage(
          showAppBar: true,
          centerTitle: false,
          showLeading: true,
          customAppBar: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                logic.opType == GroupMemberOpType.del
                    ? StrRes.removeGroupMember
                    : StrRes.groupMember,
                style: const TextStyle(
                  fontFamily: 'FilsonPro',
                  fontWeight: FontWeight.w500,
                  fontSize: 23,
                  color: Colors.black,
                ).copyWith(fontSize: 23.sp),
              ),
              Text(
                StrRes.manageGroupMembers,
                style: const TextStyle(
                  fontFamily: 'FilsonPro',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFBDBDBD),
                ).copyWith(fontSize: 12.sp),
              ),
            ],
          ),
          actions: logic.opType == GroupMemberOpType.view
              ? [
                  CustomButtom(
                    margin: EdgeInsets.only(right: 10.w, top: 6.h, bottom: 6.h),
                    onPressed: () => logic.poController.showMenu(),
                    icon: Ionicons.ellipsis_horizontal,
                    colorButton: Colors.white.withOpacity(0.3),
                    colorIcon: Colors.white,
                  ),
                  PopButton(
                    popCtrl: logic.poController,
                    horizontalMargin: 1.w,
                    menus: [
                      PopMenuInfo(
                          text: StrRes.addMember, onTap: logic.addMember),
                      if (logic.isOwnerOrAdmin)
                        PopMenuInfo(
                            text: StrRes.delMember, onTap: logic.delMember),
                    ],
                    child: const SizedBox(),
                  ),
                ]
              : null,
          body: _buildContentContainer(),
        ));
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
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: AnimationLimiter(
          child: Column(
            children: [
              // Search Box Section
              AnimationConfiguration.staggeredList(
                position: 0,
                duration: const Duration(milliseconds: 400),
                child: SlideAnimation(
                  curve: Curves.easeOutCubic,
                  verticalOffset: 40.0,
                  child: FadeInAnimation(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: logic.search,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF9CA3AF).withOpacity(0.06),
                                offset: const Offset(0, 2),
                                blurRadius: 6.r,
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xFFF3F4F6),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Ionicons.search,
                                size: 20.w,
                                color: const Color(0xFF6B7280),
                              ),
                              12.horizontalSpace,
                              Text(
                                StrRes.search,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              16.verticalSpace,

              // @Everyone option for group at
              if (logic.isOwnerOrAdmin && logic.isShowEveryone)
                AnimationConfiguration.staggeredList(
                  position: 1,
                  duration: const Duration(milliseconds: 400),
                  child: SlideAnimation(
                    curve: Curves.easeOutCubic,
                    verticalOffset: 40.0,
                    child: FadeInAnimation(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: logic.selectEveryone,
                          borderRadius: BorderRadius.circular(16.r),
                          child: logic.isOwnerOrAdmin &&
                                  logic.isShowEveryone &&
                                  logic.opType == GroupMemberOpType.at
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 16.h),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42.w,
                                        height: 42.w,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF3B82F6),
                                              Color(0xFF1D4ED8)
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF3B82F6)
                                                  .withOpacity(0.25),
                                              offset: const Offset(0, 2),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            '@',
                                            style: TextStyle(
                                              fontFamily: 'FilsonPro',
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      16.horizontalSpace,
                                      Text(
                                        StrRes.everyone,
                                        style: TextStyle(
                                          fontFamily: 'FilsonPro',
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF374151),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                        ),
                      ),
                    ),
                  ),
                ),

              // Member List
              Flexible(
                child: SmartRefresher(
                  controller: logic.controller,
                  onLoading: logic.onLoad,
                  enablePullDown: false,
                  enablePullUp: true,
                  header: IMViews.buildHeader(),
                  footer: IMViews.buildFooter(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: AnimationLimiter(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: logic.memberList.length,
                        itemBuilder: (_, index) =>
                            AnimationConfiguration.staggeredList(
                          position: index + 2,
                          duration: const Duration(milliseconds: 400),
                          child: SlideAnimation(
                            curve: Curves.easeOutCubic,
                            verticalOffset: 40.0,
                            child: FadeInAnimation(
                              child: Obx(
                                () => Column(
                                  children: [
                                    _buildItemView(
                                      logic.memberList[index],
                                      showDivider:
                                          index != logic.memberList.length - 1,
                                      isFirst: index == 0,
                                      isLast:
                                          index == logic.memberList.length - 1,
                                    ),
                                    if (index != logic.memberList.length - 1)
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: logic.isMultiSelMode
                                                ? 90.w
                                                : 74.w),
                                        child: Container(
                                          height: 1,
                                          color: const Color(0xFFF3F4F6),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom confirm section for multi-select mode
              if (logic.isMultiSelMode) _buildCheckedConfirmView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemView(
    GroupMembersInfo membersInfo, {
    bool showDivider = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    if (logic.hiddenMember(membersInfo)) return const SizedBox();

    final bool hasIcon = logic.isMultiSelMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => logic.clickMember(membersInfo),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            children: [
              if (hasIcon)
                Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: logic.isChecked(membersInfo)
                          ? const Color(0xFF3B82F6)
                          : Colors.transparent,
                      border: Border.all(
                        color: logic.isChecked(membersInfo)
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFD1D5DB),
                        width: 2.w,
                      ),
                    ),
                    child: logic.isChecked(membersInfo)
                        ? Icon(
                            Ionicons.checkmark,
                            size: 14.w,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              AvatarView(
                url: membersInfo.faceURL,
                text: membersInfo.nickname,
                width: 42.w,
                height: 42.w,
                isCircle: true,
              ),
              16.horizontalSpace,
              Expanded(
                child: Text(
                  membersInfo.nickname ?? '',
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (membersInfo.roleLevel == GroupRoleLevel.owner)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    StrRes.groupOwner,
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ),
              if (membersInfo.roleLevel == GroupRoleLevel.admin)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    StrRes.groupAdmin,
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckedConfirmView() => Container(
        constraints: BoxConstraints(
          minHeight: 80.h,
        ),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.6, 1.0],
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64748B).withOpacity(0.08),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: const Color(0xFF64748B).withOpacity(0.04),
              offset: const Offset(0, 2),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => Get.bottomSheet(
                    SelectedMemberListView(),
                    isScrollControlled: true,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              sprintf(StrRes.selectedPeopleCount,
                                  [logic.checkedList.length]),
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3B82F6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          8.horizontalSpace,
                          Icon(
                            Ionicons.chevron_up,
                            size: 20.w,
                            color: const Color(0xFF3B82F6),
                          ),
                        ],
                      ),
                      if (logic.checkedList.isNotEmpty) 4.verticalSpace,
                      if (logic.checkedList.isNotEmpty)
                        Text(
                          logic.checkedList
                              .map((e) => e.nickname ?? '')
                              .join('、'),
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),

              // Confirm Button
              Container(
                height: 44.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.25),
                      offset: const Offset(0, 2),
                      blurRadius: 6.r,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: logic.confirmSelectedMember,
                    borderRadius: BorderRadius.circular(22.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      alignment: Alignment.center,
                      child: Text(
                        sprintf(StrRes.confirmSelectedPeople, [
                          logic.checkedList.length,
                          logic.maxLength,
                        ]),
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class SelectedMemberListView extends StatelessWidget {
  SelectedMemberListView({super.key});
  final logic = Get.find<GroupMemberListLogic>(
      tag: (Get.arguments['opType'] as GroupMemberOpType).name);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 548.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.08),
            offset: const Offset(0, -4),
            blurRadius: 12.r,
          ),
        ],
      ),
      child: Obx(() => Column(
            children: [
              // Handle bar
              Container(
                width: 36.w,
                height: 4.h,
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFF3F4F6),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      sprintf(StrRes.selectedPeopleCount,
                          [logic.checkedList.length]),
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F42FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          StrRes.confirm,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4F42FF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // List with Animation
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    itemCount: logic.checkedList.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    itemBuilder: (_, index) =>
                        AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 400),
                      child: SlideAnimation(
                        curve: Curves.easeOutCubic,
                        verticalOffset: 40.0,
                        child: FadeInAnimation(
                          child: _buildItemView(
                            logic.checkedList[index],
                            isLast: index == logic.checkedList.length - 1,
                          ),
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

  Widget _buildItemView(GroupMembersInfo membersInfo, {bool isLast = false}) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => logic.removeSelectedMember(membersInfo),
          child: Container(
            margin: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              bottom: isLast ? 0 : 8.h,
            ),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFFF1F5F9),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF64748B).withOpacity(0.03),
                  offset: const Offset(0, 2),
                  blurRadius: 8.r,
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                AvatarView(
                  width: 48.w,
                  height: 48.h,
                  url: membersInfo.faceURL,
                  text: membersInfo.nickname,
                  textStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),

                16.horizontalSpace,

                // Member info
                Expanded(
                  child: Text(
                    membersInfo.nickname ?? '',
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                8.horizontalSpace,

                // Remove button
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    StrRes.remove,
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
