// ignore_for_file: deprecated_member_use, unused_field, library_private_types_in_public_api

import 'package:chat_bottom_container/panel_container.dart';
import 'package:chat_bottom_container/typedef.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/cupertino.dart';

double kInputBoxMinHeight = 32.h;

enum PanelType {
  none,
  keyboard,
  emoji,
  tool,
}

class ChatInputBox extends StatefulWidget {
  const ChatInputBox({
    super.key,
    required this.toolbox,
    required this.voiceRecordBar,
    required this.emojiView,
    required this.multiOpToolbox,
    this.allAtMap = const {},
    this.atCallback,
    this.controller,
    required this.focusNode,
    this.style,
    this.atStyle,
    this.inputFormatters,
    this.enabled = true,
    this.isMultiModel = false,
    this.isNotInGroup = false,
    this.hintText,
    this.openAtList,
    this.forceCloseToolboxSub,
    this.quoteContent,
    this.onClearQuote,
    this.onSend,
    required this.callbackKeyboardHeight,
    this.onTapAlbum,
    this.onTapCamera,
    this.onTapFile,
    this.onTapCard,
    this.onSendVoice,
    this.stateKey,
  });
  final AtTextCallback? atCallback;
  final Map<String, String> allAtMap;
  final FocusNode focusNode;
  final TextEditingController? controller;
  final TextStyle? style;
  final TextStyle? atStyle;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool isMultiModel;
  final bool isNotInGroup;
  final String? hintText;
  final String Function()? openAtList;
  final Widget toolbox;
  final Widget voiceRecordBar;
  final Widget emojiView;
  final Widget multiOpToolbox;
  final Stream? forceCloseToolboxSub;
  final String? quoteContent;
  final Function()? onClearQuote;
  final ValueChanged<String>? onSend;
  final Function()? onTapAlbum;
  final Function()? onTapCamera;
  final Function()? onTapFile;
  final Function()? onTapCard;
  final Function(int sec, String path)? onSendVoice;
  final GlobalKey<_ChatInputBoxState>? stateKey;

  final void Function(double) callbackKeyboardHeight;

  @override
  State<ChatInputBox> createState() => _ChatInputBoxState();
}

