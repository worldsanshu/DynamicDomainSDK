// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A scaffold for profile pages with gradient header and overlapping avatar
/// Used in mine_view, user_profile, group_profile, etc.
class ProfilePageScaffold extends StatelessWidget {
  final Widget avatar;
  final String? title;
  final String? subtitle;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget body;
  final double headerHeight;
  final double avatarOverlap;
  final Color? backgroundColor;
  final VoidCallback? onBack;
  final bool showBackButton;
  final Widget? floatingActionButton;

  const ProfilePageScaffold({
    super.key,
    required this.avatar,
    this.title,
    this.subtitle,
    this.titleWidget,
    this.actions,
    required this.body,
    this.headerHeight = 180,
    this.avatarOverlap = 50,
    this.backgroundColor,
    this.onBack,
    this.showBackButton = true,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor ?? primaryColor,
      floatingActionButton: floatingActionButton,
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showBackButton)
                      IconButton(
                        onPressed:
                            onBack ?? () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 22.w,
                        ),
                      )
                    else
                      SizedBox(width: 48.w),
                    if (actions != null) ...actions!,
                  ],
                ),
              ),
            ),
          ),
          // Main Content Card
          Container(
            margin: EdgeInsets.only(top: headerHeight.h - avatarOverlap.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30.r),
              ),
            ),
            child: Column(
              children: [
                // Space for avatar overlap
                SizedBox(height: avatarOverlap.h + 20.h),
                // Title and subtitle
                if (titleWidget != null)
                  titleWidget!
                else if (title != null)
                  Column(
                    children: [
                      Text(
                        title!,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                          color: const Color(0xFF374151),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (subtitle != null) ...[
                        4.verticalSpace,
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                16.verticalSpace,
                // Body content
                Expanded(child: body),
              ],
            ),
          ),
          // Overlapping Avatar
          Positioned(
            top: headerHeight.h - avatarOverlap.h - avatarOverlap.h,
            left: 0,
            right: 0,
            child: Center(child: avatar),
          ),
        ],
      ),
    );
  }
}

/// Profile avatar with optional edit button
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final VoidCallback? onEdit;
  final bool showEditButton;
  final String? fallbackText;
  final Widget? placeholder;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.size = 100,
    this.onEdit,
    this.showEditButton = false,
    this.fallbackText,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size.w,
          height: size.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 4.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: ClipOval(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildFallback(),
                  )
                : _buildFallback(),
          ),
        ),
        if (showEditButton)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.w,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 16.w,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFallback() {
    if (placeholder != null) return placeholder!;
    return Container(
      color: const Color(0xFFF3F4F6),
      child: Center(
        child: Text(
          fallbackText?.isNotEmpty == true
              ? fallbackText![0].toUpperCase()
              : '?',
          style: TextStyle(
            fontFamily: 'FilsonPro',
            fontWeight: FontWeight.w600,
            fontSize: (size * 0.4).sp,
            color: const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

/// Action buttons row for profile pages
class ProfileActionButtons extends StatelessWidget {
  final List<ProfileActionItem> items;
  final MainAxisAlignment alignment;

  const ProfileActionButtons({
    super.key,
    required this.items,
    this.alignment = MainAxisAlignment.spaceEvenly,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: items.map((item) => _buildActionButton(context, item)).toList(),
    );
  }

  Widget _buildActionButton(BuildContext context, ProfileActionItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: (item.color ?? Theme.of(context).primaryColor)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              item.icon,
              size: 24.w,
              color: item.color ?? Theme.of(context).primaryColor,
            ),
          ),
          8.verticalSpace,
          Text(
            item.label,
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

/// Model for profile action button
class ProfileActionItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  ProfileActionItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
  });
}
