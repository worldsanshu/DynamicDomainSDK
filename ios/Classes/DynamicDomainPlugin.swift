import Flutter
import UIKit
import Tunnel_core

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
            let config = args?["config"] as? String ?? "{}"
            let status = Tunnel_coreStartTunnel(10808, config)
            if status == "success" || status == "already running" {
                result("127.0.0.1:10808")
            } else {
                result(FlutterError(code: "START_FAILED", message: status, details: nil))
            }
        case "stopTunnel":
            Tunnel_coreStopTunnel()
            result(nil)
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
// LogDelegate 遵循 Tunnel_coreLogHandlerProtocol 协议
class LogDelegate: NSObject, Tunnel_coreLogHandlerProtocol {
    weak var plugin: DynamicDomainPlugin?
    
    func onLog(_ msg: String?) {
        plugin?.sendLog(msg)
    }
}
