// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim/pages/report_submit/report_submit_logic.dart';
import 'package:openim/widgets/custom_buttom.dart';
import 'package:openim_common/openim_common.dart';
import '../../widgets/base_page.dart';

class ReportDetailPage extends StatelessWidget {
  ReportDetailPage({super.key});

  final logic = Get.find<ReportSubmitLogic>();

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: BasePage(
        showAppBar: true,
        title: StrRes.reportSubmit,
        centerTitle: false,
        showLeading: true,
        actions: [
          CustomButtom(
            margin: EdgeInsets.symmetric(horizontal: 5.w),
            onPressed: logic.submitReport,
            title: StrRes.confirm,
            colorButton: const Color(0xFF4F42FF).withOpacity(0.8),
          ),
        ],
        body: Container(
          width: double.infinity,
          color: const Color(0xFFF9FAFB),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.verticalSpace,
                  _buildReportReason(),
                  16.verticalSpace,
                  _buildDescriptionInput(),
                  16.verticalSpace,
                  _buildImageSection(),
                  24.verticalSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportReason() {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 300),
      child: SlideAnimation(
        curve: Curves.easeOutCubic,
        verticalOffset: 20.0,
        child: FadeInAnimation(
          child: Container(
            width: double.infinity,
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
            child: Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF87171).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.all(5.w),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedAlert02,
                    size: 16.w,
                    color: const Color(0xFFF87171),
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        StrRes.reportReasonLabel,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      4.verticalSpace,
                      Text(
                        logic.reportReason.value,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
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

  Widget _buildDescriptionInput() {
    return AnimationConfiguration.staggeredList(
      position: 1,
      duration: const Duration(milliseconds: 300),
      child: SlideAnimation(
        curve: Curves.easeOutCubic,
        verticalOffset: 20.0,
        child: FadeInAnimation(
          child: Container(
            width: double.infinity,
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
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedEdit02,
                      size: 16.w,
                      color: const Color(0xFF6B7280),
                    ),
                    8.horizontalSpace,
                    Text(
                      StrRes.detailedDescriptionLabel,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                16.verticalSpace,
                Container(
                  height: 120.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFFF3F4F6),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: logic.descriptionController,
                    focusNode: logic.descriptionFocusNode,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12.w),
                      hintText: StrRes.enterDetailedReportContent,
                      hintStyle: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return AnimationConfiguration.staggeredList(
      position: 2,
      duration: const Duration(milliseconds: 300),
      child: SlideAnimation(
        curve: Curves.easeOutCubic,
        verticalOffset: 20.0,
        child: FadeInAnimation(
          child: Container(
            width: double.infinity,
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
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedImage01,
                      size: 16.w,
                      color: const Color(0xFF6B7280),
                    ),
                    8.horizontalSpace,
                    Text(
                      StrRes.reportImages,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                16.verticalSpace,
                Obx(() => SizedBox(
                      child: Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: [
                          ...logic.images.map((e) => _buildPictureView(e)),
                          if (logic.images.length < 5) _buildAddButton(),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPictureView(File file) {
    return Stack(
      children: [
        Container(
          width: 90.w,
          height: 90.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFF3F4F6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9CA3AF).withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(
              file,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () => logic.removeImage(file),
            child: Container(
              width: 22.w,
              height: 22.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF87171),
                borderRadius: BorderRadius.circular(11.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9CA3AF).withOpacity(0.1),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedCancel01,
                size: 12.w,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: logic.pickImage,
      child: Container(
        width: 70.w,
        height: 70.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFF3F4F6),
            width: 1,
          ),
        ),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedCamera01,
          size: 20.w,
          color: const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}
