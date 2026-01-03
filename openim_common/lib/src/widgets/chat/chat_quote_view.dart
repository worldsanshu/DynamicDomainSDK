import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class ChatQuoteView extends StatelessWidget {
  const ChatQuoteView({
    super.key,
    required this.quoteMsg,
    this.onTap,
    this.onLongPress,
    this.senderNickname,
    this.isISend = false,
  });
  final Message quoteMsg;
  final Function(Message message)? onTap;
  final Function(Message message)? onLongPress;
  final String? senderNickname;
  final bool isISend;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => onTap?.call(quoteMsg),
        onLongPress: () => onLongPress?.call(quoteMsg),
        child: _ChatQuoteContentView(
          message: quoteMsg,
          senderNickname: senderNickname,
          isISend: isISend,
        ),
      );
}

class _ChatQuoteContentView extends StatelessWidget {
  const _ChatQuoteContentView({
    required this.message,
    this.senderNickname,
    this.isISend = false,
  });
  final Message message;
  final String? senderNickname;
  final bool isISend;

  // ignore: unused_field
  final _decoder = const JsonDecoder();

  @override
  Widget build(BuildContext context) {
    String name = senderNickname ?? message.senderNickname ?? '';
    String? content;
    Widget? mediaChild;

    final bgColor = isISend
        ? Colors.white.withOpacity(0.15)
        : Colors.black.withOpacity(0.05);
    final barColor = isISend ? Colors.white : Styles.c_0089FF;
    final nameColor =
        isISend ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.8);
    final contentColor =
        isISend ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.5);

    try {
      if (message.isTextType) {
        content = message.textElem!.content;
      } else if (message.isAtTextType) {
        content = message.atTextElem?.text;
        message.atTextElem?.atUsersInfo?.forEach((element) {
          content = content?.replaceFirst(
              element.atUserID ?? "", element.groupNickname ?? "");
        });
      } else if (message.isPictureType) {
        final picture = message.pictureElem;
        if (null != picture) {
          final url =
              picture.snapshotPicture?.url ?? picture.sourcePicture?.url;
          if (IMUtils.isUrlValid(url)) {
            mediaChild = ClipRRect(
              borderRadius: BorderRadius.circular(2.r),
              child: ImageUtil.networkImage(
                url: url!,
                width: 32.w,
                height: 32.w,
                fit: BoxFit.cover,
              ),
            );
          }
        }
      } else if (message.isVideoType) {
        final video = message.videoElem;
        if (null != video) {
          final url = video.snapshotUrl;
          if (IMUtils.isUrlValid(url)) {
            mediaChild = Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2.r),
                  child: ImageUtil.networkImage(
                    url: url!,
                    width: 32.w,
                    height: 32.w,
                    fit: BoxFit.cover,
                  ),
                ),
                Icon(Icons.play_circle_fill_rounded,
                    size: 14.w, color: Colors.white.withOpacity(0.8)),
              ],
            );
          }
        }
      } else if (message.isVoiceType) {
        final duration = message.soundElem?.duration ?? 0;
        final random = math.Random(duration);
        mediaChild = Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(12, (index) {
            final height = 4.h + random.nextDouble() * 10.h;
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 0.5.w),
              width: 1.5.w,
              height: height,
              decoration: BoxDecoration(
                color: contentColor,
                borderRadius: BorderRadius.circular(1.r),
              ),
            );
          }),
        );
      } else if (message.isCardType) {
        final card = message.cardElem;
        content = card?.nickname;
        mediaChild = AvatarView(
          width: 24.w,
          height: 24.w,
          url: card?.faceURL,
          text: card?.nickname,
          isCircle: true,
        );
      } else if (message.isFileType) {
        final file = message.fileElem;
        if (null != file) {
          content = file.fileName ?? '';
          mediaChild = Icon(Icons.insert_drive_file_rounded,
              size: 20.w, color: contentColor);
        }
      } else if (message.isQuoteType) {
        content = message.quoteElem?.text;
      } else if (message.isMergerType) {
        content = StrRes.chatRecord;
      } else if (message.isCustomFaceType) {
        content = '[${StrRes.emoji}]';
      } else if (message.isCustomType) {
        if (message.isTagTextType) {
          content = message.tagContent?.textElem?.content;
        }
      } else if (message.isRevokeType) {
        content = StrRes.quoteContentBeRevoked;
      } else if (message.isNotificationType) {}
    } catch (e, s) {
      Logger.print('$e   $s');
    }

    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Vertical Bar
            Container(
              width: 2.w,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(1.r),
              ),
            ),
            8.horizontalSpace,
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sender Name (Bold)
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: nameColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  2.verticalSpace,
                  // Quoted Content
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (mediaChild != null) ...[
                        mediaChild,
                        if (content != null) 6.horizontalSpace,
                      ],
                      if (content != null)
                        Flexible(
                          child: Text(
                            content!.fixAutoLines(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: contentColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
