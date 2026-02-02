import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'dynamic_domain_method_channel.dart';

abstract class DynamicDomainPlatform extends PlatformInterface {
  /// 构造 DynamicDomainPlatform。
  DynamicDomainPlatform() : super(token: _token);

  static final Object _token = Object();

  static DynamicDomainPlatform _instance = MethodChannelDynamicDomain();

  /// 默认使用的 [DynamicDomainPlatform] 实例。
  ///
  /// 默认为 [MethodChannelDynamicDomain]。
  static DynamicDomainPlatform get instance => _instance;

  /// 平台特定的实现应该在注册自己时
  /// 使用它们自己的扩展了 [DynamicDomainPlatform] 的平台特定类来设置它。
  static set instance(DynamicDomainPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> init(String appId) {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<void> setEnv(String key, String value) {
    throw UnimplementedError('setEnv() has not been implemented.');
  }

  Future<String?> startTunnel(String config) {
    throw UnimplementedError('startTunnel() has not been implemented.');
  }

  Future<void> stopTunnel() {
    throw UnimplementedError('stopTunnel() has not been implemented.');
  }

  Future<void> setSystemProxy(String host, int port) {
    throw UnimplementedError('setSystemProxy() has not been implemented.');
  }
  
  Future<void> clearSystemProxy() {
    throw UnimplementedError('clearSystemProxy() has not been implemented.');
  }

  Future<String?> getStats() {
    throw UnimplementedError('getStats() has not been implemented.');
  }

  Future<String?> validateConfig(String config) {
    throw UnimplementedError('validateConfig() has not been implemented.');
  }

  Stream<String> get logs {
    throw UnimplementedError('logs has not been implemented.');
  }
}
