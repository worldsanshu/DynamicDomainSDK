import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

enum OperateType {
  forward,
  save,
}

class PhotoBrowserBottomBar {
  PhotoBrowserBottomBar._();

  static void show(BuildContext context,
      {ValueChanged<OperateType>? onPressedButton}) {
    Get.dialog(
      Center(
        child: ChatLongPressMenu(
          popupMenuController: null,
          menus: [
            MenuInfo(
              icon: ImageRes.menuForward,
              text: StrRes.menuForward,
              onTap: () {
                Get.back();
                onPressedButton?.call(OperateType.forward);
              },
            ),
            MenuInfo(
              icon: ImageRes.saveIcon,
              text: StrRes.save,
              onTap: () {
                Get.back();
                onPressedButton?.call(OperateType.save);
              },
            ),
          ],
        ),
      ),
    );
  }
}
