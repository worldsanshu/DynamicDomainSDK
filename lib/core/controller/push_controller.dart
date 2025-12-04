// ignore_for_file: unused_field

import 'dart:async';
import 'dart:io';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:getuiflut/getuiflut.dart';
import 'package:openim_common/openim_common.dart';

class PushController extends GetxController {
  final String _platformVersion = 'Unknown';
  String _payloadInfo = 'Null';
  String _notificationState = "";
  String _getClientId = "";
  String _getDeviceToken = "";
  String _onReceivePayload = "";
  String _onReceiveNotificationResponse = "";
  String _onAppLinkPayLoad = "";
  final Getuiflut _getui = Getuiflut();

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> init() async {
    Logger.print('=======================推送初始化=====================');
    Permissions.notification();
    initGetuiSdk();
    // iOS 配置, 安卓配置build.gradle文件
    if (Platform.isIOS) {
      Getuiflut().startSdk(
        appId: Config.gtAppID,
        appKey: Config.gtAppKey,
        appSecret: Config.gtAppSecret,
      );
    }

    _getui.addEventHandler(
      onReceiveOnlineState: (res) async {},
      // 注册收到 cid 的回调
      onReceiveClientId: (String message) async {
        Logger.print("Getui flutter onReceiveClientId: $message");
        _getClientId = "ClientId: $message";
        setTag(DataSp.getSavedInviteCode() ?? Config.defaultInviteCode, Config.gtAliasAsn);
      },

      onNotificationMessageArrived: (Map<String, dynamic> msg) async {
        Logger.print("Getui flutter onNotificationMessageArrived: $msg");
        _notificationState = 'Arrived';
      },
      onNotificationMessageClicked: (Map<String, dynamic> msg) async {
        Logger.print("Getui flutter onNotificationMessageClicked: $msg");
        _notificationState = 'Clicked';
      },
      // 注册 DeviceToken 回调
      onRegisterDeviceToken: (String message) async {
        Logger.print("Getui flutter onRegisterDeviceToken: $message");
        _getDeviceToken = message;
      },
      // SDK收到透传消息回调
      onReceivePayload: (Map<String, dynamic> message) async {
        Logger.print("Getui flutter onReceivePayload: $message");
        _onReceivePayload = "$message";
      },
      // 点击通知回调
      onReceiveNotificationResponse: (Map<String, dynamic> message) async {
        Logger.print("Getui flutter onReceiveNotificationResponse: $message");
        _onReceiveNotificationResponse = "$message";
      },
      // APPLink中携带的透传payload信息
      onAppLinkPayload: (String message) async {
        Logger.print("Getui flutter onAppLinkPayload: $message");
        _onAppLinkPayLoad = message;
      },
      // 通知服务开启\关闭回调
      onPushModeResult: (Map<String, dynamic> message) async {
        Logger.print("Getui flutter onPushModeResult: $message");
      },
      // SetTag回调
      onSetTagResult: (Map<String, dynamic> message) async {
        Logger.print("Getui flutter onSetTagResult: $message");
      },
      // 设置别名回调
      onAliasResult: (Map<String, dynamic> message) async {
        Logger.print("Getui flutter onAliasResult: $message");
      },
      // 查询Tag回调
      onQueryTagResult: (Map<String, dynamic> message) async {
        Logger.print("Getui flutter onQueryTagResult: $message");
      },
      // APNs通知即将展示回调
      onWillPresentNotification: (Map<String, dynamic> message) async {
        Logger.print("Getui flutter onWillPresentNotification: $message");
      },
      // APNs通知设置跳转回调
      onOpenSettingsForNotification: (Map<String, dynamic> message) async {
        Logger.print("Getui flutter onOpenSettingsForNotification: $message");
      },
      onTransmitUserMessageReceive: (Map<String, dynamic> event) async {
        Logger.print("Getui flutter onTransmitUserMessageReceive: $event");
      },
      onGrantAuthorization: (String event) async {
        Logger.print("Getui flutter onLiveActivityResult: $event");
      },
      onLiveActivityResult: (Map<String, dynamic> event) async {
        Logger.print("Getui flutter onLiveActivityResult: $event");
      },

      onRegisterPushToStartTokenResult: (Map<String, dynamic> result) async {
        Logger.print("Getui flutter onRegisterPushToStartTokenResult: $result");
      },
    );
  }

  /// 初始化个推sdk
  Future<void> initGetuiSdk() async {
    try {
      _getui.initGetuiSdk;
    } catch (e) {
      e.toString();
    }
  }

  ///////////SDK Public Function//////////

  void activityCreate() {
    Getuiflut().onActivityCreate();
  }

  Future<void> getClientId() async {
    String getClientId;
    try {
      getClientId = await _getui.getClientId;
      Logger.print(getClientId);
    } catch (e) {
      Logger.print(e.toString());
    }
  }

  /// 仅android 停止SDK服务
  void stopPush() {
    Getuiflut().turnOffPush();
  }

  /// 开启SDK服务
  void startPush() {
    Getuiflut().turnOnPush();
  }

  ///
  /// 绑定别名功能:后台可以根据别名进行推送
  /// alias 别名字符串
  /// aSn   绑定序列码, Android中无效，仅在iOS有效
  void login(String uid) {
    Getuiflut().bindAlias(uid, Config.gtAliasAsn);
  }

  void logout() {
    Getuiflut().unbindAlias(OpenIM.iMManager.userID, Config.gtAliasAsn, true);
  }

  /// 给用户打标签 , 后台可以根据标签进行推送
  void setTag(String tag, String sn) {
    List<String> tags = List.filled(1, tag);
    Getuiflut().setTag(tags, sn);
  }

  ////////////ios Public Function////////////

  /// 仅ios 同步服务端角标
  static void setBadge(int badge) {
    Getuiflut().setBadge(badge);
  }

  /// 仅ios 同步App本地角标
  void setLocalBadge() {
    Getuiflut().setLocalBadge(0);
  }

  /// 仅ios 复位服务端角标
  static void resetBadge() {
    Getuiflut().resetBadge();
  }

  /// 仅ios
  void setPushMode() {
    Getuiflut().setPushMode(0);
  }

  /// 获取冷启动Apns参数
  Future<void> getLaunchNotification() async {
    // ignore: unused_local_variable
    Map _info;
    try {
      _info = await _getui.getLaunchNotification;
    } catch (e) {
      Logger.print(e.toString());
    }
  }
}
