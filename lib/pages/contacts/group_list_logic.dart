import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/core/controller/client_config_controller.dart';
import 'package:openim/core/controller/im_controller.dart';
import 'package:openim/core/im_callback.dart';

class GroupListLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final clientConfigLogic = Get.find<ClientConfigController>();

  final RxList<GroupInfo> allGroups = <GroupInfo>[].obs;

  int offset = 0;
  final int count = 1000;

  @override
  void onInit() {
    imLogic.imSdkStatusPublishSubject.last.then((con) {
      if (con.status == IMSdkStatus.syncEnded) {
        initialLoad();
      }
    });
    initialLoad();
    super.onInit();
  }

  void initialLoad() async {
    offset = 0;
    allGroups.clear();
    final length = await _load(offset);

    if (length >= count) offset += length;
  }

  void loadMore() async {
    final length = await _load(offset);
    if (length >= count) offset += length;
  }

  Future<int> _load(int offset) async {
    try {
      final list = await OpenIM.iMManager.groupManager.getJoinedGroupListPage(
        offset: offset,
        count: count,
      );

      allGroups.addAll(list);
      return list.length;
    } catch (e) {
      print('Error loading groups: $e');
      return 0;
    }
  }

  List<GroupInfo> get joinedList =>
      allGroups.where((g) => g.ownerUserID != OpenIM.iMManager.userID).toList();

  List<GroupInfo> get createdList =>
      allGroups.where((g) => g.ownerUserID == OpenIM.iMManager.userID).toList();

  bool shouldShowMemberCount(String ownerUserID) {
    return clientConfigLogic.shouldShowMemberCount(ownerUserID: ownerUserID);
  }
}
