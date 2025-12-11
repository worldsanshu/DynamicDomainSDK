// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/cupertino.dart';

import '../../../../widgets/gradient_scaffold.dart';
import '../../../../widgets/section_title.dart';
import '../../../../widgets/settings_menu.dart';
import 'personal_info_logic.dart';

class PersonalInfoPage extends StatelessWidget {
  final logic = Get.find<PersonalInfoLogic>();

  PersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: StrRes.personalInfo,
      subtitle: StrRes.userInformation,
      showBackButton: true,
      scrollable: true,
      bodyColor: const Color(0xFFF4F5F9),
      body: AnimationLimiter(
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 450),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                curve: Curves.easeOutQuart,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                SectionTitle(title: StrRes.information),
                SettingsMenuSection(
                  items: [
                    SettingsMenuItem(
                      label: StrRes.avatar,
                      icon: CupertinoIcons.person,
                      color: const Color(0xFF3B82F6),
                      showArrow: false,
                      valueWidget: AvatarView(
                        width: 44.w,
                        height: 44.h,
                        url: logic.faceURL,
                        text: logic.nickname,
                        textStyle: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        isCircle: true,
                      ),
                    ),
                    SettingsMenuItem(
                      label: StrRes.nickname,
                      value: logic.nickname,
                      icon: CupertinoIcons.person_fill,
                      color: const Color(0xFF10B981),
                      showArrow: false,
                    ),
                    SettingsMenuItem(
                      label: StrRes.gender,
                      value: logic.isMale ? StrRes.man : StrRes.woman,
                      icon: CupertinoIcons.person_2_fill,
                      color: const Color(0xFFF87171),
                      showArrow: false,
                    ),
                    SettingsMenuItem(
                      label: StrRes.birthDay,
                      value: logic.birth,
                      icon: CupertinoIcons.gift,
                      color: const Color(0xFF8B5CF6),
                      showArrow: false,
                      showDivider: false,
                    ),
                    SettingsMenuItem(
                      label: StrRes.mobile,
                      value: logic.phoneNumber,
                      icon: CupertinoIcons.phone,
                      color: Colors.pink,
                      showArrow: false,
                      showDivider: false,
                    ),
                  ],
                ),
                24.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
