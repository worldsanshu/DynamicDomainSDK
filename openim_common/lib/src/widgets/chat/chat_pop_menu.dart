import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class MenuInfo {
  String icon;
  String text;
  Function()? onTap;
  bool enabled;

  MenuInfo({
    required this.icon,
    required this.text,
    this.onTap,
    this.enabled = true,
  });
}

class ChatLongPressMenu extends StatelessWidget {
  final CustomPopupMenuController? popupMenuController;
  final List<MenuInfo> menus;

  const ChatLongPressMenu({
    super.key,
    required this.popupMenuController,
    required this.menus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 180.w,
        maxWidth: 240.w,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.08),
            offset: Offset(0, 4.h),
            blurRadius: 12.r,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: menus.asMap().entries.map((entry) {
              final index = entry.key;
              final menu = entry.value;
              final isLast = index == menus.length - 1;
              return _menuItem(
                icon: menu.icon,
                label: menu.text,
                onTap: menu.onTap,
                isLast: isLast,
                enabled: menu.enabled,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required String icon,
    required String label,
    Function()? onTap,
    bool isLast = false,
    bool enabled = true,
  }) =>
      InkWell(
        onTap: enabled
            ? () {
                popupMenuController?.hideMenu();
                onTap?.call();
              }
            : null,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(
                      color: const Color(0xFFE5E5EA),
                      width: 0.5,
                    ),
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: label.toText
                  ..style = TextStyle(
                    color: enabled
                        ? const Color(0xFF0C1C33)
                        : const Color(0xFF0C1C33).withOpacity(0.4),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  )
                  ..maxLines = 1
                  ..overflow = TextOverflow.ellipsis,
              ),
              SizedBox(width: 12.w),
              icon.toImage
                ..width = 20.w
                ..height = 20.h
                ..color =
                    enabled ? null : const Color(0xFF0C1C33).withOpacity(0.4)
                ..fit = BoxFit.contain,
            ],
          ),
        ),
      );
}

final allMenus = <MenuInfo>[
  MenuInfo(
    icon: ImageRes.menuCopy,
    text: StrRes.menuCopy,
    onTap: () {},
  ),
  MenuInfo(
    icon: ImageRes.menuDel,
    text: StrRes.menuDel,
    onTap: () {},
  ),
  MenuInfo(
    icon: ImageRes.menuForward,
    text: StrRes.menuForward,
    onTap: () {},
  ),
  MenuInfo(
    icon: ImageRes.menuReply,
    text: StrRes.menuReply,
    onTap: () {},
  ),
  MenuInfo(
    icon: ImageRes.menuMulti,
    text: StrRes.menuMulti,
    onTap: () {},
  ),
  MenuInfo(
    icon: ImageRes.menuRevoke,
    text: StrRes.menuRevoke,
    onTap: () {},
  ),
  MenuInfo(
    icon: ImageRes.menuAddFace,
    text: StrRes.menuAdd,
    onTap: () {},
  ),
];
