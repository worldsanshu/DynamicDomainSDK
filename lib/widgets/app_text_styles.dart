// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// App text styles using FilsonPro font family
/// These styles are used consistently across the app
class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'FilsonPro';

  // ============================================
  // Heading Styles
  // ============================================

  /// Large heading - page titles
  static TextStyle get heading1 => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 24.sp,
        color: const Color(0xFF1F2937),
      );

  /// Medium heading - section titles
  static TextStyle get heading2 => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 20.sp,
        color: const Color(0xFF1F2937),
      );

  /// Small heading - card titles
  static TextStyle get heading3 => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 18.sp,
        color: const Color(0xFF374151),
      );

  // ============================================
  // Body Styles
  // ============================================

  /// Standard body text
  static TextStyle get body => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 16.sp,
        color: const Color(0xFF374151),
      );

  /// Body text - medium weight
  static TextStyle get bodyMedium => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 15.sp,
        color: const Color(0xFF374151),
      );

  /// Body text - regular weight
  static TextStyle get bodyRegular => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 15.sp,
        color: const Color(0xFF374151),
      );

  // ============================================
  // Subtitle/Caption Styles
  // ============================================

  /// Subtitle text
  static TextStyle get subtitle => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14.sp,
        color: const Color(0xFF6B7280),
      );

  /// Caption text - small descriptions
  static TextStyle get caption => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 12.sp,
        color: const Color(0xFF9CA3AF),
      );

  /// Label text - form labels, section headers
  static TextStyle get label => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
        color: const Color(0xFF9CA3AF),
      );

  // ============================================
  // Button Styles
  // ============================================

  /// Primary button text
  static TextStyle get buttonPrimary => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 15.sp,
        color: Colors.white,
      );

  /// Secondary button text
  static TextStyle get buttonSecondary => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 15.sp,
        color: const Color(0xFF6B7280),
      );

  /// Small button text
  static TextStyle get buttonSmall => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 13.sp,
        color: Colors.white,
      );

  // ============================================
  // Input Styles
  // ============================================

  /// Input field text
  static TextStyle get input => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 15.sp,
        color: const Color(0xFF374151),
      );

  /// Input hint text
  static TextStyle get inputHint => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 15.sp,
        color: const Color(0xFF9CA3AF),
      );

  // ============================================
  // List Item Styles
  // ============================================

  /// List item title
  static TextStyle get listTitle => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 15.sp,
        color: const Color(0xFF374151),
      );

  /// List item subtitle
  static TextStyle get listSubtitle => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 13.sp,
        color: const Color(0xFF9CA3AF),
      );

  // ============================================
  // Tab Styles
  // ============================================

  /// Selected tab text
  static TextStyle get tabSelected => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
        color: const Color(0xFF2563EB),
      );

  /// Unselected tab text
  static TextStyle get tabUnselected => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14.sp,
        color: const Color(0xFF6B7280),
      );

  // ============================================
  // Badge/Count Styles
  // ============================================

  /// Badge text
  static TextStyle get badge => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 10.sp,
        color: Colors.white,
      );

  /// Small badge text
  static TextStyle get badgeSmall => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 9.sp,
        color: Colors.white,
      );

  // ============================================
  // Special Styles
  // ============================================

  /// White text for dark backgrounds
  static TextStyle get white => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14.sp,
        color: Colors.white,
      );

  /// White heading for dark backgrounds
  static TextStyle get whiteHeading => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 24.sp,
        color: Colors.white,
      );

  /// White subtitle for dark backgrounds
  static TextStyle get whiteSubtitle => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14.sp,
        color: Colors.white.withOpacity(0.8),
      );

  /// Error/warning text
  static TextStyle get error => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14.sp,
        color: const Color(0xFFEF4444),
      );

  /// Link text
  static TextStyle get link => TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14.sp,
        color: const Color(0xFF3B82F6),
      );

  // ============================================
  // Helper Methods
  // ============================================

  /// Create a custom text style with FilsonPro font
  static TextStyle custom({
    FontWeight fontWeight = FontWeight.w500,
    double fontSize = 14,
    Color color = const Color(0xFF374151),
    double? height,
    TextDecoration? decoration,
  }) =>
      TextStyle(
        fontFamily: _fontFamily,
        fontWeight: fontWeight,
        fontSize: fontSize.sp,
        color: color,
        height: height,
        decoration: decoration,
      );
}
