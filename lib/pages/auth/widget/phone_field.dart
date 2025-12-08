import 'package:flutter/material.dart';
import 'package:openim/pages/auth/widget/app_text_form_field.dart';
import 'package:openim_common/openim_common.dart';

class PhoneField extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController controller;
  final bool isRequired;

  const PhoneField({
    super.key,
    required this.focusNode,
    required this.controller,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      label: StrRes.phoneNumber,
      keyboardType: TextInputType.phone,
      focusNode: focusNode,
      isRequired: isRequired,
      onChanged: (value) {
        // Field validation handled by validator
      },
      validator: (value) {
        String phone = (value ?? '').trim();

        if (phone.isEmpty) {
          return StrRes.pleaseEnterPhoneNumber;
        }

        // Remove spaces and dashes for validation
        String cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');

        // Remove country code if present
        if (cleanPhone.startsWith('+86')) {
          cleanPhone = cleanPhone.substring(3);
        } else if (cleanPhone.startsWith('86')) {
          cleanPhone = cleanPhone.substring(2);
        }

        // Validate Chinese phone number using shared utility
        if (!IMUtils.isChinaMobile(cleanPhone)) {
          return StrRes.pleaseEnterValidPhoneNumber;
        }

        return null;
      },
      controller: controller,
    );
  }
}
