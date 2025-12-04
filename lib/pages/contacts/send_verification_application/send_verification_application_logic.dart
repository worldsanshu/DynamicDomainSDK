import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../group_profile_panel/group_profile_panel_logic.dart';
import '../user_profile_panel/user_profile _panel_logic.dart';

class SendVerificationApplicationLogic extends GetxController {
  final inputCtrl = TextEditingController();
  String? userID;
  String? groupID;
  JoinGroupMethod? joinGroupMethod;

  bool get isEnterGroup => groupID != null;

  bool get isAddFriend => userID != null;

  late Rx<UserFullInfo> userInfo;

  @override
  void onReady() {
    _getUsersInfo();
  }

  @override
  void onInit() {
    userInfo = (UserFullInfo()
          ..userID = Get.arguments['userID']
          ..nickname = Get.arguments['nickname']
          ..faceURL = Get.arguments['faceURL'])
        .obs;

    userID = Get.arguments['userID'];
    groupID = Get.arguments['groupID'];
    joinGroupMethod = Get.arguments['joinGroupMethod'];
    super.onInit();
  }

  void _getUsersInfo() async {
    final userID = userInfo.value.userID!;
    final existUser = UserCacheManager().getUserInfo(userID);
    if (existUser != null) {
      userInfo.update((val) {
        val?.nickname = existUser.nickname;
        val?.faceURL = existUser.faceURL;
        val?.status = existUser.status;
        val?.level = existUser.level;
        val?.phoneNumber = existUser.phoneNumber;
        val?.areaCode = existUser.areaCode;
        val?.birth = existUser.birth;
        val?.email = existUser.email;
        val?.gender = existUser.gender;
        val?.mobile = existUser.mobile;
      });
    }

    // ignore: deprecated_member_use
    final list = await OpenIM.iMManager.userManager.getUsersInfoWithCache(
      [userID],
    );
    final friendInfo = (await OpenIM.iMManager.friendshipManager.getFriendsInfo(
      userIDList: [userID],
      filterBlack: true,
    ))
        .firstOrNull;

    final blackList = await OpenIM.iMManager.friendshipManager.getBlacklist();

    final user = list.firstOrNull;
    final isFriendship = friendInfo != null;
    final isBlack =
        blackList.firstWhereOrNull((e) => e.userID == friendInfo?.userID) !=
            null;

    if (user != null) {
      userInfo.update((val) {
        val?.nickname = user.nickname;
        val?.faceURL = user.faceURL;
        val?.remark = friendInfo?.remark;
        val?.isBlacklist = isBlack;
        val?.isFriendship = isFriendship;
      });
    }

    final list2 = await ChatApis.getUserFullInfo(userIDList: [userID]);
    final fullInfo = list2?.firstOrNull;

    if (null != fullInfo) {
      UserCacheManager().addOrUpdateUserInfo(userID, fullInfo);

      userInfo.update((val) {
        val?.allowAddFriend = fullInfo.allowAddFriend;
        val?.status = fullInfo.status;
        val?.level = fullInfo.level;
        val?.phoneNumber = fullInfo.phoneNumber;
        val?.areaCode = fullInfo.areaCode;
        val?.birth = fullInfo.birth;
        val?.email = fullInfo.email;
        val?.gender = fullInfo.gender;
        val?.mobile = fullInfo.mobile;
      });

      // if (fullInfo.faceURL != null) {
      //   _resetAvatar(fullInfo.faceURL!);
      // }
    }
  }

  void send() async {
    if (isAddFriend) {
      // Validate before sending friend request
      if (!_validateAddFriendRequest()) {
        return;
      }
      _applyAddFriend();
    } else if (isEnterGroup) {
      _applyEnterGroup();
    }
  }

  /// Validate friend request conditions and show appropriate toast messages
  bool _validateAddFriendRequest() {
    // Check if trying to add yourself
    final isMyself = userInfo.value.userID == OpenIM.iMManager.userID;
    if (isMyself) {
      IMViews.showToast(StrRes.cannotAddYourself);
      return false;
    }

    // Check if already friends
    final isFriendship = userInfo.value.isFriendship == true;
    if (isFriendship) {
      IMViews.showToast(StrRes.alreadyFriends);
      return false;
    }

    // Check if user allows adding friends
    final isAllowAddFriend = userInfo.value.allowAddFriend == 1;
    if (!isAllowAddFriend) {
      IMViews.showToast(StrRes.canNotAddFriends);
      return false;
    }

    // Check group member restrictions
    // If this request comes from group member page, check group settings
    if (groupID != null && groupID!.isNotEmpty) {
      final notAllowAddGroupMemberFriend = _checkGroupMemberFriendRestriction();
      if (notAllowAddGroupMemberFriend) {
        IMViews.showToast(StrRes.notAllAddMemberToBeFriend);
        return false;
      }
    }

    return true;
  }

  /// Check if group settings allow adding members as friends
  bool _checkGroupMemberFriendRestriction() {
    try {
      // Try to get GroupProfilePanelLogic if it exists
      if (Get.isRegistered<GroupProfilePanelLogic>()) {
        final groupLogic = Get.find<GroupProfilePanelLogic>();
        final groupInfo = groupLogic.groupInfo.value;
        // applyMemberFriend == 1 means NOT allow to add member as friend
        return groupInfo.applyMemberFriend == 1;
      }
    } catch (e) {
      // If can't get group logic, allow by default
    }
    return false;
  }

  _applyAddFriend() async {
    try {
      await LoadingView.singleton.wrap(
        asyncFunction: () => OpenIM.iMManager.friendshipManager.addFriend(
          userID: userID!,
          reason: inputCtrl.text.trim(),
        ),
      );
      Get.back();
      IMViews.showToast(StrRes.sendSuccessfully);
    } catch (_) {
      if (_ is PlatformException) {
        if (_.code == '${SDKErrorCode.refuseToAddFriends}') {
          IMViews.showToast(StrRes.canNotAddFriends);
          return;
        }
      }
      IMViews.showToast(StrRes.sendFailed);
    }
  }

  /// By Invitation = 2 , Search = 3 , QRCode  = 4
  _applyEnterGroup() {
    LoadingView.singleton
        .wrap(
          asyncFunction: () => OpenIM.iMManager.groupManager.joinGroup(
            groupID: groupID!,
            reason: inputCtrl.text.trim(),
            joinSource: joinGroupMethod == JoinGroupMethod.qrcode ? 4 : 3,
          ),
        )
        .then((value) => IMViews.showToast(StrRes.sendSuccessfully))
        .then((value) => Get.back())
        .catchError((e) => IMViews.showToast(StrRes.sendFailed));
  }
}
