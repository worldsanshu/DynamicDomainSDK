// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'my_qrcode_logic.dart';
import '../../../widgets/base_page.dart';

class MyQrcodePage extends StatelessWidget {
  final logic = Get.find<MyQrcodeLogic>();

  MyQrcodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BasePage(
        showAppBar: true,
        centerTitle: false,
        showLeading: true,
        customAppBar: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StrRes.qrcode,
              style: const TextStyle(
                fontFamily: 'FilsonPro',
                fontWeight: FontWeight.w500,
                fontSize: 23,
                color: Colors.black,
              ).copyWith(fontSize: 23.sp),
            ),
            Text(
              StrRes.shareYourQRCode,
              style: const TextStyle(
                fontFamily: 'FilsonPro',
                fontWeight: FontWeight.w400,
                color: Color(0xFFBDBDBD),
              ).copyWith(fontSize: 12.sp),
            ),
          ],
        ),
        body: _buildContentContainer(),
      ),
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
                _buildProfileCard(),
                18.verticalSpace,
                _buildQRCodeSection(),
                24.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final user = logic.imLogic.userInfo.value;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: const Offset(-1, -1),
            blurRadius: 4,
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            const Color(0xFFF8FAFC),
          ],
          stops: const [0.05, 0.3],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Stack(
              children: [
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
                    url: user.faceURL,
                    text: user.nickname,
                    width: 68.w,
                    height: 68.h,
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
            16.horizontalSpace,

            // Profile info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nickname
                  Text(
                    user.nickname ?? '',
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  5.verticalSpace,
                  // User ID
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 0.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${StrRes.userIdLabel}${user.userID ?? ''}',
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeSection() {
    return Column(
      children: [
        // Section Title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              StrRes.scanToAddMe,
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
        // QR Code Container
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
          padding: EdgeInsets.all(24.w),
          child: Center(
            child: Container(
              width: 220.w,
              height: 220.w,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(1, 1),
                    blurRadius: 3,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.9),
                    offset: const Offset(-0.5, -0.5),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: QrImageView(
                data: logic.buildQRContent(),
                size: 180.w,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
        20.verticalSpace,
        // Hint Text
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            StrRes.qrcodeHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
