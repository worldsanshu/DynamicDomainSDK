// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim/widgets/custom_buttom.dart';

/// A reusable section title widget
/// Used to label sections in settings, lists, and other grouped content
class SectionTitle extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final Widget? trailing;
  final Color? color;
  final IconData? icon;

  const SectionTitle({
    super.key,
    required this.title,
    this.padding,
    this.style,
    this.trailing,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // If icon is provided, use row layout with icon container
    if (icon != null) {
      return Padding(
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: (color ?? const Color(0xFF9CA3AF)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                size: 22.w,
                color: color ?? const Color(0xFF9CA3AF),
              ),
            ),
            10.horizontalSpace,
            Expanded(
              child: Text(
                title,
                style: style ??
                    TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151),
                    ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
    }

    // Default layout without icon
    return Container(
      width: double.infinity,
      padding: padding ??
          EdgeInsets.only(left: 24.w, right: 24.w, top: 24.h, bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: style ??
                TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: color ?? const Color(0xFF9CA3AF),
                ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Section title with "See All" action
class SectionTitleWithAction extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? onActionTap;
  final EdgeInsetsGeometry? padding;

  const SectionTitleWithAction({
    super.key,
    required this.title,
    this.actionText = 'See All',
    this.onActionTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SectionTitle(
      title: title,
      padding: padding,
      trailing: CustomButton(
        title: actionText,
        onTap: onActionTap,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
