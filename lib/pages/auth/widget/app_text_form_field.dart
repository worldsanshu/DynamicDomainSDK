import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openim/pages/auth/theming/colors.dart';

class AppTextFormField extends StatelessWidget {
  final String hint;
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

  const AppTextFormField({
    super.key,
    required this.hint,
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
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          return validator(value);
        },
        onChanged: onChanged,
        controller: controller,
        decoration: InputDecoration(
          label: label != null
              ? Text(
                  label!,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                )
              : null,
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
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(14),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFF60A5FA),
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
        cursorColor: const Color(0xFF60A5FA),
      ),
    );
  }
}
