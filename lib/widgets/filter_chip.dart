// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable animated filter chip widget
class AnimatedFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final Duration animationDuration;

  const AnimatedFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor = const Color(0xFF2563EB),
    this.unselectedColor = Colors.transparent,
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = const Color(0xFF6B7280),
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: animationDuration,
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? selectedColor : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'FilsonPro',
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            color: isSelected ? selectedTextColor : unselectedTextColor,
          ),
        ),
      ),
    );
  }
}

/// Filter chip with count badge
class FilterChipWithCount extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;

  const FilterChipWithCount({
    super.key,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.selectedColor = const Color(0xFF2563EB),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? selectedColor : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
            if (count > 0) ...[
              6.horizontalSpace,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                    color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
