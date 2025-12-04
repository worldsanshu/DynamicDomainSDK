import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/controller/app_controller.dart';
import '../../../core/controller/gateway_config_controller.dart';
import '../../../core/controller/im_controller.dart';

class AboutUsLogic extends GetxController {
  final version = "".obs;
  final buildNumber = "".obs;
  final appName = "App".obs;
  final appLogic = Get.find<AppController>();
  final imLogic = Get.find<IMController>();
  final gatewayConfigController = Get.find<GatewayConfigController>();
  final lineTextController = TextEditingController(text: '1000');

  get showContactUs => gatewayConfigController.showContactUs;

  void getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
    appName.value = packageInfo.appName;
    buildNumber.value = packageInfo.buildNumber;
  }

  void checkUpdate() {
    // appLogic.checkUpdate();
  }

  void uploadLogs([int line = 0]) async {
    EasyLoading.showProgress(0);
    await OpenIM.iMManager.uploadLogs(line: line);
    EasyLoading.dismiss();
  }

  void startContactUs() => AppNavigator.startContactUs();

  @override
  void onReady() {
    getPackageInfo();

    imLogic.onUploadProgress = (current, size) {
      final p = current / size;
      final pStr = '${(p * 100.0).truncate()}%';
      EasyLoading.show(status: pStr, dismissOnTap: false);
    };
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
