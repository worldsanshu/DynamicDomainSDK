// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A styled confirmation dialog
/// Used for delete confirmations, logout, etc.
class StyledConfirmDialog extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const StyledConfirmDialog({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  /// Show the dialog
  static Future<bool?> show({
    required BuildContext context,
    IconData? icon,
    Color? iconColor,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => StyledConfirmDialog(
        icon: icon,
        iconColor: iconColor,
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ??
        (isDestructive ? const Color(0xFFEF4444) : const Color(0xFFF59E0B));

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320.w,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 10),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (icon != null)
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32.w,
                  color: effectiveIconColor,
                ),
              ),
            if (icon != null) 20.verticalSpace,
            // Title
            Text(
              title,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
                color: const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            12.verticalSpace,
            // Message
            Text(
              message,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            24.verticalSpace,
            // Buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onCancel ?? () => Navigator.of(context).pop(false),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        cancelText,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                          color: const Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: GestureDetector(
                    onTap: onConfirm ?? () => Navigator.of(context).pop(true),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: isDestructive
                            ? const Color(0xFFEF4444)
                            : Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        confirmText,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Alert dialog with single action
class StyledAlertDialog extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onTap;

  const StyledAlertDialog({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    required this.message,
    this.buttonText = 'OK',
    this.onTap,
  });

  /// Show the dialog
  static Future<void> show({
    required BuildContext context,
    IconData? icon,
    Color? iconColor,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => StyledAlertDialog(
        icon: icon,
        iconColor: iconColor,
        title: title,
        message: message,
        buttonText: buttonText,
        onTap: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300.w,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 10),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (icon != null)
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: (iconColor ?? Theme.of(context).primaryColor)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32.w,
                  color: iconColor ?? Theme.of(context).primaryColor,
                ),
              ),
            if (icon != null) 20.verticalSpace,
            // Title
            Text(
              title,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
                color: const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            12.verticalSpace,
            // Message
            Text(
              message,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            24.verticalSpace,
            // Button
            GestureDetector(
              onTap: onTap ?? () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Input dialog for getting text input
class StyledInputDialog extends StatefulWidget {
  final String title;
  final String? message;
  final String? initialValue;
  final String? hintText;
  final String confirmText;
  final String cancelText;
  final int maxLines;
  final TextInputType keyboardType;

  const StyledInputDialog({
    super.key,
    required this.title,
    this.message,
    this.initialValue,
    this.hintText,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  /// Show the dialog
  static Future<String?> show({
    required BuildContext context,
    required String title,
    String? message,
    String? initialValue,
    String? hintText,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => StyledInputDialog(
        title: title,
        message: message,
        initialValue: initialValue,
        hintText: hintText,
        confirmText: confirmText,
        cancelText: cancelText,
        maxLines: maxLines,
        keyboardType: keyboardType,
      ),
    );
  }

  @override
  State<StyledInputDialog> createState() => _StyledInputDialogState();
}

class _StyledInputDialogState extends State<StyledInputDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320.w,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 10),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.title,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
                color: const Color(0xFF1F2937),
              ),
            ),
            if (widget.message != null) ...[
              8.verticalSpace,
              Text(
                widget.message!,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
            16.verticalSpace,
            // Input field
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextField(
                controller: _controller,
                maxLines: widget.maxLines,
                keyboardType: widget.keyboardType,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontWeight: FontWeight.w500,
                  fontSize: 15.sp,
                  color: const Color(0xFF374151),
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontWeight: FontWeight.w400,
                    fontSize: 15.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.w),
                ),
              ),
            ),
            24.verticalSpace,
            // Buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        widget.cancelText,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                          color: const Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(_controller.text),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        widget.confirmText,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
