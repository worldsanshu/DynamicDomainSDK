// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/widgets/custom_buttom.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'edit_my_info_logic.dart';
import '../../../widgets/base_page.dart';

class EditMyInfoPage extends StatelessWidget {
  final logic = Get.find<EditMyInfoLogic>();
  EditMyInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      centerTitle: false,
      showLeading: true,
      customAppBar: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            logic.title ?? StrRes.editInfo,
            style: const TextStyle(
              fontFamily: 'FilsonPro',
              fontWeight: FontWeight.w500,
              fontSize: 23,
              color: Colors.black,
            ).copyWith(fontSize: 23.sp),
          ),
          Text(
            StrRes.editYourInformation,
            style: const TextStyle(
              fontFamily: 'FilsonPro',
              fontWeight: FontWeight.w400,
              color: Color(0xFFBDBDBD),
            ).copyWith(fontSize: 12.sp),
          ),
        ],
      ),
      body: _buildContentContainer(),
    );
  }

  Widget _buildContentContainer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 20.h),
        child: AnimationLimiter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 450),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                curve: Curves.easeOutQuart,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                20.verticalSpace,
                _buildInputSection(),
                18.verticalSpace,
                _buildSaveButton(),
                24.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      children: [
        // Section Title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _getInputLabel(),
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 24.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF212121),
                shadows: [
                  Shadow(
                    color: Colors.white.withOpacity(0.9),
                    offset: const Offset(0.5, 0.5),
                    blurRadius: 0.5,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Input Container
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9CA3AF).withOpacity(0.06),
                offset: const Offset(0, 2),
                blurRadius: 6.r,
              ),
            ],
            border: Border.all(
              color: const Color(0xFFF3F4F6),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input field
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.7),
                        offset: const Offset(-0.5, -0.5),
                        blurRadius: 2,
                      ),
                    ],
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
                    keyboardType: logic.keyboardType,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(logic.maxLength)
                    ],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14.h,
                        horizontal: 16.w,
                      ),
                      hintText: _getHintText(),
                      hintStyle: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ),

                10.verticalSpace,

                // Character count indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(() => Text(
                          '${logic.characterCount.value}/${logic.maxLength}',
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: logic.characterCount.value > logic.maxLength
                                ? const Color(0xFFF87171)
                                : const Color(0xFF9CA3AF),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      width: double.infinity,
      child: CustomButtom(
        onPressed: logic.save,
        title: StrRes.save,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        colorButton: const Color(0xFF4F42FF),
        colorIcon: Colors.white,
      ),
    );
  }

  String _getInputLabel() {
    switch (logic.editAttr) {
      case EditAttr.nickname:
        return StrRes.yourNickname;
      case EditAttr.mobile:
        return StrRes.phoneNumber;
      case EditAttr.email:
        return StrRes.emailAddress;
      default:
        return StrRes.information;
    }
  }

  String _getHintText() {
    switch (logic.editAttr) {
      case EditAttr.nickname:
        return StrRes.enterYourNickname;
      case EditAttr.mobile:
        return StrRes.enterYourPhoneNumber;
      case EditAttr.email:
        return StrRes.enterYourEmailAddress;
      default:
        return StrRes.enterInformation;
    }
  }
}
