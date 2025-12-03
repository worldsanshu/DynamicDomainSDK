import 'package:get/get.dart';

import 'group_online_info_logic.dart';

class GroupOnlineInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GroupOnlineInfoLogic());
  }
}
