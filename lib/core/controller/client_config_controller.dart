import 'dart:convert';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/pages/chat/message_visibility_cache.dart';
import 'package:openim_common/openim_common.dart';

import '../helpers/config_util.dart';

class ClientConfigController extends GetxController {
  final clientConfigMap = Map<String, dynamic>.from(defaultClientConfig).obs;

  Future<void> queryClientConfig() async {
    Map<String, dynamic>? remoteConfig;

    try {
      remoteConfig = await ChatApis.getClientConfig();
    } catch (_) {}

    final configSource =
        remoteConfig ?? ConfigUtil.castMapOrNull(DataSp.getClientConfig());

    if (configSource != null) {
      final mergedConfig = ConfigUtil.mergeWithDefault(
        source: configSource,
        defaultValues: defaultClientConfig,
      );
      clientConfigMap.assignAll(mergedConfig);
      print('Config nè: ${clientConfigMap}');
      DataSp.putClientConfig(mergedConfig);
    }
  }

  bool isOwner(int? roleLevel) => roleLevel == GroupRoleLevel.owner;

  bool isAdminOrOwner(int? roleLevel) {
    return roleLevel == GroupRoleLevel.admin ||
        roleLevel == GroupRoleLevel.owner;
  }

  bool get showMemberKickedMessages =>
      clientConfigMap['hideMemberKickedMessagesOnMobile'] == '2';

  bool get showRevokeMessage =>
      clientConfigMap['hideRevokeMessageOnMobile'] == '2';

  bool get showMemberJoinedMessages =>
      clientConfigMap['hideMemberJoinedMessagesOnMobile'] == '2';

  bool get showMemberQuitMessages =>
      clientConfigMap['hideMemberQuitMessageOnMobile'] == '2';

  bool get showMemberMutedMessages =>
      clientConfigMap['hideMemberMutedMessageOnMobile'] == '2';

  String get memberCountVisibility => clientConfigMap['memberCountVisibility'];

  String get joinGroupTimeVisibility =>
      clientConfigMap['joinGroupTimeVisibilityOnMobile'];

  String get joinGroupMethodVisibility =>
      clientConfigMap['joinGroupMethodVisibilityOnMobile'];

  String get onlineInfoVisibility => clientConfigMap['onlineInfoVisibility'];

  int get maxImageSendCount =>
      (int.tryParse(clientConfigMap['maxImageSendCountOnMobile'] ?? '') ?? 9);

  bool get showOnlineDevices =>
      clientConfigMap['showOnlineDevicesOnMobile'] == '1';

  int get maxMessagesPerInterval =>
      (int.tryParse(clientConfigMap['maxMessagesPerIntervalOnMobile'] ?? '') ??
          -1);

  bool get showOrganization =>
      clientConfigMap['showOrganizationOnMobile'] == '1';

  String get phoneNumberVisibility =>
      clientConfigMap['phoneNumberVisibilityOnMobile'];

  bool get showPhoneNumber =>
      clientConfigMap['phoneNumberVisibilityOnMobile'] == 'showAll';

  bool get allowSendMsgNotFriend =>
      clientConfigMap['allowSendMsgNotFriend'] == '1';

  bool get showAudioAndVideoCall =>
      clientConfigMap['showAudioAndVideoCall'] == '1';

  bool get adminHasManagementAccess =>
      clientConfigMap['adminHasManagementAccess'] == '1';

  bool get showCreateGroupTime => clientConfigMap['showCreateGroupTime'] == '1';

  String get discoverPageURL => clientConfigMap['discoverPageURL'] ?? '';

  bool get allowAtGroupMembers => clientConfigMap['allowAtGroupMembers'] == '1';

  String get friendSearchMode => clientConfigMap['friendSearchMode'];

  bool computeVisibility(String setting, int groupMemberRoleLevel) {
    switch (setting) {
      case 'everyone':
        return true;
      case 'adminOrOwner':
        return isAdminOrOwner(groupMemberRoleLevel);
      case 'ownerOnly':
        return isOwner(groupMemberRoleLevel);
      case 'none':
        return false;
      default:
        return true;
    }
  }

  bool shouldShowMemberCount({int? roleLevel, String? ownerUserID}) {
    if (memberCountVisibility == 'none') {
      return false;
    }
    if (roleLevel == null) {
      return memberCountVisibility == 'everyone' ||
          ownerUserID == OpenIM.iMManager.userID;
    }
    return computeVisibility(memberCountVisibility, roleLevel);
  }

