import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/widgets/friend_item_view.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim/widgets/base_page.dart';

import '../../../../../constants/app_color.dart';
import '../../select_contacts_logic.dart';
import 'search_friend_logic.dart';

class SelectContactsFromSearchFriendsPage extends StatelessWidget {
  final logic = Get.find<SelectContactsFromSearchFriendsLogic>();
  final selectContactsLogic = Get.find<SelectContactsLogic>();

  SelectContactsFromSearchFriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: BasePage(
        showAppBar: true,
        title: StrRes.search,
        centerTitle: false,
        showLeading: true,
        customAppBar: WechatStyleSearchBox(
          controller: logic.searchCtrl,
          focusNode: logic.focusNode,
          hintText: StrRes.search,
          enabled: true,
          autofocus: true,
          onSubmitted: (_) => logic.search(),
          onCleared: () => logic.focusNode.requestFocus(),
          margin: EdgeInsets.zero,
          backgroundColor: const Color(0xFFFFFFFF),
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() => logic.isSearchNotResult
                  ? _emptyListView
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: logic.resultList.length,
                      itemBuilder: (_, index) => Obx(() {
                        final friend = logic.resultList[index];
                        final showDivider =
                            index != logic.resultList.length - 1;
                        final checked = selectContactsLogic.isChecked(friend);
                        final enabled =
                            !selectContactsLogic.isDefaultChecked(friend);
                        return FriendItemView(
                          info: friend,
                          showDivider: showDivider,
                          checked: checked,
                          enabled: enabled,
                          keyText: logic.searchCtrl.text.trim(),
                          onTap: selectContactsLogic.onTap(friend),
                        );
                      }),
                    )),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _emptyListView => SizedBox(
        width: 1.sw,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 157.verticalSpace,
            // ImageRes.blacklistEmpty.toImage
            //   ..width = 120.w
            //   ..height = 120.h,
            // 22.verticalSpace,
            44.verticalSpace,
            StrRes.searchNotFound.toText..style = Styles.ts_8E9AB0_17sp,
          ],
        ),
      );
}
