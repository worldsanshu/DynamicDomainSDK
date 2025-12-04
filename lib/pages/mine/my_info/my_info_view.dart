// ignore_for_file: deprecated_member_use

import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim_common/openim_common.dart';

import '../../../core/controller/im_controller.dart';
import '../../../widgets/base_page.dart';
import 'my_info_logic.dart';

class MyInfoPage extends StatelessWidget {
  final logic = Get.find<MyInfoLogic>();
  final imLogic = Get.find<IMController>();

  MyInfoPage({super.key});

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
            StrRes.myInfo,
            style: const TextStyle(
              fontFamily: 'FilsonPro',
              fontWeight: FontWeight.w500,
              fontSize: 23,
              color: Colors.black,
            ).copyWith(fontSize: 23.sp),
          ),
          Text(
            StrRes.personalInformation,
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
                Obx(() => _buildProfileCard()),
                _buildMenuSection([
                  Obx(
                    () => _buildMenuItem(
                      icon: HugeIcons.strokeRoundedUser,
                      label: StrRes.nickname,
                      value: imLogic.userInfo.value.nickname,
                      onTap: logic.editMyName,
                      showDivider: true,
                    ),
                  ),
                  Obx(() => _buildMenuItem(
                        icon: HugeIcons.strokeRoundedUserMultiple,
                        label: StrRes.gender,
                        value: imLogic.userInfo.value.gender == 1
                            ? StrRes.man
                            : StrRes.woman,
                        onTap: logic.selectGender,
                        showDivider: true,
                      )),
                  Obx(
                    () => _buildMenuItem(
                      icon: HugeIcons.strokeRoundedCalendar03,
                      label: StrRes.birthDay,
                      value: DateUtil.formatDateMs(
                        imLogic.userInfo.value.birth ?? 0,
                        format: IMUtils.getTimeFormat1(),
                      ),
                      onTap: logic.openDatePicker,
                      showDivider: true,
                    ),
                  ),
                  _buildMenuItem(
                    icon: HugeIcons.strokeRoundedCall,
                    label: StrRes.mobile,
                    value: imLogic.userInfo.value.phoneNumber,
                    showDivider: false,
                    hideArrow: true,
                  ),
                ]),
                24.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final user = imLogic.userInfo.value;

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
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
                      child: InkWell(
                        onTap: logic.openUpdateAvatarSheet,
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
                    ),
                  ],
                ),
                16.horizontalSpace,

                // Profile info
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nickname
                          Text(
                            user.nickname ?? StrRes.unknown,
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
                          GestureDetector(
                            onTap: () {
                              if (user.userID != null) {
                                Clipboard.setData(
                                    ClipboardData(text: user.userID!));
                                ScaffoldMessenger.of(Get.context!).showSnackBar(
                                    SnackBar(content: Text(StrRes.idCopied)));
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 0.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${StrRes.userIdLabel}${user.userID ?? ''}',
                                    style: TextStyle(
                                      fontFamily: 'FilsonPro',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF6B7280),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  4.horizontalSpace,
                                  Icon(
                                    CupertinoIcons.doc_on_doc,
                                    size: 14.w,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: logic.viewMyQrcode,
                        child: const HugeIcon(
                          icon: HugeIcons.strokeRoundedQrCode01,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(List<Widget> items) {
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
        children: items,
      ),
    );
  }

  Widget _buildMenuItem({
    required List<List<dynamic>> icon,
    required String label,
    String? value,
    VoidCallback? onTap,
    required bool showDivider,
    bool hideArrow = false,
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
                    color: const Color(0xFF424242),
                  ),
                  16.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF374151),
                          ),
                        ),
                        if (value != null && value.isNotEmpty) ...[
                          4.verticalSpace,
                          Text(
                            value,
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!hideArrow)
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 16.w,
                      color: const Color(0xFF9CA3AF),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
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
