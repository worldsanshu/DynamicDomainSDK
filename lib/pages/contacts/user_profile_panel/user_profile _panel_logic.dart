// ignore_for_file: unused_element, deprecated_member_use

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:common_utils/common_utils.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/core/controller/client_config_controller.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import '../../../core/controller/im_controller.dart';
import '../../conversation/conversation_logic.dart';
import '../../../core/controller/trtc_controller.dart';
import '../select_contacts/select_contacts_logic.dart';

class UserProfilePanelLogic extends GetxController {
  final clientConfigLogic = Get.find<ClientConfigController>();
  final imLogic = Get.find<IMController>();
  final conversationLogic = Get.find<ConversationLogic>();
  final trtcLogic = Get.find<TRTCController>();
  late Rx<UserFullInfo> userInfo;
  GroupMembersInfo? groupMembersInfo;
  GroupInfo? groupInfo;
  String? groupID;
  bool? offAllWhenDelFriend = false;
  final iHasMutePermissions = false.obs;
  final iAmOwner = false.obs;
  final mutedTime = "".obs;
  final onlineStatus = false.obs;
  final onlineStatusDesc = ''.obs;
  final RxInt groupMemberRoleLevel = GroupRoleLevel.member.obs;
  final groupUserNickname = "".obs;
  final joinGroupTime = 0.obs;
  final joinGroupMethod = ''.obs;
  final hasAdminPermission = false.obs;
  final notAllowLookGroupMemberProfiles = true.obs;
  final notAllowAddGroupMemberFriend = false.obs;
  final iHaveAdminOrOwnerPermission = false.obs;
  late StreamSubscription _friendAddedSub;
  late StreamSubscription _friendInfoChangedSub;
  late StreamSubscription _friendDeletedSub;
  late StreamSubscription _blacklistAddedSub;
  late StreamSubscription _blacklistDeletedSub;
  late StreamSubscription _memberInfoChangedSub;

  @override
  void onClose() {
    _friendAddedSub.cancel();
    _friendInfoChangedSub.cancel();
    _friendDeletedSub.cancel();
    _blacklistAddedSub.cancel();
    _blacklistDeletedSub.cancel();
    _memberInfoChangedSub.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    userInfo = (UserFullInfo()
          ..userID = Get.arguments['userID']
          ..nickname = Get.arguments['nickname']
          ..faceURL = Get.arguments['faceURL'])
        .obs;
    groupID = Get.arguments['groupID'];
    offAllWhenDelFriend = Get.arguments['offAllWhenDelFriend'];

    _friendAddedSub = imLogic.friendAddSubject.listen((user) {
      if (user.userID == userInfo.value.userID) {
        userInfo.update((val) {
          val?.isFriendship = true;
        });
      }
    });
    _friendInfoChangedSub = imLogic.friendInfoChangedSubject.listen((user) {
      if (user.userID == userInfo.value.userID) {
        userInfo.update((val) {
          val?.nickname = user.nickname;
          val?.remark = user.remark;
        });
      }
    });
    _friendDeletedSub = imLogic.friendDelSubject.listen((user) {
      if (user.userID == userInfo.value.userID) {
        userInfo.update((val) {
          val?.isFriendship = false;
        });
      }
    });
    _blacklistAddedSub = imLogic.blacklistAddedSubject.listen((user) {
      if (user.userID == userInfo.value.userID) {
        userInfo.update((val) {
          val?.isBlacklist = true;
          val?.isFriendship =
              false; // When added to blacklist, unfriend automatically
        });
      }
    });
    _blacklistDeletedSub = imLogic.blacklistDeletedSubject.listen((user) {
      if (user.userID == userInfo.value.userID) {
        userInfo.update((val) {
          val?.isBlacklist = false;
        });
      }
    });
    // 禁言时间被改变，或群成员资料改变
    _memberInfoChangedSub = imLogic.memberInfoChangedSubject.listen((value) {
      if (value.userID == userInfo.value.userID) {
        if (null != value.muteEndTime) {
          _calMuteTime(value.muteEndTime!);
        }
        groupUserNickname.value = value.nickname ?? '';
      }
    });
    super.onInit();
  }

  @override
  void onReady() {
    _getUsersInfo();
    _queryGroupInfo();
    _queryGroupMemberInfo();
    // _queryUserOnlineStatus();
    super.onReady();
  }

