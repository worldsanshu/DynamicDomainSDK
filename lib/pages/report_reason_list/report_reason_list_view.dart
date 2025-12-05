// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim/pages/report_reason_list/report_reason_list_logic.dart';
import 'package:openim/widgets/gradient_scaffold.dart';
import 'package:openim_common/openim_common.dart';

class ReportReasonListPage extends StatelessWidget {
  ReportReasonListPage({super.key});

  final logic = Get.find<ReportReasonListLogic>();

  Map<String, List<String>> get reportGroups => {
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

  IconData _getIconForCategory(int index) {
    final icons = [
      Icons.campaign_outlined,
      Icons.security_outlined,
      Icons.warning_amber_outlined,
      Icons.person_off_outlined,
      Icons.privacy_tip_outlined,
      Icons.child_care_outlined,
      Icons.more_horiz_outlined,
    ];
    return icons[index % icons.length];
  }

  Color _getColorForCategory(int index) {
    final colors = [
      const Color(0xFFEF4444), // Red - Spam
      const Color(0xFFF59E0B), // Amber - Fraud
      const Color(0xFF8B5CF6), // Purple - Inappropriate
      const Color(0xFFEC4899), // Pink - Harassment
      const Color(0xFF06B6D4), // Cyan - Privacy
      const Color(0xFF10B981), // Green - Minor
      const Color(0xFF6B7280), // Gray - Other
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffoldWithBack(
      title: StrRes.report,
      headerTrailing: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.flag_outlined,
          color: Colors.white,
          size: 22.w,
        ),
      ),
      content: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30.r),
        ),
        child: Container(
          color: const Color(0xFFF9FAFB),
          child: Column(
            children: [
              // Report Title Section
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(
                  top: 20.h,
                  left: 16.w,
                  right: 16.w,
                  bottom: 12.h,
                ),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9CA3AF).withOpacity(0.08),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: const Color(0xFF3B82F6),
                      size: 20.w,
                    ),
                    12.horizontalSpace,
                    Expanded(
                      child: Obx(() => Text(
                            logic.reportTitle.value,
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF374151),
                            ),
                          )),
                    ),
                  ],
                ),
              ),

              // Report Categories List
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      top: 8.h,
                      bottom: 24.h,
                      left: 16.w,
                      right: 16.w,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: reportGroups.length,
                    itemBuilder: (context, index) {
                      final entry = reportGroups.entries.elementAt(index);
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          curve: Curves.easeOutCubic,
                          verticalOffset: 30.0,
                          child: FadeInAnimation(
                            curve: Curves.easeOutCubic,
                            child: _buildReportSection(
                              entry.key,
                              entry.value,
                              index,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportSection(
      String title, List<String> options, int categoryIndex) {
    final categoryColor = _getColorForCategory(categoryIndex);
    final categoryIcon = _getIconForCategory(categoryIndex);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: categoryColor.withOpacity(0.1),
          highlightColor: categoryColor.withOpacity(0.05),
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          childrenPadding: EdgeInsets.zero,
          initiallyExpanded: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          leading: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              categoryIcon,
              color: categoryColor,
              size: 20.w,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          subtitle: Text(
            '${options.length} ${StrRes.options}',
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          trailing: Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFF6B7280),
              size: 20.w,
            ),
          ),
          children: options.asMap().entries.map((optionEntry) {
            final isLast = optionEntry.key == options.length - 1;
            return Column(
              children: [
                if (optionEntry.key == 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF3F4F6),
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        logic.handleReport(reportReason: optionEntry.value),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            margin: EdgeInsets.only(left: 16.w),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                          16.horizontalSpace,
                          Expanded(
                            child: Text(
                              optionEntry.value,
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4B5563),
                              ),
                            ),
                          ),
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowRight01,
                            size: 16.w,
                            color: const Color(0xFF9CA3AF),
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
                    indent: 56.w,
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
