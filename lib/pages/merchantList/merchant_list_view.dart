import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:openim/pages/merchantList/merchant_list_logic.dart';
import 'package:openim/widgets/merchant_item.dart';
import 'package:openim_common/openim_common.dart';
import '../../widgets/gradient_scaffold.dart';
import '../auth/widget/app_text_form_field.dart';

class MerchantListView extends StatelessWidget {
  MerchantListView({super.key});

  final logic = Get.find<MerchantListLogic>();
  final merchantLogic = Get.find<MerchantController>();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return GradientScaffold(
      title: StrRes.myCompany,
      showBackButton: true,
      bodyColor: const Color(0xFFF9FAFB),
      searchBox: AppTextFormField(
        controller: logic.searchController,
        hint: StrRes.searchCompanyCode,
        prefixIcon: Icon(
          CupertinoIcons.search,
          size: 22.w,
          color: const Color(0xFF9CA3AF),
        ),
        suffixIcon: Obx(() {
          if (logic.searchQuery.value.isEmpty) {
            return const SizedBox.shrink();
          }
          return IconButton(
            icon: Icon(
              CupertinoIcons.clear_circled_solid,
              size: 16.w,
              color: const Color(0xFF9CA3AF),
            ),
            onPressed: logic.clearSearch,
          );
        }),
        onChanged: logic.onSearchChanged,
        validator: (_) => null,
      ),
      body: Obx(() {
        final filteredList = logic.filteredMerchantList;

        if (logic.noData.isTrue) {
          return _buildEmptyState(primaryColor, isSearchEmpty: false);
        }

        if (filteredList.isEmpty && logic.searchQuery.value.isNotEmpty) {
          return _buildEmptyState(primaryColor, isSearchEmpty: true);
        }

        return AnimationLimiter(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 30.h),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final merchant = filteredList[index];
              final isCurrent = merchant.id == merchantLogic.currentMerchantID;
              final isSearchedMerchant =
                  logic.searchedMerchant.value?.id == merchant.id;
              final isAlreadyBound = logic.isExists(merchant);

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
                            color: const Color(0xFF000000).withOpacity(0.03),
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
                          isDefault: merchant.id == logic.defaultMerchantID,
                          btnStr: isSearchedMerchant && !isAlreadyBound
                              ? StrRes.bindNow
                              : isCurrent
                                  ? StrRes.refresh
                                  : logic.fromLogin.value
                                      ? StrRes.enterText
                                      : StrRes.switchText,
                          onBtnTap: isSearchedMerchant && !isAlreadyBound
                              ? () {
                                  print(
                                      '===BIND=== Button tapped! isSearchedMerchant=$isSearchedMerchant, isAlreadyBound=$isAlreadyBound');
                                  logic.onBind(merchant);
                                }
                              : isCurrent
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
    );
  }

  Widget _buildEmptyState(Color primaryColor, {required bool isSearchEmpty}) {
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
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      isSearchEmpty
                          ? CupertinoIcons.search
                          : CupertinoIcons.building_2_fill,
                      size: 32.w,
                      color: primaryColor,
                    ),
                  ),
                  20.verticalSpace,
                  Text(
                    isSearchEmpty
                        ? StrRes.searchNotResult
                        : StrRes.noCompanyBound,
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  8.verticalSpace,
                  Text(
                    isSearchEmpty
                        ? StrRes.tryAnother
                        : StrRes.noCompanyBoundHint,
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  if (!isSearchEmpty) ...[
                    24.verticalSpace,
                    _buildPrimaryButton(
                      onTap: () => logic.startMerchantSearch(),
                      label: StrRes.bindNow,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onTap,
    required String label,
  }) {
    final primaryColor = Theme.of(Get.context!).primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
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
