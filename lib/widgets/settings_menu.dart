// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// A section container for grouping settings menu items
/// Used in mine_view, about_view, blacklist_view, account_settings, etc.
class SettingsMenuSection extends StatelessWidget {
  final List<Widget> items;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool showBorder;

  const SettingsMenuSection({
    super.key,
    required this.items,
    this.margin,
    this.borderRadius = 16,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.06),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
        border: showBorder ? Border.all(color: const Color(0xFFF3F4F6)) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items,
        ),
      ),
    );
  }
}

/// A single settings menu item
/// Supports icon, label, value, switch, and navigation arrow
class SettingsMenuItem extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String label;
  final String? value;
  final Widget? valueWidget;
  final VoidCallback? onTap;
  final bool showArrow;
  final bool hasSwitch;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final bool isWarning; // Amber color for warnings
  final bool isDestroy; // Red color for destructive actions
  final bool showDivider;
  final EdgeInsetsGeometry? padding;
  final bool isRow;

  // Colors
  static const Color _warningColor = Color(0xFFF59E0B); // Amber
  static const Color _destroyColor = Color(0xFFEF4444); // Red
  static const Color _defaultIconColor = Color(0xFF424242); // Dark gray
  static const Color _defaultTextColor = Color(0xFF374151); // Gray
  static const Color _defaultBgColor = Color(0xFFF3F4F6); // Light gray

  const SettingsMenuItem(
      {super.key,
      this.icon,
      this.iconWidget,
      required this.label,
      this.value,
      this.valueWidget,
      this.onTap,
      this.showArrow = true,
      this.hasSwitch = false,
      this.switchValue,
      this.onSwitchChanged,
      this.isWarning = false,
      this.isDestroy = false,
      this.showDivider = true,
      this.padding,
      this.isRow = true});

  Color get _iconColor {
    if (isDestroy) return _destroyColor;
    if (isWarning) return _warningColor;
    return _defaultIconColor;
  }

  Color get _iconBgColor {
    if (isDestroy) return _destroyColor.withOpacity(0.1);
    if (isWarning) return _warningColor.withOpacity(0.1);
    return _defaultBgColor;
  }

  Color get _textColor {
    if (isDestroy) return _destroyColor;
    if (isWarning) return _warningColor;
    return _defaultTextColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: hasSwitch ? null : onTap,
            child: Padding(
              padding: padding ??
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: isRow ? _buildRowLayout() : _buildColumnLayout(),
            ),
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            margin: EdgeInsets.only(
              left: (icon != null || iconWidget != null) ? 64.w : 16.w,
              right: 16.w,
            ),
            color: const Color(0xFFF3F4F6),
          ),
      ],
    );
  }

  Widget _buildRowLayout() {
    return Row(
      children: [
        // Icon
        if (icon != null || iconWidget != null) ...[
          iconWidget ??
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: _iconBgColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  size: 20.w,
                  color: _iconColor,
                ),
              ),
          12.horizontalSpace,
        ],
        // Label
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontWeight: FontWeight.w500,
              fontSize: 15.sp,
              color: _textColor,
            ),
          ),
        ),
        // Value / Switch / Arrow
        if (hasSwitch && switchValue != null)
          _buildSwitch()
        else ...[
          if (value != null)
            Container(
              constraints: BoxConstraints(maxWidth: 0.4.sw),
              child: Text(
                value!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  color: const Color(0xFF9CA3AF),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          if (valueWidget != null) valueWidget!,
          if (showArrow && !hasSwitch) ...[
            8.horizontalSpace,
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.w,
              color: const Color(0xFF9CA3AF),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildColumnLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon
        if (icon != null || iconWidget != null) ...[
          iconWidget ??
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: _iconBgColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  size: 20.w,
                  color: _iconColor,
                ),
              ),
          12.horizontalSpace,
        ],

        // Label + value (giữ cùng cột)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontWeight: FontWeight.w500,
                  fontSize: 15.sp,
                  color: _textColor,
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
            ],
          ),
        ),

        // Toggle / arrow
        if (hasSwitch && switchValue != null)
          _buildSwitch()
        else ...[
          if (valueWidget != null) valueWidget!,
          if (showArrow && !hasSwitch) ...[
            8.horizontalSpace,
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.w,
              color: const Color(0xFF9CA3AF),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildSwitch() {
    return GestureDetector(
      onTap: () => onSwitchChanged?.call(!(switchValue ?? false)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52.w,
        height: 30.h,
        decoration: BoxDecoration(
          color: switchValue == true
              ? Theme.of(Get.context!).primaryColor
              : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: switchValue == true
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            width: 26.w,
            height: 26.w,
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Settings menu item with badge/count
class SettingsMenuItemWithBadge extends StatelessWidget {
  final IconData? icon;
  final String label;
  final int badgeCount;
  final VoidCallback? onTap;
  final bool showDivider;
  final Color badgeColor;

  const SettingsMenuItemWithBadge({
    super.key,
    this.icon,
    required this.label,
    this.badgeCount = 0,
    this.onTap,
    this.showDivider = true,
    this.badgeColor = const Color(0xFFEF4444),
  });

  @override
  Widget build(BuildContext context) {
    return SettingsMenuItem(
      icon: icon,
      label: label,
      onTap: onTap,
      showDivider: showDivider,
      valueWidget: badgeCount > 0
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontWeight: FontWeight.w600,
                  fontSize: 11.sp,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}
