# Dynamic Domain SDK (Flutter)

Dynamic Domain SDK 是一个专业的 Flutter 插件，用于在移动应用中集成抗封锁、高可用的网络代理功能。它集成了 Xray 核心，支持自动化的配置获取、节点优选、本地代理隧道建立，并提供对原生 WebView 的流量接管能力。

## 主要功能

*   **抗封锁隧道**: 基于 Xray-core (VLESS/REALITY 等协议)，提供稳健的加密隧道。
*   **智能配置分发**:
    *   支持 DoH (DNS over HTTPS) 隐蔽获取配置。
    *   支持远程 API 动态拉取。
    *   支持 GitHub 备用配置源。
    *   支持本地缓存和硬编码种子配置，确保离线或极端环境下的可用性。
*   **自动端口管理**: 自动寻找本地空闲端口，避免冲突。
*   **智能分流 (Bypass)**: 内置常用国内域名白名单（如 BAT、银行等），自动直连不走代理，提升访问速度并规避风控。
*   **WebView 深度集成**: 提供 Android 系统级代理设置和 WebView 内核代理注入，确保 Web 业务也能享受抗封锁能力。
*   **全局代理助手**: 一键接管 App 内所有 `HttpClient` 请求。

## 集成指南

> **重要**: 本项目使用 Git LFS 存储原生依赖库（.aar, .xcframework）。Clone 后务必执行以下命令以确保文件完整：
> ```bash
> git lfs install
> git lfs pull
> ```
> *如果您不想使用 LFS，也可以将其配置为普通大文件提交，但请注意这会显著增加仓库体积。*

### 1. 安装

在你的 `pubspec.yaml` 中添加：

```yaml
dependencies:
  dynamic_domain:
    path: ./path/to/dynamic_domain # 或者 git 依赖
```

### 2. 初始化与启动

```dart
import 'package:dynamic_domain/dynamic_domain.dart';

final dynamicDomain = DynamicDomain();

// 1. 初始化 (自动准备资源)
await dynamicDomain.init("YOUR_APP_ID");

// 2. 获取配置
// SDK 会自动按优先级尝试：DoH -> API -> Backup -> Cache -> Seed
final config = await dynamicDomain.fetchRemoteConfig();

// 3. 启动隧道
// 返回代理地址，例如 "127.0.0.1:54321"
final proxyUrl = await dynamicDomain.startTunnel(config);
print("Tunnel started at: $proxyUrl");

// 4. 接管 Flutter 全局网络请求
// bypassHosts: 可选，覆盖默认的国内域名白名单
dynamicDomain.setGlobalProxy(
  proxyUrl,
  bypassHosts: ['.cn', 'baidu.com', 'myserver.com'], // 自定义白名单
);
```

### 3. WebView 集成 (Android)

对于需要显示网页的场景（如通过 WebView 访问被墙的资源），需要进行额外的设置以确保流量走代理。

推荐使用 `flutter_inappwebview` 配合 SDK 使用：

```dart
import 'dart:io';
import 'package:dynamic_domain/dynamic_domain.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future<void> setupWebViewProxy(String proxyUrl) async {
  final dynamicDomain = DynamicDomain();
  
  // 解析代理地址
  final parts = proxyUrl.split(':');
  final host = parts[0];
  final port = int.parse(parts[1]);

  // [关键步骤 1] 设置 Android 系统级代理 (对部分原生组件和 Java 网络栈生效)
  await dynamicDomain.setSystemProxy(host, port);

  // [关键步骤 2] 设置 WebView 内核代理 (使用 flutter_inappwebview)
  final proxyController = ProxyController.instance();
  await proxyController.setProxyOverride(
    settings: ProxySettings(
      proxyRules: [
        ProxyRule(url: "$host:$port", schemeFilter: ProxySchemeFilter.MATCH_HTTP),
        ProxyRule(url: "$host:$port", schemeFilter: ProxySchemeFilter.MATCH_HTTPS),
      ],
      bypassSimpleHostnames: true,
    ),
  );
}

// 在页面销毁时清理
void dispose() {
  if (Platform.isAndroid) {
    DynamicDomain().clearSystemProxy(); // 清理系统代理
    ProxyController.instance().clearProxyOverride(); // 清理 WebView 代理
  }
}
```

## API 接口文档

### `DynamicDomain`

核心类，负责 SDK 的主要功能。

#### `init([String? appId])`
初始化 SDK。
*   `appId`: (可选) 应用 ID，用于配置获取时的身份验证。若不传则使用默认 ID。
*   **返回值**: `Future<void>`
*   **说明**: 此方法会准备本地资源（如 GeoIP 数据库）并初始化原生组件。

