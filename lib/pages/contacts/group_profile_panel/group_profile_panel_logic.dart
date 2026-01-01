import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';

import '../../../core/controller/client_config_controller.dart';
import '../../../core/controller/im_controller.dart';
import '../../../routes/app_navigator.dart';
import '../../conversation/conversation_logic.dart';

enum JoinGroupMethod { search, qrcode, invite }

class GroupProfilePanelLogic extends GetxController {
  final conversationLogic = Get.find<ConversationLogic>();
  final imLogic = Get.find<IMController>();
  final clientConfigLogic = Get.find<ClientConfigController>();
  final isJoined = false.obs;
  final hasPendingRequest = false.obs;
  final members = <GroupMembersInfo>[].obs;
  late Rx<GroupInfo> groupInfo;
  late JoinGroupMethod joinGroupMethod;

  late StreamSubscription sub;
  late StreamSubscription joinedGroupAddedSub;
  late StreamSubscription memberAddedSub;

  @override
  void onInit() {
    print('groupInfo iddd: ${Get.arguments['groupID']}');
    groupInfo = Rx(GroupInfo(groupID: Get.arguments['groupID']));
    joinGroupMethod = Get.arguments['joinGroupMethod'];
    sub = imLogic.groupApplicationChangedSubject.listen(_onChanged);
    joinedGroupAddedSub = imLogic.joinedGroupAddedSubject.listen(_onChanged);
    memberAddedSub = imLogic.memberAddedSubject.listen(_onChanged);
    _checkGroup();
    _checkPendingRequest();
    _getGroupInfo();
    _getMembers();
    super.onInit();
  }

  _onChanged(dynamic value) {
    if (value is GroupApplicationInfo) {
      if (value.groupID == groupInfo.value.groupID) {
        // Update pending request status based on handleResult
        if (value.handleResult == 0) {
          // Request is pending
          hasPendingRequest.value = true;
        } else if (value.handleResult == 1) {
          // Request approved - user joined
          hasPendingRequest.value = false;
          if (!isJoined.value) {
            isJoined.value = true;
            _getGroupInfo();
            _getMembers();
          }
        } else if (value.handleResult == -1) {
          // Request rejected
          hasPendingRequest.value = false;
        }
      }
    } else if (value is GroupInfo) {
      if (value.groupID == groupInfo.value.groupID) {
        if (!isJoined.value) {
          isJoined.value = true;
          _getGroupInfo();
          _getMembers();
        }
      }
    } else if (value is GroupMembersInfo) {
      if (value.groupID == groupInfo.value.groupID &&
          value.userID == OpenIM.iMManager.userID) {
        if (!isJoined.value) {
          isJoined.value = true;
          _getGroupInfo();
          _getMembers();
        }
      }
    }
  }

  _getGroupInfo() async {
    var list = await OpenIM.iMManager.groupManager.getGroupsInfo(
      groupIDList: [groupInfo.value.groupID],
    );
    var info = list.firstOrNull;
    print('getGroupInfo: ${info?.toJson()}');
    if (null != info) {
      groupInfo.update((val) {
        val?.groupName = info.groupName;
        val?.faceURL = info.faceURL;
        val?.memberCount = info.memberCount;
        val?.groupType = info.groupType;
        val?.createTime = info.createTime;
      });
    }
  }

  _checkGroup() async {
    isJoined.value = await OpenIM.iMManager.groupManager.isJoinedGroup(
      groupID: groupInfo.value.groupID,
    );
  }

  _checkPendingRequest() async {
    try {
      final applications = await OpenIM.iMManager.groupManager
          .getGroupApplicationListAsApplicant();
      final hasPending = applications.any((app) =>
          app.groupID == groupInfo.value.groupID && app.handleResult == 0);
      hasPendingRequest.value = hasPending;
    } catch (e) {
      print('Error checking pending request: $e');
      hasPendingRequest.value = false;
    }
  }

  _getMembers() async {
    var list = await OpenIM.iMManager.groupManager.getGroupMemberList(
      groupID: groupInfo.value.groupID,
      count: 10,
    );
    members.assignAll(list);
  }

  enterGroup() async {
    if (isJoined.value) {
      conversationLogic.toChat(
        groupID: groupInfo.value.groupID,
        nickname: groupInfo.value.groupName,
        faceURL: groupInfo.value.faceURL,
        sessionType: groupInfo.value.sessionType,
      );
    } else {
      AppNavigator.startSendVerificationApplication(
        groupID: groupInfo.value.groupID,
        joinGroupMethod: joinGroupMethod,
      );
    }
  }

  bool get showMemberCount => clientConfigLogic.shouldShowMemberCount(
      ownerUserID: groupInfo.value.ownerUserID);

  @override
  void onClose() {
    sub.cancel();
    joinedGroupAddedSub.cancel();
    memberAddedSub.cancel();
    super.onClose();
  }
}
