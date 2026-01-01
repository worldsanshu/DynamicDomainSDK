// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:openim/widgets/empty_view.dart';

import 'package:openim/core/controller/im_controller.dart';
import 'package:openim/widgets/custom_buttom.dart';
import 'package:openim/widgets/gradient_scaffold.dart';
import 'package:openim/widgets/overlay_new_contact.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter/cupertino.dart';

import 'conversation_logic.dart';
import 'conversation_preview_overlay.dart';

class ConversationPage extends StatefulWidget {
  ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final logic = Get.find<ConversationLogic>();
  final im = Get.find<IMController>();
  final GlobalKey _newButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => GradientScaffold(
        title: '${logic.titleText} (${logic.conversationCount.value})',
        subtitle: logic.getUnreadText,
        trailing: CustomButton(
          key: _newButtonKey,
          onTap: () => showNewContactPopup(context, _newButtonKey),
          icon: Icons.grid_view,
          color: Colors.white,
        ),
        body: Center(
          child: Column(
            children: [
              // Network unavailable banner
              if (!logic.isConnected.value) _buildNetworkUnavailableBanner(),
              // Announcement list
              _buildAnnouncementList(),
              // Content
              Expanded(
                child: _buildContentContainer(),
              ),
            ],
          ),
        )));
  }

  Widget _buildAnnouncementList() {
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      children: logic.systemAnnouncementList.map(
        (announcement) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: primaryColor.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () => logic.viewAnnouncement(announcement),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: Row(
                    children: [
                      Container(
                        width: 28.w,
                        height: 28.h,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.speaker_2_fill,
                            size: 16.w,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      10.horizontalSpace,
                      Expanded(
                        child: Text(
                          announcement.content
                              .replaceAll('\n', '')
                              .replaceAll('·', '|'),
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: primaryColor.withOpacity(0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      6.horizontalSpace,
                      GestureDetector(
                        onTap: () => logic.markAnnouncementAsRead(announcement),
                        child: Container(
                          width: 24.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Center(
                            child: Icon(
                              CupertinoIcons.xmark,
                              size: 14.w,
                              color: primaryColor.withOpacity(0.7),
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
        },
      ).toList(),
    );
  }

  Widget _buildContentContainer() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Obx(() {
        final filteredList = logic.filteredList;

        final sortedConversations = [...filteredList];
        sortedConversations.sort((a, b) {
          final aIsPinned = logic.isPinned(a);
          final bIsPinned = logic.isPinned(b);

          // First priority: pinned status
          if (aIsPinned && !bIsPinned) return -1;
          if (!aIsPinned && bIsPinned) return 1;

          // Second priority: sort by latest message time within same pinned status
          // Compare draft time vs latest message time for each conversation
          int aCompare = (a.draftTextTime ?? 0) > (a.latestMsgSendTime ?? 0)
              ? (a.draftTextTime ?? 0)
              : (a.latestMsgSendTime ?? 0);
          int bCompare = (b.draftTextTime ?? 0) > (b.latestMsgSendTime ?? 0)
              ? (b.draftTextTime ?? 0)
              : (b.latestMsgSendTime ?? 0);

          // Sort descending (newest first)
          if (aCompare > bCompare) {
            return -1;
          } else if (aCompare < bCompare) {
            return 1;
          } else {
            return 0;
          }
        });

        return Column(
          children: [
            _buildFriendsCarousel(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.zero,
                child: filteredList.isEmpty
                    ? EmptyView(
                        message: StrRes.noConversationsYet,
                        icon: Ionicons.chatbubble_ellipses_outline,
                      )
                    : ListView.builder(
                        itemExtent: 86.0,
                        padding: EdgeInsets.zero,
                        controller: logic.scrollController,
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          return _buildConversationItemView(
                              filteredList[index]);
                        },
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFriendsCarousel() {
    return Obx(() {
      if (logic.showLoading || logic.friendList.isEmpty) {
        return const SizedBox.shrink();
      }
      final seenUserIds = <String>{};
      var uniqueFriends = logic.friendList.where((friend) {
        if (friend.userID == null || friend.userID!.isEmpty) {
          return false;
        }
        if (seenUserIds.contains(friend.userID!)) {
          return false;
        }
        seenUserIds.add(friend.userID!);
        return true;
      }).toList();

      uniqueFriends.sort((a, b) {
        final aOnline = logic.isFriendOnline(a);
        final bOnline = logic.isFriendOnline(b);

        if (aOnline && !bOnline) return -1;
        if (!aOnline && bOnline) return 1;
        return a.showName.compareTo(b.showName);
      });
      uniqueFriends = uniqueFriends.take(20).toList();
      return Container(
        margin: EdgeInsets.only(top: 5.h),
        height: 72.h,
        width: double.infinity,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: uniqueFriends.length,
          itemBuilder: (context, index) {
            final friend = uniqueFriends[index];
            return _buildFriendItem(friend);
          },
        ),
      );
    });
  }

  Widget _buildFriendItem(ISUserInfo friend) {
    return GestureDetector(
      onTap: () => logic.chatWithFriend(friend),
      child: Container(
        margin: EdgeInsets.only(right: 10.w),
        child: Column(
          children: [
            Stack(
              children: [
                AvatarView(
                  url: friend.faceURL,
                  text: friend.showName,
                  width: 50.w,
                  height: 50.h,
                  textStyle: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  isCircle: false,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                // Online status indicator
                if (logic.isFriendOnline(friend))
                  Positioned(
                    right: 2.w,
                    bottom: 2.h,
                    child: Container(
                      width: 12.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: const Color(0xFFF8FAFC),
                          width: 2.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            4.verticalSpace,
            Text(
              friend.showName.length > 6
                  ? '${friend.showName.substring(0, 6)}...'
                  : friend.showName,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFBDBDBD),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _sanitizeText(String text) {
    if (text.isEmpty) return text;
    try {
      final buffer = StringBuffer();
      for (int i = 0; i < text.length; i++) {
        final codeUnit = text.codeUnitAt(i);
        if (codeUnit >= 0xD800 && codeUnit <= 0xDBFF) {
          if (i + 1 < text.length) {
            final nextCodeUnit = text.codeUnitAt(i + 1);
            if (nextCodeUnit >= 0xDC00 && nextCodeUnit <= 0xDFFF) {
              buffer.writeCharCode(codeUnit);
              buffer.writeCharCode(nextCodeUnit);
              i++;
              continue;
            }
          }
          continue;
        } else if (codeUnit >= 0xDC00 && codeUnit <= 0xDFFF) {
          continue;
        }
        buffer.writeCharCode(codeUnit);
      }
      return buffer.toString();
    } catch (e) {
      return '';
    }
  }

  Widget _buildConversationItemView(ConversationInfo info) => Slidable(
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: logic.existUnreadMsg(info) ? 0.45 : 0.3,
          children: [
            SlidableAction(
              onPressed: (_) => logic.pinConversation(info),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              icon: info.isPinned!
                  ? CupertinoIcons.pin_slash
                  : CupertinoIcons.pin,
              borderRadius: BorderRadius.circular(12.r),
            ),
            if (logic.existUnreadMsg(info))
              SlidableAction(
                onPressed: (_) => logic.markMessageHasRead(info),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                icon: Ionicons.checkmark_done_circle_outline,
                padding:EdgeInsets.only(right: 0),
                borderRadius: BorderRadius.circular(12.r),
              ),
            SlidableAction(
              onPressed: (_) => logic.deleteConversation(info),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: CupertinoIcons.trash,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ],
        ),
        child: _buildItemView(info),
      );

  Widget _buildItemView(ConversationInfo info) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),

          /// viền cạnh dưới
          border: Border(
            bottom: BorderSide(
              color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
              width: 0.5.w,
            ),
          )),
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          // onLongPress: () => _showMessagePreview(info),
          child: InkWell(
            onTap: () => logic.toChat(conversationInfo: info),
            child: Row(
              children: [
                _buildAvatar(info),
                16.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _sanitizeText(logic.getShowName(info)),
                                    style: TextStyle(
                                      fontFamily: 'FilsonPro',
                                      fontSize: 16.sp,
                                      fontWeight: logic.getUnreadCount(info) > 0
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: const Color(0xFF424242),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (info.isPinned!) ...[
                                  4.horizontalSpace,
                                  Icon(
                                    CupertinoIcons.pin,
                                    size: 14.w,
                                    color: Theme.of(Get.context!).primaryColor,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (logic.getUnreadCount(info) > 0) ...[
                            8.horizontalSpace,
                            CustomButton(
                              onTap: () {},
                              title: logic.getUnreadCount(info) > 99
                                  ? '99+'
                                  : logic.getUnreadCount(info).toString(),
                              fontSize: 12.sp,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              color: Colors.red,
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: MatchTextView(
                              text: _sanitizeText(logic.getContent(info)),
                              textStyle: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 14.sp,
                                fontWeight: logic.getUnreadCount(info) > 0
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: logic.getUnreadCount(info) > 0
                                    ? Theme.of(Get.context!).primaryColor
                                    : const Color(0xFF9E9E9E),
                              ),
                              allAtMap: logic.getAtUserMap(info),
                              prefixSpan: TextSpan(
                                text: _sanitizeText(
                                    logic.getPrefixTag(info) ?? ""),
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 14.sp,
                                  fontWeight: logic.getUnreadCount(info) > 0
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: const Color(0xFF3B82F6),
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              patterns: <MatchPattern>[
                                MatchPattern(
                                  type: PatternType.at,
                                  style: TextStyle(
                                    fontFamily: 'FilsonPro',
                                    fontSize: 14.sp,
                                    fontWeight: logic.getUnreadCount(info) > 0
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          8.horizontalSpace,
                          Text(
                            _sanitizeText(logic.getTime(info)),
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF9E9E9E),
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
        ),
      ),
    );
  }

  Future<void> _showMessagePreview(ConversationInfo info) async {
    final messages = await logic.getPreviewMessages(info);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => ConversationPreviewOverlay(
        conversationInfo: info,
        messages: messages,
        onTapPreview: () => logic.toChat(conversationInfo: info),
      ),
    );
  }

  Widget _buildAvatar(ConversationInfo info) {
    return Stack(
      children: [
        AvatarView(
          width: 50.w,
          height: 50.h,
          text: _sanitizeText(logic.getShowName(info)),
          url: info.faceURL,
          isGroup: logic.isGroupChat(info),
          textStyle: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          isCircle: false,
          borderRadius: BorderRadius.circular(50.r),
        ),
        // Online status indicator
        if (logic.isUserOnline(info))
          Positioned(
            right: 4.w,
            bottom: 4.h,
            child: Container(
              width: 16.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981), // Green color for online
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: const Color(0xFFF8FAFC),
                  width: 2.w,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNetworkUnavailableBanner() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
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
            const Color(0xFFFEE2E2),
          ],
          stops: const [0.05, 0.3],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.wifi,
                size: 22.w,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
          12.horizontalSpace,
          Expanded(
            child: Text(
              '${StrRes.networkUnavailable}，${StrRes.checkNetworkSettings}',
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFB91C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add method to show menu on long press
}

// Animated Dot Widget for thinking indicator
class AnimatedDot extends StatefulWidget {
  final int index;

  const AnimatedDot({Key? key, required this.index}) : super(key: key);

  @override
  State<AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final delay = widget.index * 0.2;
        final animValue = ((_animation.value + delay) % 1.0);
        final scale = 0.5 + (animValue * 0.5);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              color:
                  const Color(0xFF8B5CF6).withOpacity(0.3 + (animValue * 0.7)),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
