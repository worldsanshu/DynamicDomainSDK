import 'package:get/get.dart';

import 'invite_code_logic.dart';

class InviteCodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InviteCodeLogic());
  }
}
