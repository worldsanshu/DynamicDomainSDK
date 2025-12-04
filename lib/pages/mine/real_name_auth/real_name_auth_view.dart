// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim/widgets/custom_buttom.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim/pages/auth/widget/app_text_button.dart';
import 'real_name_auth_logic.dart';

class RealNameAuthView extends StatelessWidget {
  final logic = Get.find<RealNameAuthLogic>();

  RealNameAuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 1. Header Background
          Container(
            height: 200.h,
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          behavior: HitTestBehavior.translucent,
                          child: Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                StrRes.realNameAuth,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24.sp,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              6.verticalSpace,
                              Text(
                                StrRes.identityVerification,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.sp,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                        10.horizontalSpace,
                        CustomButton(
                          icon: CupertinoIcons.refresh,
                          onTap: logic.loadAuthInfo,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Content Card
          Container(
            margin: EdgeInsets.only(top: 150.h),
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
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
              child: Obx(
                () => logic.isLoading.value
                    ? const Center(
                        child: SpinKitFadingCircle(color: Color(0xFF8E9AB0)),
                      )
                    : AnimationLimiter(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(bottom: 40.h, top: 20.h),
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              FocusScope.of(context).unfocus();
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: AnimationConfiguration.toStaggeredList(
                                duration: const Duration(milliseconds: 420),
                                childAnimationBuilder: (widget) =>
                                    SlideAnimation(
                                  verticalOffset: 40.0,
                                  curve: Curves.easeOutQuart,
                                  child: FadeInAnimation(child: widget),
                                ),
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.w),
                                    child: _buildStatusCard(),
                                  ),
                                  12.verticalSpace,
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.w),
                                    child: logic.canEdit
                                        ? Column(
                                            children: [
                                              _buildFormCard(),
                                              12.verticalSpace,
                                              _buildImageUploadCard(),
                                              20.verticalSpace,
                                              _buildSubmitButton(),
                                            ],
                                          )
                                        : logic.authStatus.value == 3
                                            ? Column(
                                                children: [
                                                  _buildRejectReasonCard(),
                                                  12.verticalSpace,
                                                  _buildResubmitButton(),
                                                ],
                                              )
                                            : _buildApprovedInfoCard(),
                                  ),
                                  30.verticalSpace,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2540).withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: 8.r,
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: logic.statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: _getStatusIcon(logic.authStatus.value),
                    size: 24.w,
                    color: logic.statusColor,
                  ),
                ),
              ),
              16.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      StrRes.realNameAuthStatus,
                      style: const TextStyle(fontFamily: 'FilsonPro').copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                    6.verticalSpace,
                    Text(
                      logic.statusText,
                      style: const TextStyle(fontFamily: 'FilsonPro').copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: logic.statusColor,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (logic.authInfo.value?['verifiedAt'] != null) ...[
            12.verticalSpace,
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F7F9),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '${StrRes.authTime}: ${_formatTime(logic.authInfo.value!['verifiedAt'])}',
                style: const TextStyle(fontFamily: 'FilsonPro').copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
          if (logic.authStatus.value == 3) ...[
            8.verticalSpace,
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F7F9),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '${StrRes.remark}: ${logic.rejectRemark}',
                style: const TextStyle(fontFamily: 'FilsonPro').copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2540).withOpacity(0.03),
            offset: const Offset(0, 1),
            blurRadius: 6.r,
          ),
        ],
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Form(
        key: logic.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StrRes.realNamePersonalInfo,
              style: const TextStyle(fontFamily: 'FilsonPro').copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            16.verticalSpace,
            _buildInputField(
              controller: logic.realNameController,
              focusNode: logic.realNameFocusNode,
              label: StrRes.realName,
              hint: StrRes.plsEnterRealName,
              icon: HugeIcons.strokeRoundedUser,
              validator: _validateName,
            ),
            16.verticalSpace,
            _buildInputField(
              controller: logic.idCardNumberController,
              focusNode: logic.idCardNumberFocusNode,
              label: StrRes.realNameIdCardNumber,
              hint: StrRes.plsEnter18DigitIdCard,
              icon: HugeIcons.strokeRoundedFile01,
              validator: _validateIdNumber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required dynamic icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontFamily: 'FilsonPro').copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        8.verticalSpace,
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(fontFamily: 'FilsonPro').copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontFamily: 'FilsonPro').copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF9CA3AF),
            ),
            prefixIcon: Container(
              margin: EdgeInsets.all(12.w),
              width: 24.w,
              height: 24.h,
              child: Center(
                child: HugeIcon(
                    icon: icon as List<List<dynamic>>,
                    size: 18.w,
                    color: AppColor.iconColor),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: Color(0xFF4F42FF),
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2540).withOpacity(0.03),
            offset: const Offset(0, 1),
            blurRadius: 6.r,
          ),
        ],
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StrRes.idCardPhotos,
            style: const TextStyle(fontFamily: 'FilsonPro').copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
          4.verticalSpace,
          Text(
            StrRes.plsEnsurePhotoClarity,
            style: const TextStyle(fontFamily: 'FilsonPro').copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),
          16.verticalSpace,
          _buildImageUploadItem(
            title: StrRes.idCardFront,
            imageUrl: logic.idCardFrontUrl.value,
            onTap: logic.selectIdCardFrontImage,
            onGallery: logic.pickIdCardFrontFromGallery,
            errorText: logic.showImageErrorFront.value
                ? StrRes.plsUploadIdCardFront
                : null,
          ),
          12.verticalSpace,
          _buildImageUploadItem(
            title: StrRes.idCardBack,
            imageUrl: logic.idCardBackUrl.value,
            onTap: logic.selectIdCardBackImage,
            onGallery: logic.pickIdCardBackFromGallery,
            errorText: logic.showImageErrorBack.value
                ? StrRes.plsUploadIdCardBack
                : null,
          ),
          12.verticalSpace,
          _buildImageUploadItem(
            title: StrRes.idCardHolding,
            imageUrl: logic.idCardHandheldUrl.value,
            onTap: logic.selectIdCardHandheldImage,
            onGallery: logic.pickIdCardHandheldFromGallery,
            errorText: logic.showImageErrorHandheld.value
                ? StrRes.plsUploadIdCardHolding
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadItem({
    required String title,
    required String? imageUrl,
    required VoidCallback onTap,
    VoidCallback? onGallery,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 120.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: imageUrl != null
              ? Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: GestureDetector(
                          onTap: () {
                            Get.dialog(
                              Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: EdgeInsets.zero,
                                child: GestureDetector(
                                  onTap: () => Get.back(),
                                  child: InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 1.0,
                                    maxScale: 4.0,
                                    child: Center(
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              barrierDismissible: true,
                            );
                          },
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12.w,
                      right: 12.w,
                      bottom: 8.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 32.h,
                            child: OutlinedButton(
                              onPressed: onTap,
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: Color(0xFFE5E7EB)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                backgroundColor: Colors.white.withOpacity(0.9),
                              ),
                              child: Text(
                                StrRes.edit,
                                style: const TextStyle(fontFamily: 'FilsonPro')
                                    .copyWith(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onTap,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedCamera01,
                        size: 32.w,
                        color: const Color(0xFF9CA3AF),
                      ),
                      8.verticalSpace,
                      Text(
                        title,
                        style:
                            const TextStyle(fontFamily: 'FilsonPro').copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        if (errorText != null && imageUrl == null)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              errorText,
              style: TextStyle(color: Colors.red.shade700, fontSize: 12.sp),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: logic.isSubmitButtonEnabled.value
              ? logic.submitRealNameAuth
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: logic.isSubmitButtonEnabled.value
                ? const Color(0xFF3B82F6)
                : const Color(0xFFF3F4F6),
            disabledBackgroundColor: const Color(0xFFF3F4F6),
            foregroundColor: Colors.white,
            disabledForegroundColor: const Color(0xFFD1D5DB),
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          child: Text(
            StrRes.submitAuth,
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: logic.isSubmitButtonEnabled.value
                  ? Colors.white
                  : const Color(0xFFC5CAD3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRejectReasonCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFF87171),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF87171).withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedFlag03,
                size: 20.w,
                color: const Color(0xFFF87171),
              ),
              8.horizontalSpace,
              Text(
                StrRes.reviewFailedReason,
                style: const TextStyle(fontFamily: 'FilsonPro').copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF87171),
                ),
              ),
            ],
          ),
          12.verticalSpace,
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF87171).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              logic.rejectRemark.isNotEmpty
                  ? logic.rejectRemark
                  : StrRes.noReasonProvided,
              style: const TextStyle(fontFamily: 'FilsonPro').copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: logic.resubmitAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF97373),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          StrRes.resubmitAuth,
          style: const TextStyle(fontFamily: 'FilsonPro').copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildApprovedInfoCard() {
    final authInfo = logic.authInfo.value;
    if (authInfo == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: logic.statusColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StrRes.realNameAuthInfo,
            style: const TextStyle(fontFamily: 'FilsonPro').copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: logic.statusColor,
            ),
          ),
          16.verticalSpace,
          _buildInfoRow(StrRes.realNameAuthName, authInfo['realName'] ?? ''),
          8.verticalSpace,
          _buildInfoRow(
              StrRes.realNameIdNumber, authInfo['idCardMasked'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            style: const TextStyle(fontFamily: 'FilsonPro').copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontFamily: 'FilsonPro').copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }

  dynamic _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return HugeIcons.strokeRoundedFile01;
      case 1:
        return HugeIcons.strokeRoundedClock01;
      case 2:
        return HugeIcons.strokeRoundedCheckmarkCircle02;
      case 3:
        return HugeIcons.strokeRoundedCancel01;
      default:
        return HugeIcons.strokeRoundedInformationCircle;
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      int milliseconds;
      if (timestamp is int) {
        milliseconds =
            timestamp.toString().length <= 10 ? timestamp * 1000 : timestamp;
      } else if (timestamp is String) {
        final dateTime = DateTime.parse(timestamp);
        milliseconds = dateTime.millisecondsSinceEpoch;
      } else {
        return timestamp.toString();
      }

      final languageCode = Get.locale?.languageCode ?? 'zh';
      final isChinese = languageCode == 'zh';

      final timeStr = IMUtils.formatDateMs(milliseconds, format: 'HH:mm');

      String dateStr;
      dateStr = isChinese
          ? IMUtils.formatDateMs(milliseconds, format: 'yyyy年MM月dd日')
          : IMUtils.formatDateMs(milliseconds, format: 'yyyy/MM/dd');

      return '$dateStr $timeStr';
    } catch (e) {
      return timestamp.toString();
    }
  }

  String? _validateName(String? value) {
    if (value == null) return StrRes.plsEnterRealNamePrompt;
    final v = value.trim();

    if (v.isEmpty || v.length > 20 || v.length < 2) {
      return StrRes.plsEnterRealNamePrompt;
    }

    final allowPattern = RegExp(r"^[\u4e00-\u9fffA-Za-z\-\'·\s]+");

    if (!allowPattern.hasMatch(v)) {
      return StrRes.plsEnterRealNamePrompt;
    }

    // Disallow any digits
    if (RegExp(r"\d").hasMatch(v)) {
      return StrRes.plsEnterRealNamePrompt;
    }

    final emojiPattern = RegExp(
        r'[\u{1F300}-\u{1F6FF}\u{1F900}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true);
    if (emojiPattern.hasMatch(v)) {
      return StrRes.plsEnterRealNamePrompt;
    }

    return null;
  }

  String? _validateIdNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return StrRes.plsEnterValidIdCardNumber;
    }

    final logic = Get.find<RealNameAuthLogic>();
    if (!logic.validateIdCardNumber(value.trim())) {
      return StrRes.plsEnterValidIdCardNumber;
    }

    return null;
  }
}
