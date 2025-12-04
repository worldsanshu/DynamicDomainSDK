// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

/// App color constants extracted from the codebase
/// These colors are used consistently across the app for unified styling
class AppColors {
  AppColors._();

  // ============================================
  // Background Colors
  // ============================================
  
  /// Main background gray - used for page backgrounds
  static const Color backgroundGray = Color(0xFFF9FAFB);
  
  /// Card/container white background
  static const Color cardWhite = Color(0xFFFFFFFF);
  
  /// Light gray background for inputs, chips, etc.
  static const Color inputBackground = Color(0xFFF3F4F6);
  
  /// Slightly darker background
  static const Color surfaceGray = Color(0xFFF8FAFC);

  // ============================================
  // Text Colors
  // ============================================
  
  /// Primary dark text - headings, important text
  static const Color textPrimary = Color(0xFF374151);
  
  /// Darker text - for emphasis
  static const Color textDark = Color(0xFF1F2937);
  
  /// Secondary text - labels, descriptions
  static const Color textSecondary = Color(0xFF6B7280);
  
  /// Muted/placeholder text
  static const Color textMuted = Color(0xFF9CA3AF);
  
  /// Light gray text
  static const Color textLighter = Color(0xFFBDBDBD);
  
  /// Icon default color
  static const Color iconDefault = Color(0xFF424242);

  // ============================================
  // Border & Divider Colors
  // ============================================
  
  /// Light divider/border color
  static const Color dividerColor = Color(0xFFF3F4F6);
  
  /// Border color for cards/inputs
  static const Color borderColor = Color(0xFFE5E7EB);
  
  /// Slightly darker border
  static const Color borderDark = Color(0xFFD1D5DB);

  // ============================================
  // Accent/Brand Colors
  // ============================================
  
  /// Primary blue - main brand color
  static const Color primaryBlue = Color(0xFF3B82F6);
  
  /// Darker blue - selected states
  static const Color selectedBlue = Color(0xFF2563EB);
  
  /// Light blue - backgrounds, highlights
  static const Color lightBlue = Color(0xFF4A90E2);
  
  /// Accent purple
  static const Color accentPurple = Color(0xFF4F42FF);

  // ============================================
  // Semantic Colors
  // ============================================
  
  /// Success green
  static const Color successGreen = Color(0xFF10B981);
  
  /// Error/danger red
  static const Color errorRed = Color(0xFFEF4444);
  
  /// Warning yellow
  static const Color warningYellow = Color(0xFFFBBF24);
  
  /// Warning orange
  static const Color warningOrange = Color(0xFFF59E0B);
  
  /// Info blue
  static const Color infoBlue = Color(0xFF3B82F6);

  // ============================================
  // Switch/Toggle Colors
  // ============================================
  
  /// Active toggle color
  static const Color toggleActive = Color(0xFF10B981);
  
  /// Inactive toggle color
  static const Color toggleInactive = Color(0xFFE2E8F0);

  // ============================================
  // Badge Colors
  // ============================================
  
  /// Badge/notification red
  static const Color badgeRed = Color(0xFFEF4444);
  
  /// Online status green
  static const Color onlineGreen = Color(0xFF22C55E);

  // ============================================
  // Shadow Colors
  // ============================================
  
  /// Standard shadow color
  static Color shadowColor = const Color(0xFF9CA3AF).withOpacity(0.08);
  
  /// Light shadow color
  static Color shadowLight = const Color(0xFF9CA3AF).withOpacity(0.06);
  
  /// Dark shadow color
  static Color shadowDark = Colors.black.withOpacity(0.12);

  // ============================================
  // Gradient Colors
  // ============================================
  
  /// Primary gradient colors (header backgrounds)
  static List<Color> primaryGradient(Color primaryColor) => [
        primaryColor.withOpacity(0.7),
        primaryColor,
        primaryColor.withOpacity(0.9),
      ];
}

/// Common box shadow styles
class AppShadows {
  AppShadows._();

  /// Soft subtle shadow
  static BoxShadow get soft => BoxShadow(
        color: const Color(0xFF9CA3AF).withOpacity(0.06),
        offset: const Offset(0, 2),
        blurRadius: 6,
      );

  /// Standard card shadow
  static BoxShadow get card => BoxShadow(
        color: const Color(0xFF9CA3AF).withOpacity(0.08),
        offset: const Offset(0, 4),
        blurRadius: 12,
      );

  /// Elevated shadow
  static List<BoxShadow> get elevated => [
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
      ];

  /// Neumorphic soft shadows
  static List<BoxShadow> get neumorphic => [
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
      ];
}
