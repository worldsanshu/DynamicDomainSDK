import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

/// Helper class to manage the message overlay singleton
class MessageOverlayHelper {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  /// Capture widget to image using RepaintBoundary
  static Future<Uint8List?> _captureWidget(
      RenderRepaintBoundary boundary) async {
    try {
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing widget: $e');
      return null;
    }
  }

  static Future<void> show({
    required BuildContext context,
    required RenderRepaintBoundary captureBoundary,
    required bool isISend,
    required List<MenuInfo> menus,
    VoidCallback? onDismiss,
  }) async {
    if (_isVisible) return;

    // Check if context is valid before capturing
    if (!context.mounted) return;

    // Get overlay reference BEFORE any async operations
    final OverlayState? overlay;
    try {
      overlay = Overlay.of(context, rootOverlay: true);
    } catch (e) {
      debugPrint('Error getting overlay: $e');
      return;
    }

    // Capture the message widget first
    final imageBytes = await _captureWidget(captureBoundary);

    // Check if context is still valid after async operation
    if (!context.mounted) return;

    _overlayEntry = OverlayEntry(
      builder: (ctx) => MessageOverlay(
        messageImage: imageBytes,
        isISend: isISend,
        menus: menus,
        onDismiss: () {
          hide();
          onDismiss?.call();
        },
      ),
    );

    _isVisible = true;

    // Insert overlay immediately
    try {
      if (_overlayEntry != null && overlay != null) {
        overlay.insert(_overlayEntry!);
      }
    } catch (e) {
      debugPrint('Error inserting overlay: $e');
      _isVisible = false;
      _overlayEntry = null;
    }
  }

  static void hide() {
    if (!_isVisible) return;
    _isVisible = false;
    try {
      _overlayEntry?.remove();
    } catch (e) {
      debugPrint('Error removing overlay: $e');
    }
    _overlayEntry = null;
  }

  static bool get isVisible => _isVisible;
}

/// The overlay widget that displays message preview with menu
class MessageOverlay extends StatefulWidget {
  final Uint8List? messageImage;
  final bool isISend;
  final List<MenuInfo> menus;
  final VoidCallback? onDismiss;

  const MessageOverlay({
    super.key,
    this.messageImage,
    required this.isISend,
    required this.menus,
    this.onDismiss,
  });

  @override
  State<MessageOverlay> createState() => _MessageOverlayState();
}

class _MessageOverlayState extends State<MessageOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Blurred background
            GestureDetector(
              onTap: _dismiss,
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: 8 * _fadeAnimation.value,
                  sigmaY: 8 * _fadeAnimation.value,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.3 * _fadeAnimation.value),
                ),
              ),
            ),

            // Centered content
            Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: widget.isISend
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        // Message preview image
                        if (widget.messageImage != null)
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: 250.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Image.memory(
                                  widget.messageImage!,
                                  scale:
                                      3.0, // Match the pixelRatio used in capture
                                ),
                              ),
                            ),
                          ),

                        SizedBox(height: 12.h),

                        // Menu options
                        _buildMenuOptions(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuOptions() {
    return Container(
      constraints: BoxConstraints(
        minWidth: 180.w,
        maxWidth: 240.w,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.08),
            offset: Offset(0, 4.h),
            blurRadius: 12.r,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.menus.asMap().entries.map((entry) {
              final index = entry.key;
              final menu = entry.value;
              final isLast = index == widget.menus.length - 1;
              return _menuItem(
                icon: menu.icon,
                label: menu.text,
                onTap: menu.onTap,
                isLast: isLast,
                enabled: menu.enabled,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required String icon,
    required String label,
    Function()? onTap,
    bool isLast = false,
    bool enabled = true,
  }) =>
      InkWell(
        onTap: enabled
            ? () {
                _dismiss();
                onTap?.call();
              }
            : null,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(
                      color: Color(0xFFE5E5EA),
                      width: 0.5,
                    ),
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: label.toText
                  ..style = TextStyle(
                    color: enabled
                        ? const Color(0xFF0C1C33)
                        : const Color(0xFF0C1C33).withOpacity(0.4),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  )
                  ..maxLines = 1
                  ..overflow = TextOverflow.ellipsis,
              ),
              SizedBox(width: 12.w),
              icon.toImage
                ..width = 20.w
                ..height = 20.h
                ..color =
                    enabled ? null : const Color(0xFF0C1C33).withOpacity(0.4)
                ..fit = BoxFit.contain,
            ],
          ),
        ),
      );
}
