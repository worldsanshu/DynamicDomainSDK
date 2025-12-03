import 'package:get/get.dart';
import 'package:openim/pages/report_submit/report_submit_logic.dart';

class ReportSubmitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReportSubmitLogic());
  }
}
