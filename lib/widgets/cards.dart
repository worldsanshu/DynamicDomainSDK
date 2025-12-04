// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A card with soft shadows and subtle gradient
/// Used for modern "neumorphic" style cards throughout the app
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final bool showGradient;
  final VoidCallback? onTap;

  const SoftCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius = 16,
    this.backgroundColor,
    this.showGradient = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: const Offset(-1, -1),
            blurRadius: 4,
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        gradient: showGradient
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.9),
                  const Color(0xFFF8FAFC),
                ],
              )
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// A card with standard shadow styling
/// Used for list items, content cards, etc.
class ContentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final bool showShadow;
  final bool showBorder;
  final VoidCallback? onTap;

  const ContentCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius = 16,
    this.backgroundColor,
    this.showShadow = true,
    this.showBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius.r),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.08),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ]
            : null,
        border: showBorder
            ? Border.all(color: const Color(0xFFF3F4F6))
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// Container with rounded top corners - used for main content area
class RoundedTopContainer extends StatelessWidget {
  final Widget child;
  final double topMargin;
  final double borderRadius;
  final Color? backgroundColor;
  final bool showShadow;

  const RoundedTopContainer({
    super.key,
    required this.child,
    this.topMargin = 0,
    this.borderRadius = 20,
    this.backgroundColor,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: topMargin.h),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius.r),
          topRight: Radius.circular(borderRadius.r),
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.08),
                  offset: const Offset(0, -4),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

/// Elevated card with prominent shadow
class ElevatedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const ElevatedCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius = 16,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
