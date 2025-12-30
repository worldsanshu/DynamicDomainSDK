import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../pages/chat/chat_setup/search_chat_history/multimedia/multimedia_logic.dart';
import '../pages/chat/group_setup/group_member_list/group_member_list_logic.dart';
import '../pages/contacts/add_by_search/add_by_search_logic.dart';
import '../pages/contacts/contacts_logic.dart';
import '../pages/contacts/group_profile_panel/group_profile_panel_logic.dart';
import '../pages/contacts/select_contacts/select_contacts_logic.dart';
import '../pages/mine/edit_my_info/edit_my_info_logic.dart';
import '../pages/auth/invite_code_binding.dart';
import '../pages/auth/invite_code_view.dart';
import 'app_pages.dart';

class AppNavigator {
  AppNavigator._();

  static void startLogin() {
    Get.offAllNamed(AppRoutes.auth, arguments: {'tab': 0});
  }

  static void startRegister() {
    Get.offAllNamed(AppRoutes.auth, arguments: {'tab': 1});
  }

  static void startInviteCode() {
    // Clear entire navigation stack to prevent back navigation
    Get.offAll(
      () => InviteCodeView(),
      binding: InviteCodeBinding(),
    );
  }

  static void startAuth({int initialTab = 0}) {
    Get.toNamed(AppRoutes.auth, arguments: {'tab': initialTab});
  }

  /// Navigate to auth screen and clear entire navigation stack (for logout)
  static void startAuthAfterLogout({int initialTab = 0}) {
    Get.offAll(
      () => InviteCodeView(),
      binding: InviteCodeBinding(),
    );
  }

  static Future? startGatewaySwitcher({Function()? onSwitch}) {
    return Get.toNamed(AppRoutes.gatewaySwitcher,
        arguments: {'onSwitch': onSwitch});
  }

  static Future? startMerchantList({fromLogin = false}) {
    return Get.toNamed(AppRoutes.merchantList,
        arguments: {'fromLogin': fromLogin});
  }

  static startMerchantSearch() {
    return Get.toNamed(AppRoutes.merchantSearch);
  }

  static startContacts() {
    return Get.toNamed(AppRoutes.contacts);
  }

  static void startAppeal({
    required String blockReason,
    required String imUserId,
    required String chatAddr,
  }) {
    Get.toNamed(AppRoutes.appeal, arguments: {
      'blockReason': blockReason,
      'imUserId': imUserId,
      'chatAddr': chatAddr,
    });
  }

  static void startBackLogin() {
    Get.until((route) => Get.currentRoute == AppRoutes.login);
  }

  static void startMain({bool isAutoLogin = false}) {
    Get.offAllNamed(
      AppRoutes.home,
      arguments: {'isAutoLogin': isAutoLogin},
    );
  }

  static void startSplashToMain(
      {bool isAutoLogin = false, List<ConversationInfo>? conversations}) {
    Get.offAndToNamed(
      AppRoutes.home,
      arguments: {'isAutoLogin': isAutoLogin, 'conversations': conversations},
    );
  }

  static void startBackMain() {
    Get.until((route) => Get.currentRoute == AppRoutes.home);
  }

  static startOANtfList({required ConversationInfo info}) {
    return Get.toNamed(AppRoutes.oaNotificationList, arguments: info);
  }

  /// 聊天页
  static Future<T?>? startChat<T>({
    required ConversationInfo conversationInfo,
    bool offUntilHome = true,
    String? draftText,
    Message? searchMessage,
  }) async {
    GetTags.createChatTag();

    final arguments = {
      'draftText': draftText,
      'conversationInfo': conversationInfo,
      'searchMessage': searchMessage,
    };

    if (offUntilHome) {
      // Two-step approach to avoid GetX argument mixing bug with offNamedUntil
      // Step 1: Pop all routes until we reach home
      Get.until((route) => route.settings.name == AppRoutes.home);

      // Give time for routes to settle and arguments to clear
      await Future.delayed(const Duration(milliseconds: 200));

      // Step 2: Push chat route with correct arguments
      return Get.toNamed(
        AppRoutes.chat,
        arguments: arguments,
        preventDuplicates: false,
      );
    } else {
      return Get.toNamed(
        AppRoutes.chat,
        arguments: arguments,
        preventDuplicates: false,
      );
    }
  }

