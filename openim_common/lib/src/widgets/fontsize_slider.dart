// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class FontSizeSlider extends StatelessWidget {
  const FontSizeSlider({
    super.key,
    required this.value,
    this.onChanged,
  });
  final double value;
  final Function(dynamic value)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
        vertical: 24.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(3, 3),
            blurRadius: 8,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            offset: const Offset(-3, -3),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.4),
            offset: const Offset(0, 0),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.9),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          _buildIndicatorLabel(),
          20.verticalSpace,
          SfSliderTheme(
            data: SfSliderThemeData(
              activeTrackHeight: 6.h,
              inactiveTrackHeight: 6.h,
              activeTrackColor: const Color(0xFF3B82F6),
              inactiveTrackColor: const Color(0xFFE5E7EB),
              activeTickColor: const Color(0xFF3B82F6),
              inactiveTickColor: const Color(0xFFE5E7EB),
              activeMinorTickColor: const Color(0xFF3B82F6),
              inactiveMinorTickColor: const Color(0xFFE5E7EB),
              thumbColor: Colors.white,
              thumbRadius: 12.r,
              tickOffset: Offset(0, -16.h),
              overlayColor: const Color(0xFF3B82F6).withOpacity(0.1),
              overlayRadius: 20.r,
            ),
            child: SfSlider(
              min: 0.5,
              max: 2,
              value: value,
              interval: 1,
              showTicks: true,
              showLabels: false,
              labelFormatterCallback: (actualValue, formattedText) {
                return '打';
              },
              minorTicksPerInterval: 1,
              labelPlacement: LabelPlacement.onTicks,
              edgeLabelPlacement: EdgeLabelPlacement.inside,
              onChanged: onChanged,
            ),
          ),
          10.verticalSpace,
        ],
      ),
    );
  }

  Widget _buildIndicatorLabel() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => onChanged?.call(0.5),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: value == 0.5
                    ? const Color(0xFF3B82F6).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                StrRes.little,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: value == 0.5
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF374151),
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
          GestureDetector(
            onTap: () => onChanged?.call(1.25),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: value == 1.25
                    ? const Color(0xFF3B82F6).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                StrRes.standard,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: value == 1.25
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF374151),
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
          GestureDetector(
            onTap: () => onChanged?.call(2.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: value == 2.0
                    ? const Color(0xFF3B82F6).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                StrRes.big,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: value == 2.0
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF374151),
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
        ],
      );
}
