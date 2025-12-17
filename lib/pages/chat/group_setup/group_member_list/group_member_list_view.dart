// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';
import 'package:openim/widgets/custom_buttom.dart';
import 'package:openim/widgets/gradient_scaffold.dart';

import 'group_member_list_logic.dart';

class GroupMemberListPage extends StatelessWidget {
  final logic = Get.find<GroupMemberListLogic>(
      tag: (Get.arguments['opType'] as GroupMemberOpType).name);

  GroupMemberListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => GradientScaffold(
          title: logic.opType == GroupMemberOpType.del
              ? StrRes.removeGroupMember
              : StrRes.groupMember,
          showBackButton: true,
          trailing: logic.opType == GroupMemberOpType.view
              ? PopButton(
                  popCtrl: logic.poController,
                  horizontalMargin: 1.w,
                  menus: [
                    PopMenuInfo(text: StrRes.addMember, onTap: logic.addMember),
                    if (logic.isOwnerOrAdmin)
                      PopMenuInfo(
                          text: StrRes.delMember, onTap: logic.delMember),
                  ],
                  child: CustomButton(
                    onTap: () => logic.poController.showMenu(),
                    icon: Ionicons.ellipsis_horizontal,
                    color: Colors.white,
                  ),
                )
              : null,
          searchBox: _buildSearchBox(),
          body: _buildContentContainer(),
        ));
  }

  Widget _buildSearchBox() {
    return WechatStyleSearchBox(
      controller: logic.searchCtrl,
      focusNode: logic.focusNode,
      enabled: true,
      hintText: StrRes.search,
      onSubmitted: (_) => logic.search(),
      onChanged: (_) {
        if (logic.searchCtrl.text.trim().isNotEmpty) {
          logic.search();
        } else {
          logic.clearSearch();
        }
      },
      onCleared: () {
        logic.searchCtrl.clear();
        logic.clearSearch();
      },
    );
  }

  Widget _buildContentContainer() {
    return Column(
      children: [
        SizedBox(height: 40.h),

        // @Everyone option for group at
        if (logic.isOwnerOrAdmin && logic.isShowEveryone)
          Obx(() {
            if (logic.isOwnerOrAdmin &&
                logic.isShowEveryone &&
                logic.opType == GroupMemberOpType.at) {
              return Column(children: [
                GestureDetector(
                  onTap: logic.selectEveryone,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: logic.checkedList.any((e) =>
                                e.userID ==
                                OpenIM.iMManager.conversationManager.atAllTag)
                            ? Theme.of(Get.context!).primaryColor
                            : Colors.transparent,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9CA3AF).withOpacity(0.08),
                          offset: const Offset(0, 4),
                          blurRadius: 12.r,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF3B82F6).withOpacity(0.25),
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
                  ),
                ),
              ]);
            }
            return const SizedBox.shrink();
          }),

        // Member List
        Flexible(
          child: _buildMemberListWithEmptyState(),
        ),

        // Bottom confirm section for multi-select mode
        if (logic.isMultiSelMode) _CheckedConfirmView(logic: logic),
      ],
    );
  }

  Widget _buildMemberListWithEmptyState() {
    return Obx(
      () {
        // Chỉ observe isSearching và searchResults/memberList cho empty state và list data
        final isSearching = logic.isSearching.value;
        final isSearchNotResult = logic.isSearchNotResult;

        // Lấy reference của list (không tạo bản copy)
        final searchResultsRef = logic.searchResults;
        final memberListRef = logic.memberList;

        if (isSearching && isSearchNotResult) {
          return Center(
            child: Text(
              StrRes.searchNotFound,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          );
        }

        final list = isSearching ? searchResultsRef : memberListRef;
        final listLength = list.length;

        return _MemberListViewWidget(
          logic: logic,
          isSearching: isSearching,
          listLength: listLength,
        );
      },
    );
  }
}

class _MemberListViewWidget extends StatefulWidget {
  final GroupMemberListLogic logic;
  final bool isSearching;
  final int listLength;

  const _MemberListViewWidget({
    required this.logic,
    required this.isSearching,
    required this.listLength,
  });

  @override
  State<_MemberListViewWidget> createState() => _MemberListViewWidgetState();
}

