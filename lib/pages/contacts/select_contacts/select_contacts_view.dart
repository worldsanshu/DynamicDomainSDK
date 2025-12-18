// ignore_for_file: deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ionicons/ionicons.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim/widgets/custom_buttom.dart';
import 'package:openim/widgets/empty_view.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import 'package:flutter/cupertino.dart';

import '../../../widgets/friend_item_view.dart';
import 'package:openim/widgets/gradient_scaffold.dart';
import 'select_contacts_logic.dart';

class SelectContactsPage extends StatelessWidget {
  final logic = Get.find<SelectContactsLogic>();

  SelectContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: StrRes.selectContacts,
      showBackButton: true,
      searchBox: WechatStyleSearchBox(
        hintText: StrRes.search,
        enabled: true,
        autofocus: false,
        controller: logic.searchCtrl,
        onChanged: logic.performSearch,
        onCleared: logic.clearSearch,
        margin: EdgeInsets.zero,
      ),
      body: _buildContentContainer(),
    );
  }

  Widget _buildContentContainer() {
    return Column(
      children: [
        // Content based on search or normal view
        Expanded(
          child: Obx(() {
            final hasSearchText = logic.searchText.value.isNotEmpty;
            final displayResults = hasSearchText ? logic.searchResults : null;

            // Show friend list only mode
            if (logic.isShowFriendListOnly) {
              if (hasSearchText) {
                if (displayResults!.isEmpty) {
                  return EmptyView(
                    message: StrRes.noFriendsFound,
                    icon: Ionicons.people_outline,
                  );
                }
                return _buildSearchResultsList(displayResults);
              }
              // Show all friends
              if (logic.friendList.isEmpty) {
                return EmptyView(
                  message: StrRes.noFriendsYet,
                  icon: Ionicons.people_outline,
                );
              }
              return WrapAzListView<ISUserInfo>(
                data: logic.friendList,
                itemCount: logic.friendList.length,
                itemBuilder: (_, friend, index) => Obx(() => Column(
                      children: [
                        if (index == 0) ...[SizedBox(height: 16.h)],
                        FriendItemView(
                          info: friend,
                          showDivider: index != logic.friendList.length - 1,
                          checked: logic.isChecked(friend),
                          // Allow toggling even if previously default-checked so
                          // selected users are visible and can be unchecked.
                          enabled: true,
                          onTap: () => logic.toggleChecked(friend),
                          showRadioButton: logic.showRadioButton,
                        )
                      ],
                    )),
              );
            }

            // Normal view with categories and conversations
            if (hasSearchText) {
              if (displayResults!.isEmpty) {
                return EmptyView(
                  message: StrRes.noData,
                  icon: Ionicons.search_outline,
                );
              }
              return _buildSearchResultsList(displayResults);
            }

            // Show normal list with categories
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildCategoryItemView(
                    label: StrRes.chooseFriends,
                    onTap: logic.selectFromMyFriend,
                    isFirst: true,
                    isLast: logic.hiddenGroup,
                  ),
                  if (!logic.hiddenGroup)
                    _buildCategoryItemView(
                      label: StrRes.chooseGroups,
                      onTap: logic.selectFromMyGroup,
                      isLast: true,
                    ),
                  if (logic.conversationList.isNotEmpty) ...[
                    Container(
                      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        StrRes.recentConversations,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    ...List.generate(
                      logic.conversationList.length,
                      (index) => _buildConversationItemView(
                        logic.conversationList[index],
                        index == 0,
                        index == logic.conversationList.length - 1,
                      ),
                    ),
                  ],
                  16.verticalSpace,
                ],
              ),
            );
          }),
        ),

        logic.checkedConfirmView,
      ],
    );
  }

  Widget _buildSearchResultsList(Map<String, dynamic> results) {
    return ListView.builder(
      itemCount: results.length,
      padding: EdgeInsets.zero,
      itemBuilder: (_, index) {
        final info = results.values.elementAt(index);
        if (info is ISUserInfo) {
          return Obx(() => FriendItemView(
                info: info,
                showDivider: index != results.length - 1,
                checked: logic.isChecked(info),
                // Always enable so previously selected users are visible
                // and can be unchecked from search results.
                enabled: true,
                onTap: () => logic.toggleChecked(info),
                showRadioButton: logic.showRadioButton,
              ));
        } else if (info is ConversationInfo) {
          return _buildConversationItemView(
              info, index == 0, index == results.length - 1);
        }
        return const SizedBox.shrink();
      },
    );
  }

  // _buildSendButton removed: unused in this view

  Widget _buildCategoryItemView({
    required String label,
    required Function() onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.vertical(
            top: isFirst ? Radius.circular(16.r) : Radius.zero,
            bottom: isLast ? Radius.circular(16.r) : Radius.zero,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  Icon(
                    label == StrRes.chooseFriends
                        ? CupertinoIcons.person_2_fill
                        : CupertinoIcons.person_3_fill,
                    size: 20.w,
                    color: AppColor.iconColor,
                  ),
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
                  Icon(
                    CupertinoIcons.right_chevron,
                    size: 16.w,
                    color: const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
            if (!isLast)
              Padding(
                padding: EdgeInsets.only(left: 70.w),
                child: Container(
                  height: 1,
                  color: const Color(0xFFF3F4F6),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationItemView(
      ConversationInfo info, bool isFirst, bool isLast) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => logic.toggleConversationChecked(info),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                // Checkbox
                Obx(() => Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: logic.isConversationChecked(info)
                            ? const Color(0xFF3B82F6)
                            : Colors.transparent,
                        border: Border.all(
                          color: logic.isConversationChecked(info)
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFFD1D5DB),
                          width: 1.5.w,
                        ),
                      ),
                      child: logic.isConversationChecked(info)
                          ? Icon(
                              CupertinoIcons.check_mark,
                              size: 12.w,
                              color: Colors.white,
                            )
                          : null,
                    )),
                12.horizontalSpace,
                // Avatar
                AvatarView(
                  url: info.faceURL,
                  text: info.showName,
                  isGroup: info.isGroupChat,
                  width: 40.w,
                  height: 40.h,
                  isCircle: true,
                ),
                12.horizontalSpace,
                // Conversation Info
                Expanded(
                  child: Text(
                    info.showName ?? '',
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (!isLast)
            Padding(
              padding: EdgeInsets.only(left: 50.w),
              child: Container(
                height: 0.5,
                color: const Color(0xFFF1F5F9),
              ),
            ),
        ],
      ),
    );
  }
}

