import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/pages/chat/group_setup/group_setup_logic.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

import '../../../../../core/controller/im_controller.dart';
import '../../../../../routes/app_navigator.dart';
import '../group_member_list_logic.dart';

class SearchGroupMemberLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final controller = RefreshController();
  final focusNode = FocusNode();
  final searchCtrl = TextEditingController();
  final memberList = <GroupMembersInfo>[].obs;
  final count = 100;
  late GroupInfo groupInfo;
  late GroupMemberOpType opType;
  late StreamSubscription mISub;
  late bool isOwnerOrAdmin;

  @override
  void onInit() {
    groupInfo = Get.arguments['groupInfo'];
    opType = Get.arguments['opType'];
    isOwnerOrAdmin = Get.arguments['isOwnerOrAdmin'];
    searchCtrl.addListener(_clearInput);
    mISub = imLogic.memberInfoChangedSubject.listen((e) {
      if (e.groupID == groupInfo.groupID) {
        final member =
            memberList.firstWhereOrNull((el) => el.userID == e.userID);
        if (null != member && e.roleLevel != member.roleLevel) {
          member.roleLevel = e.roleLevel;
          memberList.refresh();
        }
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    focusNode.dispose();
    searchCtrl.dispose();
    mISub.cancel();
    super.onClose();
  }

  bool get isSearchNotResult =>
      searchCtrl.text.trim().isNotEmpty && memberList.isEmpty;

  _clearInput() {
    final key = searchCtrl.text.trim();
    if (key.isEmpty) {
      memberList.clear();
    }
  }

  Future<List<GroupMembersInfo>> _request(int offset) =>
      LoadingView.singleton.wrap(
        asyncFunction: () => OpenIM.iMManager.groupManager.searchGroupMembers(
          groupID: groupInfo.groupID,
          isSearchMemberNickname: true,
          isSearchUserID: true,
          keywordList: [searchCtrl.text.trim()],
          offset: offset,
          count: count,
        ),
      );

  search() async {
    final key = searchCtrl.text.trim();
    if (key.isNotEmpty) {
      final list = await _request(0);

      // Also search by friend remark name
      final keyLower = key.toLowerCase();
      final remarkMatches = <String>[];
      for (var entry in imLogic.userRemarkMap.entries) {
        final userId = entry.key;
        final remark = entry.value.toLowerCase();
        if (remark.contains(keyLower) && !list.any((m) => m.userID == userId)) {
          remarkMatches.add(userId);
        }
      }

      // Fetch member info for remark matches
      if (remarkMatches.isNotEmpty) {
        try {
          final memberInfos =
              await OpenIM.iMManager.groupManager.getGroupMembersInfo(
            groupID: groupInfo.groupID,
            userIDList: remarkMatches,
          );
          list.addAll(memberInfos);
        } catch (e) {
          // User might not be a member of this group, ignore
        }
      }

      memberList.assignAll(list);
      if (list.length < count) {
        controller.loadNoData();
      } else {
        controller.loadComplete();
      }
    }
  }

  load() async {
    final key = searchCtrl.text.trim();
    if (key.isNotEmpty) {
      final list = await _request(memberList.length);
      memberList.addAll(list);
      if (list.length < count) {
        controller.loadNoData();
      } else {
        controller.loadComplete();
      }
    }
  }

  bool hiddenMembers(GroupMembersInfo info) {
    if (opType == GroupMemberOpType.transferRight ||
        opType == GroupMemberOpType.at ||
        opType == GroupMemberOpType.call) {
      return info.userID == OpenIM.iMManager.userID;
    } else if (opType == GroupMemberOpType.del) {
      final logic = Get.find<GroupSetupLogic>();
      return logic.isAdmin && info.roleLevel != GroupRoleLevel.member ||
          logic.isOwner && info.roleLevel == GroupRoleLevel.owner;
    }
    return false;
  }

  clickMember(GroupMembersInfo membersInfo) {
    if (opType == GroupMemberOpType.transferRight) {
      _transferGroupRight(membersInfo);
    } else if (opType == GroupMemberOpType.at ||
        opType == GroupMemberOpType.call ||
        opType == GroupMemberOpType.del) {
      Get.back(result: membersInfo);
    } else {
      viewMemberInfo(membersInfo);
    }
  }

  static _transferGroupRight(GroupMembersInfo membersInfo) async {
    var confirm = await CustomDialog.show(
      title: sprintf(StrRes.confirmTransferGroupToUser, [membersInfo.nickname]),
    );
    if (confirm == true) {
      Get.back(result: membersInfo);
    }
  }

  viewMemberInfo(GroupMembersInfo membersInfo) {
    final isSelf = membersInfo.userID == OpenIM.iMManager.userID;
    final isFriend = imLogic.friendIDMap.containsKey(membersInfo.userID);
    if (!isSelf &&
        groupInfo.lookMemberInfo == 1 &&
        !isOwnerOrAdmin &&
        !isFriend) {
      return;
    }
    AppNavigator.startUserProfilePane(
      userID: membersInfo.userID!,
      groupID: membersInfo.groupID,
      nickname: membersInfo.nickname,
      faceURL: membersInfo.faceURL,
    );
  }
}
