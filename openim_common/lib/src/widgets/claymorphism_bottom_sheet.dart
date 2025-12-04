// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class ClaymorphismBottomSheet extends StatelessWidget {
  const ClaymorphismBottomSheet({
    super.key,
    required this.title,
    required this.items,
    this.icon,
    this.onCancel,
  });

  final String title;
  final List<ClaymorphismSheetItem> items;
  final IconData? icon;
  final Function()? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.08),
            offset: const Offset(0, -2),
            blurRadius: 12.r,
          ),
        ],
      ),
      child: SafeArea(
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

            20.verticalSpace,

            // Header with icon and title
            if (icon != null || title.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F42FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          icon!,
                          size: 20.w,
                          color: const Color(0xFF4F42FF),
                        ),
                      ),
                      16.horizontalSpace,
                    ],
                    Text(
                      title,
                      style: TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF374151
    ),
                      ),
                    ),
                  ],
                ),
              ),
              16.verticalSpace,
            ],

            // Section Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Options",
                  style: TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280
    ),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),

            // Options Container
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9CA3AF).withOpacity(0.06),
                    offset: const Offset(0, 2),
                    blurRadius: 6.r,
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFF3F4F6),
                  width: 1,
                ),
              ),
              child: AnimationLimiter(
                child: Column(
                  children: items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isLast = index == items.length - 1;

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 400),
                      child: SlideAnimation(
                        curve: Curves.easeOutCubic,
                        verticalOffset: 40.0,
                        child: FadeInAnimation(
                          child: _buildOptionItem(
                            item: item,
                            isLast: isLast,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            18.verticalSpace,

            // Cancel Button
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: InkWell(
                onTap: onCancel ?? () => Get.back(),
                borderRadius: BorderRadius.circular(16.r),
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9CA3AF).withOpacity(0.06),
                        offset: const Offset(0, 2),
                        blurRadius: 6.r,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFF3F4F6),
                      width: 1,
                    ),
                  ),
                  child: SizedBox(
                    height: 56.h,
                    child: Center(
                      child: Text(
                        StrRes.cancel,
                        style: TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280
    ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            24.verticalSpace,
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required ClaymorphismSheetItem item,
    required bool isLast,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Get.back();
          item.onTap?.call();
        },
        splashColor: const Color(0xFFF9FAFB),
        highlightColor: const Color(0xFFF9FAFB).withOpacity(0.5),
        borderRadius: BorderRadius.vertical(
          top: items.indexOf(item) == 0 ? Radius.circular(16.r) : Radius.zero,
          bottom: isLast ? Radius.circular(16.r) : Radius.zero,
        ),
        child: Container(
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            border: !isLast
                ? const Border(
                    bottom: BorderSide(
                      color: Color(0xFFF3F4F6),
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: item.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  item.icon,
                  size: 20.w,
                  color: item.iconColor,
                ),
              ),
              16.horizontalSpace,

              // Label
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF374151
    ),
                  ),
                ),
              ),

              // Arrow
              Icon(
                CupertinoIcons.chevron_right,
                size: 18.w,
                color: const Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClaymorphismSheetItem {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Function()? onTap;
  final dynamic result;

  ClaymorphismSheetItem({
    required this.label,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.result,
  });
}
