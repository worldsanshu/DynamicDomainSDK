// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim/widgets/custom_buttom.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'set_remark_logic.dart';
import '../../../../widgets/base_page.dart';
import '../../../../utils/character_length_limiting_formatter.dart';

class SetFriendRemarkPage extends StatefulWidget {
  const SetFriendRemarkPage({super.key});

  @override
  State<SetFriendRemarkPage> createState() => _SetFriendRemarkPageState();
}

class _SetFriendRemarkPageState extends State<SetFriendRemarkPage> {
  final logic = Get.find<SetFriendRemarkLogic>();
  int characterCount = 0;

  @override
  void initState() {
    super.initState();
    characterCount = logic.inputCtrl.text.characters.length;
    logic.inputCtrl.addListener(_updateCharacterCount);
  }

  @override
  void dispose() {
    logic.inputCtrl.removeListener(_updateCharacterCount);
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {
      characterCount = logic.inputCtrl.text.characters.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      title: StrRes.remark,
      centerTitle: false,
      showLeading: true,
      actions: [
        CustomButton(
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          onTap: logic.save,
          title: StrRes.save,
          colorButton: AppColor.appBarEnd.withOpacity(0.9),
        ),
      ],
      body: Column(
        children: [
          // Content
          Expanded(
            child: AnimationLimiter(
              child: SingleChildScrollView(
                child: AnimationConfiguration.staggeredList(
                  position: 0,
                  duration: const Duration(milliseconds: 400),
                  child: SlideAnimation(
                    verticalOffset: 40.0,
                    curve: Curves.easeOutCubic,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section title
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 12.h),
                              child: Text(
                                StrRes.setRemarkName,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6B7280),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            12.verticalSpace,

                            // Input field
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF9CA3AF)
                                        .withOpacity(0.06),
                                    offset: const Offset(0, 2),
                                    blurRadius: 6,
                                  ),
                                ],
                                border: Border.all(
                                  color: const Color(0xFFF3F4F6),
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: logic.inputCtrl,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF374151),
                                ),
                                autofocus: true,
                                inputFormatters: [
                                  CharacterLengthLimitingFormatter(16)
                                ],
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText: StrRes.enterRemarkName,
                                  hintStyle: TextStyle(
                                    fontFamily: 'FilsonPro',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 16.h,
                                    horizontal: 20.w,
                                  ),
                                ),
                              ),
                            ),

                            16.verticalSpace,

                            // Character count display
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Text(
                                "$characterCount/16",
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
