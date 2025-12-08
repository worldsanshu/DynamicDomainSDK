import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim/widgets/base_page.dart';
import 'package:search_keyword_text/search_keyword_text.dart';

import '../../../../constants/app_color.dart';
import '../select_contacts_logic.dart';
import 'search_contacts_logic.dart';

class SelectContactsFromSearchPage extends StatelessWidget {
  final logic = Get.find<SelectContactsFromSearchLogic>();
  final selectContactsLogic = Get.find<SelectContactsLogic>();

  SelectContactsFromSearchPage({super.key});

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
                      itemBuilder: (_, index) =>
                          _buildItemView(logic.resultList.elementAt(index)),
                    )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemView(dynamic info) {
    Widget buildChild() => Ink(
          height: 64.h,
          color: Styles.c_FFFFFF,
          child: InkWell(
            onTap: selectContactsLogic.onTap(info),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  if (selectContactsLogic.isMultiModel)
                    Padding(
                      padding: EdgeInsets.only(right: 10.w),
                      child: ChatRadio(
                        checked: selectContactsLogic.isChecked(info),
                        enabled: !selectContactsLogic.isDefaultChecked(info),
                      ),
                    ),
                  AvatarView(
                    url: logic.parseFaceURL(info),
                    text: logic.parseNickname(info),
                    isGroup: info is GroupInfo,
                  ),
                  10.horizontalSpace,
                  // info.getShowName().toText..style = Styles.ts_0C1C33_17sp,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SearchKeywordText(
                          text: logic.parseNickname(info) ?? '',
                          keyText: RegExp.escape(logic.searchCtrl.text.trim()),
                          style: Styles.ts_0C1C33_17sp,
                          keyStyle: Styles.ts_0089FF_17sp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    return selectContactsLogic.isMultiModel ? Obx(buildChild) : buildChild();
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
