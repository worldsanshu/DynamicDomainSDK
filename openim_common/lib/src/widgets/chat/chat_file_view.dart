import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class ChatFileView extends StatelessWidget {
  const ChatFileView({
    super.key,
    required this.message,
    required this.isISend,
    this.sendProgressStream,
    this.fileDownloadProgressView,
  });
  final Message message;
  final Stream<MsgStreamEv<int>>? sendProgressStream;
  final bool isISend;
  final Widget? fileDownloadProgressView;

  @override
  Widget build(BuildContext context) {
    final bgColor = isISend ? Colors.transparent : Styles.c_FFFFFF;
    final subTextStyle = isISend
        ? TextStyle(fontSize: 12.sp, color: Colors.white.withOpacity(0.7))
        : Styles.ts_8E9AB0_14sp;
    final borderColor =
        isISend ? Colors.white.withOpacity(0.2) : Styles.c_E8EAEF;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      width: maxWidth,
      height: 64.h,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: borderRadius(isISend),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWithMidEllipsis(
                      message.fileElem?.fileName ?? '',
                      style: isISend
                          ? TextStyle(
                              fontSize: 17.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w500)
                          : Styles.ts_0C1C33_17sp,
                      endPartLength: 8,
                    ),
                    Text(
                      IMUtils.formatBytes(message.fileElem?.fileSize ?? 0),
                      style: subTextStyle,
                    ),
                  ],
                ),
              ),
              10.horizontalSpace,
              ChatFileIconView(
                message: message,
                sendProgressStream: sendProgressStream,
                downloadProgressView: fileDownloadProgressView,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
