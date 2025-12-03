import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import '../../../routes/app_navigator.dart';
import 'group_requests_logic.dart';
import '../../../widgets/base_page.dart';

class GroupRequestsPage extends StatelessWidget {
  final logic = Get.find<GroupRequestsLogic>();

  GroupRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      title: StrRes.groupJoinRequests,
      centerTitle: false,
      showLeading: true,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9CA3AF).withOpacity(0.08),
              offset: const Offset(0, 0),
              blurRadius: 12,
            ),
          ],
        ),
        child: Obx(() {
          if (logic.list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9CA3AF).withOpacity(0.07),
                          offset: const Offset(0, 3),
                          blurRadius: 8,
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Ionicons.people_outline,
                        size: 60.w,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  24.verticalSpace,
                  Text(
                    StrRes.noGroupRequests,
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            );
          }

          return AnimationLimiter(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 24.h, bottom: 30.h),
              itemCount: logic.list.length,
              itemBuilder: (_, index) => AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 400),
                child: SlideAnimation(
                  verticalOffset: 40.0,
                  curve: Curves.easeOutCubic,
                  child: FadeInAnimation(
                    child: _buildItemView(logic.list[index], index),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildItemView(GroupApplicationInfo info, int index) {
    final isISendRequest = info.userID == OpenIM.iMManager.userID;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.06),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF3F4F6),
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
          child: Row(
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar with Cute Minimalist style
                        Expanded(
                          child: Text(
                            info.nickname ?? '',
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
                        16.horizontalSpace,
                        _buildActionWidget(info, isISendRequest),
                      ],
                    ),
                    8.verticalSpace,
                    // Action description (apply join or invite)
                    _buildActionDescription(info),

                    // Application reason (if available)
                    if (null != IMUtils.emptyStrToNull(info.reqMsg)) ...[
                      8.verticalSpace,
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA78BFA).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: const Color(0xFFA78BFA).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          sprintf(StrRes.applyReason, [info.reqMsg!]),
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFA78BFA),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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

  Widget _buildActionDescription(GroupApplicationInfo info) {
    if (!logic.isInvite(info)) {
      // Apply join case
      return RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: StrRes.applyJoin,
              style: const TextStyle(
                  fontFamily: 'FilsonPro',
                  color: Color(
                    0xFF6B7280,
                  )),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: logic.getGroupName(info),
              style: const TextStyle(
                fontFamily: 'FilsonPro',
                color: Color(
                  0xFF4F42FF,
                ),
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
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: logic.getInviterNickname(info),
              style: const TextStyle(
                fontFamily: 'FilsonPro',
                color: Color(
                  0xFF34D399,
                ),
                fontWeight: FontWeight.w600,
              ),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: StrRes.invite,
              style: const TextStyle(
                  fontFamily: 'FilsonPro',
                  color: Color(
                    0xFF6B7280,
                  )),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: info.nickname,
              style: const TextStyle(
                fontFamily: 'FilsonPro',
                color: Color(
                  0xFF4F42FF,
                ),
                fontWeight: FontWeight.w600,
              ),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: StrRes.joinIn,
              style: const TextStyle(
                  fontFamily: 'FilsonPro',
                  color: Color(
                    0xFF6B7280,
                  )),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: logic.getGroupName(info),
              style: const TextStyle(
                fontFamily: 'FilsonPro',
                color: Color(
                  0xFFF9A8D4,
                ),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildActionWidget(GroupApplicationInfo info, bool isISendRequest) {
    if (isISendRequest) {
      if (info.handleResult == 0) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42.w,
              height: 42.h,
              decoration: BoxDecoration(
                color: const Color(0xFF4F42FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Ionicons.people_outline,
                size: 20.w,
                color: const Color(0xFF4F42FF),
              ),
            ),
            8.horizontalSpace,
            Text(
              StrRes.waitingForVerification,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        );
      }
    } else {
      if (info.handleResult == 0) {
        return GestureDetector(
          onTap: () => logic.handle(info),
          child: Container(
            height: 30.h,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: const Color(0xFF34D399),
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF34D399).withOpacity(0.2),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Center(
              child: Text(
                StrRes.lookOver,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      }
    }

    // Status indicators
    if (info.handleResult == -1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30.w,
            height: 30.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF87171).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Ionicons.close_circle_outline,
              size: 18.w,
              color: const Color(0xFFF87171),
            ),
          ),
          8.horizontalSpace,
          Text(
            StrRes.rejected,
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFF87171),
            ),
          ),
        ],
      );
    }

    if (info.handleResult == 1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30.w,
            height: 30.h,
            decoration: BoxDecoration(
              color: const Color(0xFF34D399).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Ionicons.checkmark_circle_outline,
              size: 18.w,
              color: const Color(0xFF34D399),
            ),
          ),
          5.horizontalSpace,
          Text(
            StrRes.approved,
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF34D399),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
