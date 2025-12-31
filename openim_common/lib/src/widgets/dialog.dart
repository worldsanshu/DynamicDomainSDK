// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/cupertino.dart';

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
    this.primaryColor,
    this.icon,
    this.iconSize,
  });

  final String? title;
  final String? url; // URL hình ảnh minh họa (nếu có)
  final String? content;
  final String? rightText;
  final String? leftText;
  final bool showCancel;
  final bool scrollable;
  final Function()? onTapLeft;
  final Function()? onTapRight;
  final Color? primaryColor;
  final IconData? icon;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final btnColor = primaryColor ?? Theme.of(context).primaryColor;
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 1. Lớp nền mờ (Blur Background)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (showCancel) Get.back(result: false);
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(
                      0.25), // Làm tối nền một chút để nổi bật dialog
                ),
              ),
            ),
          ),

          // 2. Nội dung Dialog
          Center(
            child: AnimationConfiguration.synchronized(
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                curve: Curves.easeOutBack, // Hiệu ứng nảy nhẹ hiện đại hơn
                verticalOffset: 40.0,
                child: FadeInAnimation(
                  child: Container(
                    width: 320.w, // Tăng độ rộng một chút cho thoáng
                    margin: EdgeInsets.symmetric(horizontal: 24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(24.r), // Bo tròn mềm mại hơn
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF111827).withOpacity(0.15),
                          offset: const Offset(0, 10),
                          blurRadius: 30.r,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 24.h),

                        // --- Image / Icon Section ---
                        if (url != null && url!.isNotEmpty)
                          Container(
                            height: 80.h,
                            width: 80.w,
                            margin: EdgeInsets.only(bottom: 16.h),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: btnColor.withOpacity(0.1),
                              image: DecorationImage(
                                image: NetworkImage(url!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          // Icon mặc định nếu không có url
                          Container(
                            padding: EdgeInsets.all(16.r),
                            margin: EdgeInsets.only(bottom: 16.h),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: btnColor.withOpacity(0.08),
                            ),
                            child: Icon(
                              icon ?? CupertinoIcons.bell,
                              color: btnColor,
                              size: iconSize ?? 32.w,
                            ),
                          ),

                        // --- Title Section ---
                        if (title != null && title!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Text(
                              title!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1F2937),
                                height: 1.2,
                              ),
                            ),
                          ),

                        // --- Content Section ---
                        if (content != null && content!.isNotEmpty) ...[
                          SizedBox(height: 12.h),
                          scrollable
                              ? Container(
                                  constraints: BoxConstraints(maxHeight: 200.h),
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 20.w),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Text(
                                      content!,
                                      textAlign: TextAlign.center,
                                      style: _contentStyle(),
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.w),
                                  child: Text(
                                    content!,
                                    textAlign: TextAlign.center,
                                    style: _contentStyle(),
                                  ),
                                ),
                        ],

                        SizedBox(height: 32.h),

                        // --- Buttons Section ---
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                          child: Row(
                            children: [
                              if (showCancel) ...[
                                Expanded(
                                  child: _buildSecondaryButton(
                                    text: leftText ?? StrRes.cancel,
                                    onTap: onTapLeft ??
                                        () => Get.back(result: false),
                                  ),
                                ),
                                SizedBox(width: 12.w), // Khoảng cách giữa 2 nút
                              ],
                              Expanded(
                                child: _buildPrimaryButton(
                                  text: rightText ?? StrRes.agree,
                                  color: btnColor,
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
        ],
      ),
    );
  }

  TextStyle _contentStyle() {
    return TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 15.sp,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF6B7280),
      height: 1.5,
    );
  }

  // Nút chính (Filled)
  Widget _buildPrimaryButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 48.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Nút phụ (Outlined/Text)
  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 48.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6), // Màu nền xám nhẹ
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }
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
        child: Icon(
          isCancel ? CupertinoIcons.xmark : CupertinoIcons.paperplane,
          color: textColor,
          size: 20.w,
        ),
      ),
    );
  }
}