  static startMyQrcode() => Get.toNamed(AppRoutes.myQrcode);

  static startFavoriteMange() => Get.toNamed(AppRoutes.favoriteManage);

  static startAddContactsMethod() => Get.toNamed(AppRoutes.addContactsMethod);

  static startScan() => Permissions.camera(() {
        // Ensure ScanBridge is available even if ContactsLogic hasn't been built yet
        if (!Get.isRegistered<ContactsLogic>()) {
          Get.put(ContactsLogic());
        }
        if (PackageBridge.scanBridge == null) {
          try {
            PackageBridge.scanBridge = Get.find<ContactsLogic>();
          } catch (_) {}
        }
        return Get.to(
          () => const QrcodeView(),
          transition: Transition.cupertino,
          popGesture: true,
        );
      });

  static startAddContactsBySearch({required SearchType searchType}) =>
      Get.toNamed(
        AppRoutes.addContactsBySearch,
        arguments: {"searchType": searchType},
      );

  static startUserProfilePane({
    required String userID,
    String? groupID,
    String? nickname,
    String? faceURL,
    bool offAllWhenDelFriend = false,
    bool offAndToNamed = false,
  }) {
    GetTags.createUserProfileTag();

    final arguments = {
      'groupID': groupID,
      'userID': userID,
      'nickname': nickname,
      'faceURL': faceURL,
      'offAllWhenDelFriend': offAllWhenDelFriend,
    };

    return offAndToNamed
        ? Get.offAndToNamed(AppRoutes.userProfilePanel, arguments: arguments)
        : Get.toNamed(
            AppRoutes.userProfilePanel,
            arguments: arguments,
            preventDuplicates: false,
          );
  }

  static startPersonalInfo({
    required String userID,
  }) =>
      Get.toNamed(AppRoutes.personalInfo, arguments: {
        'userID': userID,
      });

  static startFriendSetup({
    required String userID,
  }) =>
      Get.toNamed(AppRoutes.friendSetup, arguments: {
        'userID': userID,
      });

  static startSetFriendRemark() =>
      Get.toNamed(AppRoutes.setFriendRemark, arguments: {});

  static startSendVerificationApplication({
    String? userID,
    String? groupID,
    JoinGroupMethod? joinGroupMethod,
  }) =>
      Get.toNamed(AppRoutes.sendVerificationApplication, arguments: {
        'joinGroupMethod': joinGroupMethod,
        'userID': userID,
        'groupID': groupID,
      });

  static startGroupProfilePanel({
    required String groupID,
    required JoinGroupMethod joinGroupMethod,
    bool offAndToNamed = false,
  }) =>
      offAndToNamed
          ? Get.offAndToNamed(AppRoutes.groupProfilePanel, arguments: {
              'joinGroupMethod': joinGroupMethod,
              'groupID': groupID,
            })
          : Get.toNamed(AppRoutes.groupProfilePanel, arguments: {
              'joinGroupMethod': joinGroupMethod,
              'groupID': groupID,
            });

  static startSetMuteForGroupMember({
    required String groupID,
    required String userID,
  }) =>
      Get.toNamed(AppRoutes.setMuteForGroupMember, arguments: {
        'groupID': groupID,
        'userID': userID,
      });

  static startMyInfo() => Get.toNamed(AppRoutes.myInfo);

  static startEditMyInfo({EditAttr attr = EditAttr.nickname, int? maxLength}) =>
      Get.toNamed(AppRoutes.editMyInfo,
          arguments: {'editAttr': attr, 'maxLength': maxLength});

  static startAccountSetup() => Get.toNamed(AppRoutes.accountSetup);

  static startBlacklist() => Get.toNamed(AppRoutes.blacklist);

  static startLanguageSetup() => Get.toNamed(AppRoutes.languageSetup);

  static startUnlockSetup() => Get.toNamed(AppRoutes.unlockSetup);

  static startChangePassword() => Get.toNamed(AppRoutes.changePassword);

  static startResetPassword({bool fromLogin = true}) =>
      Get.toNamed(AppRoutes.resetPassword, arguments: {'fromLogin': fromLogin});

  static startAboutUs() => Get.toNamed(AppRoutes.aboutUs);

  static startPrivacyPolicy() => Get.toNamed(AppRoutes.privacyPolicy);

