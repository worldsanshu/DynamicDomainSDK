// ignore_for_file: deprecated_member_use

import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim_common/openim_common.dart';

import '../../../core/controller/im_controller.dart';
import 'my_info_logic.dart';

class MyInfoPage extends StatelessWidget {
  final logic = Get.find<MyInfoLogic>();
  final imLogic = Get.find<IMController>();

  MyInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 1. Header Background
          Container(
            height: 220.h,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.8),
                  primaryColor,
                  primaryColor.withOpacity(0.95),
                ],
              ),
            ),
            child: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          color: Colors.transparent,
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20.w,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          StrRes.myInfo,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontWeight: FontWeight.w700,
                            fontSize: 20.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 36.w), // Balance the back button
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Main Content
          Container(
            margin: EdgeInsets.only(top: 160.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                  top: 60.h, bottom: 40.h, left: 16.w, right: 16.w),
              child: Column(
                children: [
                  // User ID
                  Obx(() {
                    final user = imLogic.userInfo.value;
                    return GestureDetector(
                      onTap: () {
                        if (user.userID != null) {
                          Clipboard.setData(ClipboardData(text: user.userID!));
                          ScaffoldMessenger.of(Get.context!).showSnackBar(
                              SnackBar(content: Text(StrRes.idCopied)));
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ID: ${user.userID ?? ''}',
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            8.horizontalSpace,
                            Icon(
                              CupertinoIcons.doc_on_doc,
                              size: 14.sp,
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  24.verticalSpace,

                  // Info Group
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoItem(
                          icon: HugeIcons.strokeRoundedUser,
                          label: StrRes.nickname,
                          valueObx: () => imLogic.userInfo.value.nickname ?? '',
                          onTap: logic.editMyName,
                          isFirst: true,
                        ),
                        _buildDivider(),
                        _buildInfoItem(
                          icon: HugeIcons.strokeRoundedUserMultiple,
                          label: StrRes.gender,
                          valueObx: () => imLogic.userInfo.value.gender == 1
                              ? StrRes.man
                              : StrRes.woman,
                          onTap: logic.selectGender,
                        ),
                        _buildDivider(),
                        _buildInfoItem(
                          icon: HugeIcons.strokeRoundedCalendar03,
                          label: StrRes.birthDay,
                          valueObx: () => DateUtil.formatDateMs(
                            imLogic.userInfo.value.birth ?? 0,
                            format: IMUtils.getTimeFormat1(),
                          ),
                          onTap: logic.openDatePicker,
                        ),
                        _buildDivider(),
                        _buildInfoItem(
                          icon: HugeIcons.strokeRoundedCall,
                          label: StrRes.mobile,
                          valueObx: () =>
                              imLogic.userInfo.value.phoneNumber ?? '',
                          hideArrow: true,
                        ),
                        _buildDivider(),
                        _buildInfoItem(
                          icon: HugeIcons.strokeRoundedQrCode01,
                          label: StrRes.qrcode,
                          onTap: logic.viewMyQrcode,
                          isLast: true,
                          trailing: Icon(
                            CupertinoIcons.qrcode,
                            size: 20.w,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Avatar (Overlapping)
          Positioned(
            top: 110.h,
            child: Obx(() {
              final user = imLogic.userInfo.value;
              return GestureDetector(
                onTap: logic.openUpdateAvatarSheet,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: AvatarView(
                        url: user.faceURL,
                        text: user.nickname,
                        width: 100.w,
                        height: 100.w,
                        textStyle:
                            TextStyle(fontSize: 32.sp, color: Colors.white),
                        isCircle: true,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 4.w, bottom: 4.w),
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF212121),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedCamera01,
                        size: 14.w,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.only(left: 56.w, right: 16.w),
      child: const Divider(height: 1, color: Color(0xFFF3F4F6)),
    );
  }

  Widget _buildInfoItem({
    required dynamic icon,
    required String label,
    String Function()? valueObx,
    VoidCallback? onTap,
    bool hideArrow = false,
    bool isFirst = false,
    bool isLast = false,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? Radius.circular(20.r) : Radius.zero,
          bottom: isLast ? Radius.circular(20.r) : Radius.zero,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: icon is IconData
                    ? Icon(icon, size: 20.w, color: const Color(0xFF4B5563))
                    : HugeIcon(
                        icon: icon,
                        size: 20.w,
                        color: const Color(0xFF4B5563),
                      ),
              ),
              16.horizontalSpace,
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (valueObx != null)
                      Obx(() => Flexible(
                            child: Text(
                              valueObx(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          )),
                    if (trailing != null) trailing,
                  ],
                ),
              ),
              if (!hideArrow && trailing == null) ...[
                8.horizontalSpace,
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14.w,
                  color: const Color(0xFF9CA3AF),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
