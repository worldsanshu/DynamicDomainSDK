// ignore_for_file: deprecated_member_use, unused_element

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim/widgets/gradient_scaffold.dart';
import 'group_online_info_logic.dart';

class GroupOnlineInfoPage extends StatelessWidget {
  GroupOnlineInfoPage({super.key});

  final logic = Get.find<GroupOnlineInfoLogic>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => GradientScaffold(
          title: StrRes.onlineInfo,
          subtitle: StrRes.groupMemberStatus,
          showBackButton: true,
          onBack: () =>
              logic.showInfos.value ? Get.back() : logic.changeShowInfos(),
          body: AnimationLimiter(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                if (logic.showInfos.value)
                  SliverPadding(
                    padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 450),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            verticalOffset: 50.0,
                            curve: Curves.easeOutQuart,
                            child: FadeInAnimation(child: widget),
                          ),
                          children: [
                            _buildOnlineInfoCard(
                              title: StrRes.currentlyOnline,
                              ids: logic.currentlyOnline,
                              keyType: 'currentlyOnline',
                            ),
                            _buildOnlineInfoCard(
                              title: StrRes.onlineLast24Hours,
                              ids: logic.onlineLast24Hours,
                              keyType: 'onlineLast24Hours',
                            ),
                            _buildOnlineInfoCard(
                              title: StrRes.onlineLast3Days,
                              ids: logic.onlineLast3Days,
                              keyType: 'onlineLast3Days',
                            ),
                            _buildOnlineInfoCard(
                              title: StrRes.onlineLast7Days,
                              ids: logic.onlineLast7Days,
                              keyType: 'onlineLast7Days',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (!logic.showInfos.value) ...[
                  SliverToBoxAdapter(
                    child: (logic.memberList.isNotEmpty)
                        ? _buildSectionTitle(StrRes.groupMember)
                        : SizedBox(height: 8.h),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, int index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 450),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            curve: Curves.easeOutQuart,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child:
                                    _buildMemberTile(logic.memberList[index]),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: logic.memberList.length,
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                ]
              ],
            ),
          ),
        ));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'FilsonPro',
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF212121),
          shadows: [
            Shadow(
              color: Colors.white.withOpacity(0.9),
              offset: const Offset(0.5, 0.5),
              blurRadius: 0.5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTile(GroupMembersInfo info) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => logic.viewMemberInfo(info),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9CA3AF).withOpacity(0.1),
                        blurRadius: 8.r,
                      ),
                    ],
                  ),
                  child: AvatarView(
                    url: info.faceURL,
                    text: info.nickname,
                    width: 44.w,
                    height: 44.h,
                    textStyle: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    isCircle: true,
                  ),
                ),
                16.horizontalSpace,
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.nickname ?? '',
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (info.roleLevel == GroupRoleLevel.owner ||
                          info.roleLevel == GroupRoleLevel.admin) ...[
                        4.verticalSpace,
                        Text(
                          info.roleLevel == GroupRoleLevel.owner
                              ? StrRes.groupOwner
                              : StrRes.groupAdmin,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  CupertinoIcons.person_crop_circle,
                  size: 20.w,
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineInfoCard({
    required String title,
    required List<String> ids,
    required String keyType,
  }) {
    final count = ids.length;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            logic.expandedGroup.value = '$title($count)';
            logic.loadGroupMemberList(ids);
            logic.showInfos.value = false;
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(keyType),
                  size: 24.w,
                  color: _getStatusColor(keyType),
                ),
                16.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      4.verticalSpace,
                      Text(
                        '$count ${count == 1 ? StrRes.member : StrRes.members}',
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(keyType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(keyType),
                    ),
                  ),
                ),
                8.horizontalSpace,
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 16.w,
                  color: const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String keyType) {
    switch (keyType) {
      case 'currentlyOnline':
        return const Color(0xFF10B981); // Green
      case 'onlineLast24Hours':
        return const Color(0xFF3B82F6); // Blue
      case 'onlineLast3Days':
        return const Color(0xFF8B5CF6); // Purple
      case 'onlineLast7Days':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getStatusIcon(String keyType) {
    switch (keyType) {
      case 'currentlyOnline':
        return CupertinoIcons.circle;
      case 'onlineLast24Hours':
        return CupertinoIcons.clock;
      case 'onlineLast3Days':
        return CupertinoIcons.calendar;
      case 'onlineLast7Days':
        return CupertinoIcons.calendar_badge_plus;
      default:
        return CupertinoIcons.person;
    }
  }
}
