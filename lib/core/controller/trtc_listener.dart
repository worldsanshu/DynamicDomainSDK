import 'package:flutter/foundation.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';

int _logShowLevel = 0;

_printLog(int level, String msg) {
  if (level > _logShowLevel) {
    debugPrint(msg);
  }
}

TRTCCloudListener getListener() {
  return TRTCCloudListener(
    onError: (errCode, errMsg) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onError errCode:$errCode errMsg:$errMsg");

      if (kDebugMode) {
        print(errMsg);
      }
    },
    onWarning: (warningCode, warningMsg) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onWarning warningCode:$warningCode warningMsg:$warningMsg");
    },
    onEnterRoom: (result) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onEnterRoom result:$result");
    },
    onExitRoom: (reason) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onExitRoom reason:$reason");
    },
    onSwitchRole: (errCode, errMsg) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onSwitchRole errCode:$errCode errMsg:$errMsg");
    },
    onSwitchRoom: (errCode, errMsg) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onSwitchRoom errCode:$errCode errMsg:$errMsg");
    },
    onConnectOtherRoom: (userId, errCode, errMsg) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onConnectOtherRoom userId:$userId errCode:$errCode errMsg:$errMsg");
    },
    onDisconnectOtherRoom: (errCode, errMsg) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onDisconnectOtherRoom errCode:$errCode errMsg:$errMsg");
    },
    onRemoteUserEnterRoom: (userId) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onRemoteUserEnterRoom userId:$userId");
    },
    onRemoteUserLeaveRoom: (userId, reason) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onRemoteUserLeaveRoom userId:$userId reason:$reason");
    },
    onUserVideoAvailable: (userId, available) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onUserVideoAvailable userId:$userId available:$available");
    },
    onUserSubStreamAvailable: (userId, available) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onUserSubStreamAvailable userId:$userId available:$available");
    },
    onUserAudioAvailable: (userId, available) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onUserAudioAvailable userId:$userId available:$available");
    },
    onFirstVideoFrame: (userId, streamType, width, height) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onFirstVideoFrame userId:$userId streamType:$streamType width:$width height:$height");
    },
    onFirstAudioFrame: (userId) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onFirstAudioFrame userId:$userId");
    },
    onSendFirstLocalVideoFrame: (streamType) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onSendFirstLocalVideoFrame streamType:$streamType");
    },
    onSendFirstLocalAudioFrame: () {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onSendFirstLocalAudioFrame");
    },
    onRemoteVideoStatusUpdated: (userId, streamType, status, reason) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onRemoteVideoStatusUpdated userId:$userId streamType:$streamType status:$status reason:$reason");
    },
    onRemoteAudioStatusUpdated: (userId, status, reason) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onRemoteAudioStatusUpdated userId:$userId status:$status reason:$reason");
    },
    onUserVideoSizeChanged: (userId, streamType, newWidth, newHeight) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onUserVideoSizeChanged userId:$userId streamType:$streamType newWidth:$newWidth newHeight:$newHeight");
    },
    onNetworkQuality: (localQuality, remoteQuality) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onNetworkQuality localQuality userId:${localQuality.userId} quality:${localQuality.quality}");

      for (TRTCQualityInfo info in remoteQuality) {
        _printLog(1,
            "TRTCCloudExample TRTCCloudListenerparseCallbackParam onNetworkQuality remoteQuality userId:${info.userId} quality:${info.quality}");
      }
    },
    onStatistics: (statistics) {
      _printLog(
          1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onStatistics "
          "appCu:${statistics.appCpu} systemCu:${statistics.systemCpu} upLoss:${statistics.upLoss} "
          "downLoss:${statistics.downLoss} rtt:${statistics.rtt} gatewayRtt:${statistics.gatewayRtt} "
          "sendBytes:${statistics.sentBytes} receiveBytes:${statistics.receivedBytes}");

      for (TRTCLocalStatistics info in statistics.localStatisticsArray!) {
        _printLog(
            1,
            "TRTCCloudExample TRTCCloudListenerparseCallbackParam onStatistics width:${info.width} height:${info.height} frameRate:${info.frameRate} \n"
            " onStatistics videoBitrate:${info.videoBitrate} audioSampleRate:${info.audioSampleRate} audioBitrate:${info.audioBitrate} \n"
            " onStatistics streamType:${info.streamType} audioCaptureState:${info.audioCaptureState}");
      }

      for (TRTCRemoteStatistics info in statistics.remoteStatisticsArray!) {
        _printLog(
            1,
            "TRTCCloudExample TRTCCloudListenerparseCallbackParam onStatistics userId:${info.userId} audioPacketLoss:${info.audioPacketLoss} videoPacketLoss:${info.videoPacketLoss} \n"
            " onStatistics width:${info.width} height:${info.height} frameRate:${info.frameRate} videoBitrate:${info.videoBitrate} audioSampleRate:${info.audioSampleRate} \n"
            " onStatistics audioBitrate:${info.audioBitrate} jitterBufferDelay:${info.jitterBufferDelay} point2PointDelay:${info.point2PointDelay} audioTotalBlockTime:${info.audioTotalBlockTime} \n"
            " onStatistics audioBlockRate:${info.audioBlockRate} videoTotalBlockTime:${info.videoTotalBlockTime} videoBlockRate:${info.videoBlockRate} finalLoss:${info.finalLoss} remoteNetworkUplinkLoss:${info.remoteNetworkUplinkLoss} \n"
            " onStatistics remoteNetworkRTT:${info.remoteNetworkRTT} streamType:${info.streamType}");
      }
    },
    onSpeedTestResult: (result) {
      _printLog(
          1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onSpeedTestResult TRTCSpeedTestResult: success:${result.success} errMsg:${result.errMsg} ip:${result.ip} \n"
          " onSpeedTestResult quality:${result.quality} upLostRate:${result.upLostRate} downLostRate:${result.downLostRate} rtt:${result.rtt} \n"
          " onSpeedTestResult availableUpBandwidth:${result.availableUpBandwidth} availableDownBandwidth:${result.availableDownBandwidth} upJitter:${result.upJitter} downJitter:${result.downJitter}\n");
    },
    onConnectionLost: () {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onConnectionLost");
    },
    onTryToReconnect: () {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onTryToReconnect");
    },
    onConnectionRecovery: () {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onConnectionRecovery");
    },
    onCameraDidReady: () {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onCameraDidReady");
    },
    onMicDidReady: () {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onMicDidReady");
    },
    onUserVoiceVolume: (userVolumes, totalVolume) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onUserVoiceVolume totalVolume:$totalVolume");

      for (TRTCVolumeInfo info in userVolumes) {
        _printLog(1,
            "TRTCCloudExample TRTCCloudListenerparseCallbackParam onUserVoiceVolume userId:${info.userId} volume:${info.volume}");
      }
    },
    onAudioDeviceCaptureVolumeChanged: (volume, muted) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onAudioDeviceCaptureVolumeChanged volume:$volume muted:$muted");
    },
    onAudioDevicePlayoutVolumeChanged: (volume, muted) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onAudioDevicePlayoutVolumeChanged volume:$volume muted:$muted");
    },
    onSystemAudioLoopbackError: (errCode) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onSystemAudioLoopbackError errCode:$errCode");
    },
    onTestMicVolume: (volume) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onTestMicVolume volume:$volume");
    },
    onTestSpeakerVolume: (volume) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onTestSpeakerVolume volume:$volume");
    },
    onRecvCustomCmdMsg: (userId, cmdId, seq, message) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onRecvCustomCmdMsg userId:$userId cmdId:$cmdId seq:$seq message:$message");
    },
    onMissCustomCmdMsg: (userId, cmdId, errCode, missed) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onMissCustomCmdMsg userId:$userId cmdId:$cmdId errCode:$errCode missed:$missed");
    },
    onRecvSEIMsg: (userId, message) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onRecvSEIMsg userId:$userId message:$message");
    },
    onStartPublishMediaStream: (taskId, errCode, errMsg, extraInfo) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onStartPublishMediaStream taskId:$taskId errCode:$errCode errMsg:$errMsg extraInfo:$extraInfo");
    },
    onUpdatePublishMediaStream: (taskId, errCode, errMsg, extraInfo) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onUpdatePublishMediaStream taskId:$taskId errCode:$errCode errMsg:$errMsg extraInfo:$extraInfo");
    },
    onStopPublishMediaStream: (taskId, errCode, errMsg, extraInfo) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onStopPublishMediaStream taskId:$taskId errCode:$errCode errMsg:$errMsg extraInfo:$extraInfo");
    },
    onCdnStreamStateChanged: (cdnUrl, status, errCode, errMsg, extraInfo) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onCdnStreamStateChanged cdnUrl:$cdnUrl status:$status errCode:$errCode errMsg:$errMsg extraInfo:$extraInfo");
    },
    onScreenCaptureStarted: () {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onScreenCaptureStarted");
    },
    onScreenCapturePaused: (reason) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onScreenCapturePaused reason:$reason");
    },
    onScreenCaptureResumed: (reason) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onScreenCaptureResumed reason:$reason");
    },
    onScreenCaptureStopped: (reason) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onScreenCaptureStopped reason:$reason");
    },
    onScreenCaptureCovered: () {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onScreenCaptureCovered");
    },
    onLocalRecordBegin: (errCode, storagePath) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onLocalRecordBegin errCode:$errCode storagePath:$storagePath");
    },
    onLocalRecording: (duration, storagePath) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onLocalRecording duration:$duration storagePath:$storagePath");
    },
    onLocalRecordFragment: (storagePath) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onLocalRecordingFragment storagePath:$storagePath");
    },
    onLocalRecordComplete: (errCode, storagePath) {
      _printLog(1,
          "TRTCCloudExample TRTCCloudListenerparseCallbackParam onLocalRecordComplete errCode:$errCode storagePath:$storagePath");
    },
  );
}
