// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:openim/widgets/custom_buttom.dart';

import 'package:openim/widgets/empty_view.dart';
import 'package:openim/widgets/friend_item_view.dart';
import 'package:openim/widgets/gradient_scaffold.dart';
import 'package:openim/pages/auth/widget/app_text_form_field.dart';
import 'package:openim/widgets/overlay_new_contact.dart';
import 'package:openim_common/openim_common.dart';
import 'package:azlistview/azlistview.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:sprintf/sprintf.dart';

import 'contacts_logic.dart';
import '../conversation/conversation_logic.dart';
import 'group_list_logic.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

enum GroupFilterType { all, myGroup, joinedGroup }

class _ContactsPageState extends State<ContactsPage>
    with TickerProviderStateMixin {
  late final ContactsLogic logic;
  late final GroupListLogic groupListLogic;
  late TabController _tabController;
  final GlobalKey _newButtonKey = GlobalKey();
  GroupFilterType _selectedGroupFilter = GroupFilterType.all;
  final TextEditingController _friendSearchController = TextEditingController();
  final TextEditingController _groupSearchController = TextEditingController();
  late final FocusNode _friendSearchFocusNode;
  late final FocusNode _groupSearchFocusNode;
  bool _isFriendSearchActive = false;
  bool _isGroupSearchActive = false;

  @override
  void initState() {
    super.initState();
    logic = Get.find<ContactsLogic>();
    groupListLogic = Get.find<GroupListLogic>();
    _tabController = TabController(length: 2, vsync: this);
    _friendSearchFocusNode = FocusNode();
    _groupSearchFocusNode = FocusNode();

    // Close keyboard when tab changes
    _tabController.addListener(() {
      _friendSearchFocusNode.unfocus();
      _groupSearchFocusNode.unfocus();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _friendSearchController.dispose();
    _groupSearchController.dispose();
    _friendSearchFocusNode.dispose();
    _groupSearchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Obx(() => GradientScaffold(
          title: StrRes.contacts,
          subtitle:
              '${StrRes.friends}: ${logic.friendListLogic.friendList.length}, ${StrRes.groups}: ${groupListLogic.createdList.length + groupListLogic.joinedList.length}',
          trailing: CustomButton(
            onTap: () => showNewContactPopup(context, _newButtonKey),
            icon: Icons.grid_view,
            color: Colors.white,
          ),
          body: Column(
            children: [
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
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    logic.friendApplicationCount > 99
                                        ? StrRes.moreThan99
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
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    logic.groupApplicationCount > 99
                                        ? StrRes.moreThan99
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
        ));
  }

  Widget _buildFriendsTab() {
    return Obx(() {
      final friendList = logic.friendListLogic.friendList
          .map((u) => FriendListItem(type: FriendItemType.friend, user: u))
          .toList();

      // Filter by search
      final searchQuery = _friendSearchController.text.toLowerCase().trim();
      final filteredList = searchQuery.isEmpty
          ? friendList
          : friendList.where((item) {
              if (item.type != FriendItemType.friend) return false;
              final user = item.user;
              final name = user?.nickname ?? '';
              final remark = user?.remark ?? '';
              return name.toLowerCase().contains(searchQuery) ||
                  remark.toLowerCase().contains(searchQuery);
            }).toList();

      SuspensionUtil.setShowSuspensionStatus(filteredList);

      return Column(
        children: [
          // Friends function button & search box
          AnimatedCrossFade(
            firstChild: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _buildFunctionItem(
                      icon: CupertinoIcons.person_add,
                      label: StrRes.newFriend,
                      count: logic.friendApplicationCount,
                      onTap: logic.newFriend,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFriendSearchActive = true;
                        _friendSearchFocusNode.requestFocus();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      color: const Color(0xFFFFFFFF),
                      child: Center(
                        child: Icon(
                          CupertinoIcons.search,
                          color: Theme.of(context).primaryColor,
                          size: 20.w,
                          weight: 100,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            secondChild: Container(
              height: 48.h,
              margin: EdgeInsets.symmetric(vertical: 6.h),
              // padding: EdgeInsets.only(top: 10.h),
              color: const Color(0xFFFFFFFF),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isFriendSearchActive = false;
                        _friendSearchController.clear();
                        _friendSearchFocusNode.unfocus();
                      });
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: const Color(0xFF424242),
                      size: 20.w,
                    ),
                  ),
                  Expanded(
                    child: AppTextFormField(
                      focusNode: _friendSearchFocusNode,
                      controller: _friendSearchController,
                      label: StrRes.search,
                      keyboardType: TextInputType.text,
                      onChanged: (value) => setState(() {}),
                      validator: (value) => null,
                      prefixIcon: Icon(CupertinoIcons.search),
                      suffixIcon: _friendSearchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _friendSearchController.clear();
                                setState(() {});
                              },
                              child: Icon(
                                CupertinoIcons.xmark_circle_fill,
                                size: 22.w,
                                color: const Color(0xFF9CA3AF),
                              ),
                            )
                          : null,
                    ),
                  ),
                  16.horizontalSpace,
                ],
              ),
            ),
            crossFadeState: _isFriendSearchActive
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          Container(
            width: double.infinity,
            height: 5.h,
            color: const Color(0xFFF3F4F6),
          ),
          filteredList.isEmpty
              ? Expanded(
                  child: EmptyView(
                  message: searchQuery.isEmpty
                      ? StrRes.noFriendsYet
                      : StrRes.noFriendsFound,
                  icon: CupertinoIcons.person_2,
                ))
              : Expanded(
                  child: WrapAzListView<FriendListItem>(
                    data: filteredList,
                    itemCount: filteredList.length,
                    itemBuilder: (_, data, index) {
                      return FriendItemView(
                        info: data.user!,
                        showDivider: !_isLastFriendInGroup(index, filteredList),
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
        // Group function button & search box
        AnimatedCrossFade(
          firstChild: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildFunctionItem(
                    icon: CupertinoIcons.person_3,
                    label: StrRes.groupJoinRequests,
                    count: logic.groupApplicationCount,
                    onTap: logic.newGroup,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isGroupSearchActive = true;
                      _groupSearchFocusNode.requestFocus();
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    color: const Color(0xFFFFFFFF),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.search,
                        color: Theme.of(context).primaryColor,
                        size: 20.w,
                        weight: 100,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          secondChild: Container(
            height: 48.h,
            margin: EdgeInsets.symmetric(vertical: 6.h),
            color: const Color(0xFFFFFFFF),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isGroupSearchActive = false;
                      _groupSearchController.clear();
                      _groupSearchFocusNode.unfocus();
                    });
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: const Color(0xFF424242),
                    size: 20.w,
                  ),
                ),
                Expanded(
                  child: AppTextFormField(
                    focusNode: _groupSearchFocusNode,
                    controller: _groupSearchController,
                    label: StrRes.search,
                    keyboardType: TextInputType.text,
                    onChanged: (value) => setState(() {}),
                    validator: (value) => null,
                    prefixIcon: Icon(CupertinoIcons.search),
                    suffixIcon: _groupSearchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _groupSearchController.clear();
                              setState(() {});
                            },
                            child: Icon(
                              CupertinoIcons.xmark_circle_fill,
                              size: 22.w,
                              color: const Color(0xFF9CA3AF),
                            ),
                          )
                        : null,
                  ),
                ),
                16.horizontalSpace,
              ],
            ),
          ),
          crossFadeState: _isGroupSearchActive
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
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
              return EmptyView(
                icon: CupertinoIcons.group,
                message: StrRes.noGroupChatsYet,
              );
            }

            // Apply filter
            final showMyGroups = _selectedGroupFilter == GroupFilterType.all ||
                _selectedGroupFilter == GroupFilterType.myGroup;
            final showJoinedGroups =
                _selectedGroupFilter == GroupFilterType.all ||
                    _selectedGroupFilter == GroupFilterType.joinedGroup;

            // Search filter
            final searchQuery =
                _groupSearchController.text.toLowerCase().trim();
            final filteredMyGroups =
                (showMyGroups ? myGroups : <GroupInfo>[]).where((group) {
              if (searchQuery.isEmpty) return true;
              return (group.groupName ?? '')
                  .toLowerCase()
                  .contains(searchQuery);
            }).toList();

            final filteredJoinedGroups =
                (showJoinedGroups ? joinedGroups : <GroupInfo>[])
                    .where((group) {
              if (searchQuery.isEmpty) return true;
              return (group.groupName ?? '')
                  .toLowerCase()
                  .contains(searchQuery);
            }).toList();

            if (filteredMyGroups.isEmpty && filteredJoinedGroups.isEmpty) {
              return EmptyView(
                icon: CupertinoIcons.group,
                message: searchQuery.isEmpty
                    ? (_selectedGroupFilter == GroupFilterType.myGroup
                        ? StrRes.noCreatedGroupsYet
                        : _selectedGroupFilter == GroupFilterType.joinedGroup
                            ? StrRes.noJoinedGroupsYet
                            : StrRes.noGroupChatsYet)
                    : 'No groups found',
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
    required IconData icon,
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
                  Icon(
                    icon,
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
                          count > 99 ? StrRes.moreThan99 : count.toString(),
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
