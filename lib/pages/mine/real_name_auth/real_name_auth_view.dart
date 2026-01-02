// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim/widgets/custom_buttom.dart';
import 'package:openim/widgets/gradient_scaffold.dart';
import 'package:openim_common/openim_common.dart';
import 'real_name_auth_logic.dart';

class RealNameAuthView extends StatelessWidget {
  final logic = Get.find<RealNameAuthLogic>();

  RealNameAuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: StrRes.authentication,
      subtitle: StrRes.realNameAuth,
      showBackButton: true,
      trailing: CustomButton(
          icon: CupertinoIcons.refresh,
          onTap: logic.loadAuthInfo,
          color: Colors.white),
      scrollable: true,
      body: Obx(
        () => logic.isLoading.value
            ? Center(
                child: SpinKitFadingCircle(color: Color(0xFF8E9AB0)),
              )
            : AnimationLimiter(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 420),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 40.0,
                        curve: Curves.easeOutQuart,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: _buildStatusCard(),
                        ),
                        12.verticalSpace,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                  child: Icon(
                    _getStatusIcon(logic.authStatus.value),
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
              label: '${StrRes.realName} *',
              hint: StrRes.plsEnterRealName,
              icon: CupertinoIcons.person,
              validator: _validateName,
            ),
            16.verticalSpace,
            _buildInputField(
              controller: logic.idCardNumberController,
              focusNode: logic.idCardNumberFocusNode,
              label: '${StrRes.realNameIdCardNumber} *',
              hint: StrRes.plsEnter18DigitIdCard,
              icon: CupertinoIcons.doc,
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
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.contains('*'))
          RichText(
            text: TextSpan(
              text: label.replaceAll(' *', ''),
              style: const TextStyle(fontFamily: 'FilsonPro').copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
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
                child: Icon(icon, size: 22.w, color: AppColor.iconColor),
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
            title: '${StrRes.idCardFront} *',
            imageUrl: logic.idCardFrontUrl.value,
            onTap: logic.selectIdCardFrontImage,
            onGallery: logic.pickIdCardFrontFromGallery,
            errorText: logic.showImageErrorFront.value
                ? StrRes.plsUploadIdCardFront
                : null,
          ),
          12.verticalSpace,
          _buildImageUploadItem(
            title: '${StrRes.idCardBack} *',
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
                      Icon(
                        CupertinoIcons.camera,
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
          onPressed: logic.submitRealNameAuth,
          style: ElevatedButton.styleFrom(
            backgroundColor: logic.isSubmitButtonEnabled.value
                ? const Color(0xFF3B82F6)
                : const Color(0xFFF3F4F6),
            // We want the button to handle taps even when "visually" disabled to show errors
            // So we don't use 'disabledBackgroundColor' in the traditional sense for logic
            foregroundColor: Colors.white,
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
              Icon(
                CupertinoIcons.flag,
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
          _buildInfoRow(StrRes.realName, authInfo['realName'] ?? ''),
          8.verticalSpace,
          _buildInfoRow(
              StrRes.realNameIdCardNumber, authInfo['idCardMasked'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        text: '$label:  ',
        style: const TextStyle(fontFamily: 'FilsonPro').copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF6B7280),
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(fontFamily: 'FilsonPro').copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  dynamic _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return CupertinoIcons.doc;
      case 1:
        return CupertinoIcons.clock;
      case 2:
        return CupertinoIcons.checkmark_circle;
      case 3:
        return CupertinoIcons.xmark;
      default:
        return CupertinoIcons.info_circle;
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
