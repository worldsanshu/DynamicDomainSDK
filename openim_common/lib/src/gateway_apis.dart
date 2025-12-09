import 'dart:async';
import 'dart:io';
import 'package:openim_common/openim_common.dart';
import 'package:openim_common/src/api_helper.dart';
import 'gateway_urls.dart';
import 'package:dio/dio.dart';

///
///
/// 网关接口
///
///
class GatewayApi {
  /// 注册
  static Future register({
    required String account,
    required String password,
    required String nickname,
    required String code,
    String? invitationCode,
  }) async {
    return await HttpUtil.post(
      GatewayUrls.register,
      data: {
        'account': account,
        'password': password,
        'nickname': nickname,
        'invitationCode': invitationCode,
        'code': code,
        'port': 'user',
        'deviceID': DataSp.getDeviceID(),
        'platform': IMUtils.getPlatform(),
        'autoLoginIM': true,
      },
      baseURLType: BaseURLType.gateway,
    ).catchApiError();
  }

  /// 登录
  static Future login({
    required String account,
    required String password,
  }) async {
    return await HttpUtil.post(
      GatewayUrls.login,
      data: {
        'account': account,
        'password': password,
        'port': 'user',
        'deviceID': DataSp.getDeviceID(),
        'platform': IMUtils.getPlatform(),
        'autoLoginIM': true,
      },
      baseURLType: BaseURLType.gateway,
      showErrorToast: false,
    ).catchApiError();
  }

  /// 登录(切换)IM
  static Future switchMerchant({required int merchantID}) async {
    return await HttpUtil.post(
      GatewayUrls.loginIM,
      data: {
        'organizationId': merchantID,
        'deviceID': DataSp.getDeviceID(),
        'deviceId': DataSp.getDeviceID(),
        'platform': IMUtils.getPlatform(),
      },
      baseURLType: BaseURLType.gateway,
      showErrorToast: false,
    ).catchApiError();
  }

  /// 商户列表
  static Future<List<Merchant>> getMerchantList() async {
    try {
      final response = await HttpUtil.post(
        GatewayUrls.merchantList,
        baseURLType: BaseURLType.gateway,
      ).catchApiError();
      List<Merchant> merchantList = [];
      if (response is List) {
        merchantList = List<Merchant>.from((response)
            .map((data) => Merchant.fromJson(data as Map<String, dynamic>)));
      }
      return merchantList;
    } catch (error) {
      return [];
    }
  }

  /// 搜索商户
  static Future<Merchant> searchMerchant(
      {required String code, bool showErrorToast = true}) async {
    final result = await HttpUtil.post(
      GatewayUrls.searchMerchant,
      data: {'code': code},
      baseURLType: BaseURLType.gateway,
      showErrorToast: showErrorToast,
    ).catchApiError();
    return Merchant.fromJson(result as Map<String, dynamic>);
  }

  /// 绑定商户
  static Future bindMerchant({required String code}) async {
    return await HttpUtil.post(
      GatewayUrls.bindMerchant,
      data: {
        'code': code,
      },
      baseURLType: BaseURLType.gateway,
    ).catchApiError();
  }

  /// 搜索商户
  static Future<Merchant> searchMerchantByID(int id) async {
    final result = await HttpUtil.post(
      GatewayUrls.searchMerchantByID,
      data: {'id': id},
      baseURLType: BaseURLType.gateway,
      showErrorToast: false,
    ).catchApiError();
    return Merchant.fromJson(result as Map<String, dynamic>);
  }

  /// 发送短信验证码
  static Future<bool> sendVerificationCode({
    required String phoneNumber,
    String? inviteCode,
    required String use,
  }) async {
    return await HttpUtil.post(
      GatewayUrls.sendSMSCode,
      data: {
        // register | passwordReset
        'use': use,
        'areaCode': '+86',
        'phoneNumber': phoneNumber,
        'inviteCode': inviteCode,
      },
      baseURLType: BaseURLType.gateway,
    ).catchApiError();
  }

  /// 发送短信验证码(带返回值)
  static Future<dynamic> sendVerificationCodeV2({
    required String phoneNumber,
  }) async {
    return await HttpUtil.post(
      GatewayUrls.sendSMSCodeV2,
      data: {
        'use': 'register',
        'phoneNumber': phoneNumber,
      },
      baseURLType: BaseURLType.gateway,
    ).catchApiError();
  }

  /// 获取图形验证码ID
  static Future<String> getCaptchaID() async {
    return await HttpUtil.post(
      GatewayUrls.getCaptchaID,
      data: {
        'scene': 'register',
      },
      baseURLType: BaseURLType.gateway,
    ).catchApiError();
  }

  /// 获取图形验证码
  static Future<dynamic> getCaptcha({
    required String id,
  }) async {
    return await HttpUtil.post(
      GatewayUrls.getCaptcha,
      data: {
        'id': id,
      },
      baseURLType: BaseURLType.gateway,
    ).catchApiError();
  }

