// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/core/controller/client_config_controller.dart';
import 'package:openim/pages/contacts/group_profile_panel/group_profile_panel_logic.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

enum SearchType {
  user,
  group,
}

class AddContactsBySearchLogic extends GetxController {
  final refreshCtrl = RefreshController();
  final searchCtrl = TextEditingController();
  final focusNode = FocusNode();
  final userInfoList = <UserFullInfo>[].obs;
  final groupInfoList = <GroupInfo>[].obs;
  late SearchType searchType;
  int pageNo = 0;

  final clientConfigLogic = Get.find<ClientConfigController>();
  get friendSearchConfig => FriendSearchConfig.fromKey(clientConfigLogic.friendSearchMode);

  @override
  void onClose() {
    searchCtrl.dispose();
    focusNode.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    searchType = Get.arguments['searchType'] ?? SearchType.user;
    searchCtrl.addListener(() {
      if (searchKey.isEmpty) {
        focusNode.requestFocus();
        userInfoList.clear();
        groupInfoList.clear();
      }
    });
    super.onInit();
  }

  bool get isSearchUser => searchType == SearchType.user;

  String get searchKey => searchCtrl.text.trim();

  bool get isNotFoundUser => userInfoList.isEmpty && searchKey.isNotEmpty;

  bool get isNotFoundGroup => groupInfoList.isEmpty && searchKey.isNotEmpty;

  void search() {
    if (searchKey.isEmpty) return;
    if (isSearchUser) {
      searchUser();
    } else {
      searchGroup();
    }
  }

  void searchUser() async {
    // Determine if the input is all digits and its length
    final isAllDigits = RegExp(r'^\d+$').hasMatch(searchKey);
    final length = searchKey.length;

    void clearUserList() {
      userInfoList.assignAll([]);
      refreshCtrl.refreshCompleted();
      refreshCtrl.loadNoData();
    }

    // Prevent searching by phone number
    if (friendSearchConfig.noPhone && isAllDigits && length == 11) {
      clearUserList();
      return;
    }

    // Prevent searching by userID
    if (friendSearchConfig.noUserID && isAllDigits && length == 10) {
      clearUserList();
      return;
    }

    // Prevent fuzzy search: input must be a complete userID or phone number
    if (friendSearchConfig.noFuzzy) {
      if (!isAllDigits || (length != 10 && length != 11)) {
        clearUserList();
        return;
      }
    }

    var list = await LoadingView.singleton.wrap(
      asyncFunction: () => ChatApis.searchUserFullInfo(
        content: searchKey,
        pageNumber: pageNo = 1,
        showNumber: 20,
      ),
    );
    userInfoList.assignAll(list ?? []);
    refreshCtrl.refreshCompleted();
    if (null == list || list.isEmpty || list.length < 20) {
      refreshCtrl.loadNoData();
    } else {
      refreshCtrl.loadComplete();
    }
  }

  void loadMoreUser() async {
    var list = await LoadingView.singleton.wrap(
      asyncFunction: () => ChatApis.searchUserFullInfo(
        content: searchKey,
        pageNumber: ++pageNo,
        showNumber: 20,
      ),
    );
    userInfoList.addAll(list ?? []);
    refreshCtrl.refreshCompleted();
    if (null == list || list.isEmpty || list.length < 20) {
      refreshCtrl.loadNoData();
    } else {
      refreshCtrl.loadComplete();
    }
  }

  void searchGroup() async {
    var list = await OpenIM.iMManager.groupManager.getGroupsInfo(
      groupIDList: [searchKey],
    );
    groupInfoList.assignAll(list);
  }

  String getMatchContent(UserFullInfo userInfo) {
    final keyword = searchCtrl.text;
    // String searchPrefix = "%s";
    // if (keyword == userInfo.userID) {
    //   searchPrefix = StrRes.searchIDIs;
    // } else if (keyword == userInfo.phoneNumber) {
    //   searchPrefix = StrRes.searchPhoneIs;
    // } else if (keyword == userInfo.email) {
    //   searchPrefix = StrRes.searchEmailIs;
    // } else if (keyword == userInfo.nickname) {
    //   searchPrefix = StrRes.searchNicknameIs;
    // }
    return sprintf(StrRes.searchNicknameIs, [userInfo.nickname]);
  }

  String? getShowName(dynamic info) {
    if (info is UserFullInfo) {
      return info.nickname;
    } else if (info is GroupInfo) {
      return info.groupName;
    }
    return null;
  }

  void viewInfo(dynamic info) {
    if (info is UserFullInfo) {
      AppNavigator.startUserProfilePane(
        userID: info.userID!,
        nickname: info.nickname,
        faceURL: info.faceURL,
      );
    } else if (info is GroupInfo) {
      AppNavigator.startGroupProfilePanel(
        groupID: info.groupID,
        joinGroupMethod: JoinGroupMethod.search,
      );
    }
  }

  String getShowTitle(info) {
    if (!isSearchUser) {
      return sprintf(StrRes.searchGroupNameIs, [getShowName(info)]);
    }

    UserFullInfo userFullInfo = info;
    String? tips, content;
    if (int.tryParse(searchKey) != null) {
      if (searchKey.length == 11) {
        tips = StrRes.phoneNumber;
        content = userFullInfo.phoneNumber ?? searchKey;
      } else {
        tips = StrRes.userID;
        content = userFullInfo.userID;
      }
    } else {
      tips = StrRes.searchNicknameIs;
      content = getShowName(info);
    }
    return "$tips:$content";
  }
}

class FriendSearchConfig {
  final bool noFuzzy;
  final bool noUserID;
  final bool noPhone;

  FriendSearchConfig({
    required this.noFuzzy,
    required this.noUserID,
    required this.noPhone,
  });

  factory FriendSearchConfig.fromKey(String key) {
    return FriendSearchConfig(
      noFuzzy: key.contains('noFuzzy'),
      noUserID: key.contains('noUserID'),
      noPhone: key.contains('noPhone'),
    );
  }
}
