// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatTimelineView extends StatelessWidget {
  const ChatTimelineView({
    super.key,
    required this.timeStr,
    this.margin,
  });
  final String timeStr;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(vertical: 8.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 199, 201, 204),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                offset: const Offset(2, 2),
                blurRadius: 6,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.9),
                offset: const Offset(-2, -2),
                blurRadius: 6,
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 1,
            ),
          ),
          child: Text(
            timeStr,
            style: TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 12.sp,
              //fontWeight: FontWeight.w500,
              color: const Color.fromARGB(255, 255, 255, 255
    ),
              shadows: [
                Shadow(
                  color: Colors.white.withOpacity(0.9),
                  offset: const Offset(0.5, 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
