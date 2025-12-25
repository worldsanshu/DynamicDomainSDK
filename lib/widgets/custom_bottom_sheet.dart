// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'custom_buttom.dart';

/// A reusable custom bottom sheet widget with consistent styling
///
/// Features:
/// - Backdrop blur effect
/// - Handle bar for drag indication
/// - Optional icon with gradient background
/// - Customizable title with primary color
/// - Flexible body content
/// - Optional confirm and cancel buttons
class CustomBottomSheet {
  /// Shows a custom bottom sheet with the specified configuration
  static Future<T?> show<T>({
    String? title,
    IconData? icon,
    required Widget body,
    VoidCallback? onConfirm,
    String? confirmText,
    bool showCancelButton = false,
    VoidCallback? onCancel,
    String? cancelText,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return Get.bottomSheet<T>(
      barrierColor: Colors.transparent,
      Stack(
        children: [
          // Backdrop blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Bottom sheet content
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32.r),
                topRight: Radius.circular(32.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.08),
                  offset: const Offset(0, -3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),

                // Title Section
                if (title != null && title.isNotEmpty) ...[
                  Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: Row(
                      children: [
                        if (icon != null) ...[
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Get.theme.primaryColor.withOpacity(0.1),
                                  Get.theme.primaryColor.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              icon,
                              size: 24.w,
                              color: Get.theme.primaryColor,
                            ),
                          ),
                          12.horizontalSpace,
                        ],
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: Get.theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Body content
                body,

                // Buttons section
                if (onConfirm != null || showCancelButton) ...[
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: _buildButtons(
                      onConfirm: onConfirm,
                      confirmText: confirmText,
                      showCancelButton: showCancelButton,
                      onCancel: onCancel,
                      cancelText: cancelText,
                    ),
                  ),
                ],

                SizedBox(height: 30.h),
              ],
            ),
          ),
        ],
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }

  static Widget _buildButtons({
    VoidCallback? onConfirm,
    String? confirmText,
    bool showCancelButton = false,
    VoidCallback? onCancel,
    String? cancelText,
  }) {
    if (showCancelButton && onConfirm != null) {
      // Both cancel and confirm buttons
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              onTap: onCancel ?? () => Get.back(),
              title: cancelText ?? StrRes.cancel,
              color: Colors.blueGrey,
              expand: true,
            ),
          ),
          16.horizontalSpace,
          Expanded(
            child: CustomButton(
              onTap: onConfirm,
              title: confirmText ?? StrRes.confirm,
              color: Get.theme.primaryColor,
              expand: true,
            ),
          ),
        ],
      );
    } else if (onConfirm != null) {
      // Only confirm button - centered
      return Center(
        child: SizedBox(
          width: 150.w,
          child: CustomButton(
            onTap: onConfirm,
            title: confirmText ?? StrRes.confirm,
            color: Get.theme.primaryColor,
            expand: true,
          ),
        ),
      );
    } else {
      // Only cancel button - centered
      return Center(
        child: SizedBox(
          width: 150.w,
          child: CustomButton(
            onTap: onCancel ?? () => Get.back(),
            title: cancelText ?? StrRes.cancel,
            color: Colors.blueGrey,
            expand: true,
          ),
        ),
      );
    }
  }
}
