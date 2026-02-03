import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';

import 'secret_keeper.dart';

/// 管理从多个来源获取最新的代理配置。
class ConfigurationManager {
  // 种子配置（硬编码回退）- 生产环境建议移除或使用真实可用的备用节点
  // 如果此配置无效，客户端将无法连接。
  static const String _seedConfig = '';

  static const String _configCacheFileName = 'dynamic_domain_config_cache.json';
  static const Duration _cacheTtl = Duration(hours: 1);

  /// 获取配置，尝试顺序：DoH -> 主 API -> 备份 -> 本地缓存 -> 种子。
  Future<String> fetchConfig([String? appId]) async {
    final targetAppId = appId ?? SecretKeeper.defaultAppId;
    final headers = {
      'User-Agent': _getMaskedUserAgent(),
      'Accept': 'application/json',
    };

    // 1. 优先尝试本地缓存（检查有效期，且必须匹配当前 AppID）
    final cachedData = await _loadConfigFromCache(
      appId: targetAppId,
      checkTtl: true,
    );
    if (cachedData != null) {
      print('Using valid local cache for AppID: $targetAppId');
      return cachedData;
    }

    String? fetchedConfig;

    // 2. 尝试并发 DoH (DNS over HTTPS) - 最快响应获胜
    try {
      print('Fetching config via concurrent DoH racing...');
      fetchedConfig = await _fetchFromDoHWithRacing();
      if (fetchedConfig != null) {
        print('Config fetched from DoH (Note: DoH skips AppID validation).');
      }
    } catch (e) {
      print('DoH racing failed: $e');
    }

    // 3. 尝试主 API (支持多个冗余端点轮询)
    if (fetchedConfig == null) {
      print('Fetching config from Primary APIs (Redundancy Mode)...');
      for (final endpoint in SecretKeeper.apiEndpoints) {
        try {
          print('Trying API endpoint: $endpoint');
          final response = await http
              .get(
                Uri.parse(
                  '$endpoint?app_id=$targetAppId&api_key=${SecretKeeper.apiKey}',
                ),
                headers: headers,
              )
              .timeout(const Duration(seconds: 8));

          if (response.statusCode == 200) {
            try {
              final json = jsonDecode(response.body);
              if (json is Map && json['code'] == 0 && json['data'] != null) {
                fetchedConfig = _decryptConfig(json['data']['config']);
              } else {
                fetchedConfig = _decryptConfig(response.body);
              }
              if (fetchedConfig != null) {
                print('Successfully fetched config from: $endpoint');
                break; // 成功获取，跳出循环
              }
            } catch (e) {
              print('Failed to parse/decrypt response from $endpoint: $e');
            }
          } else if (response.statusCode == 403) {
            // 账户级别错误，通常是全局性的，不再尝试其他端点
            String errorDetail = '该 AppID 已被禁用、过期或流量超限。';
            try {
              final json = jsonDecode(response.body);
              if (json is Map && json.containsKey('code')) {
                final code = json['code'];
                if (code == 40301) errorDetail = '该应用已被禁用，请联系管理员。';
                if (code == 40302) errorDetail = '该应用已过期，请及时续费。';
                if (code == 40303) errorDetail = '该应用流量已超限，请升级套餐。';
              }
            } catch (e) {
              print("[ConfigurationManager] Error parsing error response: $e");
            }
            throw Exception('Account Forbidden (403): $errorDetail');
          } else if (response.statusCode == 401) {
            // API Key 错误也是全局性的
            throw Exception(
              'Unauthorized (401): SDK 配置的 API Key 错误，请检查 SecretKeeper 设置。',
            );
          } else {
            print('Endpoint $endpoint returned status: ${response.statusCode}');
          }
        } catch (e) {
          print('Request to $endpoint failed: $e');
          if (e.toString().contains('Account Forbidden') ||
              e.toString().contains('Unauthorized')) {
            rethrow; // 业务级错误直接抛出
          }
          // 其他网络错误，继续尝试下一个端点
        }
      }
    }

    // 3. 尝试备份 (支持多个冗余 URL 轮询)
    if (fetchedConfig == null) {
      print('Fetching config from Backup URLs (Redundancy Mode)...');
      for (final url in SecretKeeper.backupUrls) {
        try {
          print('Trying Backup URL: $url');
          final response = await http
              .get(Uri.parse(url))
              .timeout(const Duration(seconds: 5));
          if (response.statusCode == 200) {
            // 假设备份文件也是加密的
            fetchedConfig = _decryptConfig(response.body);
            if (fetchedConfig != null) {
              print('Successfully fetched config from Backup: $url');
              break;
            }
          }
        } catch (e) {
          print('Backup request to $url failed: $e');
        }
      }
    }

    // 如果成功获取到配置，保存到缓存并返回
    if (fetchedConfig != null) {
      await _saveConfigToCache(fetchedConfig, targetAppId);
      return fetchedConfig;
    }

    // 4. 尝试从本地缓存加载
    print('Fetching from network failed, trying local cache...');
    final cachedConfig = await _loadConfigFromCache();
    if (cachedConfig != null) {
      print('Loaded config from local cache.');
      return cachedConfig;
    }

    if (_seedConfig.isNotEmpty) {
      print('Using Seed Config.');
      return _seedConfig;
    }

    throw Exception(
      'Failed to fetch config from all sources (DoH, API, Backup, Cache, Seed).',
    );
  }

