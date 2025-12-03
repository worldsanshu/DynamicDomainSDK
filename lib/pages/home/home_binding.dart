import 'package:get/get.dart';

import '../contacts/contacts_logic.dart';
import '../contacts/group_list_logic.dart';
import '../conversation/conversation_logic.dart';
import '../global_search/global_search_logic.dart';
import '../mine/mine_logic.dart';
import '../workbench/workbench_logic.dart';
import 'home_logic.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Use Get.put() to create HomeLogic immediately and ensure it's a singleton
    // This prevents race conditions where multiple controllers try to Get.find<HomeLogic>()
    // at the same time during first login, which could create multiple instances with Get.lazyPut()
    Get.put(HomeLogic());
    Get.lazyPut(() => ConversationLogic());
    Get.lazyPut(() => ContactsLogic());
    Get.lazyPut(() => GroupListLogic());
    Get.lazyPut(() => GlobalSearchLogic());
    Get.lazyPut(() => MineLogic());
    Get.lazyPut(() => WorkbenchLogic());
  }
}
