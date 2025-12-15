// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:openim/widgets/empty_view.dart';
import 'package:openim/widgets/friend_item_view.dart';
import 'package:openim_common/openim_common.dart';

import 'package:flutter/cupertino.dart';
import '../../../../widgets/gradient_scaffold.dart';

import '../select_contacts_logic.dart';
import 'friend_list_logic.dart';

class SelectContactsFromFriendsPage extends StatelessWidget {
  final logic = Get.find<SelectContactsFromFriendsLogic>();
  final selectContactsLogic = Get.find<SelectContactsLogic>();

  SelectContactsFromFriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: StrRes.chooseFriends,
      showBackButton: true,
      searchBox: Container(
        height: 50.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.search,
              size: 20.w,
              color: const Color(0xFF9CA3AF),
            ),
            12.horizontalSpace,
            Expanded(
              child: TextField(
                controller: logic.searchCtrl,
                onChanged: logic.performSearch,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF111827),
                ),
                decoration: InputDecoration(
                  hintText: StrRes.search,
                  hintStyle: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Obx(() => logic.searchText.value.isNotEmpty
                ? GestureDetector(
                    onTap: logic.clearSearch,
                    child: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      size: 18.w,
                      color: const Color(0xFF9CA3AF),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () {
                final displayList = logic.searchText.value.isEmpty
                    ? logic.friendList
                    : logic.searchResults;

                if (displayList.isEmpty) {
                  return EmptyView(
                    message: StrRes.noFriendsFound,
                    icon: Ionicons.people_outline,
                  );
                }

                return WrapAzListView<ISUserInfo>(
                    data: displayList,
                    itemCount: displayList.length,
                    itemBuilder: (_, friend, index) => Column(
                          children: [
                            if (displayList.length < 7) SizedBox(height: 16.h),
                            Obx(() {
                              return FriendItemView(
                                info: friend,
                                showDivider: index != displayList.length - 1,
                                checked: selectContactsLogic.isChecked(friend),
                                // Allow toggling so previously selected users are visible
                                // and can be unselected in the friends selector.
                                enabled: true,
                                onTap: selectContactsLogic.onTap(friend),
                                showRadioButton:
                                    selectContactsLogic.isMultiModel,
                              );
                            }),
                          ],
                        ));
              },
            ),
          ),
          selectContactsLogic.checkedConfirmView,
        ],
      ),
    );
  }
}
