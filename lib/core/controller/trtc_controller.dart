// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:openim/core/controller/im_controller.dart';
import 'package:openim/core/im_callback.dart';
import 'package:openim_common/openim_common.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'trtc_listener.dart';

class TRTCController extends GetxController {
  String? trtcSign;
  int trtcAppID = Config.trtcAppID;
  bool isTrtcAvailable = false;
  TRTCCloud? trtcCloud;

  final im = Get.find<IMController>();
  final merchant = Get.find<MerchantController>();

  int get currentMerchantID => merchant.currentIMServerInfo.value.merchantID;
  UserFullInfo get userinfo => im.userInfo.value;

  void callAudio(String userId) => _call(userId, TUICallMediaType.audio);
  void callVideo(String userId) => _call(userId, TUICallMediaType.video);

  Future<void> _call(String userId, TUICallMediaType type) async {
    print('Vào call');
    if (!await _ensureLogin()) {
      IMViews.showToast('音视频通话不可用，请稍后重试');
      debugPrint('TRTC 未登录，无法拨打');
      return;
    }

    if (type == TUICallMediaType.audio) {
      Permissions.microphone(() async {
        final targetId = _genTrtcUserId(userId);
        try {
          final result = await TUICallKit.instance.call(targetId, type);
          if (result.code == '-1001') {
            IMViews.showToast(StrRes.callFail);
          }
          _logResult('单人通话', result);
        } catch (e) {
          IMViews.showToast(StrRes.callFail);
          debugPrint('音频/视频通话失败: $e');
        }
      });
    } else {
      Permissions.cameraAndMicrophone(() async {
        final targetId = _genTrtcUserId(userId);
        try {
          final result = await TUICallKit.instance.call(targetId, type);
           if (result.code == '-1001') {
            IMViews.showToast(StrRes.callFail);
          }
          _logResult('单人通话', result);
        } catch (e) {
          IMViews.showToast(StrRes.callFail);
          debugPrint('音频/视频通话失败: $e');
        }
      });
    }
  }

  void callGroupAudio(List<String> ids, int roomId, String groupId) =>
      _callGroup(ids, roomId, groupId, TUICallMediaType.audio);

  void callGroupVideo(List<String> ids, int roomId, String groupId) =>
      _callGroup(ids, roomId, groupId, TUICallMediaType.video);

  Future<void> _callGroup(
    List<String> userIds,
    int roomId,
    String groupId,
    TUICallMediaType type,
  ) async {
    if (!await _ensureLogin()) {
      IMViews.showToast('音视频通话不可用，请稍后重试');
      debugPrint('TRTC 未登录，无法发起群通话');
      return;
    }
    if (type == TUICallMediaType.audio) {
      Permissions.microphone(() async {
        final trtcUserIds = userIds.map(_genTrtcUserId).toList();
        final params = TUICallParams()
          ..chatGroupId = groupId
          ..roomId = TUIRoomId(intRoomId: roomId, strRoomId: '');
        final result =
            await TUICallKit.instance.calls(trtcUserIds, type, params);
        _logResult('群组通话', result);
      });
    } else {
      Permissions.cameraAndMicrophone(() async {
        final trtcUserIds = userIds.map(_genTrtcUserId).toList();
        final params = TUICallParams()
          ..chatGroupId = groupId
          ..roomId = TUIRoomId(intRoomId: roomId, strRoomId: '');
        final result =
            await TUICallKit.instance.calls(trtcUserIds, type, params);
        _logResult('群组通话', result);
      });
    }
  }

  void setNicknameAvatar(String nickname, String avatar) async {
    final result = await TUICallKit.instance.setSelfInfo(nickname, avatar);
    if (kDebugMode) {
      print('设置昵称/头像结果：${result.message}');
    }
  }

  Future<void> login() async {
    await TUICallKit.instance.logout();

    TUICallKit.instance.enableFloatWindow(true);

    try {
      final result = await TUICallKit.instance
          .login(trtcAppID, _genTrtcUserId(userinfo.userID!), trtcSign!);
      if (result.code.isEmpty) {
        await _setSelfInfo();
        TUICallEngine.instance
            .init(trtcAppID, _genTrtcUserId(userinfo.userID!), trtcSign!);
        TUICallEngine.instance.addObserver(observer);
        await _initTRTCCloud();
        isTrtcAvailable = true;
        debugPrint('TRTC 登录成功');
      } else {
        isTrtcAvailable = false;
        debugPrint('TRTC 登录失败: ${result.code} ${result.message}');
      }
    } catch (e) {
      isTrtcAvailable = false;
      debugPrint('TRTC 登录异常: $e');
    }
  }

  Future<void> _initTRTCCloud() async {
    try {
      trtcCloud = await TRTCCloud.sharedInstance();
      trtcCloud?.registerListener(getListener());
      debugPrint('TRTC Cloud initialized with listener');
    } catch (e) {
      debugPrint('Failed to initialize TRTC Cloud: $e');
    }
  }

