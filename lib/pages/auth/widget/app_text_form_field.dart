// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim/pages/auth/theming/colors.dart';

class AppTextFormField extends StatefulWidget {
  final String? hint;
  final String? label;
  final String? helperText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final bool? isObscureText;
  final bool? isDense;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Function(String?) validator;
  final bool isRequired;
  final int? maxLength;

  const AppTextFormField({
    super.key,
    this.hint,
    this.label,
    this.helperText,
    this.suffixIcon,
    this.prefixIcon,
    this.isObscureText,
    this.isDense,
    this.controller,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    required this.validator,
    this.isRequired = false,
    this.maxLength,
  });

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  late FocusNode _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    // Only dispose if we created the FocusNode (not passed from parent)
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focusNode = widget.focusNode ?? _internalFocusNode;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.04),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF3F4F6),
          width: 1,
        ),
      ),
      child: TextFormField(
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        focusNode: focusNode,
        autovalidateMode: AutovalidateMode.onUnfocus,
        validator: (value) => widget.validator(value),
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onFieldSubmitted,
        maxLength: widget.maxLength,
        controller: widget.controller,
        decoration: InputDecoration(
           counterText: '', 
          label: AnimatedBuilder(
            animation: Listenable.merge([focusNode, widget.controller ?? FocusNode()]),
            builder: (context, _) {
              final isFloating =
                  focusNode.hasFocus == true || (widget.controller?.text.isNotEmpty ?? false);

              return RichText(
                text: TextSpan(
                  text: widget.label ?? '',
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: isFloating ? 16.sp : 14.sp,
                    fontWeight: isFloating ? FontWeight.w600 : FontWeight.w400,
                    color: isFloating
                        ? const Color(0xFF37417F)
                        : const Color(0xFF6B7280),
                  ),
                  children: [
                    if (widget.isRequired)
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              );
            },
          ),

          hintText: widget.hint,
          hintStyle: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9CA3AF),
          ),
          helperText: widget.helperText,
          helperStyle: const TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 12,
            color: Colors.grey,
            height: 1.2,
            fontStyle: FontStyle.italic,
          ),
          isDense: widget.isDense ?? true,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),

          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(14),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: ColorsManager.coralRed.withOpacity(0.7),
              width: 1.3.w,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: ColorsManager.coralRed.withOpacity(0.7),
              width: 1.3.w,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          errorStyle: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 12.sp,
            color: const Color(0xFFF87171),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
        ),
        obscureText: widget.isObscureText ?? false,
        style: TextStyle(
          fontFamily: 'FilsonPro',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF374151),
        ),
        cursorColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
