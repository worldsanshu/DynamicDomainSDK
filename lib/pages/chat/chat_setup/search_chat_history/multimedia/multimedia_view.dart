// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'multimedia_logic.dart';
import '../../../../../widgets/gradient_scaffold.dart';

class ChatHistoryMultimediaPage extends StatelessWidget {
  final logic = Get.find<ChatHistoryMultimediaLogic>();

  ChatHistoryMultimediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: logic.isPicture ? StrRes.picture : StrRes.video,
      showBackButton: true,
      body: Obx(() => SmartRefresher(
            controller: logic.refreshController,
            onRefresh: logic.onRefresh,
            onLoading: logic.onLoad,
            header: IMViews.buildHeader(),
            footer: IMViews.buildFooter(),
            child: _buildListView(),
          )),
    );
  }

  Widget _buildListView() {
    final mediaMessages = logic.messageList.reversed.toList();

    return AnimationLimiter(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        itemCount: logic.groupMessage.length,
        itemBuilder: (_, index) {
          var entry =
              logic.groupMessage.entries.toList().reversed.elementAt(index);
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              verticalOffset: 40.0,
              child: FadeInAnimation(
                curve: Curves.easeOutCubic,
                child: MultimediaItemWidget(
                  list: entry.value,
                  label: entry.key,
                  isVideo: !logic.isPicture,
                  onTap: (message) {
                    final currentIndex = mediaMessages.indexOf(message);
                    IMUtils.previewMediaFile(
                        context: Get.context!,
                        currentIndex: currentIndex,
                        mediaMessages: mediaMessages,
                        onOperate: (type) {
                          if (type == OperateType.forward) {
                            logic.chatLogic.forward(message);
                          }
                        }
                    );
                  },
                  snapshotUrl: logic.getSnapshotUrl,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MultimediaItemWidget extends StatelessWidget {
  const MultimediaItemWidget({
    super.key,
    required this.list,
    required this.label,
    required this.snapshotUrl,
    this.isVideo = false,
    this.onTap,
  });
  final String label;
  final List<Message> list;
  final Function(Message message)? onTap;
  final String Function(Message message) snapshotUrl;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
              letterSpacing: 0.3,
            ),
          ),
        ),
        AnimationLimiter(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.0,
              crossAxisCount: 3,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
            ),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (_, index) => AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 400),
              columnCount: 3,
              child: ScaleAnimation(
                curve: Curves.easeOutCubic,
                child: FadeInAnimation(
                  child: _buildItemView(list.elementAt(index)),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildItemView(Message message) => GestureDetector(
        onTap: () => onTap?.call(message),
        child: Hero(
          tag: message.clientMsgID!,
          placeholderBuilder:
              (BuildContext context, Size heroSize, Widget child) => child,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                width: 1,
                color: const Color(0xFFE5E7EB),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.08),
                  blurRadius: 8.r,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ImageUtil.networkImage(
                    url: snapshotUrl.call(message),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  if (isVideo)
                    Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        CupertinoIcons.play_fill,
                        color: Colors.white,
                        size: 22.w,
                      ),
                    ),
                  Positioned(
                    top: 6.h,
                    right: 6.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        isVideo ? '▶' : '📷',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
