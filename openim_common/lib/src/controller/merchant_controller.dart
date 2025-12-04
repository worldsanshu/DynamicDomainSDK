// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class MerchantController extends GetxController {
  var currentIMServerInfo = IMServerInfo(
    merchantID: 0,
    wsAddr: '',
    apiAddr: '',
    chatAddr: '',
    name: '',
    ip: '',
  ).obs;

  List<IMServerInfo> fallbackServerInfoList = [];

  int get currentMerchantID => currentIMServerInfo.value.merchantID;

  @override
  void onInit() {
    final main = DataSp.getMainServer();
    if (main != null) {
      currentIMServerInfo.value = main;
      print('=============**** MERCHANT ****===============> ${main.name}');
      print('=============**** MERCHANT IP ****===============> ${main.ip}');
    }
    fallbackServerInfoList = DataSp.getFallbackServers();
    print(
        '=============**** BACKUPS ****===============> ${fallbackServerInfoList.length}');
    super.onInit();
  }

  void updateCurrentIMServer({
    MerchantServers? servers,
    IMServerInfo? main,
    List<IMServerInfo>? fallbacks,
  }) async {
    if (servers != null) {
      main = servers.main;
      fallbacks = servers.fallback;
    }

    if (main == null) return;

    currentIMServerInfo.value = main;
    await DataSp.putMainServer(main);

    if (fallbacks != null) {
      await DataSp.putFallbackServers(fallbacks);
    }
  }

  Future<void> updateMainServer(IMServerInfo main) async {
    currentIMServerInfo.value = main;
    await DataSp.putMainServer(main);
  }

  Future<void> updateFallbackServers(List<IMServerInfo> fallbacks) async {
    fallbackServerInfoList = fallbacks;
    await DataSp.putFallbackServers(fallbacks);
  }
}
