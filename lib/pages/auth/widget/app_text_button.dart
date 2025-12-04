// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextButton extends StatelessWidget {
  final double? borderRadius;
  final Color? backgroundColor;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? buttonWidth;
  final double? buttonHeight;
  final String buttonText;
  final TextStyle textStyle;
  final VoidCallback onPressed;

  const AppTextButton(
      {super.key,
      this.borderRadius,
      this.backgroundColor,
      this.horizontalPadding,
      this.verticalPadding,
      this.buttonWidth,
      this.buttonHeight,
      required this.buttonText,
      required this.textStyle,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: buttonWidth?.w ?? double.maxFinite,
      height: buttonHeight?.h ?? 52.h,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF3B82F6),
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.25),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius ?? 16),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding?.w ?? 12.w,
              vertical: verticalPadding?.h ?? 14.h,
            ),
            child: Center(
              child: Text(
                buttonText,
                style: textStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
