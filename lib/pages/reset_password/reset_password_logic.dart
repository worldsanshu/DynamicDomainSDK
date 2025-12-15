import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim/routes/app_navigator.dart';

class ResetPasswordLogic extends GetxController {
  // Form key for validation
  final formKey = GlobalKey<FormState>();
    bool fromLogin = false;


  // Controllers
  final phoneNumberCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final smsCodeCtrl = TextEditingController();

  // Focus nodes
  final phoneFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final passwordConfirmationFocusNode = FocusNode();
  final smsCodeFocusNode = FocusNode();

  // Observable state for button
  var isButtonEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
        fromLogin = Get.arguments?['fromLogin'] ?? false;

    // Add listeners for real-time validation
    phoneNumberCtrl.addListener(_validateForm);
    passwordCtrl.addListener(_validateForm);
    confirmPasswordCtrl.addListener(_validateForm);
    smsCodeCtrl.addListener(_validateForm);

    // Initial validation
    _validateForm();
  }

  @override
  void onReady() {
    phoneFocusNode.requestFocus();
    super.onReady();
  }

  @override
  void onClose() {
    // Remove listeners
    phoneNumberCtrl.removeListener(_validateForm);
    passwordCtrl.removeListener(_validateForm);
    confirmPasswordCtrl.removeListener(_validateForm);
    smsCodeCtrl.removeListener(_validateForm);

    // Dispose controllers
    phoneNumberCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    smsCodeCtrl.dispose();

    // Dispose focus nodes
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    passwordConfirmationFocusNode.dispose();
    smsCodeFocusNode.dispose();

    super.onClose();
  }

  /// Validate form and update button state
  void _validateForm() {
    final phoneValid = phoneNumberCtrl.text.trim().isNotEmpty;
    final passwordValid = passwordCtrl.text.trim().isNotEmpty;
    final confirmPasswordValid = confirmPasswordCtrl.text.trim().isNotEmpty;
    final smsCodeValid = smsCodeCtrl.text.trim().isNotEmpty;

    isButtonEnabled.value =
        phoneValid && passwordValid && confirmPasswordValid && smsCodeValid;

    // Keep validators in sync: whenever either password field changes,
    // re-run form validation so the confirm password field reflects
    // the latest value even if it was edited first.
    try {
      if (formKey.currentState != null) {
        formKey.currentState!.validate();
      }
    } catch (_) {}
  }

  Future<bool> onSendVerificationCode() async {
    final phoneNumber = phoneNumberCtrl.text.trim();

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
        asyncFunction: () => GatewayApi.sendVerificationCode(
          phoneNumber: phoneNumber,
          use: 'passwordReset',
        ),
      );
      if (result == true) {
        IMViews.showToast(StrRes.verificationCodeSent,type: 1);
        return true;
      }
    } catch (error) {
      IMViews.showToast(StrRes.failedToSendVerificationCode);
      Logger.print(error);
    }
    return false;
  }

  /// Reset password with form validation
  onResetPassword() async {
    // Validate form first
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Additional password validation
    if (!IMUtils.isValidPassword(passwordCtrl.text)) {
      IMViews.showToast(StrRes.wrongPasswordFormat);
      return;
    }

    // Check if passwords match
    if (passwordCtrl.text != confirmPasswordCtrl.text) {
      IMViews.showToast(StrRes.twicePwdNoSame);
      return;
    }

    // Call API to reset password
    final result = await LoadingView.singleton.wrap(
      asyncFunction: () => GatewayApi.resetPassword(
        password: passwordCtrl.text,
        phoneNumber: phoneNumberCtrl.text,
        smsCode: smsCodeCtrl.text,
      ),
    );

    if (result) {
      IMViews.showToast(StrRes.resetSuccessful,type: 1);
      // Navigate back to login screen after successful password reset
      AppNavigator.startLogin();
    } else {
      // Show failure message
      IMViews.showToast(StrRes.saveFailed);
    }
  }
}
