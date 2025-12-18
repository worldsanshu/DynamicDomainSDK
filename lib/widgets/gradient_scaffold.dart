// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// A complete scaffold widget with gradient header and body
/// Unified component - no types, simple API
class GradientScaffold extends StatelessWidget {
  /// Main title text (required)
  final String title;

  /// Optional subtitle text
  final String? subtitle;

  /// Show back button (optional)
  final bool showBackButton;

  /// Back button callback (default: Get.back())
  final VoidCallback? onBack;

  /// Custom trailing widget on the right (optional)
  final Widget? trailing;

  /// Body content widget
  final Widget body;

  /// Whether body scrolls (wrap in SingleChildScrollView)
  final bool scrollable;

  /// Background color of body
  final Color bodyColor;

  /// Avatar widget to display overlapping header and body
  final Widget? avatar;

  /// Search box widget (overlapping between header and body)
  final Widget? searchBox;

  /// Fixed values for consistency
  static const double headerHeight = 175;
  static const double titleFontSize = 20;
  static const double subtitleFontSize = 14;
  static const double bodyTopMargin = 130;
  static const double bodyTopPadding = 30;

  const GradientScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.trailing,
    required this.body,
    this.scrollable = false,
    this.bodyColor = Colors.white,
    this.avatar,
    this.searchBox,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // Build the body content widget
    Widget bodyContent = scrollable
        ? Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: avatar != null ? 80.h : bodyTopPadding.h),
                  body,
                ],
              ),
            ),
          )
        : Expanded(
            child: Column(
              children: [
                SizedBox(height: avatar != null ? 80.h : bodyTopPadding.h),
                Expanded(child: body),
              ],
            ),
          );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 1. Header Background (Fixed)
          _buildHeader(primaryColor),

          // 2. Main Content Card
          Container(
            margin: EdgeInsets.only(
                top: searchBox != null
                    ? bodyTopMargin.h + 12.h
                    : bodyTopMargin.h),
            decoration: BoxDecoration(
              color: bodyColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
              child: Column(
                children: [
                  bodyContent,
                ],
              ),
            ),
          ),

          // 3. Avatar (Overlapping) - optional
          if (avatar != null)
            Positioned(
              top: 90.h,
              child: avatar!,
            ),

          // 4. Search Box (Overlapping) - optional
          if (searchBox != null)
            Positioned(
              top: (headerHeight - 75).h,
              left: 20.w,
              right: 20.w,
              child: searchBox!,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color primaryColor) {
    return Container(
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
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
              left: 20.w, right: 20.w, bottom: (headerHeight - 105).h),
          child: _buildHeaderContent(),
        ),
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Row(
      children: [
        // Back button (optional)
        if (showBackButton) ...[
          GestureDetector(
            onTap: onBack ?? () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(8.w),
              color: Colors.transparent,
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20.w,
              ),
            ),
          ),
          12.horizontalSpace,
        ],

        // Title + Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontWeight: FontWeight.w700,
                  fontSize: titleFontSize.sp,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontWeight: FontWeight.w500,
                    fontSize: subtitleFontSize.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Trailing (optional)
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Standard action button for header trailing
class HeaderActionButton extends StatelessWidget {
  final GlobalKey? buttonKey;
  final VoidCallback onTap;
  final IconData icon;

  const HeaderActionButton({
    super.key,
    this.buttonKey,
    required this.onTap,
    this.icon = Icons.grid_view,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: buttonKey,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20.w,
        ),
      ),
    );
  }
}

/// Standard search box widget for GradientScaffold
class GradientSearchBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  const GradientSearchBox({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          16.horizontalSpace,
          Icon(
            CupertinoIcons.search,
            size: 24.w,
            color: const Color(0xFF9CA3AF),
          ),
          12.horizontalSpace,
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF374151),
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9CA3AF),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
              onSubmitted: onSubmitted,
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onClear?.call();
              },
              child: Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Icon(
                  Icons.close,
                  size: 20.w,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
