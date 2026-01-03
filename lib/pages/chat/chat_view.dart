// ignore_for_file: invalid_use_of_protected_member, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/widgets/custom_buttom.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../widgets/file_download_progress.dart';
import '../../widgets/gradient_scaffold.dart';
import 'chat_logic.dart';

class ChatPage extends StatelessWidget {
  // final logic = Get.find<ChatLogic>();
  final logic = Get.find<ChatLogic>(tag: GetTags.chat);

  ChatPage({super.key});

  Widget _buildItemView(Message message) => Obx(() => ChatItemView(
        key: ValueKey(message.clientMsgID),
        message: message,
        textScaleFactor: logic.scaleFactor.value,
        readingDuration: logic.readTime(message),
        timelineStr: logic.getShowTime(message),
        leftNickname: logic.getNewestNickname(message),
        leftFaceUrl: logic.getNewestFaceURL(message),
        rightNickname: logic.senderName,
        rightFaceUrl: OpenIM.iMManager.userInfo.faceURL,
        showLeftNickname: !logic.isSingleChat,
        showRightNickname: false,
        isMultiSelMode: logic.multiSelMode.value,
        checkedList: logic.multiSelList.value,
        isPrivateChat: message.isPrivateType,
        showLongPressMenu: !logic.isInvalidGroup,
        isPlayingSound: logic.isPlaySound(message),
        canReEdit: logic.canEditMessage(message),
        ignorePointer: logic.isInvalidGroup,
        enabledAddEmojiMenu: logic.showAddEmojiMenu(message) && !logic.isMuted,
        enabledCopyMenu: logic.showCopyMenu(message),
        enabledDelMenu: logic.showDelMenu(message),
        enabledForwardMenu: logic.showForwardMenu(message),
        enabledMultiMenu: logic.showMultiMenu(message),
        enabledReplyMenu: logic.showReplyMenu(message),
        enabledRevokeMenu: logic.showRevokeMenu(message),
        userRemarkMap: logic.imLogic.userRemarkMap,
        quoteMsgSenderNickname: logic.getQuoteMsgSenderNickname(message),
        allAtMap: logic.getAtMapping(message),
        patterns: _buildLinkPatterns(message),
        onTapAddEmojiMenu: () => logic.addEmoji(message),
        onTapCopyMenu: () => logic.copy(message),
        onTapDelMenu: () => logic.deleteMsg(message),
        onTapForwardMenu: () => logic.forward(message),
        onTapReplyMenu: () => logic.setQuoteMsg(message),
        onTapRevokeMenu: () {
          logic.markRevokedMessage(message);
          logic.revokeMsgV2(message);
        },
        onTapMultiMenu: () => logic.openMultiSelMode(message),
        onVisibleTrulyText: (text) {
          logic.copyTextMap[message.clientMsgID] = text;
        },
        onPopMenuShowChanged: logic.onPopMenuShowChanged,
        onTapQuoteMessage: (Message message) {
          logic.onTapQuoteMsg(message);
        },
        onLongPressQuoteMessage: (Message message) {
          logic.onLongPressQuoteMsg(message);
        },
        onMultiSelChanged: (checked) {
          logic.multiSelMsg(message, checked);
        },
        onDestroyMessage: () => logic.deleteMsg(message),
        onViewMessageReadStatus: () {},
        onFailedToResend: () => logic.failedResend(message),
        onReEit: () => logic.reEditMessage(message),
        closePopMenuSubject: logic.forceCloseMenuSub,
        onClickItemView: () => logic.parseClickEvent(message),
        fileDownloadProgressView: FileDownloadProgressView(message),
        onTapUserProfile: handleUserProfileTap,
        onTapLeftAvatar: () {
          logic.onTapLeftAvatar(message);
        },
        onTapRightAvatar: logic.onTapRightAvatar,
        onLongPressLeftAvatar: () {
          logic.onLongPressLeftAvatar(message);
        },
        onLongPressRightAvatar: () {},
        customTypeBuilder: _buildCustomTypeItemView,
        mediaItemBuilder: (context, message) {
          return _buildMediaItem(context, message);
        },
        shouldShowNicknameCallback: (message) {
          // Sử dụng logic từ chat_logic.dart
          final list = logic.messageList.reversed.toList();
          final index =
              list.indexWhere((msg) => msg.clientMsgID == message.clientMsgID);
          if (index != -1) {
            return logic.shouldShowLeftNicknameAt(index);
          }
          return false;
        },
      ));

