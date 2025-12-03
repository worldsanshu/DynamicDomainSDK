import 'package:flutter/material.dart';
import 'package:openim_common/openim_common.dart';
import 'app_text_form_field.dart';

class PasswordField extends StatefulWidget {
  final FocusNode focusNode;
  final TextEditingController controller;
  final TextEditingController? compareController;
  final bool validateFormat;

  const PasswordField({
    super.key,
    required this.focusNode,
    required this.controller,
    this.compareController,
    this.validateFormat = false,
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
        label: isConfirmPassword ? StrRes.confirmPassword : StrRes.password,
        focusNode: widget.focusNode,
        controller: widget.controller,
        hint: isConfirmPassword
            ? StrRes.confirmPasswordHint
            : StrRes.passwordHint,
        // helperText: widget.validateFormat ? StrRes.wrongPasswordFormat : null,
        isObscureText: isObscureText,
        onChanged: (value) {
          // Field validation handled by validator
        },
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
                  : const Color(0xFF60A5FA).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isObscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: isObscureText
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFF60A5FA),
              size: 20,
            ),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return StrRes.plsEnterPwd;
          }

          if (widget.compareController != null &&
              value != widget.compareController?.text) {
            return StrRes.passwordMismatch;
          }

          if (widget.validateFormat == true) {
            if (!IMUtils.isValidPassword(value)) {
              return StrRes.wrongPasswordFormat;
            }
          }

          return null;
        });
  }
}
