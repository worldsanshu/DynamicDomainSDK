// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        border: showBorder
            ? Border.all(color: const Color(0xFFF3F4F6))
            : null,
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
  final bool isWarning;
  final bool showDivider;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const SettingsMenuItem({
    super.key,
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
    this.showDivider = true,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: hasSwitch ? null : onTap,
          child: Padding(
            padding: padding ??
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                // Icon
                if (icon != null || iconWidget != null) ...[
                  iconWidget ??
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: color!=null ? color!.withOpacity(0.1)
                              : (isWarning
                                  ? const Color(0xFFEF4444).withOpacity(0.1)
                                  : const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          icon,
                          size: 20.w,
                          color: color ??
                              (isWarning
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF424242)),
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
                      color: isWarning
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF374151),
                    ),
                  ),
                ),
                // Value / Switch / Arrow
                if (hasSwitch && switchValue != null)
                  _buildSwitch()
                else ...[
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

  Widget _buildSwitch() {
    return GestureDetector(
      onTap: () => onSwitchChanged?.call(!(switchValue ?? false)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52.w,
        height: 30.h,
        decoration: BoxDecoration(
          color: switchValue == true
              ? const Color(0xFF1510F0)
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
