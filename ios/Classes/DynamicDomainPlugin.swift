import Flutter
import UIKit
import Tunnel_core

// 修复编译错误：Gomobile 在 Swift 中生成的协议名称可能不带 Protocol 后缀
// 如果编译失败，尝试使用 Tunnel_coreLogHandler
#if canImport(Tunnel_core)
// 这里我们尝试通过 typealias 兼容不同版本的生成代码
// typealias LogHandlerProtocol = Tunnel_coreLogHandlerProtocol 
#endif

public class DynamicDomainPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var logDelegate: LogDelegate?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "dynamic_domain", binaryMessenger: registrar.messenger())
        let instance = DynamicDomainPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        let eventChannel = FlutterEventChannel(name: "dynamic_domain/logs", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)

        // 设置 Go 的日志处理器
        // 我们需要一个单独的类来继承 NSObject 并实现 Tunnel_coreLogHandlerProtocol
        // 因为 Swift 不支持类的多重继承
        let delegate = LogDelegate()
        instance.logDelegate = delegate // 保持强引用
        delegate.plugin = instance
        Tunnel_coreSetLogHandler(delegate)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "init":
            // let args = call.arguments as? [String: Any]
            // let appId = args?["appId"] as? String
            // 在实际应用中，我们可能会在这里对 appId 做一些处理
            result(nil)
        case "setEnv":
            let args = call.arguments as? [String: Any]
            let key = args?["key"] as? String
            let value = args?["value"] as? String
            Tunnel_coreSetEnv(key, value)
            result(nil)
        case "startTunnel":
            // 启动 Go 隧道
            let args = call.arguments as? [String: Any]
            guard let config = args?["config"] as? String, !config.isEmpty else {
                result(FlutterError(code: "INVALID_CONFIG", message: "Config string is empty", details: nil))
                return
            }
            
            // 简单校验是否为 JSON
            if !config.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("{") {
                result(FlutterError(code: "INVALID_CONFIG", message: "Config is not a valid JSON", details: nil))
                return
            }

            let status = Tunnel_coreStartTunnel(config)
            if status == "success" || status == "already running" {
                result("success")
            } else {
                result(FlutterError(code: "START_FAILED", message: status, details: nil))
            }
        case "stopTunnel":
            Tunnel_coreStopTunnel()
            result(nil)
        case "getStats":
            let stats = Tunnel_coreGetStats()
            result(stats)
        case "validateConfig":
            let args = call.arguments as? [String: Any]
            let config = args?["config"] as? String ?? "{}"
            let status = Tunnel_coreValidateConfig(config)
            result(status)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - FlutterStreamHandler

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    // 内部方法，用于处理来自代理的日志
    fileprivate func sendLog(_ msg: String?) {
        DispatchQueue.main.async {
            self.eventSink?(msg)
        }
    }
}

// 单独的类来处理日志，以避免多重继承问题
// 由于 Swift 中协议与类名冲突，我们尝试通过 extension 或直接声明来解决
// 如果编译失败，说明编译器无法区分 Tunnel_coreLogHandler 类和协议
class LogDelegate: NSObject {
    weak var plugin: DynamicDomainPlugin?
    
    func sendLog(_ msg: String?) {
        plugin?.sendLog(msg)
    }
}

extension LogDelegate: Tunnel_coreLogHandlerProtocol {
    public func onLog(_ msg: String?) {
        self.sendLog(msg)
    }
}
