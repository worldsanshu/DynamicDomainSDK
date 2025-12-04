import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable section title widget
/// Used to label sections in settings, lists, and other grouped content
class SectionTitle extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final Widget? trailing;
  final Color? color;

  const SectionTitle({
    super.key,
    required this.title,
    this.padding,
    this.style,
    this.trailing,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
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
      trailing: GestureDetector(
        onTap: onActionTap,
        child: Text(
          actionText,
          style: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
