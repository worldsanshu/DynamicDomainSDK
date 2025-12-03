import 'package:chat_bottom_container/panel_container.dart';
import 'package:chat_bottom_container/typedef.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';
import 'package:ionicons/ionicons.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim_common/src/res/styles/app_colors.dart';

double kInputBoxMinHeight = 56.h;

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

  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  bool get _showQuoteView => IMUtils.isNotNullEmptyStr(widget.quoteContent);

  final panelController = ChatBottomPanelContainerController<PanelType>();
  PanelType currentPanelType = PanelType.none;

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

    widget.focusNode.addListener(() {
      if (widget.focusNode.hasFocus) {
        setState(() {
          _toolsVisible = false;
          _emojiVisible = false;
          _leftKeyboardButton = false;
          _rightKeyboardButton = false;
        });
        // Force close any open panels when text field is focused
        // forceCloseAllPanels();
        _expandController.forward();
      } else {
        // setState(() {
        //   _isTextFieldFocused = false;
        // });
        // _expandController.reverse();
      }
    });

    widget.forceCloseToolboxSub?.listen((value) {
      if (!mounted) return;
      forceCloseAllPanels();
    });

    widget.controller?.addListener(() {
      setState(() {
        _sendButtonVisible = widget.controller!.text.isNotEmpty;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  // Claymorphism button widget
  Widget _buildClaymorphismButton({
    required List<List<dynamic>> icon,
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
        child: HugeIcon(
          icon: icon,
          size: 20.w,
          color: iconColor ??
              (isActive ? const Color(0xFF4F42FF) : const Color(0xFF6B7280)),
        ),
      ),
    );
  }

  // Claymorphism send button
  Widget _buildSendButton() {
    return GestureDetector(
      onTap: _sendButtonVisible ? send : toggleToolbox,
      child: Container(
        width: 30.w,
        height: 30.h,
        decoration: BoxDecoration(
          color: _sendButtonVisible
              ? const Color(0xFF4F42FF)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8.r),
          border: _sendButtonVisible
              ? null
              : Border.all(
                  color: const Color(0xFFF3F4F6),
                  width: 1,
                ),
        ),
        alignment: Alignment.center,
        child: HugeIcon(
          icon: _sendButtonVisible
              ? HugeIcons.strokeRoundedSent
              : HugeIcons.strokeRoundedAdd01,
          size: 20.w,
          color: _sendButtonVisible ? Colors.white : AppColors.iconColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) widget.controller?.clear();
    return widget.isNotInGroup
        ? const ChatDisableInputBox()
        : widget.isMultiModel
            ? widget.multiOpToolbox
            : Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _expandAnimation,
                      builder: (context, child) {
                        return Container(
                          constraints:
                              BoxConstraints(minHeight: kInputBoxMinHeight),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 10.h),
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
                              _buildClaymorphismButton(
                                icon: _leftKeyboardButton
                                    ? HugeIcons.strokeRoundedKeyboard
                                    : HugeIcons.strokeRoundedMic01,
                                onTap: _leftKeyboardButton
                                    ? onTapLeftKeyboard
                                    : onTapSpeak,
                                isActive: _leftKeyboardButton,
                                backgroundColor: _leftKeyboardButton
                                    ? const Color(0xFF4F42FF).withOpacity(0.1)
                                    : const Color(0xFFF9FAFB),
                              ),
                              12.horizontalSpace,
                              Expanded(
                                child: Stack(
                                  children: [
                                    Offstage(
                                      offstage: _leftKeyboardButton,
                                      child: _textFiled,
                                    ),
                                    Offstage(
                                      offstage: !_leftKeyboardButton,
                                      child: widget.voiceRecordBar,
                                    ),
                                  ],
                                ),
                              ),
                              12.horizontalSpace,
                              // _buildClaymorphismButton(
                              //   icon: _rightKeyboardButton
                              //       ? HugeIcons.strokeRoundedKeyboard
                              //       : HugeIcons.strokeRoundedSmile,
                              //   onTap: _rightKeyboardButton
                              //       ? onTapRightKeyboard
                              //       : onTapEmoji,
                              //   isActive: _rightKeyboardButton || _emojiVisible,
                              //   backgroundColor:
                              //       (_rightKeyboardButton || _emojiVisible)
                              //           ? const Color(0xFFA78BFA).withOpacity(0.1)
                              //           : const Color(0xFFF9FAFB),
                              //   iconColor: (_rightKeyboardButton || _emojiVisible)
                              //       ? const Color(0xFFA78BFA)
                              //       : const Color(0xFF6B7280),
                              // ),
                              8.horizontalSpace,
                              _buildSendButton(),
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
      _leftKeyboardButton = false;
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
            return widget.toolbox;
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
      safeAreaBottom: 0,
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

  Widget get _textFiled => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                color: const Color(0xFF4F42FF),
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
      focus();
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
