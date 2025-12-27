import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:uuid/uuid.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';

class ReportSubmitLogic extends GetxController {
  final TextEditingController descriptionController = TextEditingController();
  final FocusNode descriptionFocusNode = FocusNode();
  final RxList<File> images = <File>[].obs;
  final RxList<String> uploadedUrls = <String>[].obs;

  final reportReason = ''.obs;
  List<AssetEntity> selectedAssets = [];

  @override
  void onInit() {
    reportReason.value = Get.arguments['reportReason'];
    super.onInit();
  }

  Future<void> pickImage() async {
    Permissions.photos(() async {
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        Get.context!,
        pickerConfig: AssetPickerConfig(
          maxAssets: 5,
          requestType: RequestType.image,
          selectedAssets: selectedAssets,
          limitedPermissionOverlayPredicate: (state) => false,
        ),
      );

      if (result != null) {
        images.clear();
        selectedAssets.clear();
        for (var asset in result) {
          final file = await asset.file;
          if (file != null) {
            images.add(file);
            selectedAssets.add(asset);
          }
        }
      }
    });
  }

  void removeImage(File image) {
    final index = images.indexOf(image);
    if (index != -1) {
      images.removeAt(index);
      selectedAssets.removeAt(index);
    }
  }

  Future<List<String>> uploadImages() async {
    final List<String> urls = [];
    for (var image in images) {
      String path = image.path;
      try {
        var response = await OpenIM.iMManager.uploadFile(
          id: const Uuid().v4(),
          filePath: path,
          fileName: path,
        );
        if (response is String) {
          final url = jsonDecode(response)['url'];
          urls.add(url);
        }
      } catch (e) {
        Logger.print('图片上传失败 $e', isError: true);
      }
    }
    return urls;
  }

  void submitReport() async {
    if (descriptionController.text.isEmpty) {
      IMViews.showToast(StrRes.pleaseEnterReportContent);
      return;
    }
    descriptionFocusNode.unfocus();
    var confirm = await Get.dialog(
        barrierColor: Colors.transparent,
        CustomDialog(
          title: StrRes.reportConfirmTitle,
          content: reportReason.value,
        ));
    if (confirm != true) {
      return;
    }
    await LoadingView.singleton.wrap(
      asyncFunction: () async {
        final imageURls = await uploadImages();
        await ChatApis.report(
          type: Get.arguments['chatType'] == 'groupChat' ? 'group' : 'user',
          contentType: reportReason.value,
          content: descriptionController.text,
          images: imageURls,
          reportedGroupID: Get.arguments['groupID'],
          reportedUserID: Get.arguments['userID'],
        );
        LoadingView.singleton.dismiss();
        await Get.dialog(
            barrierColor: Colors.transparent,
            CustomDialog(
              title: StrRes.reportSubmittedTitle,
              content: StrRes.reportSubmittedContent,
              showCancel: false,
            ));
        Get.back(result: true);
      },
    );
  }
}
