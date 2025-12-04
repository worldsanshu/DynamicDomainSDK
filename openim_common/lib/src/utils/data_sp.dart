// ignore_for_file: unused_field

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';
import 'package:uuid/uuid.dart';

class DataSp {
  static const _gatewayToken = 'gatewayToken';
  static const _currentMerchant = 'currentMerchant';

  static const _mainServerKey = 'main_server';
  static const _fallbackServersKey = 'fallback_servers';

  static const _loginCertificate = 'loginCertificate';
  static const _loginAccount = 'loginAccount';
  static const _server = "server";
  static const _ip = 'ip';
  static const _deviceID = 'deviceID';
  static const _ignoreUpdate = 'ignoreUpdate';
  static const _language = "language";
  static const _groupApplication = "%s_groupApplication";
  static const _friendApplication = "%s_friendApplication";
  static const _groupApplicationPendingUpdates =
      "%s_groupApplicationPendingUpdates"; // Pending status updates
  static const _enabledVibration = 'enabledVibration';
  static const _enabledRing = 'enabledRing';
  static const _screenPassword = '%s_screenPassword';
  static const _enabledBiometric = '%s_enabledBiometric';
  static const _chatFontSizeFactor = '%s_chatFontSizeFactor';
  static const _chatBackground = '%s_chatBackground_%s';
  static const _loginType = 'loginType';
  static const _isPrivacyPolicyAccepted = '_isPrivacyPolicyAccepted';

  static const _fallbackGatewayDomains = 'fallbackGatewayDomains';
  static const _currentGatewayDomain = 'currentGatewayDomain';

  static const _teenModePassword = '_teenModePassword';

  static const _gatewayConfigKey = '_gatewayConfigKey';

  static const _clientConfigKey = '_clientConfigKey';

  static const _aiChatMessages = '%s_aiChatMessages';

  DataSp._();

  static init() async {
    await SpUtil().init();
  }

  static String getKey(String key, {String key2 = ""}) {
    return sprintf(key, [OpenIM.iMManager.userID, key2]);
  }

  static String? get imToken => getLoginCertificate()?.imToken;

  static String? get chatToken => getLoginCertificate()?.chatToken;

  static String? get gatewayToken => getGatewayToken();

  static String? get userID => getLoginCertificate()?.userID;

  static Future<bool>? putLoginCertificate(LoginCertificate lc) {
    return SpUtil().putObject(_loginCertificate, lc);
  }

  static Future<bool>? putGatewayToken(String gatewayToken) {
    return SpUtil().putString(_gatewayToken, gatewayToken);
  }

  static String? getGatewayToken() {
    return SpUtil().getString(_gatewayToken);
  }

  static Future<bool>? putCurrentMerchant(Merchant merchant) {
    return SpUtil().putObject(_currentMerchant, merchant);
  }

  static Merchant? getCurrentMerchant() {
    return SpUtil().getObj(
      _currentMerchant,
      (v) {
        return Merchant.fromJson(v.cast());
      },
    );
  }

  /// 存主服务器
  static Future<bool>? putMainServer(IMServerInfo main) {
    return SpUtil().putObject(_mainServerKey, main.toJson());
  }

  /// 取主服务器
  static IMServerInfo? getMainServer() {
    return SpUtil().getObj(
      _mainServerKey,
      (v) => IMServerInfo.fromJson(Map<String, dynamic>.from(v)),
    );
  }

  /// 存备用服务器
  static Future<bool>? putFallbackServers(List<IMServerInfo> list) {
    return SpUtil().putObjectList(
      _fallbackServersKey,
      list.map((e) => e.toJson()).toList(),
    );
  }

  /// 取备用服务器
  ///
  static List<IMServerInfo> getFallbackServers() {
    final list = SpUtil().getObjList(
      _fallbackServersKey,
      (v) => IMServerInfo.fromJson(Map<String, dynamic>.from(v)),
      defValue: [],
    );

    // 显式转换每一项
    return list?.map((e) => e as IMServerInfo).toList() ?? [];
  }

  static Future<bool>? putFallbackGatewayDomains(List<String> domains) {
    return SpUtil().putStringList(_fallbackGatewayDomains, domains);
  }

  static List<String>? getFallbackGatewayDomains() {
    return SpUtil().getStringList(_fallbackGatewayDomains, defValue: []);
  }

  static Future<bool>? clearFallbackGatewayDomains() {
    return SpUtil().remove(_fallbackGatewayDomains);
  }

