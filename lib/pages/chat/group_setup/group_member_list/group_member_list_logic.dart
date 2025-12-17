import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

import '../../../../core/controller/im_controller.dart';
import '../group_setup_logic.dart';

enum GroupMemberOpType {
  view,
  transferRight,
  call,
  at,
  del,
}

class GroupMemberListLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final groupSetupLogic = Get.find<GroupSetupLogic>();
  final controller = RefreshController();
  final memberList = <GroupMembersInfo>[].obs;
  final searchResults = <GroupMembersInfo>[].obs;
  final checkedList = <GroupMembersInfo>[].obs;
  final poController = CustomPopupMenuController();
  final searchCtrl = TextEditingController();
  final focusNode = FocusNode();
  final scrollController = ScrollController();
  int count = 500;
  final myGroupMemberLevel = 1.obs;
  final isSearching = false.obs;
  late GroupInfo groupInfo;
  late GroupMemberOpType opType;
  late StreamSubscription mISub;
  late bool isShowEveryone;
  List<String> defaultCheckedUserIDs = [];
  int? maxSelectCount;

  int _actualLoadedCount = 0;

  /// 多选模式
  bool get isMultiSelMode =>
      opType == GroupMemberOpType.call ||
      opType == GroupMemberOpType.at ||
      opType == GroupMemberOpType.del;

  /// 需要移除自己
  bool get excludeSelfFromList =>
      opType == GroupMemberOpType.call ||
      opType == GroupMemberOpType.at ||
      opType == GroupMemberOpType.transferRight;

  bool get isDelMember => opType == GroupMemberOpType.del;

  bool get isAdmin => myGroupMemberLevel.value == GroupRoleLevel.admin;

  bool get isOwner => myGroupMemberLevel.value == GroupRoleLevel.owner;

  bool get isOwnerOrAdmin => isAdmin || isOwner;

  // int get maxLength => maxSelectCount ?? min(groupInfo.memberCount!, 10);
  int get maxLength => min(groupInfo.memberCount!, 10);

  /// Number of selected members excluding the special @everyone tag.
  int get checkedCountExcludingEveryone {
    final atAll = OpenIM.iMManager.conversationManager.atAllTag;
    if (atAll == null || atAll.isEmpty) return checkedList.length;
    return checkedList.where((e) => e.userID != atAll).length;
  }

  @override
  void onClose() {
    mISub.cancel();
    searchCtrl.dispose();
    focusNode.dispose();
    scrollController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    groupInfo = Get.arguments['groupInfo'];
    isShowEveryone = Get.arguments['isShowEveryone'];
    opType = Get.arguments['opType'];
    defaultCheckedUserIDs = Get.arguments['defaultCheckedUserIDs'] ?? [];
    maxSelectCount = Get.arguments['maxSelectCount'];
    mISub = imLogic.memberInfoChangedSubject.listen(_updateMemberLevel);
    super.onInit();
  }

  @override
  void onReady() {
    _queryMyGroupMemberLevel();

    // If there are default checked user IDs (passed from caller),
    // load their GroupMembersInfo and initialize the checked list so
    // they are displayed in the selected area when opening the page.
    if (defaultCheckedUserIDs.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          final list = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
            groupID: groupInfo.groupID,
            userIDList: defaultCheckedUserIDs,
          );
          // Add to checkedList if not already present
          for (var member in list) {
            if (!checkedList.contains(member)) checkedList.add(member);
          }
        } catch (e) {
          Logger.print('Error loading default checked members: $e');
        }
      });
    }

    super.onReady();
  }

  void _updateMemberLevel(GroupMembersInfo e) {
    if (e.groupID == groupInfo.groupID) {
      equal(GroupMembersInfo el) => el.userID == e.userID;
      final member = memberList.firstWhereOrNull(equal);
      if (null != member && e.roleLevel != member.roleLevel) {
        member.roleLevel = e.roleLevel;
        // memberList.refresh();
      }
      memberList.sort((a, b) {
        if (b.roleLevel != a.roleLevel) {
          return b.roleLevel!.compareTo(a.roleLevel!);
        } else {
          return b.joinTime!.compareTo(a.joinTime!);
        }
      });
    }
  }

  void _queryMyGroupMemberLevel() async {
    LoadingView.singleton.wrap(asyncFunction: () async {
      final list = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
        groupID: groupInfo.groupID,
        userIDList: [OpenIM.iMManager.userID],
      );
      final myInfo = list.firstOrNull;
      if (null != myInfo) {
        myGroupMemberLevel.value = myInfo.roleLevel ?? 1;
      }
      await onLoad();
    });
  }

  Future<List<GroupMembersInfo>> _getGroupMembers() {
    final result = OpenIM.iMManager.groupManager.getGroupMemberList(
      groupID: groupInfo.groupID,
      count: count,
      offset: _actualLoadedCount,
      filter: isDelMember ? (isOwner ? 4 : (isAdmin ? 3 : 0)) : 0,
    );

    count = 100;

    return result;
  }

  onLoad() async {
    final list = await _getGroupMembers();

    _actualLoadedCount += list.length;

    // Always show all members in the list. If some members were passed
    // in `defaultCheckedUserIDs`, keep them visible and mark them as
    // checked by adding to `checkedList`.
    memberList.addAll(list);

    if (defaultCheckedUserIDs.isNotEmpty) {
      for (var member in list) {
        if (defaultCheckedUserIDs.contains(member.userID) &&
            !checkedList.any((e) => e.userID == member.userID)) {
          checkedList.add(member);
        }
      }
    }

    if (list.length < count) {
      controller.loadNoData();
    } else {
      controller.loadComplete();
    }
  }

  bool isChecked(GroupMembersInfo membersInfo) =>
      checkedList.contains(membersInfo);

  clickMember(GroupMembersInfo membersInfo) async {
    if (opType == GroupMemberOpType.transferRight) {
      _transferGroupRight(membersInfo);
      return;
    }
    if (isMultiSelMode) {
      // Lưu vị trí scroll trước khi thay đổi checkedList
      final scrollOffset =
          scrollController.hasClients ? scrollController.offset : 0.0;

      if (isChecked(membersInfo)) {
        checkedList.remove(membersInfo);
        // Update checkbox and selected count
        update(['checkbox_${membersInfo.userID}', 'selected_count']);
      } else {
        // If "everyone" is currently selected, remove it when selecting any member
        final everyoneId = OpenIM.iMManager.conversationManager.atAllTag;
        final everyoneIndex =
            checkedList.indexWhere((e) => e.userID == everyoneId);
        if (everyoneIndex > -1) {
          final everyoneMember = checkedList[everyoneIndex];
          checkedList.removeAt(everyoneIndex);
          // Update everyone checkbox and selected count
          update(['checkbox_${everyoneMember.userID}', 'selected_count']);
        }

        if (checkedList.length < maxLength) {
          checkedList.add(membersInfo);
          // Update checkbox and selected count
          update(['checkbox_${membersInfo.userID}', 'selected_count']);
        } else {
          IMViews.showToast(StrRes.maxAtUserHint);
        }
      }

      // Khôi phục vị trí scroll sau khi rebuild
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollOffset);
        }
      });
    } else {
      viewMemberInfo(membersInfo);
    }
  }

  static _transferGroupRight(GroupMembersInfo membersInfo) async {
    var confirm = await Get.dialog(
        barrierColor: Colors.transparent,
        CustomDialog(
          title: sprintf(
              StrRes.confirmTransferGroupToUser, [membersInfo.nickname]),
        ));
    if (confirm == true) {
      Get.back(result: membersInfo);
    }
  }

  void removeSelectedMember(GroupMembersInfo membersInfo) {
    checkedList.remove(membersInfo);
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

  void addMember() async {
    poController.hideMenu();
    await groupSetupLogic.addMember();
    refreshData();
  }

  void refreshData() {
    LoadingView.singleton.wrap(asyncFunction: () async {
      memberList.clear();
      _actualLoadedCount = 0; // Reset offset counter to load from beginning
      await onLoad();
    });
  }

  void delMember() async {
    poController.hideMenu();
    await groupSetupLogic.removeMember();
    refreshData();
  }

  void search() async {
    final key = searchCtrl.text.trim();
    if (key.isNotEmpty) {
      final list = await LoadingView.singleton.wrap(
        asyncFunction: () => OpenIM.iMManager.groupManager.searchGroupMembers(
          groupID: groupInfo.groupID,
          isSearchMemberNickname: true,
          isSearchUserID: true,
          keywordList: [key],
          offset: 0,
          count: 100,
        ),
      );
      searchResults.assignAll(list);
      isSearching.value = true;
    }
  }

  void clearSearch() {
    searchCtrl.clear();
    searchResults.clear();
    isSearching.value = false;
  }

  bool get isSearchNotResult =>
      searchCtrl.text.trim().isNotEmpty && searchResults.isEmpty;

  List<GroupMembersInfo> get displayList =>
      isSearching.value ? searchResults : memberList;

  // ignore: unused_element
  void _oldSearch() async {
    final memberInfo = await AppNavigator.startSearchGroupMember(
        groupInfo: groupInfo, opType: opType, isOwnerOrAdmin: isOwnerOrAdmin);
    if (opType == GroupMemberOpType.transferRight) {
      Get.back(result: memberInfo);
    } else if (isMultiSelMode) {
      clickMember(memberInfo);
    }
  }

  static _buildEveryoneMemberInfo() => GroupMembersInfo(
        userID: OpenIM.iMManager.conversationManager.atAllTag,
        nickname: StrRes.everyone,
      );

  /// Select @everyone tag. If other users are already selected,
  /// show a toast and do not add the everyone tag.
  Future<void> selectEveryone() async {
    final everyoneId = OpenIM.iMManager.conversationManager.atAllTag;
    if (checkedList.isNotEmpty) {
      // Ask user whether to remove already-selected users to select everyone
      final result = await Get.dialog(
        barrierColor: Colors.transparent,
        CustomDialog(
          title: StrRes.cannotSelectEveryoneWithOthersContent,
          content: StrRes.doYouWantToRemoveOtherMembers,
          onTapRight: () => Get.back(result: true),
        ),
      );

      if (result == true) {
        checkedList.clear();
        update([
          'selected_count',
          'confirm_button'
        ]); // Update both count and button
        print('checkedList cleared: ${checkedList.length} items');
        final info = _buildEveryoneMemberInfo();
        if (!checkedList.any((e) => e.userID == everyoneId)) {
          checkedList.add(info);
          update([
            'selected_count',
            'confirm_button'
          ]); // Update both count and button
          print(
              'checkedList updated with @everyone: ${checkedList.length} items');
        }
      }

      return;
    }
    if (defaultCheckedUserIDs.isNotEmpty) {
      IMViews.showToast(StrRes.cannotSelectEveryoneWithOthers);
      return;
    }

    final info = _buildEveryoneMemberInfo();
    if (!checkedList.any((e) => e.userID == everyoneId)) {
      checkedList.add(info);
      update(
          ['selected_count', 'confirm_button']); // Update both count and button
      print('checkedList updated with @everyone: ${checkedList.length} items');
    }
  }

  void confirmSelectedMember() {
    // Return a snapshot of the selected members to avoid timing/race issues
    print(
        'confirmSelectedMember called with checkedList: ${checkedList.map((e) => e.userID).toList()}');
    Get.back(result: checkedList.toList());
  }

  bool hiddenMember(GroupMembersInfo membersInfo) =>
      excludeSelfFromList && membersInfo.userID == OpenIM.iMManager.userID;
}
