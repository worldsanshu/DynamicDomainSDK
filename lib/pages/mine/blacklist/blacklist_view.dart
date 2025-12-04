// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../widgets/base_page.dart';
import 'blacklist_logic.dart';

class BlacklistPage extends StatelessWidget {
  final logic = Get.find<BlacklistLogic>();

  BlacklistPage({super.key});

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
            StrRes.blacklist,
            style: const TextStyle(
              fontFamily: 'FilsonPro',
              fontWeight: FontWeight.w500,
              fontSize: 23,
              color: Colors.black,
            ).copyWith(fontSize: 23.sp),
          ),
          Text(
            StrRes.blockedContacts,
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
      child: Obx(() =>
          logic.blacklist.isEmpty ? _buildEmptyView() : _buildBlacklistView()),
    );
  }

  Widget _buildBlacklistView() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: EdgeInsets.only(top: 18.h, left: 16.w, right: 16.w),
        itemCount: logic.blacklist.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              curve: Curves.easeOutCubic,
              verticalOffset: 40.0,
              child: FadeInAnimation(
                child: _buildBlacklistItem(
                  logic.blacklist[index],
                  index: index,
                  isLast: index == logic.blacklist.length - 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBlacklistItem(
    BlacklistInfo info, {
    required int index,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 24.h : 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: const Offset(-1, -1),
            blurRadius: 4,
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            const Color(0xFFF8FAFC),
          ],
          stops: const [0.05, 0.3],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showRemoveDialog(info),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1.5.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9CA3AF).withOpacity(0.1),
                            blurRadius: 8.r,
                          ),
                        ],
                      ),
                      child: AvatarView(
                        url: info.faceURL,
                        text: info.nickname,
                        width: 68.w,
                        height: 68.h,
                        textStyle: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        isCircle: true,
                      ),
                    ),
                  ],
                ),
                16.horizontalSpace,

                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.nickname ?? '',
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      5.verticalSpace,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 0.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'ID: ${info.userID ?? ''}',
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Remove button
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF87171).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedDelete03,
                        color: const Color(0xFFF87171),
                        size: 16.w,
                      ),
                      6.horizontalSpace,
                      Text(
                        StrRes.remove,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFF87171),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return AnimationLimiter(
      child: Column(
        children: [
          Expanded(
            child: AnimationConfiguration.staggeredList(
              position: 0,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                curve: Curves.easeOutCubic,
                verticalOffset: 40.0,
                child: FadeInAnimation(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Empty illustration
                      Container(
                        width: 120.w,
                        height: 120.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(60.r),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 60.w,
                            height: 60.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B7280).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(2.w),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedUserBlock01,
                              size: 40.w,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),

                      24.verticalSpace,

                      // Empty message
                      Text(
                        StrRes.blacklistEmpty,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(BlacklistInfo info) {
    Get.dialog(
      barrierColor: Colors.transparent,
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9CA3AF).withOpacity(0.08),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
            border: Border.all(
              color: const Color(0xFFF3F4F6),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 70.w,
                height: 70.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF87171).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.all(5.w),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedUserBlock01,
                  size: 40.w,
                  color: const Color(0xFFF87171),
                ),
              ),

              20.verticalSpace,

              // Title
              Text(
                StrRes.removeFromBlacklist,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),

              12.verticalSpace,

              // Message
              Text(
                StrRes.confirmRemoveFromBlacklist
                    .replaceFirst('%s', info.nickname ?? ''),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),

              24.verticalSpace,

              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            StrRes.cancel,
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  16.horizontalSpace,

                  // Remove button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        logic.remove(info);
                      },
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF87171),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Center(
                          child: Text(
                            StrRes.remove,
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
