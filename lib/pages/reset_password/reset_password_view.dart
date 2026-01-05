// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/pages/auth/widget/password_field.dart';
import 'package:openim/pages/auth/widget/phone_field.dart';
import 'package:openim/pages/auth/widget/phone_code_field.dart';
import 'package:openim/pages/auth/widget/app_text_button.dart';
import 'package:openim/widgets/gradient_scaffold.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'reset_password_logic.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<ResetPasswordLogic>();
    final primaryColor = Theme.of(context).primaryColor;

    return GradientScaffold(
        title: logic.fromLogin ? StrRes.forgotPassword : StrRes.resetPassword,
        showBackButton: true,
        scrollable: true,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 500),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 0,
                    curve: Curves.easeOutCubic,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    // Form container with validation
                    Form(
                      key: logic.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Phone number field
                          PhoneField(
                            focusNode: logic.phoneFocusNode,
                            controller: logic.phoneNumberCtrl,
                            isRequired: true,
                          ),
                          20.verticalSpace,

                          // Password field with format validation
                          PasswordField(
                            focusNode: logic.passwordFocusNode,
                            controller: logic.passwordCtrl,
                            validateFormat: true,
                            label: StrRes.newPwd,
                            isRequired: true,
                            isNew: true,
                            onPasswordChange: () {
                              // Only re-validate confirm password if it already has a value
                              if (logic.confirmPasswordCtrl.text.isNotEmpty) {
                                logic.passwordConfirmationFieldKey.currentState
                                    ?.validate();
                              }
                            },
                          ),
                          20.verticalSpace,

                          // Confirm password field with comparison
                          PasswordField(
                            focusNode: logic.passwordConfirmationFocusNode,
                            controller: logic.confirmPasswordCtrl,
                            compareController: logic.passwordCtrl,
                            formFieldKey: logic.passwordConfirmationFieldKey,
                            isRequired: true,
                            onFieldSubmitted: (_) {
                              // Smoothly transition to SMS code field with a small delay
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                FocusScope.of(context)
                                    .requestFocus(logic.smsCodeFocusNode);
                              });
                            },
                          ),
                          20.verticalSpace,

                          // Verification code field
                          PhoneCodeField(
                            controller: logic.smsCodeCtrl,
                            phoneController: logic.phoneNumberCtrl,
                            validatePhone: logic.phoneNumberCtrl.text,
                            onSendCode: logic.onSendVerificationCode,
                            isRequired: true,
                          ),

                          30.verticalSpace,

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: Obx(() => AppTextButton(
                                  buttonText: StrRes.confirm,
                                  backgroundColor: logic.isButtonEnabled.value
                                      ? primaryColor
                                      : const Color(0xFF9CA3AF),
                                  textStyle: TextStyle(
                                    fontFamily: 'FilsonPro',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    logic.passwordFocusNode.unfocus();
                                    logic.passwordConfirmationFocusNode
                                        .unfocus();
                                    if (logic.isButtonEnabled.value &&
                                        logic.formKey.currentState!
                                            .validate()) {
                                      logic.onResetPassword();
                                    }
                                  },
                                )),
                          ),
                          150.verticalSpace,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}