  /// 更改密码
  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await await HttpUtil.post(
        GatewayUrls.changePassword,
        data: {
          'current': IMUtils.generateMD5(currentPassword),
          'new': IMUtils.generateMD5(newPassword),
          'platform': IMUtils.getPlatform()
        },
        baseURLType: BaseURLType.gateway,
      ).catchApiError();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 重置密码
  static Future<bool> resetPassword({
    required String password,
    required String phoneNumber,
    required String smsCode,
  }) async {
    try {
      await HttpUtil.post(
        GatewayUrls.resetPassword,
        data: {
          'password': IMUtils.generateMD5(password),
          'phoneNumber': phoneNumber,
          'smsCode': smsCode,
          'areaCode': '+86',
        },
        baseURLType: BaseURLType.gateway,
      ).catchApiError();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取最新版本信息
  static Future<VersionInfo?> getLatestVersion() async {
    try {
      final result = await HttpUtil.post(
        GatewayUrls.latestVersion,
        data: {'platform': Platform.isAndroid ? 'Android' : 'IOS'},
        baseURLType: BaseURLType.gateway,
        showErrorToast: false,
      ).catchApiError();
      return VersionInfo.fromJson(result);
    } catch (e) {
      return null;
    }
  }

  /// 网关配置
  static Future getGatewayConfig() async {
    return await HttpUtil.post(
      GatewayUrls.gatewayConfigAll,
      baseURLType: BaseURLType.gateway,
      showErrorToast: false,
    ).catchApiError();
  }

  /// 网关配置 - 域名列表
  static Future<List<String>> getDomainList() async {
    try {
      final result = await HttpUtil.post(
        GatewayUrls.gatewayConfig,
        data: {'label': 'fallbackDomains'},
        baseURLType: BaseURLType.gateway,
        showErrorToast: false,
      ).catchApiError();
      List<String> domainList = [];
      if (result is String && result.isNotEmpty) {
        domainList = result.split('\n');
      }
      return domainList;
    } catch (e) {
      return [];
    }
  }

  /// 上报不可用域名
  static Future reportUnavailableDomains({required List<String> urls}) async {
    return await HttpUtil.post(
      GatewayUrls.reportUnavailableDomains,
      data: {'url': urls},
      baseURLType: BaseURLType.gateway,
    ).catchApiError();
  }

  /// 提交实名认证申请
  /// Submit real-name authentication application
  static Future<Map<String, dynamic>> submitRealNameAuth({
    required String realName,
    required String idCardNumber,
    required String idCardFrontUrl,
    required String idCardBackUrl,
    required String idCardHandheldUrl,
  }) async {
    return await HttpUtil.post(
      GatewayUrls.submitRealNameAuth,
      data: {
        'realName': realName,
        'idCardNumber': idCardNumber,
        'idCardFrontUrl': idCardFrontUrl,
        'idCardBackUrl': idCardBackUrl,
        'idCardHandheldUrl': idCardHandheldUrl,
      },
      baseURLType: BaseURLType.gateway,
    ).catchApiError();
  }

  /// 查询实名认证信息
  /// Query real-name authentication information
  static Future<Map<String, dynamic>> getRealNameAuthInfo() async {
    return await HttpUtil.post(
      GatewayUrls.getRealNameAuthInfo,
      data: {},
      baseURLType: BaseURLType.gateway,
    ).catchApiError();
  }

  /// 上传文件(通用接口)
  /// Upload file (general interface)
  static Future<String> uploadFile({
    required File file,
    required String fileType,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final mf = MultipartFile.fromBytes(
        bytes,
        filename: file.path.split('/').last,
      );

      final formData = FormData.fromMap({
        'file': mf,
        'type': fileType,
      });

      final result = await HttpUtil.post(
        GatewayUrls.uploadFile,
        data: formData,
        baseURLType: BaseURLType.gateway,
      ).catchApiError();

      if (result is Map<String, dynamic> && result.containsKey('url')) {
        return result['url'] as String;
      }
      throw Exception('Upload failed: Invalid response format');
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  /// 发送消息到 Gemini AI
  /// Send message to Gemini AI
  static Future<String> sendMessageToGemini({
    required String message,
    List<Map<String, dynamic>>? chatHistory,
  }) async {
    try {
      final dio = Dio();

      // Build contents array with chat history
      final List<Map<String, dynamic>> contents = [];

      // Add chat history if provided
      if (chatHistory != null && chatHistory.isNotEmpty) {
        for (var msg in chatHistory) {
          final isUser = msg['isUser'] as bool;
          final text = msg['message'] as String;

          contents.add({
            'role': isUser ? 'user' : 'model',
            'parts': [
              {'text': text}
            ]
          });
        }
      }

      // Add current message
      contents.add({
        'role': 'user',
        'parts': [
          {'text': message}
        ]
      });

      final response = await dio.post(
        GatewayUrls.geminiAPIBaseURL,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'contents': contents,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        if (data.containsKey('candidates') &&
            data['candidates'] is List &&
            (data['candidates'] as List).isNotEmpty) {
          final candidate =
              (data['candidates'] as List).first as Map<String, dynamic>;

          if (candidate.containsKey('content')) {
            final content = candidate['content'] as Map<String, dynamic>;

            if (content.containsKey('parts') &&
                content['parts'] is List &&
                (content['parts'] as List).isNotEmpty) {
              final part =
                  (content['parts'] as List).first as Map<String, dynamic>;

              if (part.containsKey('text')) {
                return part['text'] as String;
              }
            }
          }
        }

        throw Exception('Invalid response format from Gemini API');
      }

      throw Exception(
          'Failed to get response from Gemini API: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      throw Exception('Gemini API error: $e');
    }
  }

  /// 获取实名认证信息
  static Future<bool> checkInvitationCode({required String inviteCode}) async {
    try {
      final result = await HttpUtil.post(
        GatewayUrls.checkInvitationCode,
        data: {
          'code': inviteCode,
        },
        baseURLType: BaseURLType.gateway,
        showErrorToast: false,
      ).catchApiError();
      return result['valid'] == true || result['status'] == true;
    } catch (e) {
      if (e is (int, String, Map)) {
        if (e.$1 == 500) {
          IMViews.showToast(StrRes.tooMuchRequestValidationCode);
        }
      }

      rethrow;
    }
  }
}
