// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:openim_common/openim_common.dart';
import 'app_text_form_field.dart';

class PasswordField extends StatefulWidget {
  final FocusNode focusNode;
  final TextEditingController controller;
  final TextEditingController? compareController;
  final bool validateFormat;
  final bool isRequired;
  final Function(String)? onFieldSubmitted;
  final String? label;
  final String? emptyErrorLabel;
  final bool? isNew;

  /// Key to access this field's FormFieldState for external validation trigger
  final GlobalKey<FormFieldState>? formFieldKey;

  /// Callback when password text changes - used to re-validate confirm password field
  final VoidCallback? onPasswordChange;

  const PasswordField({
    super.key,
    required this.focusNode,
    required this.controller,
    this.compareController,
    this.validateFormat = false,
    this.isRequired = false,
    this.onFieldSubmitted,
    this.formFieldKey,
    this.onPasswordChange,
    this.label,
    this.emptyErrorLabel,
    this.isNew=false,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool isObscureText = true;

  @override
  Widget build(BuildContext context) {
    final isConfirmPassword = widget.compareController != null;
    return AppTextFormField(
        formFieldKey: widget.formFieldKey,
        label: widget.label ??
            (isConfirmPassword ? StrRes.confirmPassword : StrRes.password),
        focusNode: widget.focusNode,
        controller: widget.controller,
        textInputAction:
            isConfirmPassword ? TextInputAction.next : TextInputAction.done,
        isObscureText: isObscureText,
        isRequired: widget.isRequired,
        onChanged: (value) {
          // Trigger callback when password changes (for re-validating confirm password)
          widget.onPasswordChange?.call();
        },
        onFieldSubmitted: widget.onFieldSubmitted,
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              isObscureText = !isObscureText;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isObscureText
                  ? Colors.transparent
                  : const Color(0xFF4F42FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isObscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: isObscureText
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFF4F42FF),
              size: 20,
            ),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            if (widget.emptyErrorLabel != null) {
              return widget.emptyErrorLabel;
            }
            return widget.compareController != null
                ? StrRes.plsEnterConfirmPassword
                : ((widget.isNew ?? false)
                    ?StrRes.plsEnterNewPwd:
                    StrRes.plsEnterPwd);
          }

          if (widget.compareController != null &&
              value != widget.compareController?.text) {
            return StrRes.passwordMismatch;
          }

          if (widget.validateFormat == true) {
            if (value.length < 8 || value.length > 20) {
              return StrRes.passwordMustLength;
            }
            // Check for at least one letter and one number
            final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
            final hasNumber = RegExp(r'[0-9]').hasMatch(value);
            if (!hasLetter) {
              return StrRes.passwordMustContainLetter;
            }
            if (!hasNumber) {
              return StrRes.passwordMustContainNumber;
            }
          }

          return null;
        });
  }
}
