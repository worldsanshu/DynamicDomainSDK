import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/widgets/group_item.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim/widgets/base_page.dart';

import 'search_group_logic.dart';

class SearchGroupPage extends StatelessWidget {
  final logic = Get.find<SearchGroupLogic>();

  SearchGroupPage({super.key});

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
          enabled: false,
          autofocus: true,
          onSubmitted: (_) => logic.search(),
          onCleared: () => logic.focusNode.requestFocus(),
          margin: EdgeInsets.zero,
          backgroundColor: const Color(0xFFFFFFFF),
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(
                () => logic.isSearchNotResult
                    ? _emptyListView
                    : ListView.builder(
                        itemCount: logic.resultList.length,
                        itemBuilder: (_, index) => GroupItemView(
                          info: logic.resultList[index],
                          showMemberCount: logic.shouldShowMemberCount(
                              logic.resultList[index].ownerUserID!),
                          showDivider: index != logic.resultList.length - 1,
                          keyText: logic.searchCtrl.text.trim(),
                          onTap: () => logic.toGroupChat(
                            logic.resultList[index],
                          ),
                        ),
                      ),
              ),
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
