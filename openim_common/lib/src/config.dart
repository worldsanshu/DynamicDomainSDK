import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:openim_common/openim_common.dart';
import 'package:path_provider/path_provider.dart';

class Config {
  //初始化全局信息
  static Future init(Function() runApp) async {
    try {
      final path = (await getApplicationDocumentsDirectory()).path;
      cachePath = '$path/';
      await DataSp.init();
      await Hive.initFlutter(path);
      HttpUtil.init();
    } catch (_) {}

    runApp();

    // 设置屏幕方向
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 状态栏透明（Android）
    var brightness = Platform.isAndroid ? Brightness.dark : Brightness.light;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: brightness,
      statusBarIconBrightness: brightness,
    ));
  }

  static late String cachePath;
  static const uiW = 375.0;
  static const uiH = 812.0;

  /// 默认公司配置
  static const String deptName = "CNL";

  static const String appName = "CNL";

  /// 全局字体size
  static const double textScaleFactor = 1.0;

  /// 离线消息默认类型
  static OfflinePushInfo offlinePushInfo = OfflinePushInfo(
    title: StrRes.offlineMessage,
    desc: "",
    iOSBadgeCount: true,
    iOSPushSound: '+1',
  );

  static const String defaultInviteCode = "150904";

  /// 二维码：scheme
  static const friendScheme = "x.imserver.xyz/addFriend/";
  static const groupScheme = "x.imserver.xyz/joinGroup/";

  static const appID = "__cnl__";

  // 主域名
  static String get mainGatewayDomain {
    return 'https://api.kelaiguanxin.cloud';
    // return 'https://api.xinchangyou.com';
  }

  // 本地备用域名
  static List<String> get localFallbackGatewayDomains {
    // return ['https://api.xinchangyou.com'];
    return ['https://api.kelaiguanxin.cloud'];
  }

  static const scrambleKey = 'scrambleKey';

  static const iosAppId = '6755507309';

  static String get contactLink => '$mainGatewayDomain/contact';

  static String get privacyPolicyLink =>
      'https://www.tingjunge.com/static/privacy-policy.html';

  static String get serviceAgreementLink =>
      'https://www.tingjunge.com/static/service-agreement.html';

  // trtc
  static const trtcAppID = 1600107550;
  static const trtcDefaultAvatarURL =
      'https://im-statics.oss-cn-shenzhen.aliyuncs.com/user_1.png';

  // getui
  static const gtAppID = 'gNpSbOZQsW7y3gZk1WAmi6';
  static const gtAppKey = 'c8oGq9K9mF6205bJhGyU18';
  static const gtAppSecret = 'd2C6I1ZTgx8ORcJR7hFFD';
  static const gtMasterSecret = 'mnqcAqvvSb9hknCiEN15v2';
  static const gtAliasAsn = 'cnl';

  static int get logLevel {
    String? level;
    var server = DataSp.getServerConfig();
    if (null != server) {
      level = server['logLevel'];
      Logger.print('logLevel: $level');
    }
    return level == null ? 5 : int.parse(level);
  }
}
