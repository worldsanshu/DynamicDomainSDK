// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sprintf/sprintf.dart';

enum PermissionType { photos, storage, camera, microphone }

class Permissions {
  Permissions._();

  static Future<bool> checkSystemAlertWindow() async {
    return Permission.systemAlertWindow.isGranted;
  }

  static Future<bool> checkStorage() async {
    return await Permission.storage.isGranted;
  }

  static void checkAndShowPermissionExplanation(Permission permission,
      {bool forceShow = false}) async {
    String title;
    String message;

    switch (permission) {
      case Permission.photos:
        title = StrRes.permissionStorageTitle;
        message = StrRes.permissionStorageMessage;
        permission = Permission.photos;
        break;

      case Permission.storage:
        title = StrRes.permissionStorageTitle;
        message = StrRes.permissionStorageMessage;
        permission = Permission.storage;
        break;

      case Permission.camera:
        title = StrRes.permissionCameraTitle;
        message = StrRes.permissionCameraMessage;
        permission = Permission.camera;
        break;
      case Permission.microphone:
        title = StrRes.permissionMicrophoneTitle;
        message = StrRes.permissionMicrophoneMessage;
        permission = Permission.microphone;
        break;
      default:
        title = StrRes.permissionDefaultTitle;
        message = StrRes.permissionDefaultMessage;
        permission = Permission.photos;
        break;
    }

    // if (await permission.status.isGranted ||
    //     await permission.status.isPermanentlyDenied ||
    //     await permission.status.isPermanentlyDenied) {
    //   return;
    // }
    if ((await permission.isDenied || await permission.isPermanentlyDenied) &&
            (permission == Permission.photos
                ? (await Permission.storage.isDenied) ||
                    (await Permission.storage.isPermanentlyDenied)
                : true) ||
        forceShow) {
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
            fontFamily: 'SFPro',
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        messageText: Text(
          message,
          style: const TextStyle(
            fontFamily: 'SFPro',
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        duration: null,
      );
    }
  }

  static void camera(Function()? onGranted) async {
    if (Platform.isAndroid) {
      checkAndShowPermissionExplanation(Permission.camera);
    }
    if (await Permission.camera.request().isGranted) {
      Get.closeCurrentSnackbar();
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    }
    if (await Permission.camera.isPermanentlyDenied ||
        await Permission.camera.isDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      showPermissionDeniedDialog(Permission.camera.title);
    }
  }

  /// Request storage permission
  /// On Android 13+ (SDK 33+), we use Permission.storage which doesn't require
  /// MANAGE_EXTERNAL_STORAGE (which conflicts with limited photo access)
  static void storage(Function()? onGranted) async {
    if (!Platform.isAndroid) {
      onGranted?.call();
      return;
    }
    if (Platform.isAndroid) {
      checkAndShowPermissionExplanation(Permission.storage);
    }
    final androidInfo = await DeviceInfoPlugin().androidInfo;

    // On Android 13+ (SDK 33+), we don't need MANAGE_EXTERNAL_STORAGE
    // Use SAF (Storage Access Framework) via native channel instead
    // For older versions, use storage permission
    if (androidInfo.version.sdkInt <= 32) {
      final permisson = Permission.storage;
      if (await permisson.request().isGranted) {
        Get.closeCurrentSnackbar();
        onGranted?.call();
      } else if (await permisson.isPermanentlyDenied ||
          await permisson.isDenied) {
        showPermissionDeniedDialog(permisson.title);
      }
    } else {
      // On Android 13+, we rely on SAF for file access
      // No need for storage permission for file picking
      Get.closeCurrentSnackbar();
      onGranted?.call();
    }
  }

  /// Note: This method is kept for backward compatibility but should be avoided
  /// Using MANAGE_EXTERNAL_STORAGE conflicts with limited photo access on Android 14+
  @Deprecated('Use storage() instead to avoid permission conflicts')
  static void manageExternalStorage(Function()? onGranted) async {
    if (await Permission.manageExternalStorage.request().isGranted) {
      Get.closeCurrentSnackbar();
      onGranted?.call();
    }
    if (await Permission.storage.isPermanentlyDenied ||
        await Permission.storage.isDenied) {
      showPermissionDeniedDialog(Permission.storage.title);
    }
  }

  static Future<PermissionStatus> microphone(Function()? onGranted,
      {Function()? onDenied}) async {
    if (Platform.isAndroid) {
      checkAndShowPermissionExplanation(Permission.microphone);
    }
    final result = await Permission.microphone.request();
    if (result.isGranted) {
      Get.closeCurrentSnackbar();
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    } else if (result.isPermanentlyDenied || result.isDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      onDenied?.call();
      showPermissionDeniedDialog(Permission.microphone.title);
    }
    return result;
  }

  static void speech(Function()? onGranted) async {
    if (await Permission.speech.request().isGranted) {
      Get.closeCurrentSnackbar();
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    }
    if (await Permission.speech.isPermanentlyDenied ||
        await Permission.speech.isDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      showPermissionDeniedDialog(Permission.speech.title);
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
          Get.closeCurrentSnackbar();
          onGranted?.call();
        } else if (await Permission.photos.isPermanentlyDenied ||
            await Permission.photos.isDenied) {
          showPermissionDeniedDialog(Permission.photos.title);
        }
      }
    } else {
      if (await Permission.photos.isGranted ||
          await Permission.photosAddOnly.isGranted) {
        Get.closeCurrentSnackbar();
        onGranted?.call();
        return;
      }

      final addOnlyResult = await Permission.photosAddOnly.request();
      if (addOnlyResult.isGranted) {
        Get.closeCurrentSnackbar();
        onGranted?.call();
        return;
      }

      final photosResult = await Permission.photos.request();
      if (photosResult.isGranted || photosResult.isLimited) {
        Get.closeCurrentSnackbar();
        onGranted?.call();
        return;
      }

      if (await Permission.photos.isPermanentlyDenied ||
          await Permission.photos.isDenied) {
        showPermissionDeniedDialog(Permission.photos.title);
      }
    }
  }

  /// Request photos permission using PhotoManager (recommended for gallery picker)
  /// This uses PhotoManager.requestPermissionExtend() which handles both
  /// full access and limited access correctly on Android 14+
  ///
  /// Returns true if permission was granted (full or limited access)
  /// Returns false if permission was denied
  ///
  /// [onGranted] - callback when permission is granted (full or limited)
  /// [onDenied] - optional callback when permission is denied
  /// [showExplanation] - whether to show permission explanation snackbar (default: true)
  static Future<bool> photosWithPhotoManager({
    Function()? onGranted,
    Function()? onDenied,
    bool showExplanation = true,
  }) async {
    if (Platform.isAndroid) {
      // Show explanation snackbar on Android
      if (showExplanation) {
        checkAndShowPermissionExplanation(Permission.photos, forceShow: false);
      }

      // Use PhotoManager to request permission (handles limited access correctly)
      final permissionState = await PhotoManager.requestPermissionExtend(
        requestOption: const PermissionRequestOption(
          androidPermission: AndroidPermission(
            type: RequestType.common,
            mediaLocation: true,
          ),
        ),
      );

      Logger.print('Photo permission state (PhotoManager): $permissionState');

      // Check if permission granted (full or limited access)
      if (permissionState.isAuth || permissionState.hasAccess) {
        onGranted?.call();
        Get.closeAllSnackbars();
        return true;
      } else {
        // Permission denied
        onDenied?.call();
        showPermissionDeniedDialog(Permission.photos.title);
        return false;
      }
    } else {
      // iOS: Use PhotoManager for consistency
      final permissionState = await PhotoManager.requestPermissionExtend();

      Logger.print(
          'Photo permission state (PhotoManager iOS): $permissionState');

      if (permissionState.isAuth || permissionState.hasAccess) {
        Get.closeAllSnackbars();
        onGranted?.call();
        return true;
      } else {
        onDenied?.call();
        showPermissionDeniedDialog(Permission.photos.title);
        return false;
      }
    }
  }

  static Future<bool> notification() async {
    if (await Permission.notification.request().isGranted) {
      Get.closeCurrentSnackbar();
      // Either the permission was already granted before or the user just granted it.
      return true;
    }
    if (await Permission.notification.isPermanentlyDenied ||
        await Permission.notification.isDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      showPermissionDeniedDialog(Permission.notification.title);
    }

    return false;
  }

  static void ignoreBatteryOptimizations(Function()? onGranted) async {
    if (await Permission.ignoreBatteryOptimizations.request().isGranted) {
      Get.closeCurrentSnackbar();
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
    }
    if (isAllGranted) {
      Get.closeCurrentSnackbar();
      onGranted?.call();
    } else {
      msg = msg.substring(0, msg.length - 1);
      showPermissionDeniedDialog(msg);
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
      showPermissionDeniedDialog(msg);
    }
    if (isAllGranted) {
      Get.closeCurrentSnackbar();
    }
    return isAllGranted;
  }

  /// Request storage and microphone permissions
  /// On Android 13+, we don't need storage permission for file access (use SAF)
  static void storageAndMicrophone(Function()? onGranted) async {
    final permissions = [
      Permission.microphone,
    ];

    final androidInfo = await DeviceInfoPlugin().androidInfo;

    // Only add storage permission on Android 12 and below
    // On Android 13+, we use SAF for file access
    if (androidInfo.version.sdkInt <= 32) {
      permissions.add(Permission.storage);
    }
    // Note: Don't add manageExternalStorage - it conflicts with limited photo access

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
      Get.closeCurrentSnackbar();
      onGranted?.call();
    } else {
      msg = msg.substring(0, msg.length - 1);
      showPermissionDeniedDialog(msg);
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

  static void showPermissionDeniedDialog(String tips) {
    var content = sprintf(StrRes.permissionDeniedHint, [tips]);
    CustomDialog.show(
      title: StrRes.permissionDeniedTitle,
      content: content,
      rightText: StrRes.determine,
      leftText: StrRes.cancel,
      icon: Icons.security,
      onTapLeft: () async {
        Get.closeAllSnackbars();
        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.of(Get.overlayContext!).pop();
      },
      onTapRight: () async {
        Get.closeAllSnackbars();
        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.of(Get.overlayContext!).pop();
        openAppSettings();
      },
    );
  }
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
