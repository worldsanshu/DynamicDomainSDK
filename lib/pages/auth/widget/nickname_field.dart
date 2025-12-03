import 'package:flutter/material.dart';
import 'package:openim_common/openim_common.dart';
import 'app_text_form_field.dart';

class NicknameField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;

  const NicknameField({
    super.key,
    required this.controller,
    this.focusNode,
  });

  @override
  State<NicknameField> createState() => _NicknameFieldState();
}

class _NicknameFieldState extends State<NicknameField> {
  late FocusNode _internalFocusNode;
  FocusNode get effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = FocusNode();
    effectiveFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    effectiveFocusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    // Trim whitespace when user leaves the field
    if (!effectiveFocusNode.hasFocus) {
      final trimmed = widget.controller.text.trim();
      if (widget.controller.text != trimmed) {
        widget.controller.text = trimmed;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      label: StrRes.nickname,
      hint: StrRes.nicknameHint,
      focusNode: effectiveFocusNode,
      validator: (value) {
        // Don't modify controller.text inside validator - it causes setState during build
        String name = (value ?? '').trim();
        if (name.isEmpty) {
          return StrRes.pleaseEnterValidName;
        }
        return null;
      },
      controller: widget.controller,
    );
  }
}
