// ignore_for_file: deprecated_member_use

import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:openim_common/openim_common.dart';

import '../../../core/controller/im_controller.dart';
import '../../../widgets/gradient_scaffold.dart';
import '../../../widgets/settings_menu.dart';
import 'my_info_logic.dart';

class MyInfoPage extends StatelessWidget {
  final logic = Get.find<MyInfoLogic>();
  final imLogic = Get.find<IMController>();

  MyInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return GradientScaffold(
      title: StrRes.myInfo,
      showBackButton: true,
      scrollable: true,
      bodyColor: const Color(0xFFF8F9FA),
      avatar: _buildAvatar(),
      body: Column(
        children: [
          // User ID
          Obx(() {
            final user = imLogic.userInfo.value;
            return GestureDetector(
              onTap: () {
                if (user.userID != null) {
                  Clipboard.setData(ClipboardData(text: user.userID!));
                  IMViews.showToast(StrRes.copySuccessfully, type: 1);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ID: ${user.userID ?? ''}',
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  8.horizontalSpace,
                  Icon(
                    CupertinoIcons.doc_on_doc,
                    size: 14.sp,
                    color: primaryColor,
                  ),
                ],
              ),
            );
          }),

          24.verticalSpace,

          // Info Group
          Obx(() => SettingsMenuSection(
                items: [
                  SettingsMenuItem(
                    icon: CupertinoIcons.person,
                    color: const Color(0xFF10B981),
                    label: StrRes.nickname,
                    value: imLogic.userInfo.value.nickname ?? '',
                    onTap: logic.editMyName,
                    isRow: false,
                  ),
                  SettingsMenuItem(
                    icon: CupertinoIcons.person_2_fill,
                    color: const Color(0xFFF87171),
                    label: StrRes.gender,
                    value: imLogic.userInfo.value.gender == 1
                        ? StrRes.man
                        : StrRes.woman,
                    onTap: logic.selectGender,
                    isRow: false,
                  ),
                  SettingsMenuItem(
                    icon: CupertinoIcons.gift,
                    color: const Color(0xFF8B5CF6),
                    label: StrRes.birthDay,
                    value: DateUtil.formatDateMs(
                      imLogic.userInfo.value.birth ?? 0,
                      format: IMUtils.getTimeFormat1(),
                    ),
                    onTap: logic.openDatePicker,
                    isRow: false,
                  ),
                  SettingsMenuItem(
                    icon: CupertinoIcons.phone,
                    color: const Color(0xFF3B82F6),
                    label: StrRes.mobile,
                    value: imLogic.userInfo.value.phoneNumber ?? '',
                    showArrow: false,
                    isRow: false,
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Obx(() {
      final user = imLogic.userInfo.value;
      return GestureDetector(
        onTap: logic.openUpdateAvatarSheet,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: AvatarView(
                url: user.faceURL,
                text: user.nickname,
                width: 100.w,
                height: 100.w,
                textStyle: TextStyle(fontSize: 32.sp, color: Colors.white),
                isCircle: true,
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 4.w, bottom: 4.w),
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                CupertinoIcons.camera,
                size: 14.w,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    });
  }
}
