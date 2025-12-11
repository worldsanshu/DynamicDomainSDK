import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import '../select_contacts_logic.dart';

class SelectContactsFromGroupLogic extends GetxController {
  final selectContactsLogic = Get.find<SelectContactsLogic>();
  final allList = <GroupInfo>[].obs;
  
  final searchCtrl = TextEditingController();
  final searchText = ''.obs;
  final searchResults = <GroupInfo>[].obs;

  @override
  void onReady() {
    _getGroupRelatedToMe();
    super.onReady();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

  void _getGroupRelatedToMe() async {
    final list = await OpenIM.iMManager.groupManager.getJoinedGroupList();
    allList.addAll(list);
  }

  void performSearch(String query) {
    searchText.value = query;
    searchResults.clear();
    
    if (query.isEmpty) {
      return;
    }

    final lowerQuery = query.toLowerCase();

    // Search by group name and groupID
    for (var group in allList) {
      bool match = false;
      
      // Search by group name
      if (group.groupName?.toLowerCase().contains(lowerQuery) ?? false) {
        match = true;
      }
      
      // Search by groupID
      if (!match && (group.groupID?.toLowerCase().contains(lowerQuery) ?? false)) {
        match = true;
      }
      
      if (match) {
        searchResults.add(group);
      }
    }
  }

  void clearSearch() {
    searchCtrl.clear();
    searchText.value = '';
    searchResults.clear();
  }

  Iterable<GroupInfo> get operableList => allList.where(_remove);

  bool _remove(GroupInfo info) => !selectContactsLogic.isDefaultChecked(info);
}
