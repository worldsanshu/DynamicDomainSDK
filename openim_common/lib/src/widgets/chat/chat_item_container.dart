// ignore_for_file: unnecessary_this

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class ChatItemContainer extends StatelessWidget {
  const ChatItemContainer({
    super.key,
    required this.id,
    this.leftFaceUrl,
    this.rightFaceUrl,
    this.leftNickname,
    this.rightNickname,
    this.timelineStr,
    this.timeStr,
    required this.isBubbleBg,
    required this.isISend,
    required this.isPrivateChat,
    required this.isMultiSelModel,
    required this.isChecked,
    required this.hasRead,
    required this.isSending,
    required this.isSendFailed,
    this.ignorePointer = false,
    this.showLeftNickname = true,
    this.showRightNickname = false,
    required this.readingDuration,
    this.menus,
    required this.child,
    this.quoteView,
    this.readStatusView,
    this.voiceReadStatusView,
    this.bottomInfoView,
    this.popupMenuController,
    this.sendStatusStream,
    this.onTapLeftAvatar,
    this.onTapRightAvatar,
    this.onLongPressLeftAvatar,
    this.onLongPressRightAvatar,
    this.onRadioChanged,
    this.onStartDestroy,
    this.onFailedToResend,
    this.shouldShowNickname = true,
  });
  final String id;
  final String? leftFaceUrl;
  final String? rightFaceUrl;
  final String? leftNickname;
  final String? rightNickname;
  final String? timelineStr;
  final String? timeStr;
  final bool isBubbleBg;
  final bool isISend;
  final bool isPrivateChat;
  final bool isMultiSelModel;
  final bool isChecked;
  final bool hasRead;
  final bool isSending;
  final bool isSendFailed;
  final bool ignorePointer;
  final bool showLeftNickname;
  final bool showRightNickname;
  final int readingDuration;
  final List<MenuInfo>? menus;
  final Widget child;
  final Widget? quoteView;
  final Widget? readStatusView;
  final Widget? voiceReadStatusView;
  final Widget? bottomInfoView;
  final CustomPopupMenuController? popupMenuController;
  final Stream<MsgStreamEv<bool>>? sendStatusStream;
  final Function()? onTapLeftAvatar;
  final Function()? onTapRightAvatar;
  final Function()? onLongPressLeftAvatar;
  final Function()? onLongPressRightAvatar;
  final Function(bool checked)? onRadioChanged;
  final Function()? onStartDestroy;
  final Function()? onFailedToResend;
  final bool shouldShowNickname;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: this.isPrivateChat
          ? null
          : (this.isMultiSelModel
              ? () => this.onRadioChanged?.call(!this.isChecked)
              : null),
      child: IgnorePointer(
        ignoring: this.ignorePointer || this.isMultiSelModel,
        child: Column(
          children: [
            if (null != this.timelineStr)
              ChatTimelineView(
                timeStr: this.timelineStr!,
                margin: EdgeInsets.only(bottom: 20.h, top: 10.h),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (this.isMultiSelModel)
                  Container(
                    height: 44.w,
                    margin: EdgeInsets.only(right: 10.w),
                    child: ChatRadio(checked: this.isChecked),
                  ),
                Expanded(
                    child: this.isISend
                        ? _buildRightView(context)
                        : _buildLeftView(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildView(BuildContext context, BubbleType type) {
    final bubbleContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (null != this.quoteView) this.quoteView!,
        this.child,
      ],
    );

    final bubbleChild = this.isBubbleBg
        ? ChatBubble(
            bubbleType: type,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 0.7.sw),
              child: bubbleContent,
            ),
          )
        : bubbleContent;

    return RepaintBoundary(
      child: Builder(
        builder: (ctx) {
          // If menus is null or empty, just show the child without popup menu
          if (this.menus == null || this.menus!.isEmpty) {
            return bubbleChild;
          }

          // Show message overlay on long press
          return GestureDetector(
            onLongPress: () async {
              final boundary =
                  ctx.findAncestorRenderObjectOfType<RenderRepaintBoundary>();
              if (boundary != null) {
                await MessageOverlayHelper.show(
                  context: ctx,
                  captureBoundary: boundary,
                  isISend: this.isISend,
                  menus: this.menus ?? allMenus,
                );
              }
            },
            child: bubbleChild,
          );
        },
      ),
    );
  }

  List<MenuInfo> get allMenus => [
        MenuInfo(
          icon: ImageRes.menuCopy,
          text: StrRes.menuCopy,
          onTap: () {},
        ),
        MenuInfo(
          icon: ImageRes.menuDel,
          text: StrRes.menuDel,
          onTap: () {},
        ),
        MenuInfo(
          icon: ImageRes.menuForward,
          text: StrRes.menuForward,
          onTap: () {},
        ),
        MenuInfo(
          icon: ImageRes.menuReply,
          text: StrRes.menuReply,
          onTap: () {},
        ),
        MenuInfo(
          icon: ImageRes.menuMulti,
          text: StrRes.menuMulti,
          onTap: () {},
        ),
        MenuInfo(
          icon: ImageRes.menuRevoke,
          text: StrRes.menuRevoke,
          onTap: () {},
        ),
        MenuInfo(
          icon: ImageRes.menuAddFace,
          text: StrRes.menuAdd,
          onTap: () {},
        ),
      ];

  Widget _buildLeftView(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AvatarView(
              width: 44.w,
              height: 44.h,
              textStyle: Styles.ts_FFFFFF_14sp_medium,
              url: this.leftFaceUrl,
              text: this.leftNickname,
              onTap: this.onTapLeftAvatar,
              onLongPress: this.onLongPressLeftAvatar,
              isCircle: true,
            ),
            5.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (this.showLeftNickname &&
                    this.leftNickname != null &&
                    this.leftNickname!.isNotEmpty &&
                    _shouldShowLeftNickname()) ...[
                  Row(
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: 100.w),
                        margin: EdgeInsets.only(right: 6.w),
                        child: Text(
                          this.leftNickname!,
                          style: Styles.ts_8E9AB0_12sp,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (this.timeStr != null)
                        Text(this.timeStr!, style: Styles.ts_8E9AB0_12sp),
                    ],
                  ),
                  2.verticalSpace,
                ],
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildChildView(context, BubbleType.receiver),
                    //  / 4.horizontalSpace,
                    if (!this.isMultiSelModel)
                      ChatDestroyAfterReadingView(
                        hasRead: this.hasRead,
                        isPrivateChat: this.isPrivateChat,
                        readingDuration: this.readingDuration,
                        onStartDestroy: this.onStartDestroy,
                      ),
                    // if (null != this.voiceReadStatusView)
                    //   this.voiceReadStatusView!,
                  ],
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    final offset = Tween<Offset>(
                            begin: const Offset(0, -0.1), end: Offset.zero)
                        .animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: offset, child: child),
                    );
                  },
                  child: this.bottomInfoView == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: this.bottomInfoView,
                        ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildRightView(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (this.showRightNickname &&
                    this.rightNickname != null &&
                    this.rightNickname!.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: 100.w),
                        margin: EdgeInsets.only(right: 6.w),
                        child: Text(
                          this.rightNickname!,
                          style: Styles.ts_8E9AB0_12sp,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (this.timeStr != null)
                        Text(this.timeStr!, style: Styles.ts_8E9AB0_12sp),
                    ],
                  ),
                  2.verticalSpace,
                ],
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!this.isMultiSelModel && this.isSendFailed)
                      ChatSendFailedView(
                        id: this.id,
                        isISend: this.isISend,
                        onFailedToResend: this.onFailedToResend,
                        isFailed: this.isSendFailed,
                        stream: this.sendStatusStream,
                      ),
                    if (!this.isMultiSelModel)
                      ChatDestroyAfterReadingView(
                        hasRead: this.hasRead,
                        isPrivateChat: this.isPrivateChat,
                        readingDuration: this.readingDuration,
                        onStartDestroy: this.onStartDestroy,
                      ),
                    if (!this.isMultiSelModel && this.isSending)
                      ChatDelayedStatusView(isSending: this.isSending),
                    4.horizontalSpace,
                    _buildChildView(context, BubbleType.send),
                  ],
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    final offset = Tween<Offset>(
                            begin: const Offset(0, -0.1), end: Offset.zero)
                        .animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: offset, child: child),
                    );
                  },
                  child: this.bottomInfoView == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: this.bottomInfoView,
                        ),
                ),
                if (null != this.readStatusView) this.readStatusView!,
              ],
            ),
            // 5.horizontalSpace,
            // AvatarView(
            //   width: 44.w,
            //   height: 44.h,
            //   textStyle: Styles.ts_FFFFFF_14sp_medium,
            //   url: this.rightFaceUrl,
            //   text: this.rightNickname,
            //   onTap: this.onTapRightAvatar,
            //   onLongPress: this.onLongPressRightAvatar,
            //   isCircle: true,
            // ),
          ],
        ),
      );

  bool _shouldShowLeftNickname() {
    if (!this.shouldShowNickname) {
      return false;
    }
    if (this.timelineStr != null) {
      return true;
    }
    return true;
  }
}
