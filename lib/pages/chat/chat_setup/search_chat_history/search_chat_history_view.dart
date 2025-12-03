// ignore_for_file: must_be_immutable

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:search_keyword_text/search_keyword_text.dart';
import 'package:sprintf/sprintf.dart';

import 'search_chat_history_logic.dart';
import '../../../../widgets/base_page.dart';

class SearchChatHistoryPage extends StatelessWidget {
  final logic = Get.find<SearchChatHistoryLogic>();
  DateTime? dateTime;

  SearchChatHistoryPage({super.key, this.dateTime});

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: BasePage(
        showAppBar: true,
        centerTitle: false,
        showLeading: true,
        customAppBar: Container(
          height: 140.h,
          //padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              8.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: WechatStyleSearchBox(
                      controller: logic.searchCtrl,
                      focusNode: logic.focusNode,
                      hintText: StrRes.search,
                      enabled: true,
                      autofocus: true,
                      onChanged: logic.onChanged,
                      onSubmitted: (_) => logic.search(),
                      onCleared: () {
                        logic.clearInput();
                        logic.focusNode.requestFocus();
                      },
                      margin: EdgeInsets.zero,
                      backgroundColor: const Color(0xFFFFFFFF),
                      searchIconColor: AppColor.iconColor,
                    ),
                  ),
                  8.horizontalSpace,
                  // Calendar button
                  GestureDetector(
                    onTap: () => datePicker(context),
                    child: Container(
                      width: 30.w,
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F42FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedCalendar03,
                        size: 18.w,
                        color: AppColor.iconColor,
                      ),
                    ),
                  ),
                ],
              ),
              8.verticalSpace,
            ],
          ),
        ),
        body: _buildContentContainer(),
      ),
    );
  }

  Widget _buildContentContainer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Builder(
        builder: (context) => Obx(() => logic.isNotKey && logic.isNotDate
            ? SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: 20.h),
                child: _defaultView(context),
              )
            : (logic.isSearchNotResult
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 20.h),
                    child: _emptyListView,
                  )
                : _resultView(context))),
      ),
    );
  }

  Widget _buildItemView(Message message, BuildContext ctx) {
    return AnimationConfiguration.staggeredList(
      position: logic.messageList.indexOf(message),
      duration: const Duration(milliseconds: 400),
      child: SlideAnimation(
        curve: Curves.easeOutCubic,
        verticalOffset: 40.0,
        child: FadeInAnimation(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.06),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
              border: Border.all(
                color: const Color(0xFFF3F4F6),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16.r),
              child: InkWell(
                onTap: () => logic.previewMessageHistory(message),
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  child: Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9CA3AF).withOpacity(0.1),
                              offset: const Offset(0, 0),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: AvatarView(
                          url: message.senderFaceUrl,
                          text: message.senderNickname,
                          isCircle: true,
                        ),
                      ),
                      16.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    message.senderNickname ?? '',
                                    style: TextStyle(
                                      fontFamily: 'FilsonPro',
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF374151),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  IMUtils.getChatTimeline(
                                      message.sendTime ?? 0),
                                  style: TextStyle(
                                    fontFamily: 'FilsonPro',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                            8.verticalSpace,
                            SearchKeywordText(
                              text: logic.calContent(message),
                              keyText: RegExp.escape(logic.searchKey.value),
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF6B7280),
                              ),
                              keyStyle: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4F42FF),
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultView(BuildContext ctx) => Container(
        padding: EdgeInsets.only(top: 16.h),
        height: double.infinity,
        child: SmartRefresher(
          controller: logic.refreshController,
          footer: IMViews.buildFooter(),
          enablePullDown: false,
          enablePullUp: true,
          onLoading: logic.load,
          child: AnimationLimiter(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              itemCount: logic.messageList.length,
              itemBuilder: (_, index) =>
                  _buildItemView(logic.messageList.elementAt(index), _),
            ),
          ),
        ),
      );

  Widget _defaultView(BuildContext ctx) => AnimationLimiter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 450),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              curve: Curves.easeOutQuart,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              20.verticalSpace,
              _buildSectionTitle(StrRes.quicklyFindChatHistory),
              _buildQuickActionsSection(),
              24.verticalSpace,
            ],
          ),
        ),
      );

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'FilsonPro',
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF212121),
          shadows: [
            Shadow(
              color: Colors.white.withOpacity(0.9),
              offset: const Offset(0.5, 0.5),
              blurRadius: 0.5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: const Offset(-1, -1),
            blurRadius: 4,
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            const Color(0xFFF8FAFC),
          ],
          stops: const [0.05, 0.3],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Text(
              StrRes.chatContent,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF374151),
                letterSpacing: 0.3,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 0.5),
                    blurRadius: 1,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              bottom: 20.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionButton(
                  hugeIcon: HugeIcons.strokeRoundedImage02,
                  label: StrRes.picture,
                  color: const Color(0xFF34D399),
                  onTap: logic.searchChatHistoryPicture,
                  index: 1,
                ),
                _buildQuickActionButton(
                  hugeIcon: HugeIcons.strokeRoundedVideoReplay,
                  label: StrRes.video,
                  color: const Color(0xFFF87171),
                  onTap: logic.searchChatHistoryVideo,
                  index: 2,
                ),
                _buildQuickActionButton(
                  hugeIcon: HugeIcons.strokeRoundedFile02,
                  label: StrRes.file,
                  color: const Color(0xFFFBBF24),
                  onTap: logic.searchChatHistoryFile,
                  index: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required List<List<dynamic>> hugeIcon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required int index,
  }) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 400),
      child: SlideAnimation(
        curve: Curves.easeOutCubic,
        verticalOffset: 40.0,
        child: FadeInAnimation(
          child: GestureDetector(
            onTap: onTap,
            child: Column(
              children: [
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9CA3AF).withOpacity(0.08),
                        offset: const Offset(0, 3),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.95),
                        offset: const Offset(0, -1),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFF3F4F6),
                      width: 0.5,
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColor.iconColor.withOpacity(0.12),
                          AppColor.iconColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: hugeIcon,
                        size: 24.w,
                        color: AppColor.iconColor,
                      ),
                    ),
                  ),
                ),
                8.verticalSpace,
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 0.5),
                        blurRadius: 1,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> datePicker(BuildContext ctx) async {
    logic.clearDateTime();
    final DateTime? picked = await showDialog<DateTime>(
      context: ctx,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                height: MediaQuery.of(context).size.height / 1.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF4F42FF),
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: DatePickerDialog(
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                      helpText: StrRes.selectSearchDate,
                      cancelText: StrRes.cancel,
                      confirmText: StrRes.confirm,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (picked != null && picked != logic.dateTime.value) {
      logic.updateSearchTime(picked);
      logic.searchByTime();
    }
  }

  Widget get _emptyListView => AnimationConfiguration.staggeredList(
        position: 0,
        duration: const Duration(milliseconds: 400),
        child: SlideAnimation(
          curve: Curves.easeOutCubic,
          verticalOffset: 40.0,
          child: FadeInAnimation(
            child: Container(
              width: 1.sw,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  40.verticalSpace,
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9CA3AF).withOpacity(0.06),
                          offset: const Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFF3F4F6),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          size: 48.w,
                          color: const Color(0xFF6B7280),
                        ),
                        16.verticalSpace,
                        logic.searchCtrl.text.isEmpty
                            ? Text(
                                StrRes.noMessagesOnThatDay,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              )
                            : Text(
                                sprintf(StrRes.notFoundChatHistory,
                                    [logic.searchKey.value]),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
