// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim/widgets/custom_buttom.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/cupertino.dart';

import 'change_pwd_logic.dart';
import '../../../widgets/base_page.dart';

class ChangePwdPage extends StatelessWidget {
  final logic = Get.find<ChangePwdLogic>();

  ChangePwdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: BasePage(
        showAppBar: true,
        centerTitle: false,
        showLeading: true,
        customAppBar: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StrRes.changePassword,
              style: const TextStyle(
                fontFamily: 'FilsonPro',
                fontWeight: FontWeight.w500,
                fontSize: 23,
                color: Colors.black,
              ).copyWith(fontSize: 23.sp),
            ),
            Text(
              StrRes.updateYourPassword,
              style: const TextStyle(
                fontFamily: 'FilsonPro',
                fontWeight: FontWeight.w400,
                color: Color(0xFFBDBDBD),
              ).copyWith(fontSize: 12.sp),
            ),
          ],
        ),
        actions: [
          CustomButton(
            margin: const EdgeInsets.only(right: 5),
            onTap: logic.confirm,
            title: StrRes.determine,
            color: Colors.white,
          ),
        ],
        body: _buildContentContainer(),
      ),
    );
  }

  Widget _buildContentContainer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: AnimationLimiter(
        child: SingleChildScrollView(
          child: Column(
            children: [
              18.verticalSpace,
              AnimationConfiguration.staggeredList(
                position: 0,
                duration: const Duration(milliseconds: 400),
                child: SlideAnimation(
                  curve: Curves.easeOutCubic,
                  verticalOffset: 40.0,
                  child: FadeInAnimation(
                    child: _buildPasswordSection(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.06),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF3F4F6),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildPasswordItem(
            label: StrRes.oldPwd,
            controller: logic.oldPwdCtrl,
            icon: CupertinoIcons.lock,
            autofocus: true,
            isFirst: true,
          ),
          _buildPasswordItem(
            label: StrRes.newPwd,
            controller: logic.newPwdCtrl,
            icon: CupertinoIcons.lock_rotation,
          ),
          _buildPasswordItem(
            label: StrRes.confirmNewPwd,
            controller: logic.againPwdCtrl,
            icon: CupertinoIcons.checkmark_shield,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordItem({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool autofocus = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    // Pick the correct obscure toggle from logic based on which controller is passed
    RxBool getObscureRx() {
      if (identical(controller, logic.oldPwdCtrl)) return logic.oldPwdObscure;
      if (identical(controller, logic.newPwdCtrl)) return logic.newPwdObscure;
      return logic.againPwdObscure;
    }

    VoidCallback getToggle() {
      if (identical(controller, logic.oldPwdCtrl)) {
        return logic.toggleOldPwdVisibility;
      }
      if (identical(controller, logic.newPwdCtrl)) {
        return logic.toggleNewPwdVisibility;
      }
      return logic.toggleAgainPwdVisibility;
    }

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20.w,
                    color: AppColor.iconColor,
                  ),
                  16.horizontalSpace,
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),

                  // Text Field + Eye Button
                  Expanded(
                    child: Obx(() {
                      final obscure = getObscureRx().value;
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                autofocus: autofocus,
                                obscureText: obscure,
                                textInputAction: TextInputAction.next,
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF374151),
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: '••••••••',
                                  hintStyle: TextStyle(
                                    fontFamily: 'FilsonPro',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                ),
                              ),
                            ),
                            8.horizontalSpace,
                            GestureDetector(
                              onTap: getToggle(),
                              child: Icon(
                                obscure
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 20.w,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: EdgeInsets.only(left: 70.w),
            child: const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF3F4F6),
            ),
          ),
      ],
    );
  }
}
