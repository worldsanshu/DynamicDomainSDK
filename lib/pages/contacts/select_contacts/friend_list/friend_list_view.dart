// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/widgets/friend_item_view.dart';
import 'package:openim_common/openim_common.dart';

import 'package:flutter/cupertino.dart';
import '../../../../widgets/base_page.dart';

import '../select_contacts_logic.dart';
import 'friend_list_logic.dart';

class SelectContactsFromFriendsPage extends StatelessWidget {
  final logic = Get.find<SelectContactsFromFriendsLogic>();
  final selectContactsLogic = Get.find<SelectContactsLogic>();

  SelectContactsFromFriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      centerTitle: false,
      showLeading: true,
      customAppBar: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StrRes.chooseFriends,
            style: const TextStyle(
              fontFamily: 'FilsonPro',
              fontWeight: FontWeight.w500,
              fontSize: 23,
              color: Colors.black,
            ).copyWith(fontSize: 23.sp),
          ),
          Text(
            StrRes.chooseFriendsHint,
            style: const TextStyle(
              fontFamily: 'FilsonPro',
              fontWeight: FontWeight.w400,
              color: Color(0xFFBDBDBD),
            ).copyWith(fontSize: 12.sp),
          ),
        ],
      ),
      body: _buildContentContainer(),
    );
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
      child: Column(
        children: [
          // Search Box
          Container(
            margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: logic.searchFriend,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
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
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.search,
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

          16.verticalSpace,

          // Friends List
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Obx(
                () => WrapAzListView<ISUserInfo>(
                  data: logic.friendList,
                  itemCount: logic.friendList.length,
                  itemBuilder: (_, friend, index) => Obx(
                    () {
                      return FriendItemView(
                        info: friend,
                        showDivider: index != logic.friendList.length - 1,
                        checked: selectContactsLogic.isChecked(friend),
                        enabled: !selectContactsLogic.isDefaultChecked(friend),
                        onTap: selectContactsLogic.onTap(friend),
                        showRadioButton: selectContactsLogic.isMultiModel,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Confirmation Bar
          selectContactsLogic.checkedConfirmView,
        ],
      ),
    );
  }
}
