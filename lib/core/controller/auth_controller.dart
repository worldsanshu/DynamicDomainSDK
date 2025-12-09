import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:openim/core/controller/app_controller.dart';
import 'package:openim/core/controller/im_controller.dart';
import 'package:openim/core/controller/push_controller.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim/routes/app_pages.dart';
import 'package:openim_common/openim_common.dart';

import 'client_config_controller.dart';
import 'gateway_config_controller.dart';

class AuthController extends SuperController {
  final imLogic = Get.find<IMController>();
  final pushLogic = Get.find<PushController>();
  final appLogic = Get.find<AppController>();
  final gatewayConfigController = Get.find<GatewayConfigController>();
  final clientConfigLogic = Get.find<ClientConfigController>();
  final MerchantController merchantController = Get.find<MerchantController>();
  final GatewayDomainController gatewayDomainLogic =
      Get.find<GatewayDomainController>();

  IMServerInfo get currentIMServerInfo =>
      merchantController.currentIMServerInfo.value;

  String? get userID => DataSp.userID;
  String? get imToken => DataSp.imToken;
  bool get isLoggedIn => userID != null && imToken != null;

  var isInitialized = false;

  String? inviteCode;

  Future processLogin() async {
    Logger.print('---------login---------- userID: $userID, token: $imToken');
    await _prepareAndInitIM(currentIMServerInfo);
    await completeLoginFlow(
      userID!,
      imToken!,
      resetCache: false,
      jumpToMain: false,
    );
    Logger.print('--------- LOGIN SUCCESS ---------');
  }

  Future<void> refreshIm({
    IMServerInfo? imServerInfo,
  }) async {
    return LoadingView.singleton.wrap(
      asyncFunction: () async {
        if (imServerInfo != null) {
          merchantController.updateMainServer(imServerInfo);
        }
        await imLogic.logout();
        pushLogic.logout();
        await processLogin();
      },
    );
  }

  void register({
    required String account,
    required String password,
    required String nickname,
    required String code,
    String? invitationCode,
    VoidCallback? onError,
  }) async {
    LoadingView.singleton.wrap(
      asyncFunction: () async {
        try {
          final result = await GatewayApi.register(
            account: account,
            password: password,
            nickname: nickname,
            code: code,
            invitationCode: invitationCode,
          );

          // 处理本地存储与网关逻辑
          await _saveGatewayInfo(result['token'], account);

          // 解析 merchant 列表
          final merchantList = _parseMerchantList(result['organization']);
          if (merchantList.isEmpty) {
            _handleRegisterError('注册异常！请重新绑定企业');
            return;
          }

          // 解析登录凭证
          final loginCertificate = _parseLoginCertificate(result['imCurrent']);
          if (loginCertificate == null) {
            _handleRegisterError('请选择企业登录！');
            return;
          }
          await DataSp.putLoginCertificate(loginCertificate);

          // 更新 merchant 和初始化 IM
          final merchant = merchantList.first;
          final merchantServers =
              MerchantServers.fromApiJson(merchant.toJson());
          merchantController.updateCurrentIMServer(servers: merchantServers);
          await _prepareAndInitIM(merchantServers.main);

          completeLoginFlow(loginCertificate.userID, loginCertificate.imToken);
        } catch (e) {
          if (isNetworkError(e)) {
            handleErrorWithRetry(
              e,
              () => register(
                account: account,
                password: password,
                nickname: nickname,
                code: code,
                invitationCode: invitationCode,
                onError: onError,
              ),
            );
          } else {
            onError?.call();
          }
        }
      },
    );
  }

  void login({
    required String account,
    required String password,
    VoidCallback? onSuccess,
  }) {
    LoadingView.singleton.wrap(asyncFunction: () async {
      try {
        final result = await GatewayApi.login(
          account: account,
          password: password,
        );
        await _saveGatewayInfo(result['token'], account);
        onSuccess?.call();

        // 解析 merchant 列表
        final merchantList = _parseMerchantList(result['organization']);
        if (merchantList.isEmpty) {
          _handleRegisterError(StrRes.noCompanyBound);
          return;
        }

        // 绑定了多个企业
        if (merchantList.length > 1) {
          startMerchantList();
          return;
        }

        // 解析登录凭证
        final loginCertificate = _parseLoginCertificate(result['imCurrent']);
        if (loginCertificate == null) {
          _handleRegisterError(StrRes.enterVerificationCode);
          return;
        }
        await DataSp.putLoginCertificate(loginCertificate);

        // 更新 merchant 和初始化 IM
        final merchant = merchantList.first;
        final merchantServers = MerchantServers.fromApiJson(merchant.toJson());
        merchantController.updateCurrentIMServer(servers: merchantServers);
        await _prepareAndInitIM(merchantServers.main);
        completeLoginFlow(loginCertificate.userID, loginCertificate.imToken);
      } catch (e) {
        if (e is (int, String?, dynamic)) {
          LoadingView.singleton.dismiss();
          final errCode = e.$1;
          final errMsg = e.$2;
          final data = e.$3;
          if (errCode == 52) {
            final merchantList = _parseMerchantList(data['organization']);
            handleBlock(
              errMsg: errMsg,
              merchant: merchantList.firstOrNull,
            );
          } else {
            print('---- login error: $errCode, $errMsg');
            String msg=StrRes.loginFailed;
            switch(errCode){
              case 51:
                msg=StrRes.notFoundAccount;
              case 53:
                msg=StrRes.loginIncorrectPwd;
              default:
                msg=StrRes.loginFailed;
            }
            IMViews.showToast(msg);
          }
        } else if (isNetworkError(e)) {
          handleErrorWithRetry(
            e,
            () => login(
              account: account,
              password: password,
              onSuccess: onSuccess,
            ),
          );
        }
      }
    });
  }

