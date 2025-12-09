import 'package:flutter/material.dart';
import 'package:openim_common/openim_common.dart';
import 'app_text_form_field.dart';

class NicknameField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isRequired;

  const NicknameField({
    super.key,
    required this.controller,
    this.focusNode,
    this.isRequired = false,
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
      focusNode: effectiveFocusNode,
      isRequired: widget.isRequired,
      maxLength: 20,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return StrRes.pleaseEnterValidName;
        }
        return null;
      },
      controller: widget.controller,
    );
  }
}
