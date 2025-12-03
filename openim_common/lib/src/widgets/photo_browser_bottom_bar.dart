import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openim_common/openim_common.dart';

enum OperateType {
  forward,
  save,
}

class PhotoBrowserBottomBar extends StatelessWidget {
  PhotoBrowserBottomBar({super.key, this.onPressedButton});
  ValueChanged<OperateType>? onPressedButton;

  PhotoBrowserBottomBar.show(BuildContext context,
      {super.key, ValueChanged<OperateType>? onPressedButton}) {
    showModalBottomSheet(
        barrierColor: Colors.transparent,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return PhotoBrowserBottomBar(
            onPressedButton: onPressedButton,
          );
        });
  }
  @override
  Widget build(BuildContext context) {
    return _buildBar(context);
  }

  Widget _buildBar(BuildContext context) {
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

              // Section Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    StrRes.options,
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              // Actions
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.symmetric(vertical: 16.h),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AnimationConfiguration.staggeredList(
                        position: 0,
                        duration: const Duration(milliseconds: 400),
                        child: SlideAnimation(
                          curve: Curves.easeOutCubic,
                          verticalOffset: 40.0,
                          child: FadeInAnimation(
                            child: _buildItem(
                              icon: Icons.forward_outlined,
                              title: StrRes.menuForward,
                              iconColor: const Color(0xFF4F42FF),
                              onPressed: () {
                                Navigator.of(context).pop();
                                onPressedButton?.call(OperateType.forward);
                              },
                            ),
                          ),
                        ),
                      ),
                      AnimationConfiguration.staggeredList(
                        position: 1,
                        duration: const Duration(milliseconds: 400),
                        child: SlideAnimation(
                          curve: Curves.easeOutCubic,
                          verticalOffset: 40.0,
                          child: FadeInAnimation(
                            child: _buildItem(
                              icon: Icons.save,
                              title: StrRes.save,
                              iconColor: const Color(0xFF34D399),
                              onPressed: () {
                                Navigator.of(context).pop();
                                onPressedButton?.call(OperateType.save);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              18.verticalSpace,

              // Cancel Button
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  width: MediaQuery.of(context).size.width / 3 + 4,
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

  Widget _buildItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 28.w,
                  color: iconColor,
                ),
              ),
            ),
            12.verticalSpace,
            Text(
              title,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
