// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim/core/im_callback.dart';
import 'package:openim_common/openim_common.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/controller/gateway_config_controller.dart';
import '../../core/controller/im_controller.dart';
import '../../core/controller/push_controller.dart';
import '../../routes/app_navigator.dart';
import '../../core/controller/trtc_controller.dart';

class MineLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final pushLogic = Get.find<PushController>();
  final merchantController = Get.find<MerchantController>();
  final gatewayConfigController = Get.find<GatewayConfigController>();
  final trtcLogic = Get.find<TRTCController>();

  get showMyCompanyEntry => gatewayConfigController.showMyCompanyEntry;

  late StreamSubscription kickedOfflineSub;

  void copyID() {
    IMUtils.copy(text: imLogic.userInfo.value.userID!);
  }

  void startRealNameAuth() => AppNavigator.startRealNameAuth();

  void viewMyQrcode() => _showQRCodeBottomSheet();
  void _showQRCodeBottomSheet() {
    Get.bottomSheet(
      barrierColor: Colors.transparent,
      Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32.r),
                topRight: Radius.circular(32.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.08),
                  offset: const Offset(0, -3),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),

                // Title Section
                Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedQrCode01,
                        size: 24.w,
                        color: const Color(0xFF374151),
                      ),
                      12.horizontalSpace,
                      Text(
                        StrRes.qrcode,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),

                // QR Code Section
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9CA3AF).withOpacity(0.06),
                        offset: const Offset(0, 2),
                        blurRadius: 6.r,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFF3F4F6),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      children: [
                        // QR Title
                        Text(
                          StrRes.scanToAddMe,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                        ),
                        16.verticalSpace,
                        // QR Code
                        Center(
                          child: Container(
                            width: 180.w,
                            height: 180.w,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  offset: const Offset(1, 1),
                                  blurRadius: 3,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.9),
                                  offset: const Offset(-0.5, -0.5),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: QrImageView(
                              data: _buildQRContent(),
                              size: 150.w,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        16.verticalSpace,
                        // Hint Text
                        Text(
                          StrRes.qrcodeHint,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30.h),
              ],
            ),
          ),
        ],
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  String _buildQRContent() {
    return '${Config.friendScheme}${imLogic.userInfo.value.userID}';
  }

  void viewMyInfo() => AppNavigator.startMyInfo();
  void startMerchantList() => AppNavigator.startMerchantList();
  void accountSetup() => AppNavigator.startAccountSetup();
  void aboutUs() => AppNavigator.startAboutUs();
  void privacyPolicy() => AppNavigator.startPrivacyPolicy();
  void serviceAgreement() => AppNavigator.startServiceAgreement();
  void startChatAnalytics() => AppNavigator.startChatAnalytics();

  void logout() async {
    var confirm = await Get.dialog(
        barrierColor: Colors.transparent,
        CustomDialog(title: StrRes.logoutHint));
    if (confirm == true) {
      try {
        await LoadingView.singleton.wrap(asyncFunction: () async {
          await imLogic.logout();
          await DataSp.removeLoginCertificate();
          pushLogic.logout();
          trtcLogic.logout();
        });
        AppNavigator.startInviteCode();
      } catch (e) {
        IMViews.showToast('e:$e');
      }
    }
  }

  // 假的清除缓存，不等待im登录成功就退出登录
  void clearCache() async {
    var confirm = await Get.dialog(
        barrierColor: Colors.transparent,
        CustomDialog(title: StrRes.clearCacheHint));
    if (confirm == true) {
      imLogic.logout();
      await DataSp.removeLoginCertificate();
      pushLogic.logout();
      trtcLogic.logout();
      AppNavigator.startInviteCode();
    }
  }

  void kickedOffline({String? tips}) async {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    Get.snackbar(StrRes.accountWarn, tips ?? StrRes.accountException);
    await DataSp.removeLoginCertificate();
    pushLogic.logout();
    trtcLogic.logout();
    AppNavigator.startInviteCode();
  }

  @override
  void onInit() {
    kickedOfflineSub = imLogic.onKickedOfflineSubject.listen((value) {
      if (value == KickoffType.userTokenInvalid) {
        kickedOffline(tips: StrRes.tokenInvalid);
      } else {
        kickedOffline();
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    kickedOfflineSub.cancel();
    super.onClose();
  }
}