  /// 是当前登录用户的资料页
  bool get isMyself => userInfo.value.userID == OpenIM.iMManager.userID;

  /// 当前是群成员资料页面
  bool get isGroupMemberPage => null != groupID && groupID!.isNotEmpty;

  bool get isFriendship => userInfo.value.isFriendship == true;

  bool get isBlacklisted => userInfo.value.isBlacklist == true;

  ///用户是否允许添加好友
  bool get isAllowAddFriend => userInfo.value.allowAddFriend == 1;

  /// （Cloud Fei）是否能给非好友发送消息
  bool get allowSendMsgNotFriend => clientConfigLogic.allowSendMsgNotFriend;

  /// Cloud Fei）是否显示音视频通话
  bool get showAudioAndVideoCall => clientConfigLogic.showAudioAndVideoCall;

  bool get isBlacklist => userInfo.value.isBlacklist;

  get showJoinGroupTime {
    return joinGroupTime.value > 0 &&
        clientConfigLogic.shouldShowJoinGroupTime(groupMemberRoleLevel.value);
  }

  get showJoinGroupMethod {
    return joinGroupMethod.value.isNotEmpty &&
        clientConfigLogic.shouldShowJoinGroupMethod(groupMemberRoleLevel.value);
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
        val?.isFriendship = existUser.isFriendship;
        val?.isBlacklist = existUser.isBlacklist;
      });
    }

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
        blackList.firstWhereOrNull((e) => e.userID == userID) != null;

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
    fullInfo?.isBlacklist = isBlack;
    fullInfo?.isFriendship = isFriendship;

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
        val?.isFriendship = isFriendship;
        val?.isBlacklist = isBlack;
      });

      // if (fullInfo.faceURL != null) {
      //   _resetAvatar(fullInfo.faceURL!);
      // }
    }
  }

  void _resetAvatar(String url) async {
    clearMemoryImageCache(keyToMd5(url));
    await clearDiskCachedImage(url);
    PaintingBinding.instance.imageCache.evict(keyToMd5(url));
    userInfo.refresh();
  }

  _queryGroupInfo() async {
    if (isGroupMemberPage) {
      var list = await OpenIM.iMManager.groupManager.getGroupsInfo(
        groupIDList: [groupID!],
      );
      groupInfo = list.firstOrNull;
      // 不允许查看群成员资料
      notAllowLookGroupMemberProfiles.value = groupInfo?.lookMemberInfo == 1;
      // 不允许添加组成员为好友
      notAllowAddGroupMemberFriend.value = groupInfo?.applyMemberFriend == 1;
    }
  }

  /// 查询我与当前页面用户的群成员信息
  _queryGroupMemberInfo() async {
    if (isGroupMemberPage) {
      final list = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
        groupID: groupID!,
        userIDList: [
          userInfo.value.userID!,
          if (!isMyself) OpenIM.iMManager.userID
        ],
      );
      final other =
          list.firstWhereOrNull((e) => e.userID == userInfo.value.userID);
      groupMembersInfo = other;
      groupUserNickname.value = other?.nickname ?? '';
      joinGroupTime.value = other?.joinTime ?? 0;

      _getJoinGroupMethod(other);

      hasAdminPermission.value = other?.roleLevel == GroupRoleLevel.admin;

      // 是我查看其他人的资料
      if (!isMyself) {
        var me =
            list.firstWhereOrNull((e) => e.userID == OpenIM.iMManager.userID);
        // 只有群主可以设置管理员
        iAmOwner.value = me?.roleLevel == GroupRoleLevel.owner;
        // 群主禁言（取消禁言）管理员和普通成员，管理员只能禁言（取消禁言）普通成员
        iHasMutePermissions.value = me?.roleLevel == GroupRoleLevel.owner ||
            (me?.roleLevel == GroupRoleLevel.admin &&
                other?.roleLevel == GroupRoleLevel.member);
        // 我是管理员或群主
        iHaveAdminOrOwnerPermission.value =
            me?.roleLevel == GroupRoleLevel.owner ||
                me?.roleLevel == GroupRoleLevel.admin;
      }

      if (null != other &&
          null != other.muteEndTime &&
          other.muteEndTime! > 0) {
        _calMuteTime(other.muteEndTime!);
      }
    }
  }

  _getJoinGroupMethod(GroupMembersInfo? other) async {
    // 入群方式 2：邀请加入 3：搜索加入 4：通过二维码加入
    if (other?.joinSource == 2) {
      if (other!.inviterUserID != null && other.inviterUserID != other.userID) {
        final list = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
          groupID: groupID!,
          userIDList: [other.inviterUserID!],
        );
        var inviterUserInfo = list.firstOrNull;
        joinGroupMethod.value = sprintf(
          StrRes.byInviteJoinGroup,
          [inviterUserInfo?.nickname ?? ''],
        );
      }
    } else if (other?.joinSource == 3) {
      joinGroupMethod.value = StrRes.byIDJoinGroup;
    } else if (other?.joinSource == 4) {
      joinGroupMethod.value = StrRes.byQrcodeJoinGroup;
    }
  }

  /// 禁言时长
  _calMuteTime(int time) {
    var date = DateUtil.formatDateMs(time, format: IMUtils.getTimeFormat2());
    var now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var diff = time - now;
    if (diff > 0) {
      mutedTime.value = date;
    } else {
      mutedTime.value = "";
    }
  }

  String getShowName() {
    if (isGroupMemberPage) {
      if (isFriendship) {
        // if (userInfo.value.nickname != groupUserNickname.value) {
        //   return '${groupUserNickname.value}(${IMUtils.emptyStrToNull(userInfo.value.remark) ?? userInfo.value.nickname})';
        // } else {
        //   if (userInfo.value.remark != null &&
        //       userInfo.value.remark!.isNotEmpty) {
        //     return '${groupUserNickname.value}(${IMUtils.emptyStrToNull(userInfo.value.remark)})';
        //   }
        // }
        if (null != IMUtils.emptyStrToNull(userInfo.value.remark)) {
          return groupUserNickname.value.isEmpty
              ? '${IMUtils.emptyStrToNull(userInfo.value.remark)}'
              : '${groupUserNickname.value}(${IMUtils.emptyStrToNull(userInfo.value.remark)})';
        }
      }
      if (groupUserNickname.value.isEmpty) {
        return userInfo.value.nickname ??= "";
      }
      return groupUserNickname.value;
    }
    if (userInfo.value.remark != null && userInfo.value.remark!.isNotEmpty) {
      return '${userInfo.value.nickname}(${userInfo.value.remark})';
    }
    return userInfo.value.nickname ?? '';
  }

  /// 设置为管理员
  void toggleAdmin() async {
    final hasPermission = !hasAdminPermission.value;
    final roleLevel =
        hasPermission ? GroupRoleLevel.admin : GroupRoleLevel.member;
    await LoadingView.singleton.wrap(
        asyncFunction: () =>
            OpenIM.iMManager.groupManager.setGroupMemberRoleLevel(
              groupID: groupID!,
              userID: userInfo.value.userID!,
              roleLevel: roleLevel,
            ));

    groupMembersInfo?.roleLevel = roleLevel;
    hasAdminPermission.value = hasPermission;
    // 更新其他界面群成员权限
    if (null != groupMembersInfo) {
      imLogic.memberInfoChangedSubject.add(groupMembersInfo!);
    }
    IMViews.showToast(StrRes.setSuccessfully);
  }

  void toChat() {
    conversationLogic.toChat(
      offUntilHome: true,
      userID: userInfo.value.userID,
      nickname: userInfo.value.showName,
      faceURL: userInfo.value.faceURL,
    );
  }

  void toCall() {
    if (trtcLogic.isTrtcAvailable == false) {
      IMViews.showToast('音视频通话不可用');
      return;
    }
    if (userInfo.value.userID == null) {
      return;
    }
    Get.bottomSheet(
      barrierColor: Colors.transparent,
      BottomSheetView(
        items: [
          SheetItem(
            customIcon: Icons.call,
            label: StrRes.audioCall,
            onTap: () => trtcLogic.callAudio(userInfo.value.userID!),
          ),
          SheetItem(
            customIcon: Icons.videocam_outlined,
            label: StrRes.videoCall,
            onTap: () => trtcLogic.callVideo(userInfo.value.userID!),
          ),
        ],
      ),
    );
  }

  /// 群主禁言（取消禁言）管理员和普通成员，管理员只能禁言（取消禁言）普通成员
  void setMute() => AppNavigator.startSetMuteForGroupMember(
        groupID: groupID!,
        userID: userInfo.value.userID!,
      );

  void copyID() {
    IMUtils.copy(text: userInfo.value.userID!);
  }

  void addFriend() => AppNavigator.startSendVerificationApplication(
        userID: userInfo.value.userID!,
      );

  void viewPersonalInfo() => AppNavigator.startPersonalInfo(
        userID: userInfo.value.userID!,
      );

  void friendSetup() => AppNavigator.startFriendSetup(
        userID: userInfo.value.userID!,
      );

  void viewDynamics() => {};

  /// Set friend remark
  void setFriendRemark() => AppNavigator.startSetFriendRemark();

  /// Toggle blacklist
  void toggleBlacklist() {
    if (userInfo.value.isBlacklist == true) {
      removeBlacklist();
    } else {
      addBlacklist();
    }
  }

  /// Add to blacklist
  void addBlacklist() async {
    var confirm = await Get.dialog(
        barrierColor: Colors.transparent,
        CustomDialog(title: StrRes.areYouSureAddBlacklist));
    if (confirm == true) {
      await OpenIM.iMManager.friendshipManager.addBlacklist(
        userID: userInfo.value.userID!,
      );
      userInfo.update((val) {
        val?.isBlacklist = true;
        val?.isFriendship = false;
      });
      _getUsersInfo();
    }
  }

  /// Remove from blacklist
  void removeBlacklist() async {
    await OpenIM.iMManager.friendshipManager.removeBlacklist(
      userID: userInfo.value.userID!,
    );
    userInfo.update((val) {
      val?.isBlacklist = false;
    });
    _getUsersInfo();
  }

  /// Delete friend
  void deleteFromFriendList() async {
    var confirm = await Get.dialog(
        barrierColor: Colors.transparent,
        CustomDialog(
          title: StrRes.areYouSureDelFriend,
          rightText: StrRes.delete,
        ));
    if (confirm == true) {
      await LoadingView.singleton.wrap(asyncFunction: () async {
        await OpenIM.iMManager.friendshipManager.deleteFriend(
          userID: userInfo.value.userID!,
        );
        userInfo.update((val) {
          val?.isFriendship = false;
        });
        final userIDList = [
          userInfo.value.userID,
          OpenIM.iMManager.userID,
        ];
        userIDList.sort();
        final conversationID = 'si_${userIDList.join('_')}';
        await OpenIM.iMManager.conversationManager
            .deleteConversationAndDeleteAllMsg(conversationID: conversationID);
        conversationLogic.list
            .removeWhere((e) => e.conversationID == conversationID);
      });
      IMViews.showToast(StrRes.friendDeletedSuccessfully);
      if (offAllWhenDelFriend == true) {
        AppNavigator.startBackMain();
      } else {
        Get.back();
      }
    }
  }

  /// Recommend to friend
  void recommendToFriend() async {
    final result = await AppNavigator.startSelectContacts(
      action: SelAction.recommend,
      ex: '[${StrRes.carte}] ${userInfo.value.nickname}',
    );
    if (null != result) {
      final customEx = result['customEx'];
      final checkedList = result['checkedList'];
      for (var info in checkedList) {
        final userID = IMUtils.convertCheckedToUserID(info);
        final groupID = IMUtils.convertCheckedToGroupID(info);
        if (customEx is String && customEx.isNotEmpty) {
          OpenIM.iMManager.messageManager.sendMessage(
            message: await OpenIM.iMManager.messageManager.createTextMessage(
              text: customEx,
            ),
            userID: userID,
            groupID: groupID,
            offlinePushInfo: Config.offlinePushInfo,
          );
        }
        OpenIM.iMManager.messageManager.sendMessage(
          message: await OpenIM.iMManager.messageManager.createCardMessage(
            userID: userInfo.value.userID!,
            nickname: userInfo.value.nickname!,
            faceURL: userInfo.value.faceURL,
          ),
          userID: userID,
          groupID: groupID,
          offlinePushInfo: Config.offlinePushInfo,
        );
      }
    }
  }
}

class UserCacheManager {
  static final UserCacheManager _instance = UserCacheManager._();
  UserCacheManager._();
  final Map<String, UserFullInfo> _userInfoMap = {};

  void addOrUpdateUserInfo(String userID, UserFullInfo userInfo) {
    _userInfoMap[userID] = userInfo;
  }

  UserFullInfo? getUserInfo(String userID) {
    return _userInfoMap[userID];
  }

  void removeUserInfo(String userID) {
    _userInfoMap.remove(userID);
  }

  factory UserCacheManager() {
    return _instance;
  }
}
