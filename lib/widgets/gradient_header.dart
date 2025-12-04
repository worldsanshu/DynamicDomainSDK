// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable gradient header widget used across multiple pages
/// (ConversationPage, ContactsPage, GlobalSearchPage)
class GradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final double height;
  final bool showSafeArea;

  const GradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.height = 180,
    this.showSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      height: height.h,
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
      child: showSafeArea
          ? SafeArea(
              child: _buildContent(),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
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
              ),
              if (trailing != null) trailing!,
            ],
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
    );
  }
}

/// Header action button with white opacity background
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
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8.r),
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
