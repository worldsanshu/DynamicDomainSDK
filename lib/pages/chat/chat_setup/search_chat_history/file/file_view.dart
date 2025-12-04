// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../../widgets/file_download_progress.dart';
import 'file_logic.dart';
import '../../../../../widgets/base_page.dart';

class ChatHistoryFilePage extends StatelessWidget {
  final logic = Get.find<ChatHistoryFileLogic>();

  ChatHistoryFilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      title: StrRes.file,
      centerTitle: false,
      showLeading: true,
      body: Obx(() => Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.08),
                  blurRadius: 12.r,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SmartRefresher(
              controller: logic.refreshController,
              onRefresh: logic.onRefresh,
              onLoading: logic.onLoad,
              header: IMViews.buildHeader(),
              footer: IMViews.buildFooter(),
              child: AnimationLimiter(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  itemCount: logic.messageList.length,
                  itemBuilder: (_, index) =>
                      AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 400),
                    child: SlideAnimation(
                      verticalOffset: 40.0,
                      child: FadeInAnimation(
                        curve: Curves.easeOutCubic,
                        child: _buildItemView(
                            logic.messageList.reversed.elementAt(index)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )),
    );
  }

  Widget _buildItemView(Message message) => GestureDetector(
        onTap: () => logic.viewFile(message),
        behavior: HitTestBehavior.translucent,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9CA3AF).withOpacity(0.06),
                blurRadius: 6.r,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFF3F4F6),
              width: 1,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: ChatFileIconView(
                    message: message,
                    downloadProgressView: FileDownloadProgressView(message),
                  ),
                ),
              ),
              16.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWithMidEllipsis(
                      message.fileElem!.fileName!,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    8.verticalSpace,
                    Row(
                      children: [
                        Text(
                          IMUtils.formatBytes(message.fileElem!.fileSize!),
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        10.horizontalSpace,
                        Expanded(
                            child: Text(
                          message.senderNickname!,
                          overflow: TextOverflow.ellipsis, // 超出显示省略号
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280),
                          ),
                        )),
                        10.horizontalSpace,
                        Text(
                          IMUtils.getChatTimeline(message.sendTime!),
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              12.horizontalSpace,
              Icon(
                CupertinoIcons.cloud_download,
                color: const Color(0xFFFBBF24),
                size: 18.w,
              ),
            ],
          ),
        ),
      );
}
