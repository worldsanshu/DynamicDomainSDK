// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim/core/controller/app_controller.dart';
import 'package:openim/core/controller/auth_controller.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/controller/gateway_config_controller.dart';
import '../../routes/app_navigator.dart';

class SplashLogic extends GetxController {
  final appLogic = Get.find<AppController>();
  final AuthController authController = Get.find<AuthController>();
  final gatewayConfigController = Get.find<GatewayConfigController>();

  late TapGestureRecognizer _registerProtocolRecognizer;
  late TapGestureRecognizer _privacyProtocolRecognizer;

  @override
  void onInit() async {
    init();
    super.onInit();
  }

  Future<bool> showProtocolFunction() async {
    _registerProtocolRecognizer = TapGestureRecognizer();
    _privacyProtocolRecognizer = TapGestureRecognizer();

    final isShow = await Get.dialog<bool>(
          _ClayProtocolDialog(
            title: StrRes.warmTips,
            content: buildContent(),
            leftText: StrRes.cancel,
            rightText: StrRes.agree,
            onTapLeft: () => Get.back(result: false),
            onTapRight: () => Get.back(result: true),
          ),
          barrierDismissible: false,
        ) ??
        false;

    _registerProtocolRecognizer.dispose();
    _privacyProtocolRecognizer.dispose();

    return isShow;
  }

  //协议说明文案
  String userPrivateProtocol = StrRes.userPrivateProtocol;

  RichText buildContent() {
    return RichText(
      text: TextSpan(
          text: StrRes.plsReadBeforeUse,
          style: TextStyle(
            fontFamily: 'FilsonPro',
            color: Colors.grey[600],
          ),
          children: [
            TextSpan(
              text: StrRes.userAgreementDoc,
              style: const TextStyle(
                fontFamily: 'FilsonPro',
                color: Colors.blue,
              ),
              recognizer: _registerProtocolRecognizer
                ..onTap = startServiceAgreement,
            ),
            TextSpan(
              text: StrRes.and,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                color: Colors.grey[600],
              ),
            ),
            TextSpan(
              text: StrRes.privacyPolicy,
              style: const TextStyle(
                fontFamily: 'FilsonPro',
                color: Colors.blue,
              ),
              //点击事件
              recognizer: _privacyProtocolRecognizer
                ..onTap = startPrivacyPolicy,
            ),
            TextSpan(
              text: userPrivateProtocol,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                color: Colors.grey[600],
              ),
            ),
          ]),
    );
  }

  void startServiceAgreement() {
    AppNavigator.startServiceAgreement();
  }

  void startPrivacyPolicy() {
    AppNavigator.startPrivacyPolicy();
  }

  init() async {
    if (!await DataSp.isPrivacyPolicyAgreed()) {
      var result = await showProtocolFunction();
      if (!result) {
        exit(0);
      }
      DataSp.savePrivacyPolicyAgreement(result);
    }

    gatewayConfigController.refreshGatewayConfig();

    if (authController.isLoggedIn) {
      _login();
    } else {
      AppNavigator.startInviteCode();
    }
  }

  _login() async {
    try {
      appLogic.checkAppBadgeSupport();
      await authController.processLogin();
      authController.gatewayDomainLogic.refreshFallbackGatewayDomains();
      final result = await getConversationFirstPage();
      AppNavigator.startSplashToMain(isAutoLogin: true, conversations: result);
    } catch (e, s) {
      IMViews.showToast('$e $s');
      await DataSp.removeLoginCertificate();
      AppNavigator.startInviteCode();
    }
  }

  Future<List<ConversationInfo>> getConversationFirstPage() async {
    final result = await OpenIM.iMManager.conversationManager
        .getConversationListSplit(offset: 0, count: 50);

    return result;
  }
}

class _ClayProtocolDialog extends StatelessWidget {
  const _ClayProtocolDialog({
    required this.title,
    required this.content,
    required this.leftText,
    required this.rightText,
    required this.onTapLeft,
    required this.onTapRight,
  });

  final String title;
  final Widget content;
  final String leftText;
  final String rightText;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Material(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: AnimationConfiguration.synchronized(
          duration: const Duration(milliseconds: 450),
          child: SlideAnimation(
            curve: Curves.easeOutQuart,
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.9,
                // constraints: BoxConstraints(
                //   maxHeight: 600.h,
                // ),
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 30.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      offset: const Offset(0, 8),
                      blurRadius: 24,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header section with gradient
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                primaryColor.withOpacity(0.08),
                                primaryColor.withOpacity(0.04),
                              ],
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                          ),
                          child: Column(
                            children: [
                              // Icon container
                              Container(
                                width: 50.w,
                                height: 50.w,
                                margin: EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: primaryColor.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.info_outline_rounded,
                                  size: 36.w,
                                  color: primaryColor,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1F2937),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Divider
                        Container(
                          height: 1,
                          color: const Color(0xFFF3F4F6),
                        ),

                        // Content section
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 12.h,
                            ),
                            child: SingleChildScrollView(
                              child: DefaultTextStyle(
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 14.sp,
                                  color: const Color(0xFF6B7280),
                                  height: 1.6,
                                ),
                                child: content,
                              ),
                            ),
                          ),
                        ),

                        // Divider
                        Container(
                          height: 1,
                          color: const Color(0xFFF3F4F6),
                        ),

                        // Buttons section
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          child: Row(
                            children: [
                              // Cancel button
                              Expanded(
                                child: GestureDetector(
                                  onTap: onTapLeft,
                                  child: Container(
                                    height: 48.h,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        leftText,
                                        style: TextStyle(
                                          fontFamily: 'FilsonPro',
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              12.horizontalSpace,
                              // Agree button with gradient
                              Expanded(
                                child: GestureDetector(
                                  onTap: onTapRight,
                                  child: Container(
                                    height: 48.h,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          primaryColor,
                                          primaryColor.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.3),
                                          offset: const Offset(0, 4),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        rightText,
                                        style: TextStyle(
                                          fontFamily: 'FilsonPro',
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }

}
