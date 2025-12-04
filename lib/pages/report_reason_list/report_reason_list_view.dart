// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim/pages/report_reason_list/report_reason_list_logic.dart';
import 'package:openim_common/openim_common.dart';
import '../../widgets/base_page.dart';

class ReportReasonListPage extends StatelessWidget {
  ReportReasonListPage({super.key});

  final logic = Get.find<ReportReasonListLogic>();

  final Map<String, List<String>> reportGroups = {
    StrRes.reportCategorySpamAndAds: [
      StrRes.reportReasonMaliciousAds,
      StrRes.reportReasonMassSpamming,
      StrRes.reportReasonMisleadingAds,
      StrRes.reportReasonMaliciousMassInvites,
    ],
    StrRes.reportCategoryFraudAndSecurity: [
      StrRes.reportReasonFraudImpersonation,
      StrRes.reportReasonPhishingMalware,
      StrRes.reportReasonIdentityImpersonation,
    ],
    StrRes.reportCategoryInappropriateContent: [
      StrRes.reportReasonPornographicContent,
      StrRes.reportReasonViolentGoreContent,
      StrRes.reportReasonHateOrExtremistSpeech,
      StrRes.reportReasonPoliticallySensitiveViolation,
    ],
    StrRes.reportCategoryHarassmentAndBullying: [
      StrRes.reportReasonInsultsPersonalAttacks,
      StrRes.reportReasonHarassmentSexualHarassment,
      StrRes.reportReasonBaitingBehavior,
    ],
    StrRes.reportCategoryPrivacyAndRights: [
      StrRes.reportReasonPrivacyLeak,
      StrRes.reportReasonCopyrightInfringement,
    ],
    StrRes.reportCategoryMinorProtection: [
      StrRes.reportReasonInducingMinorViolation,
      StrRes.reportReasonInappropriateForMinors,
    ],
    StrRes.reportCategoryOther: [
      StrRes.reportReasonAbuseReportingFunction,
      StrRes.reportReasonInsultPlatformAdmin,
      StrRes.reportReasonSeriouslyAffectsExperience,
    ],
  };

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      title: StrRes.report,
      centerTitle: false,
      showLeading: true,
      body: Container(
        width: double.infinity,
        color: const Color(0xFFF9FAFB),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              16.verticalSpace,

              // Title Section
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9CA3AF).withOpacity(0.06),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  logic.reportTitle.value,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),

              16.verticalSpace,

              // Report Categories
              ...reportGroups.entries.map((entry) {
                int groupIndex = reportGroups.keys.toList().indexOf(entry.key);
                return AnimationConfiguration.staggeredList(
                  position: groupIndex,
                  duration: const Duration(milliseconds: 300),
                  child: SlideAnimation(
                    curve: Curves.easeOutCubic,
                    verticalOffset: 20.0,
                    child: FadeInAnimation(
                      curve: Curves.easeOutCubic,
                      child: _buildReportSection(entry.key, entry.value),
                    ),
                  ),
                );
              }),

              24.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportSection(String title, List<String> options) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.06),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
          ),

          // Section Items
          ...options.asMap().entries.map((optionEntry) {
            final isLast = optionEntry.key == options.length - 1;
            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        logic.handleReport(reportReason: optionEntry.value),
                    borderRadius: isLast
                        ? BorderRadius.only(
                            bottomLeft: Radius.circular(16.r),
                            bottomRight: Radius.circular(16.r),
                          )
                        : null,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 16.h),
                      child: Row(
                        children: [
                          Container(
                            width: 20.w,
                            height: 20.h,
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedFlag03,
                              size: 16.w,
                              color: AppColor.iconColor,
                            ),
                          ),
                          12.horizontalSpace,
                          Expanded(
                            child: Text(
                              optionEntry.value,
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ),
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowRight01,
                            size: 16.w,
                            color: const Color(0xFF6B7280),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: const Color(0xFFF3F4F6),
                    indent: 48.w,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
