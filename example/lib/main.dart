import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:dynamic_domain/dynamic_domain.dart';
import 'webview_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _platformVersion = '未知';
  String _status = '空闲';
  String _proxyUrl = '';
  String _testResult = '';
  final _appIdController = TextEditingController(text: "123456");
  final _dynamicDomain = DynamicDomain();
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _logSubscription;
  StreamSubscription? _statsSubscription;
  TunnelStats? _currentStats;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _startLogListening();
    _startStatsListening();
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    _statsSubscription?.cancel();
    _scrollController.dispose();
    _appIdController.dispose();
    _dynamicDomain.dispose();
    super.dispose();
  }

  void _startStatsListening() {
    _statsSubscription = _dynamicDomain.stats.listen((stats) {
      if (mounted) {
        setState(() {
          _currentStats = stats;
        });
      }
    });
  }

  void _startLogListening() {
    _logSubscription = _dynamicDomain.logs.listen((log) {
      setState(() {
        _logs.add(log);
      });
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (math.log(bytes) / math.log(1024)).floor();
    return ((bytes / math.pow(1024, i)).toStringAsFixed(2)) + ' ' + suffixes[i];
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await _dynamicDomain.getPlatformVersion() ?? '未知平台版本';
    } on PlatformException {
      platformVersion = '获取平台版本失败。';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _startProxy() async {
    print("[UI] 点击启动代理...");
    setState(() {
      _status = '正在初始化...';
      _logs.add("[UI] 开始初始化流程...");
    });

    try {
      print("[UI] 调用 dynamicDomain.init...");
      await _dynamicDomain.init(_appIdController.text);

      setState(() {
        _status = '正在获取配置...';
        _logs.add("[UI] 初始化完成，开始获取远程配置...");
      });

      // 获取远程配置
      print("[UI] 调用 fetchRemoteConfig...");
      String config = await _dynamicDomain.fetchRemoteConfig(
        _appIdController.text,
      );
      print(
        "[UI] 配置获取成功: ${config.substring(0, math.min(50, config.length))}...",
      );

      setState(() {
        _status = '正在启动隧道...';
        _logs.add("[UI] 成功获取配置，正在启动隧道...");
      });

      final proxyUrl = await _dynamicDomain.startTunnel(config);
      print("[UI] 隧道启动成功: $proxyUrl");

      setState(() {
        _status = '运行中';
        _proxyUrl = proxyUrl;
        _logs.add("[UI] 代理已就绪: $proxyUrl");
      });
    } catch (e, stack) {
      print("[UI] 启动发生异常: $e");
      print("[UI] 堆栈信息: $stack");
      final errorMsg = e.toString();
      setState(() {
        _status = '错误: $errorMsg';
        _logs.add("[ERR] $errorMsg");
      });

      if (errorMsg.contains('Account Forbidden')) {
        _showErrorDialog('应用已停用', '该 AppID 已被禁用、过期或流量超限。请联系管理员确认您的账户状态。');
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _stopProxy() async {
    setState(() {
      _status = '正在停止...';
    });

    try {
      await _dynamicDomain.stopTunnel();
      setState(() {
        _status = '已停止';
        _proxyUrl = '';
        _testResult = '';
      });
    } catch (e) {
      setState(() {
        _status = '错误: $e';
      });
    }
  }

  Future<void> _testConnectivity(String url, String label) async {
    if (_proxyUrl.isEmpty) {
      setState(() {
        _testResult = '请先启动代理';
      });
      return;
    }

    setState(() {
      _testResult = '测试 [$label] 连接中...';
    });

    try {
      final proxyParts = _proxyUrl.split(':');
      final host = proxyParts[0];

      final client = HttpClient();
      // 使用动态分配的端口
      final proxyPort = int.parse(_proxyUrl.split(':')[1]);
      client.findProxy = (uri) {
        return "PROXY $host:$proxyPort";
      };
      client.badCertificateCallback = (cert, host, port) => true;

      final request = await client
          .getUrl(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );
      final responseBody = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 10));

      setState(() {
        _testResult = '[$label] 连接成功! 响应: $responseBody';
        _logs.add("[UI] [$label] 测试成功");
      });
    } catch (e, stack) {
      setState(() {
        _testResult = '[$label] 连接失败: $e';
        _logs.add("[ERR] [$label] 测试失败: ${e.runtimeType}: $e");
        print("[UI] 测试失败详情: $e\n$stack");
      });
    }
  }

  Widget _buildActionButtons() {
    final bool isRunning = _proxyUrl.isNotEmpty;
    final bool isLoading = _status.contains('正在');

    return SizedBox(
      width: 200,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : (isRunning ? _stopProxy : _startProxy),
        style: ElevatedButton.styleFrom(
          backgroundColor: isRunning ? Colors.redAccent : Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 4,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                isRunning ? '停止代理' : '启动代理',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('动态域名 SDK 演示')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 顶部固定内容区域 (可滚动)
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text('运行环境: $_platformVersion'),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _appIdController,
                        decoration: const InputDecoration(
                          labelText: 'App ID (应用ID)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '状态: $_status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _status.startsWith('错误')
                              ? Colors.red
                              : Colors.blue,
                        ),
                      ),
                      if (_proxyUrl.isNotEmpty)
                        Text(
                          '代理地址: $_proxyUrl',
                          style: const TextStyle(fontSize: 14),
                        ),
                      if (_currentStats != null && _proxyUrl.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.arrow_upward,
                                size: 14,
                                color: Colors.blue,
                              ),
                              Text(
                                ' ${_formatBytes(_currentStats!.totalUplink)}',
                              ),
                              const SizedBox(width: 15),
                              const Icon(
                                Icons.arrow_downward,
                                size: 14,
                                color: Colors.green,
                              ),
                              Text(
                                ' ${_formatBytes(_currentStats!.totalDownlink)}',
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 10),
                      if (_proxyUrl.isNotEmpty) ...[
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _testConnectivity(
                                'http://httpbin.org/get',
                                'httpbin (HTTP)',
                              ),
                              icon: const Icon(Icons.http, size: 18),
                              label: const Text('测试 HTTP'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _testConnectivity(
                                'https://httpbin.org/ip',
                                'httpbin (HTTPS)',
                              ),
                              icon: const Icon(Icons.network_check, size: 18),
                              label: const Text('测试 HTTPS'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _testConnectivity(
                                'https://api.ipify.org/',
                                'ipify',
                              ),
                              icon: const Icon(Icons.language, size: 18),
                              label: const Text('测试 ipify'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WebViewPage(
                                      proxyUrl: _proxyUrl,
                                      initialUrl: 'https://ip.gs',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.web, size: 18),
                              label: const Text('WebView'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '日志:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              // 日志显示区域 (固定占位)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.black12,
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return Text(
                        _logs[index],
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (_testResult.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _testResult,
                    style: TextStyle(
                      fontSize: 12,
                      color: _testResult.contains('成功')
                          ? Colors.green
                          : Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
