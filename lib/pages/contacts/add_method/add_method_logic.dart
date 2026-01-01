import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/pages/contacts/add_by_search/add_by_search_logic.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';

class AddContactsMethodLogic extends GetxController {
  scan() => AppNavigator.startScan();

  addFriend() =>
      AppNavigator.startAddContactsBySearch(searchType: SearchType.user);

  Future<void> createGroup() async {
    try {
      final result = await GatewayApi.getRealNameAuthInfo();
      final status = result['status'] ?? 0;
      if (status != 2) {
        var confirm = await CustomDialog.show(
          title: StrRes.realNameAuthRequiredForGroup,
          rightText: StrRes.goToRealNameAuth,
        );
        if (confirm == true) AppNavigator.startRealNameAuth();
        return;
      }
    } catch (e) {
      var confirm = await CustomDialog.show(
        title: StrRes.realNameAuthRequiredForGroup,
        rightText: StrRes.goToRealNameAuth,
      );
      if (confirm == true) AppNavigator.startRealNameAuth();
      return;
    }

    AppNavigator.startCreateGroup();
  }

  addGroup() =>
      AppNavigator.startAddContactsBySearch(searchType: SearchType.group);
}
