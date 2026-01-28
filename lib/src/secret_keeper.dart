import 'dart:convert';

/// 安全存储配置解密密钥
/// 使用简单的异或 (XOR) 混淆来防止直接的字符串搜索攻击
class SecretKeeper {
  // --- 混淆后的敏感信息 ---
  // 使用 XOR 混淆，避免字符串在二进制文件中明文出现。

  // Key: qZIO1idZarkYxBqoyvLsHQJmSiT9wGBP
  static const int _keySeed = 165;
  static const List<int> _obfuscatedKey = [
    212,
    252,
    238,
    231,
    152,
    195,
    207,
    246,
    204,
    220,
    196,
    233,
    201,
    240,
    194,
    219,
    204,
    192,
    251,
    203,
    241,
    235,
    241,
    209,
    238,
    215,
    235,
    249,
    182,
    133,
    129,
    148,
  ];

  // --- 配置域名与 API 端点 ---
  // 生产环境建议将以下值也进行混淆存储，就像上面的 Key 一样。
  // 为了方便配置，这里暂时使用明文返回，请在发布前修改为您自己的域名。

  /// DoH 配置域名 (TXT 记录) - 支持多个域名冗余
  static List<String> get configDomains => [
        'domain.zm-tool.me',
        'config.dynamic-domain.org', // 示例备选域名
      ];

  /// DoH 服务商列表
  static List<String> get dohProviders => [
        'https://cloudflare-dns.com/dns-query',
        'https://dns.google/dns-query',
        'https://dns.alidns.com/resolve',
      ];

  /// 主 API 端点
  static String get apiEndpoint => 'https://domain.zm-tool.me/api/v1/endpoints';

  // IV: hryuhrkYaY52AL5r
  static const int _ivSeed = 66;
  static const List<int> _obfuscatedIV = [
    42,
    49,
    61,
    48,
    46,
    53,
    35,
    16,
    43,
    18,
    121,
    127,
    15,
    3,
    101,
    35,
  ];

  // API Key: yOA8NzdGrfWKT4rmowl8i40rW6PhBrHj
  static const int _apiKeySeed = 48;
  static const List<int> _obfuscatedApiKey = [
    73,
    126,
    115,
    11,
    122,
    79,
    82,
    112,
    74,
    95,
    109,
    112,
    104,
    9,
    76,
    82,
    47,
    54,
    46,
    123,
    45,
    113,
    118,
    53,
    31,
    127,
    26,
    35,
    14,
    63,
    6,
    37,
  ];

  // 原始 App ID: "com.example.dynamic_domain"
  static const int _appIdSeed = 0x7B;
  static const List<int> _obfuscatedAppId = [
    24,
    20,
    22,
    85,
    30,
    3,
    26,
    22,
    11,
    23,
    30,
    85,
    31,
    2,
    21,
    26,
    22,
    18,
    24,
    36,
    31,
    20,
    22,
    26,
    18,
    21,
  ];

  /// 获取解密密钥
  static String get encryptionKey => _deobfuscate(_obfuscatedKey, _keySeed);

  /// 获取解密 IV
  static String get encryptionIV => _deobfuscate(_obfuscatedIV, _ivSeed);

  /// 获取 API Key
  static String get apiKey => _deobfuscate(_obfuscatedApiKey, _apiKeySeed);

  /// 获取默认 App ID
  static String get defaultAppId {
    return _deobfuscate(_obfuscatedAppId, _appIdSeed);
  }

  static String _deobfuscate(List<int> data, int seed) {
    final List<int> original = [];
    for (var i = 0; i < data.length; i++) {
      original.add(data[i] ^ (seed + i) % 255);
    }
    return utf8.decode(original);
  }
}
