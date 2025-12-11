package com.cnl.chat

import android.app.DownloadManager
import android.content.Context
import android.net.Uri
import android.os.Environment
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app.channel.download"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "startDownload") {
                    val url = call.argument<String>("url")
                    if (url != null) {
                        startDownload(url)
                        result.success("下载已开始")
                    } else {
                        result.error("URL_NULL", "URL 为空", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun startDownload(url: String) {
        val request = DownloadManager.Request(Uri.parse(url))
        request.setTitle("应用更新")
        request.setDescription("APK 下载中...")
        request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
        request.setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, "update.apk")
        request.setAllowedOverMetered(true)
        request.setAllowedOverRoaming(true)

        val downloadManager = getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
        downloadManager.enqueue(request)
    }
}
