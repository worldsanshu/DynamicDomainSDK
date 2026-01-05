// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim/pages/report_submit/report_submit_logic.dart';
import 'package:openim/widgets/custom_buttom.dart';
import 'package:openim/widgets/gradient_scaffold.dart';
import 'package:openim_common/openim_common.dart';

class ReportDetailPage extends StatelessWidget {
  ReportDetailPage({super.key});

  final logic = Get.find<ReportSubmitLogic>();

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: StrRes.reportSubmit,
      subtitle: logic.reportReason.value,
      showBackButton: true,
      trailing: CustomButton(
        onTap: logic.submitReport,
        icon: CupertinoIcons.paperplane,
        color: Colors.white,
      ),
      scrollable: false,
      body: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30.r),
        ),
        child: Container(
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
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF87171).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.flag_outlined,
                    size: 20.w,
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
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      4.verticalSpace,
                      Obx(() => Text(
                            logic.reportReason.value,
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF374151),
                            ),
                          )),
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
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        size: 22.w,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    10.horizontalSpace,
                    Text(
                      StrRes.detailedDescriptionLabel,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                16.verticalSpace,
                Container(
                  height: 140.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: logic.descriptionController,
                    focusNode: logic.descriptionFocusNode,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14.w),
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
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.photo_library_outlined,
                        size: 22.w,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    10.horizontalSpace,
                    Expanded(
                      child: Text(
                        StrRes.reportImages,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ),
                    Obx(() => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '${logic.images.length}/5',
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        )),
                  ],
                ),
                16.verticalSpace,
                Obx(() => Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: [
                        ...logic.images.map((e) => _buildPictureView(e)),
                        if (logic.images.length < 5) _buildAddButton(),
                      ],
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
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9CA3AF).withOpacity(0.08),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11.r),
            child: Image.file(
              file,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: -4,
          top: -4,
          child: GestureDetector(
            onTap: () => logic.removeImage(file),
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9CA3AF).withOpacity(0.15),
                    offset: const Offset(0, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Icon(
                Icons.close_rounded,
                size: 14.w,
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
        width: 80.w,
        height: 80.w,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 24.w,
              color: const Color(0xFF9CA3AF),
            ),
            4.verticalSpace,
            Text(
              StrRes.add,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
