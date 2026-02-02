import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dynamic_domain_platform_interface.dart';

/// [DynamicDomainPlatform] 的一个实现，使用 method channel。
class MethodChannelDynamicDomain extends DynamicDomainPlatform {
  /// 用于与原生平台交互的 method channel。
  @visibleForTesting
  final methodChannel = const MethodChannel('dynamic_domain');

  final eventChannel = const EventChannel('dynamic_domain/logs');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<void> init(String appId) async {
    await methodChannel.invokeMethod<void>('init', {'appId': appId});
  }

  @override
  Future<void> setEnv(String key, String value) async {
    await methodChannel.invokeMethod<void>('setEnv', {
      'key': key,
      'value': value,
    });
  }

  @override
  Future<String?> startTunnel(String config) async {
    final result = await methodChannel.invokeMethod<String>('startTunnel', {
      'config': config,
    });
    return result;
  }

  @override
  Future<void> stopTunnel() async {
    await methodChannel.invokeMethod<void>('stopTunnel');
  }

  @override
  Future<void> setSystemProxy(String host, int port) async {
    await methodChannel.invokeMethod<void>('setSystemProxy', {
      'host': host,
      'port': port,
    });
  }

  @override
  Future<void> clearSystemProxy() async {
    await methodChannel.invokeMethod<void>('setSystemProxy', {
      'host': null,
      'port': null,
    });
  }

  @override
  Future<String?> getStats() async {
    return await methodChannel.invokeMethod<String>('getStats');
  }

  @override
  Future<String?> validateConfig(String config) async {
    return await methodChannel.invokeMethod<String>('validateConfig', {
      'config': config,
    });
  }

  @override
  Stream<String> get logs {
    return eventChannel.receiveBroadcastStream().map(
      (event) => event.toString(),
    );
  }
}
