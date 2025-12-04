// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hugeicons/hugeicons.dart';

enum DialogType {
  confirm,
}

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    this.title,
    this.url,
    this.content,
    this.rightText,
    this.leftText,
    this.showCancel = true,
    this.scrollable = false,
    this.onTapLeft,
    this.onTapRight,
  });
  final String? title;
  final String? url;
  final String? content;
  final String? rightText;
  final String? leftText;
  final bool showCancel;
  final bool scrollable;
  final Function()? onTapLeft;
  final Function()? onTapRight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Center(
            child: AnimationConfiguration.synchronized(
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                curve: Curves.easeOutCubic,
                verticalOffset: 40.0,
                child: FadeInAnimation(
                  child: Container(
                    width: 300.w,
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9CA3AF).withOpacity(0.08),
                          offset: const Offset(0, 2),
                          blurRadius: 12.r,
                          spreadRadius: 0,
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFF3F4F6),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header section
                          Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 16.h,
                            ),
                            child: Column(
                              children: [
                                if (title != null && title!.isNotEmpty)
                                  Text(
                                    title!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'FilsonPro',
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF374151),
                                    ),
                                  ),
                                if (title != null &&
                                    title!.isNotEmpty &&
                                    content != null &&
                                    content!.isNotEmpty)
                                  SizedBox(height: 16.h),
                                if (content != null &&
                                    content!.isNotEmpty &&
                                    !scrollable)
                                  Text(
                                    content!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'FilsonPro',
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF6B7280),
                                      height: 1.5,
                                    ),
                                  ),
                                if (content != null &&
                                    content!.isNotEmpty &&
                                    scrollable)
                                  Container(
                                    constraints:
                                        BoxConstraints(maxHeight: 280.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                        width: 1,
                                      ),
                                    ),
                                    margin: EdgeInsets.only(top: 12.h),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 16.h,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Text(
                                        content!,
                                        style: TextStyle(
                                          fontFamily: 'FilsonPro',
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF6B7280),
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Buttons section
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Color(0xFFF0F4F8),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                if (showCancel)
                                  Expanded(
                                    child: _actionButton(
                                      text: leftText ?? StrRes.cancel,
                                      textColor: const Color(0xFF6B7280),
                                      isLeft: true,
                                      onTap: onTapLeft ??
                                          () => Get.back(result: false),
                                    ),
                                  ),
                                if (showCancel)
                                  Container(
                                    width: 1.w,
                                    height: 56.h,
                                    color: const Color(0xFFF0F4F8),
                                  ),
                                Expanded(
                                  child: _actionButton(
                                    text: rightText ?? StrRes.determine,
                                    textColor: const Color(0xFF4F42FF),
                                    isLeft: false,
                                    onTap: onTapRight ??
                                        () => Get.back(result: true),
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required Color textColor,
    required bool isLeft,
    Function()? onTap,
  }) =>
      InkWell(
        onTap: onTap,
        child: Container(
          height: 56.h,
          width: 56.w,
          alignment: Alignment.center,
          child: HugeIcon(
            icon: isLeft
                ? HugeIcons.strokeRoundedCancel01
                : HugeIcons.strokeRoundedCheckmarkCircle02,
            color: textColor,
            size: 24.w,
          ),
        ),
      );
}

