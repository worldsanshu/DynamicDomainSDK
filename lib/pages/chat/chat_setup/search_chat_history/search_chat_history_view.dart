// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim/widgets/gradient_scaffold.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:search_keyword_text/search_keyword_text.dart';
import 'package:sprintf/sprintf.dart';

import 'search_chat_history_logic.dart';

class SearchChatHistoryPage extends StatelessWidget {
  final logic = Get.find<SearchChatHistoryLogic>();
  DateTime? dateTime;

  SearchChatHistoryPage({super.key, this.dateTime});

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: GradientScaffold(
        title: StrRes.globalSearchChatHistory,
        showBackButton: true,
        searchBox: _buildSearchBox(context),
        body: _buildContentContainer(),
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    return WechatStyleSearchBox(
      controller: logic.searchCtrl,
      focusNode: logic.focusNode,
      enabled: true,
      hintText: StrRes.search,
      onSubmitted: (_) => logic.search(),
      onChanged: (v) {
        logic.onChanged(v);
      },
      onCleared: () {
        logic.clearInput();
        logic.focusNode.requestFocus();
      },
      suffix: GestureDetector(
        onTap: () => datePicker(context),
        behavior: HitTestBehavior.translucent,
        child: Container(
          width: 28.w,
          height: 28.h,
          margin: EdgeInsets.only(left: 8.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedCalendar03,
              size: 18.w,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentContainer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      // decoration removed as it is handled by the parent container
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
              _buildSectionTitle(StrRes.quicklyFindChatHistory),
              _buildQuickActionsSection(),
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
    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ClaymorphismDatePicker(
          title: StrRes.selectSearchDate,
          initialDate: DateTime.now(),
          minDate: DateTime(2000),
          maxDate: DateTime.now(),
          icon: CupertinoIcons.calendar,
          onConfirm: (DateTime date) {
            Get.back(result: date);
          },
          onCancel: () => Get.back(),
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
