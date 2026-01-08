import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
                      child: Icon(
                        CupertinoIcons.house_fill,
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
                            BoxConstraints(minWidth: 20.w, minHeight: 20.h),
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
                              fontSize: 10.sp,
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
                      child: Icon(
                        CupertinoIcons.person_2_fill,
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
                            BoxConstraints(minWidth: 20.w, minHeight: 20.h),
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
                              fontSize: 10.sp,
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
                  child: Icon(
                    CupertinoIcons.search,
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
                  child: Icon(
                    CupertinoIcons.person_fill,
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
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Create the initial tab here where context is safe to use
    if (!_initialized) {
      _initialized = true;
      _cachedTabs[widget.currentIndex] =
          widget.tabBuilder(context, widget.currentIndex);
    }
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
    // Ensure initial tab is created if not yet (fallback)
    if (!_cachedTabs.containsKey(widget.currentIndex)) {
      _cachedTabs[widget.currentIndex] =
          widget.tabBuilder(context, widget.currentIndex);
    }

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
