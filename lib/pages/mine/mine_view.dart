// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../widgets/gradient_scaffold.dart';
import '../../widgets/settings_menu.dart';
import '../../widgets/section_title.dart';
import 'mine_logic.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  final logic = Get.find<MineLogic>();

  @override
  void initState() {
    super.initState();
    // Unfocus keyboard when returning to this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: GradientScaffold(
        title: StrRes.mine,
        // Avatar overlapping header and body
        avatar: Obx(() {
          final user = logic.imLogic.userInfo.value;
          return ProfileHeaderAvatar(
            url: user.faceURL,
            text: user.nickname,
            onTap: logic.viewMyInfo,
          );
        }),
        body: Column(
          children: [
            // Name and ID Section (below avatar)
            Obx(() {
              final user = logic.imLogic.userInfo.value;
              return Column(
                children: [
                  // Name
                  Text(
                    user.nickname ?? '',
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  8.verticalSpace,
                  // ID with copy button
                  GestureDetector(
                    onTap: logic.copyID,
                    behavior: HitTestBehavior.opaque,
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

            20.verticalSpace,

            // Action Buttons Row (QR Code, Information, Settings)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  context,
                  icon: CupertinoIcons.qrcode,
                  label: StrRes.qrcode,
                  onTap: logic.viewMyQrcode,
                  primaryColor: primaryColor,
                ),
                32.horizontalSpace,
                _buildActionButton(
                  context,
                  icon: CupertinoIcons.person,
                  label: StrRes.information,
                  onTap: logic.viewMyInfo,
                  primaryColor: primaryColor,
                ),
                32.horizontalSpace,
                _buildActionButton(
                  context,
                  icon: CupertinoIcons.settings,
                  label: StrRes.settings,
                  onTap: logic.accountSetup,
                  primaryColor: primaryColor,
                ),
              ],
            ),

            20.verticalSpace,
            const Divider(height: 1, color: Color(0xFFF3F4F6)),

            // === SCROLLABLE SECTION ===
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    // Menu List
                    SectionTitle(title: StrRes.aboutSection),
                    SettingsMenuSection(
                      items: [
                        SettingsMenuItem(
                          icon:
                              CupertinoIcons.person_crop_circle_badge_checkmark,
                          label: StrRes.realNameAuth,
                          onTap: logic.startRealNameAuth,
                        ),
                        // My Company - conditionally displayed
                        Obx(() {
                          if (logic.showMyCompanyEntry == true) {
                            return const SizedBox.shrink();
                          }
                          return SettingsMenuItem(
                            icon: CupertinoIcons.building_2_fill,
                            label: StrRes.myCompany,
                            onTap: logic.startMerchantList,
                          );
                        }),
                        SettingsMenuItem(
                          icon: CupertinoIcons.shield,
                          label: StrRes.privacyPolicy,
                          onTap: logic.privacyPolicy,
                        ),
                        SettingsMenuItem(
                          icon: CupertinoIcons.doc_text,
                          label: StrRes.serviceAgreement,
                          onTap: logic.serviceAgreement,
                        ),
                        SettingsMenuItem(
                          icon: CupertinoIcons.info,
                          label: StrRes.aboutUs,
                          onTap: logic.aboutUs,
                          showDivider: false,
                        ),
                      ],
                    ),

                    20.verticalSpace,

                    SectionTitle(title: StrRes.systemSection),
                    SettingsMenuSection(
                      items: [
                        // SettingsMenuItem(
                        //   icon: CupertinoIcons.chart_bar,
                        //   label: StrRes.chatAnalytics,
                        //   onTap: logic.startChatAnalytics,
                        // ),
                        SettingsMenuItem(
                          icon: Icons.logout,
                          label: StrRes.logout,
                          onTap: logic.logout,
                          isDestroy: true,
                          showDivider: false,
                        ),
                      ],
                    ),
                    40.verticalSpace,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build circular action button with icon and label
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24.sp,
              color: primaryColor,
            ),
          ),
          8.verticalSpace,
          Text(
            label,
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}
