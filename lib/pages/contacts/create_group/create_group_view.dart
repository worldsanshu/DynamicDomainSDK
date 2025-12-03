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

import 'create_group_logic.dart';
import 'package:openim/widgets/base_page.dart';

class CreateGroupPage extends StatelessWidget {
  final logic = Get.find<CreateGroupLogic>();

  CreateGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
   final theme = Theme.of(context);
    return TouchCloseSoftKeyboard(
      child: BasePage(
        showAppBar: true,
        showLeading: true,
        centerTitle: false,
        customAppBar: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StrRes.createGroup,
              style: const TextStyle(
                fontFamily: 'FilsonPro',
                fontWeight: FontWeight.w500,
                fontSize: 23,
                color: Colors.black,
              ).copyWith(fontSize: 23.sp),
            ),
            Text(
              StrRes.createGroupHint,
              style: const TextStyle(
                fontFamily: 'FilsonPro',
                fontWeight: FontWeight.w400,
                color: Color(0xFFBDBDBD),
              ).copyWith(fontSize: 12.sp),
            ),
          ],
        ),
        actions: [
          CustomButtom(
            margin: const EdgeInsets.only(right: 10),
            onPressed: logic.completeCreation,
            icon: CupertinoIcons.checkmark,
            colorButton: theme.primaryColor.withOpacity(0.1),
            colorIcon: theme.primaryColor,
          ),
        ],
        body: _buildContentContainer(),
      ),
    );
  }

  Widget _buildContentContainer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 20.h),
        child: AnimationLimiter(
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
                20.verticalSpace,
                _buildSectionTitle(StrRes.groupInformation),
                _buildGroupBaseInfoView(),
                18.verticalSpace,
                _buildSectionTitle(StrRes.groupMembers),
                _buildGroupMemberView(),
                24.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'FilsonPro',
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF212121),
          shadows: [
            Shadow(
              color: Colors.white.withOpacity(0.9),
              offset: const Offset(0.5, 0.5),
              blurRadius: 0.5,
            ),
          ],
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
                      borderRadius: BorderRadius.circular(12.r),
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
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  )
                else
                  Container(
                    width: 56.w,
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: InkWell(
                      onTap: logic.selectAvatar,
                      borderRadius: BorderRadius.circular(12.r),
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
                  Text(
                    StrRes.groupMember,
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151),
                    ),
                  ),
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
                        borderRadius: BorderRadius.circular(12.r),
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
                        borderRadius: BorderRadius.circular(12.r),
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
