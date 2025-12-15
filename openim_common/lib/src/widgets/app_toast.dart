// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

enum ToastType { success, warning, error }

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

    // 3. Xác định Style
    Color color;
    IconData iconData;

    switch (type) {
      case ToastType.success:
        color = const Color(0xFF10B981);
        iconData = CupertinoIcons.checkmark_circle_fill;
        break;
      case ToastType.warning:
        color = const Color(0xFFF59E0B);
        iconData = CupertinoIcons.exclamationmark_triangle_fill;
        break;
      case ToastType.error:
        color = const Color(0xFFEF4444);
        iconData = CupertinoIcons.xmark_circle_fill;
        break;
    }

    // 4. Hiển thị Snackbar
    // Get.snackbar là hàm void nhưng vì ta đánh dấu hàm showToast là 'async',
   Get.snackbar(
  '',
  '',
  duration: duration ?? const Duration(milliseconds: 1750),
  snackPosition: SnackPosition.TOP,
  isDismissible: true,
  dismissDirection: DismissDirection.up,
  onTap: (snack) => Get.back(),
  backgroundColor: Colors.transparent, // để không bị đè màu
  margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
  padding: EdgeInsets.zero, // padding để container tự lo
  borderRadius: 12.r,
  snackStyle: SnackStyle.FLOATING,
  animationDuration: const Duration(milliseconds: 750),
  forwardAnimationCurve: Curves.easeOut,
  reverseAnimationCurve: Curves.easeIn,
  titleText: const SizedBox.shrink(),

  messageText: Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.75),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(
        color: color,
        width: 1.3,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        Icon(iconData, color: color, size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            msg,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  ),
);

}
}