  void handleUserProfileTap(
      ({
        String userID,
        String name,
        String? faceURL,
        String? groupID
      }) userProfile) {
    final userInfo = UserInfo(
        userID: userProfile.userID,
        nickname: userProfile.name,
        faceURL: userProfile.faceURL);
    logic.viewUserInfo(userInfo);
  }

  /// Build link patterns with appropriate styling based on message direction
  List<MatchPattern> _buildLinkPatterns(Message message) {
    // Check if the current user sent this message
    final isSentByMe = message.sendID == OpenIM.iMManager.userInfo.userID;
    // Use white color for sent messages, purple for received messages
    final linkColor = isSentByMe ? Colors.white : const Color(0xFF4F42FF);

    return <MatchPattern>[
      MatchPattern(
        type: PatternType.at,
        onTap: logic.clickLinkText,
      ),
      // Add @everyone pattern for highlighting
      MatchPattern(
        type: PatternType.atAll,
      ),
      MatchPattern(
        type: PatternType.email,
        style: TextStyle(
          color: linkColor,
          decoration: TextDecoration.underline,
          decorationColor: linkColor,
        ),
        onTap: logic.clickLinkText,
      ),
      MatchPattern(
        type: PatternType.url,
        style: TextStyle(
          color: linkColor,
          decoration: TextDecoration.underline,
          decorationColor: linkColor,
        ),
        onTap: logic.clickLinkText,
      ),
      MatchPattern(
        type: PatternType.mobile,
        style: TextStyle(
          color: linkColor,
          decoration: TextDecoration.underline,
          decorationColor: linkColor,
        ),
        onTap: logic.clickLinkText,
      ),
      MatchPattern(
        type: PatternType.tel,
        style: TextStyle(
          color: linkColor,
          decoration: TextDecoration.underline,
          decorationColor: linkColor,
        ),
        onTap: logic.clickLinkText,
      ),
    ];
  }

  Widget? _buildMediaItem(BuildContext context, Message message) {
    if (message.contentType != MessageType.picture &&
        message.contentType != MessageType.video) {
      return null;
    }

    return GestureDetector(
      onTap: () async {
        try {
          logic.stopVoice();
          final mediaMessages = await logic.searchMediaMessage();
          final temp = mediaMessages
              .firstWhereOrNull((e) => e.clientMsgID == message.clientMsgID);

          if (temp == null) {
            mediaMessages.add(message);
          }

          final cellIndex = mediaMessages
              .indexWhere((e) => e.clientMsgID == message.clientMsgID);

          if (cellIndex == -1 || !context.mounted) {
            return;
          }

          IMUtils.previewMediaFile(
              context: context,
              currentIndex: cellIndex,
              mediaMessages: mediaMessages,
              onAutoPlay: (index) {
                final msg = mediaMessages[index];
                return msg.clientMsgID == message.clientMsgID &&
                    !logic.playOnce;
              },
              muted: false,
              onPageChanged: (index) {
                logic.playOnce = true;
              },
              onOperate: (type) {
                if (type == OperateType.forward) {
                  logic.forward(message);
                }
              }).then((value) {
            logic.playOnce = false;
          });
        } catch (e) {
          IMViews.showToast(e.toString());
        }
      },
      child: Hero(
        tag: message.clientMsgID!,
        child: _buildMediaContent(message),
        placeholderBuilder:
            (BuildContext context, Size heroSize, Widget child) => child,
      ),
    );
  }

  Widget _buildMediaContent(Message message) {
    final isOutgoing = message.sendID == OpenIM.iMManager.userID;

    if (message.isVideoType) {
      return ChatVideoView(
        key: ValueKey('${message.clientMsgID}_${message.status}'),
        isISend: isOutgoing,
        message: message,
        sendProgressStream: logic.sendProgressSub,
      );
    } else {
      return ChatPictureView(
        isISend: isOutgoing,
        message: message,
        sendProgressStream: logic.sendProgressSub,
      );
    }
  }