  Future<bool> _ensureLogin() async {
    if (trtcSign == null || !isTrtcAvailable) {
      return await LoadingView.singleton.wrap(
        asyncFunction: () async {
          if (trtcSign == null) {
            final result = await _fetchTRTCSign();
            if (result != true) return false;
          }
          await login();
          return isTrtcAvailable;
        },
      );
    }
    return true;
  }

  Future<void> logout() async {
    isTrtcAvailable = false;
    await _cleanupTRTCCloud();
    return TUICallKit.instance.logout();
  }

  Future<bool?> _fetchTRTCSign() async {
    try {
      final res = await ChatApis.getTRTCSign();

      if (res.userSig.isEmpty) {
        return null;
      }

      trtcSign = res.userSig;
      trtcAppID = res.appId ?? Config.trtcAppID;
      return true;
    } catch (e) {
      debugPrint('获取 TRTC 签名失败: $e');
      return false;
    }
  }

  Future<void> ensureTRTCReady() async {
    await Future.delayed(const Duration(seconds: 1));
    for (int i = 0; i < 3; i++) {
      final result = await _fetchTRTCSign();

      if (result == null) {
        return;
      }

      if (result == true) {
        login();
        return;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> _cleanupTRTCCloud() async {
    try {
      if (trtcCloud != null) {
        trtcCloud?.unRegisterListener(getListener());

        TRTCCloud.destroySharedInstance();
        trtcCloud = null;

        debugPrint('TRTC Cloud cleaned up');
      }
    } catch (e) {
      debugPrint('Failed to cleanup TRTC Cloud: $e');
    }
  }

  Future<void> _setSelfInfo() async {
    final nickname = userinfo.nickname ?? userinfo.userID!;
    final avatar = (userinfo.faceURL?.isNotEmpty ?? false) &&
            userinfo.faceURL != 'NICKNAME'
        ? userinfo.faceURL!
        : Config.trtcDefaultAvatarURL;
    final result = await TUICallKit.instance.setSelfInfo(nickname, avatar);
    _logResult('设置昵称/头像', result);
  }

  String _genTrtcUserId(String userId) => "${currentMerchantID}_$userId";

  TRTCCloud? getTRTCCloud() {
    return trtcCloud;
  }

  bool get isTRTCCloudReady => trtcCloud != null;

  void _logResult(String action, dynamic result) {
    debugPrint('$action 结果: ${result.code} - ${result.message}');
  }

  @override
  void onClose() {
    _cleanupTRTCCloud();
    super.onClose();
  }
}

enum CallType { video, audio }

enum CallStatus {
  normal,
  end,
  reject,
  cancelled,
  lineBusy,
  noResponse,
  offline,
  error,
}

extension CallStatusExt on CallStatus {
  String get name {
    switch (this) {
      case CallStatus.normal:
        return '通话时长: ';
      case CallStatus.reject:
        return '通话拒接';
      case CallStatus.cancelled:
        return '通话已取消';
      case CallStatus.end:
        return '通话结束';
      case CallStatus.lineBusy:
        return '通话正忙';
      case CallStatus.noResponse:
        return '通话未响应';
      case CallStatus.offline:
        return '用户离线';
      case CallStatus.error:
        return '通话错误';
    }
  }
}

final TUICallObserver observer = TUICallObserver(
  onCallCancelled: (callerId) {},
  onError: (code, reason) {},
  onCallBegin: (roomId, callMediaType, callRole) {
    Permissions.microphone(
      () async {},
      onDenied: () {
        TUICallEngine.instance.hangup();
      },
    );
  },
  onCallEnd: (callId, mediaType, reason, userId, totalTime, info) {
    if (info.role != TUICallRole.caller) return;
    callEventSubject.add((
      duration: totalTime.toInt(),
      status: CallStatus.normal,
      userId: userId,
      roomId: info.roomId.intRoomId,
      groupId: info.chatGroupId,
      type:
          mediaType == TUICallMediaType.video ? CallType.video : CallType.audio,
      isSender: true,
    ));
  },
  onCallNotConnected: (callId, mediaType, reason, userId, info) {
    if (info.role != TUICallRole.caller) return;
    CallStatus status;
    switch (reason) {
      case CallEndReason.lineBusy:
        status = CallStatus.lineBusy;
        break;
      case CallEndReason.offline:
        status = CallStatus.offline;
        break;
      case CallEndReason.canceled:
        status = CallStatus.cancelled;
        break;
      case CallEndReason.reject:
        status = CallStatus.reject;
        break;
      default:
        status = CallStatus.error;
        break;
    }
    callEventSubject.add((
      duration: 0,
      status: status,
      userId: userId,
      roomId: info.roomId.intRoomId,
      groupId: info.chatGroupId,
      type:
          mediaType == TUICallMediaType.video ? CallType.video : CallType.audio,
      isSender: true,
    ));
  },
);
