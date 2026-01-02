import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class OnlineInfoController extends GetxController {
  final onlineUserId = <String>[].obs;
  final onlineUserIdDay = <String>[].obs;
  final onlineUserIdWeek = <String>[].obs;
  final onlineUserId3Day = <String>[].obs;
  final groupOnlineInfoError = false.obs;

  refreshGroupMemberOnlineInfo(String groupID) async {
    try {
      final result =
          await ChatApis.getGroupMemberOnlineInfo(groupIDS: [groupID]);
      onlineUserId.value = result.onlineUserId;
      onlineUserIdDay.value = result.onlineUserIdDay;
      onlineUserIdWeek.value = result.onlineUserIdWeek;
      onlineUserId3Day.value = result.onlineUserId3Day;
      groupOnlineInfoError.value = false;
    } catch (e) {
      groupOnlineInfoError.value = true;
    }
  }

  void clear() {
    onlineUserId.clear();
    onlineUserIdDay.clear();
    onlineUserIdWeek.clear();
    onlineUserId3Day.clear();
    groupOnlineInfoError.value = false;
  }
}
