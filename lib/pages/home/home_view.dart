import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim_common/openim_common.dart';

import '../contacts/contacts_view.dart';
import '../conversation/conversation_view.dart';
import '../global_search/global_search_view.dart';
import '../mine/mine_view.dart';
import '../workbench/workbench_view.dart';
import 'home_logic.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<HomeLogic>();
    return Obx(() => Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: LazyTabView(
          currentIndex: logic.index.value,
          tabCount: logic.discoverPageURL.isNotEmpty ? 5 : 4,
          tabBuilder: (context, index) {
            switch (index) {
              case 0:
                return ConversationPage();
              case 1:
                return const ContactsPage();
              case 2:
                return const GlobalSearchPage();
              case 3:
                if (logic.discoverPageURL.isNotEmpty) {
                  return WorkbenchPage();
                } else {
                  return MinePage();
                }
              case 4:
                return MinePage();
              default:
                return ConversationPage();
            }
          },
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(width: 0.1)),
          ),
          height: 70.h,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home/Conversation tab
              Stack(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      logic.switchTab(0);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 30.0),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedHome01,
                        color: logic.index.value == 0
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF6B7280),
                        size: 24.w,
                      ),
                    ),
                  ),
                  if (logic.unreadMsgCount.value > 0)
                    Positioned(
                      top: 5.h,
                      right: 10.w,
                      child: Container(
                        constraints:
                            BoxConstraints(minWidth: 24.w, minHeight: 24.h),
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            logic.unreadMsgCount.value > 99
                                ? '99+'
                                : logic.unreadMsgCount.value.toString(),
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Contacts tab
              Stack(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      logic.switchTab(1);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 30.0),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedUserMultiple02,
                        color: logic.index.value == 1
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF6B7280),
                        size: 24.w,
                      ),
                    ),
                  ),
                  if (logic.unhandledCount.value > 0)
                    Positioned(
                      top: 5.h,
                      right: 10.w,
                      child: Container(
                        constraints:
                            BoxConstraints(minWidth: 24.w, minHeight: 24.h),
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            logic.unhandledCount.value > 99
                                ? '99+'
                                : logic.unhandledCount.value.toString(),
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Global Search tab
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  logic.switchTab(2);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 30.0),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedSearch01,
                    color: logic.index.value == 2
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF6B7280),
                    size: 24.w,
                  ),
                ),
              ),
              // User/Profile tab
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  logic.switchTab(3);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 30.0),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedUser03,
                    color: logic.index.value == 3
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF6B7280),
                    size: 24.w,
                  ),
                ),
              )
            ],
          ),
        )));
  }

  void _showActionBottomSheet(BuildContext context) {
    final logic = Get.find<HomeLogic>();
    Get.bottomSheet(
      barrierColor: Colors.transparent,
      Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32.r),
                topRight: Radius.circular(32.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.08),
                  offset: const Offset(0, -3),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
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
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9CA3AF).withOpacity(0.06),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFF3F4F6),
                      width: 1,
                    ),
                  ),
                  child: AnimationLimiter(
                    child: Column(
                      children: [
                        _buildActionItem(
                          icon: HugeIcons.strokeRoundedAiScan,
                          title: StrRes.scan,
                          onTap: () {
                            Get.back();
                            logic.scan();
                          },
                          index: 0,
                        ),
                        _buildDivider(),
                        _buildActionItem(
                          icon: HugeIcons.strokeRoundedUserAdd01,
                          title: StrRes.addFriend,
                          onTap: () {
                            Get.back();
                            logic.addFriend();
                          },
                          index: 1,
                        ),
                        _buildDivider(),
                        _buildActionItem(
                          icon: HugeIcons.strokeRoundedUserGroup,
                          title: StrRes.addGroup,
                          onTap: () {
                            Get.back();
                            logic.addGroup();
                          },
                          index: 2,
                        ),
                        _buildDivider(),
                        _buildActionItem(
                          icon: HugeIcons.strokeRoundedUserGroup02,
                          title: StrRes.createGroup,
                          onTap: () {
                            Get.back();
                            logic.createGroup();
                          },
                          index: 3,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30.h),

                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    width: MediaQuery.of(context).size.width / 3 + 4,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(50),
                        left: Radius.circular(50),
                      ),
                    ),
                    child: Text(StrRes.cancel,
                        style: const TextStyle(
                            fontFamily: 'FilsonPro',
                            fontWeight: FontWeight.w500)),
                  ),
                ),
                SizedBox(height: 15.h),
              ],
            ),
          ),
        ],
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildDivider() {
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
}

/// Custom widget for lazy loading tabs
/// Only creates pages when they are first accessed
class LazyTabView extends StatefulWidget {
  final int currentIndex;
  final int tabCount;
  final Widget Function(BuildContext context, int index) tabBuilder;

  const LazyTabView({
    super.key,
    required this.currentIndex,
    required this.tabCount,
    required this.tabBuilder,
  });

  @override
  State<LazyTabView> createState() => _LazyTabViewState();
}

class _LazyTabViewState extends State<LazyTabView> {
  // Track which tabs have been created
  final Map<int, Widget> _cachedTabs = {};

  @override
  void initState() {
    super.initState();
    // Create the initial tab
    _cachedTabs[widget.currentIndex] =
        widget.tabBuilder(context, widget.currentIndex);
  }

  @override
  void didUpdateWidget(LazyTabView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If we switched to a new tab that hasn't been created yet, create it
    if (widget.currentIndex != oldWidget.currentIndex &&
        !_cachedTabs.containsKey(widget.currentIndex)) {
      _cachedTabs[widget.currentIndex] =
          widget.tabBuilder(context, widget.currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.currentIndex,
      children: List.generate(widget.tabCount, (index) {
        // Return the cached widget if it exists, otherwise return an empty container
        // The widget will be created when the tab is first accessed
        return _cachedTabs[index] ?? Container();
      }),
    );
  }
}
