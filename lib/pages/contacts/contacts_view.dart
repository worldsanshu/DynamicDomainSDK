// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import 'package:hugeicons/hugeicons.dart';
import 'package:openim/widgets/friend_item_view.dart';
import 'package:openim_common/openim_common.dart';
import 'package:azlistview/azlistview.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:sprintf/sprintf.dart';

import 'contacts_logic.dart';
import '../conversation/conversation_logic.dart';
import '../home/home_logic.dart';
import 'group_list_logic.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

enum GroupFilterType { all, myGroup, joinedGroup }

class _ContactsPageState extends State<ContactsPage>
    with TickerProviderStateMixin {
  final logic = Get.find<ContactsLogic>();
  final groupListLogic = Get.find<GroupListLogic>();
  late TabController _tabController;
  final GlobalKey _newButtonKey = GlobalKey();
  GroupFilterType _selectedGroupFilter = GroupFilterType.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
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
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          StrRes.contacts,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontWeight: FontWeight.w700,
                            fontSize: 24.sp,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          key: _newButtonKey,
                          onTap: () => _showActionPopup(),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.grid_view,
                              color: Colors.white,
                              size: 20.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                    4.verticalSpace,
                    Obx(
                      () => Text(
                        '${StrRes.friends}: ${logic.friendListLogic.friendList.length}, ${StrRes.groups}: ${groupListLogic.createdList.length + groupListLogic.joinedList.length}',
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Content Card
          Container(
            margin: EdgeInsets.only(top: 100.h),
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
            child: Column(
              children: [
                20.verticalSpace,
                // Tab Bar
                TabBar(
                  controller: _tabController,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 3.0,
                    ),
                    insets: EdgeInsets.symmetric(horizontal: 16.0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  indicatorPadding: EdgeInsets.zero,
                  dividerColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  labelColor: primaryColor,
                  unselectedLabelColor: const Color(0xFF9CA3AF),
                  labelStyle: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(
                      child: Obx(() => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(StrRes.friends),
                              if (logic.friendApplicationCount > 0) ...[
                                5.horizontalSpace,
                                Container(
                                  constraints: BoxConstraints(
                                      minWidth: 20.w, minHeight: 20.h),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 6.w),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      logic.friendApplicationCount > 99
                                          ? '99+'
                                          : logic.friendApplicationCount
                                              .toString(),
                                      style: TextStyle(
                                        fontFamily: 'FilsonPro',
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          )),
                    ),
                    Tab(
                      child: Obx(() => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(StrRes.groups),
                              if (logic.groupApplicationCount > 0) ...[
                                5.horizontalSpace,
                                Container(
                                  constraints: BoxConstraints(
                                      minWidth: 20.w, minHeight: 20.h),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 6.w),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      logic.groupApplicationCount > 99
                                          ? '99+'
                                          : logic.groupApplicationCount
                                              .toString(),
                                      style: TextStyle(
                                        fontFamily: 'FilsonPro',
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          )),
                    ),
                  ],
                ),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),

                // Tab Bar View
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFriendsTab(),
                      _buildGroupsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsTab() {
    return Obx(() {
      final friendList = logic.friendListLogic.friendList
          .map((u) => FriendListItem(type: FriendItemType.friend, user: u))
          .toList();
      SuspensionUtil.setShowSuspensionStatus(friendList);

      return Column(
        children: [
          // Friends function button
          _buildFunctionItem(
            icon: HugeIcons.strokeRoundedUserAdd01,
            label: StrRes.newFriend,
            count: logic.friendApplicationCount,
            onTap: logic.newFriend,
          ),
          Container(
            width: double.infinity,
            height: 5.h,
            color: const Color(0xFFF3F4F6),
          ),
          friendList.isEmpty
              ? Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.person_2,
                          size: 48.w,
                          color: const Color(0xFF9CA3AF),
                        ),
                        12.verticalSpace,
                        Text(
                          StrRes.noFriendsYet,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: WrapAzListView<FriendListItem>(
                    data: friendList,
                    itemCount: friendList.length,
                    itemBuilder: (_, data, index) {
                      return FriendItemView(
                        info: data.user!,
                        showDivider: !_isLastFriendInGroup(index, friendList),
                        onTap: () =>
                            logic.friendListLogic.viewFriendInfo(data.user!),
                      );
                    },
                  ),
                ),
        ],
      );
    });
  }

  Widget _buildGroupsTab() {
    return Column(
      children: [
        _buildFunctionItem(
          icon: HugeIcons.strokeRoundedUserGroup,
          label: StrRes.groupJoinRequests,
          count: logic.groupApplicationCount,
          onTap: logic.newGroup,
        ),
        Container(
          width: double.infinity,
          height: 5.h,
          color: const Color(0xFFF3F4F6),
        ),
        // Filter chips
        _buildGroupFilterChips(),
        Expanded(
          child: Obx(() {
            // Filter group conversations
            final myGroups = groupListLogic.createdList;
            final joinedGroups = groupListLogic.joinedList;

            if (myGroups.isEmpty && joinedGroups.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.group,
                      size: 48.w,
                      color: const Color(0xFF9CA3AF),
                    ),
                    12.verticalSpace,
                    Text(
                      StrRes.noGroupChatsYet,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Apply filter
            final showMyGroups = _selectedGroupFilter == GroupFilterType.all ||
                _selectedGroupFilter == GroupFilterType.myGroup;
            final showJoinedGroups =
                _selectedGroupFilter == GroupFilterType.all ||
                    _selectedGroupFilter == GroupFilterType.joinedGroup;

            // Check if filtered list is empty
            final filteredMyGroups = showMyGroups ? myGroups : <GroupInfo>[];
            final filteredJoinedGroups =
                showJoinedGroups ? joinedGroups : <GroupInfo>[];

            if (filteredMyGroups.isEmpty && filteredJoinedGroups.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.group,
                      size: 48.w,
                      color: const Color(0xFF9CA3AF),
                    ),
                    12.verticalSpace,
                    Text(
                      _selectedGroupFilter == GroupFilterType.myGroup
                          ? StrRes.noCreatedGroupsYet
                          : StrRes.noJoinedGroupsYet,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              );
            }

            return SlidableAutoCloseBehavior(
              child: CustomScrollView(
                slivers: [
                  // My Groups section
                  if (filteredMyGroups.isNotEmpty) ...[
                    if (_selectedGroupFilter == GroupFilterType.all)
                      SliverToBoxAdapter(
                        child: Container(
                          padding: EdgeInsets.only(
                            left: 16.w,
                            right: 16.w,
                            top: 15.h,
                            bottom: 5.h,
                          ),
                          color: Colors.white,
                          child: Text(
                            StrRes.myGroup,
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
                        ),
                      ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildGroupConversationItem(
                              filteredMyGroups[index]);
                        },
                        childCount: filteredMyGroups.length,
                      ),
                    ),
                  ],

                  // Joined Groups section
                  if (filteredJoinedGroups.isNotEmpty) ...[
                    if (_selectedGroupFilter == GroupFilterType.all)
                      SliverToBoxAdapter(
                        child: Container(
                          padding: EdgeInsets.only(
                            left: 16.w,
                            right: 16.w,
                            top: 15.h,
                            bottom: 5.h,
                          ),
                          color: Colors.white,
                          child: Text(
                            StrRes.joinedGroup,
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
                        ),
                      ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildGroupConversationItem(
                            filteredJoinedGroups[index],
                          );
                        },
                        childCount: filteredJoinedGroups.length,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildGroupFilterChips() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: Colors.white,
      child: Row(
        children: [
          _buildFilterChip(
            label: StrRes.all,
            isSelected: _selectedGroupFilter == GroupFilterType.all,
            onTap: () =>
                setState(() => _selectedGroupFilter = GroupFilterType.all),
          ),
          8.horizontalSpace,
          _buildFilterChip(
            label: StrRes.myGroup,
            isSelected: _selectedGroupFilter == GroupFilterType.myGroup,
            onTap: () =>
                setState(() => _selectedGroupFilter = GroupFilterType.myGroup),
          ),
          8.horizontalSpace,
          _buildFilterChip(
            label: StrRes.joinedGroup,
            isSelected: _selectedGroupFilter == GroupFilterType.joinedGroup,
            onTap: () => setState(
                () => _selectedGroupFilter = GroupFilterType.joinedGroup),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildFunctionItem({
    required List<List<dynamic>> icon,
    required String label,
    int count = 0,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
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
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 30),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(
                    icon: icon,
                    size: 20.w,
                    color: const Color(0xFF424242),
                  ),
                  8.horizontalSpace,
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  8.horizontalSpace,
                  if (count > 0)
                    Container(
                      constraints:
                          BoxConstraints(minWidth: 24.w, minHeight: 24.h),
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          count > 99 ? '99+' : count.toString(),
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isLastFriendInGroup(int index, List<FriendListItem> data) {
    final item = data[index];
    if (item.type != FriendItemType.friend) return false;

    for (int i = index + 1; i < data.length;) {
      final nextItem = data[i];
      if (nextItem.type == FriendItemType.friend) {
        return item.getSuspensionTag() != nextItem.getSuspensionTag();
      }
      return true;
    }
    return true;
  }

  Widget _buildGroupConversationItem(GroupInfo groupInfo) {
    final conversationLogic = Get.find<ConversationLogic>();
    final shouldShowCount =
        groupListLogic.shouldShowMemberCount(groupInfo.ownerUserID!);

    return Material(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => conversationLogic.toChat(
          offUntilHome: false,
          groupID: groupInfo.groupID,
          nickname: groupInfo.groupName,
          faceURL: groupInfo.faceURL,
          sessionType: groupInfo.sessionType,
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Group Avatar
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.r),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50.r),
                  child: AvatarView(
                    width: 50.w,
                    height: 50.h,
                    url: groupInfo.faceURL,
                    isGroup: true,
                    textStyle: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    isCircle: true,
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                ),
              ),
              12.horizontalSpace,
              // Group Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            groupInfo.groupName ?? '',
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF374151),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (shouldShowCount) ...[
                      4.verticalSpace,
                      sprintf(StrRes.nPerson, [groupInfo.memberCount]).toText
                        ..style = Styles.ts_8E9AB0_14sp,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionPopup() {
    final homeLogic = Get.find<HomeLogic>();
    final RenderBox button =
        _newButtonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(Offset.zero);
    final menuWidth = 200.w;
    final double left = buttonPosition.dx + button.size.width - menuWidth;
    final double top = buttonPosition.dy + button.size.height + 4;

    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Stack(
            children: [
              Positioned(
                left: left,
                top: top,
                width: menuWidth,
                child: Material(
                  color: Colors.transparent,
                  child: ScaleTransition(
                    scale: animation,
                    alignment: Alignment.topRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMenuItemPopup(
                            icon: HugeIcons.strokeRoundedAiScan,
                            title: StrRes.scan,
                            onTap: () {
                              Navigator.pop(context);
                              homeLogic.scan();
                            },
                            isFirst: true,
                          ),
                          _buildMenuDividerPopup(),
                          _buildMenuItemPopup(
                            icon: HugeIcons.strokeRoundedUserAdd01,
                            title: StrRes.addFriend,
                            onTap: () {
                              Navigator.pop(context);
                              homeLogic.addFriend();
                            },
                          ),
                          _buildMenuDividerPopup(),
                          _buildMenuItemPopup(
                            icon: HugeIcons.strokeRoundedUserGroup,
                            title: StrRes.addGroup,
                            onTap: () {
                              Navigator.pop(context);
                              homeLogic.addGroup();
                            },
                          ),
                          _buildMenuDividerPopup(),
                          _buildMenuItemPopup(
                            icon: HugeIcons.strokeRoundedUserGroup02,
                            title: StrRes.createGroup,
                            onTap: () {
                              Navigator.pop(context);
                              homeLogic.createGroup();
                            },
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItemPopup({
    required List<List<dynamic>> icon,
    required String title,
    VoidCallback? onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: isFirst
                ? BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  )
                : isLast
                    ? BorderRadius.only(
                        bottomLeft: Radius.circular(12.r),
                        bottomRight: Radius.circular(12.r),
                      )
                    : null,
          ),
          child: Row(
            children: [
              HugeIcon(
                icon: icon,
                size: 20.w,
                color: const Color(0xFF424242),
              ),
              12.horizontalSpace,
              Text(
                title,
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
    );
  }

  Widget _buildMenuDividerPopup() {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w),
      child: const Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFF3F4F6),
      ),
    );
  }
}

enum FriendItemType {
  functionGrid,
  friend,
}

class FriendListItem with ISuspensionBean {
  final FriendItemType type;
  final ISUserInfo? user;

  FriendListItem({
    required this.type,
    this.user,
  });

  @override
  String getSuspensionTag() {
    if (type == FriendItemType.friend) {
      final tag = user?.getSuspensionTag() ?? '';
      return tag;
    }
    return '🔍';
  }
}
