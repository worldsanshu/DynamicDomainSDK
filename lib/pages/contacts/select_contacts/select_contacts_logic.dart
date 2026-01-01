// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/core/controller/client_config_controller.dart';
import 'package:openim/pages/conversation/conversation_logic.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim/routes/app_pages.dart';
import 'package:openim/widgets/custom_bottom_sheet.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import '../friend_list_logic.dart';
import 'select_contacts_view.dart';

enum SelAction {
  /// 转发到最近聊天，转发到好友，转发到群里，转发到组织架构
  forward,

  /// 发送名片到该聊天：可从好友，组织架构
  carte,

  /// 创建群聊：可从好友，组织架构
  crateGroup,

  /// 添加群成员：可从好友，组织架构
  addMember,

  /// 推荐：可推荐给最近聊天，好友，群里，组织架构
  recommend,

  /// 创建tag组，可从好友, 组织架构
  createTag,

  /// 朋友圈：可见或部分可见 选择从 好友，群
  whoCanWatch,

  /// 朋友圈：提醒谁看 只有好友
  remindWhoToWatch,

  /// 下发通知 好友，组织架构，群，标签，最近会话
  notificationIssued,
}

class SelectContactsLogic
    extends GetxController /*implements OrganizationMultiSelBridge*/ {
  final checkedList = <String, dynamic>{}.obs; // 已经选中的
  final defaultCheckedIDList = <String>{}.obs; // 默认选中，且不能修改
  List<String>? excludeIDList; // 剔除某些数据
  late SelAction action;
  late bool openSelectedSheet;
  String? groupID;
  final conversationList = <ConversationInfo>[].obs;
  String? ex;
  bool? showRadioButton;
  final inputCtrl = TextEditingController();
  final clientConfigLogic = Get.find<ClientConfigController>();
  final friendListLogic = Get.find<FriendListLogic>();
  late RxList<ISUserInfo> friendList;
  final searchCtrl = TextEditingController();
  final searchText = ''.obs;
  final searchResults = <String, dynamic>{}.obs;

  @override
  void onInit() {
    action = Get.arguments['action'];
    showRadioButton = Get.arguments['showRadioButton'];
    groupID = Get.arguments['groupID'];
    excludeIDList = Get.arguments['excludeIDList'];

    if (excludeIDList != null && excludeIDList!.isNotEmpty) {
      friendList = friendListLogic.friendList
          .where((friend) => !excludeIDList!.contains(friend.userID))
          .toList()
          .obs;
    } else {
      friendList = friendListLogic.friendList;
    }

    // Defer reactive updates to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final defaultList = Get.arguments['defaultCheckedIDList'] ?? [];
      final checkedMap = Get.arguments['checkedList'] ?? {};

      if (defaultList.isNotEmpty) {
        defaultCheckedIDList.addAll(defaultList);
      }
      if (checkedMap.isNotEmpty) {
        checkedList.addAll(checkedMap);
      }
    });

    openSelectedSheet = Get.arguments['openSelectedSheet'];
    ex = Get.arguments['ex'];
    // PackageBridge.organizationBridge = this;
    super.onInit();
  }

  @override
  void onClose() {
    inputCtrl.dispose();
    searchCtrl.dispose();
    // PackageBridge.organizationBridge = null;
    super.onClose();
  }

  @override
  void onReady() {
    _queryConversationList();
    if (openSelectedSheet) viewSelectedContactsList();
    super.onReady();
  }

  bool get isMultiModel => true; //action != SelAction.carte;

  /// 隐藏群
  bool get hiddenGroup =>
      action == SelAction.carte ||
      action == SelAction.crateGroup ||
      action == SelAction.addMember ||
      action == SelAction.createTag ||
      action == SelAction.remindWhoToWatch;

  /// 隐藏最近会话
  bool get hiddenConversations =>
      action == SelAction.carte ||
      action == SelAction.crateGroup ||
      action == SelAction.addMember ||
      action == SelAction.createTag ||
      action == SelAction.whoCanWatch ||
      action == SelAction.remindWhoToWatch;

  /// 隐藏标签组
  bool get hiddenTagGroup =>
      action == SelAction.forward ||
      action == SelAction.carte ||
      action == SelAction.crateGroup ||
      action == SelAction.addMember ||
      action == SelAction.recommend ||
      action == SelAction.createTag ||
      action == SelAction.whoCanWatch ||
      action == SelAction.remindWhoToWatch;

  bool get isShowFriendListOnly => (action == SelAction.crateGroup ||
      action == SelAction.addMember ||
      action == SelAction.carte);

  bool shouldShowMemberCount(String ownerUserID) =>
      clientConfigLogic.shouldShowMemberCount(ownerUserID: ownerUserID);

  /// 最近会话
  _queryConversationList() async {
    if (!hiddenConversations) {
      final cons = Get.find<ConversationLogic>().list;

      final futures = cons.map((con) async {
        if (con.isGroupChat) {
          final result = await OpenIM.iMManager.groupManager
              .isJoinedGroup(groupID: con.groupID!);
          return result ? con : null;
        }
        return con;
      }).toList();

      final results = await Future.wait(futures);
      final filteredCons =
          results.where((con) => con != null).cast<ConversationInfo>().toList();

      // Use post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        conversationList.addAll(filteredCons);
      });
    }
  }

  /// 处理最近会话的选择
  void toggleConversationChecked(ConversationInfo info) {
    if (isMultiModel) {
      final key = parseID(info);
      if (checkedList.containsKey(key)) {
        checkedList.remove(key);
      } else {
        if (checkedList.length >= 999) {
          IMViews.showToast(sprintf(StrRes.selectAllMaxUserHint, [999]));
          return;
        }
        checkedList.putIfAbsent(key ?? '', () => info);
      }
    } else {
      confirmSelectedItem(info);
    }
  }

  /// 检查最近会话是否被选中
  bool isConversationChecked(ConversationInfo info) {
    return checkedList.containsKey(parseID(info));
  }

  /// 发送到选中的会话
  void sendToSelectedConversations() async {
    if (checkedList.isEmpty) return;

    // 根据action类型处理
    if (action == SelAction.forward || action == SelAction.recommend) {
      final sure = await Get.dialog(
          barrierColor: Colors.transparent,
          ForwardHintDialog(
            title: ex ?? '',
            checkedList: checkedList.values.toList(),
            controller: inputCtrl,
          ));
      if (sure == true) {
        IMViews.showToast(StrRes.sentSuccessfully, type: 1);
        Get.back(result: {
          "checkedList": checkedList.values,
          "customEx": inputCtrl.text.trim(),
        });
      }
    } else {
      Get.back(result: checkedList);
    }
  }

  static String? parseID(e) {
    if (e is ConversationInfo) {
      return e.isSingleChat ? e.userID : e.groupID;
    } else if (e is GroupInfo) {
      return e.groupID;
    } else if (e is UserInfo || e is FriendInfo || e is UserFullInfo) {
      return e.userID;
    } else if (e is TagInfo) {
      return e.tagID;
    } else {
      return null;
    }
  }

  static String? parseName(e) {
    if (e is ConversationInfo) {
      return e.showName;
    } else if (e is GroupInfo) {
      return e.groupName;
    } else if (e is UserInfo || e is FriendInfo || e is UserFullInfo) {
      return e.nickname;
    } else if (e is TagInfo) {
      return e.tagName;
    } else {
      return null;
    }
  }

  static String? parseFaceURL(e) {
    if (e is ConversationInfo) {
      return e.faceURL;
    } else if (e is GroupInfo) {
      return e.faceURL;
    } else if (e is UserInfo || e is FriendInfo || e is UserFullInfo) {
      return e.faceURL;
    } else {
      return null;
    }
  }

  bool isChecked(info) => checkedList.containsKey(parseID(info));

  bool isDefaultChecked(info) => defaultCheckedIDList.contains(parseID(info));

  Function()? onTap(dynamic info) {
    // Allow toggling even for items that were passed as default-checked so
    // previously selected users are visible and can be unchecked.
    return () => toggleChecked(info);
  }

  removeItem(dynamic info) {
    checkedList.remove(parseID(info));
  }

  toggleChecked(dynamic info) {
    if (isMultiModel) {
      final key = parseID(info);
      if (checkedList.containsKey(key)) {
        checkedList.remove(key);
      } else {
        if (checkedList.length >= 999) {
          IMViews.showToast(sprintf(StrRes.selectAllMaxUserHint, [999]));
          return;
        }
        checkedList.putIfAbsent(key ?? '', () => info);
      }
    } else {
      confirmSelectedItem(info);
    }
  }

  /// 邀请群成员，标记已入群的人员
  updateDefaultCheckedList(List<String> userIDList) async {
    if (groupID != null) {
      var list = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
        groupID: groupID!,
        userIDList: userIDList,
      );
      // Use post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        defaultCheckedIDList.addAll(list.map((e) => e.userID!));
      });
    }
  }

  String get checkedStrTips {
    if (checkedList.isEmpty) return '';

    final names = checkedList.values
        .map((item) {
          // Display remark if available, otherwise display nickname
          if (item is ISUserInfo) {
            return (item.remark != null && item.remark!.isNotEmpty)
                ? item.remark
                : item.nickname;
          }
          return parseName(item);
        })
        .where((name) => name != null)
        .cast<String>()
        .toList();

    if (names.length <= 2) {
      return names.join('、');
    } else if (names.length == 3) {
      return '${names[0]}、${names[1]}、${names[2]}';
    } else {
      return '${names[0]}、${names[1]} ${StrRes.nOthers.replaceAll('%s', '${names.length - 2}')}';
    }
  }

  viewSelectedContactsList() => CustomBottomSheet.show(
        body: Container(
          constraints: BoxConstraints(maxHeight: 548.h),
          child: SelectedContactsListView(),
        ),
        isDismissible: true,
      );

  selectFromMyFriend() async {
    final result = await AppNavigator.startSelectContactsFromFriends();
    if (null != result) {
      Get.back(result: result);
    }
  }

  selectFromMyGroup() async {
    final result = await AppNavigator.startSelectContactsFromGroup();
    if (null != result) {
      Get.back(result: result);
    }
  }

  // selectFromOrganization() async {
  //   final result = await ONavigator.startSelectContactsFromOrganization();
  //   if (null != result) {
  //     Get.back(result: result);
  //   }
  // }

  void selectFromSearch() {
    AppNavigator.startSelectContactsFromSearch();
  }

  void performSearch(String query) {
    searchText.value = query;
    searchResults.clear();
    if (query.isEmpty) {
      return;
    }

    final lowerQuery = query.toLowerCase();

    // Search in friend list - search by nickname, remark, and userID
    for (var friend in friendList) {
      bool match = false;

      // Search by nickname
      if (friend.nickname?.toLowerCase().contains(lowerQuery) ?? false) {
        match = true;
      }

      // Search by remark (if available)
      if (!match &&
          (friend.remark?.toLowerCase().contains(lowerQuery) ?? false)) {
        match = true;
      }

      // Search by userID
      if (!match &&
          (friend.userID?.toLowerCase().contains(lowerQuery) ?? false)) {
        match = true;
      }

      if (match) {
        searchResults.putIfAbsent(friend.userID ?? '', () => friend);
      }
    }

    // Search in recent conversations
    for (var con in conversationList) {
      if (con.showName?.toLowerCase().contains(lowerQuery) ?? false) {
        final key = con.isSingleChat ? con.userID : con.groupID;
        searchResults.putIfAbsent(key ?? '', () => con);
      }
    }
  }

  void closeSearch() {
    searchCtrl.clear();
    searchText.value = '';
    searchResults.clear();
  }

  void clearSearch() {
    searchCtrl.clear();
    searchText.value = '';
    searchResults.clear();
  }

  selectTagGroup() async {}

  confirmSelectedList() async {
    if (action == SelAction.forward || action == SelAction.recommend) {
      final sure = await Get.dialog(
          barrierColor: Colors.transparent,
          ForwardHintDialog(
            title: ex ?? '',
            checkedList: checkedList.values.toList(),
            controller: inputCtrl,
          ));
      if (sure == true) {
        Get.back(result: {
          "checkedList": checkedList.values,
          "customEx": inputCtrl.text.trim(),
        });
      }
    } else {
      if (action == SelAction.carte) {
        final sure = await CustomDialog.show(
          title: StrRes.sendCarteConfirmHint,
        );
        if (sure != true) return;
        Get.back(
            result: checkedList.values
                .map((e) => UserInfo.fromJson(e.toJson()))
                .toList());
      } else if (action == SelAction.crateGroup) {
        // Include defaultCheckedIDList + current user (who is added automatically) in the total count
        final totalSelected =
            defaultCheckedIDList.length + checkedList.length + 1;
        if (totalSelected < 3) {
          IMViews.showToast(StrRes.selectContactsMinimum.trArgs(["2"]));
          return;
        }
        // Convert checked map to List<UserInfo>
        final list = IMUtils.convertSelectContactsResultToUserInfo(checkedList);
        if (list is List<UserInfo>) {
          // Build defaultCheckedList as List<UserInfo> from default IDs if possible
          final defaultList = <UserInfo>[];
          for (final id in defaultCheckedIDList) {
            try {
              final f = friendList.firstWhere((f) => f.userID == id);
              defaultList.add(UserInfo.fromJson(f.toJson()));
            } catch (_) {}
          }
          Get.toNamed(AppRoutes.createGroup, arguments: {
            'checkedList': list,
            'defaultCheckedList': defaultList,
          });
          return;
        }
        Get.back(result: checkedList);
      } else {
        Get.back(result: checkedList);
      }
    }
  }

  confirmSelectedItem(dynamic info) async {
    if (action == SelAction.carte) {
      final sure = await CustomDialog.show(
        title: StrRes.sendCarteConfirmHint,
      );
      if (sure == true) {
        Get.back(result: UserInfo.fromJson(info.toJson()));
      }
    }
  }

  bool get enabledConfirmButton {
    // For `forward` and `addMember` actions we allow confirming when at least one contact is selected.
    // For `crateGroup` action, require 3 total selected (including current user who is added automatically).
    // For other actions, allow at least 1 selection.
    final totalSelected = defaultCheckedIDList.length + checkedList.length;
    if (action == SelAction.forward ||
        action == SelAction.addMember ||
        action == SelAction.recommend) {
      return checkedList.isNotEmpty;
    }
    if (action == SelAction.crateGroup) {
      return totalSelected + 1 >= 3; // +1 for current user added automatically
    }
    return checkedList.isNotEmpty;
  }

  Widget get checkedConfirmView =>
      isMultiModel ? CheckedConfirmView() : const SizedBox();
}
