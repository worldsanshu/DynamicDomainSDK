import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim/core/controller/auth_controller.dart';
import 'package:openim/core/controller/gateway_config_controller.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';

class MerchantListLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  final MerchantController merchantController = Get.find<MerchantController>();
  final AuthController authController = Get.find<AuthController>();
  final gatewayConfigController = Get.find<GatewayConfigController>();

  final merchantList = <Merchant>[].obs;
  final noData = false.obs;
  final fromLogin = false.obs;

  // Search
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final searchedMerchant = Rxn<Merchant>(); // Merchant found via API search
  final isSearching = false.obs;

  get defaultMerchantID => gatewayConfigController.defaultMerchantID;

  // Filtered list based on search query
  List<Merchant> get filteredMerchantList {
    if (searchQuery.value.isEmpty) {
      return merchantList;
    }
    final query = searchQuery.value.toLowerCase();

    // First filter from existing list
    final filtered = merchantList.where((merchant) {
      final inviteCode = merchant.inviteCode.toLowerCase();
      final id = merchant.id.toString();
      return inviteCode.contains(query) || id.contains(query);
    }).toList();

    // If found in existing list, return it
    if (filtered.isNotEmpty) {
      searchedMerchant.value = null; // Clear API search result
      return filtered;
    }

    // If not found and we have a search result from API, show it
    if (searchedMerchant.value != null) {
      return [searchedMerchant.value!];
    }

    return [];
  }

  @override
  void onInit() {
    fromLogin.value = Get.arguments['fromLogin'] ?? false;
    refreshData();
    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void onSearchChanged(String value) async {
    searchQuery.value = value;

    if (value.isEmpty) {
      searchedMerchant.value = null;
      return;
    }

    // Check if value matches any existing merchant
    final query = value.toLowerCase();
    final hasMatch = merchantList.any((merchant) {
      final inviteCode = merchant.inviteCode.toLowerCase();
      final id = merchant.id.toString();
      return inviteCode.contains(query) || id.contains(query);
    });

    // If no match in existing list, search via API
    if (!hasMatch && value.length >= 5) {
      await _searchMerchantByCode(value);
    } else {
      searchedMerchant.value = null;
    }
  } 

  Future<void> _searchMerchantByCode(String code) async {
    try {
      isSearching.value = true;
      final merchant = await GatewayApi.searchMerchant(
        code: code,
        showErrorToast: false,
      );

      // Check if this merchant is already in the list
      if (!isExists(merchant)) {
        searchedMerchant.value = merchant;
      } else {
        searchedMerchant.value = null;
      }
    } catch (e) {
      searchedMerchant.value = null;
    } finally {
      isSearching.value = false;
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchedMerchant.value = null;
  }

  void refreshData() async {
    LoadingView.singleton.wrap(
      asyncFunction: () async {
        merchantList.value = await GatewayApi.getMerchantList();
        noData.value = merchantList.isEmpty;
      },
    );
  }

  bool isExists(Merchant merchant) {
    for (var m in merchantList) {
      if (m.id == merchant.id) {
        return true;
      }
    }
    return false;
  }

  void startMerchantSearch() async {
    final changed = await AppNavigator.startMerchantSearch();
    if (changed == true) {
      noData.value = false;
      refreshData();
    }
  }

  Future<void> onBind(Merchant merchant) async {
    print('===BIND=== onBind called for merchant: ${merchant.inviteCode}');
    try {
      await LoadingView.singleton.wrap(asyncFunction: () async {
        print('===BIND=== Calling bindMerchant API...');
        await GatewayApi.bindMerchant(code: merchant.inviteCode);
        print('===BIND=== API call successful');
      });
      print('===BIND=== Showing success toast');
      IMViews.showToast(StrRes.bindSuccess);
      clearSearch();
      refreshData();
    } catch (e) {
      print('===BIND=== Error: $e');
      IMViews.showToast('Bind failed: $e');
    }
  }

  void onSwitch(Merchant merchant) async {
    authController.switchMerchant(
        merchant: merchant, fromLogin: fromLogin.value);
  }

  void onRefresh(Merchant merchant) async {
    await authController.refreshIm();
    AppNavigator.startMain();
  }
}