class ForwardHintDialog extends StatelessWidget {
  const ForwardHintDialog({
    super.key,
    required this.title,
    this.checkedList = const [],
    this.controller,
  });
  final String title;
  final List<dynamic> checkedList;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final list = IMUtils.convertCheckedListToForwardObj(checkedList);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Center(
            child: AnimationConfiguration.synchronized(
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                curve: Curves.easeOutCubic,
                verticalOffset: 40.0,
                child: FadeInAnimation(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      margin: EdgeInsets.symmetric(horizontal: 5.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9CA3AF).withOpacity(0.08),
                            offset: const Offset(0, 2),
                            blurRadius: 12.r,
                            spreadRadius: 0,
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFF3F4F6),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            list.length == 1
                                ? StrRes.sentTo
                                : StrRes.sentSeparatelyTo,
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF374151),
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Recipients section
                          list.length == 1
                              ? Row(
                                  children: [
                                    // Avatar
                                    AvatarView(
                                      url: list.first['faceURL'],
                                      text: list.first['nickname'],
                                      isCircle: true,
                                      width: 68.w,
                                      height: 68.w,
                                      isGroup: list.first['groupID'] != '' &&
                                          list.first['groupID'] != null,
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: Text(
                                        list.first['nickname'] ?? '',
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
                                  ],
                                )
                              : ConstrainedBox(
                                  constraints: BoxConstraints(maxHeight: 280.h),
                                  child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 5,
                                      crossAxisSpacing: 12.w,
                                      mainAxisSpacing: 12.h,
                                      childAspectRatio: 50.w / 75.h,
                                    ),
                                    itemCount: list.length,
                                    shrinkWrap: true,
                                    itemBuilder: (_, index) =>
                                        AnimationConfiguration.staggeredGrid(
                                      position: index,
                                      duration:
                                          const Duration(milliseconds: 400),
                                      columnCount: 5,
                                      child: ScaleAnimation(
                                        child: FadeInAnimation(
                                          child: Column(
                                            children: [
                                              // Avatar
                                              Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color:
                                                        const Color(0xFFE5E7EB),
                                                    width: 1.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                              0xFF9CA3AF)
                                                          .withOpacity(0.1),
                                                      offset:
                                                          const Offset(0, 2),
                                                      blurRadius: 8.r,
                                                    ),
                                                  ],
                                                ),
                                                child: AvatarView(
                                                  url: list.elementAt(
                                                      index)['faceURL'],
                                                  text: list.elementAt(
                                                      index)['nickname'],
                                                  isCircle: true,
                                                  width: 46.w,
                                                  height: 46.w,
                                                  isGroup:
                                                      list.elementAt(index)[
                                                                  'groupID'] !=
                                                              '' &&
                                                          list.elementAt(index)[
                                                                  'groupID'] !=
                                                              null,
                                                ),
                                              ),
                                              SizedBox(height: 6.h),
                                              Text(
                                                list.elementAt(
                                                        index)['nickname'] ??
                                                    '',
                                                style: TextStyle(
                                                  fontFamily: 'FilsonPro',
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      const Color(0xFF6B7280),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                          SizedBox(height: 18.h),

                          // Section title
                          Text(
                            title,
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B7280),
                              letterSpacing: 0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: 16.h),

                          // Message input
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF9CA3AF).withOpacity(0.06),
                                  offset: const Offset(0, 2),
                                  blurRadius: 6.r,
                                ),
                              ],
                              border: Border.all(
                                color: const Color(0xFFF3F4F6),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF374151),
                              ),
                              controller: controller,
                              maxLines: 3,
                              minLines: 1,
                              decoration: InputDecoration(
                                hintText: StrRes.leaveMessage,
                                hintStyle: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF9CA3AF),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 14.h,
                                ),
                                isDense: true,
                              ),
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _actionButton(
                                text: StrRes.cancel,
                                textColor: const Color(0xFF6B7280),
                                onTap: () => Get.back(),
                                isCancel: true,
                              ),
                              SizedBox(width: 16.w),
                              _actionButton(
                                text: StrRes.determine,
                                textColor: const Color(0xFF4F42FF),
                                onTap: () => Get.back(result: true),
                                isCancel: false,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required Color textColor,
    required VoidCallback onTap,
    required bool isCancel,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30.w,
        height: 30.w,
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
          border: Border.all(
            color: const Color(0xFFF3F4F6),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(5.w),
        child: HugeIcon(
          icon: isCancel
              ? HugeIcons.strokeRoundedCancel01
              : HugeIcons.strokeRoundedSent,
          color: textColor,
          size: 20.w,
        ),
      ),
    );
  }
}
