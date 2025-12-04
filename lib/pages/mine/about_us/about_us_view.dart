// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../widgets/base_page.dart';
import 'about_us_logic.dart';

class AboutUsPage extends StatelessWidget {
  final logic = Get.find<AboutUsLogic>();

  AboutUsPage({super.key});

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
            StrRes.aboutUs,
            style: const TextStyle(
              fontFamily: 'FilsonPro',
              fontWeight: FontWeight.w500,
              fontSize: 23,
              color: Colors.black,
            ).copyWith(fontSize: 23.sp),
          ),
          Text(
            StrRes.appInformation,
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
                _buildAppInfoSection(),
                if (logic.showContactUs) ...[
                  18.verticalSpace,
                  _buildContactUsSection(),
                ],
                24.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Container(
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
      child: Column(
        children: [
          _buildAppInfoCard(),
        ],
      ),
    );
  }

  Widget _buildContactUsSection() {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: logic.startContactUs,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F42FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: const Icon(
                    Icons.contact_support_outlined,
                    size: 14,
                    color: Color(0xFF4F42FF),
                  ),
                ),
                16.horizontalSpace,
                Expanded(
                  child: Text(
                    StrRes.contactUs,
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ),
                8.horizontalSpace,
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // App Icon with modern styling
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 12.r,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: ImageRes.logoApp.toImage,
            ),
          ),

          20.verticalSpace,

          // App Name and Version with modern typography
          Obx(() => Column(
                children: [
                  Text(
                    logic.appName.value,
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  6.verticalSpace,
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F42FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Version ${logic.version.value}+${logic.buildNumber.value}',
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4F42FF),
                      ),
                    ),
                  ),
                ],
              )),

          18.verticalSpace,

          // Description with modern styling
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              StrRes.appDescription,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