  static startContactUs() => Get.toNamed(AppRoutes.contactUs);

  static startServiceAgreement() => Get.toNamed(AppRoutes.serviceAgreement);

  static startChatAnalytics() => Get.toNamed(AppRoutes.chatAnalytics);

  static startRealNameAuth() => Get.toNamed(AppRoutes.realNameAuth);

  static startChatSetup({
    required ConversationInfo conversationInfo,
  }) =>
      Get.toNamed(AppRoutes.chatSetup, arguments: {
        'conversationInfo': conversationInfo,
      });

  static startSetBackgroundImage() => Get.toNamed(AppRoutes.setBackgroundImage);

  static startSetFontSize() => Get.toNamed(AppRoutes.setFontSize);

  static startSearchChatHistory({
    required ConversationInfo conversationInfo,
  }) =>
      Get.toNamed(AppRoutes.searchChatHistory, arguments: {
        'conversationInfo': conversationInfo,
      });

  static startSearchChatHistoryTime(
          {required ConversationInfo conversationInfo,
          required DateTime dateTime}) =>
      Get.toNamed(AppRoutes.searchChatHistory, arguments: {
        'conversationInfo': conversationInfo,
        'dateTime': dateTime
      });

  static startSearchChatHistoryMultimedia({
    required ConversationInfo conversationInfo,
    MultimediaType multimediaType = MultimediaType.picture,
  }) =>
      Get.toNamed(AppRoutes.searchChatHistoryMultimedia, arguments: {
        'conversationInfo': conversationInfo,
        'multimediaType': multimediaType,
      });

  static startSearchChatHistoryFile({
    required ConversationInfo conversationInfo,
  }) =>
      Get.toNamed(AppRoutes.searchChatHistoryFile, arguments: {
        'conversationInfo': conversationInfo,
      });

  static startPreviewChatHistory({
    required ConversationInfo conversationInfo,
    required Message message,
  }) =>
      Get.toNamed(AppRoutes.previewChatHistory, arguments: {
        'conversationInfo': conversationInfo,
        'message': message,
      });

  static startGroupChatSetup({
    required ConversationInfo conversationInfo,
  }) =>
      Get.toNamed(AppRoutes.groupChatSetup, arguments: {
        'conversationInfo': conversationInfo,
      });

  static startGroupManage({
    required GroupInfo groupInfo,
  }) =>
      Get.toNamed(AppRoutes.groupManage, arguments: {
        'groupInfo': groupInfo,
      });

  static startEditGroupAnnouncement({required String groupID}) =>
      Get.toNamed(AppRoutes.editGroupAnnouncement, arguments: groupID);

  static Future<T?>? startGroupMemberList<T>({
    required GroupInfo groupInfo,
    GroupMemberOpType opType = GroupMemberOpType.view,
    bool isShowEveryone = true,
    List<String>? defaultCheckedUserIDs,
    int? maxSelectCount,
  }) =>
      Get.toNamed(AppRoutes.groupMemberList,
          preventDuplicates: false,
          arguments: {
            'groupInfo': groupInfo,
            'opType': opType,
            'isShowEveryone': isShowEveryone,
            'defaultCheckedUserIDs': defaultCheckedUserIDs,
            'maxSelectCount': maxSelectCount,
          });

  static startSearchGroupMember(
          {required GroupInfo groupInfo,
          GroupMemberOpType opType = GroupMemberOpType.view,
          required bool isOwnerOrAdmin}) =>
      Get.toNamed(AppRoutes.searchGroupMember, arguments: {
        'groupInfo': groupInfo,
        'opType': opType,
        'isOwnerOrAdmin': isOwnerOrAdmin,
      });

  static startGroupOnlineInfo({
    required GroupInfo groupInfo,
    required bool isOwnerOrAdmin,
  }) =>
      Get.toNamed(AppRoutes.groupOnlineInfo, arguments: {
        'groupInfo': groupInfo,
        'isOwnerOrAdmin': isOwnerOrAdmin,
      });

  static startGroupQrcode() => Get.toNamed(AppRoutes.groupQrcode);

  static startReportReasonList({
    required String chatType,
    String? groupID,
    String? userID,
  }) =>
      Get.toNamed(AppRoutes.reportReasonList, arguments: {
        'chatType': chatType,
        'groupID': groupID,
        'userID': userID
      });

