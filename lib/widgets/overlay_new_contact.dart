import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/widgets/settings_menu.dart';
import 'package:openim_common/openim_common.dart';
import '../pages/home/home_logic.dart';

void showNewContactPopup(BuildContext context, GlobalKey buttonKey) {
  final homeLogic = Get.find<HomeLogic>();
  final RenderBox button =
      buttonKey.currentContext!.findRenderObject() as RenderBox;
  final Offset buttonPosition = button.localToGlobal(Offset.zero);
  final menuWidth = 225.w;
  final double left = buttonPosition.dx + button.size.width - menuWidth;
  final double top = buttonPosition.dy + button.size.height + 4;

  showGeneralDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
        child: Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              width: menuWidth,
              child: Material(
                color: Colors.transparent,
                child: ScaleTransition(
                  scale: animation,
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SettingsMenuItem(
                          icon: CupertinoIcons.qrcode_viewfinder,
                          label: StrRes.scan,
                          onTap: () {
                            Navigator.pop(context);
                            homeLogic.scan();
                          },
                        ),
                        SettingsMenuItem(
                          icon: CupertinoIcons.person_add,
                          label: StrRes.addFriend,
                          onTap: () {
                            Navigator.pop(context);
                            homeLogic.addFriend();
                          },
                        ),
                        SettingsMenuItem(
                          icon: CupertinoIcons.person_2,
                          label: StrRes.addGroup,
                          onTap: () {
                            Navigator.pop(context);
                            homeLogic.addGroup();
                          },
                        ),
                        SettingsMenuItem(
                          icon: CupertinoIcons.create,
                          label: StrRes.createGroup,
                          onTap: () {
                            Navigator.pop(context);
                            homeLogic.createGroup();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildMenuDivider() {
  return Padding(
    padding: EdgeInsets.only(left: 16.w, right: 16.w),
    child: const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF3F4F6),
    ),
  );
}