class CheckedConfirmView extends StatelessWidget {
  CheckedConfirmView({super.key});

  final logic = Get.find<SelectContactsLogic>();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 80.h,
      ),
      // margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Obx(() => Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: logic.viewSelectedContactsList,
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
                            Icons.keyboard_arrow_up,
                            size: 20.w,
                            color: const Color(0xFF3B82F6),
                          ),
                        ],
                      ),
                      if (logic.checkedList.isNotEmpty) 4.verticalSpace,
                      if (logic.checkedList.isNotEmpty)
                        Text(
                          logic.checkedStrTips,
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
              SizedBox(
                height: 44.h,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: logic.enabledConfirmButton
                        ? logic.confirmSelectedList
                        : null,
                    borderRadius: BorderRadius.circular(22.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: logic.enabledConfirmButton
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF3B82F6),
                                  Color(0xFF1D4ED8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: logic.enabledConfirmButton
                            ? null
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(22.r),
                        boxShadow: logic.enabledConfirmButton
                            ? [
                                BoxShadow(
                                  color:
                                      const Color(0xFF3B82F6).withOpacity(0.25),
                                  offset: const Offset(0, 2),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        sprintf(StrRes.confirmSelectedPeople, [
                          logic.checkedList.length,
                          '999',
                        ]),
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: logic.enabledConfirmButton
                              ? Colors.white
                              : const Color(0xFF64748B),
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
}

class SelectedContactsListView extends StatelessWidget {
  SelectedContactsListView({super.key});

  final logic = Get.find<SelectContactsLogic>();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
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
                        color: primaryColor,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => Get.back(),
                      child: CustomButton(
                          icon: CupertinoIcons.xmark,
                          iconSize: 12,
                          color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              // List
              Expanded(
                child: ListView.builder(
                  itemCount: logic.checkedList.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  itemBuilder: (_, index) => _buildItemView(index),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildItemView(int index) {
    final info = logic.checkedList.values.elementAt(index);
    String? name;
    String? faceURL;
    bool isGroup = false;
    name = SelectContactsLogic.parseName(info);
    faceURL = SelectContactsLogic.parseFaceURL(info);
    if (info is ConversationInfo) {
      isGroup = !info.isSingleChat;
    } else if (info is GroupInfo) {
      isGroup = true;
      name = info.groupName;
      faceURL = info.faceURL;
    } else if (info is UserInfo) {
      name = info.nickname;
      faceURL = info.faceURL;
    } else if (info is TagInfo) {
      name = info.tagName;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          if (info is TagInfo)
            Container(
              width: 42.w,
              height: 42.h,
              decoration: BoxDecoration(
                color: const Color(0xFFA78BFA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.tag,
                size: 20.w,
                color: const Color(0xFFA78BFA),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34.r),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1.5.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9CA3AF).withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 8.r,
                  ),
                ],
              ),
              child: AvatarView(
                url: faceURL,
                text: name,
                isGroup: isGroup,
                width: 50.w,
                height: 50.h,
                isCircle: true,
              ),
            ),
          16.horizontalSpace,
          Expanded(
            child: Text(
              name ?? '',
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF374151),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => logic.removeItem(info),
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child:
                    Icon(CupertinoIcons.delete, color: Colors.red, size: 20.w)),
          ),
        ],
      ),
    );
  }
}
