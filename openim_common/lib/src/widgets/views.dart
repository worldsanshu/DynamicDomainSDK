// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:common_utils/common_utils.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_picker_plus/flutter_picker_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openim_common/openim_common.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:uuid/uuid.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

class IMViews {
  IMViews._();

  // ignore: unused_field
  static final ImagePicker _picker = ImagePicker();

  static Future showToast(String msg, {Duration? duration}) {
    if (msg.trim().isNotEmpty) {
      return EasyLoading.showToast(msg, duration: duration);
    } else {
      return Future.value();
    }
  }

  static Widget buildHeader([double distance = 60]) => WaterDropMaterialHeader(
        backgroundColor: Styles.c_0089FF,
        distance: distance,
      );

  static Widget buildFooter() => CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            // body = Text("pull up load");
            body = const CupertinoActivityIndicator();
          } else if (mode == LoadStatus.loading) {
            body = const CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            // body = Text("Load Failed!Click retry!");
            body = const CupertinoActivityIndicator();
          } else if (mode == LoadStatus.canLoading) {
            // body = Text("release to load more");
            body = const CupertinoActivityIndicator();
          } else {
            // body = Text("No more Data");
            body = const SizedBox();
          }
          return SizedBox(
            height: 55.0,
            child: Center(child: body),
          );
        },
      );

  static openIMCallSheet(
    String label,
    Function(int index) onTapSheetItem,
  ) {
    return Get.bottomSheet(
      BottomSheetView(
        mainAxisAlignment: MainAxisAlignment.start,
        items: [
          SheetItem(
            label: StrRes.callVoice,
            icon: ImageRes.callVoice,
            alignment: MainAxisAlignment.start,
            onTap: () => onTapSheetItem.call(0),
          ),
          SheetItem(
            label: StrRes.callVideo,
            icon: ImageRes.callVideo,
            alignment: MainAxisAlignment.start,
            onTap: () => onTapSheetItem.call(1),
          ),
        ],
      ),
      // barrierColor: Colors.transparent,
    );
  }

  static openIMGroupCallSheet(
    String groupID,
    Function(int index) onTapSheetItem,
  ) {
    return Get.bottomSheet(
      BottomSheetView(
        mainAxisAlignment: MainAxisAlignment.start,
        items: [
          SheetItem(
            label: StrRes.callVoice,
            icon: ImageRes.callVoice,
            onTap: () => onTapSheetItem.call(0),
          ),
          SheetItem(
            label: StrRes.callVideo,
            icon: ImageRes.callVideo,
            onTap: () => onTapSheetItem.call(1),
          ),
        ],
      ),
      // barrierColor: Colors.transparent,
    );
  }

  static void openPhotoSheet({
    Function(dynamic path, dynamic url)? onData,
    bool crop = true,
    bool toUrl = true,
    bool fromGallery = true,
    bool fromCamera = true,
    bool useNicknameAsAvatarEnabled = true,
    bool onlyImage = false,
    List<SheetItem> items = const [],
    int quality = 80,
    bool isGroup = false,
  }) {
    bool allowSendImageTypeHelper(String? mimeType) {
      final result = mimeType?.contains('png') == true ||
          mimeType?.contains('jpeg') == true;

      return result;
    }

    Future<bool> allowSendImageType(AssetEntity entity) async {
      final mimeType = await entity.mimeTypeAsync;

      return allowSendImageTypeHelper(mimeType);
    }

    Get.bottomSheet(
      barrierColor: Colors.transparent,
      Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32.r),
                topRight: Radius.circular(32.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.08),
                  offset: const Offset(0, -3),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9CA3AF).withOpacity(0.06),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFF3F4F6),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      ...items
                          .asMap()
                          .entries
                          .map((entry) => _buildPhotoActionItem(
                                icon: const [[]],
                                customIcon: entry.value.customIcon,
                                title: entry.value.label,
                                onTap: entry.value.onTap!,
                                index: entry.key,
                              )),
                      if (fromCamera)
                        _buildPhotoActionItem(
                          icon: HugeIcons.strokeRoundedCamera01,
                          title: StrRes.camera,
                          onTap: () async {
                            Get.back();
                            PermissionStatus result = PermissionStatus.denied;
                            if (!onlyImage) {
                              result = await Permission.microphone.request();
                            }
                            Permissions.camera(() async {
                              await CameraPicker.pickFromCamera(
                                Get.context!,
                                locale: Get.locale,
                                pickerConfig: CameraPickerConfig(
                                  enableAudio: onlyImage
                                      ? false
                                      : result == PermissionStatus.granted,
                                  enableRecording: false,
                                  enableScaledPreview: false,
                                  maximumRecordingDuration: 60.seconds,
                                  shouldDeletePreviewFile: true,
                                  onEntitySaving:
                                      (context, viewType, file) async {
                                    final map = await uCropPic(
                                      file.path,
                                      crop: crop,
                                      toUrl: toUrl,
                                      quality: quality,
                                      showLoading: false,
                                    );
                                    onData?.call(map['path'], map['url']);
                                    Get.back();
                                    Get.back();
                                  },
                                  onMinimumRecordDurationNotMet: () {
                                    IMViews.showToast(StrRes.tapTooShort);
                                  },
                                ),
                              );
                            });
                          },
                          index: 0,
                        ),
                      _buildPhotoDivider(),
                      if (fromGallery)
                        _buildPhotoActionItem(
                          icon: HugeIcons.strokeRoundedImage01,
                          title: StrRes.toolboxAlbum,
                          onTap: () {
                            Get.back();
                            Permissions.photos(
                              () async {
                                final List<AssetEntity>? assets =
                                    await AssetPicker.pickAssets(Get.context!,
                                        pickerConfig: AssetPickerConfig(
                                            requestType: RequestType.image,
                                            maxAssets: 1,
                                            selectPredicate:
                                                (_, entity, isSelected) async {
                                              if (await allowSendImageType(
                                                  entity)) {
                                                return true;
                                              }

                                              IMViews.showToast(
                                                  StrRes.supportsTypeHint);

                                              return false;
                                            }));
                                final file = await assets?.firstOrNull?.file;

                                if (file?.path != null) {
                                  final map = await uCropPic(file!.path,
                                      crop: crop,
                                      toUrl: toUrl,
                                      quality: quality);
                                  onData?.call(map['path'], map['url']);
                                }
                              },
                            );
                          },
                          index: 1,
                          isLast: !useNicknameAsAvatarEnabled,
                        ),
                      if (useNicknameAsAvatarEnabled) ...[
                        _buildPhotoDivider(),
                        _buildPhotoActionItem(
                          icon: HugeIcons.strokeRoundedUser,
                          title: isGroup
                              ? StrRes.useDefaultGroupAvatar
                              : StrRes.useNicknameAsAvatar,
                          onTap: () async {
                            Get.back();
                            var confirm = await Get.dialog(CustomDialog(
                              title: isGroup
                                  ? StrRes.confirmUseDefaultGroupAvatar
                                  : StrRes.confirmUseNicknameAsAvatar,
                            ));
                            if (confirm) {
                              onData?.call('', 'NICKNAME');
                            }
                          },
                          index: 2,
                          isLast: true,
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    width: Get.width / 3 + 4,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(50),
                        left: Radius.circular(50),
                      ),
                    ),
                    child: Text(StrRes.cancel,
                        style: const TextStyle(
                            fontFamily: 'FilsonPro',
                            fontWeight: FontWeight.w500)),
                  ),
                ),
                SizedBox(height: 15.h),
              ],
            ),
          ),
        ],
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  static Widget _buildPhotoActionItem({
    required List<List<dynamic>> icon,
    IconData? customIcon,
    required String title,
    required VoidCallback onTap,
    required int index,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: isLast
              ? BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                )
              : null,
          child: Row(
            children: [
              customIcon != null
                  ? Icon(
                      customIcon,
                      size: 20.w,
                      color: const Color(0xFF424242),
                    )
                  : HugeIcon(
                      icon: icon,
                      size: 20.w,
                      color: const Color(0xFF424242),
                    ),
              16.horizontalSpace,
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildPhotoDivider() {
    return Padding(
      padding: EdgeInsets.only(left: 70.w),
      child: const Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFF3F4F6),
      ),
    );
  }

  static Future<Map<String, dynamic>> uCropPic(
    String path, {
    bool crop = true,
    bool toUrl = true,
    int quality = 80,
    bool showLoading = true,
  }) async {
    CroppedFile? cropFile;
    String? url;
    if (crop && !path.endsWith('.gif')) {
      cropFile = await IMUtils.uCrop(path);
      if (cropFile == null) {
        // 放弃选择
        // return {'path': cropFile?.path ?? path, 'url': url};
        return {'path': null, 'url': null};
      }
    }
    if (toUrl) {
      String putID = const Uuid().v4();
      dynamic result;
      if (null != cropFile) {
        Logger.print('-----------crop path: ${cropFile.path}');
        if (showLoading) LoadingView.singleton.show();
        final image = await IMUtils.compressImageAndGetFile(
            File(cropFile.path),
            quality: quality);

        result = await OpenIM.iMManager.uploadFile(
          id: putID,
          filePath: image!.path,
          fileName: image.path.split('/').last,
        );
        if (showLoading) LoadingView.singleton.dismiss();
      } else {
        Logger.print('-----------source path: $path');
        if (showLoading) LoadingView.singleton.show();
        final image =
            await IMUtils.compressImageAndGetFile(File(path), quality: quality);

        result = OpenIM.iMManager.uploadFile(
          id: putID,
          filePath: image!.path,
          fileName: image.path,
        );
        if (showLoading) LoadingView.singleton.dismiss();
      }
      if (result is String) {
        url = jsonDecode(result)['url'];
        Logger.print('url:$url');
      }
    }
    return {'path': cropFile?.path ?? path, 'url': url};
  }

  static void openDownloadSheet(
    String url, {
    Function()? onDownload,
  }) {
    Get.bottomSheet(
      BottomSheetView(
        items: [
          SheetItem(
            label: StrRes.download,
            onTap: () {
              Permissions.storage(() => onDownload?.call());
            },
          ),
        ],
      ),
      barrierColor: Colors.transparent,
    );
  }

  static TextSpan getTimelineTextSpan(int ms) {
    int locTimeMs = DateTime.now().millisecondsSinceEpoch;
    var languageCode = Get.locale?.languageCode ?? 'zh';

    if (DateUtil.isToday(ms, locMs: locTimeMs)) {
      return TextSpan(
        text: languageCode == 'zh' ? '今天' : 'Today',
        style: Styles.ts_0C1C33_17sp_medium,
      );
    }

    if (DateUtil.isYesterdayByMs(ms, locTimeMs)) {
      return TextSpan(
        text: languageCode == 'zh' ? '昨天' : 'Yesterday',
        style: Styles.ts_0C1C33_17sp_medium,
      );
    }

    if (DateUtil.isWeek(ms, locMs: locTimeMs)) {
      final weekday = DateUtil.getWeekdayByMs(ms, languageCode: languageCode);
      if (weekday.contains('星期')) {
        return TextSpan(
          text: weekday.replaceAll('星期', ''),
          style: Styles.ts_0C1C33_17sp_medium,
          children: [
            TextSpan(
              text: '\n星期',
              style: Styles.ts_0C1C33_12sp_medium,
            ),
          ],
        );
      }
      return TextSpan(text: weekday, style: Styles.ts_0C1C33_17sp_medium);
    }

    // if (DateUtil.yearIsEqualByMs(ms, locTimeMs)) {
    //   final date = IMUtils.formatDateMs(ms, format: 'MM月dd');
    //   final one = date.split('月')[0];
    //   final two = date.split('月')[1];
    //   return TextSpan(
    //     text: two,
    //     style: Styles.ts_0C1C33_17sp_medium,
    //     children: [
    //       TextSpan(
    //         text: '\n$one${languageCode == 'zh' ? '月' : ''}',
    //         style: Styles.ts_0C1C33_12sp_medium,
    //       ),
    //     ],
    //   );
    // }
    final date = IMUtils.formatDateMs(ms, format: 'MM月dd');
    final one = date.split('月')[0];
    final two = date.split('月')[1];
    return TextSpan(
      text: '${int.parse(two)}',
      style: Styles.ts_0C1C33_17sp_medium,
      children: [
        TextSpan(
          text: '\n${int.parse(one)}${languageCode == 'zh' ? '月' : ''}',
          style: Styles.ts_0C1C33_12sp_medium,
        ),
      ],
    );
  }

  static Future<String?> showCountryCodePicker() async {
    Completer<String> completer = Completer();
    showCountryPicker(
      context: Get.context!,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Colors.white,
        textStyle: TextStyle(
          fontFamily: 'FilsonPro',
          fontSize: 16.sp,
          color: Colors.blueGrey,
        ),
        bottomSheetHeight: 500.h,
        // Optional. Country list modal height
        //Optional. Sets the border radius for the bottomsheet.
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.0.r),
          topRight: Radius.circular(8.0.r),
        ),
        //Optional. Styles the search field.
        inputDecoration: InputDecoration(
          labelText: StrRes.search,
          // hintText: 'Start typing to search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
          ),
        ),
      ),
      onSelect: (Country country) {
        completer.complete("+${country.phoneCode}");
      },
    );
    return completer.future;
  }

  static void showSinglePicker({
    required String title,
    required String description,
    required dynamic pickerData,
    bool isArray = false,
    List<int>? selected,
    Function(List<int> indexList, List valueList)? onConfirm,
  }) {
    Picker(
      adapter: PickerDataAdapter<String>(
        pickerData: pickerData,
        isArray: isArray,
      ),
      backgroundColor: Styles.c_FFFFFF,
      changeToFirst: true,
      hideHeader: false,
      containerColor: Styles.c_0089FF,
      textStyle: Styles.ts_0C1C33_17sp.copyWith(color: Styles.c_0C1C33),
      selectedTextStyle: Styles.ts_0C1C33_17sp.copyWith(color: Styles.c_0C1C33),
      itemExtent: 45.h,
      cancelTextStyle: Styles.ts_0C1C33_17sp,
      confirmTextStyle: Styles.ts_0089FF_17sp,
      cancelText: StrRes.cancel,
      confirmText: StrRes.confirm,
      selecteds: selected,
      builderHeader: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(bottom: 7.h),
            child: title.toText..style = Styles.ts_0C1C33_17sp,
          ),
          Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: description.toText..style = Styles.ts_8E9AB0_14sp),
        ],
      ),
      selectionOverlay: Container(
        alignment: Alignment.center,
      ),
      onConfirm: (Picker picker, List value) {
        onConfirm?.call(picker.selecteds, picker.getSelectedValues());
        // 在此处执行选定项目的逻辑
      },
    ).showDialog(Get.context!);
  }
}
