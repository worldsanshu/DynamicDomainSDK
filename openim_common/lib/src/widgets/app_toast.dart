// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

enum ToastType { success, warning, error, info }

class AppToast {
  AppToast._();

  /// Hàm hiển thị Toast - Trả về Future để tương thích code cũ
  static Future<void> showToast(
    String msg, {
    ToastType type = ToastType.error, // Mặc định ERROR
    Duration? duration,
  }) async {
    // 1. Kiểm tra chuỗi rỗng
    if (msg.trim().isEmpty) return;

    // 2. Chặn spam: Nếu đang có thông báo thì return luôn (hoàn thành Future ngay lập tức)
    if (Get.isSnackbarOpen) return;

    // 3. Xác định Style (Màu chính & Màu nền & Icon)
    Color mainColor;
    Color bgColor;
    IconData iconData;

    switch (type) {
      case ToastType.success:
        mainColor = const Color(0xFF10B981); // Green
        bgColor = const Color(0xFFECFDF5);
        iconData = CupertinoIcons.checkmark_circle_fill;
        break;
      case ToastType.warning:
        mainColor = const Color(0xFFF59E0B); // Amber / Yellow
        bgColor = const Color(0xFFFFFBEB);
        iconData = CupertinoIcons.exclamationmark_triangle_fill;
        break;
      case ToastType.error:
        mainColor = const Color(0xFFEF4444); // Red
        bgColor = const Color(0xFFFEF2F2);
        iconData = CupertinoIcons.xmark_circle_fill;
        break;
      case ToastType.info:
        mainColor = const Color(0xFF3B82F6); // Blue
        bgColor = const Color(0xFFEFF6FF);
        iconData = CupertinoIcons.info_circle_fill;
        break;
    }

    // 4. Hiển thị Snackbar
    Get.snackbar(
      '',
      '',
      duration: duration ?? const Duration(milliseconds: 1750),
      snackPosition: SnackPosition.TOP,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      onTap: (_) => Get.back(), // Restore tap to dismiss
      backgroundColor: Colors.transparent,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      padding: EdgeInsets.zero,
      borderRadius: 12.r,
      snackStyle: SnackStyle.FLOATING,
      animationDuration: const Duration(milliseconds: 750),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      titleText: const SizedBox.shrink(),
      messageText: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: mainColor.withOpacity(0.3), // Viền nhạt hơn màu chính chút
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Icon(
              iconData,
              color: mainColor,
              size: 24.w, // Chuẩn hóa size icon
            ),
            12.horizontalSpace,

            // Message Content
            Expanded(
              child: Text(
                msg,
                style: TextStyle(
                  fontFamily: 'FilsonPro', // Dùng font của app nếu có
                  fontSize: 15.sp, // Tăng font size xíu cho dễ đọc
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2937), // Màu chữ tối (Gray 800)
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Close Button
            8.horizontalSpace,
            GestureDetector(
              onTap: () => Get.closeCurrentSnackbar(),
              behavior: HitTestBehavior.opaque, // Tăng vùng bấm
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(
                  CupertinoIcons.xmark,
                  color: const Color(0xFF6B7280), // Gray 500
                  size: 18.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
