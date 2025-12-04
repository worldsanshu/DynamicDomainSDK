// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Base scaffold with gradient header and main content card
/// This is the main layout pattern used across multiple pages
class GradientScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? headerTrailing;
  final Widget content;
  final Widget? headerContent;
  final double headerHeight;
  final double contentTopMargin;
  final double contentBorderRadius;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const GradientScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.headerTrailing,
    required this.content,
    this.headerContent,
    this.headerHeight = 180,
    this.contentTopMargin = 100,
    this.contentBorderRadius = 30,
    this.backgroundColor,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor ?? primaryColor,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Stack(
        children: [
          // Gradient Header Background
          Container(
            height: headerHeight.h,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.7),
                  primaryColor,
                  primaryColor.withOpacity(0.9),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24.sp,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (subtitle != null) ...[
                                4.verticalSpace,
                                Text(
                                  subtitle!,
                                  style: TextStyle(
                                    fontFamily: 'FilsonPro',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.sp,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (headerTrailing != null) headerTrailing!,
                      ],
                    ),
                  ),
                  if (headerContent != null) headerContent!,
                ],
              ),
            ),
          ),
          // Main Content Card
          Container(
            margin: EdgeInsets.only(top: contentTopMargin.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(contentBorderRadius.r),
              ),
            ),
            child: content,
          ),
        ],
      ),
    );
  }
}

/// A variation with back button for detail/search pages
class GradientScaffoldWithBack extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? headerTrailing;
  final Widget content;
  final Widget? headerContent;
  final double headerHeight;
  final double contentTopMargin;
  final double contentBorderRadius;
  final Color? backgroundColor;
  final VoidCallback? onBack;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const GradientScaffoldWithBack({
    super.key,
    required this.title,
    this.subtitle,
    this.headerTrailing,
    required this.content,
    this.headerContent,
    this.headerHeight = 180,
    this.contentTopMargin = 100,
    this.contentBorderRadius = 30,
    this.backgroundColor,
    this.onBack,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor ?? primaryColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Stack(
        children: [
          // Gradient Header Background
          Container(
            height: headerHeight.h,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.7),
                  primaryColor,
                  primaryColor.withOpacity(0.9),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                    child: Row(
                      children: [
                        // Back button
                        IconButton(
                          onPressed:
                              onBack ?? () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 22.w,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24.sp,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (subtitle != null) ...[
                                4.verticalSpace,
                                Text(
                                  subtitle!,
                                  style: TextStyle(
                                    fontFamily: 'FilsonPro',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.sp,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (headerTrailing != null) ...[
                          12.horizontalSpace,
                          headerTrailing!,
                        ],
                      ],
                    ),
                  ),
                  if (headerContent != null) headerContent!,
                ],
              ),
            ),
          ),
          // Main Content Card
          Container(
            margin: EdgeInsets.only(top: contentTopMargin.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(contentBorderRadius.r),
              ),
            ),
            child: content,
          ),
        ],
      ),
    );
  }
}
