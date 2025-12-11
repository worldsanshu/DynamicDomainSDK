import 'dart:math';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import '../../../widgets/custom_buttom.dart';
import '../../../widgets/gradient_scaffold.dart';
import 'group_profile_panel_logic.dart';

class GroupProfilePanelPage extends StatelessWidget {
  final logic = Get.find<GroupProfilePanelLogic>();

  GroupProfilePanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: StrRes.groupInformation,
      showBackButton: true,
      scrollable: false,
      bodyColor: const Color(0xFFF4F5F9),
      body: Obx(() => Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
                  child: Column(
                    children: [
                      _buildBaseInfo(),
                      16.verticalSpace,
                      if (logic.members.isNotEmpty) _buildGroupMemberList(),
                      16.verticalSpace,
                      _buildGroupID(),
                      30.verticalSpace,
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(horizontal: 40.w),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 16.h),
                        decoration: BoxDecoration(
                          color: Theme.of(Get.context!).primaryColor,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              offset: const Offset(0, -4),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Text(StrRes.applyJoin,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontFamily: "FilsonPro",
                                )),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildBaseInfo() => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9CA3AF).withOpacity(0.06),
              offset: const Offset(0, 2),
              blurRadius: 6.r,
            ),
          ],
        ),
        child: Row(
          children: [
            AvatarView(
              width: 56.w,
              height: 56.h,
              url: logic.groupInfo.value.faceURL,
              text: logic.groupInfo.value.groupName,
              isGroup: true,
              borderRadius: BorderRadius.circular(12.r),
            ),
            16.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    logic.groupInfo.value.groupName ?? '',
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  6.verticalSpace,
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14.w,
                        color: const Color(0xFF9CA3AF),
                      ),
                      4.horizontalSpace,
                      Text(
                        DateUtil.formatDateMs(
                          (logic.groupInfo.value.createTime ?? 0),
                          format: IMUtils.getTimeFormat1(),
                        ),
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 13.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildGroupMemberList() => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9CA3AF).withOpacity(0.06),
              offset: const Offset(0, 2),
              blurRadius: 6.r,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  StrRes.groupMember,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
                if (logic.showMemberCount)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      sprintf(
                          StrRes.nPerson, [logic.groupInfo.value.memberCount]),
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
              ],
            ),
            16.verticalSpace,
            GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1,
              ),
              itemCount: min(logic.members.length, 6),
              shrinkWrap: true,
              itemBuilder: (_, index) {
                final member = logic.members.elementAt(index);
                if (index == 5 && logic.members.length > 6) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: const Color(0xFF9CA3AF),
                      size: 20.w,
                    ),
                  );
                }
                return AvatarView(
                  width: 44.w,
                  height: 44.h,
                  text: member.nickname,
                  url: member.faceURL,
                  borderRadius: BorderRadius.circular(10.r),
                );
              },
            ),
          ],
        ),
      );

  Widget _buildGroupID() => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9CA3AF).withOpacity(0.06),
              offset: const Offset(0, 2),
              blurRadius: 6.r,
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              StrRes.groupID,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF374151),
              ),
            ),
            const Spacer(),
            Text(
              logic.groupInfo.value.groupID,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 14.sp,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            8.horizontalSpace,
            GestureDetector(
              onTap: () => IMUtils.copy(text: logic.groupInfo.value.groupID),
              child: Icon(
                Icons.copy_rounded,
                size: 16.w,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      );
}
