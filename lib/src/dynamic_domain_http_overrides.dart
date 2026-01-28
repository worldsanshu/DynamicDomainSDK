import 'dart:io';

/// A helper class to automatically configure global HTTP proxy settings for the app.
///
/// Usage:
/// ```dart
/// HttpOverrides.global = DynamicDomainHttpOverrides(
///   '127.0.0.1',
///   10809,
///   bypassHosts: ['baidu.com', 'qq.com'],
/// );
/// ```
class DynamicDomainHttpOverrides extends HttpOverrides {
  final String proxyHost;
  final int proxyPort;
  final bool allowBadCertificates;

  /// List of domains that should bypass the proxy and connect directly.
  /// Supports exact match or suffix match (e.g., ".cn").
  final List<String> bypassHosts;

  // Common Chinese domains that should usually bypass proxy
  static const List<String> defaultCommonCnHosts = [
    '.cn',
    'qq.com',
    'baidu.com',
    'taobao.com',
    'alipay.com',
    'aliyun.com',
    'jd.com',
    '163.com',
    '126.com',
    'sina.com.cn',
    'weibo.com',
    'bilibili.com',
    'zhihu.com',
    'meituan.com',
    'dianping.com',
    'pinduoduo.com',
    'amap.com', // Gaode Map
    'map.baidu.com',
    'gtimg.com', // Tencent
    'bdstatic.com', // Baidu
  ];

  DynamicDomainHttpOverrides(
    this.proxyHost,
    this.proxyPort, {
    this.allowBadCertificates = false,
    List<String>? bypassHosts,
  }) : bypassHosts = bypassHosts ?? defaultCommonCnHosts;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.findProxy = (uri) {
      if (_shouldBypass(uri.host)) {
        return "DIRECT";
      }
      return "PROXY $proxyHost:$proxyPort";
    };

    if (allowBadCertificates) {
      client.badCertificateCallback = (cert, host, port) => true;
    }

    return client;
  }

  bool _shouldBypass(String host) {
    if (host == 'localhost' || host == '127.0.0.1' || host == '::1') {
      return true;
    }

    for (final domain in bypassHosts) {
      if (domain.startsWith('.')) {
        // Suffix match (e.g., .cn matches www.gov.cn)
        if (host.endsWith(domain)) {
          return true;
        }
      } else {
        // Exact match or subdomain match
        if (host == domain || host.endsWith('.$domain')) {
          return true;
        }
      }
    }
    return false;
  }
}
