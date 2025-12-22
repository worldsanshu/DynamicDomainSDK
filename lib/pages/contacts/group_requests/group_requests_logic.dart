import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';

import '../../../core/controller/im_controller.dart';
import '../../home/home_logic.dart';

class GroupRequestsLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final homeLogic = Get.find<HomeLogic>();
  final list = <GroupApplicationInfo>[].obs;
  final groupList = <String, GroupInfo>{}.obs;
  final memberList = <GroupMembersInfo>[].obs;
  final userInfoList = <UserInfo>[].obs;
  final selectedTab = 'requests'.obs;

  late StreamSubscription _sub;

  @override
  void onReady() {
    getApplicationList();
    getJoinedGroup();
    super.onReady();
  }

  @override
  void onInit() {
    _sub = imLogic.groupApplicationChangedSubject.listen((info) {
      getApplicationList();
    });
    super.onInit();
  }

  @override
  void onClose() {
    homeLogic.getUnhandledGroupApplicationCount();
    _sub.cancel();
    super.onClose();
  }

  bool isInvite(GroupApplicationInfo info) {
    if (info.joinSource == 2) {
      return info.inviterUserID != null && info.inviterUserID!.isNotEmpty;
    }
    return false;
  }

  getApplicationList() async {
    final list = await LoadingView.singleton.wrap(asyncFunction: () async {
      final list = await Future.wait([
        OpenIM.iMManager.groupManager.getGroupApplicationListAsRecipient(),
        OpenIM.iMManager.groupManager.getGroupApplicationListAsApplicant(),
      ]);

      final allList = <GroupApplicationInfo>[];
      allList
        ..addAll(list[0])
        ..addAll(list[1]);

      allList.sort((a, b) {
        if (a.reqTime! > b.reqTime!) {
          return -1;
        } else if (a.reqTime! < b.reqTime!) {
          return 1;
        }
        return 0;
      });

      // Debug log to check SDK data
      for (var item in allList) {
        Logger.print(
          '[GroupRequests] groupID=${item.groupID}, userID=${item.userID}, '
          'reqTime=${item.reqTime}, handleResult=${item.handleResult}, '
          'nickname=${item.nickname}',
        );
      }

      var map = <String, List<String>>{};
      var inviterList = <String>[];
      // 统计未查看的群申请数量
      var haveReadList = DataSp.getHaveReadUnHandleGroupApplication();
      haveReadList ??= <String>[];
      for (var a in list[0]) {
        var id = IMUtils.buildGroupApplicationID(a);
        if (!haveReadList.contains(id)) {
          haveReadList.add(id);
        }
      }
      DataSp.putHaveReadUnHandleGroupApplication(haveReadList);

      // Update badge count immediately after marking as read
      homeLogic.getUnhandledGroupApplicationCount();

      // ignore: unused_local_variable
      var groupIDList = <String>[];
      // 记录邀请者id
      for (var a in allList) {
        if (isInvite(a)) {
          if (!map.containsKey(a.groupID)) {
            map[a.groupID!] = [a.inviterUserID!];
          } else {
            if (!map[a.groupID!]!.contains(a.inviterUserID!)) {
              map[a.groupID!]!.add(a.inviterUserID!);
            }
          }
          if (!inviterList.contains(a.inviterUserID!)) {
            inviterList.add(a.inviterUserID!);
          }
        }
      }

      // 查询邀请者的群成员信息
      if (map.isNotEmpty) {
        await Future.wait(map.entries.map((e) => OpenIM.iMManager.groupManager
            .getGroupMembersInfo(groupID: e.key, userIDList: e.value)
            .then((list) => memberList.assignAll(list))));
        // await Future.forEach<MapEntry>(map.entries, (element) {
        //   OpenIM.iMManager.groupManager
        //       .getGroupMembersInfo(groupId: element.key, uidList: element.value)
        //       .then((list) => memberList.assignAll(list));
        // });
      }

      // 查询邀请者的用户信息
      if (inviterList.isNotEmpty) {
        await OpenIM.iMManager.userManager
            .getUsersInfo(userIDList: inviterList)
            .then((list) => userInfoList
                .assignAll(list.map((e) => e.simpleUserInfo).toList()));
      }

      return allList;
    });

    // Merge pending updates from local storage
    final pendingUpdates = DataSp.getGroupApplicationPendingUpdates();
    if (pendingUpdates.isNotEmpty) {
      for (var item in list) {
        // Key includes reqTime to distinguish between different requests from same user
        final key = '${item.groupID}_${item.userID}_${item.reqTime}';
        // Apply pending update only if SDK still shows as unhandled (handleResult == 0)
        // This means server hasn't synced yet, so use our local state
        if (pendingUpdates.containsKey(key) && item.handleResult == 0) {
          item.handleResult = pendingUpdates[key]!;
        } else if (pendingUpdates.containsKey(key) && item.handleResult != 0) {
          // Server has synced, remove from pending updates
          DataSp.removeGroupApplicationPendingUpdate(
              item.groupID!, item.userID!, item.reqTime);
        }
      }
    }

    // Update UI
    this.list.assignAll(list);
  }

  void getJoinedGroup() {
    OpenIM.iMManager.groupManager.getJoinedGroupList().then((list) {
      var map = <String, GroupInfo>{};
      for (var e in list) {
        map[e.groupID] = e;
      }
      groupList.addAll(map);
    });
  }

  String getGroupName(GroupApplicationInfo info) =>
      info.groupName ?? groupList[info.groupID]?.groupName ?? '';

  String getInviterNickname(GroupApplicationInfo info) =>
      (getMemberInfo(info.inviterUserID!)?.nickname) ??
      (getUserInfo(info.inviterUserID!)?.nickname) ??
      '-';

  GroupMembersInfo? getMemberInfo(inviterUserID) =>
      memberList.firstWhereOrNull((e) => e.userID == inviterUserID);

  UserInfo? getUserInfo(inviterUserID) =>
      userInfoList.firstWhereOrNull((e) => e.userID == inviterUserID);

  void handle(GroupApplicationInfo info) async {
    var result =
        await AppNavigator.startProcessGroupRequests(applicationInfo: info);
    if (result is int) {
      info.handleResult = result;
      list.refresh();
    }
  }

  /// Update application status and save to pending updates
  /// (called from ProcessGroupRequestsLogic)
  Future<void> updateApplicationStatus({
    required String groupID,
    required String userID,
    required int handleResult,
    int? reqTime,
  }) async {
    // Update local list immediately for instant UI feedback
    final index = list.indexWhere(
      (item) => item.groupID == groupID && item.userID == userID,
    );

    if (index != -1) {
      list[index].handleResult = handleResult;
      list.refresh();
    }

    // Save to pending updates in local storage (with reqTime for uniqueness)
    await DataSp.putGroupApplicationPendingUpdate(
      groupID,
      userID,
      handleResult,
      reqTime,
    );
  }

  /// Approve a group join request inline
  Future<void> approveApplication(GroupApplicationInfo info) async {
    try {
      await LoadingView.singleton.wrap(
        asyncFunction: () =>
            OpenIM.iMManager.groupManager.acceptGroupApplication(
          groupID: info.groupID!,
          userID: info.userID!,
          handleMsg: '',
        ),
      );

      // Update local status immediately for instant UI feedback
      await updateApplicationStatus(
        groupID: info.groupID!,
        userID: info.userID!,
        handleResult: 1,
        reqTime: info.reqTime,
      );
      IMViews.showToast(StrRes.approved, type: 1);
    } catch (e) {
      Logger.print('Error approving application: $e');
      if (e is PlatformException &&
          e.code == '${SDKErrorCode.groupApplicationHasBeenProcessed}') {
        IMViews.showToast(StrRes.groupRequestHandled);
      } else {
        IMViews.showToast(StrRes.sendFailed);
      }
    }
  }

  /// Reject a group join request inline
  Future<void> rejectApplication(GroupApplicationInfo info) async {
    try {
      await LoadingView.singleton.wrap(
        asyncFunction: () =>
            OpenIM.iMManager.groupManager.refuseGroupApplication(
          groupID: info.groupID!,
          userID: info.userID!,
          handleMsg: '',
        ),
      );

      // Update local status immediately for instant UI feedback
      await updateApplicationStatus(
        groupID: info.groupID!,
        userID: info.userID!,
        handleResult: -1,
        reqTime: info.reqTime,
      );

      IMViews.showToast(StrRes.rejectSuccessfully, type: 1);
    } catch (e) {
      Logger.print('Error rejecting application: $e');
      if (e is PlatformException &&
          e.code == '${SDKErrorCode.groupApplicationHasBeenProcessed}') {
        IMViews.showToast(StrRes.groupRequestHandled);
      } else {
        IMViews.showToast(StrRes.rejectFailed);
      }
    }
  }
}
