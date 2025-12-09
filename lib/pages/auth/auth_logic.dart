// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:openim/core/controller/auth_controller.dart';
import 'package:openim/core/controller/gateway_config_controller.dart';
import 'package:openim_common/openim_common.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';

enum AuthFormMode { login, register }

class AuthLogic extends GetxController with GetTickerProviderStateMixin {
  final gatewayConfigController = Get.find<GatewayConfigController>();
  final merchantController = Get.find<MerchantController>();
  final authController = Get.find<AuthController>();

  // TabController
  late TabController tabController;

  // Login Form
  final loginFormKey = GlobalKey<FormState>();
  final loginPhoneController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final loginPhoneFocusNode = FocusNode();
  final loginPasswordFocusNode = FocusNode();

  // Register Form
  final registerFormKey = GlobalKey<FormState>();
  final registerPhoneController = TextEditingController();
  final registerNameController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final registerPasswordConfirmationController = TextEditingController();
  final registerVerificationCodeController = TextEditingController();
  final registerPhoneFocusNode = FocusNode();
  final registerNameFocusNode = FocusNode();
  final registerPasswordFocusNode = FocusNode();
  final registerPasswordConfirmationFocusNode = FocusNode();
  final registerInviteCodeFocusNode = FocusNode();

  // Observable states
  final versionInfo = ''.obs;
  final versionInfoShow = false.obs;
  final isLoginAgree = false.obs;
  final isRegisterAgree = false.obs;
  final isShowGatewayDomain = false.obs;

  // Gradient animation opacity (same as invite_code_view)
  final gradientOpacity = 0.0.obs;

  // Current form mode (login or register)
  final currentFormMode = AuthFormMode.login.obs;

  // Form validation states
  final isLoginFormValid = false.obs;
  final isRegisterFormValid = false.obs;

  // Getters
  get showContactUs => gatewayConfigController.showContactUs;
  String get currentDomainDisplayText =>
      authController.gatewayDomainLogic.currentDomainDisplayText;
  get requestDomainReveal =>
      authController.gatewayDomainLogic.requestDomainReveal;

  final rememberPassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    merchantController.currentIMServerInfo.value.merchantID = 100000;
    _initLoginData();
    _initFormValidation();

