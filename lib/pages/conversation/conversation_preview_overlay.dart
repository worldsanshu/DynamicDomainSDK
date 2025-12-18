import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class ConversationPreviewOverlay extends StatelessWidget {
  final ConversationInfo conversationInfo;
  final List<Message> messages;
  final VoidCallback onTapPreview;

  const ConversationPreviewOverlay({
    super.key,
    required this.conversationInfo,
    required this.messages,
    required this.onTapPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.4),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  onTapPreview();
                },
                child: _buildPreviewCard(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      constraints: BoxConstraints(
        maxHeight: 520.h,
        maxWidth: 400.w,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 50,
            spreadRadius: 0,
            offset: const Offset(0, 25),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.98),
                  Colors.white.withOpacity(0.92),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                _buildMessageList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AvatarView(
              url: conversationInfo.faceURL,
              text: conversationInfo.showName,
              width: 52.w,
              height: 52.w,
              isCircle: true,
            ),
          ),
          16.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversationInfo.showName ?? '',
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                2.verticalSpace,
                Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                    6.horizontalSpace,
                    Text(
                      '${messages.length} recent ${messages.length == 1 ? 'message' : 'messages'}',
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (messages.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 40.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.chat_bubble_2_fill,
                size: 40.w,
                color: const Color(0xFFD1D5DB),
              ),
            ),
            20.verticalSpace,
            Text(
              'No new messages',
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
            8.verticalSpace,
            Text(
              'Your conversation history will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 14.sp,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      );
    }

    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          // Check if this is the first unread message from the partner
          final isUnread = message.isRead == false &&
              message.sendID != OpenIM.iMManager.userID;
          return _buildMessageItem(context, message, isUnread);
        },
      ),
    );
  }

  Widget _buildMessageItem(
      BuildContext context, Message message, bool isUnread) {
    final isMyMessage = message.sendID == OpenIM.iMManager.userID;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMyMessage) ...[
            AvatarView(
              url: message.senderFaceUrl,
              text: message.senderNickname,
              width: 28.w,
              height: 28.w,
              isCircle: true,
            ),
            8.horizontalSpace,
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMyMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMyMessage && messages.length > 1)
                  Padding(
                    padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
                    child: Text(
                      message.senderNickname ?? '',
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9CA3AF),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: isMyMessage
                            ? LinearGradient(
                                colors: [
                                  primaryColor,
                                  primaryColor.withOpacity(0.85),
                                ],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              )
                            : LinearGradient(
                                colors: [
                                  const Color(0xFFF3F4F6),
                                  const Color(0xFFE5E7EB),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18.r),
                          topRight: Radius.circular(18.r),
                          bottomLeft: Radius.circular(isMyMessage ? 18.r : 4.r),
                          bottomRight:
                              Radius.circular(isMyMessage ? 4.r : 18.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isMyMessage
                                ? primaryColor.withOpacity(0.2)
                                : Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _getMessageContent(message),
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: isMyMessage
                              ? Colors.white
                              : const Color(0xFF1F2937),
                          height: 1.3,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isUnread)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF87171),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
                1.verticalSpace,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Text(
                    IMUtils.getChatTimeline(message.sendTime!),
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMyMessage) ...[
            8.horizontalSpace,
            AvatarView(
              url: message.senderFaceUrl,
              text: message.senderNickname,
              width: 28.w,
              height: 28.w,
              isCircle: true,
            ),
          ],
        ],
      ),
    );
  }

  String _getMessageContent(Message message) {
    switch (message.contentType) {
      case MessageType.text:
        return message.textElem?.content ?? '';
      case MessageType.picture:
        return '[${StrRes.picture}]';
      case MessageType.voice:
        return '[${StrRes.voice}]';
      case MessageType.video:
        return '[${StrRes.video}]';
      case MessageType.file:
        return '[${StrRes.file}]';
      case MessageType.atText:
        return message.atTextElem?.text ?? '';
      case MessageType.card:
        return '[${StrRes.carte}]';
      default:
        return '[Message]';
    }
  }
}
