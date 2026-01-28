import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dynamic_domain_platform_interface.dart';
import 'src/configuration_manager.dart';
import 'src/dynamic_domain_http_overrides.dart';

import 'src/secret_keeper.dart';

export 'src/dynamic_domain_http_overrides.dart';
export 'src/configuration_manager.dart';

class DynamicDomain {
  final _configManager = ConfigurationManager();
  int? _currentHttpPort;
  int? _currentSocksPort;
  bool _isTransitioning = false;

  /// 获取当前 HTTP 代理端口
  int? get httpPort => _currentHttpPort;

  /// 获取当前 SOCKS5 代理端口
  int? get socksPort => _currentSocksPort;

  /// 获取结构化的代理配置信息，方便第三方 SDK (如 OpenIM) 接入
  ProxyConfig? getProxyConfig() {
    if (_currentHttpPort == null || _currentSocksPort == null) return null;
    return ProxyConfig(
      host: '127.0.0.1',
      httpPort: _currentHttpPort!,
      socksPort: _currentSocksPort!,
    );
  }

  Future<String?> getPlatformVersion() {
    return DynamicDomainPlatform.instance.getPlatformVersion();
  }

  /// 使用给定的 App ID 初始化 SDK。
  /// 这将自动尝试从远程源获取最新的配置。
  ///
  /// 如果 [appId] 为空，将使用内置的默认 App ID。
  Future<void> init([String? appId]) async {
    if (_isTransitioning) throw Exception("SDK is busy with another operation");
    _isTransitioning = true;
    try {
      final targetAppId = appId ?? SecretKeeper.defaultAppId;

      // 1. 准备资源（将 geoip/geosite 复制到文件系统）
      await _prepareAssets();

      // 2. 初始化原生平台
      await DynamicDomainPlatform.instance.init(targetAppId);
    } finally {
      _isTransitioning = false;
    }
  }

  Future<void> _prepareAssets() async {
    // 获取我们可以放置文件的目录（例如，Application Support 或 FilesDir）
    final directory = await getApplicationSupportDirectory();
    final assetPath = directory.path;

    // 告诉 Xray 核心去哪里寻找资源
    await DynamicDomainPlatform.instance.setEnv(
      "xray.location.asset",
      assetPath,
    );

    // 将文件从 Flutter 资源复制到文件系统
    for (final fileName in ["geoip.dat", "geosite.dat"]) {
      final file = File('$assetPath/$fileName');

      // 检查文件是否存在以避免不必要的写入
      if (!await file.exists()) {
        try {
          final data = await rootBundle.load(
            'packages/dynamic_domain/assets/$fileName',
          );
          final bytes = data.buffer.asUint8List();
          await file.writeAsBytes(bytes, flush: true);
        } catch (e) {
          throw Exception("Failed to copy asset $fileName: $e");
        }
      }
    }
  }

  /// 获取远程配置（带有回退逻辑）。
  ///
  /// 如果 [appId] 为空，将使用内置的默认 App ID。
  Future<String> fetchRemoteConfig([String? appId]) {
    return _configManager.fetchConfig(appId);
  }

