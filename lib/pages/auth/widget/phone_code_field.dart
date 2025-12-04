// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:openim/pages/auth/widget/app_text_form_field.dart';
import 'package:openim_common/openim_common.dart';

/// PhoneCodeField with an integrated 60s resend countdown.
class PhoneCodeField extends StatefulWidget {
  final TextEditingController controller;
  final Future<bool> Function()? onSendCode;
  final int seconds;

  const PhoneCodeField({
    super.key,
    required this.controller,
    required this.onSendCode,
    this.seconds = 60,
  });

  @override
  State<PhoneCodeField> createState() => _PhoneCodeFieldState();
}

class _PhoneCodeFieldState extends State<PhoneCodeField> {
  Timer? _timer;
  int _left = 0; // remaining seconds, 0 => can send
  bool _isSending = false;

  bool get _canSend => _left == 0 && !_isSending;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _left = widget.seconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_left <= 1) {
        t.cancel();
        setState(() => _left = 0);
      } else {
        setState(() => _left -= 1);
      }
    });
  }

  Future<void> _handleSend() async {
    if (!_canSend) return;
    setState(() => _isSending = true);
    try {
      final ok = await widget.onSendCode?.call();
      if (ok == true) {
        _startCountdown();
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: AppTextFormField(
            label: StrRes.verificationCode,
            hint: StrRes.smsVerificationCodeHint,
            keyboardType: TextInputType.number,
            controller: widget.controller,
            validator: (value) {
              final code = (value ?? '').trim();
              if (code.isEmpty) {
                return StrRes.pleaseEnterVerificationCode;
              }
              return null;
            },
          ),
        ),
        Gap(12.w),
        _CodeSendButton(
          canSend: _canSend,
          secondsLeft: _left,
          isSending: _isSending,
          onTap: _handleSend,
        ),
      ],
    );
  }
}

class _CodeSendButton extends StatelessWidget {
  final bool canSend;
  final int secondsLeft;
  final bool isSending;
  final VoidCallback onTap;
  const _CodeSendButton({
    required this.canSend,
    required this.secondsLeft,
    required this.isSending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String label;
    if (isSending) {
      label = '...'; // loading state
    } else if (secondsLeft == 0) {
      label = StrRes.sendCode;
    } else {
      label = '${secondsLeft}s';
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: SizedBox(
        key: ValueKey(label),
        height: 44.h,
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            backgroundColor: canSend
                ? const Color(0xFF3B82F6)
                : const Color(0xFF9CA3AF).withOpacity(0.3),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            minimumSize: Size(100.w, 44.h),
          ),
          onPressed: canSend ? onTap : null,
          child: isSending
              ? SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white)),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
    );
  }
}
