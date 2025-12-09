// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:openim/pages/auth/auth_logic.dart';
import 'package:openim/pages/auth/widget/app_text_button.dart';
import 'package:openim/pages/auth/widget/password_field.dart';
import 'package:openim/pages/auth/widget/phone_field.dart';
import 'package:openim/pages/auth/widget/phone_code_field.dart';
import 'package:openim/pages/auth/widget/nickname_field.dart';
import 'package:openim/pages/auth/widget/terms_and_conditions_text.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';

class AuthView extends StatelessWidget {
  AuthView({super.key});

  final logic = Get.find<AuthLogic>();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return TouchCloseSoftKeyboard(
      isGradientBg: false,
      child: Scaffold(
        body: Stack(
          children: [
            // Animated radial gradient background (same as invite_code_view)
            _buildAnimatedGradientBackground(primaryColor),
            // Main content với form nổi lên ở giữa
            SafeArea(
              child: Column(
                children: [
                  // Floating form với chiều cao giới hạn
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: AnimationLimiter(
                          child: _buildFloatingForm(context, primaryColor),
                        ),
                      ),
                    ),
                  ),
                  Gap(20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedGradientBackground(Color primaryColor) {
    return Obx(
      () => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: logic.gradientOpacity.value),
        duration: const Duration(seconds: 2),
        builder: (context, value, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -1.0),
                radius: 1.8,
                colors: [
                  primaryColor.withOpacity(value * 0.9),
                  primaryColor.withOpacity(value * 0.5),
                  Colors.white.withOpacity(0.0),
                ],
                stops: const [0.0, 0.4, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingForm(BuildContext context, Color primaryColor) {
    // Tính toán chiều cao cố định cho form (giới hạn trong màn hình)
    final screenHeight = MediaQuery.of(context).size.height;
    final formHeight = screenHeight * 0.9; // 90% màn hình - cố định

    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 40,
        child: FadeInAnimation(
          child: Container(
            width: double.infinity,
            height: formHeight, // Cố định chiều cao
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Column(
                mainAxisSize:
                    MainAxisSize.max, // Chiếm toàn bộ chiều cao cố định
                children: [
                  // Header với logo (fixed, không scroll)
                  _buildFormHeader(primaryColor),
                  // Form content với scroll bên trong - căn giữa nếu nội dung ngắn
                  Flexible(
                    child: _buildFormContent(primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.05),
            primaryColor.withOpacity(0.02),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Logo và Title ở giữa
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onDoubleTap: logic.toggleVersionInfoShow,
                  child: Container(
                    width: 72.w,
                    height: 72.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(90),
                      child: Image.asset(
                        "assets/images/app-icon.png",
                        width: 72.w,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: logic.requestDomainReveal,
                  child: Text(
                    StrRes.loginTitle,
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Back button ở top left
          Positioned(
            left: 0,
            top: 10,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20.sp,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(Color primaryColor) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start, // Căn giữa nội dung
      children: [
        // Mode Toggle (Login / Register) - Fixed
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 0),
          child: _buildModeToggle(primaryColor),
        ),
        // Scrollable form fields
        Flexible(
          child: Obx(() {
            if (logic.currentFormMode.value == AuthFormMode.login) {
              return _buildLoginFields(primaryColor);
            } else {
              return _buildRegisterFields(primaryColor);
            }
          }),
        ),
      ],
    );
  }

  Widget _buildModeToggle(Color primaryColor) {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => logic.switchFormMode(AuthFormMode.login),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.fastOutSlowIn,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: logic.currentFormMode.value == AuthFormMode.login
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      StrRes.login,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 14.sp,
                        fontWeight:
                            logic.currentFormMode.value == AuthFormMode.login
                                ? FontWeight.w600
                                : FontWeight.w500,
                        color: logic.currentFormMode.value == AuthFormMode.login
                            ? primaryColor
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => logic.switchFormMode(AuthFormMode.register),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.fastOutSlowIn,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color:
                          logic.currentFormMode.value == AuthFormMode.register
                              ? Colors.white
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow:
                          logic.currentFormMode.value == AuthFormMode.register
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                    ),
                    child: Text(
                      StrRes.register,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 14.sp,
                        fontWeight:
                            logic.currentFormMode.value == AuthFormMode.register
                                ? FontWeight.w600
                                : FontWeight.w500,
                        color:
                            logic.currentFormMode.value == AuthFormMode.register
                                ? primaryColor
                                : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildLoginFields(Color primaryColor) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 20.h),
      child: Form(
        key: logic.loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhoneField(
              focusNode: logic.loginPhoneFocusNode,
              controller: logic.loginPhoneController,
              isRequired: true,
            ),
            Gap(20.h),
            PasswordField(
              focusNode: logic.loginPasswordFocusNode,
              controller: logic.loginPasswordController,
              isRequired: true,
            ),
            Gap(20.h),
            // Remember Password - Left aligned
            Obx(
              () => Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    logic.rememberPassword.value =
                        !logic.rememberPassword.value;
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: logic.rememberPassword.value,
                        onChanged: (bool? value) {
                          logic.rememberPassword.value =
                              value ?? !logic.rememberPassword.value;
                        },
                        fillColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.selected)) {
                              return primaryColor;
                            }
                            return Colors.transparent;
                          },
                        ),
                        checkColor: Colors.white,
                        side: const BorderSide(
                          color: Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Text(
                        StrRes.rememberPassword,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Gap(20.h),
            // Login Button - Centered
            SizedBox(
              width: double.infinity,
              child: Obx(() => AppTextButton(
                    buttonText: StrRes.login,
                    backgroundColor: logic.isLoginFormValid.value
                        ? primaryColor
                        : const Color(0xFF9CA3AF),
                    textStyle: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      logic.loginPasswordFocusNode.unfocus();
                      if (logic.isLoginFormValid.value &&
                          logic.loginFormKey.currentState!.validate()) {
                        logic.onLoginSubmit();
                      }
                    },
                  )),
            ),
            Gap(20.h),
            // Forgot Password - Centered
            Center(
              child: GestureDetector(
                onTap: () {
                  AppNavigator.startResetPassword();
                },
                child: Text(
                  StrRes.forgetPassword,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 14.sp,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Gap(8.h),
            // Agree Terms and Conditions - Left aligned
            Align(
              alignment: Alignment.centerLeft,
              child: TermsAndConditionsText(
                content: Obx(
                  () => Checkbox(
                    value: logic.isLoginAgree.value,
                    onChanged: (bool? value) {
                      logic.isLoginAgree.value = !logic.isLoginAgree.value;
                    },
                    fillColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return primaryColor;
                        }
                        return Colors.transparent;
                      },
                    ),
                    checkColor: Colors.white,
                    side: const BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
            // Version info
            _buildVersionInfo(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterFields(Color primaryColor) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 20.h),
      child: Form(
        key: logic.registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NicknameField(
              controller: logic.registerNameController,
              focusNode: logic.registerNameFocusNode,
              isRequired: true,
            ),
            Gap(20.h),
            PhoneField(
              focusNode: logic.registerPhoneFocusNode,
              controller: logic.registerPhoneController,
              isRequired: true,
            ),
            Gap(20.h),
            PasswordField(
              focusNode: logic.registerPasswordFocusNode,
              controller: logic.registerPasswordController,
              validateFormat: true,
              isRequired: true,
            ),
            Gap(20.h),
            PasswordField(
              focusNode: logic.registerPasswordConfirmationFocusNode,
              controller: logic.registerPasswordConfirmationController,
              compareController: logic.registerPasswordController,
              isRequired: true,
            ),
            Gap(20.h),
            PhoneCodeField(
              controller: logic.registerVerificationCodeController,
              phoneController: logic.registerPhoneController,
              validatePhone: logic.registerPhoneController.text,
              onSendCode: logic.onSendVerificationCode,
              isRequired: true,
            ),
            // Register Button
            Gap(20.h),
            SizedBox(
              width: double.infinity,
              child: Obx(() => AppTextButton(
                    buttonText: StrRes.createAccount,
                    backgroundColor: logic.isRegisterFormValid.value
                        ? primaryColor
                        : const Color(0xFF9CA3AF),
                    textStyle: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      logic.registerPasswordFocusNode.unfocus();
                      logic.registerPasswordConfirmationFocusNode.unfocus();
                      if (logic.isRegisterFormValid.value &&
                          logic.registerFormKey.currentState!.validate()) {
                        logic.onRegisterSubmit();
                      }
                    },
                  )),
            ),
            TermsAndConditionsText(
              content: Obx(
                () => Checkbox(
                  value: logic.isRegisterAgree.value,
                  onChanged: (bool? value) {
                    logic.isRegisterAgree.value = !logic.isRegisterAgree.value;
                  },
                  fillColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return primaryColor;
                      }
                      return Colors.transparent;
                    },
                  ),
                  checkColor: Colors.white,
                  side: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            Gap(6.h),
            _buildVersionInfo(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo(Color primaryColor) {
    return Obx(
      () => Visibility(
        visible: logic.versionInfoShow.value,
        child: Column(
          children: [
            Gap(12.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              padding: EdgeInsets.all(10.w),
              child: Column(
                children: [
                  Text(
                    logic.versionInfo.value,
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 11.sp,
                      color:  Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Gap(4.h),
                  GestureDetector(
                    onTap: () {
                      AppNavigator.startGatewaySwitcher();
                    },
                    child: Text(
                      logic.currentDomainDisplayText,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 11.sp,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