    // Check for initial tab from arguments
    if (Get.arguments != null && Get.arguments['tab'] != null) {
      final initialTab = Get.arguments['tab'] as int;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        tabController.animateTo(initialTab);
        // Also update form mode
        currentFormMode.value =
            initialTab == 0 ? AuthFormMode.login : AuthFormMode.register;
      });
    }
  }

  @override
  void onReady() {
    super.onReady();
    loginPhoneFocusNode.requestFocus();
    initPackageInfo();
    // Start gradient animation
    _startGradientAnimation();
  }

  void _startGradientAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      gradientOpacity.value = 1.0;
    });
  }

  @override
  void onClose() {
    // Dispose controllers
    loginPhoneController.dispose();
    loginPasswordController.dispose();
    registerPhoneController.dispose();
    registerNameController.dispose();
    registerPasswordController.dispose();
    registerPasswordConfirmationController.dispose();
    registerVerificationCodeController.dispose();

    // Dispose focus nodes
    loginPhoneFocusNode.dispose();
    loginPasswordFocusNode.dispose();
    registerPhoneFocusNode.dispose();
    registerNameFocusNode.dispose();
    registerPasswordFocusNode.dispose();
    registerPasswordConfirmationFocusNode.dispose();
    registerInviteCodeFocusNode.dispose();

    // Dispose tab controller
    tabController.dispose();
    super.onClose();
  }

  void _initLoginData() {
    var map = DataSp.getLoginAccount();
    if (map is Map) {
      String? account = map["account"];
      if (account != null && account.isNotEmpty) {
        loginPhoneController.text = account;
        final password = DataSp.getSavedPassword(account);
        if (password != null) {
          loginPasswordController.text = password;
        }
      }
    }
  }

  void _initFormValidation() {
    // Login form validation listeners
    loginPhoneController.addListener(_validateLoginForm);
    loginPasswordController.addListener(_validateLoginForm);

    // Register form validation listeners
    registerPhoneController.addListener(_validateRegisterForm);
    registerNameController.addListener(_validateRegisterForm);
    registerPasswordController.addListener(_validateRegisterForm);
    registerPasswordConfirmationController.addListener(_validateRegisterForm);
    registerVerificationCodeController.addListener(_validateRegisterForm);

    // Initial validation
    _validateLoginForm();
    _validateRegisterForm();
  }

  void _validateLoginForm() {
    final phoneValid = loginPhoneController.text.trim().isNotEmpty;
    final passwordValid = loginPasswordController.text.trim().isNotEmpty;

    isLoginFormValid.value = phoneValid && passwordValid;
  }

  void _validateRegisterForm() {
    final phoneValid = registerPhoneController.text.trim().isNotEmpty;
    final nameValid = registerNameController.text.trim().isNotEmpty;
    final passwordValid = registerPasswordController.text.trim().isNotEmpty;
    final passwordConfirmValid =
        registerPasswordConfirmationController.text.trim().isNotEmpty;
    final verificationCodeValid =
        registerVerificationCodeController.text.trim().isNotEmpty;

    isRegisterFormValid.value = phoneValid &&
        nameValid &&
        passwordValid &&
        passwordConfirmValid &&
        verificationCodeValid;
  }

  void initPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version;
    final appName = packageInfo.appName;
    final buildNumber = packageInfo.buildNumber;

    versionInfo.value = '$appName $version+$buildNumber SDK: ${OpenIM.version}';
  }

  // Login Methods
  void onLoginSubmit() async {
    if (isLoginAgree.isFalse) {
      var confirm = await Get.dialog(
          barrierColor: Colors.transparent,
          CustomDialog(
            title: StrRes.agreeToUserAgreementAndPrivacyPolicy,
          ));
      if (!confirm) {
        return;
      }
      isLoginAgree.value = true;
    }
    authController.login(
      account: loginPhoneController.text.trim(),
      password: IMUtils.generateMD5(loginPasswordController.text)!,
      onSuccess: () {
        DataSp.putSavedPassword(
          loginPhoneController.text,
          rememberPassword.isTrue ? loginPasswordController.text : '',
        );
      },
    );
  }

  // Register Methods
  void onRegisterSubmit() async {
    if (isRegisterAgree.isFalse) {
      var confirm = await Get.dialog(
          barrierColor: Colors.transparent,
          CustomDialog(
            title: StrRes.agreeToUserAgreementAndPrivacyPolicy,
          ));
      if (!confirm) {
        return;
      }
      isRegisterAgree.value = true;
    }

    try {
      FocusScope.of(Get.context!).requestFocus(FocusNode());
    } catch (_) {}

    authController.register(
      account: registerPhoneController.text,
      password: IMUtils.generateMD5(registerPasswordController.text)!,
      nickname: registerNameController.text,
      code: registerVerificationCodeController.text,
      invitationCode: authController.inviteCode,
    );
  }

  Future<bool> onSendVerificationCode() async {
    final phoneNumber = registerPhoneController.text.trim();

    // Remove spaces and dashes for validation
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[\s\-]'), '');

    // Remove country code if present
    if (cleanPhone.startsWith('+86')) {
      cleanPhone = cleanPhone.substring(3);
    } else if (cleanPhone.startsWith('86')) {
      cleanPhone = cleanPhone.substring(2);
    }

    // Validate using shared utility
    if (phoneNumber.isEmpty || !IMUtils.isChinaMobile(cleanPhone)) {
      IMViews.showToast(StrRes.pleaseEnterCorrectPhoneNumber);
      return false;
    }

    try {
      final result = await LoadingView.singleton.wrap(
        asyncFunction: () => GatewayApi.sendVerificationCodeV2(
          phoneNumber: phoneNumber,
        ),
      );

      Logger.print('SMS verification code response: $result');

      if (result == true) {
        IMViews.showToast(StrRes.verificationCodeSent);
        return true;
      }

      if (result is! Map) {
        return false;
      }

      final smsCode = result['smsValue']?.toString();
      final smsMsg = result['smsCode']?.toString();

      if (smsCode == null || smsCode.isEmpty) {
        IMViews.showToast(StrRes.verificationCodeSent);
        return true;
      }

      // showCupertinoSMSCodeDialog(
      //   message: smsMsg ?? StrRes.yourVerificationCodeIs.trArgs([smsCode]),
      //   onConfirm: () {
      //     registerVerificationCodeController.text = smsCode;
      //     FocusScope.of(Get.context!).unfocus();
      //   },
      // );
      ///Custom dialog has some issues on Android, temporarily use toast
     await Get.dialog( CustomDialog(
        title: StrRes.yourVerificationCodeIs.trArgs([smsCode]),
        showCancel: true,
        onTapRight: () {
          registerVerificationCodeController.text = smsCode;
          FocusScope.of(Get.context!).unfocus();
        },
      ));
      return true;
    } catch (error) {
      Logger.print('Failed to send verification code: $error');
      return false;
    }
  }

  Future<void> showCupertinoSMSCodeDialog({
    required String message,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: Center(
            child: AnimationConfiguration.synchronized(
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                curve: Curves.easeOutCubic,
                verticalOffset: 40.0,
                child: FadeInAnimation(
                  child: Container(
                    width: 300.w,
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9CA3AF).withOpacity(0.08),
                          offset: const Offset(0, 2),
                          blurRadius: 12.r,
                          spreadRadius: 0,
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFF3F4F6),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Content section
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 24.h,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  StrRes.verificationCode,
                                  style: TextStyle(
                                    fontFamily: 'FilsonPro',
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                                16.verticalSpace,
                                Text(
                                  message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'FilsonPro',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF6B7280),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Buttons section
                          Container(
                            width: double.infinity,
                            height: 60.h,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Color(0xFFF3F4F6),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: CupertinoButton(
                              borderRadius: BorderRadius.zero,
                              onPressed: () {
                                Get.back();
                                onConfirm();
                              },
                              child: Text(
                                StrRes.confirm,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4F42FF),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Other Methods
  void toggleVersionInfoShow() {
    versionInfoShow.value = !versionInfoShow.value;
  }

  void startContactUs() {
    // Contact us logic
  }

  void switchToRegisterTab() {
    tabController.animateTo(1);
  }

  void switchToLoginTab() {
    tabController.animateTo(0);
  }

  void switchFormMode(AuthFormMode mode) {
    currentFormMode.value = mode;
  }
}
