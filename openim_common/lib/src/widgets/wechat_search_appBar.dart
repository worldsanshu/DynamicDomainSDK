// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';

import '../res/styles/app_colors.dart';

class WechatSearchAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final bool enabled;
  final bool autofocus;
  final Color? color;
  final VoidCallback? onCancel;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Function()? onCleared;

  const WechatSearchAppBar({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.enabled = true,
    this.autofocus = true,
    this.color,
    this.onCancel,
    this.onChanged,
    this.onSubmitted,
    this.onCleared,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 8.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? const Color(0xFFF8FAFC),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: onCancel ?? () => Get.back(),
                child: Container(
                  width: 44.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.back,
                    size: 20,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: WechatStyleSearchBox(
                  controller: controller,
                  focusNode: focusNode,
                  hintText: hintText ?? StrRes.search,
                  enabled: enabled,
                  autofocus: autofocus,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  onCleared: onCleared,
                  margin: EdgeInsets.zero,
                  backgroundColor: const Color(0xFFFFFFFF),
                  searchIconColor: AppColors.iconColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
