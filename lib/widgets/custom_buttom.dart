import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButtom extends StatefulWidget {
  final Function()? onPressed;
  final String? title;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final IconData? icon;
  final Color? colorButton;
  final Color? colorIcon;
  final int? badgeCount;
  final double? fontSize;

  const CustomButtom({
    super.key,
    this.onPressed,
    this.title,
    this.margin,
    this.padding,
    this.icon,
    this.colorButton,
    this.colorIcon,
    this.badgeCount,
    this.fontSize,
  });

  @override
  State<CustomButtom> createState() => _CustomButtomState();
}

class _CustomButtomState extends State<CustomButtom> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: widget.margin,
            padding: widget.padding ??
                EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 10.h,
                ),
            decoration: BoxDecoration(
              color: widget.colorButton ?? const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: IntrinsicWidth(
              child: widget.icon != null
                  ? Icon(
                      color: widget.colorIcon ?? const Color(0xFF757575),
                      widget.icon,
                      size: 16.w,
                    )
                  : Text(
                      widget.title ?? '',
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        color: widget.colorIcon ?? const Color(0xFF757575),
                        fontSize: widget.fontSize ?? 17.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
          if (widget.badgeCount != null && widget.badgeCount! > 0)
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
                    widget.badgeCount! > 99
                        ? '99+'
                        : widget.badgeCount.toString(),
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
  }
}
