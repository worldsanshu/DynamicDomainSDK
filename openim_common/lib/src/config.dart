import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dynamic_domain/dynamic_domain.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:openim_common/openim_common.dart';
import 'package:path_provider/path_provider.dart';

class Config {
  //初始化全局信息
  static bool _isDynamicDomainInitializing = false;

  static Future init(Function() runApp) async {
    // 1. 优先启动隧道，确保动态域名解析生效
    if (!_isDynamicDomainInitializing) {
      _isDynamicDomainInitializing = true;
      try {
        Logger.print("Config.init: 正在尝试优先启动 Dynamic Domain 隧道...");
        // 使用带超时保护的初始化，确保隧道不会无限期挂起启动流程
        await _initDynamicDomain().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            Logger.print("Dynamic Domain 初始化超时 (15s)，为保证应用启动，降级走普通网络流程");
          },
        );
      } catch (e) {
        Logger.print("Dynamic Domain 初始化发生致命错误 (已降级): $e");
      } finally {
        _isDynamicDomainInitializing = false;
      }
    }

    // 2. 后续其他操作 (Hive, DataSp 等)
    try {
      final path = (await getApplicationDocumentsDirectory()).path;
      cachePath = '$path/';
      await DataSp.init();
      await Hive.initFlutter(path);
      HttpUtil.init();

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
    } catch (e) {
      Logger.print("核心组件初始化发生严重错误: $e");
    }

    runApp();
  }

  static late String cachePath;

  static const dynamicDomainAppId =
      "b174015e-2b75-41ee-af1b-087f7b8a5264"; // TODO: 替换为实际的 App ID
  static String? proxyUrl;

  static Future<void> _initDynamicDomain() async {
    try {
      // 检查是否为模拟器，模拟器暂不支持部分 FFI 功能
      if (Platform.isIOS) {
        final deviceInfo = DeviceInfoPlugin();
        final iosInfo = await deviceInfo.iosInfo;
        if (!iosInfo.isPhysicalDevice) {
          Logger.print("检测到 iOS 模拟器，跳过 Dynamic Domain 初始化以防止崩溃");
          return;
        }
      }

      Logger.print("开始初始化 Dynamic Domain...");
      final dynamicDomain = DynamicDomain();
      Logger.print("正在调用 dynamicDomain.init($dynamicDomainAppId)...");
      await dynamicDomain.init(dynamicDomainAppId);

      Logger.print("正在获取远程配置...");
      final config = await dynamicDomain.fetchRemoteConfig(dynamicDomainAppId);

      Logger.print("正在启动隧道...");
      await dynamicDomain.startTunnel(config);

      // 获取代理配置并应用到环境变量（OpenIM Go 核心会自动读取）
      Logger.print("正在获取代理配置...");
      final proxy = dynamicDomain.getProxyConfig();
      if (proxy != null) {
        proxyUrl = proxy.socksUrl;
        Logger.print("正在注入环境变量...");
        await proxy.applyToEnvironment();
        Logger.print("Dynamic Domain 隧道已启动，SOCKS5 代理: $proxyUrl");
      } else {
        Logger.print("警告: 隧道已启动但未获取到代理配置");
      }
    } catch (e) {
      Logger.print("Dynamic Domain 初始化发生异常: $e");
    }
  }

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

  static const String defaultInviteCode = "123789";

  /// 二维码：scheme
  static const friendScheme = "x.imserver.xyz/addFriend/";
  static const groupScheme = "x.imserver.xyz/joinGroup/";

  static const appID = "__cnl__";

  // 主域名
  static String get mainGatewayDomain {
    return 'https://api.spdkvfb.cn';
    // return 'https://api.kelaiguanxin.cloud';
  }

  // 本地备用域名
  static List<String> get localFallbackGatewayDomains {
    return ['https://api.spdkvfb.cn'];
    // return ['https://api.kelaiguanxin.cloud'];
  }

  static const scrambleKey = 'scrambleKey';

  static const iosAppId = '_';

  static String get contactLink => '$mainGatewayDomain/contact';

  static String get privacyPolicyLink => 'https://www.google.com/';

  static String get serviceAgreementLink => 'https://www.google.com/';

  static String get personalInfoListLink => 'https://www.google.com/';

  static String get thirdPartSdksLink => 'https://www.google.com/';

  /// 工信部ICP备案号
  static const String icpRecordNumber = "鄂ICP备xxxxxx";

  /// 工信部ICP备案查询地址
  static const String icpRecordQueryUrl = "https://beian.miit.gov.cn/";

  // trtc
  static const trtcAppID = 1600107550;
  static const trtcDefaultAvatarURL =
      'https://im-statics.oss-cn-shenzhen.aliyuncs.com/user_1.png';

  // getui
  static const gtAppID = '_';
  static const gtAppKey = '_';
  static const gtAppSecret = '_';
  static const gtMasterSecret = '_';
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
