import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim/tracking_service.dart';
import 'package:openim/core/controller/auth_controller.dart';
import 'package:openim/core/controller/gateway_config_controller.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';

class InviteCodeLogic extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final gatewayConfigController = Get.find<GatewayConfigController>();

  bool get enableInviteCodeRequired =>
      gatewayConfigController.enableInviteCodeRequired;

  final formKey = GlobalKey<FormState>();
  final inviteCodeController = TextEditingController();
  final inviteCodeFocusNode = FocusNode();

  final gradientOpacity = 0.0.obs;
  final isButtonEnabled = false.obs; // Track if submit button should be enabled

  final Set<String> _validInviteCodesCache = {};

  // Rate limiting
  final List<DateTime> _requestTimestamps = [];
  DateTime? _blockedUntil;
  static const int _maxRequests = 5;
  static const Duration _timeWindow = Duration(seconds: 30);
  static const Duration _blockDuration = Duration(minutes: 2);

  bool _checkRateLimit() {
    final now = DateTime.now();

    // Check if currently blocked
    if (_blockedUntil != null && now.isBefore(_blockedUntil!)) {
      IMViews.showToast(StrRes.tooMuchRequestValidationCode);
      return false;
    }

    // Clear block if expired
    if (_blockedUntil != null && now.isAfter(_blockedUntil!)) {
      _blockedUntil = null;
      _requestTimestamps.clear();
    }

    // Remove old timestamps outside the time window
    _requestTimestamps.removeWhere(
      (timestamp) => now.difference(timestamp) > _timeWindow,
    );

    // Check if too many requests
    if (_requestTimestamps.length >= _maxRequests) {
      _blockedUntil = now.add(_blockDuration);
      IMViews.showToast(StrRes.tooMuchRequestValidationCode);
      return false;
    }

    // Add current request timestamp
    _requestTimestamps.add(now);
    return true;
  }

  void onSubmit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final inviteCode = inviteCodeController.text;
    if (!_validInviteCodesCache.contains(inviteCode) && inviteCode.isNotEmpty) {
      // Check rate limit before making API call
      if (!_checkRateLimit()) {
        return;
      }

      try {
        final valid = await LoadingView.singleton.wrap(
          asyncFunction: () => GatewayApi.checkInvitationCode(
            inviteCode: inviteCode,
          ),
        );
        if (valid == false) {
          IMViews.showToast(StrRes.enterpriseCodeNotExist);
          return;
        }
        _validInviteCodesCache.add(inviteCode);
      } catch (_) {
        return;
      }
    }
    DataSp.putSavedInviteCode(inviteCode);
    authController.inviteCode = inviteCode;
    AppNavigator.startAuth();
    IMViews.showToast(StrRes.savedInviteCode, type: 1);
  }

  @override
  void onInit() {
    super.onInit();

    // Listen to text changes to validate and enable/disable submit button
    inviteCodeController.addListener(() {
      final value = inviteCodeController.text;
      final isEmpty = value.isEmpty;
      final isInvalid = !isEmpty && !IMUtils.isValidInviteCode(value);

      // Button is enabled only when:
      // 1. If invite code is required: not empty AND valid format
      // 2. If invite code is optional: empty OR valid format
      if (enableInviteCodeRequired) {
        // Required: must have valid code
        isButtonEnabled.value = !isEmpty && !isInvalid;
      } else {
        // Optional: empty is OK, but if not empty must be valid
        isButtonEnabled.value = isEmpty || !isInvalid;
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      gradientOpacity.value = 1.0;
      inviteCodeFocusNode.requestFocus();
    });

    final inviteCode = DataSp.getSavedInviteCode();
    if (inviteCode != null) {
      inviteCodeController.text = inviteCode;
    }
  }

  @override
  void onReady() {
    if (Platform.isIOS) {
      TrackingService.requestTrackingAuthorization();
    }
  }

  @override
  void onClose() {
    inviteCodeController.dispose();
    inviteCodeFocusNode.dispose();
    super.onClose();
  }
}
