import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:search_keyword_text/search_keyword_text.dart';

import 'expand_chat_history_logic.dart';
import '../../../widgets/base_page.dart';

class ExpandChatHistoryPage extends StatelessWidget {
  final logic = Get.find<ExpandChatHistoryLogic>();

  ExpandChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: BasePage(
        showAppBar: true,
        title: '',
        centerTitle: true,
        showLeading: true,
        customAppBar: WechatStyleSearchBox(
          controller: logic.searchCtrl,
          focusNode: logic.focusNode,
          hintText: StrRes.search,
          enabled: true,
          autofocus: false,
          onSubmitted: (_) => logic.search(),
          onCleared: () => logic.focusNode.requestFocus(),
          margin: EdgeInsets.zero,
          backgroundColor: const Color(0xFFF8FAFC),
        ),
        body: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: logic.toChat,
              child: Container(
                height: 64.h,
                margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Styles.c_FFFFFF,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  children: [
                    AvatarView(
                      text: logic.searchResultItems.value.showName,
                      url: logic.searchResultItems.value.faceURL,
                      isGroup: logic.searchResultItems.value.conversationType !=
                          ConversationType.single,
                    ),
                    10.horizontalSpace,
                    Expanded(
                      child:
                          (logic.searchResultItems.value.showName ?? '').toText
                            ..style = Styles.ts_0C1C33_17sp,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 24.w,
                    ),
                  ],
                ),
              ),
            ),
            Obx(
              () => Expanded(
                child: logic.isSearchNotResult
                    ? _buildEmptyListView()
                    : SmartRefresher(
                        controller: logic.refreshCtrl,
                        enablePullDown: false,
                        enablePullUp: true,
                        footer: IMViews.buildFooter(),
                        onLoading: () => logic.load(),
                        child: ListView.builder(
                          itemCount: logic.searchResultItems.value.messageList
                                  ?.length ??
                              0,
                          itemBuilder: (_, index) => _buildItemView(
                            message: logic
                                .searchResultItems.value.messageList![index],
                          ),
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItemView({
    required Message message,
  }) =>
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => logic.previewMessageHistory(message),
        child: Container(
          height: 64.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          color: Styles.c_FFFFFF,
          child: Row(
            children: [
              AvatarView(
                text: message.senderNickname,
                url: message.senderFaceUrl,
              ),
              10.horizontalSpace,
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: ((message.senderNickname ?? '').toText
                              ..style = Styles.ts_0C1C33_17sp
                              ..maxLines = 1
                              ..overflow = TextOverflow.ellipsis)),
                        if (message.sendTime != null)
                          IMUtils.getChatTimeline(message.sendTime!).toText
                            ..style = Styles.ts_8E9AB0_14sp,
                      ],
                    ),
                    SearchKeywordText(
                      text: logic.calContent(message),
                      keyText: RegExp.escape(logic.searchKey),
                      style: Styles.ts_8E9AB0_14sp,
                      keyStyle: Styles.ts_0089FF_14sp,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );

  Widget _buildEmptyListView() => SizedBox(
        width: 1.sw,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            44.verticalSpace,
            StrRes.searchNotFound.toText..style = Styles.ts_8E9AB0_17sp,
          ],
        ),
      );
}
