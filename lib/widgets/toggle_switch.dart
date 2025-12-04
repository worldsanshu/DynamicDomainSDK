// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Custom styled toggle switch
/// Used in settings pages for on/off options
class CustomToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final double width;
  final double height;
  final Duration animationDuration;

  const CustomToggleSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor = const Color(0xFF10B981),
    this.inactiveColor = const Color(0xFFE2E8F0),
    this.width = 52,
    this.height = 30,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    final thumbSize = height - 4;
    
    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: AnimatedContainer(
        duration: animationDuration,
        width: width.w,
        height: height.h,
        decoration: BoxDecoration(
          color: value ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular((height / 2).r),
        ),
        child: AnimatedAlign(
          duration: animationDuration,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: thumbSize.w,
            height: thumbSize.w,
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Toggle switch with label
class LabeledToggleSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? description;
  final Color activeColor;

  const LabeledToggleSwitch({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.description,
    this.activeColor = const Color(0xFF10B981),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontWeight: FontWeight.w500,
                  fontSize: 15.sp,
                  color: const Color(0xFF374151),
                ),
              ),
              if (description != null) ...[
                4.verticalSpace,
                Text(
                  description!,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ],
          ),
        ),
        CustomToggleSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: activeColor,
        ),
      ],
    );
  }
}

/// iOS-style segment control
class SegmentedControl<T> extends StatelessWidget {
  final List<T> items;
  final T selectedItem;
  final ValueChanged<T>? onChanged;
  final String Function(T item) labelBuilder;
  final Color selectedColor;
  final double borderRadius;

  const SegmentedControl({
    super.key,
    required this.items,
    required this.selectedItem,
    this.onChanged,
    required this.labelBuilder,
    this.selectedColor = const Color(0xFF2563EB),
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
      padding: EdgeInsets.all(2.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          final isSelected = item == selectedItem;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged?.call(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular((borderRadius - 2).r),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labelBuilder(item),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13.sp,
                    color: isSelected
                        ? selectedColor
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
