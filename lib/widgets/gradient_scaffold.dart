// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// A complete scaffold widget with gradient header and body
/// Unified component - no types, simple API
class GradientScaffold extends StatelessWidget {
  /// Main title text (required if titleWidget is null)
  final String? title;

  /// Custom widget to replace title/subtitle text (optional)
  final Widget? titleWidget;

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

  /// Font sizes
  static const double titleFontSize = 24;
  static const double subtitleFontSize = 14;

  const GradientScaffold({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.trailing,
    required this.body,
    this.scrollable = false,
    this.bodyColor = Colors.white,
    this.avatar,
    this.searchBox,
  }) : assert(title != null || titleWidget != null,
            'Either title or titleWidget must be provided');

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final topPadding = MediaQuery.of(context).padding.top;

    // Calculate layout metrics based on content presence
    // 1. Determine where the text content logically ends
    double contentEnd = topPadding + 30.h; // Base: StatusBar + Title + Padding
    if (subtitle != null && subtitle!.isNotEmpty) {
      contentEnd += 24.h; // Add space for subtitle
    }else if(showBackButton && (avatar == null && searchBox == null)){
      contentEnd += 16.h; // Add space for subtitle
    }else if(showBackButton && (avatar == null && searchBox != null)){
      contentEnd += 16.h; // Add space for subtitle
    }

    // 2. Determine where the white card should start (Body Top Margin)
    double bodyMargin = contentEnd + 20.h; // Default gap

    // If we have overlapping elements (SearchBox or Avatar), we need to adjust
    // where the card starts so the element overlaps correctly.
    // Usually we want the element to be centered on the card edge or slightly above.
    if (searchBox != null) {
      // SearchBox (height ~56)
      // We want the text to be visible above the searchbox.
      // SearchBox Top should be `contentEnd +gap`
      // Body Margin should be `SearchBox Top + 28` (halfway)
      bodyMargin = contentEnd + 50;
    } else if (avatar != null) {
      // Avatar (height ~80)
      // Avatar Top should be below text? Or aligned with text?
      // Usually for "Mine" page, Avatar is centered and overlaps the edge.
      // Let's place Body Margin well below content to give room.
      bodyMargin = contentEnd + 60.h;
    }

    // 3. Header Background Height
    // Needs to be comfortably taller than bodyMargin to ensure no gaps behind the curve
    double headerHeight = bodyMargin + 50.h;

    // 4. Overpass Element Positioning
    double? searchBoxTop;
    double? avatarTop;

    if (searchBox != null) {
      // Place SearchBox centered on the Body Margin line
      // SearchBox Height is 56.h
      searchBoxTop = bodyMargin - 40.h;
    }

    if (avatar != null) {
      // Place Avatar centered on the Body Margin line
      // Avatar Height is 80.h
      avatarTop = bodyMargin - 40.h;
    }

    // 5. Body Padding
    double bodyTopPadding = 15.h; // Default
    if (searchBox != null) {
      bodyTopPadding = 30.h; // Space for the bottom half of searchbox + gap
    } else if (avatar != null) {
      bodyTopPadding = 75.h; // Space for bottom half of avatar + gap
    }

    // Build Body Content
    Widget bodyContent = scrollable
        ? Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: bodyTopPadding),
                        body,
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        : Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: bodyTopPadding),
                Expanded(child: body),
              ],
            ),
          );

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 1. Header Background (Fixed)
          // Uses calculated headerHeight
          Container(
            height: headerHeight,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: topPadding),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Align to top
                    children: [
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
                        8.horizontalSpace,
                      ],
                      Expanded(
                        child: titleWidget ??
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title!,
                                  style: TextStyle(
                                    fontFamily: 'FilsonPro',
                                    fontWeight: FontWeight.w700,
                                    fontSize: titleFontSize.sp,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (subtitle != null &&
                                    subtitle!.isNotEmpty) ...[
                                  4.verticalSpace,
                                  Text(
                                    subtitle!,
                                    style: TextStyle(
                                      fontFamily: 'FilsonPro',
                                      fontWeight: FontWeight.w500,
                                      fontSize: subtitleFontSize.sp,
                                      color: Colors.white.withOpacity(0.85),
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                      ),
                      if (trailing != null) trailing!,
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Main Content Card
          Container(
            margin: EdgeInsets.only(top: bodyMargin),
            decoration: BoxDecoration(
              color: bodyColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10.r,
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

          // 3. Avatar (Overlapping)
          if (avatar != null && avatarTop != null)
            Positioned(
              top: avatarTop,
              child: avatar!,
            ),

          // 4. Search Box (Overlapping)
          if (searchBox != null && searchBoxTop != null)
            Positioned(
              top: searchBoxTop,
              left: 20.w,
              right: 20.w,
              child: searchBox!,
            ),
        ],
      ),
    );
  }
}

