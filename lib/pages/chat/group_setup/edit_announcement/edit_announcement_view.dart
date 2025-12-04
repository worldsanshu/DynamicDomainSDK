// ignore_for_file: deprecated_member_use

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim/widgets/base_page.dart';
import 'package:openim/widgets/custom_buttom.dart';

import 'edit_announcement_logic.dart';

class EditGroupAnnouncementPage extends StatelessWidget {
  final logic = Get.find<EditGroupAnnouncementLogic>();

  EditGroupAnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => TouchCloseSoftKeyboard(
          child: BasePage(
            showAppBar: true,
            title: StrRes.groupAc,
            centerTitle: false,
            showLeading: true,
            actions: logic.hasEditPermissions.value
                ? [
                    CustomButton(
                      title:
                          logic.onlyRead.value ? StrRes.edit : StrRes.publish,
                      onTap:
                          logic.onlyRead.value ? logic.editing : logic.publish,
                      colorButton: Colors.white.withOpacity(0.3),
                    )
                  ]
                : null,
            // Cute Minimalist: keep overall white background for cleanness
            body: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: Styles.c_FFFFFF,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9CA3AF).withOpacity(0.08),
                    offset: const Offset(0, 4),
                    blurRadius: 12.r,
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFF3F4F6),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((logic.updateMember.value.nickname ?? '').isNotEmpty)
                    Row(
                      children: [
                        AvatarView(
                          url: logic.updateMember.value.faceURL,
                          text: logic.updateMember.value.nickname,
                        ),
                        16.horizontalSpace,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (logic.updateMember.value.nickname ?? '').toText,
                            '${StrRes.updatedAt} ${DateUtil.formatDateMs(
                              (logic.groupInfo.value.notificationUpdateTime ??
                                  0),
                              format: IMUtils.getTimeFormat3(),
                            )}'
                                .toText
                              ..style = Styles.ts_8E9AB0_12sp,
                          ],
                        ),
                      ],
                    ),
                  Expanded(
                    child: logic.onlyRead.value
                        ? Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: SelectableText(logic.inputCtrl.text,
                                style: Styles.ts_0C1C33_17sp),
                          )
                        : TextField(
                            controller: logic.inputCtrl,
                            focusNode: logic.focusNode,
                            style: Styles.ts_0C1C33_17sp,
                            enabled: !logic.onlyRead.value,
                            expands: true,
                            maxLines: null,
                            minLines: null,
                            maxLength: 250,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: StrRes.plsEnterGroupAc,
                              hintStyle: Styles.ts_8E9AB0_17sp,
                              isDense: true,
                            ),
                          ),
                  ),
                  // Permission tips divider styled subtly
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 42.w,
                        height: 1.h,
                        margin: EdgeInsets.only(right: 2.w),
                        color: const Color(0xFFF3F4F6),
                      ),
                      StrRes.groupAcPermissionTips.toText
                        ..style = Styles.ts_8E9AB0_12sp,
                      Container(
                        width: 42.w,
                        height: 1.h,
                        margin: EdgeInsets.only(left: 2.w),
                        color: const Color(0xFFF3F4F6),
                      ),
                    ],
                  ),
                  51.verticalSpace,
                ],
              ),
            ),
          ),
        ));
  }
}