  bool shouldShowJoinGroupTime(int roleLevel) =>
      computeVisibility(joinGroupTimeVisibility, roleLevel);

  bool shouldShowJoinGroupMethod(int roleLevel) =>
      computeVisibility(joinGroupMethodVisibility, roleLevel);

  bool shouldShowGroupOnlineInfo(int groupMemberRoleLevel) =>
      computeVisibility(onlineInfoVisibility, groupMemberRoleLevel);

  /// 判断是否应显示撤回消息
  /// 1. 如果全局配置允许显示所有撤回消息（`showRevokeMessage == true`），则直接返回 true；
  /// 2. 如果该消息的可见性已有缓存，返回缓存值；
  /// 3. 否则解析撤回详情，满足以下任一条件则显示：
  ///    - 当前用户是消息的发送者（有权知晓自己的消息被撤回）；
  ///    - 撤回者就是消息发送者（即发送者主动撤回自己的消息）；
  ///    - 当前用户是撤回者（即使撤回别人消息，也应看到提示）；
  /// 无论结果如何，都会将其缓存。
  bool shouldShowRevokeMessage(Message message) {
    if (showRevokeMessage) {
      return true;
    }

    final cached = MessageVisibilityCache.instance.getVisibility(message);
    if (cached != null) return cached;

    try {
      final map = json.decode(message.notificationElem!.detail!);
      final info = RevokedInfo.fromJson(map);

      final isSelfSender = info.sourceMessageSendID == OpenIM.iMManager.userID;
      final isRevokerTheSender = info.revokerID == info.sourceMessageSendID;
      final isSelfRevoker = info.revokerID == OpenIM.iMManager.userID;

      final visible = isSelfSender || isRevokerTheSender || isSelfRevoker;

      MessageVisibilityCache.instance.setVisibility(message, visible);

      return visible;
    } catch (e) {
      return false;
    }
  }

  bool shouldShowMemberKickedMessages(Message message) {
    if (showMemberKickedMessages) {
      return true;
    }

    final cached = MessageVisibilityCache.instance.getVisibility(message);
    if (cached != null) return cached;

    try {
      final detail = message.notificationElem!.detail;
      if (detail == null) return false;

      final map = json.decode(detail);
      final ntf = KickedGroupMemeberNotification.fromJson(map);
      final kickedUserList = ntf.kickedUserList;
      final opUser = ntf.opUser!;

      final hasSelfBeenKicked = kickedUserList?.any((user) {
            return user.userID == OpenIM.iMManager.userID;
          }) ??
          false;
      final isSelfOperator = opUser.userID == OpenIM.iMManager.userID;
      final visible = hasSelfBeenKicked || isSelfOperator;

      MessageVisibilityCache.instance.setVisibility(message, visible);

      return visible;
    } catch (e) {
      return false;
    }
  }