  Future<String?> _getDirectoryPath() async {
    try {
      final directory = await getApplicationSupportDirectory();
      return directory.path;
    } catch (e) {
      print("[ConfigurationManager] 警告: getApplicationSupportDirectory 失败: $e");
      if (Platform.isAndroid) {
        // 备选方案
        return "/data/user/0/com.dynamic.domain.example/app_flutter";
      }
      return null;
    }
  }

  Future<void> _saveConfigToCache(String config, String appId) async {
    try {
      final path = await _getDirectoryPath();
      if (path == null) return;
      final file = File('$path/$_configCacheFileName');
      final data = {
        'app_id': appId,
        'config': config,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      print("Failed to save config to cache: $e");
    }
  }

  Future<String?> _loadConfigFromCache({
    String? appId,
    bool checkTtl = false,
  }) async {
    try {
      final path = await _getDirectoryPath();
      if (path == null) return null;
      final file = File('$path/$_configCacheFileName');
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);

        if (data is Map && data.containsKey('config')) {
          // 如果传入了 appId，则必须匹配
          if (appId != null && data['app_id'] != appId) {
            print('Cache AppID mismatch: ${data['app_id']} != $appId');
            return null;
          }

          final config = data['config'] as String;

          if (checkTtl && data.containsKey('timestamp')) {
            final timestamp = data['timestamp'] as int;
            final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            if (DateTime.now().difference(cachedTime) > _cacheTtl) {
              print('Cache expired.');
              return null;
            }
          }

          // 简单验证一下是否是 JSON
          jsonDecode(config);
          return config;
        }
      }
    } catch (e) {
      print("Failed to load config from cache: $e");
    }
    return null;
  }

  /// 并发请求所有 DoH 组合，返回最快的一个有效结果
  Future<String?> _fetchFromDoHWithRacing() async {
    final List<Future<String?>> tasks = [];

    for (final domain in SecretKeeper.configDomains) {
      for (final provider in SecretKeeper.dohProviders) {
        tasks.add(_fetchAndDecrypt(domain, provider));
      }
    }

    if (tasks.isEmpty) return null;

    // 使用 Completer 来实现第一个成功的 Future 返回
    final completer = Completer<String?>();
    int failedCount = 0;

    for (var task in tasks) {
      task
          .then((result) {
            if (result != null && !completer.isCompleted) {
              completer.complete(result);
            } else {
              failedCount++;
              if (failedCount == tasks.length && !completer.isCompleted) {
                completer.complete(null);
              }
            }
          })
          .catchError((e) {
            failedCount++;
            if (failedCount == tasks.length && !completer.isCompleted) {
              completer.complete(null);
            }
          });
    }

    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () => null,
    );
  }

  Future<String?> _fetchAndDecrypt(String domain, String provider) async {
    try {
      final encrypted = await _fetchFromDoH(domain, provider);
      if (encrypted != null && encrypted.isNotEmpty) {
        return _decryptConfig(encrypted);
      }
    } catch (e) {
      // 忽略单个失败，但可以记录日志用于调试
      print(
        "[ConfigurationManager] DoH fetch failed for $domain via $provider: $e",
      );
    }
    return null;
  }

  /// 生成伪装的 User-Agent，区分平台且不包含项目特色
  String _getMaskedUserAgent() {
    if (Platform.isAndroid) {
      // 模拟通用的 Android Chrome UA
      return 'Mozilla/5.0 (Linux; Android 13; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36';
    } else if (Platform.isIOS) {
      // 模拟通用的 iOS Safari UA
      return 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 Safari/604.1';
    }
    // 回退到通用 UA
    return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36';
  }

  /// 解密配置字符串
  String _decryptConfig(String encryptedBase64) {
    String result = encryptedBase64;
    try {
      // 如果字符串以 '{' 开头，说明是明文 JSON，无需解密
      final trimmed = encryptedBase64.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        return trimmed;
      }

      final key = encrypt.Key.fromUtf8(SecretKeeper.encryptionKey);
      final iv = encrypt.IV.fromUtf8(SecretKeeper.encryptionIV);

      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );
      result = encrypter.decrypt64(encryptedBase64, iv: iv);
    } catch (e) {
      throw Exception(
        'Configuration decryption failed. Please check your encryption key and IV. Error: $e',
      );
    }

    // 验证结果是否为有效 JSON
    try {
      jsonDecode(result);
      return result;
    } catch (e) {
      throw Exception(
        'Decrypted configuration is not a valid JSON. The data might be corrupted or the key might be wrong. Decrypted snippet: ${result.length > 50 ? result.substring(0, 50) : result}',
      );
    }
  }

  /// 通过 DoH 查询 TXT 记录以获取配置。
  /// TXT 记录应包含 base64 编码的配置或 URL。
  Future<String?> _fetchFromDoH(String domain, String provider) async {
    // 构建 TXT 记录的 DoH 查询
    final uri = Uri.parse('$provider?name=$domain&type=TXT');

    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/dns-json',
            'User-Agent': _getMaskedUserAgent(),
          },
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      // 检查 Answer 部分是否存在
      if (json.containsKey('Answer')) {
        final answers = json['Answer'] as List;
        for (var answer in answers) {
          if (answer['type'] == 16) {
            // TXT 记录类型是 16
            String data = answer['data'];
            // TXT 记录通常带有引号，移除引号
            data = data.replaceAll('"', '');

            // 在实际场景中，此数据可能是 Base64 编码或加密的。
            // 目前，我们假设它只是一个字符串，或者如果我们没有真正的域名设置，它可能是空的。
            if (data.startsWith('{')) {
              return data; // 它是 JSON
            }
            // 如果它是 base64，请在此处解码：
            // return utf8.decode(base64Decode(data));
          }
        }
      }
    }
    return null;
  }
}