  /// 启动隧道并返回本地代理 URL（例如 "127.0.0.1:12345"）。
  /// [config] 是 Xray JSON 配置字符串。
  ///
  /// 此方法包含重试机制，会自动寻找空闲端口。
  Future<String> startTunnel(String config, {int maxRetries = 3}) async {
    if (_isTransitioning) throw Exception("SDK is busy with another operation");
    _isTransitioning = true;
    try {
      int attempts = 0;
      String? lastError;

      while (attempts < maxRetries) {
        attempts++;
        try {
          // 在内部方法中执行实际逻辑，不在这里设置 _isTransitioning
          return await _startTunnelInternal(config);
        } catch (e) {
          lastError = e.toString();
          print("Start tunnel attempt $attempts failed: $e. Retrying...");
          // 在重试前清理
          await DynamicDomainPlatform.instance.stopTunnel();
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      throw Exception(
        "Failed to start tunnel after $maxRetries attempts. Last error: $lastError",
      );
    } finally {
      _isTransitioning = false;
    }
  }

  Future<String> _startTunnelInternal(String config) async {
    // 1. 找到一个空闲端口
    final int port = await _findFreePort();
    final int httpPort = await _findFreePort(startPort: port + 1);

    _currentSocksPort = port;
    _currentHttpPort = httpPort;

    // 2. 将端口注入到配置中 (使用 JSON 解析)
    String finalConfig;
    try {
      final jsonConfig = jsonDecode(config) as Map<String, dynamic>;

      // 注入入站端口
      if (jsonConfig.containsKey('inbounds') &&
          jsonConfig['inbounds'] is List) {
        final inbounds = jsonConfig['inbounds'] as List;
        bool socksFound = false;
        bool httpFound = false;

        for (var inbound in inbounds) {
          if (inbound is Map) {
            final protocol = inbound['protocol'];
            if (protocol == 'socks') {
              inbound['port'] = port;
              socksFound = true;
            } else if (protocol == 'http') {
              inbound['port'] = httpPort;
              httpFound = true;
            }
          }
        }

        // 如果没有找到明确的协议，回退到按顺序注入
        if (!socksFound && !httpFound) {
          if (inbounds.isNotEmpty) inbounds[0]['port'] = port;
          if (inbounds.length > 1) inbounds[1]['port'] = httpPort;
        }
      } else {
        throw Exception("Invalid config: 'inbounds' not found or not a list");
      }

      finalConfig = jsonEncode(jsonConfig);
    } catch (e) {
      throw Exception("Failed to inject ports into config: $e");
    }

    // 3. 使用原生调用启动隧道
    final result = await DynamicDomainPlatform.instance.startTunnel(
      finalConfig,
    );

    // 如果原生返回成功
    if (result != null &&
        (result.contains("success") || result.contains("127.0.0.1"))) {
      // 4. 验证端口是否真的在监听
      if (await _waitForPort(httpPort)) {
        return "127.0.0.1:$httpPort";
      } else {
        throw Exception("Tunnel started but port $httpPort is not accessible");
      }
    }

    throw Exception("Failed to start tunnel: $result");
  }

  /// 等待端口变为可用 (Listening)
  Future<bool> _waitForPort(
    int port, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < timeout) {
      try {
        final socket = await Socket.connect(
          '127.0.0.1',
          port,
          timeout: const Duration(milliseconds: 200),
        );
        await socket.close(); // 正常关闭
        socket.destroy(); // 确保销毁
        return true;
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    return false;
  }

  /// 在本地机器上找到一个空闲端口。
  Future<int> _findFreePort({int startPort = 0}) async {
    ServerSocket? socket;
    try {
      socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, startPort);
      return socket.port;
    } catch (e) {
      if (startPort != 0) return _findFreePort(startPort: 0);
      return 10808; // 最后的兜底
    } finally {
      await socket?.close();
    }
  }

  /// 停止隧道。
  Future<void> stopTunnel() async {
    if (_isTransitioning) return; // 已经在操作中
    _isTransitioning = true;
    try {
      _currentHttpPort = null;
      _currentSocksPort = null;
      await DynamicDomainPlatform.instance.stopTunnel();
      if (Platform.isAndroid) {
        await DynamicDomainPlatform.instance.clearSystemProxy();
      }
    } finally {
      _isTransitioning = false;
    }
  }

  /// 设置系统级代理 (仅 Android 支持，可能需要特定权限或仅对部分应用生效)
  /// 这主要用于尝试让 WebView 自动识别代理。
  Future<void> setSystemProxy(String host, int port) async {
    if (Platform.isAndroid) {
      await DynamicDomainPlatform.instance.setSystemProxy(host, port);
    }
  }

  /// 清除系统级代理
  Future<void> clearSystemProxy() async {
    if (Platform.isAndroid) {
      await DynamicDomainPlatform.instance.clearSystemProxy();
    }
  }

  /// 设置全局 HTTP 代理覆盖
  /// [proxyUrl] 应该是 "host:port" 格式，通常由 [startTunnel] 返回。
  /// [bypassHosts] 可以覆盖默认的 CN 域名白名单。
  void setGlobalProxy(
    String proxyUrl, {
    bool allowBadCertificates = false,
    List<String>? bypassHosts,
  }) {
    final parts = proxyUrl.split(':');
    if (parts.length == 2) {
      final host = parts[0];
      final port = int.tryParse(parts[1]);
      if (port != null) {
        HttpOverrides.global = DynamicDomainHttpOverrides(
          host,
          port,
          allowBadCertificates: allowBadCertificates,
          bypassHosts: bypassHosts,
        );
      }
    }
  }

  /// 检查当前连接是否健康
  /// 尝试通过代理访问一个轻量级目标（如 Google Generate 204 或类似）
  Future<bool> isConnectionHealthy({
    String testUrl = 'https://www.google.com/generate_204',
  }) async {
    if (_currentHttpPort == null) return false;

    try {
      final client = HttpClient();
      client.findProxy = (uri) {
        return "PROXY 127.0.0.1:$_currentHttpPort";
      };
      // 忽略证书错误 (对于代理测试通常不需要，但为了稳健性)
      client.badCertificateCallback = (cert, host, port) => true;

      final request = await client
          .getUrl(Uri.parse(testUrl))
          .timeout(const Duration(seconds: 5));
      final response = await request.close();

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print("Health check failed: $e");
      return false;
    }
  }

  /// 从 SDK 获取日志流。
  Stream<String> get logs {
    return DynamicDomainPlatform.instance.logs;
  }
}

/// 代理配置信息类
class ProxyConfig {
  final String host;
  final int httpPort;
  final int socksPort;

  ProxyConfig({
    required this.host,
    required this.httpPort,
    required this.socksPort,
  });

  /// 获取 HTTP 代理 URL (例如 "127.0.0.1:10809")
  String get httpUrl => '$host:$httpPort';

  /// 获取 SOCKS5 代理 URL (例如 "127.0.0.1:10808")
  String get socksUrl => '$host:$socksPort';

  /// 将代理配置应用到当前进程的环境变量中。
  /// 这对于使用 Go (如 OpenIM)、C++ 等原生代码编写的 SDK 非常有效，
  /// 因为它们通常会读取 ALL_PROXY, HTTP_PROXY 等环境变量。
  Future<void> applyToEnvironment() async {
    final proxyString = 'socks5://$socksUrl';
    final httpProxyString = 'http://$httpUrl';

    // 设置全协议代理 (SOCKS5 优先级最高)
    await DynamicDomainPlatform.instance.setEnv('ALL_PROXY', proxyString);
    await DynamicDomainPlatform.instance.setEnv('all_proxy', proxyString);

    // 设置 HTTP/HTTPS 代理作为备选
    await DynamicDomainPlatform.instance.setEnv('HTTP_PROXY', httpProxyString);
    await DynamicDomainPlatform.instance.setEnv('http_proxy', httpProxyString);
    await DynamicDomainPlatform.instance.setEnv('HTTPS_PROXY', httpProxyString);
    await DynamicDomainPlatform.instance.setEnv('https_proxy', httpProxyString);

    print("Proxy applied to environment via native setEnv: $proxyString");
  }

  @override
  String toString() => 'ProxyConfig(HTTP: $httpUrl, SOCKS5: $socksUrl)';
}
