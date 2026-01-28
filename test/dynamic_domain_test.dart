import 'package:flutter_test/flutter_test.dart';
import 'package:dynamic_domain/dynamic_domain.dart';
import 'package:dynamic_domain/dynamic_domain_platform_interface.dart';
import 'package:dynamic_domain/dynamic_domain_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDynamicDomainPlatform
    with MockPlatformInterfaceMixin
    implements DynamicDomainPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> init(String appId) => Future.value();

  @override
  Future<String?> startTunnel(String config) => Future.value('127.0.0.1:10808');

  @override
  Future<void> stopTunnel() => Future.value();

  @override
  Stream<String> get logs => const Stream.empty();
}

void main() {
  final DynamicDomainPlatform initialPlatform = DynamicDomainPlatform.instance;

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

    await dynamicDomainPlugin.init("test_app_id");
  });

  test('startTunnel', () async {
    DynamicDomain dynamicDomainPlugin = DynamicDomain();
    MockDynamicDomainPlatform fakePlatform = MockDynamicDomainPlatform();
    DynamicDomainPlatform.instance = fakePlatform;

    expect(await dynamicDomainPlugin.startTunnel("{}"), '127.0.0.1:10808');
  });

  test('stopTunnel', () async {
    DynamicDomain dynamicDomainPlugin = DynamicDomain();
    MockDynamicDomainPlatform fakePlatform = MockDynamicDomainPlatform();
    DynamicDomainPlatform.instance = fakePlatform;

    await dynamicDomainPlugin.stopTunnel();
  });
}
