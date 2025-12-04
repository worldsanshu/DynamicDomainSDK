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
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(12.r),
      ),
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
          );
        }).toList(),
      ),
    );
  }

  Widget _menuItem({
    required String icon,
    required String label,
    Function()? onTap,
    bool isLast = false,
  }) =>
      GestureDetector(
        onTap: () {
          popupMenuController?.hideMenu();
          onTap?.call();
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(
                      color: Color(0xFFE5E5EA),
                      width: 0.5,
                    ),
                  ),
          ),
          child: Row(
            children: [
              Expanded(
                child: label.toText
                  ..style = TextStyle(
                    color: Colors.black,
                    fontSize: 14.sp,
                    fontFamily: 'FilsonPro',
                    fontWeight: FontWeight.w400,
                  )
                  ..maxLines = 1
                  ..overflow = TextOverflow.ellipsis,
              ),
              12.horizontalSpace,
              icon.toImage
                ..width = 25.w
                ..height = 25.h
                ..color = Colors.black,
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
