// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hugeicons/hugeicons.dart';

import 'language_setup_logic.dart';
import '../../../widgets/base_page.dart';

class LanguageSetupPage extends StatelessWidget {
  final logic = Get.find<LanguageSetupLogic>();

  LanguageSetupPage({super.key});

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
            StrRes.languageSetup,
            style: const TextStyle(
              fontFamily: 'FilsonPro',
              fontWeight: FontWeight.w500,
              fontSize: 23,
              color: Colors.black,
            ).copyWith(fontSize: 23.sp),
          ),
          Text(
            StrRes.chooseYourLanguage,
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
      child: AnimationLimiter(
        child: Column(
          children: [
            18.verticalSpace,
            AnimationConfiguration.staggeredList(
              position: 0,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                curve: Curves.easeOutCubic,
                verticalOffset: 40.0,
                child: FadeInAnimation(
                  child: _buildLanguageSection(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.06),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF3F4F6),
          width: 1,
        ),
      ),
      child: Obx(() => Column(
            children: [
              _buildLanguageItem(
                label: StrRes.followSystem,
                icon: HugeIcons.strokeRoundedSmartPhone01,
                isChecked: logic.isFollowSystem.value,
                onTap: () => logic.switchLanguage(0),
                isFirst: true,
              ),
              _buildLanguageItem(
                label: StrRes.chinese,
                icon: HugeIcons.strokeRoundedTranslate,
                isChecked: logic.isChinese.value,
                onTap: () => logic.switchLanguage(1),
              ),
              _buildLanguageItem(
                label: StrRes.english,
                icon: HugeIcons.strokeRoundedGlobe02,
                isChecked: logic.isEnglish.value,
                onTap: () => logic.switchLanguage(2),
                isLast: true,
              ),
            ],
          )),
    );
  }

  Widget _buildLanguageItem({
    required String label,
    required List<List<dynamic>> icon,
    bool isChecked = false,
    bool isFirst = false,
    bool isLast = false,
    Function()? onTap,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  HugeIcon(
                    icon: icon,
                    size: 20.w,
                    color: AppColor.iconColor,
                  ),
                  16.horizontalSpace,
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),

                  // Check icon
                  if (isChecked)
                    Container(
                      width: 24.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF34D399),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        CupertinoIcons.checkmark_alt,
                        size: 14.w,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: EdgeInsets.only(left: 70.w),
            child: const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF3F4F6),
            ),
          ),
      ],
    );
  }
}
