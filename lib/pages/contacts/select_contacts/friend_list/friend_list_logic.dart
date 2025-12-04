import 'package:get/get.dart';
import 'package:openim/pages/contacts/friend_list_logic.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import '../select_contacts_logic.dart';

class SelectContactsFromFriendsLogic extends GetxController {
  final selectContactsLogic = Get.find<SelectContactsLogic>();
  final friendLogic = Get.find<FriendListLogic>();

  get friendList => friendLogic.friendList;

  searchFriend() async {
    final result = await AppNavigator.startSelectContactsFromSearchFriends();
    if (null != result) {
      Get.back(result: result);
    }
  }

  Iterable<ISUserInfo> get operableList => friendList.where(_remove);

  bool _remove(ISUserInfo info) => !selectContactsLogic.isDefaultChecked(info);
}
