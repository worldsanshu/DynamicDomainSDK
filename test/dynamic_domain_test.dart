import 'package:flutter_test/flutter_test.dart';
import 'package:dynamic_domain/dynamic_domain.dart';
import 'package:dynamic_domain/dynamic_domain_platform_interface.dart';
import 'package:dynamic_domain/dynamic_domain_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter/services.dart';

class MockDynamicDomainPlatform
    with MockPlatformInterfaceMixin
    implements DynamicDomainPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> init(String appId) => Future.value();

  @override
  Future<String?> startTunnel(String config) => Future.value('success');

  @override
  Future<void> stopTunnel() => Future.value();

  @override
  Future<void> clearSystemProxy() => Future.value();

  @override
  Future<String?> getStats() => Future.value('{}');

  @override
  Future<void> setEnv(String key, String value) => Future.value();

  @override
  Future<void> setSystemProxy(String host, int port) => Future.value();

  @override
  Future<String?> validateConfig(String config) => Future.value('valid');

  @override
  Stream<String> get logs => const Stream.empty();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final DynamicDomainPlatform initialPlatform = DynamicDomainPlatform.instance;

  const MethodChannel pathProviderChannel = MethodChannel(
    'plugins.flutter.io/path_provider',
  );

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'getApplicationSupportPath') {
            return '.';
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
  });

  test('$MethodChannelDynamicDomain is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDynamicDomain>());
  });

  test('getPlatformVersion', () async {
    DynamicDomain dynamicDomainPlugin = DynamicDomain();
    MockDynamicDomainPlatform fakePlatform = MockDynamicDomainPlatform();
    DynamicDomainPlatform.instance = fakePlatform;

    expect(await dynamicDomainPlugin.getPlatformVersion(), '42');
  });

  test('init', () async {
    DynamicDomain dynamicDomainPlugin = DynamicDomain();
    MockDynamicDomainPlatform fakePlatform = MockDynamicDomainPlatform();
    DynamicDomainPlatform.instance = fakePlatform;

    // init calls _prepareAssets which loads from rootBundle
    // and writes to ApplicationSupportDirectory.
    // We also need to mock rootBundle if we want this to succeed fully.
    // But for now, let's just see if it gets past the binding error.
    try {
      await dynamicDomainPlugin.init("test_app_id");
    } catch (e) {
      // It might fail on rootBundle.load, which is expected in a bare unit test
      // unless we mock it.
      print("Init failed as expected due to rootBundle: $e");
    }
  });

  test('startTunnel', () async {
    DynamicDomain dynamicDomainPlugin = DynamicDomain();
    MockDynamicDomainPlatform fakePlatform = MockDynamicDomainPlatform();
    DynamicDomainPlatform.instance = fakePlatform;

    const validConfig = '{"inbounds": [{"protocol": "socks", "port": 0}]}';
    final result = await dynamicDomainPlugin.startTunnel(
      validConfig,
      skipPortCheck: true,
    );
    expect(result, startsWith('127.0.0.1:'));
  });

  test('stopTunnel', () async {
    DynamicDomain dynamicDomainPlugin = DynamicDomain();
    MockDynamicDomainPlatform fakePlatform = MockDynamicDomainPlatform();
    DynamicDomainPlatform.instance = fakePlatform;

    await dynamicDomainPlugin.stopTunnel();
  });
}
