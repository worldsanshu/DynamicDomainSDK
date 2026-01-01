import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim/core/controller/auth_controller.dart';
import 'package:openim/core/controller/gateway_config_controller.dart';
import 'package:openim_common/openim_common.dart';

class MerchantSearchLogic extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final gatewayConfigController = Get.find<GatewayConfigController>();

  var merchantCodeCtrl = TextEditingController();
  final focusNode = FocusNode();
  var merchantList = <Merchant>[].obs;
  var rightCode = '';

  var inputText = ''.obs;
  final tipShow = false.obs;
  final hasSearched = false.obs;

  bool get isSearchNotResult => hasSearched.value && merchantList.isEmpty;

  get defaultMerchantID => gatewayConfigController.defaultMerchantID;

  @override
  void onInit() {
    merchantCodeCtrl.addListener(() {
      final inputTextTemp = inputText.value;
      inputText.value = merchantCodeCtrl.text.trim();
      tipShow.value =
          inputTextTemp != inputText.value && inputText.value.length >= 6;
      if (tipShow.value) {
        merchantList.value = [];
        hasSearched.value = false;
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    merchantCodeCtrl.dispose();
    super.onClose();
  }

  void searchMerchantInfo(String code) async {
    try {
      hasSearched.value = true;
      merchantList.value = [
        await GatewayApi.searchMerchant(code: code, showErrorToast: false)
      ];
      rightCode = code;
    } catch (e) {
      // Print error
      merchantList.clear();
    } finally {
      focusNode.unfocus();
      tipShow.value = false;
    }
  }

  void onBind(Merchant merchant) async {
    final result = await CustomDialog.show(
          title: StrRes.confirmBindCompany,
          content: StrRes.confirmBindCompanyContent
              .replaceFirst('%s', merchant.fullName),
        );
    if (result == true) {
      LoadingView.singleton.wrap(asyncFunction: () async {
        try {
          await GatewayApi.bindMerchant(code: rightCode);
          IMViews.showToast(StrRes.bindSuccess,type: 1);
          merchantCodeCtrl.text = '';
          Get.back(result: true);
        } catch (error) {
          LoadingView.singleton.dismiss();
        }
      });
    }
  }
}