  /// 判断是否显示成员进群消息：
  /// - 如果全局设置开启，则总是显示；
  /// - 如果当前用户是群主/管理员，则总是显示；
  /// - 如果是自己加入群聊或被邀请进群，才显示；
  bool shouldShowMemberJoinedMessage(Message message,
      [int? groupMemberRoleLevel]) {
    if (showMemberJoinedMessages) {
      return true;
    }

    // Admin/Owner should always see join messages
    if (isAdminOrOwner(groupMemberRoleLevel)) {
      return true;
    }

    final cached = MessageVisibilityCache.instance.getVisibility(message);
    if (cached != null) return cached;

    try {
      final elem = message.notificationElem!;
      final map = json.decode(elem.detail!);

      if (message.contentType == MessageType.memberEnterNotification) {
        final ntf = EnterGroupNotification.fromJson(map);
        final visible = ntf.entrantUser?.userID! == OpenIM.iMManager.userID;
        MessageVisibilityCache.instance.setVisibility(message, visible);
        return visible;
      } else if (message.contentType == MessageType.memberInvitedNotification) {
        final ntf = InvitedJoinGroupNotification.fromJson(map);
        final isSelfOperator = ntf.opUser?.userID == OpenIM.iMManager.userID;
        final hasSelfBeenJoined = ntf.invitedUserList?.any((member) {
              return member.userID == OpenIM.iMManager.userID;
            }) ??
            false;
        final visible = isSelfOperator || hasSelfBeenJoined;
        MessageVisibilityCache.instance.setVisibility(message, visible);
        return visible;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// 判断是否显示群成员退群消息。
  /// 显示规则：
  /// - 若全局开关 `showMemberQuitMessages` 为 true，则显示；
  /// - 否则，仅当当前用户是退群者，或当前用户为管理员/群主时显示；
  /// - 结果会被缓存以避免重复解析。
  bool shouldShowMemberQuitMessage(Message message,
      [int? groupMemberRoleLevel]) {
    if (showMemberQuitMessages) {
      return true;
    }

    final cached = MessageVisibilityCache.instance.getVisibility(message);
    if (cached != null) return cached;

    try {
      final elem = message.notificationElem!;
      final map = json.decode(elem.detail!);
      final ntf = QuitGroupNotification.fromJson(map);

      final isSelfOperator = ntf.quitUser?.userID == OpenIM.iMManager.userID;
      final visible = isSelfOperator || isAdminOrOwner(groupMemberRoleLevel);
      MessageVisibilityCache.instance.setVisibility(message, visible);
      return visible;
    } catch (e) {
      return false;
    }
  }

  bool shouldShowMemberMutedMessages(Message message) {
    if (showMemberMutedMessages) {
      return true;
    }
    try {
      final elem = message.notificationElem!;
      final map = json.decode(elem.detail!);
      final ntf = MuteMemberNotification.fromJson(map);
      final isSelfOperator = ntf.opUser?.userID == OpenIM.iMManager.userID;
      final isSelfMuted = ntf.mutedUser?.userID == OpenIM.iMManager.userID;
      return isSelfOperator || isSelfMuted;
    } catch (e) {
      return false;
    }
  }

  /// 聚合判断
  bool isMessageHidden(Message message, [int? groupMemberRoleLevel]) {
    switch (message.contentType) {
      case MessageType.memberKickedNotification:
        return !shouldShowMemberKickedMessages(message);
      case MessageType.memberEnterNotification:
      case MessageType.memberInvitedNotification:
        return !shouldShowMemberJoinedMessage(message, groupMemberRoleLevel);
      case MessageType.revokeMessageNotification:
        return !shouldShowRevokeMessage(message);
      case MessageType.memberQuitNotification:
        return !shouldShowMemberQuitMessage(message, groupMemberRoleLevel);
      case MessageType.groupMemberMutedNotification:
      case MessageType.groupMemberCancelMutedNotification:
        return !shouldShowMemberMutedMessages(message);
      default:
        return false;
    }
  }

  String replacePhoneNumber(phoneNumber) {
    String phone = IMUtils.emptyStrToNull(phoneNumber) ?? '-';
    switch (phoneNumberVisibility) {
      case 'showAll':
        return phone;
      case 'hide':
        return '***********';
      case 'showPartial':
        if (phone.length > 7) {
          return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
        }
        return phone;
      default:
        return phone;
    }
  }
}

/// discoverPageURL
/// ordinaryUserAddFriend,
/// bossUserID,
/// adminURL ,
/// allowSendMsgNotFriend
/// needInvitationCodeRegister
/// robots
const Map<String, dynamic> defaultClientConfig = {
  'discoverPageURL': '',
  'allowSendMsgNotFriend': '2',
  'showOrganizationOnMobile': '2',
  'showOnlineDevicesOnMobile': '2',
  'phoneNumberVisibilityOnMobile': 'showPartial',
  'onlineInfoVisibility': 'adminOrOwner',
  'memberCountVisibility': 'adminOrOwner',
  'showToolboxLocation': '1',
  'showAudioAndVideoCall': '1',
  'maxImageSendCountOnMobile': '9',
  'maxMessagesPerIntervalOnMobile': '-1',
  'hideMemberKickedMessagesOnMobile': '1',
  'hideRevokeMessageOnMobile': '1',
  'hideMemberJoinedMessagesOnMobile': '1',
  'hideMemberQuitMessageOnMobile': '1',
  'hideMemberMutedMessageOnMobile': '1',
  'adminHasManagementAccess': '1',
  'allowAtGroupMembers': '1',
  'showCreateGroupTime': '2',
  'joinGroupTimeVisibilityOnMobile': 'adminOrOwner',
  'joinGroupMethodVisibilityOnMobile': 'adminOrOwner',
  'friendSearchMode': 'noFuzzy', // noFuzzy，noUserID，noPhone
};
