// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../widgets/custom_buttom.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../../widgets/menu_item_widgets.dart';
import 'mine_logic.dart';

class MinePage extends StatelessWidget {
  final logic = Get.find<MineLogic>();

  MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return GradientScaffold(
      title: StrRes.mine,
      scrollable: true,
      avatar: Obx(() => AvatarView(
            url: logic.imLogic.userInfo.value.faceURL,
            text: logic.imLogic.userInfo.value.nickname,
            width: 100.w,
            height: 100.w,
            textStyle: TextStyle(fontSize: 32.sp, color: Colors.white),
            isCircle: true,
            onTap: logic.viewMyInfo,
          )),
      body: Column(
        children: [
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
                  color: primaryColor,
                ),
                CustomButton(
                  icon: CupertinoIcons.person,
                  label: StrRes.information,
                  onTap: logic.viewMyInfo,
                  color: primaryColor,
                ),
                CustomButton(
                  icon: CupertinoIcons.settings,
                  label: StrRes.settings,
                  onTap: logic.accountSetup,
                  color: primaryColor,
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
          // My Company - conditionally displayed
          Obx(() {
            if (logic.showMyCompanyEntry==true) {
              return const SizedBox.shrink();
            }
            return MenuItemWidget(
              icon: CupertinoIcons.building_2_fill,
              label: StrRes.myCompany,
              onTap: logic.startMerchantList,
            );
          }),
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
          MenuItemWidget(
            icon: Icons.logout,
            label: StrRes.logout,
            onTap: logic.logout,
            textColor: const Color(0xFFEF4444),
          ),
          40.verticalSpace,
        ],
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
