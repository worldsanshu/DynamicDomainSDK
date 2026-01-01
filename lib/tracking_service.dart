import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

// 在iOS上，这个功能通常用于请求App Tracking Transparency (ATT)授权，以便在应用中追踪用户行为，
// 用于广告定位等目的。如果用户同意，应用可以使用设备的广告标识符（IDFA）进行追踪；如果不同意，应用则无法获取该信息。
// 在原生代码中，会有对应的实现来处理Flutter通过这个通道发出的请求。
class TrackingService {
  static const MethodChannel _channel = MethodChannel('com.example/tracking');

  static Future<void> requestTrackingAuthorizationIfNeeded() async {
    final status = await getTrackingStatus();

    if (status == 'notDetermined') {
      await CustomDialog.show(
        title: StrRes.personalizedAdDescription,
        content: StrRes.personalizedAdContent,
        showCancel: false,
      );
      await requestTrackingAuthorization();
    } else {
      Logger.print(
          "No need to request ATT authorization, current status: $status");
    }
  }

  static Future<void> requestTrackingAuthorization() async {
    try {
      final result =
          await _channel.invokeMethod<String>('requestTrackingAuthorization');
      Logger.print("ATT authorization result: $result");
    } on PlatformException catch (e) {
      Logger.print("Failed to request tracking authorization: '${e.message}'.");
    }
  }

  static Future<String?> getTrackingStatus() async {
    try {
      final result =
          await _channel.invokeMethod<String>('getTrackingAuthorizationStatus');
      Logger.print("Current ATT authorization status: $result");
      return result;
    } catch (e) {
      Logger.print("Failed to get ATT authorization status: $e");
      return null;
    }
  }
}
