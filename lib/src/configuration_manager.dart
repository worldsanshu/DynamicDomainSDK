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

  /// 获取配置，尝试顺序：DoH -> 主 API -> 备份 -> 本地缓存 -> 种子。
  Future<String> fetchConfig([String? appId]) async {
    final targetAppId = appId ?? SecretKeeper.defaultAppId;
    String? fetchedConfig;

    // 1. 尝试 DoH (DNS over HTTPS) - 遍历所有域名和服务商
    try {
      for (final domain in SecretKeeper.configDomains) {
        if (fetchedConfig != null) break;

        for (final provider in SecretKeeper.dohProviders) {
          try {
            print('Fetching config via DoH ($domain) from $provider...');
            final dohConfig = await _fetchFromDoH(domain, provider);
            if (dohConfig != null && dohConfig.isNotEmpty) {
              fetchedConfig = _decryptConfig(dohConfig);
              if (fetchedConfig != null) break;
            }
          } catch (e) {
            print('DoH fetch failed ($domain @ $provider): $e');
          }
        }
      }
    } catch (e) {
      print('DoH logic failed: $e');
    }

    // 2. 尝试主 API (如果 DoH 失败)
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
            // 如果解析 JSON 失败，可能返回的是纯文本错误
            throw Exception('API returned invalid format: ${response.body}');
          }
        } else {
          print(
            'API Request failed: ${response.statusCode} - ${response.body}',
          );
        }
      } catch (e) {
        print('Primary API failed: $e');
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
      await file.writeAsString(config);
    } catch (e) {
      print("Failed to save config to cache: $e");
    }
  }

  Future<String?> _loadConfigFromCache() async {
    try {
      final directory = await getApplicationSupportDirectory();
      final file = File('${directory.path}/$_configCacheFileName');
      if (await file.exists()) {
        final config = await file.readAsString();
        // 简单验证一下是否是 JSON
        jsonDecode(config);
        return config;
      }
    } catch (e) {
      print("Failed to load config from cache: $e");
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
      // GCM 模式通常使用 12 字节 Nonce
      final nonce = iv.bytes.length > 12 ? iv.bytes.sublist(0, 12) : iv.bytes;

      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.gcm),
      );
      result = encrypter.decrypt64(encryptedBase64, iv: encrypt.IV(nonce));
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
        'Decrypted configuration is not a valid JSON. The data might be corrupted or the key might be wrong.',
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
