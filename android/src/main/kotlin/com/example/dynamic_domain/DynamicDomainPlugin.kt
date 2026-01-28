package com.example.dynamic_domain

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import tunnel_core.Tunnel_core
import tunnel_core.LogHandler
import android.os.Handler
import android.os.Looper

/** DynamicDomainPlugin */
class DynamicDomainPlugin :
    FlutterPlugin,
    MethodCallHandler,
    EventChannel.StreamHandler {
    // 用于 Flutter 和 Android 原生之间通信的 MethodChannel
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "dynamic_domain")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "dynamic_domain/logs")
        eventChannel.setStreamHandler(this)

        // 设置 Go 的日志处理器
        Tunnel_core.setLogHandler(object : LogHandler {
            override fun onLog(msg: String?) {
                mainHandler.post {
                    eventSink?.success(msg)
                }
            }
        })
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "init" -> {
                val appId = call.argument<String>("appId")
                // 在实际应用中，我们可能会在这里对 appId 做一些处理
                result.success(null)
            }
            "setEnv" -> {
                val key = call.argument<String>("key")
                val value = call.argument<String>("value")
                Tunnel_core.setEnv(key, value)
                result.success(null)
            }
            "startTunnel" -> {
                // 从参数获取配置
                val config = call.argument<String>("config") ?: "{}"
                
                // 启动前台服务以保持进程存活
                val serviceIntent = Intent(context, TunnelService::class.java)
                ContextCompat.startForegroundService(context, serviceIntent)

                // 注意：网络操作应该在后台线程上进行，但 Go 会启动自己的 goroutines。
                // 但是，gomobile 调用可能会阻塞。
                val status = Tunnel_core.startTunnel(10808, config)
                if (status == "success" || status == "already running") {
                     result.success("127.0.0.1:10808")
                } else {
                     result.error("START_FAILED", status, null)
                }
            }
            "stopTunnel" -> {
                Tunnel_core.stopTunnel()
                // 停止服务
                val serviceIntent = Intent(context, TunnelService::class.java)
                context.stopService(serviceIntent)
                
                result.success(null)
            }
            "setSystemProxy" -> {
                val host = call.argument<String>("host")
                val port = call.argument<Int>("port")
                
                if (host != null && port != null) {
                    System.setProperty("http.proxyHost", host)
                    System.setProperty("http.proxyPort", port.toString())
                    System.setProperty("https.proxyHost", host)
                    System.setProperty("https.proxyPort", port.toString())
                } else {
                    System.clearProperty("http.proxyHost")
                    System.clearProperty("http.proxyPort")
                    System.clearProperty("https.proxyHost")
                    System.clearProperty("https.proxyPort")
                }
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
