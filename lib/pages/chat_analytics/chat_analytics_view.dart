// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:openim/widgets/custom_buttom.dart';
import 'package:openim/widgets/gradient_scaffold.dart';
import 'package:openim_common/openim_common.dart';

import 'chat_analytics_logic.dart';

class ChatAnalyticsView extends StatelessWidget {
  final logic = Get.find<ChatAnalyticsLogic>();

  ChatAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => GradientScaffold(
          title: StrRes.chatAnalytics,
          subtitle: StrRes.usageAnalyticsInsights,
          showBackButton: true,
          trailing: CustomButton(
            onTap: logic.refreshData,
            icon: CupertinoIcons.refresh,
            color: Colors.white,
          ),
          body: logic.isLoading.value ? _buildLoadingView() : _buildContent(),
        ));
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: logic.refreshData,
      color: const Color(0xFF4F42FF),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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
                _buildOverviewCards(),
                16.verticalSpace,
                _buildActivityChart(),
                16.verticalSpace,
                _buildMessageTypeChart(),
                16.verticalSpace,
                _buildTopContacts(),
                16.verticalSpace,
                _buildTopGroups(),
                30.verticalSpace,
              ],
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
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F42FF)),
              strokeWidth: 3,
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
            icon: CupertinoIcons.chat_bubble_2,
            color: const Color(0xFF4F42FF),
            subtitle: '${StrRes.sent}: ${logic.totalMessagesSent.value}',
          ),
        ),
        12.horizontalSpace,
        Expanded(
          child: _buildStatCard(
            title: StrRes.conversations,
            value: '${logic.totalConversations.value}',
            icon: CupertinoIcons.person_2,
            color: const Color(0xFF10B981),
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
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20.w,
                ),
              ),
              8.horizontalSpace,
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          16.verticalSpace,
          Text(
            value,
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          4.verticalSpace,
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9CA3AF),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart() {
    return _buildSectionCard(
      title: StrRes.sevenDayActivity,
      icon: CupertinoIcons.chart_bar,
      color: const Color(0xFFA78BFA),
      child: Column(
        children: [
          20.verticalSpace,
          SizedBox(
            height: 160.h,
            child: Obx(() {
              final data = logic.weeklyActivity;
              if (data.isEmpty) return _buildEmptyChart();

              final maxValue = data.values.isEmpty
                  ? 1
                  : data.values.reduce((a, b) => a > b ? a : b);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: data.entries.map((entry) {
                  final height = maxValue == 0
                      ? 10.h
                      : (entry.value / maxValue * 100.h).clamp(10.h, 100.h);

                  final isToday = entry.key == data.keys.last;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (entry.value > 0)
                        Text(
                          '${entry.value}',
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: isToday
                                ? const Color(0xFFA78BFA)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      6.verticalSpace,
                      Container(
                        width: 24.w,
                        height: height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isToday
                                ? [
                                    const Color(0xFFA78BFA),
                                    const Color(0xFFC4B5FD)
                                  ]
                                : [
                                    const Color(0xFFE5E7EB),
                                    const Color(0xFFF3F4F6)
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      8.verticalSpace,
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 10.sp,
                          fontWeight:
                              isToday ? FontWeight.w600 : FontWeight.w500,
                          color: isToday
                              ? const Color(0xFFA78BFA)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
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
      icon: CupertinoIcons.chart_pie,
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
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _getMessageTypeIcon(entry.key),
                          12.horizontalSpace,
                          Expanded(
                            child: Text(
                              _getMessageTypeName(entry.key),
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ),
                          Text(
                            '${entry.value}',
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                      8.verticalSpace,
                      Stack(
                        children: [
                          Container(
                            height: 8.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: percentage / 100,
                            child: Container(
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: _getMessageTypeColor(entry.key),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                        ],
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
      icon: CupertinoIcons.person,
      color: const Color(0xFF10B981),
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
                return _buildRankingItem(
                  rank: entry.key + 1,
                  name: entry.value.name,
                  subtitle:
                      '${_formatMessageCount(entry.value.messageCount)} ${StrRes.messagesCount}',
                  avatar: entry.value.avatar,
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
      icon: CupertinoIcons.person_3,
      color: const Color(0xFFEC4899),
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
                return _buildRankingItem(
                  rank: entry.key + 1,
                  name: entry.value.name,
                  isGroup: true,
                  subtitle:
                      '${_formatMessageCount(entry.value.messageCount)} ${StrRes.messagesCount}',
                  avatar: entry.value.avatar,
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
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20.w,
                  ),
                ),
                12.horizontalSpace,
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: child,
          ),
        ],
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
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.h,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
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
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          12.horizontalSpace,
          AvatarView(
            width: 40.w,
            height: 40.h,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.chart_bar,
            size: 32.w,
            color: const Color(0xFFD1D5DB),
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
    );
  }

  Widget _buildEmptyList(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          fontFamily: 'FilsonPro',
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _getMessageTypeIcon(String type) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'Text':
        iconData = CupertinoIcons.chat_bubble;
        color = const Color(0xFF4F42FF);
        break;
      case 'Image':
        iconData = CupertinoIcons.photo;
        color = const Color(0xFF10B981);
        break;
      case 'Voice':
        iconData = CupertinoIcons.mic;
        color = const Color(0xFFF59E0B);
        break;
      case 'Video':
        iconData = CupertinoIcons.videocam;
        color = const Color(0xFFEF4444);
        break;
      case 'File':
        iconData = CupertinoIcons.doc;
        color = const Color(0xFFA78BFA);
        break;
      default:
        iconData = CupertinoIcons.circle;
        color = const Color(0xFF6B7280);
        break;
    }

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        iconData,
        color: color,
        size: 16.w,
      ),
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
        return const Color(0xFF10B981);
      case 'Voice':
        return const Color(0xFFF59E0B);
      case 'Video':
        return const Color(0xFFEF4444);
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
        return const Color(0xFF9CA3AF); // Silver
      case 3:
        return const Color(0xFFB45309); // Bronze
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String _formatMessageCount(int count) {
    return count >= 100 ? '100+' : count.toString();
  }
}