  static startReportSubmit({
    required String chatType,
    required String reportReason,
    String? groupID,
    String? userID,
  }) =>
      Get.toNamed(AppRoutes.reportSubmit, arguments: {
        'chatType': chatType,
        'reportReason': reportReason,
        'groupID': groupID,
        'userID': userID
      });

  static startFriendRequests() => Get.toNamed(AppRoutes.friendRequests);

  static startProcessFriendRequests({
    required FriendApplicationInfo applicationInfo,
  }) =>
      Get.toNamed(AppRoutes.processFriendRequests, arguments: {
        'applicationInfo': applicationInfo,
      });

  static startGroupRequests() => Get.toNamed(AppRoutes.groupRequests);

  static startProcessGroupRequests({
    required GroupApplicationInfo applicationInfo,
  }) =>
      Get.toNamed(AppRoutes.processGroupRequests, arguments: {
        'applicationInfo': applicationInfo,
      });

  static startGroupReadList(String conversationID, String clientMsgID) =>
      Get.toNamed(AppRoutes.groupReadList, arguments: {
        "conversationID": conversationID,
        "clientMsgID": clientMsgID
      });

  static startSearchGroup() => Get.toNamed(AppRoutes.searchGroup);

  static startSelectContacts({
    required SelAction action,
    List<String>? defaultCheckedIDList,
    List<dynamic>? checkedList,
    List<String>? excludeIDList,
    bool openSelectedSheet = false,
    String? groupID,
    String? ex,
    bool? showRadioButton,
  }) =>
      Get.toNamed(AppRoutes.selectContacts, arguments: {
        'action': action,
        'defaultCheckedIDList': defaultCheckedIDList,
        'checkedList': IMUtils.convertCheckedListToMap(checkedList),
        'excludeIDList': excludeIDList,
        'openSelectedSheet': openSelectedSheet,
        'groupID': groupID,
        'ex': ex,
        'showRadioButton': showRadioButton
      });

  static startSelectContactsFromFriends() =>
      Get.toNamed(AppRoutes.selectContactsFromFriends);

  static startSelectContactsFromGroup() =>
      Get.toNamed(AppRoutes.selectContactsFromGroup);

  static startSelectContactsFromSearchFriends() =>
      Get.toNamed(AppRoutes.selectContactsFromSearchFriends);

  static startSelectContactsFromSearchGroup() =>
      Get.toNamed(AppRoutes.selectContactsFromSearchGroup);

  static startSelectContactsFromSearch() =>
      Get.toNamed(AppRoutes.selectContactsFromSearch);

  static startCreateGroup({
    List<UserInfo> defaultCheckedList = const [],
  }) async {
    final excludeIDs = defaultCheckedList.map((e) => e.userID!).toList();
    final result = await startSelectContacts(
      action: SelAction.crateGroup,
      defaultCheckedIDList: excludeIDs,
      excludeIDList: excludeIDs, // Hide already-selected users from the list
    );

    // Verify that result is not null before proceeding
    if (result == null) {
      return null;
    }

    // Convert UserInfo to Map for proper serialization
    final defaultCheckedMaps = defaultCheckedList
        .map((u) => {
              'userID': u.userID,
              'nickname': u.nickname,
              'faceURL': u.faceURL,
            })
        .toList();

    // Get newly selected members (may be empty)
    final list = IMUtils.convertSelectContactsResultToUserInfo(result);
    final checkedList = (list is List<UserInfo>) ? list : <UserInfo>[];

    // Navigate to create group even if no new members selected
    if (checkedList.isNotEmpty || defaultCheckedList.isNotEmpty) {
      return Get.toNamed(
        AppRoutes.createGroup,
        arguments: {
          'checkedList': checkedList,
          'defaultCheckedMaps': defaultCheckedMaps,
        },
      );
    }
    return null;
  }

  static startGlobalSearch() => Get.toNamed(AppRoutes.globalSearch);

  static startExpandChatHistory({
    required SearchResultItems searchResultItems,
    required String defaultSearchKey,
  }) =>
      Get.toNamed(AppRoutes.expandChatHistory, arguments: {
        'searchResultItems': searchResultItems,
        'defaultSearchKey': defaultSearchKey,
      });

  static startCallRecords() => Get.toNamed(AppRoutes.callRecords);
}
