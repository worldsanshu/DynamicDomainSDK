// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/pages/auth/widget/password_field.dart';
import 'package:openim/pages/auth/widget/phone_field.dart';
import 'package:openim/pages/auth/widget/phone_code_field.dart';
import 'package:openim/pages/auth/widget/app_text_button.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'reset_password_logic.dart';
import '../../widgets/base_page.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<ResetPasswordLogic>();

    return Material(
      child: BasePage(
        showAppBar: true,
        title: StrRes.changePassword,
        centerTitle: false,
        showLeading: true,
        body: Container(
          decoration: const BoxDecoration(
            color:
                Color(0xFFFAFAFA), // Slightly off-white background for contrast
          ),
          child: TouchCloseSoftKeyboard(
            isGradientBg: false,
            child: Column(
              children: [
                // Modern wave pattern header

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: AnimationLimiter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 500),
                            childAnimationBuilder: (widget) => SlideAnimation(
                              verticalOffset: 40,
                              curve: Curves.easeOutCubic,
                              child: FadeInAnimation(
                                child: widget,
                              ),
                            ),
                            children: [
                              24.verticalSpace,

                              // Form container with validation
                              Form(
                                key: logic.formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Phone number field
                                    _buildFieldLabel(StrRes.phoneNumber),
                                    8.verticalSpace,
                                    PhoneField(
                                      focusNode: logic.phoneFocusNode,
                                      controller: logic.phoneNumberCtrl,
                                    ),
                                    20.verticalSpace,

                                    // Password field with format validation
                                    _buildFieldLabel(StrRes.password),
                                    8.verticalSpace,
                                    PasswordField(
                                      focusNode: logic.passwordFocusNode,
                                      controller: logic.passwordCtrl,
                                      validateFormat: true,
                                    ),
                                    20.verticalSpace,

                                    // Confirm password field with comparison
                                    _buildFieldLabel(StrRes.confirmPassword),
                                    8.verticalSpace,
                                    PasswordField(
                                      focusNode:
                                          logic.passwordConfirmationFocusNode,
                                      controller: logic.confirmPasswordCtrl,
                                      compareController: logic.passwordCtrl,
                                    ),
                                    20.verticalSpace,

                                    // Verification code field
                                    _buildFieldLabel(StrRes.verificationCode),
                                    8.verticalSpace,
                                    PhoneCodeField(
                                      controller: logic.smsCodeCtrl,
                                      onSendCode: logic.onSendVerificationCode,
                                    ),

                                    30.verticalSpace,

                                    // Submit Button
                                    Align(
                                      alignment: Alignment.center,
                                      child: Obx(() => AppTextButton(
                                            buttonText: StrRes.confirm,
                                            buttonWidth: 200.w,
                                            backgroundColor:
                                                logic.isButtonEnabled.value
                                                    ? const Color(0xFF3B82F6)
                                                    : const Color(0xFF9CA3AF),
                                            textStyle: TextStyle(
                                              fontFamily: 'FilsonPro',
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                            onPressed: () async {
                                              logic.passwordFocusNode.unfocus();
                                              logic
                                                  .passwordConfirmationFocusNode
                                                  .unfocus();
                                              if (logic.isButtonEnabled.value &&
                                                  logic.formKey.currentState!
                                                      .validate()) {
                                                logic.onResetPassword();
                                              }
                                            },
                                          )),
                                    ),
                                  ],
                                ),
                              ),

                              30.verticalSpace,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool required = true}) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
              letterSpacing: 0.3,
            ),
          ),
          if (required)
            Text(
              ' *',
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEF4444),
              ),
            ),
        ],
      ),
    );
  }
}

// Custom wave painter for the header
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();

    // First wave
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.7,
        size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.9, size.width, size.height * 0.8);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave
    final path2 = Path();
    path2.moveTo(0, size.height * 0.9);
    path2.quadraticBezierTo(size.width * 0.25, size.height * 0.8,
        size.width * 0.5, size.height * 0.9);
    path2.quadraticBezierTo(
        size.width * 0.75, size.height, size.width, size.height * 0.9);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint..color = Colors.white.withOpacity(0.15));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
