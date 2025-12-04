// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../widgets/custom_buttom.dart';
import '../../../widgets/menu_item_widgets.dart';
import 'mine_logic.dart';

class MinePage extends StatelessWidget {
  final logic = Get.find<MineLogic>();

  MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // 1. Header Background
            Container(
              height: 180.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withOpacity(0.7),
                    primaryColor,
                    primaryColor.withOpacity(0.9),
                  ],
                ),
              ),
              child: SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 12.h,left: 16.h),
                    child: Text(
                      StrRes.mine,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 2. Main Content Card
            Container(
              margin: EdgeInsets.only(top: 120.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: 60.h), // Space for avatar

                  // User Info
                  Obx(() {
                    final user = logic.imLogic.userInfo.value;
                    return Column(
                      children: [
                        Text(
                          user.nickname ?? '',
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        8.verticalSpace,
                        GestureDetector(
                          onTap: logic.copyID,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user.userID ?? '',
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              6.horizontalSpace,
                              Icon(
                                CupertinoIcons.doc_on_doc,
                                size: 14.sp,
                                color: primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),

                  24.verticalSpace,

                  // Action Buttons Row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomButton(
                          icon: CupertinoIcons.qrcode,
                          label: StrRes.qrcode,
                          onTap: logic.viewMyQrcode,
                        ),
                        CustomButton(
                          icon: CupertinoIcons.person,
                          label: StrRes.information,
                          onTap: logic.viewMyInfo,
                        ),
                        CustomButton(
                          icon: CupertinoIcons.settings,
                          label: StrRes.settings,
                          onTap: logic.accountSetup,
                        ),
                      ],
                    ),
                  ),

                  24.verticalSpace,
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),

                  // Menu List
                  _buildSectionTitle(StrRes.aboutSection),
                  MenuItemWidget(
                    icon: CupertinoIcons.person_crop_circle_badge_checkmark,
                    label: StrRes.realNameAuth,
                    onTap: logic.startRealNameAuth,
                  ),
                  MenuItemWidget(
                    icon: CupertinoIcons.shield,
                    label: StrRes.privacyPolicy,
                    onTap: logic.privacyPolicy,
                  ),
                  MenuItemWidget(
                    icon: CupertinoIcons.doc_text,
                    label: StrRes.serviceAgreement,
                    onTap: logic.serviceAgreement,
                  ),
                  MenuItemWidget(
                    icon: CupertinoIcons.info,
                    label: StrRes.aboutUs,
                    onTap: logic.aboutUs,
                  ),

                  _buildSectionTitle(StrRes.systemSection),
                  MenuItemWidget(
                    icon: CupertinoIcons.chart_bar,
                    label: StrRes.chatAnalytics,
                    onTap: logic.startChatAnalytics,
                  ),
                  MenuItemWidget(
                    icon: CupertinoIcons.delete,
                    label: StrRes.clearCache,
                    onTap: logic.clearCache,
                    textColor: const Color(0xFFEF4444),
                  ),

                  24.verticalSpace,

                
                  MenuItemWidget(
                    icon: Icons.logout,
                    label: StrRes.logout,
                    onTap: logic.logout,
                    textColor: const Color(0xFFEF4444),
                  ),
                  40.verticalSpace,
                ],
              ),
            ),

            // 3. Avatar (Overlapping)
            Positioned(
              top: 70.h, // 120 (margin) - 50 (half size)
              child: Obx(() {
                final user = logic.imLogic.userInfo.value;
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: AvatarView(
                    url: user.faceURL,
                    text: user.nickname,
                    width: 100.w,
                    height: 100.w,
                    textStyle: TextStyle(fontSize: 32.sp, color: Colors.white),
                    isCircle: true,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 24.w, top: 24.h, bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'FilsonPro',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}
