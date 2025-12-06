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
            leftText: StrRes.rejectAndExit,
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
    return Material(
      color: Colors.transparent,
      child: Center(
        child: AnimationConfiguration.synchronized(
          duration: const Duration(milliseconds: 450),
          child: SlideAnimation(
            curve: Curves.easeOutQuart,
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                constraints: BoxConstraints(
                  maxWidth: 375.w,
                  minWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFBFC),
                  borderRadius: BorderRadius.circular(32.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32.r),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header section
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFF8FAFC),
                                Color(0xFFFAFBFC),
                              ],
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 24.h,
                          ),
                          child: Column(
                            children: [
                              // Icon container với clay effect
                              Container(
                                width: 60.w,
                                height: 60.w,
                                margin: EdgeInsets.only(bottom: 16.h),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF3B82F6).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    // Inner shadow hiệu ứng lõm
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      offset: const Offset(3, 3),
                                      blurRadius: 6,
                                      spreadRadius: -2,
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.8),
                                      offset: const Offset(-3, -3),
                                      blurRadius: 6,
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.info_outline_rounded,
                                  size: 32.w,
                                  color: const Color(0xFF3B82F6),
                                ),
                              ),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF374151),
                                  height: 1.3,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white.withOpacity(0.9),
                                      offset: const Offset(0.5, 0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Content section
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(24.r),
                              boxShadow: [
                                // Inner shadow effect
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  offset: const Offset(4, 4),
                                  blurRadius: 8,
                                  spreadRadius: -2,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  offset: const Offset(-4, -4),
                                  blurRadius: 8,
                                  spreadRadius: -2,
                                ),
                              ],
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 20.w),
                            padding: EdgeInsets.all(20.w),
                            child: SingleChildScrollView(child: content),
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Buttons section
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(32.r),
                              bottomRight: Radius.circular(32.r),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(2, 7),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                offset: const Offset(-2, -2),
                                blurRadius: 4,
                                spreadRadius: -1,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _clayButton(
                                  text: leftText,
                                  textColor: const Color(0xFF6B7280),
                                  isLeft: true,
                                  onTap: onTapLeft,
                                ),
                              ),
                              Container(
                                width: 1.w,
                                height: 56.h,
                                margin: EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.02),
                                      Colors.black.withOpacity(0.05),
                                      Colors.black.withOpacity(0.02),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _clayButton(
                                  text: rightText,
                                  textColor: const Color(0xFF3B82F6),
                                  isLeft: false,
                                  onTap: onTapRight,
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

  Widget _clayButton({
    required String text,
    required Color textColor,
    required bool isLeft,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 80.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.only(
              bottomLeft: isLeft ? Radius.circular(32.r) : Radius.zero,
              bottomRight: !isLeft ? Radius.circular(32.r) : Radius.zero,
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
                shadows: [
                  Shadow(
                    color: Colors.white.withOpacity(0.9),
                    offset: const Offset(0.5, 0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
