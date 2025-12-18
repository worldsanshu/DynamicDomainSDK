// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import 'package:flutter/cupertino.dart';
import '../../../../widgets/gradient_scaffold.dart';

import '../select_contacts_logic.dart';
import 'group_list_logic.dart';

class SelectContactsFromGroupPage extends StatelessWidget {
  final logic = Get.find<SelectContactsFromGroupLogic>();
  final selectContactsLogic = Get.find<SelectContactsLogic>();

  SelectContactsFromGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: StrRes.chooseGroups,
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
                      size: 22.w,
                      color: const Color(0xFF9CA3AF),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
      body: _buildContentContainer(),
    );
  }

  Widget _buildContentContainer() {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            final displayList = logic.searchText.value.isEmpty
                ? logic.allList
                : logic.searchResults;

            if (displayList.isEmpty) {
              return Center(
                child: Text(
                  StrRes.noData,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: displayList.length,
              itemBuilder: (_, index) => Column(
                children: [
                  _buildItemView(displayList[index]),
                  if (index != displayList.length - 1)
                    Padding(
                      padding: EdgeInsets.only(left: 70.w),
                      child: Container(
                        height: 1,
                        color: const Color(0xFFF3F4F6),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        selectContactsLogic.checkedConfirmView,
      ],
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