class _MemberListViewWidgetState extends State<_MemberListViewWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SmartRefresher(
      controller: widget.logic.controller,
      onLoading: widget.logic.onLoad,
      enablePullDown: false,
      enablePullUp: !widget.isSearching,
      header: IMViews.buildHeader(),
      footer: IMViews.buildFooter(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: ListView.builder(
          key: PageStorageKey('member_list_${widget.isSearching}'),
          controller: widget.logic.scrollController,
          padding: EdgeInsets.zero,
          itemCount: widget.listLength,
          itemBuilder: (_, index) {
            final list = widget.isSearching
                ? widget.logic.searchResults
                : widget.logic.memberList;
            if (index >= list.length) return const SizedBox();
            final member = list[index];
            return _MemberItemView(
              key: ValueKey(member.userID),
              logic: widget.logic,
              member: member,
              showDivider: index != widget.listLength - 1,
              isFirst: index == 0,
              isLast: index == widget.listLength - 1,
            );
          },
        ),
      ),
    );
  }
}

class _MemberItemView extends StatelessWidget {
  final GroupMemberListLogic logic;
  final GroupMembersInfo member;
  final bool showDivider;
  final bool isFirst;
  final bool isLast;

  const _MemberItemView({
    super.key,
    required this.logic,
    required this.member,
    this.showDivider = false,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    if (logic.hiddenMember(member)) return const SizedBox();

    final bool hasIcon = logic.isMultiSelMode;

    // Use RepaintBoundary to isolate painting for better scroll performance
    return RepaintBoundary(
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => logic.clickMember(member),
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Row(
                  children: [
                    if (hasIcon)
                      Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: _CheckboxWidget(
                          logic: logic,
                          member: member,
                        ),
                      ),
                    AvatarView(
                      url: member.faceURL,
                      text: member.nickname,
                      width: 42.w,
                      height: 42.w,
                      isCircle: true,
                    ),
                    16.horizontalSpace,
                    Expanded(
                      child: Text(
                        member.nickname ?? '',
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
                    if (member.roleLevel == GroupRoleLevel.owner)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
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
                    if (member.roleLevel == GroupRoleLevel.admin)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
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
          ),
          if (showDivider)
            Padding(
              padding:
                  EdgeInsets.only(left: logic.isMultiSelMode ? 90.w : 74.w),
              child: Container(
                height: 1,
                color: const Color(0xFFF3F4F6),
              ),
            ),
        ],
      ),
    );
  }
}

/// Isolated checkbox widget to prevent flicker and improve scroll performance
class _CheckboxWidget extends StatelessWidget {
  final GroupMemberListLogic logic;
  final GroupMembersInfo member;

  const _CheckboxWidget({
    required this.logic,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    // Use RepaintBoundary to isolate painting for better scroll performance
    return RepaintBoundary(
      child: Obx(() {
        final isChecked = logic.isChecked(member);
        return Container(
          width: 24.w,
          height: 24.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isChecked ? const Color(0xFF3B82F6) : Colors.transparent,
            border: Border.all(
              color:
                  isChecked ? const Color(0xFF3B82F6) : const Color(0xFFD1D5DB),
              width: 2.w,
            ),
          ),
          child: isChecked
              ? Icon(
                  Ionicons.checkmark,
                  size: 14.w,
                  color: Colors.white,
                )
              : null,
        );
      }),
    );
  }
}

class _CheckedConfirmView extends StatelessWidget {
  final GroupMemberListLogic logic;

  const _CheckedConfirmView({required this.logic});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: GetBuilder<GroupMemberListLogic>(
          id: 'selected_count',
          tag: logic.opType.name,
          builder: (_) => Row(
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
                      // Use AnimatedOpacity instead of conditional to prevent layout shift
                      AnimatedOpacity(
                        opacity: logic.checkedList.isNotEmpty ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 150),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            4.verticalSpace,
                            Text(
                              logic.checkedList.isNotEmpty
                                  ? logic.checkedList
                                      .map((e) => e.nickname ?? '')
                                      .join('、')
                                  : '',
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
                      child: GetBuilder<GroupMemberListLogic>(
                        id: 'confirm_button',
                        tag: logic.opType.name,
                        builder: (_) {
                          final atAllTag =
                              OpenIM.iMManager.conversationManager.atAllTag;
                          final hasEveryone = logic.checkedList
                              .any((e) => e.userID == atAllTag);
                          final maxCount = hasEveryone ? 1 : logic.maxLength;
                          return Text(
                            sprintf(StrRes.confirmSelectedPeople, [
                              logic.checkedList.length,
                              maxCount,
                            ]),
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
                          child: _buildCheckedItemView(
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

  Widget _buildCheckedItemView(GroupMembersInfo membersInfo,
          {bool isLast = false}) =>
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
