// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
// ignore: library_prefixes
import 'package:get/get.dart' as GetPackage;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:openim_common/openim_common.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:sprintf/sprintf.dart';

var dio = Dio();

enum BaseURLType {
  chatAddr,
  apiAddr,
  gateway,
}

class HttpUtil {
  HttpUtil._();
  static final MerchantController merchantController =
      GetPackage.Get.find<MerchantController>();
  static final GatewayDomainController gatewayDomainLogic =
      GetPackage.Get.find<GatewayDomainController>();
  static IMServerInfo get currentIMServerInfo =>
      merchantController.currentIMServerInfo.value;

  static void init() async {
    // DataSp.clearLastSuccessGatewayDomain();
    // DataSp.clearFallbackGatewayDomains();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int? platform;
    String? brand;
    // add interceptors
    dio
      // ..interceptors.add(PrettyDioLogger(
      //   requestHeader: kDebugMode,
      //   requestBody: kDebugMode,
      //   responseBody: kDebugMode,
      //   responseHeader: kDebugMode,
      // ))
      ..interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['version'] = packageInfo.version;
          options.headers['buildNumber'] = packageInfo.buildNumber;
          options.headers['packageName'] = packageInfo.packageName;
          options.headers['brand'] =
              brand ?? (brand = await DeviceInfoUtil.getDeviceInfoBrand());
          options.headers['platform'] =
              platform ?? (platform = IMUtils.getPlatform());
          final languageCode = GetPackage.Get.locale?.languageCode;
          String? locale;
          if (languageCode == 'zh') {
            locale = 'zh-CN';
          } else if (languageCode == 'en') {
            locale = 'en-US';
          } else {
            locale = languageCode;
          }
          options.headers['Accept-Language'] = locale;
          return handler.next(options);
        },
      ))
      ..interceptors.add(
        TalkerDioLogger(
          settings: const TalkerDioLoggerSettings(
            printRequestHeaders: kDebugMode,
            printRequestData: kDebugMode,
            printResponseMessage: kDebugMode,
            printResponseData: kDebugMode,
            printResponseHeaders: kDebugMode,
          ),
        ),
      )
      ..interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        print('************************ merchant: ${currentIMServerInfo.name}');
        print('************************ IP: ${currentIMServerInfo.ip}');

        return handler.next(options); //continue
        // 如果你想完成请求并返回一些自定义数据，你可以resolve一个Response对象 `handler.resolve(response)`。
        // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义response.
        //
        // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象,如`handler.reject(error)`，
        // 这样请求将被中止并触发异常，上层catchError会被调用。
      }, onResponse: (response, handler) {
        // Do something with response data
        return handler.next(response); // continue
        // 如果你想终止请求并触发一个错误,你可以 reject 一个`DioError`对象,如`handler.reject(error)`，
        // 这样请求将被中止并触发异常，上层catchError会被调用。
      }, onError: (DioException e, handler) {
        // Do something with response error
        return handler.next(e); //continue
        // 如果你想完成请求并返回一些自定义数据，可以resolve 一个`Response`,如`handler.resolve(response)`。
        // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义response.
      }));

    // 配置dio实例
    dio.options.connectTimeout = const Duration(seconds: 30); //30s
    dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  static String get operationID =>
      DateTime.now().millisecondsSinceEpoch.toString();

  static String get currentGatewayDomain =>
      gatewayDomainLogic.currentDomain.value;

  ///
  static Future post(String path,
      {dynamic data,
      bool showErrorToast = true,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress,
      BaseURLType baseURLType = BaseURLType.chatAddr}) async {
    try {
      data ??= {};
      options ??= Options();
      options.headers ??= {};
      options.headers!['operationID'] = operationID;

      String url;
      if (path.startsWith('http')) {
        url = path;
      } else if (baseURLType == BaseURLType.apiAddr) {
        options.headers!['token'] = DataSp.imToken;
        url = '${currentIMServerInfo.apiAddr.trim()}/$path';
      } else if (baseURLType == BaseURLType.gateway) {
        url = '$currentGatewayDomain/$path';
        options.headers!['token'] = DataSp.gatewayToken;
      } else {
        url = '${currentIMServerInfo.chatAddr.trim()}/$path';
        options.headers!['token'] = DataSp.chatToken;
      }

      var result = await dio.post<Map<String, dynamic>>(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      var resp = ApiResp.fromJson(result.data!);
      if (resp.errCode == 0) return resp.data;

      if (showErrorToast) {
        final errorMsgFromMap = ApiError.getMsg(resp.errCode);
        final fallbackMsg = resp.errMsg.isNotEmpty ? resp.errMsg : resp.errDlt;
        final displayMsg = errorMsgFromMap ?? fallbackMsg;
        IMViews.showToast(displayMsg);
      }

      return Future.error((resp.errCode, resp.errMsg, resp.data));
    } catch (error) {
      if (error is DioException) {
        String friendlyMessage;
        final connectivityResult = await Connectivity().checkConnectivity();
        final notNetwork = connectivityResult.contains(ConnectivityResult.none);
        switch (error.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            friendlyMessage = StrRes.networkTimeout;
            break;
          case DioExceptionType.connectionError:
            if (notNetwork) {
              friendlyMessage = StrRes.noNetwork;
            } else {
              friendlyMessage = StrRes.networkConnectionFailed;
            }
            break;
          case DioExceptionType.badResponse:
            friendlyMessage =
                sprintf(StrRes.serverError, [error.response?.statusCode]);
            break;
          case DioExceptionType.cancel:
            friendlyMessage = StrRes.requestCancelled;
            break;
          default:
            friendlyMessage = StrRes.requestFailed;
            break;
        }
        if (showErrorToast) IMViews.showToast(friendlyMessage);
        return Future.error((friendlyMessage, error.type, notNetwork));
      }
      if (showErrorToast) IMViews.showToast(error.toString());
      return Future.error(error);
    }
  }

  /// fileType: file = "1",video = "2",picture = "3"
  static Future<String> uploadImageForMinio({
    required String path,
    bool compress = true,
  }) async {
    String fileName = path.substring(path.lastIndexOf("/") + 1);
    // final mf = await MultipartFile.fromFile(path, filename: fileName);
    String? compressPath;
    if (compress) {
      File? compressFile = await IMUtils.compressImageAndGetFile(File(path));
      compressPath = compressFile?.path;
      Logger.print('compressPath: $compressPath');
    }
    final bytes = await File(compressPath ?? path).readAsBytes();
    final mf = MultipartFile.fromBytes(bytes, filename: fileName);

    var formData = FormData.fromMap({
      'operationID': '${DateTime.now().millisecondsSinceEpoch}',
      'fileType': 1,
      'file': mf
    });

    var resp = await dio.post<Map<String, dynamic>>(
      "${currentIMServerInfo.apiAddr.trim()}/third/minio_upload",
      data: formData,
      options: Options(headers: {'token': DataSp.imToken}),
    );
    return resp.data?['data']['URL'];
  }

  static Future download(
    String url, {
    required String cachePath,
    CancelToken? cancelToken,
    Function(int count, int total)? onProgress,
  }) {
    return dio.download(
      url,
      cachePath,
      options: Options(
        receiveTimeout: const Duration(minutes: 10),
      ),
      cancelToken: cancelToken,
      onReceiveProgress: onProgress,
    );
  }

  static Future saveUrlPicture(
    String url, {
    CancelToken? cancelToken,
    Function(int count, int total)? onProgress,
    VoidCallback? onCompletion,
  }) async {
    final name = url.substring(url.lastIndexOf('/') + 1);
    final cachePath = await IMUtils.createTempFile(dir: 'picture', name: name);
    var intervalDo = IntervalDo();

    return download(
      url,
      cachePath: cachePath,
      cancelToken: cancelToken,
      onProgress: (int count, int total) async {
        onProgress?.call(count, total);
        if (total == -1) {
          onCompletion?.call();
          intervalDo.drop(
              fun: () async {
                await ImageGallerySaverPlus.saveFile(cachePath);
                IMViews.showToast("${StrRes.saveSuccessfully}($cachePath)",
                    type: 1);
              },
              milliseconds: 1500);
        }
        if (count == total) {
          onCompletion?.call();
          final result = await ImageGallerySaverPlus.saveFile(cachePath);
          if (result != null) {
            IMViews.showToast(StrRes.saveSuccessfully, type: 1);
          }
        }
      },
    );
  }

  static Future saveImage(Image image) async {
    var byteData = await image.toByteData(format: ImageByteFormat.png);
    if (byteData != null) {
      Uint8List uint8list = byteData.buffer.asUint8List();
      var result =
          await ImageGallerySaverPlus.saveImage(Uint8List.fromList(uint8list));
      if (result != null) {
        IMViews.showToast(StrRes.saveSuccessfully, type: 1);
      }
    }
  }

  static Future saveUrlVideo(
    String url, {
    CancelToken? cancelToken,
    Function(int count, int total)? onProgress,
    VoidCallback? onCompletion,
  }) async {
    try {
      final name = url.substring(url.lastIndexOf('/') + 1);
      final cachePath = await IMUtils.createTempFile(dir: 'video', name: name);

      if (File(cachePath).existsSync()) {
        // File already exists, save it to gallery
        final result = await ImageGallerySaverPlus.saveFile(cachePath);
        if (result != null) {
          IMViews.showToast(StrRes.saveSuccessfully, type: 1);
        }
        onCompletion?.call();
        return;
      }

      return download(
        url,
        cachePath: cachePath,
        cancelToken: cancelToken,
        onProgress: (int count, int total) async {
          onProgress?.call(count, total);
          if (count == total && total > 0) {
            onCompletion?.call();
            try {
              final result = await ImageGallerySaverPlus.saveFile(cachePath);
              if (result != null) {
                IMViews.showToast(StrRes.saveSuccessfully, type: 1);
              } else {
                IMViews.showToast(StrRes.saveFailed);
              }
            } catch (e) {
              Logger.print('Save to gallery failed: $e');
              IMViews.showToast(StrRes.saveFailed);
            }
          }
        },
      );
    } catch (e) {
      Logger.print('Save video error: $e');
      IMViews.showToast(StrRes.saveFailed);
      onCompletion?.call();
    }
  }

  static Future saveFileToGallerySaver(File file,
      {bool showToast = true}) async {
    try {
      if (!file.existsSync()) {
        if (showToast) {
          IMViews.showToast(StrRes.saveFailed);
        }
        return;
      }

      final result = await ImageGallerySaverPlus.saveFile(file.path);
      if (result != null && showToast) {
        IMViews.showToast(StrRes.saveSuccessfully, type: 1);
      } else if (showToast) {
        IMViews.showToast(StrRes.saveFailed);
      }
    } catch (e) {
      Logger.print('Save file to gallery error: $e');
      if (showToast) {
        IMViews.showToast(StrRes.saveFailed);
      }
    }
  }
}
