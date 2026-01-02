// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';
import '../../../widgets/custom_buttom.dart';
import '../../../widgets/gradient_scaffold.dart';
import '../../../widgets/section_title.dart';

import 'create_group_logic.dart';

class CreateGroupPage extends StatelessWidget {
  final logic = Get.find<CreateGroupLogic>();

  CreateGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: GradientScaffold(
        title: StrRes.createGroup,
        subtitle: StrRes.createGroupHint,
        showBackButton: true,
        trailing: CustomButton(
          onTap: logic.completeCreation,
          icon: CupertinoIcons.checkmark,
          color: Colors.white,
          padding: EdgeInsets.all(10.w),
        ),
        scrollable: true,
        bodyColor: const Color(0xFFF4F5F9),
        body: AnimationLimiter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 450),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                curve: Curves.easeOutQuart,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                SectionTitle(title: StrRes.groupInformation),
                _buildGroupBaseInfoView(),
                18.verticalSpace,
                SectionTitle(title: StrRes.groupMembers),
                _buildGroupMemberView(),
                24.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupBaseInfoView() => Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9CA3AF).withOpacity(0.06),
              offset: const Offset(0, 2),
              blurRadius: 6.r,
            ),
          ],
          border: Border.all(
            color: const Color(0xFFF3F4F6),
            width: 1,
          ),
        ),
        child: Obx(() => Row(
              children: [
                if (logic.faceURL.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9CA3AF).withOpacity(0.06),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: AvatarView(
                      width: 56.w,
                      height: 56.h,
                      url: logic.faceURL.value,
                      onTap: logic.selectAvatar,
                      isCircle: true,
                    ),
                  )
                else
                  Container(
                    width: 56.w,
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                      onTap: logic.selectAvatar,
                      borderRadius: BorderRadius.circular(56.r),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: AppColor.iconColor,
                        size: 20.w,
                      ),
                    ),
                  ),
                16.horizontalSpace,
                Flexible(
                  child: TextField(
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 17.sp,
                      color: const Color(0xFF1F2937),
                      fontWeight: FontWeight.w500,
                    ),
                    autofocus: true,
                    controller: logic.nameCtrl,
                    inputFormatters: [LengthLimitingTextInputFormatter(16)],
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        color: const Color(0xFF6B7280),
                      ),
                      hintText: StrRes.plsEnterGroupNameHint,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            )),
      );

  Widget _buildGroupMemberView() => Obx(() => Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9CA3AF).withOpacity(0.06),
              offset: const Offset(0, 2),
              blurRadius: 6.r,
            ),
          ],
          border: Border.all(
            color: const Color(0xFFF3F4F6),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      sprintf(StrRes.nPerson, [logic.allList.length]),
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logic.allList.length,
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 68.w / 84.h,
              ),
              itemBuilder: (BuildContext context, int index) {
                final info = logic.allList[index];
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9CA3AF).withOpacity(0.04),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: AvatarView(
                        width: 48.w,
                        height: 48.h,
                        url: info.faceURL,
                        text: info.nickname,
                        textStyle: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 14.sp,
                          color: Colors.white,
                        ),
                        isCircle: true,
                        isGroup: false,
                      ),
                    ),
                    2.verticalSpace,
                    Text(
                      info.nickname ?? '',
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 12.sp,
                        color: const Color(0xFF4B5563),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),
            12.verticalSpace,
          ],
        ),
      ));
}
