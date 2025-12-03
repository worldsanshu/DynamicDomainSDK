import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim/constants/app_color.dart';

import 'package:openim/core/controller/im_controller.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim/widgets/base_page.dart';
import 'package:openim/widgets/custom_buttom.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';
import 'package:flutter/cupertino.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

import 'conversation_logic.dart';
import '../home/home_logic.dart';

class ConversationPage extends StatefulWidget {
  ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final logic = Get.find<ConversationLogic>();

  final im = Get.find<IMController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => BasePage(
          showAppBar: true,
          centerTitle: false,
          showLeading: false,
          customAppBar: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${logic.titleText} (${logic.conversationCount.value})',
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontWeight: FontWeight.w500,
                  fontSize: 20.sp,
                  color: Colors.black,
                ),
              ),
              Obx(
                () {
                  return Text(
                    logic.getUnreadText,
                    style: const TextStyle(
                      fontFamily: 'FilsonPro',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFBDBDBD),
                    ).copyWith(fontSize: 12.sp),
                  );
                },
              ),
            ],
          ),
          actions: [
          ],
          body: Column(
            children: [
              if (!logic.isConnected.value) _buildNetworkUnavailableBanner(),
              _buildAnnouncementList(),
              Expanded(
                child: _buildContentContainer(),
              ),
            ],
          ),
        ));
  }

  Widget _buildAnnouncementList() {
    return Column(
      children: logic.systemAnnouncementList.map(
        (announcement) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
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
                  const Color(0xFFFEF3C7),
                ],
                stops: const [0.05, 0.3],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: () => logic.viewAnnouncement(announcement),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Row(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.speaker_3,
                            size: 18.w,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: Text(
                          announcement.content.replaceAll('\n', ''),
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF92400E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      8.horizontalSpace,
                      GestureDetector(
                        onTap: () => logic.markAnnouncementAsRead(announcement),
                        child: Container(
                          width: 28.w,
                          height: 28.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Icon(
                              CupertinoIcons.xmark,
                              size: 16.w,
                              color: const Color(0xFF92400E),
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

        return Stack(
          children: [
            if (!logic.isAIChatMode.value)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFriendsCarousel(),
                  if (!logic.isInChina.value && Platform.isIOS)
                    _buildAISearchField(),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: ListView.builder(
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
              ),
            // AI Chat Interface
            if (logic.isAIChatMode.value)
              Positioned.fill(
                child: _buildAIChatInterface(),
              ),

            // Close button when in AI mode
            if (logic.isAIChatMode.value)
              Positioned(
                top: 0.h,
                left: 16.w,
                child: CustomButtom(
                    onPressed: logic.exitAIChatMode, icon: CupertinoIcons.back),
              ),

            // Floating Action Button for New actions
            if (!logic.isAIChatMode.value)
              Positioned(
                bottom: 20.h,
                right: 20.w,
                child: GestureDetector(
                  onTap: () {
                    _showActionPopup(context);
                  },
                  child: Container(
                    width: 56.w,
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF212121),
                      borderRadius: BorderRadius.circular(28.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF212121).withOpacity(0.3),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 28.w,
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  void _showActionPopup(BuildContext context) {
    final homeLogic = Get.find<HomeLogic>();
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.1),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.h, right: 20.w),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.3, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              alignment: Alignment.bottomRight,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 220.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9CA3AF).withOpacity(0.15),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFF3F4F6),
                      width: 1,
                    ),
                  ),
                  child: AnimationLimiter(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionItem(
                          icon: HugeIcons.strokeRoundedAiScan,
                          title: StrRes.scan,
                          onTap: () {
                            Navigator.pop(buildContext);
                            homeLogic.scan();
                          },
                          index: 0,
                        ),
                        _buildActionDivider(),
                        _buildActionItem(
                          icon: HugeIcons.strokeRoundedUserAdd01,
                          title: StrRes.addFriend,
                          onTap: () {
                            Navigator.pop(buildContext);
                            homeLogic.addFriend();
                          },
                          index: 1,
                        ),
                        _buildActionDivider(),
                        _buildActionItem(
                          icon: HugeIcons.strokeRoundedUserGroup,
                          title: StrRes.addGroup,
                          onTap: () {
                            Navigator.pop(buildContext);
                            homeLogic.addGroup();
                          },
                          index: 2,
                        ),
                        _buildActionDivider(),
                        _buildActionItem(
                          icon: HugeIcons.strokeRoundedUserGroup02,
                          title: StrRes.createGroup,
                          onTap: () {
                            Navigator.pop(buildContext);
                            homeLogic.createGroup();
                          },
                          index: 3,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  Widget _buildActionDivider() {
    return Padding(
      padding: EdgeInsets.only(left: 70.w),
      child: const Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFF3F4F6),
      ),
    );
  }

  Widget _buildActionItem({
    required List<List<dynamic>> icon,
    required String title,
    required VoidCallback onTap,
    required int index,
    bool isLast = false,
  }) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 400),
      child: SlideAnimation(
        verticalOffset: 40.0,
        curve: Curves.easeOutCubic,
        child: FadeInAnimation(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: isLast
                    ? BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16.r),
                          bottomRight: Radius.circular(16.r),
                        ),
                      )
                    : null,
                child: Row(
                  children: [
                    HugeIcon(
                      icon: icon,
                      size: 20.w,
                      color: const Color(0xFF424242),
                    ),
                    16.horizontalSpace,
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
        margin: EdgeInsets.only(top: 0.h),
        height: 80.h,
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

  Widget _buildAISearchField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: TextField(
        controller: logic.aiTextController,
        focusNode: logic.aiFocusNode,
        readOnly: true,
        onTap: () {
          if (!logic.isAIChatMode.value) {
            logic.toggleAIChatMode();
          }
        },
        style: TextStyle(
          fontFamily: 'FilsonPro',
          fontSize: 14.sp,
          color: const Color(0xFF212121),
        ),
        decoration: InputDecoration(
          hintText: StrRes.typeYourMessage,
          hintStyle: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 14.sp,
            color: const Color(0xFFBDBDBD),
          ),
          prefixIcon: Icon(
            CupertinoIcons.sparkles,
            color: const Color(0xFF8B5CF6),
            size: 20.w,
          ),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(
              color: Color(0xFF8B5CF6),
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  Widget _buildAIChatInterface() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.sparkles,
                          color: const Color(0xFF8B5CF6),
                          size: 24.w,
                        ),
                        8.horizontalSpace,
                        Text(
                          StrRes.aiAssistant,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF212121),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Clear history button
                Obx(() => logic.aiChatMessages.isNotEmpty
                    ? GestureDetector(
                        onTap: () async {
                          final confirm = await Get.dialog(
                            CustomDialog(
                              title: StrRes.clearAIChatHistory,
                              content: StrRes.clearAIChatHistoryConfirm,
                            ),
                          );
                          if (confirm == true) {
                            await logic.clearAIChatHistory();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.trash,
                                color: const Color(0xFFEF4444),
                                size: 16.w,
                              ),
                              4.horizontalSpace,
                              Text(
                                StrRes.delete,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Chat messages
          Expanded(
            child: Obx(() {
              if (logic.aiChatMessages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.chat_bubble_2,
                        size: 64.w,
                        color: const Color(0xFFE5E7EB),
                      ),
                      16.verticalSpace,
                      Text(
                        StrRes.startConversationWithAI,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 16.sp,
                          color: const Color(0xFFBDBDBD),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: logic.aiScrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                reverse: false,
                itemCount: logic.aiChatMessages.length +
                    (logic.isAIThinking.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == logic.aiChatMessages.length &&
                      logic.isAIThinking.value) {
                    return _buildThinkingIndicator();
                  }

                  final message = logic.aiChatMessages[index];
                  return _buildChatBubble(message);
                },
              );
            }),
          ),

          // Input area
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10.r,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: logic.aiTextController,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => logic.sendMessageToAI(),
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 14.sp,
                      color: const Color(0xFF212121),
                    ),
                    decoration: InputDecoration(
                      hintText: StrRes.typeYourMessage,
                      hintStyle: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 14.sp,
                        color: const Color(0xFFBDBDBD),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                    ),
                  ),
                ),
                12.horizontalSpace,
                Obx(() => Material(
                      color: logic.isAIThinking.value
                          ? const Color(0xFFBDBDBD)
                          : const Color(0xFF8B5CF6),
                      borderRadius: BorderRadius.circular(20.r),
                      child: InkWell(
                        onTap: logic.isAIThinking.value
                            ? null
                            : logic.sendMessageToAI,
                        borderRadius: BorderRadius.circular(20.r),
                        child: SizedBox(
                          width: 44.w,
                          height: 44.h,
                          child: Center(
                            child: Icon(
                              CupertinoIcons.arrow_up,
                              color: Colors.white,
                              size: 20.w,
                            ),
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    final text = message['message'] as String;
    final isError = message['isError'] ?? false;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                CupertinoIcons.sparkles,
                color: const Color(0xFF8B5CF6),
                size: 16.w,
              ),
            ),
            8.horizontalSpace,
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF8B5CF6)
                    : isError
                        ? const Color(0xFFFEE2E2)
                        : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 14.sp,
                  color: isUser
                      ? Colors.white
                      : isError
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF212121),
                ),
              ),
            ),
          ),
          if (isUser) ...[
            8.horizontalSpace,
            AvatarView(
              url: logic.imLogic.userInfo.value.faceURL,
              text: logic.imLogic.userInfo.value.nickname,
              width: 35.w,
              height: 35.h,
              textStyle: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              isCircle: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              CupertinoIcons.sparkles,
              color: const Color(0xFF8B5CF6),
              size: 16.w,
            ),
          ),
          8.horizontalSpace,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                4.horizontalSpace,
                _buildDot(1),
                4.horizontalSpace,
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedDot(index: index);
  }

  Widget _buildTabFilter() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      height: 36.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Stack(
          children: [
            // Animated selection indicator
            Obx(() => AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  left: logic.selectedTabIndex.value * (Get.width - 32.w) / 2,
                  top: 0,
                  bottom: 0,
                  width: (Get.width - 32.w) / 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                )),

            // Tab buttons
            Row(
              children: List.generate(
                logic.tabTitles.length,
                (index) => Expanded(
                  child: Obx(() {
                    final isSelected = logic.selectedTabIndex.value == index;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () => logic.switchTab(index),
                        child: SizedBox(
                          height: double.infinity,
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedOpacity(
                                  opacity: isSelected ? 1.0 : 0.7,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    index == 0
                                        ? CupertinoIcons.chat_bubble_2
                                        : CupertinoIcons.tray_full,
                                    size: 15.w,
                                    color: isSelected
                                        ? const Color(0xFF3B82F6)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(
                                    milliseconds: 200,
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'FilsonPro',
                                    fontSize: 13.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? const Color(0xFF3B82F6)
                                        : const Color(0xFF64748B),
                                    letterSpacing: 0.2,
                                  ),
                                  child: Text(logic.tabTitles[index]),
                                ),
                                if (index == 1) ...[
                                  SizedBox(width: 5.w),
                                  Obx(() {
                                    final unreadCount = logic.list
                                        .where((conversation) =>
                                            conversation.unreadCount > 0)
                                        .length;
                                    if (unreadCount == 0) {
                                      return const SizedBox();
                                    }

                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5.w, vertical: 1.h),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFFEF4444)
                                            : const Color(0xFF94A3B8),
                                        borderRadius:
                                            BorderRadius.circular(7.r),
                                      ),
                                      child: Text(
                                        unreadCount > 99
                                            ? '99+'
                                            : '$unreadCount',
                                        style: TextStyle(
                                          fontFamily: 'FilsonPro',
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sanitizeText(String text) {
    if (text.isEmpty) return text;
    try {
      // Remove invalid UTF-16 surrogate pairs
      return text.replaceAll(RegExp(r'[\uD800-\uDBFF](?![\uDC00-\uDFFF])'), '')
          .replaceAll(RegExp(r'(?<![\uD800-\uDBFF])[\uDC00-\uDFFF]'), '');
    } catch (e) {
      return text;
    }
  }

  Widget _buildConversationItemView(ConversationInfo info) => Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: logic.existUnreadMsg(info) ? 0.7 : 0.4,
          children: [
            CustomSlidableAction(
              onPressed: (_) => logic.pinConversation(info),
              flex: 2,
              backgroundColor: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(16.r),
              padding: EdgeInsets.all(8.w),
              child: Text(
                logic.isPinned(info) ? StrRes.unpin : StrRes.pin,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            if (logic.existUnreadMsg(info))
              CustomSlidableAction(
                onPressed: (_) => logic.markMessageHasRead(info),
                flex: 3,
                backgroundColor: const Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(16.r),
                padding: EdgeInsets.all(3.w),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate responsive font size based on available width
                    double responsiveFontSize =
                        (constraints.maxWidth * 0.12).clamp(10.0, 20.0);

                    return Center(
                      child: Text(
                        StrRes.markHasRead,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: responsiveFontSize.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2, // Allow text to wrap to 2 lines
                        overflow: TextOverflow.ellipsis,
                        softWrap: true, // Enable text wrapping
                      ),
                    );
                  },
                ),
              ),
            CustomSlidableAction(
              onPressed: (_) => logic.deleteConversation(info),
              flex: 2,
              backgroundColor: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(16.r),
              padding: EdgeInsets.all(8.w),
              child: Text(
                StrRes.delete,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
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
        color: const Color(0xFFE0F2FE).withOpacity(.25),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Material(
        color: Colors.transparent,
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
                          child: Text(
                            logic.getShowName(info),
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
                        20.horizontalSpace,
                        Row(
                          children: [
                            if (info.isPinned!) ...[
                              Icon(
                                CupertinoIcons.pin_fill,
                                size: 14.w,
                                color: const Color(0xFF3B82F6),
                              ),
                              8.horizontalSpace,
                            ],
                            Text(
                              logic.getTime(info),
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
                    // 2.verticalSpace,
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
                              color: const Color(0xFF9E9E9E),
                            ),
                            allAtMap: logic.getAtUserMap(info),
                            prefixSpan: TextSpan(
                              children: [
                                TextSpan(
                                  text: _sanitizeText(logic.getPrefixTag(info)??""),
                                  style: TextStyle(
                                    fontFamily: 'FilsonPro',
                                    fontSize: 14.sp,
                                    fontWeight: logic.getUnreadCount(info) > 0
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: const Color(0xFF3B82F6),
                                  ),
                                ),
                              ],
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
                                      ? FontWeight
                                          .w900 // In đậm pattern khi có tin nhắn chưa đọc
                                      : FontWeight.w400,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        8.horizontalSpace,
                        _buildUnreadIndicator(info),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ConversationInfo info) {
    return Stack(
      children: [
        AvatarView(
          width: 50.w,
          height: 50.h,
          text: logic.getShowName(info),
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

  Widget _buildUnreadIndicator(ConversationInfo info) {
    if (logic.isNotDisturb(info)) {
      final count = logic.getUnreadCount(info);
      return Row(
        children: [
          if (count > 0)
            Container(
              constraints: BoxConstraints(minWidth: 24.w, minHeight: 24.h),
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          5.horizontalSpace,
          Container(
            width: 24.w,
            height: 24.h,
            decoration: const BoxDecoration(
              color: Color(0xFFE5E7EB),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.bell_slash,
                size: 14.w,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      );
    } else {
      final count = logic.getUnreadCount(info);
      if (count <= 0) return const SizedBox();

      return Container(
        constraints: BoxConstraints(minWidth: 24.w, minHeight: 24.h),
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        decoration: const BoxDecoration(
          color: Color(0xFFEF4444),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            count > 99 ? '99+' : count.toString(),
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
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
                size: 18.w,
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

  Widget _buildPinnedConversationCard(ConversationInfo info) {
    return GestureDetector(
      onTap: () => logic.toChat(conversationInfo: info),
      onLongPress: () => _showPinnedItemMenu(info),
      child: Container(
        margin: EdgeInsets.only(right: 12.w),
        width: 150.w,
        height: 200.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9CA3AF).withOpacity(0.1),
              offset: const Offset(0, 3),
              blurRadius: 8.r,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.r),
                child: IMUtils.isUrlValid(info.faceURL)
                    ? SoftEdgeBlur(
                        edges: [
                          EdgeBlur(
                            tintColor:
                                const Color(0xFFBBDEFB).withOpacity(0.85),
                            type: EdgeType.bottomEdge,
                            size: 110,
                            sigma: 12,
                            controlPoints: [
                              ControlPoint(
                                position: 0.3,
                                type: ControlPointType.visible,
                              ),
                              ControlPoint(
                                position: 0.5,
                                type: ControlPointType.visible,
                              ),
                              ControlPoint(
                                position: 1,
                                type: ControlPointType.transparent,
                              )
                            ],
                          )
                        ],
                        child: ImageUtil.networkImage(
                          url: info.faceURL!,
                          fit: BoxFit.cover,
                          loadProgress: false,
                        ),
                      )
                    : SoftEdgeBlur(
                        edges: [
                          EdgeBlur(
                            tintColor: const Color(0xFFD4C4FB),
                            type: EdgeType.bottomEdge,
                            size: 120,
                            sigma: 30,
                            controlPoints: [
                              ControlPoint(
                                position: 0.3,
                                type: ControlPointType.visible,
                              ),
                              ControlPoint(
                                position: 0.5,
                                type: ControlPointType.visible,
                              ),
                              ControlPoint(
                                position: 1,
                                type: ControlPointType.transparent,
                              )
                            ],
                          )
                        ],
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                logic.isGroupChat(info)
                                    ? const Color(0xFFA78BFA)
                                    : const Color(0xFF60A5FA),
                                logic.isGroupChat(info)
                                    ? const Color(0xFF8B5CF6)
                                    : const Color(0xFF3B82F6),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              logic.isGroupChat(info)
                                  ? Icons.group
                                  : Icons.person,
                              size: 40.w,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
              ),
            ),

            // Content moved to bottom of card
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // User/Group name and online indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Online status indicator if applicable
                        if (logic.isUserOnline(info))
                          Container(
                            width: 8.w,
                            height: 8.w,
                            margin: EdgeInsets.only(right: 6.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.w,
                              ),
                            ),
                          ),
                        // User/Group name
                        Flexible(
                          child: Text(
                            logic.getShowName(info),
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                  color: Color(0xFF3B82F6),
                                  offset: Offset(0.5, 0.5),
                                  blurRadius: 1.0,
                                ),
                                Shadow(
                                  color: Color(0xFF3B82F6),
                                  offset: Offset(-0.5, 0.5),
                                  blurRadius: 1.0,
                                ),
                                Shadow(
                                  color: Color(0xFF3B82F6),
                                  offset: Offset(0.5, -0.5),
                                  blurRadius: 1.0,
                                ),
                                Shadow(
                                  color: Color(0xFF3B82F6),
                                  offset: Offset(-0.5, -0.5),
                                  blurRadius: 1.0,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    6.verticalSpace,
                    // Message content
                    MatchTextView(
                      text: logic.getContent(info),
                      textAlign: TextAlign.center,
                      textStyle: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                      allAtMap: logic.getAtUserMap(info),
                      prefixSpan: TextSpan(
                        children: [
                          if (logic.isNotDisturb(info) &&
                              logic.getUnreadCount(info) > 0)
                            TextSpan(
                              text: '[${sprintf(StrRes.nPieces, [
                                    logic.getUnreadCount(info)
                                  ])}] ',
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          TextSpan(
                            text: logic.getPrefixTag(info),
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 12.sp,
                              fontWeight: logic.getUnreadCount(info) > 0
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      patterns: <MatchPattern>[
                        MatchPattern(
                          type: PatternType.at,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 12.sp,
                            fontWeight: logic.getUnreadCount(info) > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    6.verticalSpace,
                    // Time and unread indicator in a row at bottom
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Time
                        Text(
                          logic.getTime(info),
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        8.horizontalSpace,
                        // Unread count
                        if (logic.getUnreadCount(info) > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              logic.getUnreadCount(info) > 99
                                  ? '99+'
                                  : logic.getUnreadCount(info).toString(),
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add method to show menu on long press
  void _showPinnedItemMenu(ConversationInfo info) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9CA3AF).withOpacity(0.08),
              offset: const Offset(0, -2),
              blurRadius: 12.r,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              20.verticalSpace,

              // Menu Section
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9CA3AF).withOpacity(0.06),
                      blurRadius: 6.r,
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFF3F4F6),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cancel Top option
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        logic.pinConversation(info);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 14.h),
                        child: Row(
                          children: [
                            // Icon container
                            Container(
                              width: 42.w,
                              height: 42.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFF60A5FA).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                CupertinoIcons.pin,
                                color: const Color(0xFF60A5FA),
                                size: 20.w,
                              ),
                            ),
                            16.horizontalSpace,
                            // Text
                            Text(
                              logic.isPinned(info) ? StrRes.unpin : StrRes.pin,
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Divider
                    if (logic.existUnreadMsg(info) || true)
                      Padding(
                        padding: EdgeInsets.only(left: 70.w),
                        child: const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFF3F4F6),
                        ),
                      ),

                    // Mark as Read option (only if there are unread messages)
                    if (logic.existUnreadMsg(info))
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          logic.markMessageHasRead(info);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 14.h),
                          child: Row(
                            children: [
                              // Icon container
                              Container(
                                width: 42.w,
                                height: 42.h,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFA78BFA).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  CupertinoIcons.checkmark_circle,
                                  color: const Color(0xFFA78BFA),
                                  size: 20.w,
                                ),
                              ),
                              16.horizontalSpace,
                              // Text
                              Text(
                                StrRes.markHasRead,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Divider before Delete option
                    if (logic.existUnreadMsg(info))
                      Padding(
                        padding: EdgeInsets.only(left: 70.w),
                        child: const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFF3F4F6),
                        ),
                      ),

                    // Delete option
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        logic.deleteConversation(info);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 14.h),
                        child: Row(
                          children: [
                            // Icon container
                            Container(
                              width: 42.w,
                              height: 42.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF87171).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                CupertinoIcons.delete,
                                color: const Color(0xFFF87171),
                                size: 20.w,
                              ),
                            ),
                            16.horizontalSpace,
                            // Text
                            Text(
                              StrRes.delete,
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFF87171),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom spacing
              24.verticalSpace,

              // Cancel Button
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(16.r),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9CA3AF).withOpacity(0.06),
                          offset: const Offset(0, 2),
                          blurRadius: 6.r,
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFF3F4F6),
                        width: 1,
                      ),
                    ),
                    child: SizedBox(
                      height: 56.h,
                      child: Center(
                        child: Text(
                          StrRes.cancel,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              24.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
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
