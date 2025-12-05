// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim/core/im_callback.dart';
import 'package:openim/widgets/qr_code_bottom_sheet.dart';
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
      QRCodeBottomSheet(
        name: imLogic.userInfo.value.nickname ?? '',
        avatarUrl: imLogic.userInfo.value.faceURL,
        qrData: '${Config.friendScheme}${imLogic.userInfo.value.userID}',
        isGroup: false,
        description: StrRes.scanToAddMe,
        hintText: StrRes.qrcodeHint,
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