#### `fetchRemoteConfig([String? appId])`
获取远程代理配置。
*   `appId`: (可选) 应用 ID。
*   **返回值**: `Future<String>` (加密后的配置字符串)
*   **说明**: 内部实现了自动重试和多级回退机制（DoH -> API -> GitHub -> 本地缓存 -> 种子配置）。

#### `startTunnel(String config, {int maxRetries = 3})`
启动本地代理隧道。
*   `config`: Xray JSON 配置字符串。
*   `maxRetries`: (可选) 启动失败时的最大重试次数，默认为 3。
*   **返回值**: `Future<String>` (本地代理地址，如 `127.0.0.1:10809`)
*   **说明**: 自动寻找空闲端口，并将其注入到配置中。启动后会自动进行端口连通性检查。

#### `stopTunnel()`
停止代理隧道。
*   **返回值**: `Future<void>`
*   **说明**: 停止 Xray 核心进程，并清理 Android 端的系统代理设置（如有）。

#### `setGlobalProxy(String proxyUrl, {bool allowBadCertificates = false, List<String>? bypassHosts})`
设置 Flutter 全局 HTTP 代理。
*   `proxyUrl`: 代理地址 (host:port)。
*   `allowBadCertificates`: 是否允许不安全的 SSL 证书（仅用于测试），默认为 `false`。
*   `bypassHosts`: (可选) 需要直连的域名白名单。
*   **说明**: 调用此方法后，App 内所有通过 `HttpClient` 发起的请求都会走代理，除非目标域名在 `bypassHosts` 中。

#### `isConnectionHealthy({String testUrl})`
检查代理连接是否健康。
*   `testUrl`: 用于测试的目标 URL，默认为 Google Generate 204。
*   **返回值**: `Future<bool>`

#### `setSystemProxy(String host, int port)` (Android Only)
设置 Android 系统级 HTTP 代理属性。
*   **说明**: 主要用于辅助 WebView 或其他原生组件识别代理。

#### `clearSystemProxy()` (Android Only)
清除 Android 系统级 HTTP 代理属性。

## 架构说明

*   **Dart 层**: 负责业务逻辑、配置管理、HttpOverrides 全局拦截和分流判定。
*   **Native 层 (Kotlin/Swift)**: 负责启动 Go 编写的 `tunnel_core` 动态库，管理后台服务保活。
*   **Go Core**: 封装 Xray-core，负责实际的代理协议握手和流量转发。

## 排障与常见问题

### 1. 启动或获取配置超时 (TimeoutException)
如果您在初始化或调用 `fetchRemoteConfig` 时遇到超时，请检查：
- **基础联网**: 确保设备（尤其是 Android 模拟器）能够正常访问互联网。
- **模拟器设置**: 部分 Android 模拟器（如 Genymotion 或部分版本的 AVD）需要手动设置系统代理或 DNS 才能正常访问海外 DoH 服务。
- **网络权限**: 确保 `AndroidManifest.xml` 中已声明 `INTERNET` 权限。

### 2. Android 类冲突
如果在集成 OpenIM 等同样基于 Gomobile 的 SDK 时报错 `Duplicate class go.Seq`，请参考以下步骤：
- **常规方案**: 在 `android/app/build.gradle` 中配置 `packagingOptions { pickFirst 'go/Seq.class' ... }`。
- **终极方案**: 如果 D8 依然报错 `Duplicate class`（合并 DEX 失败），说明冲突类已硬编码在 AAR 内。需通过脚本物理移除 `tunnel_core.aar` 中的 `go/` 目录。
  ```bash
  # 剥离脚本核心逻辑
  mkdir temp && unzip tunnel_core.aar -d temp
  mkdir temp/jar && unzip temp/classes.jar -d temp/jar
  rm -rf temp/jar/go/  # 移除重复运行时
  cd temp/jar && zip -r ../classes.jar . && cd ..
  zip -r ../tunnel_core_stripped.aar .
  ```
- 详细指南请访问 [官网集成指南](https://domain.zm-tool.me/guide/openim#android-依赖冲突处理)。

## 注意事项

*   **Android 权限**: 确保 `AndroidManifest.xml` 中声明了网络权限。
*   **iOS 限制**: iOS 系统的 WebView 代理设置较为严格，通常只能通过 NetworkExtension 实现系统级 VPN，本 SDK 目前主要通过 `HttpOverrides` 接管 App 内发起的网络请求。

## License

MIT
