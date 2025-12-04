// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:openim/pages/merchantList/merchant_list_logic.dart';
import 'package:openim/widgets/merchant_item.dart';
import 'package:openim_common/openim_common.dart';
import '../../widgets/base_page.dart';

class MerchantListView extends StatelessWidget {
  MerchantListView({super.key});

  final logic = Get.find<MerchantListLogic>();
  final merchantLogic = Get.find<MerchantController>();

  @override
  Widget build(BuildContext context) {
    final merchantList = logic.merchantList;
    return BasePage(
      showAppBar: true,
      title: StrRes.myCompany,
      centerTitle: false,
      showLeading: true,
      body: Column(
        children: [
          // Search Box Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: Colors.white,
            child: GestureDetector(
              onTap: logic.startMerchantSearch,
              behavior: HitTestBehavior.translucent,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.search,
                      color: const Color(0xFF6B7280),
                      size: 18.w,
                    ),
                    12.horizontalSpace,
                    Text(
                      StrRes.searchCompanyCode,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content Container
          Expanded(
            child: Container(
              color: const Color(0xFFF9FAFB),
              child: Obx(() {
                if (logic.noData.isTrue) {
                  return AnimationConfiguration.staggeredList(
                    position: 0,
                    duration: const Duration(milliseconds: 350),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      curve: Curves.easeOutQuart,
                      child: FadeInAnimation(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 72.w,
                                  height: 72.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4F42FF)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.building_2_fill,
                                    size: 32.w,
                                    color: const Color(0xFF4F42FF),
                                  ),
                                ),
                                20.verticalSpace,
                                Text(
                                  StrRes.noCompanyBound,
                                  style: TextStyle(
                                    fontFamily: 'FilsonPro',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                                8.verticalSpace,
                                Text(
                                  StrRes.noCompanyBoundHint,
                                  style: TextStyle(
                                    fontFamily: 'FilsonPro',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                                24.verticalSpace,
                                _buildPrimaryButton(
                                  onTap: logic.startMerchantSearch,
                                  label: StrRes.bindNow,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return AnimationLimiter(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: merchantList.length,
                    itemBuilder: (context, index) {
                      final merchant = merchantList[index];
                      final isCurrent =
                          merchant.id == merchantLogic.currentMerchantID;
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 350),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          curve: Curves.easeOutQuart,
                          child: FadeInAnimation(
                            child: Container(
                              margin: EdgeInsets.only(bottom: 16.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF000000)
                                        .withOpacity(0.03),
                                    offset: const Offset(0, 1),
                                    blurRadius: 3,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.r),
                                child: MerchantItemCupertino(
                                  merchant: merchant,
                                  isCurrent: isCurrent,
                                  isDefault:
                                      merchant.id == logic.defaultMerchantID,
                                  btnStr: isCurrent
                                      ? StrRes.refresh
                                      : logic.fromLogin.value
                                          ? StrRes.enterText
                                          : StrRes.switchText,
                                  onBtnTap: isCurrent
                                      ? () => logic.onRefresh(merchant)
                                      : () => logic.onSwitch(merchant),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onTap,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF4F42FF),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
