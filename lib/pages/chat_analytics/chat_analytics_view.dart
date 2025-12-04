// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim/widgets/custom_buttom.dart';
import 'package:openim_common/openim_common.dart';

import '../../widgets/base_page.dart';
import 'chat_analytics_logic.dart';

class ChatAnalyticsView extends StatelessWidget {
  final logic = Get.find<ChatAnalyticsLogic>();

  ChatAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => BasePage(
        showAppBar: true,
        centerTitle: false,
        showLeading: true,
        customAppBar: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StrRes.chatAnalytics,
              style: const TextStyle(
                fontFamily: 'FilsonPro',
                fontWeight: FontWeight.w500,
                fontSize: 23,
                color: Colors.black,
              ).copyWith(fontSize: 23.sp),
            ),
            Text(
              StrRes.usageAnalyticsInsights,
              style: const TextStyle(
                fontFamily: 'FilsonPro',
                fontWeight: FontWeight.w400,
                color: Color(0xFFBDBDBD),
              ).copyWith(fontSize: 12.sp),
            ),
          ],
        ),
        actions: [
          CustomButton(
            margin: const EdgeInsets.only(right: 10),
            onTap: logic.refreshData,
            icon: CupertinoIcons.refresh,
            colorButton: const Color(0xFF4F42FF).withOpacity(0.1),
            colorIcon: const Color(0xFF4F42FF),
          )
        ],
        body: logic.isLoading.value
            ? _buildLoadingView()
            : _buildContentContainer()));
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
      child: RefreshIndicator(
        onRefresh: logic.refreshData,
        color: const Color(0xFF4F42FF),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 20.h),
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 450),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  curve: Curves.easeOutQuart,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  20.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _buildOverviewCards(),
                  ),
                  18.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _buildActivityChart(),
                  ),
                  18.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _buildMessageTypeChart(),
                  ),
                  18.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _buildTopContacts(),
                  ),
                  18.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _buildTopGroups(),
                  ),
                  24.verticalSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.08),
                  offset: const Offset(0, 2),
                  blurRadius: 12.r,
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F42FF)),
                strokeWidth: 3,
              ),
            ),
          ),
          20.verticalSpace,
          Text(
            StrRes.loadingChatData,
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: StrRes.totalMessages,
            value: logic.totalMessages,
            icon: HugeIcons.strokeRoundedBubbleChat,
            color: const Color(0xFF4F42FF),
            subtitle: '${StrRes.sent}: ${logic.totalMessagesSent.value}',
          ),
        ),
        12.horizontalSpace,
        Expanded(
          child: _buildStatCard(
            title: StrRes.conversations,
            value: '${logic.totalConversations.value}',
            icon: HugeIcons.strokeRoundedUserMultiple,
            color: const Color(0xFF34D399),
            subtitle:
                '${StrRes.friends}: ${logic.totalFriends.value} | ${StrRes.groups}: ${logic.totalGroups.value}',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required List<List<dynamic>> icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
            const Color(0xFFF8FAFC),
          ],
          stops: const [0.05, 0.3],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30.w,
                  height: 30.h,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.7),
                        offset: const Offset(-0.5, -0.5),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: HugeIcon(
                    icon: icon,
                    color: color,
                    size: 15.w,
                  ),
                ),
                8.horizontalSpace,
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title.replaceAll(' ', '\n'),
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                        letterSpacing: 0.3,
                        height: 1.2,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ),
              ],
            ),
            12.verticalSpace,
            Text(
              value,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF374151),
                shadows: [
                  Shadow(
                    color: Colors.white.withOpacity(0.8),
                    offset: const Offset(0.5, 0.5),
                    blurRadius: 0.5,
                  ),
                ],
              ),
            ),
            6.verticalSpace,
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9CA3AF),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    return _buildSectionCard(
      title: StrRes.sevenDayActivity,
      icon: HugeIcons.strokeRoundedAnalytics02,
      color: const Color(0xFFA78BFA),
      child: Column(
        children: [
          16.verticalSpace,
          SizedBox(
            height: 140.h,
            child: Obx(() {
              final data = logic.weeklyActivity;
              if (data.isEmpty) return _buildEmptyChart();

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.entries.map((entry) {
                  final maxValue = data.values.isEmpty
                      ? 1
                      : data.values.reduce((a, b) => a > b ? a : b);
                  // Giảm chiều cao bar để chừa chỗ cho text
                  final height = maxValue == 0
                      ? 15.h
                      : (entry.value / maxValue * 70.h).clamp(15.h, 70.h);

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${entry.value}',
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          4.verticalSpace,
                          Container(
                            width: double.infinity,
                            height: height,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFFA78BFA),
                                  const Color(0xFFA78BFA).withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                          4.verticalSpace,
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTypeChart() {
    return _buildSectionCard(
      title: StrRes.messageTypes,
      icon: HugeIcons.strokeRoundedPieChart,
      color: const Color(0xFFFBBF24),
      child: Column(
        children: [
          16.verticalSpace,
          Obx(() {
            final stats = logic.messageTypeStats;
            if (stats.isEmpty) return _buildEmptyChart();

            return Column(
              children: stats.entries.map((entry) {
                final total =
                    stats.values.fold<int>(0, (sum, value) => sum + value);
                final percentage =
                    total == 0 ? 0.0 : (entry.value / total * 100);

                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Row(
                    children: [
                      _getMessageTypeIcon(entry.key),
                      12.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _getMessageTypeName(entry.key),
                                  style: TextStyle(
                                    fontFamily: 'FilsonPro',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                                Text(
                                  '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                    fontFamily: 'FilsonPro',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                            4.verticalSpace,
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: const Color(0xFFE5E7EB),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getMessageTypeColor(entry.key),
                                ),
                                minHeight: 6.h,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopContacts() {
    return _buildSectionCard(
      title: StrRes.topFriends,
      icon: HugeIcons.strokeRoundedUser,
      color: const Color(0xFF34D399),
      child: Column(
        children: [
          16.verticalSpace,
          Obx(() {
            final contacts = logic.topContacts;
            if (contacts.isEmpty) {
              return _buildEmptyList(StrRes.noFriendData);
            }

            return Column(
              children: contacts.asMap().entries.map((entry) {
                final index = entry.key;
                final contact = entry.value;

                return _buildRankingItem(
                  rank: index + 1,
                  name: contact.name,
                  subtitle:
                      '${_formatMessageCount(contact.messageCount)} ${StrRes.messagesCount}',
                  avatar: contact.avatar,
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopGroups() {
    return _buildSectionCard(
      title: StrRes.topGroups,
      icon: HugeIcons.strokeRoundedUserGroup,
      color: const Color(0xFFF9A8D4),
      child: Column(
        children: [
          16.verticalSpace,
          Obx(() {
            final groups = logic.topGroups;
            if (groups.isEmpty) {
              return _buildEmptyList(StrRes.noGroupData);
            }

            return Column(
              children: groups.asMap().entries.map((entry) {
                final index = entry.key;
                final group = entry.value;

                return _buildRankingItem(
                  rank: index + 1,
                  name: group.name,
                  isGroup: true,
                  subtitle:
                      '${_formatMessageCount(group.messageCount)} ${StrRes.messagesCount}',
                  avatar: group.avatar,
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<List<dynamic>> icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
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
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30.w,
                  height: 30.h,
                  child: HugeIcon(
                    icon: icon,
                    color: color,
                    size: 20,
                  ),
                ),
                16.horizontalSpace,
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildRankingItem({
    required int rank,
    required String name,
    required String subtitle,
    String? avatar,
    bool isGroup = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: _getRankColor(rank).withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          12.horizontalSpace,
          AvatarView(
            width: 36.w,
            height: 36.h,
            url: avatar,
            text: name,
            isCircle: true,
            isGroup: isGroup,
          ),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                2.verticalSpace,
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 100.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedBarChart,
              size: 32,
              color: Color(0xFFD1D5DB),
            ),
            8.verticalSpace,
            Text(
              StrRes.noData,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyList(String message) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  Widget _getMessageTypeIcon(String type) {
    List<List<dynamic>> iconData;
    Color color;

    switch (type) {
      case 'Text':
        iconData = HugeIcons.strokeRoundedBubbleChat;
        color = const Color(0xFF4F42FF);
        break;
      case 'Image':
        iconData = HugeIcons.strokeRoundedImage01;
        color = const Color(0xFF34D399);
        break;
      case 'Voice':
        iconData = HugeIcons.strokeRoundedMic01;
        color = const Color(0xFFFBBF24);
        break;
      case 'Video':
        iconData = HugeIcons.strokeRoundedVideo01;
        color = const Color(0xFFF87171);
        break;
      case 'File':
        iconData = HugeIcons.strokeRoundedFile01;
        color = const Color(0xFFA78BFA);
        break;
      default:
        iconData = HugeIcons.strokeRoundedCircle;
        color = const Color(0xFF6B7280);
        break;
    }

    return HugeIcon(
      icon: iconData,
      color: color,
      size: 20,
    );
  }

  String _getMessageTypeName(String type) {
    switch (type) {
      case 'Text':
        return StrRes.textMessages;
      case 'Image':
        return StrRes.imageMessages;
      case 'Voice':
        return StrRes.voiceMessages;
      case 'Video':
        return StrRes.videoMessages;
      case 'File':
        return StrRes.fileMessages;
      case 'Custom':
        return StrRes.otherMessages;
      default:
        return type;
    }
  }

  Color _getMessageTypeColor(String type) {
    switch (type) {
      case 'Text':
        return const Color(0xFF4F42FF);
      case 'Image':
        return const Color(0xFF34D399);
      case 'Voice':
        return const Color(0xFFFBBF24);
      case 'Video':
        return const Color(0xFFF87171);
      case 'File':
        return const Color(0xFFA78BFA);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String _formatMessageCount(int count) {
    return count >= 100 ? '100+' : count.toString();
  }
}
