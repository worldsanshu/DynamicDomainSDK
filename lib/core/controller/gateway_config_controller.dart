import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/config_util.dart';

class GatewayConfigController extends GetxController {
  final gatewayConfig = Map<String, dynamic>.from(defaultConfig).obs;

  final appConfig = Map<String, dynamic>.from({}).obs;

  final RxnBool isUnderReview = RxnBool(null);

  refreshGatewayConfig() async {
    Map<String, dynamic>? remoteConfig;

    try {
      remoteConfig = await GatewayApi.getGatewayConfig();
    } catch (_) {}

    final configSource =
        remoteConfig ?? ConfigUtil.castMapOrNull(DataSp.getGatewayConfig());

    if (configSource != null) {
      final mergedConfig = ConfigUtil.mergeWithDefault(
        source: configSource,
        defaultValues: defaultConfig,
      );
      gatewayConfig.assignAll(mergedConfig);
      DataSp.putGatewayConfig(mergedConfig);
      initAppConfig();
    }
  }

  bool get showContactUs => appConfig['showContactUs'] == true;

  bool get showMyCompanyEntry =>
      appConfig['showMyCompanyEntry'] == true && isUnderReview.value != true;

  int? get defaultMerchantID =>
      int.tryParse(gatewayConfig['defaultMerchantID'] ?? '');

  String? get defaultInviteCode {
    final code = gatewayConfig['defaultInviteCode'];
    if (code == null || (code is String && code.trim().isEmpty)) {
      return Config.defaultInviteCode;
    }
    return code;
  }

  bool get enableClipboardDomainCheck =>
      appConfig['enableClipboardDomainCheck'] == true;

  bool get confirmNoInviteCodeOnRegister =>
      appConfig['confirmNoInviteCodeOnRegister'] == true;

  bool get enableNetworkCheckAndFallback =>
      appConfig['enableNetworkCheckAndFallback'] == true;

  bool get enableInviteCodeRequired => true;
  //appConfig['enableInviteCodeRequired'] == true;

  Future<void> initAppConfig() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final brand = await DeviceInfoUtil.getDeviceInfoBrand();

    isUnderReview.value = false;

    try {
      final configRaw = gatewayConfig['appBrandConfigMap'];
      final Map<String, dynamic> map =
          Map<String, dynamic>.from(json.decode(configRaw));

      final brandMap = map[Config.appID];
      if (brandMap is Map<String, dynamic>) {
        final config = brandMap[brand];
        if (config is Map<String, dynamic>) {
          final underReviewVersion = config['underReviewVersion'];
          final isMatchVersion = underReviewVersion == packageInfo.version;
          appConfig.addAll(config);
          isUnderReview.value = isMatchVersion;
        }
      }
    } catch (_) {}
  }
}

const Map<String, dynamic> defaultConfig = {
  'defaultMerchantID': '',
  'appBrandConfigMap': '',
};