  static Future<bool>? putCurrentGatewayDomain(String domain) {
    return SpUtil().putString(_currentGatewayDomain, domain);
  }

  static String? getCurrentGatewayDomain() {
    return SpUtil().getString(_currentGatewayDomain, defValue: null);
  }

  static Future<bool>? clearCurrentGatewayDomain() {
    return SpUtil().remove(_currentGatewayDomain);
  }

  /// {
  ///   "phone"    :"",
  ///   "areaCode" :"",
  ///   "email"    :"",
  /// }
  static Future<bool>? putLoginAccount(Map map) {
    return SpUtil().putObject(_loginAccount, map);
  }

  static LoginCertificate? getLoginCertificate() {
    return SpUtil().getObj(_loginCertificate, (v) {
      return LoginCertificate.fromJson(v.cast());
    });
  }

  static Future<bool>? removeLoginCertificate() {
    return SpUtil().remove(_loginCertificate);
  }

  static Map? getLoginAccount() {
    return SpUtil().getObject(_loginAccount);
  }

  static Future<bool>? putServerConfig(Map<String, String> config) {
    return SpUtil().putObject(_server, config);
  }

  static Map? getServerConfig() {
    return SpUtil().getObject(_server);
  }

  static Future<bool>? putServerIP(String ip) {
    return SpUtil().putString(ip, ip);
  }

  static String? getServerIP() {
    return SpUtil().getString(_ip);
  }

  static String getDeviceID() {
    String id = SpUtil().getString(_deviceID) ?? '';
    if (id.isEmpty) {
      id = const Uuid().v4();
      SpUtil().putString(_deviceID, id);
    }
    return id;
  }

  static Future<bool>? putIgnoreVersion(String version) {
    return SpUtil().putString(_ignoreUpdate, version);
  }

  static String? getIgnoreVersion() {
    return SpUtil().getString(_ignoreUpdate);
  }

  static Future<bool>? putLanguage(int index) {
    return SpUtil().putInt(_language, index);
  }

  static int? getLanguage() {
    return SpUtil().getInt(_language);
  }

  static Future<bool>? putHaveReadUnHandleGroupApplication(
      List<String> idList) {
    return SpUtil().putStringList(getKey(_groupApplication), idList);
  }

  static Future<bool>? putHaveReadUnHandleFriendApplication(
      List<String> idList) {
    return SpUtil().putStringList(getKey(_friendApplication), idList);
  }

  static List<String>? getHaveReadUnHandleGroupApplication() {
    return SpUtil().getStringList(getKey(_groupApplication), defValue: []);
  }

  static List<String>? getHaveReadUnHandleFriendApplication() {
    return SpUtil().getStringList(getKey(_friendApplication), defValue: []);
  }

  /// Save pending group application status update
  /// Key format: "groupID_userID" -> handleResult (1=accepted, -1=rejected)
  static Future<bool>? putGroupApplicationPendingUpdate(
      String groupID, String userID, int handleResult) {
    final updates = getGroupApplicationPendingUpdates();
    final key = '${groupID}_$userID';
    updates[key] = handleResult;
    return SpUtil().putObject(getKey(_groupApplicationPendingUpdates), updates);
  }

  /// Get all pending group application status updates
  static Map<String, int> getGroupApplicationPendingUpdates() {
    final obj = SpUtil().getObject(getKey(_groupApplicationPendingUpdates));
    if (obj == null) return {};
    return Map<String, int>.from(obj);
  }

  /// Clear all pending group application updates
  static Future<bool>? clearGroupApplicationPendingUpdates() {
    return SpUtil().remove(getKey(_groupApplicationPendingUpdates));
  }

  static Future<bool>? putLockScreenPassword(String password) {
    return SpUtil().putString(getKey(_screenPassword), password);
  }

  static Future<bool>? clearLockScreenPassword() {
    return SpUtil().remove(getKey(_screenPassword));
  }

  static String? getLockScreenPassword() {
    return SpUtil().getString(getKey(_screenPassword), defValue: null);
  }

  static Future<bool>? openBiometric() {
    return SpUtil().putBool(getKey(_enabledBiometric), true);
  }

  static bool? isEnabledBiometric() {
    return SpUtil().getBool(getKey(_enabledBiometric), defValue: null);
  }

  static Future<bool>? closeBiometric() {
    return SpUtil().remove(getKey(_enabledBiometric));
  }

