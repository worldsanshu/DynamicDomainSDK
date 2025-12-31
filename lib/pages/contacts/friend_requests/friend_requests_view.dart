// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:openim/widgets/empty_view.dart';
import 'package:openim/widgets/gradient_scaffold.dart';
import 'package:openim_common/openim_common.dart';

import 'friend_requests_logic.dart';
import '../../../routes/app_navigator.dart';

class FriendRequestsPage extends StatelessWidget {
  final logic = Get.find<FriendRequestsLogic>();

  FriendRequestsPage({super.key});

  List<FriendApplicationInfo> _getFilteredList() {
    final tab = logic.selectedTab.value;

    switch (tab) {
      case 'waiting':
        return logic.applicationList
            .where((item) => item.isWaitingHandle)
            .toList();
      case 'approved':
        return logic.applicationList.where((item) => item.isAgreed).toList();
      case 'rejected':
        return logic.applicationList.where((item) => item.isRejected).toList();
      default:
        return logic.applicationList;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Obx(() {
      // Count by status - now reactive to list changes
      final waitingCount =
          logic.applicationList.where((item) => item.isWaitingHandle).length;
      final approvedCount =
          logic.applicationList.where((item) => item.isAgreed).length;
      final rejectedCount =
          logic.applicationList.where((item) => item.isRejected).length;

      return GradientScaffold(
        title: StrRes.newFriend,
        subtitle:
            "${StrRes.waiting}: $waitingCount | ${StrRes.approved}: $approvedCount | ${StrRes.rejected}: $rejectedCount",
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
                  _buildTab('waiting', StrRes.waiting, primaryColor),
                  12.horizontalSpace,
                  _buildTab('approved', StrRes.approved, primaryColor),
                  12.horizontalSpace,
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
                    message: StrRes.noFriendRequests,
                    icon: Ionicons.people_outline,
                  );
                }

                return AnimationLimiter(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                    itemCount: filteredList.length,
                    itemBuilder: (_, index) =>
                        AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 400),
                      child: SlideAnimation(
                        verticalOffset: 30.0,
                        curve: Curves.easeOutCubic,
                        child: FadeInAnimation(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _buildItemView(
                              filteredList[index],
                              index,
                              primaryColor,
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
    });
  }

  Widget _buildTab(String value, String label, Color primaryColor) {
    return Expanded(
      child: Obx(
        () {
          final isSelected = logic.selectedTab.value == value;
          return GestureDetector(
            onTap: () => logic.selectedTab.value = value,
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
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color:
                          isSelected ? primaryColor : const Color(0xFF9CA3AF),
                    ),
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
        },
      ),
    );
  }

  Widget _buildItemView(
    FriendApplicationInfo info,
    int index,
    Color primaryColor,
  ) {
    final isISendRequest = info.fromUserID == OpenIM.iMManager.userID;
    String? name = isISendRequest ? info.toNickname : info.fromNickname;
    String? faceURL = isISendRequest ? info.toFaceURL : info.fromFaceURL;
    String? reason = info.reqMsg;

    // Format request time
    String timeStr = '';
    if (info.createTime != null) {
      timeStr = IMUtils.getChatTimeline(info.createTime!);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.06),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: avatar, name/time
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AvatarView(
                    width: 52.w,
                    height: 52.h,
                    url: faceURL,
                    text: name,
                    isCircle: true,
                    onTap: () {
                      AppNavigator.startUserProfilePane(
                        userID:
                            isISendRequest ? info.toUserID! : info.fromUserID!,
                        nickname: name,
                        faceURL: faceURL,
                      );
                    },
                  ),
                  16.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name ?? '',
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (timeStr.isNotEmpty) ...[
                          4.verticalSpace,
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              // Reason section (styled like group requests)
              if (IMUtils.isNotNullEmptyStr(reason)) ...[
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
                    '${StrRes.applyReason.replaceAll('%s', '')}: $reason',
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              // Action buttons row at bottom
              12.verticalSpace,
              _buildActionWidget(info, isISendRequest, primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionWidget(
    FriendApplicationInfo info,
    bool isISendRequest,
    Color primaryColor,
  ) {
    if (isISendRequest) {
      if (info.isWaitingHandle) {
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
                size: 16.sp,
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
      if (info.isWaitingHandle) {
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => logic.refuseFriendApplication(info),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: const Color(0xFFDC2626).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
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
            ),
            12.horizontalSpace,
            Expanded(
              child: GestureDetector(
                onTap: () => logic.acceptFriendApplication(info),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
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
                  alignment: Alignment.center,
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
            ),
          ],
        );
      }
    }

    // Status indicators - full width like reason section
    if (info.isRejected) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(12.r),
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
              size: 16.sp,
              color: const Color(0xFFDC2626),
            ),
            8.horizontalSpace,
            Text(
              StrRes.rejected,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      );
    }

    if (info.isAgreed) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(12.r),
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
              size: 16.sp,
              color: const Color(0xFF059669),
            ),
            8.horizontalSpace,
            Text(
              StrRes.approved,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF059669),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
