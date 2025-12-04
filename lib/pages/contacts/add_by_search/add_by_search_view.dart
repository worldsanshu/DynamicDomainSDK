// ignore_for_file: unused_element, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import '../../../widgets/custom_buttom.dart';
import 'add_by_search_logic.dart';
import '../../../widgets/base_page.dart';

class AddContactsBySearchPage extends StatelessWidget {
  final logic = Get.find<AddContactsBySearchLogic>();

  AddContactsBySearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      centerTitle: false,
      showLeading: true,
      customAppBar: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            logic.isSearchUser ? StrRes.addFriend : StrRes.addGroup,
            style: const TextStyle(
              fontFamily: 'FilsonPro',
              fontWeight: FontWeight.w500,
              fontSize: 23,
              color: Colors.black,
            ).copyWith(fontSize: 23.sp),
          ),
          Text(
            logic.isSearchUser
                ? StrRes.searchAddFriends
                : StrRes.searchJoinGroups,
            style: const TextStyle(
              fontFamily: 'FilsonPro',
              fontWeight: FontWeight.w400,
              color: Color(0xFFBDBDBD),
            ).copyWith(fontSize: 12.sp),
          ),
        ],
      ),
      actions: [
        if (logic.isSearchUser)
          CustomButtom(
            margin: const EdgeInsets.only(right: 10),
            onPressed: AppNavigator.startScan,
            icon: CupertinoIcons.qrcode_viewfinder,
            colorButton: const Color(0xFF10B981).withOpacity(0.1),
            colorIcon: const Color(0xFF10B981),
          ),
      ],
      body: _buildContentContainer(),
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
      child: Obx(() {
        // Check if there are search results
        bool hasSearchResults = logic.isSearchUser
            ? logic.userInfoList.isNotEmpty
            : logic.groupInfoList.isNotEmpty;
        bool isSearching = logic.searchCtrl.text.trim().isNotEmpty;

        return SingleChildScrollView(
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
                  _buildSearchSection(),
                  if (isSearching && hasSearchResults) ...[
                    18.verticalSpace,
                    _buildResultsSection(),
                  ],
                  if (isSearching && !hasSearchResults) ...[
                    18.verticalSpace,
                    _buildNotFoundView(),
                  ],
                  24.verticalSpace,
                ],
              ),
            ),
          ),
        );
      }),
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

  Widget _buildSearchSection() {
    return Container(
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
      child: TextField(
        focusNode: logic.focusNode,
        controller: logic.searchCtrl,
        onSubmitted: (_) => logic.search(),
        style: TextStyle(
          fontFamily: 'FilsonPro',
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF374151),
        ),
        decoration: InputDecoration(
          hintText: logic.isSearchUser
              ? StrRes.searchByPhoneAndUid
              : StrRes.searchIDAddGroup,
          hintStyle: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
          ),
          prefixIcon: Container(
            width: 20.w,
            height: 20.h,
            margin: EdgeInsets.all(8.w),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color: AppColor.iconColor,
              size: 20.w,
            ),
          ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        ),
      ),
    );
  }

  Widget _buildScanSection() {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: AppNavigator.startScan,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedQrCode01,
                  color: AppColor.iconColor,
                  size: 20.w,
                ),
                16.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        StrRes.scan,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      4.verticalSpace,
                      Text(
                        StrRes.scanHint,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  size: 20.w,
                  color: AppColor.iconColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Container(
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
      child: logic.isSearchUser ? _buildUserResults() : _buildGroupResults(),
    );
  }

  Widget _buildUserResults() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logic.userInfoList.length,
      itemBuilder: (_, index) {
        final userInfo = logic.userInfoList.elementAt(index);
        return _buildResultItem(userInfo, index, logic.userInfoList.length);
      },
    );
  }

  Widget _buildGroupResults() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logic.groupInfoList.length,
      itemBuilder: (_, index) {
        final groupInfo = logic.groupInfoList.elementAt(index);
        return _buildResultItem(groupInfo, index, logic.groupInfoList.length);
      },
    );
  }

  Widget _buildResultItem(dynamic info, int index, int totalItems) {
    final bool isLastItem = index == totalItems - 1;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => logic.viewInfo(info),
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  AvatarView(
                    url: logic.isSearchUser ? info.faceURL : info.faceURL,
                    text: logic.isSearchUser ? info.nickname : info.groupName,
                    width: 40.w,
                    height: 40.h,
                    textStyle: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    isCircle: true,
                  ),
                  16.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          logic.getShowTitle(info),
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (logic.isSearchUser && info.userID != null) ...[
                          4.verticalSpace,
                          Text(
                            '${StrRes.idLabel} ${info.userID}',
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    size: 20.w,
                    color: AppColor.iconColor,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLastItem)
          Padding(
            padding: EdgeInsets.only(left: 72.w),
            child: const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF3F4F6),
            ),
          ),
      ],
    );
  }

  Widget _buildNotFoundView() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68.w,
              height: 68.h,
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: HugeIcon(
                icon: logic.isSearchUser
                    ? HugeIcons.strokeRoundedUserRemove01
                    : HugeIcons.strokeRoundedUserGroup,
                color: AppColor.iconColor,
                size: 20.w,
              ),
            ),
            16.verticalSpace,
            Text(
              logic.isSearchUser ? StrRes.noFoundUser : StrRes.noFoundGroup,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