  int max = 5;
  int current = 1;

  void handleErrorWithRetry(e, Function()? callback) async {
    final errMsg = e.$1;
    final notNetwork = e.$3;
    if (notNetwork) {
      IMViews.showToast(errMsg);
      return;
    }
    gatewayDomainLogic.saveUnavailableDomain();
    if (current <= max && gatewayDomainLogic.switchToNext()) {
      current++;
      callback?.call();
    } else {
      IMViews.showToast(errMsg);
      LoadingView.singleton.dismiss();
      final result = await AppNavigator.startGatewaySwitcher();
      await Future.delayed(const Duration(milliseconds: 500));
      if (result == true) {
        callback?.call();
      }
    }
  }

  void switchMerchant({required Merchant merchant, fromLogin = false}) {
    LoadingView.singleton.wrap(asyncFunction: () async {
      try {
        final result = await GatewayApi.switchMerchant(merchantID: merchant.id);

        if (!fromLogin) {
          await imLogic.logout();
          pushLogic.logout();
        }

        final loginCertificate = _parseLoginCertificate(result['imCurrent']);
        if (loginCertificate == null) {
          _handleRegisterError('切换企业失败！未返回登录凭证！');
          return;
        }
        await DataSp.putLoginCertificate(loginCertificate);

        final merchantServers = MerchantServers.fromApiJson(merchant.toJson());
        merchantController.updateCurrentIMServer(servers: merchantServers);
        await _prepareAndInitIM(merchantServers.main);

        completeLoginFlow(loginCertificate.userID, loginCertificate.imToken);
      } catch (e) {
        LoadingView.singleton.dismiss();
        if (e is (int, String?, dynamic)) {
          final errCode = e.$1;
          final errMsg = e.$2;
          if (errCode == 52) {
            handleBlock(errMsg: errMsg, merchant: merchant);
          } else {
            IMViews.showToast(errMsg ?? '登录失败');
          }
        }
      }
    });
  }

  Future<void> handleBlock({
    String? errMsg,
    Merchant? merchant,
  }) async {
    final result = await Get.dialog(CustomDialog(
      title: '已被封禁账号',
      content: errMsg == null ? null : '因被举报：$errMsg， 您暂时无法使用该账号',
      rightText: merchant != null ? '申诉' : null,
    ));
    if (result == true) {
      AppNavigator.startAppeal(
        blockReason: errMsg ?? '',
        imUserId: merchant!.imUserId,
        chatAddr: merchant.chatAddr,
      );
    }
  }

  var checking = false;
  void checkClipboard() async {
    if (checking == true) return;
    checking = true;
    if (Get.currentRoute == AppRoutes.login ||
        Get.currentRoute == AppRoutes.register) {
      await Future.delayed(const Duration(milliseconds: 500));
      final confirm = await gatewayDomainLogic.trySwitchToClipboardDomain();
      if (confirm == true) {
        IMViews.showToast('已更换域名，请重新登录');
      }
    }
    checking = false;
  }

  bool isNetworkError(dynamic e) => e is (String, DioExceptionType, bool);

  Future<void> _saveGatewayInfo(String token, String account) async {
    await DataSp.putGatewayToken(token);
    DataSp.putLoginAccount({"account": account});
    gatewayDomainLogic.saveCurrentDomainToLocal();
    gatewayDomainLogic.reportUnavailableDomains();
    gatewayDomainLogic.refreshFallbackGatewayDomains();
  }

  List<Merchant> _parseMerchantList(dynamic raw) {
    if (raw is! List) return [];
    try {
      return List<Merchant>.from(
        raw.map((e) => Merchant.fromJson(e as Map<String, dynamic>)),
      );
    } catch (_) {
      return [];
    }
  }

  LoginCertificate? _parseLoginCertificate(dynamic raw) {
    if (raw == null) return null;
    final map = {
      'chatToken': raw['chatToken'],
      'imToken': raw['imToken'],
      'userID': raw['imUserId'],
    };
    try {
      return LoginCertificate.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  void _handleRegisterError(String message) {
    IMViews.showToast(message);
    startMerchantList();
  }

  startMerchantList() => AppNavigator.startMerchantList(fromLogin: true);

  Future<void> _prepareAndInitIM(IMServerInfo s) async {
    await _prepareIMEnvironment();
    imLogic.initOpenIM(apiAddr: s.apiAddr, wsAddr: s.wsAddr);
    isInitialized = true;
  }

  Future<void> _prepareIMEnvironment() async {
    if (isInitialized) {
      await imLogic.unInitOpenIM();
    } else {
      await pushLogic.init();
    }
  }

  Future<void> completeLoginFlow(
    String userID,
    String imToken, {
    bool resetCache = true,
    bool jumpToMain = true,
  }) async {
    try {
      await imLogic.login(userID, imToken);
      pushLogic.login(userID);
      clientConfigLogic.queryClientConfig();

      if (resetCache) {
        Get.find<CacheController>().resetCache();
      }

      if (jumpToMain) {
        AppNavigator.startMain();
        IMViews.showToast(StrRes.loginSuccess, type: 1);
      }
    } catch (_) {
      IMViews.showToast(StrRes.loginFailed);
    }
  }

  void _handleClipboardDomainCheck() {
    if (gatewayConfigController.enableClipboardDomainCheck) {
      checkClipboard();
    }
  }

  @override
  void onReady() {
    _handleClipboardDomainCheck();
    super.onReady();
  }

  @override
  void onDetached() {
  }

  @override
  void onHidden() {
  }

  @override
  void onInactive() {
  }

  @override
  void onPaused() {
  }

  @override
  void onResumed() {
    _handleClipboardDomainCheck();
  }
}
