import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';

class TermsAndConditionsText extends StatelessWidget {
  final Widget content;

  const TermsAndConditionsText({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final primaryColor= Theme.of(context).primaryColor;
    return Container(
      width: double.infinity,
      // margin: EdgeInsets.symmetric(vertical: 5.h),
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 0.w),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          content,
          Expanded(
            child: RichText(
              text: TextSpan(
                text: StrRes.termsAgree,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
                children: [
                  TextSpan(
                    text: StrRes.userAgreementDoc,
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        AppNavigator.startServiceAgreement();
                      },
                  ),
                  TextSpan(
                    text: StrRes.and,
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  TextSpan(
                    text: StrRes.privacyPolicyDoc,
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        AppNavigator.startPrivacyPolicy();
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
