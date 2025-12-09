// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim/pages/auth/theming/colors.dart';

class AppTextFormField extends StatelessWidget {
  final String? hint;
  final String? label;
  final String? helperText;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final bool? isObscureText;
  final bool? isDense;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final Function(String?) validator;
  final bool isRequired;
  final int? maxLength;

  const AppTextFormField({
    super.key,
    this.hint,
    this.label,
    this.helperText,
    this.suffixIcon,
    this.isObscureText,
    this.isDense,
    this.controller,
    this.onChanged,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    required this.validator,
    this.isRequired = false,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
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
        keyboardType: keyboardType,
        focusNode: focusNode,
        autovalidateMode: AutovalidateMode.onUnfocus,
        validator: (value) => validator(value),
        onChanged: onChanged,
        maxLength: maxLength,
        controller: controller,
        decoration: InputDecoration(
           counterText: '', 
          label: AnimatedBuilder(
            animation: Listenable.merge([focusNode, controller]),
            builder: (context, _) {
              final isFloating =
                  focusNode?.hasFocus == true || (controller?.text.isNotEmpty ?? false);

              return RichText(
                text: TextSpan(
                  text: label ?? '',
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: isFloating ? 16.sp : 14.sp,
                    fontWeight: isFloating ? FontWeight.w600 : FontWeight.w400,
                    color: isFloating
                        ? const Color(0xFF37417F)
                        : const Color(0xFF6B7280),
                  ),
                  children: [
                    if (isRequired)
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              );
            },
          ),

          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9CA3AF),
          ),
          helperText: helperText,
          helperStyle: const TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 12,
            color: Colors.grey,
            height: 1.2,
            fontStyle: FontStyle.italic,
          ),
          isDense: isDense ?? true,
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
          suffixIcon: suffixIcon,
        ),
        obscureText: isObscureText ?? false,
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
