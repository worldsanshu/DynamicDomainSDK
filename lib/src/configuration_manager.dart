import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';

import 'secret_keeper.dart';

/// 管理从多个来源获取最新的代理配置。
class ConfigurationManager {
  // 备份配置 URL (可选)
  static const String _backupUrl =
      'https://raw.githubusercontent.com/your-org/dynamic_domain/main/config_backup.json';

  // 种子配置（硬编码回退）- 生产环境建议移除或使用真实可用的备用节点
  // 如果此配置无效，客户端将无法连接。
  static const String _seedConfig = '';

  static const String _configCacheFileName = 'dynamic_domain_config_cache.json';
  static const Duration _cacheTtl = Duration(hours: 1);

  /// 获取配置，尝试顺序：DoH -> 主 API -> 备份 -> 本地缓存 -> 种子。
  Future<String> fetchConfig([String? appId]) async {
    final targetAppId = appId ?? SecretKeeper.defaultAppId;

    // 1. 优先尝试本地缓存（检查有效期）
    final cachedData = await _loadConfigFromCache(checkTtl: true);
    if (cachedData != null) {
      print('Using valid local cache.');
      return cachedData;
    }

    String? fetchedConfig;

    // 2. 尝试并发 DoH (DNS over HTTPS) - 最快响应获胜
    try {
      print('Fetching config via concurrent DoH racing...');
      fetchedConfig = await _fetchFromDoHWithRacing();
    } catch (e) {
      print('DoH racing failed: $e');
    }

    // 3. 尝试主 API (如果 DoH 失败)
    if (fetchedConfig == null) {
      try {
        print('Fetching config from Primary API...');
        final response = await http
            .get(
              Uri.parse(
                '${SecretKeeper.apiEndpoint}?app_id=$targetAppId&api_key=${SecretKeeper.apiKey}',
              ),
            )
            .timeout(const Duration(seconds: 10)); // 增加超时时间
        if (response.statusCode == 200) {
          try {
            final json = jsonDecode(response.body);
            if (json is Map && json['code'] == 0 && json['data'] != null) {
              // 标准 API 响应
              fetchedConfig = _decryptConfig(json['data']['config']);
            } else {
              // 兼容旧版或直接返回配置的情况
              fetchedConfig = _decryptConfig(response.body);
            }
          } catch (e) {
            // 如果解析 JSON 失败，或者解密失败，保留原始错误信息
            throw Exception(
              'API request failed or returned invalid format: $e. Response body: ${response.body}',
            );
          }
        } else if (response.statusCode == 403) {
          // 账户被禁用或无效 (由服务端 Handler 返回)
          throw Exception(
            'Account Forbidden (403): 该 AppID 已被禁用、过期或流量超限。请联系管理员。',
          );
        } else if (response.statusCode == 401) {
          throw Exception(
            'Unauthorized (401): SDK 配置的 API Key 错误，请检查 SecretKeeper 设置。',
          );
        } else if (response.statusCode == 503) {
          throw Exception('Service Unavailable (503): 服务端目前没有可用节点，请稍后再试。');
        } else {
          print(
            'API Request failed: ${response.statusCode} - ${response.body}',
          );
        }
      } catch (e) {
        print('Primary API failed: $e');
        // 如果是明确的业务逻辑错误（权限、禁用、无节点），则不再尝试其他来源，直接抛出
        final errStr = e.toString();
        if (errStr.contains('Account Forbidden') ||
            errStr.contains('Unauthorized') ||
            errStr.contains('Service Unavailable')) {
          rethrow;
        }
      }
    }

    // 3. 尝试备份 (如果前两者都失败)
    if (fetchedConfig == null) {
      try {
        print('Fetching config from Backup (GitHub)...');
        final response = await http
            .get(Uri.parse(_backupUrl))
            .timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          // 假设备份文件也是加密的
          fetchedConfig = _decryptConfig(response.body);
        }
      } catch (e) {
        print('Backup failed: $e');
      }
    }

    // 如果成功获取到配置，保存到缓存并返回
    if (fetchedConfig != null) {
      await _saveConfigToCache(fetchedConfig);
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

  Future<void> _saveConfigToCache(String config) async {
    try {
      final directory = await getApplicationSupportDirectory();
      final file = File('${directory.path}/$_configCacheFileName');
      final data = {
        'config': config,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      print("Failed to save config to cache: $e");
    }
  }

  Future<String?> _loadConfigFromCache({bool checkTtl = false}) async {
    try {
      final directory = await getApplicationSupportDirectory();
      final file = File('${directory.path}/$_configCacheFileName');
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);

        if (data is Map && data.containsKey('config')) {
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
    } catch (_) {
      // 忽略单个失败
    }
    return null;
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
        .get(uri, headers: {'Accept': 'application/dns-json'})
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
