import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class AppealLogic extends GetxController {
  final TextEditingController descriptionController = TextEditingController();
  final FocusNode descriptionFocusNode = FocusNode();

  final blockReason = ''.obs;

  @override
  void onInit() {
    blockReason.value = Get.arguments['blockReason'];
    super.onInit();
  }

  void submitAppeal() async {
    if (descriptionController.text.isEmpty) {
      IMViews.showToast(StrRes.pleaseEnterAppealContent);
      return;
    }
    descriptionFocusNode.unfocus();
    await LoadingView.singleton.wrap(asyncFunction: () async {
      await ChatApis.appeal(
        chatAddr: Get.arguments['chatAddr'],
        imUserId: Get.arguments['imUserId'],
        reason: descriptionController.text,
      );
      LoadingView.singleton.dismiss();
      await CustomDialog.show(
        title: StrRes.appealSubmittedTitle,
        content: StrRes.appealSubmittedContent,
        showCancel: false,
      );
      Get.back();
    });
  }
}