  static Future<bool>? putChatFontSizeFactor(double factor) {
    return SpUtil().putDouble(getKey(_chatFontSizeFactor), factor);
  }

  static double getChatFontSizeFactor() {
    return SpUtil().getDouble(
      getKey(_chatFontSizeFactor),
      defValue: Config.textScaleFactor,
    )!;
  }

  static Future<bool>? putChatBackground(String toUid, String path) {
    return SpUtil().putString(getKey(_chatBackground, key2: toUid), path);
  }

  static String? getChatBackground(String toUid) {
    return SpUtil().getString(getKey(_chatBackground, key2: toUid));
  }

  static Future<bool>? clearChatBackground(String toUid) {
    return SpUtil().remove(getKey(_chatBackground, key2: toUid));
  }

  static Future<bool>? putLoginType(int type) {
    return SpUtil().putInt(_loginType, type);
  }

  static int getLoginType() {
    return SpUtil().getInt(_loginType) ?? 0;
  }

  /// Saves the user's agreement to the privacy policy.
  static savePrivacyPolicyAgreement(bool hasAgreed) async {
    return SpUtil().putBool(_isPrivacyPolicyAccepted, hasAgreed);
  }

  /// Retrieves the user's agreement status to the privacy policy.
  static Future<bool> isPrivacyPolicyAgreed() async {
    return SpUtil().getBool(_isPrivacyPolicyAccepted) ?? false;
  }

  static Future<bool>? clearPrivacyPolicyAgreed() {
    return SpUtil().remove(_isPrivacyPolicyAccepted);
  }

  static Future<bool> isMerchantPolicyAgreed(String key) async {
    return SpUtil().getBool(key) ?? false;
  }

  static putMerchantPolicyAgreement(String key, bool hasAgreed) async {
    return SpUtil().putBool(key, hasAgreed);
  }

  /// Clears the user's privacy policy agreement status.
  static clearPrivacyPolicyAgreement() async {
    return SpUtil().remove(_isPrivacyPolicyAccepted);
  }

  static String? getTeenModePassword() {
    return SpUtil().getString(getKey(_teenModePassword), defValue: null);
  }

  static Future<bool>? clearTeenModePassword() {
    return SpUtil().remove(getKey(_teenModePassword));
  }

  static Future<bool>? putTeenModePassword(String password) {
    return SpUtil().putString(getKey(_teenModePassword), password);
  }

  static putGatewayConfig(Map<String, dynamic> config) async {
    return SpUtil().putObject(_gatewayConfigKey, config);
  }

  static Map? getGatewayConfig() {
    return SpUtil().getObject(_gatewayConfigKey);
  }

  static Future<bool>? clearGatewayConfig() {
    return SpUtil().remove(_gatewayConfigKey);
  }

  static putClientConfig(Map<String, dynamic> config) async {
    return SpUtil().putObject(_clientConfigKey, config);
  }

  static Map? getClientConfig() {
    return SpUtil().getObject(_clientConfigKey);
  }

  static Future<bool>? clearClientConfig() {
    return SpUtil().remove(_clientConfigKey);
  }

  // AI Chat Messages methods
  static Future<bool>? putAIChatMessages(List<Map<String, dynamic>> messages) {
    final key = getKey(_aiChatMessages);
    return SpUtil().putObjectList(key, messages);
  }

  static List<Map<String, dynamic>> getAIChatMessages() {
    final key = getKey(_aiChatMessages);
    final list = SpUtil().getObjList(
      key,
      (v) => Map<String, dynamic>.from(v),
    );
    return list ?? [];
  }

  static Future<bool>? clearAIChatMessages() {
    final key = getKey(_aiChatMessages);
    return SpUtil().remove(key);
  }

  static const _passwordPrefix = 'saved_password_';
  static String _keyFor(String phone) => '$_passwordPrefix$phone';

  static String? getSavedPassword(String phone) {
    return SpUtil().getString(_keyFor(phone), defValue: null);
  }

  static Future<bool>? putSavedPassword(String phone, String password) {
    return SpUtil().putString(_keyFor(phone), password);
  }

  static const _inviteCodeKey = '_inviteCodeKey';
  static String? getSavedInviteCode() {
    return SpUtil().getString(_inviteCodeKey, defValue: null);
  }

  static Future<bool>? putSavedInviteCode(String inviteCode) {
    return SpUtil().putString(_inviteCodeKey, inviteCode);
  }
}
