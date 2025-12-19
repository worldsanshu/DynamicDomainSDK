// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ToastType { success, warning, error, info }

class AppToast {
  AppToast._();

  // Track all active toasts for stacking
  static final List<_ToastEntry> _activeToasts = [];

  // Notify all toasts to update their positions
  static final ValueNotifier<int> _updateNotifier = ValueNotifier(0);

  /// Hiển thị Toast - Các toast sẽ chồng lên nhau
  static void showToast(
    String msg, {
    ToastType type = ToastType.error,
    Duration? duration,
  }) {
    // 1. Kiểm tra chuỗi rỗng
    if (msg.trim().isEmpty) return;

    // 2. Get overlay
    final overlay = _getOverlay();
    if (overlay == null) return;

    // 3. Xác định Style
    Color mainColor;
    Color bgColor;
    IconData iconData;

    switch (type) {
      case ToastType.success:
        mainColor = const Color(0xFF10B981);
        bgColor = const Color(0xFFECFDF5);
        iconData = CupertinoIcons.checkmark_circle_fill;
        break;
      case ToastType.warning:
        mainColor = const Color(0xFFF59E0B);
        bgColor = const Color(0xFFFFFBEB);
        iconData = CupertinoIcons.exclamationmark_triangle_fill;
        break;
      case ToastType.error:
        mainColor = const Color(0xFFEF4444);
        bgColor = const Color(0xFFFEF2F2);
        iconData = CupertinoIcons.xmark_circle_fill;
        break;
      case ToastType.info:
        mainColor = const Color(0xFF3B82F6);
        bgColor = const Color(0xFFEFF6FF);
        iconData = CupertinoIcons.info_circle_fill;
        break;
    }

    // 4. Create overlay entry
    late OverlayEntry overlayEntry;
    late _ToastEntry toastEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: msg,
        mainColor: mainColor,
        bgColor: bgColor,
        iconData: iconData,
        toastEntry: toastEntry,
        duration: duration ?? const Duration(milliseconds: 2000),
        onDismiss: () {
          _removeToast(toastEntry);
        },
        updateNotifier: _updateNotifier,
        getIndex: () => _activeToasts.indexOf(toastEntry),
      ),
    );

    toastEntry = _ToastEntry(overlayEntry);
    _activeToasts.add(toastEntry);

    // 5. Insert overlay
    overlay.insert(overlayEntry);

    // Notify to update positions
    _updateNotifier.value++;
  }

  static OverlayState? _getOverlay() {
    try {
      final context =
          WidgetsBinding.instance.focusManager.primaryFocus?.context;
      if (context != null) {
        return Overlay.of(context);
      }
      final navigatorState = Navigator.of(
        WidgetsBinding.instance.focusManager.primaryFocus?.context ??
            WidgetsBinding.instance.renderViewElement!,
        rootNavigator: true,
      );
      return navigatorState.overlay;
    } catch (e) {
      return null;
    }
  }

  static void _removeToast(_ToastEntry entry) {
    if (_activeToasts.contains(entry)) {
      entry.overlayEntry.remove();
      _activeToasts.remove(entry);
      // Notify remaining toasts to update their positions
      _updateNotifier.value++;
    }
  }
}

class _ToastEntry {
  final OverlayEntry overlayEntry;
  _ToastEntry(this.overlayEntry);
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color mainColor;
  final Color bgColor;
  final IconData iconData;
  final _ToastEntry toastEntry;
  final Duration duration;
  final VoidCallback onDismiss;
  final ValueNotifier<int> updateNotifier;
  final int Function() getIndex;

  const _ToastWidget({
    required this.message,
    required this.mainColor,
    required this.bgColor,
    required this.iconData,
    required this.toastEntry,
    required this.duration,
    required this.onDismiss,
    required this.updateNotifier,
    required this.getIndex,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.getIndex();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();

    // Listen for position updates
    widget.updateNotifier.addListener(_onPositionUpdate);

    // Auto dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _onPositionUpdate() {
    if (mounted) {
      final newIndex = widget.getIndex();
      if (newIndex != _currentIndex && newIndex >= 0) {
        setState(() {
          _currentIndex = newIndex;
        });
      }
    }
  }

  void _dismiss() async {
    widget.updateNotifier.removeListener(_onPositionUpdate);
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    widget.updateNotifier.removeListener(_onPositionUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    // Stack toasts with small offset (8px) for subtle stacking effect
    final topPosition = topPadding + 10.h + (_currentIndex * 8.h);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      top: topPosition,
      left: 16.w,
      right: 16.w,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity!.abs() > 100) {
                  _dismiss();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: widget.bgColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: widget.mainColor.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      widget.iconData,
                      color: widget.mainColor,
                      size: 24.w,
                    ),
                    12.horizontalSpace,
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1F2937),
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    8.horizontalSpace,
                    GestureDetector(
                      onTap: _dismiss,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Icon(
                          CupertinoIcons.xmark,
                          color: const Color(0xFF6B7280),
                          size: 18.w,
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