class _ChatInputBoxState extends State<ChatInputBox>
    with TickerProviderStateMixin {
  bool _toolsVisible = false;
  bool _emojiVisible = false;
  bool _leftKeyboardButton = false;
  bool _rightKeyboardButton = false;
  bool _sendButtonVisible = false;
  bool _isTextFieldFocused = false;
  bool _actionButtonsExpanded =
      true; // New state for expanded/collapsed buttons

  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  late AnimationController _buttonsExpandController;
  late Animation<double> _buttonsExpandAnimation;

  bool get _showQuoteView => IMUtils.isNotNullEmptyStr(widget.quoteContent);

  final panelController = ChatBottomPanelContainerController<PanelType>();
  PanelType currentPanelType = PanelType.none;

  // GlobalKey for More button to get its position
  final GlobalKey _moreButtonKey = GlobalKey();

  // GlobalKey for voice record bar to call cancel/send
  final GlobalKey<ChatTapToRecordBarState> _voiceRecordBarKey =
      GlobalKey<ChatTapToRecordBarState>();

  @override
  void initState() {
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutQuart,
    ));

    _buttonsExpandController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
      value: 1.0, // Start expanded
    );

    _buttonsExpandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonsExpandController,
      curve: Curves.easeOutCubic,
    ));

    widget.focusNode.addListener(() {
      if (widget.focusNode.hasFocus) {
        setState(() {
          _toolsVisible = false;
          _emojiVisible = false;
          _leftKeyboardButton = false;
          _rightKeyboardButton = false;
          _isTextFieldFocused = true;
        });
        // Force close any open panels when text field is focused
        // forceCloseAllPanels();
        _expandController.forward();
      } else {
        setState(() {
          _isTextFieldFocused = false;
        });
        // _expandController.reverse();
      }
    });

    widget.forceCloseToolboxSub?.listen((value) {
      if (!mounted) return;
      forceCloseAllPanels();
    });

    widget.controller?.addListener(_onTextChanged);

    super.initState();
  }

  void _onTextChanged() {
    final hasText = widget.controller!.text.isNotEmpty;
    setState(() {
      _sendButtonVisible = hasText;
    });

    // Auto-collapse buttons when user types, auto-expand when text is cleared
    if (hasText && _actionButtonsExpanded) {
      setState(() {
        _actionButtonsExpanded = false;
      });
      _buttonsExpandController.reverse();
    } else if (!hasText && !_actionButtonsExpanded) {
      setState(() {
        _actionButtonsExpanded = true;
      });
      _buttonsExpandController.forward();
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _buttonsExpandController.dispose();
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  // Claymorphism button widget
  Widget _buildClaymorphismButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? backgroundColor,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30.w,
        height: 30.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor ??
              (isActive
                  ? const Color(0xFF4F42FF).withOpacity(0.1)
                  : const Color(0xFFF9FAFB)),
          borderRadius: BorderRadius.circular(8.r),
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
        child: Icon(
          icon,
          size: 25.w,
          color: iconColor ??
              (isActive ? const Color(0xFF4F42FF) : const Color(0xFF6B7280)),
        ),
      ),
    );
  }

  // Right action button - shows Mic when empty/unfocused, Send when focused/has text
  Widget _buildRightActionButton() {
    // Logic:
    // - Mic icon: not focused AND no text
    // - Gray Send: focused but no text
    // - Blue Send: has text (regardless of focus)
    final hasText = _sendButtonVisible;
    final showMic = !_isTextFieldFocused && !hasText;

    return GestureDetector(
      onTap: showMic ? onTapSpeak : (hasText ? send : null),
      child: Container(
        width: 30.w,
        height: 30.h,
        decoration: BoxDecoration(
          color: hasText
              ? const Color(0xFF4F42FF) // Blue when has text
              : const Color(0xFFF9FAFB), // Gray background otherwise
          borderRadius: BorderRadius.circular(8.r),
          border: hasText
              ? null
              : Border.all(
                  color: const Color(0xFFF3F4F6),
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9CA3AF).withOpacity(0.06),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          showMic ? CupertinoIcons.mic : CupertinoIcons.paperplane,
          size: 20.w,
          color: hasText
              ? Colors.white // White icon when blue background
              : const Color(0xFF6B7280), // Gray icon otherwise
        ),
      ),
    );
  }

  // Claymorphism more (options) button for suffix
  Widget _buildMoreButton() {
    return GestureDetector(
      onTap: _showOptionsMenu,
      child: Container(
        key: _moreButtonKey,
        width: 30.w,
        height: 30.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8.r),
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
        child: Icon(
          Icons.attach_file,
          size: 24.w,
          color: const Color(0xFF6B7280),
        ),
      ),
    );
  }

  // Cancel button for voice mode
  Widget _buildCancelVoiceButton() {
    return GestureDetector(
      onTap: () => _voiceRecordBarKey.currentState?.cancelVoice(),
      child: Container(
        width: 30.w,
        height: 30.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF87171).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
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
        child: Icon(
          CupertinoIcons.xmark,
          size: 18.w,
          color: const Color(0xFFF87171),
        ),
      ),
    );
  }

  // Send button for voice mode
  Widget _buildSendVoiceButton() {
    return GestureDetector(
      onTap: () => _voiceRecordBarKey.currentState?.sendVoice(),
      child: Container(
        width: 30.w,
        height: 30.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF4F42FF),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9CA3AF).withOpacity(0.06),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(
          CupertinoIcons.paperplane_fill,
          size: 18.w,
          color: Colors.white,
        ),
      ),
    );
  }

  // Arrow toggle button for expanding/collapsing action buttons
  Widget _buildArrowToggleButton() {
    return GestureDetector(
      onTap: _toggleActionButtons,
      child: AnimatedBuilder(
        animation: _buttonsExpandAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _buttonsExpandAnimation.value * 3.14159, // 180 degrees
            child: Container(
              width: 30.w,
              height: 30.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8.r),
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
              child: Icon(
                CupertinoIcons.chevron_right,
                size: 18.w,
                color: const Color(0xFF6B7280),
              ),
            ),
          );
        },
      ),
    );
  }

  void _toggleActionButtons() {
    setState(() {
      _actionButtonsExpanded = !_actionButtonsExpanded;
    });
    if (_actionButtonsExpanded) {
      _buttonsExpandController.forward();
    } else {
      _buttonsExpandController.reverse();
    }
  }

  // Build the expandable action buttons row
  Widget _buildActionButtons() {
    return AnimatedBuilder(
      animation: _buttonsExpandAnimation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Arrow toggle button (visible when collapsed or has text)
            if (!_actionButtonsExpanded || _sendButtonVisible)
              _buildArrowToggleButton(),
            // Animated container for the action buttons (voice only)
            ClipRect(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: _actionButtonsExpanded ? (30.w) : 0,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Opacity(
                    opacity: _buttonsExpandAnimation.value,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        6.horizontalSpace,
                        // Voice button
                        _buildClaymorphismButton(
                          icon: CupertinoIcons.mic,
                          onTap: onTapSpeak,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_actionButtonsExpanded && !_leftKeyboardButton)
              8.horizontalSpace,
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) widget.controller?.clear();
    return widget.isNotInGroup
        ? const ChatDisableInputBox()
        : widget.isMultiModel
            ? widget.multiOpToolbox
            : Container(
                color: Colors.white,
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _expandAnimation,
                      builder: (context, child) {
                        return Container(
                          constraints:
                              BoxConstraints(minHeight: kInputBoxMinHeight),
                          padding: EdgeInsets.symmetric(
                              horizontal: 22.w, vertical: 6.h),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(
                                color: Color(0xFFF0F4F8),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Cancel button when in voice mode OR More button when not
                              if (_leftKeyboardButton)
                                _buildCancelVoiceButton()
                              else
                                _buildMoreButton(),
                              8.horizontalSpace,
                              Expanded(
                                child: _leftKeyboardButton
                                    ? ChatTapToRecordBar(
                                        key: _voiceRecordBarKey,
                                        onCancel: onTapLeftKeyboard,
                                        onSend: (sec, path) {
                                          widget.onSendVoice?.call(sec, path);
                                          onTapLeftKeyboard();
                                        },
                                      )
                                    : _textFiled,
                              ),
                              8.horizontalSpace,
                              // Send button when in voice mode OR Right action button when not
                              if (_leftKeyboardButton)
                                _buildSendVoiceButton()
                              else
                                _buildRightActionButton(),
                            ],
                          ),
                        );
                      },
                    ),
                    if (_showQuoteView)
                      _QuoteView(
                        content: widget.quoteContent!,
                        onClearQuote: widget.onClearQuote,
                      ),
                    _buildPanelContainer(),
                  ],
                ),
              );
  }

  hidePanel() {
    if (widget.focusNode.hasFocus) {
      widget.focusNode.unfocus();
    }
    if (ChatBottomPanelType.none == panelController.currentPanelType) return;
    panelController.updatePanelType(ChatBottomPanelType.none);
  }

  void forceCloseAllPanels() {
    setState(() {
      _toolsVisible = false;
      _emojiVisible = false;
      // Don't close voice mode (_leftKeyboardButton) when recording
      // This allows user to tap on chat list while recording voice
      _rightKeyboardButton = false;
    });
    if (ChatBottomPanelType.none != panelController.currentPanelType) {
      panelController.updatePanelType(ChatBottomPanelType.none);
    }
  }

  Widget _buildPanelContainer() {
    return ChatBottomPanelContainer<PanelType>(
      controller: panelController,
      inputFocusNode: widget.focusNode,
      otherPanelWidget: (type) {
        if (type == null) return const SizedBox.shrink();

        switch (type) {
          case PanelType.emoji:
            return widget.emojiView;
          case PanelType.tool:
            // Build toolbox with emoji callback
            return _buildOptionsToolbox();
          default:
            return const SizedBox.shrink();
        }
      },
      onPanelTypeChange: (panelType, data) {
        switch (panelType) {
          case ChatBottomPanelType.none:
            currentPanelType = PanelType.none;
            break;
          case ChatBottomPanelType.keyboard:
            currentPanelType = PanelType.keyboard;
            break;
          case ChatBottomPanelType.other:
            if (data == null) return;
            switch (data) {
              case PanelType.emoji:
                currentPanelType = PanelType.emoji;
                break;
              case PanelType.tool:
                currentPanelType = PanelType.tool;
                break;
              default:
                currentPanelType = PanelType.none;
                break;
            }
            break;
        }
        widget.callbackKeyboardHeight(_getKeyboardHeight());
      },
      safeAreaBottom: MediaQuery.of(context).padding.bottom,
    );
  }

  double _getKeyboardHeight() {
    double height = 300.h;
    final keyboardHeight = panelController.keyboardHeight;
    if (keyboardHeight != 0) {
      height = keyboardHeight;
    }
    return height;
  }

  void _showOptionsMenu() {
    if (!widget.enabled) return;

    // Unfocus text field completely
    if (widget.focusNode.hasFocus) {
      widget.focusNode.unfocus();
    }

    // Dismiss keyboard and wait for it to close completely
    FocusScope.of(context).unfocus();

    // Show the toolbox popup after keyboard is fully closed
    _showToolboxPopup();
  }

  void _showToolboxPopup() {
    // Wait for keyboard to close completely before showing popup
    Future.delayed(const Duration(milliseconds: 300), () {
      // Get the position of the More button
      final renderBox =
          _moreButtonKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final Offset offset = renderBox.localToGlobal(Offset.zero);

      // Extract callbacks from the widget.toolbox if it's ChatToolBox
      final albumCallback = (widget.toolbox as ChatToolBox?)?.onTapAlbum;
      final cameraCallback = (widget.toolbox as ChatToolBox?)?.onTapCamera;
      final fileCallback = (widget.toolbox as ChatToolBox?)?.onTapFile;
      final cardCallback = (widget.toolbox as ChatToolBox?)?.onTapCard;
      final callCallback = (widget.toolbox as ChatToolBox?)?.onTapCall;

      final items = [
        {
          'label': StrRes.toolboxAlbum,
          'icon': Icons.photo_library_outlined,
          'onTap': () => Permissions.photos(albumCallback),
        },
        {
          'label': StrRes.toolboxCamera,
          'icon': Icons.camera_alt_outlined,
          'onTap': () =>
              Permissions.cameraAndMicrophoneAndPhotos(cameraCallback),
        },
        {
          'label': StrRes.toolboxCard,
          'icon': Icons.person_outline,
          'onTap': cardCallback,
        },
        {
          'label': StrRes.toolboxFile,
          'icon': Icons.insert_drive_file_outlined,
          'onTap': () => Permissions.storage(fileCallback),
        },
        if (callCallback != null)
          {
            'label': StrRes.toolboxCall,
            'icon': Icons.call_outlined,
            'onTap': callCallback,
          },
      ];

      if (!mounted) return; // Check if widget is still mounted

      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.3),
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Stack(
            children: [
              // Popup menu positioned relative to button
              Positioned(
                left: offset.dx - 20.w,
                top: offset.dy - 50.h - (items.length * 56.h),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 200.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9CA3AF).withOpacity(0.2),
                          offset: const Offset(0, 8),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(items.length, (index) {
                            final item = items[index];
                            final isLast = index == items.length - 1;
                            return InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                Future.delayed(
                                    const Duration(milliseconds: 100), () {
                                  final callback = item['onTap'] as Function?;
                                  callback?.call();
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: !isLast
                                      ? Border(
                                          bottom: BorderSide(
                                            color: const Color(0xFFF3F4F6),
                                            width: 1,
                                          ),
                                        )
                                      : null,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 10.h,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 32.w,
                                      height: 32.h,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4F42FF)
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Icon(
                                        item['icon'] as IconData,
                                        size: 16.w,
                                        color: const Color(0xFF4F42FF),
                                      ),
                                    ),
                                    8.horizontalSpace,
                                    Expanded(
                                      child: Text(
                                        item['label'] as String,
                                        style: TextStyle(
                                          fontFamily: 'FilsonPro',
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF374151),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildOptionsToolbox() {
    // Build a custom toolbox with all options including emoji
    if (widget.toolbox is ChatToolBox) {
      // If we have access to the toolbox, use it but we can't easily modify callbacks
      return widget.toolbox;
    }
    // Fallback to the original toolbox
    return widget.toolbox;
  }

  Widget get _textFiled => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
        decoration: BoxDecoration(
          color: Colors.white,
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
        child: ChatTextField(
          allAtMap: widget.allAtMap,
          atCallback: widget.atCallback,
          controller: widget.controller,
          focusNode: widget.focusNode,
          style: widget.style ??
              TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF374151),
              ),
          atStyle: widget.atStyle ??
              TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
          inputFormatters: widget.inputFormatters ??
              [AtTextInputFormatter(widget.openAtList)],
          enabled: widget.enabled,
          hintText: widget.hintText,
          textAlign: widget.enabled ? TextAlign.start : TextAlign.center,
        ),
      );

  void send() {
    if (!widget.enabled) return;
    if (!_emojiVisible) focus();
    if (null != widget.onSend && null != widget.controller) {
      widget.onSend!(widget.controller!.text.toString().trim());
    }
  }

  void toggleToolbox() {
    if (!widget.enabled) return;

    // If text field is focused, unfocus it first
    if (widget.focusNode.hasFocus) {
      widget.focusNode.unfocus();
    }

    setState(() {
      _toolsVisible = !_toolsVisible;
      _emojiVisible = false;
      _leftKeyboardButton = false;
      _rightKeyboardButton = false;
    });

    if (_toolsVisible) {
      panelController.updatePanelType(
        ChatBottomPanelType.other,
        data: PanelType.tool,
      );
    } else {
      panelController.updatePanelType(
        ChatBottomPanelType.keyboard,
        data: PanelType.keyboard,
      );
    }
  }

  void onTapSpeak() {
    if (!widget.enabled) return;
    Permissions.microphone(() => setState(() {
          _leftKeyboardButton = true;
          _rightKeyboardButton = false;
          _toolsVisible = false;
          _emojiVisible = false;
          unfocus();
        }));

    hidePanel();
  }

  void onTapLeftKeyboard() {
    if (!widget.enabled) return;
    setState(() {
      _leftKeyboardButton = false;
      _toolsVisible = false;
      _emojiVisible = false;
    });
  }

  void onTapRightKeyboard() {
    if (!widget.enabled) return;
    setState(() {
      _rightKeyboardButton = true;
      _toolsVisible = false;
      _emojiVisible = false;
    });

    panelController.updatePanelType(
      ChatBottomPanelType.keyboard,
      data: PanelType.keyboard,
    );
  }

  void onTapEmoji() {
    if (!widget.enabled) return;
    setState(() {
      _rightKeyboardButton = true;
      _leftKeyboardButton = false;
      _emojiVisible = true;
      _toolsVisible = false;
    });
    panelController.updatePanelType(
      ChatBottomPanelType.other,
      data: PanelType.emoji,
    );
  }

  void onTapEmojiFromToolbox() {
    // This is called from the options toolbox emoji button
    onTapEmoji();
  }

  void onTapVoiceFromToolbox() {
    // This is called from the options toolbox voice button
    onTapSpeak();
  }

  /// Check if currently recording voice
  bool get isRecordingVoice => _leftKeyboardButton;

  /// Cancel voice recording externally (e.g., when navigating away)
  void cancelVoiceRecording() {
    if (_leftKeyboardButton) {
      _voiceRecordBarKey.currentState?.cancelVoice();
    }
  }

  focus() => FocusScope.of(context).requestFocus(widget.focusNode);

  unfocus() => FocusScope.of(context).requestFocus(FocusNode());
}

class _QuoteView extends StatelessWidget {
  const _QuoteView({
    this.onClearQuote,
    required this.content,
  });
  final Function()? onClearQuote;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.07),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF3F4F6),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: const Color(0xFF4F42FF),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          14.horizontalSpace,
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          12.horizontalSpace,
          GestureDetector(
            onTap: onClearQuote,
            child: Container(
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF87171).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFF3F4F6),
                  width: 1,
                ),
              ),
              child: Icon(
                Ionicons.close,
                size: 16.w,
                color: const Color(0xFFF87171),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
