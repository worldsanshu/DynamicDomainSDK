// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPreviewMergeMsgView extends StatefulWidget {
  const ChatPreviewMergeMsgView(
      {super.key, required this.messageList, required this.title});

  final List<Message> messageList;
  final String title;

  @override
  State<ChatPreviewMergeMsgView> createState() =>
      _ChatPreviewMergeMsgViewState();
}

class _ChatPreviewMergeMsgViewState extends State<ChatPreviewMergeMsgView> {
  final FocusNode focusNode = FocusNode();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final _currentPlayClientMsgID = ''.obs;
  String title = '';

  @override
  void initState() {
    title = widget.title;

    // Remove any existing suffix pattern like " (Chat Records)" or " (聊天记录)"
    // This handles language switching correctly
    final suffixPattern = RegExp(r'\s*\([^)]+\)\s*$');
    title = title.replaceAll(suffixPattern, '');

    // Remove all known language variants of chatRecord (with or without parentheses)
    final knownSuffixes = [
      'Chat Records', // English
      '聊天记录', // Chinese
      'chatRecord', // Fallback
    ];

    for (final suffix in knownSuffixes) {
      if (title.endsWith(suffix)) {
        title = title.substring(0, title.length - suffix.length).trim();
        break;
      }
      // Also try with space before suffix
      if (title.endsWith(' $suffix')) {
        title = title.substring(0, title.length - suffix.length - 1).trim();
        break;
      }
    }

    // Add the localized suffix
    title += ' (${StrRes.chatRecord})';
    _initPlayListener();
    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _initPlayListener() {
    _audioPlayer.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
        case ProcessingState.loading:
        case ProcessingState.buffering:
        case ProcessingState.ready:
          break;
        case ProcessingState.completed:
          _currentPlayClientMsgID.value = "";
          break;
      }
    });
  }

  /// Play voice message
  void _playVoiceMessage(Message message) async {
    var isClickSame = _currentPlayClientMsgID.value == message.clientMsgID;
    if (_audioPlayer.playerState.playing) {
      _currentPlayClientMsgID.value = "";
      _audioPlayer.stop();
    }
    if (!isClickSame) {
      bool isValid = await _initVoiceSource(message);
      if (isValid) {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.play();
        _currentPlayClientMsgID.value = message.clientMsgID!;
      }
    }
  }

  /// Initialize voice source
  Future<bool> _initVoiceSource(Message message) async {
    bool isReceived = message.sendID != OpenIM.iMManager.userID;
    String? path = message.soundElem?.soundPath;
    String? url = message.soundElem?.sourceUrl;
    bool isExistSource = false;
    if (isReceived) {
      if (null != url && url.trim().isNotEmpty) {
        isExistSource = true;
        _audioPlayer.setUrl(url);
      }
    } else {
      bool existFile = false;
      if (path != null && path.trim().isNotEmpty) {
        var file = File(path);
        existFile = await file.exists();
      }
      if (existFile) {
        isExistSource = true;
        _audioPlayer.setFilePath(path!);
      } else if (null != url && url.trim().isNotEmpty) {
        isExistSource = true;
        _audioPlayer.setUrl(url);
      }
    }
    return isExistSource;
  }

  /// Handle click on @ tag
  void clickAtText(String id, Message message) async {
    var tag = await OpenIM.iMManager.conversationManager.getAtAllTag();
    if (id == tag) return;

    // Get user info from message's at user list
    final atUsers = message.atTextElem?.atUsersInfo ?? [];
    UserInfo? userInfo;

    for (var atUser in atUsers) {
      if (atUser.atUserID == id) {
        userInfo = UserInfo(
          userID: atUser.atUserID,
          nickname: atUser.groupNickname,
        );
        break;
      }
    }

    // Fallback to just userID if not found in at users list
    userInfo ??= UserInfo(userID: id);
    viewUserInfo(userInfo);
  }

  /// Open user profile
  void viewUserInfo(UserInfo userInfo) {
    // Create tag before navigating to avoid "Bad state: No element" error
    GetTags.createUserProfileTag();

    final arguments = {
      'userID': userInfo.userID,
      'nickname': userInfo.nickname,
      'faceURL': userInfo.faceURL,
    };
    Get.toNamed(
      '/user_profile_panel',
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  /// Handle click on link/email/phone
  void clickLinkText(String url, PatternType? type, Message message) async {
    if (type == PatternType.at) {
      clickAtText(url, message);
      return;
    }
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        focusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F9FA),
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: Container(
            margin: EdgeInsets.all(8.w),
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 10.h,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: const Color(0xFF757575),
                  size: 16.w,
                ),
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontWeight: FontWeight.w500,
                  fontSize: 23.sp,
                  color: Colors.black,
                ),
              ),
              Text(
                StrRes.mergedMessages,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  color: const Color(0xFFBDBDBD),
                ),
              ),
            ],
          ),
          titleSpacing: 0,
          centerTitle: false,
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
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: AnimationLimiter(
          child: ListView.builder(
            itemCount: widget.messageList.length,
            padding: EdgeInsets.only(top: 16.h),
            itemBuilder: (_, index) => AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                curve: Curves.easeOutCubic,
                verticalOffset: 40.0,
                child: FadeInAnimation(
                  child: _buildItemView(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaContent(Message message) {
    final isOutgoing = message.sendID == OpenIM.iMManager.userID;

    if (message.isVideoType) {
      return ChatVideoView(
        isISend: isOutgoing,
        message: message,
        sendProgressStream: null,
      );
    } else {
      return ChatPictureView(
        isISend: isOutgoing,
        message: message,
        sendProgressStream: null,
      );
    }
  }

  Widget _buildItemView(int index) {
    var message = widget.messageList[index];
    //和上个数据是否相同,相同就隐藏头像
    // ignore: unused_local_variable
    bool isSame = index == 0
        ? false
        : widget.messageList[index - 1].senderFaceUrl == message.senderFaceUrl;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        focusNode.unfocus();

        // Handle voice message click separately
        if (message.isVoiceType) {
          _playVoiceMessage(message);
          return;
        }

        IMUtils.parseClickEvent(
          message,
          messageList: [message],
          onViewUserInfo: (userInfo) {
            final arguments = {
              'userID': userInfo.userID,
              'nickname': userInfo.nickname,
              'faceURL': userInfo.faceURL,
            };
            Get.toNamed(
              '/user_profile_panel',
              arguments: arguments,
              preventDuplicates: false,
            );
          },
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9CA3AF).withOpacity(0.06),
              offset: const Offset(0, 2),
              blurRadius: 8.r,
            ),
          ],
          border: Border.all(
            color: const Color(0xFFF3F4F6),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Visibility.maintain(
                // visible: !isSame,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(21.r),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1.5.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9CA3AF).withOpacity(0.1),
                        offset: const Offset(0, 2),
                        blurRadius: 8.r,
                      ),
                    ],
                  ),
                  child: AvatarView(
                    url: message.senderFaceUrl,
                    text: message.senderNickname,
                    width: 42.w,
                    height: 42.w,
                    isCircle: true,
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with name and time
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              message.senderNickname ?? '',
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ),
                          Text(
                            IMUtils.getChatTimeline(message.sendTime!),
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),

                      8.verticalSpace,

                      // Message content
                      buildItemContent(message),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItemContent(Message message) {
    String content = "[${StrRes.specialMessage}]";
    bool isISend = message.sendID == OpenIM.iMManager.userID;

    // Text message
    if (message.isTextType) {
      content = message.textElem!.content!;
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: MatchTextView(
          text: content,
          textStyle: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
            height: 1.4,
          ),
          isSupportCopy: true,
          copyFocusNode: focusNode,
        ),
      );
    }

    // At text message
    if (message.isAtTextType) {
      content = message.atTextElem!.text!;
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: MatchTextView(
          text: content,
          textStyle: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
            height: 1.4,
          ),
          matchTextStyle: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0089FF),
            height: 1.4,
          ),
          allAtMap: IMUtils.getAtMapping(message, {}),
          patterns: [
            MatchPattern(
              type: PatternType.at,
              onTap: (url, type) => clickLinkText(url, type, message),
            ),
            MatchPattern(
              type: PatternType.email,
              onTap: (url, type) => clickLinkText(url, type, message),
            ),
            MatchPattern(
              type: PatternType.url,
              onTap: (url, type) => clickLinkText(url, type, message),
            ),
            MatchPattern(
              type: PatternType.mobile,
              onTap: (url, type) => clickLinkText(url, type, message),
            ),
            MatchPattern(
              type: PatternType.tel,
              onTap: (url, type) => clickLinkText(url, type, message),
            ),
          ],
          isSupportCopy: true,
          copyFocusNode: focusNode,
        ),
      );
    }

    // Picture or Video message
    if (message.isPictureType || message.isVideoType) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9CA3AF).withOpacity(0.08),
              offset: const Offset(0, 2),
              blurRadius: 8.r,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: _buildMediaContent(message),
        ),
      );
    }

    // Voice message
    if (message.isVoiceType) {
      final sound = message.soundElem;
      return GestureDetector(
        onTap: () => _playVoiceMessage(message),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 218, 222, 226),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Obx(() {
            final isPlaying =
                _currentPlayClientMsgID.value == message.clientMsgID;
            return ChatVoiceView(
              isISend: isISend,
              soundPath: sound?.soundPath,
              soundUrl: sound?.sourceUrl,
              duration: sound?.duration,
              isPlaying: isPlaying,
            );
          }),
        ),
      );
    }

    // File message
    if (message.isFileType) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9CA3AF).withOpacity(0.08),
              offset: const Offset(0, 2),
              blurRadius: 8.r,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: ChatFileView(
            message: message,
            isISend: isISend,
            sendProgressStream: null,
            fileDownloadProgressView: null,
          ),
        ),
      );
    }

    // Quote message
    if (message.isQuoteType) {
      content = message.quoteElem?.text ?? '';
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: MatchTextView(
          text: content,
          textStyle: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
            height: 1.4,
          ),
          matchTextStyle: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0089FF),
            height: 1.4,
          ),
          allAtMap: IMUtils.getAtMapping(message, {}),
          patterns: [
            MatchPattern(
              type: PatternType.at,
              onTap: (url, type) => clickLinkText(url, type, message),
            ),
            MatchPattern(
              type: PatternType.email,
              onTap: (url, type) => clickLinkText(url, type, message),
            ),
            MatchPattern(
              type: PatternType.url,
              onTap: (url, type) => clickLinkText(url, type, message),
            ),
            MatchPattern(
              type: PatternType.mobile,
              onTap: (url, type) => clickLinkText(url, type, message),
            ),
            MatchPattern(
              type: PatternType.tel,
              onTap: (url, type) => clickLinkText(url, type, message),
            ),
          ],
          isSupportCopy: true,
          copyFocusNode: focusNode,
        ),
      );
    }

    // Merger message
    if (message.isMergerType) {
      String title = message.mergeElem?.title ?? '';
      final suffixPattern = RegExp(r'\s*\([^)]+\)\s*$');
      title = title.replaceAll(suffixPattern, '');

      // Remove all known language variants of chatRecord (with or without parentheses)
      final knownSuffixes = [
        'Chat Records', // English
        '聊天记录', // Chinese
        'chatRecord', // Fallback
      ];

      for (final suffix in knownSuffixes) {
        if (title.endsWith(suffix)) {
          title = title.substring(0, title.length - suffix.length).trim();
          break;
        }
        // Also try with space before suffix
        if (title.endsWith(' $suffix')) {
          title = title.substring(0, title.length - suffix.length - 1).trim();
          break;
        }
      }
      title += ' (${StrRes.chatRecord})';

      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: ChatMergeMsgView(
          title: title,
          summaryList: message.mergeElem?.abstractList ?? [],
        ),
      );
    }

    // Card message
    if (message.isCardType) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9CA3AF).withOpacity(0.08),
              offset: const Offset(0, 2),
              blurRadius: 8.r,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: ChatCarteView(cardElem: message.cardElem!),
        ),
      );
    }

    // Custom face/emoji message
    if (message.isCustomFaceType) {
      final face = message.faceElem;
      return ChatCustomEmojiView(
        index: face?.index,
        data: face?.data,
        isISend: isISend,
        heroTag: message.clientMsgID,
      );
    }

    // Revoke message
    if (message.isRevokeType) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          '${message.senderNickname ?? ''} ${StrRes.revokeMsg}',
          style: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      );
    }

    // Notification message
    if (message.isNotificationType) {
      final notificationText =
          IMUtils.parseNtf(message) ?? '[${StrRes.notification}]';
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          notificationText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      );
    }

    // Default fallback for special/unknown messages
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: MatchTextView(
        text: content,
        textStyle: TextStyle(
          fontFamily: 'FilsonPro',
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF374151),
          height: 1.4,
        ),
        isSupportCopy: true,
        copyFocusNode: focusNode,
      ),
    );
  }
}
