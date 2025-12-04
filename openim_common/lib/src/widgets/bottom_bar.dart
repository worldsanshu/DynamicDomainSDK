// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:openim_common/openim_common.dart';
import '../res/styles/app_colors.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    this.index = 0,
    required this.items,
  });
  final int index;
  final List<BottomBarItem> items;

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.synchronized(
      duration: const Duration(milliseconds: 400),
      child: SlideAnimation(
        verticalOffset: 40.0,
        curve: Curves.easeOutCubic,
        child: FadeInAnimation(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.appBarEnd,
                  AppColors.appBarEnd,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textDisabled.withOpacity(0.15),
                  offset: const Offset(0, -4),
                  blurRadius: 16.r,
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 8.h,
                // bottom: MediaQuery.of(context).padding.bottom + 8.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  items.length,
                  (index) => _buildItemView(
                    i: index,
                    item: items.elementAt(index),
                  ),
                ).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemView({required int i, required BottomBarItem item}) =>
      Expanded(
        child: GestureDetector(
          onDoubleTap: () => item.onDoubleClick?.call(i),
          behavior: HitTestBehavior.translucent,
          onTap: () => item.onClick?.call(i),
          child: AnimationConfiguration.synchronized(
            duration: const Duration(milliseconds: 400),
            child: ScaleAnimation(
              curve: Curves.easeOutCubic,
              child: FadeInAnimation(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 32.w,
                            height: 32.h,
                            decoration: BoxDecoration(
                              color: i == index
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Center(
                              child: _buildIcon(item, i),
                            ),
                          ),
                          if ((item.count ?? 0) > 0)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Transform.translate(
                                offset: const Offset(4, -2),
                                child: UnreadCountView(
                                  count: item.count ?? 0,
                                  size: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                      2.verticalSpace,
                      Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: i == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildIcon(BottomBarItem item, int i) {
    // If iconData is provided, use CupertinoIcons as required by the guide
    if (item.iconData != null) {
      return Icon(
        item.iconData!,
        size: 18.w,
        color: i == index ? Colors.white : Colors.white.withOpacity(0.6),
      );
    }

    // Otherwise, use image icons (backward compatibility)
    return (i == index
        ? item.selectedImgRes!.toImage
        : item.unselectedImgRes!.toImage)
      ..width = 16.w
      ..height = 16.h
      ..color = i == index ? Colors.white : Colors.white.withOpacity(0.6);
  }
}

class BottomBarItem {
  final String? selectedImgRes;
  final String? unselectedImgRes;
  final IconData? iconData;
  final String label;
  final TextStyle? selectedStyle;
  final TextStyle? unselectedStyle;
  final double imgWidth;
  final double imgHeight;
  final Function(int index)? onClick;
  final Function(int index)? onDoubleClick;
  final Stream<int>? steam;
  final int? count;

  BottomBarItem({
    this.selectedImgRes,
    this.unselectedImgRes,
    this.iconData,
    required this.label,
    this.selectedStyle,
    this.unselectedStyle,
    required this.imgWidth,
    required this.imgHeight,
    this.onClick,
    this.onDoubleClick,
    this.steam,
    this.count,
  }) : assert(
          (selectedImgRes != null && unselectedImgRes != null) ||
              iconData != null,
          'Either provide both selectedImgRes and unselectedImgRes, or provide iconData',
        );
}
