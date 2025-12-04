// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum BubbleType {
  send,
  receiver,
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    this.margin,
    this.constraints,
    this.alignment = Alignment.center,
    this.backgroundColor,
    this.child,
    required this.bubbleType,
  });
  final EdgeInsetsGeometry? margin;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final Color? backgroundColor;
  final Widget? child;
  final BubbleType bubbleType;

  bool get isISend => bubbleType == BubbleType.send;

  BorderRadius get _cuteMinimalistBorderRadius {
    if (isISend) {
      return BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
          bottomLeft: Radius.circular(20.r),
          bottomRight: const Radius.circular(10));
    } else {
      return BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
          bottomLeft: Radius.circular(10.r),
          bottomRight: const Radius.circular(20));
    }
  }

  // Cute Minimalist colors
  Color get _bubbleColor {
    if (backgroundColor != null) return backgroundColor!;

    if (isISend) {
      return const Color(0xFF4F42FF); // Blue for sent messages
    } else {
      return const Color(0xFFF9FAFB); // Light background for received messages
    }
  }

  List<BoxShadow> get _cuteMinimalistShadows {
    if (isISend) {
      return [
        BoxShadow(
          color: const Color(0xFF9CA3AF).withOpacity(0.1),
          offset: const Offset(0, 2),
          blurRadius: 6,
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: const Color(0xFF9CA3AF).withOpacity(0.08),
          offset: const Offset(0, 1),
          blurRadius: 4,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        constraints: constraints,
        margin: margin,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        alignment: alignment,
        decoration: BoxDecoration(
          color: _bubbleColor,
          borderRadius: _cuteMinimalistBorderRadius,
          boxShadow: _cuteMinimalistShadows,
          border: isISend
              ? null
              : Border.all(
                  color: const Color(0xFFF3F4F6),
                  width: 1,
                ),
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: isISend ? Colors.white : const Color(0xFF374151),
          ),
          child: child ?? const SizedBox(),
        ),
      );
}
