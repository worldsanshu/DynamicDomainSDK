// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:openim/widgets/common_widgets.dart';
import 'package:openim/widgets/empty_view.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import '../../../routes/app_navigator.dart';
import 'group_requests_logic.dart';

class GroupRequestsPage extends StatelessWidget {
  final logic = Get.find<GroupRequestsLogic>();

  GroupRequestsPage({super.key});

  List<GroupApplicationInfo> _getFilteredList() {
    final tab = logic.selectedTab.value;

    switch (tab) {
      case 'requests':
        return logic.list.where((item) => item.handleResult == 0).toList();
      case 'approved':
        return logic.list.where((item) => item.handleResult == 1).toList();
      case 'rejected':
        return logic.list.where((item) => item.handleResult == -1).toList();
      default:
        return logic.list;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // Count by status
    final requestsCount =
        logic.list.where((item) => item.handleResult == 0).length;
    final approvedCount =
        logic.list.where((item) => item.handleResult == 1).length;
    final rejectedCount =
        logic.list.where((item) => item.handleResult == -1).length;

    return GradientScaffold(
      title: StrRes.groupJoinRequests,
      subtitle:
          "${StrRes.requests}: $requestsCount | ${StrRes.approved}: $approvedCount | ${StrRes.rejected}: $rejectedCount",
      showBackButton: true,
      body: Column(
        children: [
          // Tab Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                _buildTab('requests', StrRes.requests, primaryColor),
                _buildTab('approved', StrRes.approved, primaryColor),
                _buildTab('rejected', StrRes.rejected, primaryColor),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Obx(() {
              final filteredList = _getFilteredList();

              if (filteredList.isEmpty) {
                return EmptyView(
                  message: StrRes.noGroupRequests,
                  icon: CupertinoIcons.group,
                );
              }

              return AnimationLimiter(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: Column(
                      children: List.generate(
                        filteredList.length,
                        (index) => AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 400),
                          child: SlideAnimation(
                            verticalOffset: 40.0,
                            curve: Curves.easeOutCubic,
                            child: FadeInAnimation(
                              child: _buildItemView(
                                context,
                                filteredList[index],
                                index,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String tabId, String label, Color primaryColor) {
    return Expanded(
      child: Obx(() {
        final isSelected = logic.selectedTab.value == tabId;
        return GestureDetector(
          onTap: () => logic.selectedTab.value = tabId,
          behavior: HitTestBehavior.translucent,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? primaryColor : const Color(0xFF9CA3AF),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 3.h,
                  width: 30.w,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(1.5.r),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }


  Widget _buildItemView(
      BuildContext context, GroupApplicationInfo info, int index) {
    final isISendRequest = info.userID == OpenIM.iMManager.userID;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          AppNavigator.startUserProfilePane(
            userID: info.userID!,
            nickname: info.nickname,
            faceURL: info.userFaceURL,
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Column(
            children: [
              Row(
                children: [
                  AvatarView(
                    width: 55.w,
                    height: 55.h,
                    url: info.userFaceURL,
                    text: info.nickname,
                    isCircle: true,
                  ),
                  16.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.nickname ?? '',
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        6.verticalSpace,
                        _buildActionDescription(context, info),
                      ],
                    ),
                  ),
                  12.horizontalSpace,
                  _buildActionWidget(context, info, isISendRequest),
                ],
              ),
              // Application reason (if available)
              if (null != IMUtils.emptyStrToNull(info.reqMsg)) ...[
                12.verticalSpace,
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    sprintf(StrRes.applyReason, [info.reqMsg!]),
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionDescription(
      BuildContext context, GroupApplicationInfo info) {
    final primaryColor = Theme.of(context).primaryColor;

    if (!logic.isInvite(info)) {
      // Apply join case
      return RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
          children: [
            const TextSpan(
              text: 'applied to join ',
              style: TextStyle(
                fontFamily: 'FilsonPro',
                color: Color(0xFF6B7280),
              ),
            ),
            TextSpan(
              text: logic.getGroupName(info),
              style: TextStyle(
                fontFamily: 'FilsonPro',
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } else {
      // Invite case
      return RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: logic.getInviterNickname(info),
              style: TextStyle(
                fontFamily: 'FilsonPro',
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const TextSpan(
              text: ' invited you to ',
              style: TextStyle(
                fontFamily: 'FilsonPro',
                color: Color(0xFF6B7280),
              ),
            ),
            TextSpan(
              text: logic.getGroupName(info),
              style: TextStyle(
                fontFamily: 'FilsonPro',
                color: primaryColor.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildActionWidget(
    BuildContext context,
    GroupApplicationInfo info,
    bool isISendRequest,
  ) {
    final primaryColor = Theme.of(context).primaryColor;

    if (isISendRequest) {
      if (info.handleResult == 0) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Ionicons.time_outline,
                size: 16.w,
                color: primaryColor,
              ),
              6.horizontalSpace,
              Text(
                StrRes.waitingForVerification,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        );
      }
    } else {
      // Show action buttons only for pending requests
      if (info.handleResult == 0) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reject button
            GestureDetector(
              onTap: () => logic.rejectApplication(info),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: const Color(0xFFDC2626).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  StrRes.reject,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ),
            ),
            8.horizontalSpace,
            // Approve button
            GestureDetector(
              onTap: () => logic.approveApplication(info),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  StrRes.accept,
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
        );
      } else if (info.handleResult == 1) {
        // Approved status badge
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: const Color(0xFF059669).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Ionicons.checkmark_circle_outline,
                size: 16.w,
                color: const Color(0xFF059669),
              ),
              6.horizontalSpace,
              Text(
                StrRes.approved,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF059669),
                ),
              ),
            ],
          ),
        );
      } else if (info.handleResult == -1) {
        // Rejected status badge
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: const Color(0xFFDC2626).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Ionicons.close_circle_outline,
                size: 16.w,
                color: const Color(0xFFDC2626),
              ),
              6.horizontalSpace,
              Text(
                StrRes.rejected,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }
}
