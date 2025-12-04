// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class MerchantItemCupertino extends StatelessWidget {
  final Merchant merchant;
  final bool isCurrent;
  final VoidCallback? onBtnTap;
  final String btnStr;
  final bool isDefault;

  const MerchantItemCupertino({
    super.key,
    required this.merchant,
    this.isCurrent = false,
    required this.onBtnTap,
    required this.btnStr,
    this.isDefault = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onBtnTap,
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAvatar(),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildCompanyInfo(),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isCurrent) _buildCurrentBadge(),
                  if (isCurrent) SizedBox(width: 12.w),
                  _buildOperationButton(btnStr, onBtnTap),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: ImageRes.loginLogo.toImage,
      )
    );
  }

  Widget _buildCompanyInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${StrRes.invitationCode}: ${merchant.inviteCode.isNotEmpty ? merchant.inviteCode : (DataSp.getSavedInviteCode() ?? '${StrRes.companyId}: ${merchant.id}')}',
          style: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        6.verticalSpace,
        Text(
          '${StrRes.companyId}: ${merchant.id}',
          style: TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280
    ),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCurrentBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFF4F42FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.star_fill,
            size: 12.w,
            color: const Color(0xFF4F42FF),
          ),
          4.horizontalSpace,
          Text(
            StrRes.currentCompany,
            style: TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4F42FF
    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationButton(String title, VoidCallback? onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 36.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF4F42FF),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
    ),
          ),
        ),
      ),
    );
  }
}
