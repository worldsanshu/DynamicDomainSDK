import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:dynamic_domain/dynamic_domain.dart';

class WebViewPage extends StatefulWidget {
  final String proxyUrl;
  final String initialUrl;

  const WebViewPage({
    super.key,
    required this.proxyUrl,
    this.initialUrl = 'https://ip.gs',
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? webViewController;
  late InAppWebViewSettings settings;
  final TextEditingController _urlController = TextEditingController();
  final List<String> _logs = [];
  final ScrollController _logScrollController = ScrollController();
  StreamSubscription? _logSubscription;
  final _dynamicDomain = DynamicDomain();

  @override
  void initState() {
    super.initState();
    _urlController.text = widget.initialUrl;
    
    settings = InAppWebViewSettings(
      isInspectable: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true,
    );

    if (Platform.isAndroid) {
      _setAndroidProxy();
    }
    _startLogListening();
  }

  void _startLogListening() {
    _logSubscription = _dynamicDomain.logs.listen((log) {
      if (!mounted) return;
      setState(() {
        _logs.add(log);
      });
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_logScrollController.hasClients) {
          _logScrollController.animateTo(
            _logScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  Future<void> _setAndroidProxy() async {
    String proxyHost = "127.0.0.1";
    int proxyPort = 10809;
    
    if (widget.proxyUrl.isNotEmpty) {
      final parts = widget.proxyUrl.split(':');
      if (parts.length == 2) {
        proxyHost = parts[0];
        // Use the dynamic port (Note: This is SOCKS port + 1)
        // But widget.proxyUrl is "127.0.0.1:10809" (HTTP) already if constructed correctly in main.dart
        proxyPort = int.tryParse(parts[1]) ?? 10809;
      }
    }
    
    // 1. Set System Property Proxy via our plugin (affects Java net stack and potentially some WebViews)
    await _dynamicDomain.setSystemProxy(proxyHost, proxyPort);

    // 2. Set WebView specific proxy via flutter_inappwebview
    final proxyController = ProxyController.instance();
    await proxyController.setProxyOverride(
      settings: ProxySettings(
        proxyRules: [
          ProxyRule(url: "$proxyHost:$proxyPort", schemeFilter: ProxySchemeFilter.MATCH_HTTP),
          ProxyRule(url: "$proxyHost:$proxyPort", schemeFilter: ProxySchemeFilter.MATCH_HTTPS),
        ],
        bypassSimpleHostnames: true,
      ),
    );
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    _urlController.dispose();
    _logScrollController.dispose();
    if (Platform.isAndroid) {
      // Clear proxy when leaving
      ProxyController.instance().clearProxyOverride();
      _dynamicDomain.clearSystemProxy();
    }
    super.dispose();
  }

  void _loadUrl() {
    final url = _urlController.text;
    if (url.isNotEmpty && webViewController != null) {
      webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView Proxy Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              webViewController?.reload();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (Platform.isIOS)
            Container(
              color: Colors.amber.shade100,
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                "注意: iOS WebView 代理设置需要系统级配置生效。此处仅 Android 支持应用内 WebView 代理。",
                style: TextStyle(color: Colors.brown),
              ),
            ),
          // URL Input Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'URL',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onSubmitted: (_) => _loadUrl(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _loadUrl,
                ),
              ],
            ),
          ),
          // WebView
          Expanded(
            flex: 2,
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
              initialSettings: settings,
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
            ),
          ),
          const Divider(height: 1, thickness: 1),
          // Logs
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Logs:", style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () {
                            setState(() {
                              _logs.clear();
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _logScrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Text(
                          _logs[index],
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
