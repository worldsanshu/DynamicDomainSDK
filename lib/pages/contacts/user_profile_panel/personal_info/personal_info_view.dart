// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/cupertino.dart';

import 'personal_info_logic.dart';
import '../../../../widgets/base_page.dart';

class PersonalInfoPage extends StatelessWidget {
  final logic = Get.find<PersonalInfoLogic>();

  PersonalInfoPage({super.key});

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
            StrRes.personalInfo,
            style: const TextStyle(
              fontFamily: 'FilsonPro',
              fontWeight: FontWeight.w500,
              fontSize: 23,
              color: Colors.black,
            ).copyWith(fontSize: 23.sp),
          ),
          Text(
            StrRes.userInformation,
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
                  20.verticalSpace,
                  _buildSectionTitle(StrRes.information),
                  _buildSectionContainer(
                    children: [
                      _buildItemView(
                        label: StrRes.avatar,
                        isAvatar: true,
                        value: logic.nickname,
                        url: logic.faceURL,
                        iconData: CupertinoIcons.person,
                        iconColor: const Color(0xFF3B82F6),
                      ),
                      _buildDivider(),
                      _buildItemView(
                        label: StrRes.nickname,
                        value: logic.nickname,
                        iconData: CupertinoIcons.person_fill,
                        iconColor: const Color(0xFF10B981),
                      ),
                      _buildDivider(),
                      _buildItemView(
                        label: StrRes.gender,
                        value: logic.isMale ? StrRes.man : StrRes.woman,
                        iconData: CupertinoIcons.person_2_fill,
                        iconColor: const Color(0xFFF87171),
                      ),
                      _buildDivider(),
                      _buildItemView(
                        label: StrRes.birthDay,
                        value: logic.birth,
                        iconData: CupertinoIcons.gift,
                        iconColor: const Color(0xFF8B5CF6),
                        isLast: true,
                      ),
                    ],
                  ),
                  18.verticalSpace,
                  _buildSectionTitle(StrRes.settings),
                  _buildSectionContainer(
                    children: [
                      _buildItemView(
                        label: StrRes.mobile,
                        value: logic.phoneNumber,
                        onTap: logic.clickPhoneNumber,
                        iconData: CupertinoIcons.phone,
                        iconColor: const Color(0xFF3B82F6),
                        isLast: true,
                      ),
                    ],
                  ),
                  24.verticalSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'FilsonPro',
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildSectionContainer({required List<Widget> children}) => Container(
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
        child: Column(children: children),
      );

  Widget _buildDivider() => Padding(
        padding: EdgeInsets.only(left: 70.w),
        child: const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFF3F4F6),
        ),
      );

  Widget _buildItemView({
    required String label,
    String? value,
    String? url,
    bool isAvatar = false,
    bool isLast = false,
    Function()? onTap,
    required IconData iconData,
    required Color iconColor,
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                // Icon theo style MinePage (đơn giản)
                Icon(
                  iconData,
                  size: 20.w,
                  color: AppColor.iconColor, //iconColor,
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
                if (null != value && !isAvatar)
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                if (isAvatar)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1.5.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9CA3AF).withOpacity(0.1),
                          blurRadius: 8.r,
                        ),
                      ],
                    ),
                    child: AvatarView(
                      width: 68.w,
                      height: 68.h,
                      url: url,
                      text: value,
                      textStyle: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      isCircle: true,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}
