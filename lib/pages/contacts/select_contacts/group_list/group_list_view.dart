// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import 'package:flutter/cupertino.dart';
import '../../../../widgets/base_page.dart';

import '../select_contacts_logic.dart';
import 'group_list_logic.dart';

class SelectContactsFromGroupPage extends StatelessWidget {
  final logic = Get.find<SelectContactsFromGroupLogic>();
  final selectContactsLogic = Get.find<SelectContactsLogic>();

  SelectContactsFromGroupPage({super.key});

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
            StrRes.chooseGroups,
            style: const TextStyle(
              fontFamily: 'FilsonPro',
              fontWeight: FontWeight.w500,
              fontSize: 23,
              color: Colors.black,
            ).copyWith(fontSize: 23.sp),
          ),
          Text(
            StrRes.chooseGroupsHint,
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
              onTap: logic.searchGroup,
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

          // Group List
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Obx(() => ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: logic.allList.length,
                    itemBuilder: (_, index) => Column(
                      children: [
                        _buildItemView(logic.allList[index]),
                        if (index != logic.allList.length - 1)
                          Padding(
                            padding: EdgeInsets.only(left: 70.w),
                            child: Container(
                              height: 1,
                              color: const Color(0xFFF3F4F6),
                            ),
                          ),
                      ],
                    ),
                  )),
            ),
          ),

          // Confirmation Bar
          selectContactsLogic.checkedConfirmView,
        ],
      ),
    );
  }

  Widget _buildItemView(GroupInfo info) {
    Widget buildChild() => Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: selectContactsLogic.onTap(info),
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                children: [
                  // Checkbox (for multi-select mode)
                  if (selectContactsLogic.isMultiModel)
                    Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selectContactsLogic.isChecked(info)
                            ? const Color(0xFF3B82F6)
                            : Colors.transparent,
                        border: Border.all(
                          color: selectContactsLogic.isChecked(info)
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFFD1D5DB),
                          width: 2.w,
                        ),
                      ),
                      child: selectContactsLogic.isChecked(info)
                          ? Icon(
                              CupertinoIcons.check_mark,
                              size: 14.w,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  16.horizontalSpace,
                  // Avatar
                  AvatarView(
                    url: info.faceURL,
                    text: info.groupName,
                    isGroup: true,
                    width: 42.w,
                    height: 42.h,
                    isCircle: true,
                  ),
                  16.horizontalSpace,

                  // Group Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          info.groupName ?? '',
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (selectContactsLogic
                            .shouldShowMemberCount(info.ownerUserID!))
                          4.verticalSpace,
                        if (selectContactsLogic
                            .shouldShowMemberCount(info.ownerUserID!))
                          Text(
                            sprintf(StrRes.nPerson, [info.memberCount]),
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.2,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    return selectContactsLogic.isMultiModel ? Obx(buildChild) : buildChild();
  }
}
