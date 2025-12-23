// ignore_for_file: unnecessary_import, deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/widgets/custom_buttom.dart';
import 'package:openim_common/openim_common.dart';
import '../../../widgets/gradient_scaffold.dart';

import 'send_verification_application_logic.dart';

class SendVerificationApplicationPage extends StatelessWidget {
  final logic = Get.find<SendVerificationApplicationLogic>();

  SendVerificationApplicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    logic.inputCtrl.text =
        logic.isEnterGroup ? StrRes.acceptMeJoin : StrRes.addMeAsFriend;
    return TouchCloseSoftKeyboard(
      child: GradientScaffold(
        title: StrRes.sendRequest,
        showBackButton: true,
        bodyColor: const Color(0xFFF9FAFB),
        trailing: CustomButton(
          onTap: logic.send,
          title: StrRes.send,
          // icon: CupertinoIcons.paperplane,
          color: Colors.white,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                StrRes.leaveMessage,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
              16.verticalSpace,
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: logic.inputCtrl,
                  autofocus: true,
                  maxLines: 6,
                  maxLength: 20,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16.w),
                    counterStyle: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 12.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
