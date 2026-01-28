package com.example.dynamic_domain

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import tunnel_core.Tunnel_core

class TunnelService : Service() {
    private val CHANNEL_ID = "DynamicDomainTunnelChannel"

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = createNotification()
        startForeground(1, notification)

        // The tunnel is actually started via JNI call from the Plugin class.
        // This service primarily keeps the process alive.
        // However, we could move the StartTunnel logic here for better lifecycle management.

        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        // Stop tunnel when service is destroyed
        Tunnel_core.stopTunnel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Dynamic Domain Tunnel Service",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Tunnel Active")
            .setContentText("Dynamic Domain service is running in the background")
            .setSmallIcon(android.R.drawable.ic_dialog_info) // Replace with your icon
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }
}
