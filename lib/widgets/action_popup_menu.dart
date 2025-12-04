// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Model for popup menu item
class PopupMenuItem {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback onTap;

  PopupMenuItem({
    required this.icon,
    required this.text,
    this.iconColor,
    this.textColor,
    required this.onTap,
  });
}

/// Utility class to show action popup menu
class ActionPopupMenu {
  /// Shows a popup menu with custom items
  /// Positioned relative to the buttonKey widget
  static void show({
    required BuildContext context,
    required GlobalKey buttonKey,
    required List<PopupMenuItem> items,
    bool includeDividers = true,
    double menuWidth = 180,
  }) {
    final RenderBox renderBox =
        buttonKey.currentContext!.findRenderObject() as RenderBox;
    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              top: buttonPosition.dy + buttonSize.height + 8,
              right: MediaQuery.of(context).size.width -
                  buttonPosition.dx -
                  buttonSize.width,
              child: Material(
                color: Colors.transparent,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: FadeTransition(
                    opacity: animation,
                    child: Container(
                      width: menuWidth.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _buildMenuItems(context, items, includeDividers),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static List<Widget> _buildMenuItems(
    BuildContext context,
    List<PopupMenuItem> items,
    bool includeDividers,
  ) {
    final widgets = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      widgets.add(_buildMenuItem(context, items[i]));
      if (includeDividers && i < items.length - 1) {
        widgets.add(_buildMenuDivider());
      }
    }
    return widgets;
  }

  static Widget _buildMenuItem(BuildContext context, PopupMenuItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          item.onTap();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: (item.iconColor ?? const Color(0xFF374151))
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  item.icon,
                  size: 18.w,
                  color: item.iconColor ?? const Color(0xFF374151),
                ),
              ),
              12.horizontalSpace,
              Text(
                item.text,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  color: item.textColor ?? const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildMenuDivider() {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      color: const Color(0xFFF3F4F6),
    );
  }
}
