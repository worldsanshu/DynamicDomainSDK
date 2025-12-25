// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'custom_bottom_sheet.dart';

/// A reusable bottom sheet for adjusting chat font size.
/// Call `FontSizeBottomSheet.show()` to display it.
class FontSizeBottomSheet {
  FontSizeBottomSheet._();

  static void show({
    required Function(double factor) onSave,
  }) {
    final factor = DataSp.getChatFontSizeFactor().obs;
    final primaryColor = Theme.of(Get.context!).primaryColor;

    CustomBottomSheet.show(
      title: StrRes.fontSize,
      icon: CupertinoIcons.textformat_size,
      showCancelButton: true,
      confirmText: StrRes.save,
      onConfirm: () {
        Get.back();
        onSave(factor.value);
      },
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Preview Section
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Received message
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          CupertinoIcons.person_fill,
                          size: 18.w,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      8.horizontalSpace,
                      Container(
                        constraints: BoxConstraints(maxWidth: 200.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Obx(() => Text(
                              'Xin chào! 👋',
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1F2937),
                              ),
                              textScaleFactor: factor.value,
                            )),
                      ),
                    ],
                  ),
                ),

                12.verticalSpace,

                // Sent message
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: 200.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor.withOpacity(0.85),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Obx(() => Text(
                              'Cũng chào bạn!',
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                              textScaleFactor: factor.value,
                            )),
                      ),
                      8.horizontalSpace,
                      AvatarView(
                        width: 32.w,
                        height: 32.w,
                        text: OpenIM.iMManager.userInfo.nickname,
                        url: OpenIM.iMManager.userInfo.faceURL,
                        isCircle: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          16.verticalSpace,

          // Slider Section
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: const Color(0xFFF3F4F6),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Size labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'A',
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                    Obx(() => Text(
                          '${(factor.value * 100).round()}%',
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        )),
                    Text(
                      'A',
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),

                8.verticalSpace,

                // Slider
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6.h,
                    activeTrackColor: primaryColor,
                    inactiveTrackColor: const Color(0xFFF3F4F6),
                    thumbColor: primaryColor,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.r),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 18.r),
                    overlayColor: primaryColor.withOpacity(0.15),
                  ),
                  child: Obx(() => Slider(
                        value: factor.value,
                        min: 0.8,
                        max: 1.4,
                        divisions: 6,
                        onChanged: (value) => factor.value = value,
                      )),
                ),

                4.verticalSpace,

                // Quick select buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickButton('Nhỏ', 0.85, factor, primaryColor),
                    _buildQuickButton('Mặc định', 1.0, factor, primaryColor),
                    _buildQuickButton('Lớn', 1.2, factor, primaryColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildQuickButton(
    String label,
    double value,
    RxDouble factor,
    Color primaryColor,
  ) {
    return Obx(() {
      final isSelected = (factor.value - value).abs() < 0.05;
      return GestureDetector(
        onTap: () => factor.value = value,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color:
                isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isSelected ? primaryColor : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? primaryColor : const Color(0xFF6B7280),
            ),
          ),
        ),
      );
    });
  }
}
