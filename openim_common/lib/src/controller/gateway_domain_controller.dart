import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class GatewayDomainController extends GetxController {
  // 当前使用的域名
  final RxString currentDomain = Config.mainGatewayDomain.obs;

  // 不可用域名
  final Map<String, bool> unavailableDomainsMap = {};

  // 尝试顺序列表（服务器 + 本地）
  final List<String> _tryList = [];

  // 全部域名
  List<String> get fullList {
    final set = {
      Config.mainGatewayDomain,
      ..._serverList,
      ...Config.localFallbackGatewayDomains
    };

    return [
      if (initCurrentDomain != null) initCurrentDomain!,
      ...set.where((d) => d != initCurrentDomain),
    ];
  }

  final _serverList = <String>[].obs;

  int _tryListInitLength = 0;

  String? initCurrentDomain;

  final numberTextMap = {
    1: '一',
    2: '二',
    3: '三',
    4: '四',
    5: '五',
    6: '六',
    7: '七',
    8: '八',
    9: '九',
    10: '十',
    11: '十一',
    12: '十二',
    13: '十三',
    14: '十四',
    15: '十五',
  };

  Map<String, String> get domainNumberMap {
    final Map<String, String> map = {};
    for (int i = 0; i < fullList.length; i++) {
      final domain = fullList[i];
      map[domain] = '线路${numberTextMap[i + 1] ?? (i + 1)}';
    }
    return map;
  }

  /// 点击超过10次显示域名
  final RxInt _domainClickCount = 0.obs;
  final int _domainRevealClickThreshold = 10;
  bool get _shouldRevealDomain =>
      _domainClickCount.value >= _domainRevealClickThreshold;

  String getDomainLabel(String domain) {
    final label = domainNumberMap[domain] ?? '';
    return _shouldRevealDomain ? '$label $domain' : label;
  }

  String get currentDomainDisplayText {
    return _shouldRevealDomain
        ? currentDomain.value
        : domainNumberMap[currentDomain.value] ?? '粘贴板线路';
  }

  void requestDomainReveal() {
    _domainClickCount.value =
        _shouldRevealDomain ? 0 : _domainClickCount.value + 1;
  }

  String? _checkedClipboardDomain;

  @override
  void onInit() {
    // DataSp.clearCurrentGatewayDomain();
    init();
    super.onInit();
  }

  // 初始化
  Future<void> init() async {
    initCurrentDomain = currentDomain.value =
        DataSp.getCurrentGatewayDomain() ?? Config.mainGatewayDomain;
    final serverList = DataSp.getFallbackGatewayDomains()!;
    _serverList.value = serverList;
    _tryList
      ..clear()
      ..addAll({
        ...serverList,
        ...Config.localFallbackGatewayDomains,
        if (initCurrentDomain != Config.mainGatewayDomain)
          Config.mainGatewayDomain
      });
    _tryListInitLength = _tryList.length;
  }

  /// 切换到下一个域名
  bool switchToNext() {
    _tryList.remove(currentDomain.value);
    if (_tryList.isEmpty) {
      return false;
    }
    currentDomain.value = _tryList.removeAt(0);
    return true;
  }

  /// 用户手动选择域名
  bool switchTo(String domain) {
    if (domain == currentDomain.value) {
      return false;
    }
    if (_tryListInitLength == _tryList.length) {
      _tryList.insert(0, initCurrentDomain!);
    }
    currentDomain.value = domain;
    return true;
  }

  /// 成功之后保存当前域名到本地
  void saveCurrentDomainToLocal() {
    DataSp.putCurrentGatewayDomain(currentDomain.value);
    if (_checkedClipboardDomain != null) {
      Clipboard.setData(const ClipboardData(text: ''));
    }
  }

  /// 失败之后保存到列表
  void saveUnavailableDomain() {
    unavailableDomainsMap[currentDomain.value] = true;
  }

  /// 上报不可用域名
  Future<void> reportUnavailableDomains() async {
    if (unavailableDomainsMap.isNotEmpty) {
      await GatewayApi.reportUnavailableDomains(
        urls: unavailableDomainsMap.keys.toList(),
      ).catchError((_) {});
    }
  }

  /// 刷新服务器备用域名
  Future<void> refreshFallbackGatewayDomains() async {
    final result = await GatewayApi.getDomainList();
    _serverList.value = result;
    DataSp.putFallbackGatewayDomains(result);
  }

  Future<bool> trySwitchToClipboardDomain() async {
    final domain = await getDomainFromClipboard();
    if (domain == null) {
      return false;
    }
    var confirm = await CustomDialog.show(
          title: StrRes.newRouteDetected,
          content: StrRes.switchToThisRoute,
        );

    if (confirm == true) {
      switchTo(domain);
      _checkedClipboardDomain = domain;
      return true;
    }
    return false;
  }

  /// 从剪贴板获取域名
  Future<String?> getDomainFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      final text = clipboardData?.text ?? '';

      if (text.isEmpty) {
        return null;
      }
      final decrypted = restoreNonAlphabets(scrambleDecrypt(text));

      final regex = RegExp(
        r'(https?:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,})',
        caseSensitive: false,
      );

      final match = regex.firstMatch(decrypted);
      if (match != null) {
        return match.group(1);
      }
    } catch (e) {
      Logger.print('Error reading clipboard: $e', isError: true);
    }
    return null;
  }

  // 解密函数
  String scrambleDecrypt(String input) {
    final perm = generatePermutation(Config.scrambleKey, input.length);
    final chars = List.filled(input.length, '');
    for (int i = 0; i < input.length; i++) {
      chars[perm[i]] = input[i];
    }
    return chars.join();
  }

  // 加密函数
  String scrambleEncrypt(String input) {
    // 替换非字母字符
    input = replaceNonAlphabets(input);

    final perm = generatePermutation(Config.scrambleKey, input.length);
    final chars = List.filled(input.length, '');
    for (int i = 0; i < input.length; i++) {
      chars[i] = input[perm[i]];
    }
    return chars.join();
  }

  // 用于生成排列的函数
  List<int> generatePermutation(String key, int length) {
    final hash = key.codeUnits.fold(0, (prev, e) => prev * 31 + e);
    final indices = List.generate(length, (i) => i);
    for (int i = 0; i < length; i++) {
      final swapIndex = (hash + i * 7) % length;
      final tmp = indices[i];
      indices[i] = indices[swapIndex];
      indices[swapIndex] = tmp;
    }
    return indices;
  }

  // 符号替换的映射规则，使用字母代替符号
  String replaceNonAlphabets(String input) {
    final replacements = {
      '://': 'aaa',
      '.': 'bbb',
    };

    for (var entry in replacements.entries) {
      input = input.replaceAll(entry.key, entry.value);
    }
    return input;
  }

  // 恢复符号的函数
  String restoreNonAlphabets(String input) {
    final replacements = {
      'aaa': '://',
      'bbb': '.',
    };

    for (var entry in replacements.entries) {
      input = input.replaceAll(entry.key, entry.value);
    }
    return input;
  }
}
