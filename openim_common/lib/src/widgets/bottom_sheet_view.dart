import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:openim_common/src/res/styles/app_colors.dart';

class BottomSheetView extends StatelessWidget {
  const BottomSheetView({
    super.key,
    required this.items,
    this.itemHeight,
    this.textStyle,
    this.mainAxisAlignment,
    this.isOverlaySheet = false,
    this.onCancel,
  });
  final List<SheetItem> items;
  final double? itemHeight;
  final TextStyle? textStyle;
  final MainAxisAlignment? mainAxisAlignment;
  final bool isOverlaySheet;
  final Function()? onCancel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
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
                    mainAxisSize: MainAxisSize.min,
                    children: items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 400),
                        child: SlideAnimation(
                          curve: Curves.easeOutCubic,
                          verticalOffset: 40.0,
                          child: FadeInAnimation(
                            child: _parseItem(item, context),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              18.verticalSpace,

              GestureDetector(
                onTap: isOverlaySheet ? onCancel : () => Get.back(),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  width: Get.width / 3 + 4,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(50),
                      left: Radius.circular(50),
                    ),
                  ),
                  child: Text(StrRes.cancel,
                      style: const TextStyle(
                          fontFamily: 'FilsonPro',
                          fontWeight: FontWeight.w500)),
                ),
              ),

              24.verticalSpace,
            ],
          ),
        ),
      ],
    );
  }

  Widget _parseItem(SheetItem item, BuildContext context) {
    BorderRadius borderRadius;
    int length = items.length;
    bool isLast = items.indexOf(item) == items.length - 1;
    bool isFirst = items.indexOf(item) == 0;
    if (length == 1) {
      borderRadius = BorderRadius.circular(16.r);
    } else {
      borderRadius = BorderRadius.vertical(
        top: isFirst ? Radius.circular(16.r) : Radius.zero,
        bottom: isLast ? Radius.circular(16.r) : Radius.zero,
      );
    }
    return _itemBgView(
        label: item.label,
        textStyle: item.textStyle,
        icon: item.icon,
        alignment: item.alignment,
        line: !isLast,
        borderRadius: borderRadius,
        customIcon: item.customIcon,
        onTap: () {
          if (!isOverlaySheet) {
            Navigator.pop(
                context, item.result); //Get.back(result: item.result);
          }

          item.onTap?.call();
        });
  }

  Widget _itemBgView({
    required String label,
    String? icon,
    Function()? onTap,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
    MainAxisAlignment? alignment,
    bool line = false,
    IconData? customIcon,
  }) =>
      Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          splashColor: const Color(0xFFF9FAFB),
          highlightColor: const Color(0xFFF9FAFB).withOpacity(0.5),
          child: Container(
            decoration: line
                ? const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFF3F4F6),
                        width: 1,
                      ),
                    ),
                  )
                : null,
            height: itemHeight ?? 56.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              mainAxisAlignment:
                  alignment ?? mainAxisAlignment ?? MainAxisAlignment.start,
              children: [
                if (null != customIcon) ...[
                  Icon(
                    customIcon,
                    size: 20.w,
                    color: AppColors.iconColor,
                  ),
                  16.horizontalSpace,
                ],
                if (null != icon) ...[
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F42FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Image.asset(
                        icon,
                        width: 20.w,
                        height: 20.h,
                        color: const Color(0xFF4F42FF),
                      ),
                    ),
                  ),
                  16.horizontalSpace,
                ],
                Text(
                  label,
                  style: textStyle ??
                      TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF374151),
                      ),
                ),
              ],
            ),
          ),
        ),
      );
}

class SheetItem {
  final String label;
  final TextStyle? textStyle;
  final String? icon;
  final Function()? onTap;
  final BorderRadius? borderRadius;
  final MainAxisAlignment? alignment;
  final dynamic result;
  final IconData? customIcon;

  SheetItem({
    required this.label,
    this.textStyle,
    this.icon,
    this.onTap,
    this.borderRadius,
    this.alignment,
    this.result,
    this.customIcon,
  });
}
