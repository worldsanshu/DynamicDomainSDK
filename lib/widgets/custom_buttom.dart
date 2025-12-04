// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A customizable button widget that supports:
/// - Icon only button (circular)
/// - Text only button
/// - Icon with label below (action button style)
/// - Badge count indicator
class CustomButton extends StatelessWidget {
  final Function()? onTap;
  final String? title;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final IconData? icon;
  final Color? colorButton;
  final Color? colorIcon;
  final int? badgeCount;
  final double? fontSize;

  /// Optional label displayed below the button.
  /// When provided, creates an action button with icon above and label below.
  final String? label;

  /// Color for the label text. Defaults to Color(0xFF374151).
  final Color? labelColor;

  /// Whether to use primary color from theme for button and icon colors.
  /// Defaults to false.
  final bool usePrimaryColor;

  const CustomButton({
    super.key,
    this.onTap,
    this.title,
    this.margin,
    this.padding,
    this.icon,
    this.colorButton,
    this.colorIcon,
    this.badgeCount,
    this.fontSize,
    this.label,
    this.labelColor,
    this.usePrimaryColor = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    final effectiveButtonColor = colorButton ??
        (usePrimaryColor ? primaryColor.withOpacity(0.15) : const Color(0xFFF5F5F5));
    final effectiveIconColor = colorIcon ??
        (usePrimaryColor ? primaryColor : const Color(0xFF757575));
    final effectivePadding = padding ??
        (label != null
            ? EdgeInsets.all(16.w)
            : EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h));

    final button = GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: margin,
            padding: effectivePadding,
            decoration: BoxDecoration(
              color: effectiveButtonColor,
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: IntrinsicWidth(
              child: icon != null
                  ? Icon(
                      icon,
                      color: effectiveIconColor,
                      size: 16.w,
                    )
                  : Text(
                      title ?? '',
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        color: effectiveIconColor,
                        fontSize: fontSize ?? 17.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
          if (badgeCount != null && badgeCount! > 0)
            Positioned(
              top: -5.h,
              right: 0.w,
              child: Container(
                constraints: BoxConstraints(minWidth: 24.w, minHeight: 24.h),
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    badgeCount! > 99 ? '99+' : badgeCount.toString(),
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
      ),
    );

    // If label is provided, wrap button with Column to show label below
    if (label != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          button,
          8.verticalSpace,
          Text(
            label!,
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: labelColor ?? const Color(0xFF374151),
            ),
          ),
        ],
      );
    }

    return button;
  }
}
