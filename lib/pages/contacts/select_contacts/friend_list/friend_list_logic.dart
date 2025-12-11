import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim/pages/contacts/friend_list_logic.dart';
import 'package:openim_common/openim_common.dart';
import '../select_contacts_logic.dart';

class SelectContactsFromFriendsLogic extends GetxController {
  final selectContactsLogic = Get.find<SelectContactsLogic>();
  final friendLogic = Get.find<FriendListLogic>();

  final searchCtrl = TextEditingController();
  final searchText = ''.obs;
  final searchResults = <ISUserInfo>[].obs;

  get friendList => friendLogic.friendList;

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

  void performSearch(String query) {
    searchText.value = query;
    searchResults.clear();
    
    if (query.isEmpty) {
      return;
    }

    final lowerQuery = query.toLowerCase();

    // Search by nickname, remark, and userID
    for (var friend in friendList) {
      bool match = false;
      
      // Search by nickname
      if (friend.nickname?.toLowerCase().contains(lowerQuery) ?? false) {
        match = true;
      }
      
      // Search by remark (if available)
      if (!match && (friend.remark?.toLowerCase().contains(lowerQuery) ?? false)) {
        match = true;
      }
      
      // Search by userID
      if (!match && (friend.userID?.toLowerCase().contains(lowerQuery) ?? false)) {
        match = true;
      }
      
      if (match) {
        searchResults.add(friend);
      }
    }
  }

  void clearSearch() {
    searchCtrl.clear();
    searchText.value = '';
    searchResults.clear();
  }

  Iterable<ISUserInfo> get operableList => friendList.where(_remove);

  bool _remove(ISUserInfo info) => !selectContactsLogic.isDefaultChecked(info);
}
