import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../../routes/app_navigator.dart';
import '../../conversation/conversation_logic.dart';
import '../select_contacts/select_contacts_logic.dart';

class CreateGroupLogic extends GetxController {
  final conversationLogic = Get.find<ConversationLogic>();
  final nameCtrl = TextEditingController();
  final checkedList = <UserInfo>[];
  final defaultCheckedList = <UserInfo>[];
  final allList = <UserInfo>[].obs;
  final faceURL = ''.obs;

  @override
  void onInit() {
    // Always add current user first
    final currentUser = OpenIM.iMManager.userInfo;
    allList.add(UserInfo(
      userID: currentUser.userID,
      nickname: currentUser.nickname,
      faceURL: currentUser.faceURL,
    ));

    // Read defaultCheckedMaps (List of Maps) - contains chat partner info
    final argDefaultMaps = Get.arguments?['defaultCheckedMaps'];

    if (argDefaultMaps is List) {
      for (var map in argDefaultMaps) {
        if (map is Map) {
          final userID = map['userID'] as String?;
          // Skip if it's the current user (already added)
          if (userID != null && userID != currentUser.userID) {
            final user = UserInfo(
              userID: userID,
              nickname: map['nickname'] as String?,
              faceURL: map['faceURL'] as String?,
            );
            defaultCheckedList.add(user);
            allList.add(user);
          }
        }
      }
    }

    // Read checkedList (List of UserInfo) - newly selected members
    final argChecked = Get.arguments?['checkedList'];

    if (argChecked is List) {
      for (var item in argChecked) {
        if (item is UserInfo) {
          // Skip if already exists in allList
          if (!allList.any((u) => u.userID == item.userID)) {
            checkedList.add(item);
            allList.add(item);
          }
        }
      }
    }

    super.onInit();
  }

  String get groupName {
    String name = nameCtrl.text.trim();
    if (name.isEmpty) {
      int limit = min(allList.length, 3);
      name = allList.sublist(0, limit).map((e) => e.nickname).join('、');
    }
    return name;
  }

  completeCreation() async {
    try {
      if (allList.isEmpty) {
        IMViews.showToast(StrRes.createGroupMinMemberHint);
        return;
      }
      var info = await LoadingView.singleton.wrap(
        asyncFunction: () => OpenIM.iMManager.groupManager.createGroup(
          groupInfo: GroupInfo(
            groupID: '',
            groupName: groupName,
            faceURL: faceURL.value,
            groupType: GroupType.work,
          ),
          memberUserIDs: allList
              .where((e) => e.userID != OpenIM.iMManager.userID)
              .map((e) => e.userID!)
              .toList(),
        ),
      );

      conversationLogic.toChat(
        offUntilHome: true,
        groupID: info.groupID,
        nickname: groupName,
        faceURL: faceURL.value,
        sessionType: info.sessionType,
      );
    } catch (e) {
      if (e is PlatformException) {
        if (e.code == '1805') {
          IMViews.showToast(StrRes.systemMaintenance);
          return;
        } else {
          IMViews.showToast(e.message ?? '');
        }
      }
    }
  }

  void selectAvatar() {
    IMViews.openPhotoSheet(
        useNicknameAsAvatarEnabled: true,
        isGroup: true,
        onData: (path, url) {
          if (url == 'NICKNAME') {
            faceURL.value = '';
          } else if (url != null) {
            faceURL.value = url;
          }
        });
  }

  int length() {
    return (allList.length + 2) > 10 ? 10 : (allList.length + 2);
  }

  Widget itemBuilder({
    required int index,
    required Widget Function(UserInfo info) builder,
    required Widget Function() addButton,
    required Widget Function() delButton,
  }) {
    if (allList.length > 8) {
      if (index < 8) {
        var info = allList.elementAt(index);
        return builder(info);
      } else if (index == 8) {
        return addButton();
      } else {
        return delButton();
      }
    } else {
      if (index < allList.length) {
        var info = allList.elementAt(index);
        return builder(info);
      } else if (index == allList.length) {
        return addButton();
      } else {
        return delButton();
      }
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    super.onClose();
  }

  void opMember({bool isDel = false}) async {
    final result = await AppNavigator.startSelectContacts(
      action: SelAction.addMember,
      checkedList: checkedList,
      defaultCheckedIDList: defaultCheckedList.map((e) => e.userID!).toList(),
      openSelectedSheet: isDel,
    );
    final list = IMUtils.convertSelectContactsResultToUserInfo(result);
    if (list is List<UserInfo>) {
      checkedList
        ..clear()
        ..addAll(list);
      allList
        ..assignAll(defaultCheckedList)
        ..addAll(list);
    }
  }
}
