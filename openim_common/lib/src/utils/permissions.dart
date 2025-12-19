// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sprintf/sprintf.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum PermissionType { photos, storage, camera, microphone }

class Permissions {
  Permissions._();

  static Future<bool> checkSystemAlertWindow() async {
    return Permission.systemAlertWindow.isGranted;
  }

  static Future<bool> checkStorage() async {
    return await Permission.storage.isGranted;
  }

  static void checkAndShowPermissionExplanation(Permission permission) async {
    String title;
    String message;

    switch (permission) {
      case Permission.photos:
        title = '对存储空间/照片权限申请说明';
        message = '便于您在该功能中上传图片/视频及用于更换头像、分享文件、保存附件、意见反馈等操作时读取和写入相册和文件内容。';
        break;

      case Permission.storage:
      case Permission.manageExternalStorage:
        title = '对存储空间/照片权限申请说明';
        message = '便于您在该功能中上传图片/视频及用于更换头像、分享文件、保存附件、意见反馈等操作时读取和写入相册和文件内容。';
        break;

      case Permission.camera:
        title = '对相机/摄像头权限申请说明';
        message = '便于您使用该功能中拍照上传您的照片/视频及用于更换头像、意见反馈、保存相册、扫描二维码、进行视频通话等场景中使用';
        break;
      case Permission.microphone:
        title = '对麦克风权限申请说明';
        message = '便于您进行语音通话、录制语音消息、参与语音会议等操作，我们需要获取麦克风权限。';
        break;
      default:
        title = '权限申请说明';
        message = '需要获取相关权限以便提供更好的服务。';
        break;
    }

    // Skip if permission is already granted or permanently denied
    if (await permission.status.isGranted ||
        await permission.status.isPermanentlyDenied) {
      return;
    }

    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
      borderRadius: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      snackPosition: SnackPosition.TOP,
      icon: const Icon(Icons.info_outline, color: Colors.black87, size: 20),
      shouldIconPulse: false,
      animationDuration: const Duration(milliseconds: 300),
      snackStyle: SnackStyle.FLOATING,
      padding: const EdgeInsets.all(12),
      titleText: Text(
        title,
        style: const TextStyle(
          fontFamily: 'FilsonPro',
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          fontFamily: 'FilsonPro',
          fontSize: 14,
          color: Colors.black54,
        ),
      ),
      duration: null,
    );
  }

  static void camera(Function()? onGranted) async {
    // Check if permission is already granted - if so, skip explanation and just call callback
    if (await Permission.camera.status.isGranted) {
      onGranted?.call();
      return;
    }

    // Show explanation only if permission is not yet granted
    if (Platform.isAndroid) {
      checkAndShowPermissionExplanation(Permission.camera);
    }

    final status = await Permission.camera.request();

    // Always close the snackbar after permission request completes
    if (Platform.isAndroid) {
      Get.closeCurrentSnackbar();
    }

    if (status.isGranted) {
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    } else if (status.isPermanentlyDenied || status.isDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      _showPermissionDeniedDialog(Permission.camera.title);
    }
  }

  static void storage(Function()? onGranted) async {
    if (!Platform.isAndroid) {
      onGranted?.call();
      return;
    }

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    late Permission permisson;

    if (androidInfo.version.sdkInt <= 32) {
      permisson = Permission.storage;
    } else {
      permisson = Permission.manageExternalStorage;
    }

    // Check if permission is already granted - if so, skip explanation and just call callback
    if (await permisson.status.isGranted) {
      onGranted?.call();
      return;
    }

    // Show explanation only if permission is not yet granted
    checkAndShowPermissionExplanation(permisson);

    final status = await permisson.request();

    // Always close the snackbar after permission request completes
    Get.closeCurrentSnackbar();

    if (status.isGranted) {
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    } else if (status.isPermanentlyDenied || status.isDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      _showPermissionDeniedDialog(permisson.title);
    }
  }

  static void manageExternalStorage(Function()? onGranted) async {
    if (await Permission.manageExternalStorage.request().isGranted) {
      if (Platform.isAndroid) {
        Get.closeCurrentSnackbar();
      }
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    }
    if (await Permission.storage.isPermanentlyDenied ||
        await Permission.storage.isDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      _showPermissionDeniedDialog(Permission.storage.title);
    }
  }

  static void microphone(Function()? onGranted, {Function()? onDenied}) async {
    if (Platform.isAndroid) {
      checkAndShowPermissionExplanation(Permission.microphone);
    }
    final result = await Permission.microphone.request();
    if (result.isGranted) {
      if (Platform.isAndroid) {
        Get.closeCurrentSnackbar();
      }
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    } else if (result.isPermanentlyDenied || result.isDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      onDenied?.call();
      _showPermissionDeniedDialog(Permission.microphone.title);
    }
  }

  static void speech(Function()? onGranted) async {
    if (await Permission.speech.request().isGranted) {
      if (Platform.isAndroid) {
        Get.closeCurrentSnackbar();
      }
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    }
    if (await Permission.speech.isPermanentlyDenied ||
        await Permission.speech.isDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      _showPermissionDeniedDialog(Permission.speech.title);
    }
  }

  static void photos(Function()? onGranted) async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        storage(onGranted);
      } else {
        checkAndShowPermissionExplanation(Permission.photos);
        final permissions = [Permission.photos, Permission.videos];
        final results = await permissions.request();

        final photosResult = results[Permission.photos];

        if (photosResult != null && isPermissionAccepted(photosResult)) {
          Get.closeAllSnackbars();
          // Either the permission was already granted before or the user just granted it.
          // Also allow limited access for selected photos
          onGranted?.call();
        }
        if (await Permission.photos.isPermanentlyDenied ||
            await Permission.photos.isDenied) {
          _showPermissionDeniedDialog(Permission.photos.title);
        }
      }
    } else {
      final permissions = [Permission.photos, Permission.videos];
      final results = await permissions.request();

      final photosResult = results[Permission.photos];

      if (photosResult != null && isPermissionAccepted(photosResult)) {
        // Either the permission was already granted before or the user just granted it.
        // Also allow limited access for selected photos
        onGranted?.call();
      }
      if (await Permission.photos.isPermanentlyDenied ||
          await Permission.photos.isDenied) {
        _showPermissionDeniedDialog(Permission.photos.title);
      }
    }
  }

  static Future<bool> notification() async {
    if (await Permission.notification.request().isGranted) {
      if (Platform.isAndroid) {
        Get.closeCurrentSnackbar();
      }
      // Either the permission was already granted before or the user just granted it.
      return true;
    }
    if (await Permission.notification.isPermanentlyDenied ||
        await Permission.notification.isDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      _showPermissionDeniedDialog(Permission.notification.title);
    }

    return false;
  }

  static void ignoreBatteryOptimizations(Function()? onGranted) async {
    if (await Permission.ignoreBatteryOptimizations.request().isGranted) {
      if (Platform.isAndroid) {
        Get.closeCurrentSnackbar();
      }
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    }
    if (await Permission.ignoreBatteryOptimizations.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
    }
  }

  static void cameraAndMicrophoneAndPhotos(Function()? onGranted) async {
    cameraAndMicrophone(() => photos(onGranted));
  }

  static void cameraAndPhotos(Function()? onGranted) async {
    camera(() => photos(onGranted));
  }

  static void cameraAndMicrophone(Function()? onGranted) async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      // Permission.speech,
    ];
    bool isAllGranted = true;
    var msg = '';

    for (var permission in permissions) {
      if (Platform.isAndroid) {
        checkAndShowPermissionExplanation(permission);
      }
      final state = await permission.request();
      isAllGranted = isAllGranted && state.isGranted;
      if (!state.isGranted) {
        msg += '${permission.title}、';
      }
      if (Platform.isAndroid) {
        Get.closeCurrentSnackbar();
      }
    }
    if (isAllGranted) {
      onGranted?.call();
    } else {
      msg = msg.substring(0, msg.length - 1);
      _showPermissionDeniedDialog(msg);
    }

    if (Platform.isAndroid) {
      Get.closeCurrentSnackbar();
    }
  }

  static Future<bool> media() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
    ];
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        permissions.add(Permission.storage);
      } else {
        permissions.add(Permission.photos);
      }
    } else {
      permissions.add(Permission.photos);
    }

    bool isAllGranted = true;
    var msg = '';

    for (var permission in permissions) {
      if (Platform.isAndroid) {
        Permissions.checkAndShowPermissionExplanation(permission);
      }
      final state = await permission.request();
      isAllGranted = isAllGranted && state.isGranted;
      if (!state.isGranted) {
        msg += '${permission.title}、';
      }
    }
    if (!isAllGranted) {
      msg = msg.substring(0, msg.length - 1);
      _showPermissionDeniedDialog(msg);
    }
    if (Platform.isAndroid) {
      Get.closeCurrentSnackbar();
    }
    return isAllGranted;
  }

  static void storageAndMicrophone(Function()? onGranted) async {
    final permissions = [
      Permission.microphone,
    ];

    final androidInfo = await DeviceInfoPlugin().androidInfo;

    if (androidInfo.version.sdkInt <= 32) {
      permissions.add(Permission.storage);
    } else {
      permissions.add(Permission.manageExternalStorage);
    }

    bool isAllGranted = true;
    var msg = '';

    for (var permission in permissions) {
      final state = await permission.request();
      isAllGranted = isAllGranted && state.isGranted;
      if (!state.isGranted) {
        msg += '${permission.title}、';
      }
    }
    if (isAllGranted) {
      if (Platform.isAndroid) {
        Get.closeCurrentSnackbar();
      }
      onGranted?.call();
    } else {
      msg = msg.substring(0, msg.length - 1);
      _showPermissionDeniedDialog(msg);
    }
  }

  static Future<Map<Permission, PermissionStatus>> request(
      List<Permission> permissions) async {
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    return statuses;
  }

  /// Check if permission is accepted (granted or limited)
  static bool isPermissionAccepted(PermissionStatus status) {
    return status.isGranted || status.isLimited;
  }

  static void _showPermissionDeniedDialog(String tips) {
    Future.delayed(const Duration(milliseconds: 100), () {
      final context = Get.context;
      if (context != null && context.mounted) {
        showDialog(
          context: Get.context!,
          builder: (BuildContext context) {
            return Material(
              color: Colors.transparent,
              child: Center(
                child: AnimationConfiguration.synchronized(
                  duration: const Duration(milliseconds: 450),
                  child: SlideAnimation(
                    curve: Curves.easeOutQuart,
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Container(
                        width: 300.w,
                        margin: EdgeInsets.symmetric(horizontal: 20.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFBFC),
                          borderRadius: BorderRadius.circular(32.r),
                          boxShadow: [
                            // Shadow tối (hiệu ứng lõm)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              offset: const Offset(8, 8),
                              blurRadius: 20,
                              spreadRadius: 0,
                            ),
                            // Shadow sáng (hiệu ứng nổi)
                            BoxShadow(
                              color: Colors.white.withOpacity(0.9),
                              offset: const Offset(-8, -8),
                              blurRadius: 20,
                              spreadRadius: 0,
                            ),
                            // Viền glow sáng
                            BoxShadow(
                              color: Colors.white.withOpacity(0.6),
                              offset: const Offset(0, 0),
                              blurRadius: 2,
                              spreadRadius: 1,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32.r),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header section
                              Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFF8FAFC),
                                      Color(0xFFFAFBFC),
                                    ],
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 28.h,
                                ),
                                child: Column(
                                  children: [
                                    // Permission icon với clay effect
                                    Container(
                                      width: 60.w,
                                      height: 60.w,
                                      margin: EdgeInsets.only(bottom: 16.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B)
                                            .withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          // Inner shadow hiệu ứng lõm
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.04),
                                            offset: const Offset(3, 3),
                                            blurRadius: 6,
                                            spreadRadius: -2,
                                          ),
                                          BoxShadow(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            offset: const Offset(-3, -3),
                                            blurRadius: 6,
                                            spreadRadius: -2,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.security_rounded,
                                        size: 32.w,
                                        color: const Color(0xFFF59E0B),
                                      ),
                                    ),
                                    Text(
                                      StrRes.permissionDeniedTitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'FilsonPro',
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF374151),
                                        height: 1.3,
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            offset: const Offset(0.5, 0.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(
                                      sprintf(
                                          StrRes.permissionDeniedHint, [tips]),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'FilsonPro',
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF6B7280),
                                        height: 1.5,
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            offset: const Offset(0.5, 0.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Buttons section
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F8FA),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(32.r),
                                    bottomRight: Radius.circular(32.r),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _clayButton(
                                          text: StrRes.cancel,
                                          textColor: const Color(0xFF6B7280),
                                          isLeft: true,
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            if (Platform.isAndroid) {
                                              Get.closeCurrentSnackbar();
                                            }
                                          }),
                                    ),
                                    Container(
                                      width: 1.w,
                                      height: 56.h,
                                      margin:
                                          EdgeInsets.symmetric(vertical: 12.h),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.02),
                                            Colors.black.withOpacity(0.05),
                                            Colors.black.withOpacity(0.02),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: _clayButton(
                                        text: StrRes.determine,
                                        textColor: const Color(0xFF3B82F6),
                                        isLeft: false,
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          Get.closeCurrentSnackbar();
                                          openAppSettings();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }
    });
  }

  static Widget _clayButton({
    required String text,
    required Color textColor,
    required bool isLeft,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 80.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.only(
              bottomLeft: isLeft ? Radius.circular(32.r) : Radius.zero,
              bottomRight: !isLeft ? Radius.circular(32.r) : Radius.zero,
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                // Inner shadow hiệu ứng lõm cho button
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                  spreadRadius: -1,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  offset: const Offset(-2, -2),
                  blurRadius: 4,
                  spreadRadius: -1,
                ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
                shadows: [
                  Shadow(
                    color: Colors.white.withOpacity(0.9),
                    offset: const Offset(0.5, 0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

extension PermissionExt on Permission {
  String get title {
    switch (this) {
      case Permission.storage:
        return StrRes.externalStorage;
      case Permission.photos:
        return StrRes.gallery;
      case Permission.camera:
        return StrRes.camera;
      case Permission.microphone:
        return StrRes.microphone;
      case Permission.notification:
        return StrRes.notification;
      default:
        return '';
    }
  }
}
