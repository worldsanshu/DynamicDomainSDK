import 'package:get/get.dart';
import 'package:openim/core/controller/im_controller.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';

class GroupOnlineInfoLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final onlineInfoLogic = Get.find<OnlineInfoController>();
  final memberList = <GroupMembersInfo>[].obs;
  late GroupInfo groupInfo;
  late bool isOwnerOrAdmin;
  final showInfos = true.obs;
  final expandedGroup = ''.obs;

  @override
  void onInit() {
    groupInfo = Get.arguments['groupInfo'];
    isOwnerOrAdmin = Get.arguments['isOwnerOrAdmin'];
    super.onInit();
  }

  List<String> get currentlyOnline => onlineInfoLogic.onlineUserId;

  List<String> get onlineLast24Hours => onlineInfoLogic.onlineUserIdDay;

  List<String> get onlineLast3Days => onlineInfoLogic.onlineUserId3Day;

  List<String> get onlineLast7Days => onlineInfoLogic.onlineUserIdWeek;

  loadGroupMemberList(List<String> ids) async {
    LoadingView.singleton.wrap(asyncFunction: () async {
      try {
        final list = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
          groupID: groupInfo.groupID,
          userIDList: ids,
        );
        memberList.value = list;
        showInfos.value = false;
      } catch (e) {
        LoadingView.singleton.dismiss();
      }
    });
  }

  void changeShowInfos() {
    showInfos.value = !showInfos.value;
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