  CustomTypeInfo? _buildCustomTypeItemView(_, Message message) {
    final data = IMUtils.parseCustomMessage(message);
    if (null != data) {
      final viewType = data['viewType'];
      if (viewType == CustomMessageType.call) {
        final type = data['type'];
        final content = data['content'];
        final view = ChatCallItemView(type: type, content: content);
        return CustomTypeInfo(view);
      } else if (viewType == CustomMessageType.deletedByFriend ||
          viewType == CustomMessageType.blockedByFriend) {
        final view = ChatFriendRelationshipAbnormalHintView(
          name: logic.nickname.value,
          onTap: logic.sendFriendVerification,
          blockedByFriend: viewType == CustomMessageType.blockedByFriend,
          deletedByFriend: viewType == CustomMessageType.deletedByFriend,
        );
        return CustomTypeInfo(view, false, false);
      } else if (viewType == CustomMessageType.removedFromGroup) {
        return CustomTypeInfo(
          StrRes.removedFromGroupHint.toText..style = Styles.ts_8E9AB0_12sp,
          false,
          false,
        );
      } else if (viewType == CustomMessageType.groupDisbanded) {
        return CustomTypeInfo(
          StrRes.groupDisbanded.toText..style = Styles.ts_8E9AB0_12sp,
          false,
          false,
        );
      } else if (viewType == CustomMessageType.tag) {
        final isISend = message.sendID == OpenIM.iMManager.userID;
        if (null != data['textElem']) {
          final textElem = TextElem.fromJson(data['textElem']);
          return CustomTypeInfo(
            ChatText(
              // isISend: isISend,
              text: textElem.content ?? '',
              textScaleFactor: logic.scaleFactor.value,
              model: TextModel.normal,
            ),
          );
        } else if (null != data['soundElem']) {
          final soundElem = SoundElem.fromJson(data['soundElem']);
          return CustomTypeInfo(
            ChatVoiceView(
              isISend: isISend,
              soundPath: soundElem.soundPath,
              soundUrl: soundElem.sourceUrl,
              duration: soundElem.duration,
              isPlaying: logic.isPlaySound(message),
            ),
          );
        }
      }
    }
    return null;
  }

  Widget get _topNoticeView => logic.announcement.value.isNotEmpty
      ? TopNoticeView(
          content: logic.announcement.value,
          onPreview: logic.previewGroupAnnouncement,
          onClose: logic.closeGroupAnnouncement,
        )
      : const SizedBox();

  @override
  Widget build(BuildContext context) {
    // Show loading screen if not initialized (prevents Obx errors)
    if (!logic.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return WillPopScope(
      onWillPop: logic.willPop(),
      child: ChatVoiceRecordLayout(
        key: logic.voiceRecordKey,
        onCompleted: logic.sendVoice,
        builder: (bar) => Obx(() {
          return GradientScaffold(
            titleWidget: _userInfo(),
            showBackButton: true,
            // Custom back handler to properly handle navigation
            onBack: logic.onBackPressed,
            scrollable: false,
            // Header trailing buttons (Call, More)
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (logic.showAudioAndVideoCall) ...[
                  CustomButton(
                    onTap: logic.onTapAudioCall,
                    icon: Icons.call,
                    color: Colors.white,
                  ),
                  6.horizontalSpace,
                  CustomButton(
                    onTap: logic.onTapVideoCall,
                    icon: Icons.videocam_outlined,
                    color: Colors.white,
                  ),
                  6.horizontalSpace,
                ],
                CustomButton(
                  onTap: logic.chatSetup,
                  icon: Icons.more_horiz,
                  color: Colors.white,
                ),
              ],
            ),
            showTopBodyPadding: false,
            body: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(
                  bottom: logic.isInputFocused.value ? 0 : 16.h),
              child: WaterMarkBgView(
                text: '',
                path: logic.background.value,
                backgroundColor: const Color(0xFFFFFFFF),
                topView: _topNoticeView,
                bottomView: logic.isBanned
                    ? ChatGroupBannedBox(
                        text: StrRes.groupBannedMessage,
                      )
                    : ChatInputBox(
                        key: logic.chatInputBoxStateKey,
                        allAtMap: logic.atUserNameMappingMap,
                        forceCloseToolboxSub: logic.forceCloseToolbox,
                        controller: logic.inputCtrl,
                        focusNode: logic.focusNode,
                        enabled: !logic.isMuted,
                        hintText: logic.hintText,
                        inputFormatters: [
                          AtTextInputFormatter(logic.openAtList)
                        ],
                        isMultiModel: logic.multiSelMode.value,
                        isNotInGroup: logic.isInvalidGroup,
                        quoteContent: logic.quoteContent.value,
                        onClearQuote: () => logic.setQuoteMsg(null),
                        onSend: (v) => logic.sendTextMsg(),
                        onTapAlbum: logic.onTapAlbum,
                        onTapCamera: logic.onTapCamera,
                        onTapFile: logic.onTapFile,
                        onTapCard: logic.onTapCarte,
                        onSendVoice: logic.sendVoice,
                        toolbox: ChatToolBox(
                          onTapAlbum: logic.onTapAlbum,
                          onTapCamera: logic.onTapCamera,
                          onTapCard: logic.onTapCarte,
                          onTapFile: logic.onTapFile,
                          showAudioCall: logic.showAudioAndVideoCall,
                          showVideoCall: logic.showAudioAndVideoCall,
                          height: logic.keyboardHeight.value,
                        ),
                        voiceRecordBar: bar,
                        emojiView: Obx(
                          () => ChatEmojiView(
                            key: ValueKey(
                                'emoji_view_${logic.favoriteEmojiList.length}'),
                            textEditingController: logic.inputCtrl,
                            favoriteList: logic.favoriteEmojiList,
                            onAddFavorite: logic.openEmojiPicker,
                            onSelectedFavorite: (index, emoji) =>
                                logic.inputCtrl.text += emoji,
                            height: logic.keyboardHeight.value,
                          ),
                        ),
                        multiOpToolbox: ChatMultiSelToolbox(
                          onDelete: logic.mergeDelete,
                          onMergeForward: () => logic.forward(null),
                          onCancel: logic.closeMultiSelMode,
                        ),
                        callbackKeyboardHeight: (double height) =>
                            logic.keyboardHeight.value = height,
                      ),
                child: AnimationLimiter(
                  child: Stack(
                    children: [
                      ChatListView(
                        onTouch: () => logic.closeToolbox(),
                        itemCount: logic.messageList.length,
                        controller: logic.scrollController,
                        onScrollToBottomLoad: logic.onScrollToBottomLoad,
                        onScrollToTop: logic.onScrollToTop,
                        itemBuilder: (_, index) {
                          final message = logic.indexOfMessage(index);
                          if (logic.isMessageHidden(message)) {
                            return const SizedBox.shrink();
                          }
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 400),
                            child: SlideAnimation(
                              curve: Curves.easeOutCubic,
                              verticalOffset: 40.0,
                              child: FadeInAnimation(
                                curve: Curves.easeOutCubic,
                                child: AutoScrollTag(
                                    key: ValueKey(index),
                                    controller: logic.scrollController,
                                    index: index,
                                    child: _buildItemView(message)),
                              ),
                            ),
                          );
                        },
                      ),
                      if (logic.scrollingCacheMessageList.isNotEmpty)
                        Positioned(
                          bottom: 20,
                          right: 16,
                          child: GestureDetector(
                            onTap: logic.onScrollBottom,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.h, horizontal: 16.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F42FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF9CA3AF)
                                        .withOpacity(0.08),
                                    offset: const Offset(0, 2),
                                    blurRadius: 6,
                                  ),
                                ],
                                border: Border.all(
                                  color: const Color(0xFFF3F4F6),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: const Color(0xFF4F42FF),
                                    size: 22.w,
                                  ),
                                  6.horizontalSpace,
                                  Text(
                                    StrRes.newMessagesCount.replaceFirst('%s',
                                        '${logic.scrollingCacheMessageList.length}'),
                                    style: TextStyle(
                                      fontFamily: 'FilsonPro',
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4F42FF),
                                    ),
                                  ),
                                ],
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
        }),
      ),
    );
  }

  Widget _userInfo() {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.r),
                border: Border.all(color: Colors.white, width: 2.w),
              ),
              child: GestureDetector(
                onTap: !logic.multiSelMode.value ? logic.chatSetup : null,
                child: AvatarView(
                  width: 42.w,
                  height: 42.h,
                  url: logic.faceUrl.value,
                  text: logic.nickname.value,
                  isCircle: true,
                  isGroup: logic.isGroupChat,
                  textStyle: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Online indicator at bottom-right of avatar
            Obx(() {
              // For single chat: show if user is online (onlineStatus.value) OR typing
              // For group chat: show if there are online members
              final showOnlineIndicator = logic.isSingleChat
                  ? (logic.onlineStatus.value || logic.typing.value)
                  : (logic.isGroupChat &&
                      logic.onlineInfoLogic.onlineUserId.isNotEmpty);

              return showOnlineIndicator
                  ? Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF34D399),
                          border: Border.all(color: Colors.white, width: 2.w),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            }),
          ],
        ),
        12.horizontalSpace,
        Expanded(
          child: GestureDetector(
            onTap: logic.onClickTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        logic.nickname.value,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (logic.memberStr.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(left: 4.w, right: 8.w),
                        child: Text(
                          logic.memberStr,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                  ],
                ),
                if (logic.subTitle.isNotEmpty)
                  Obx(
                    () => GestureDetector(
                      onTap: logic.showGroupOnlineInfo
                          ? logic.viewGroupOnlineInfo
                          : null,
                      child: Text(
                        logic.subTitle,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
