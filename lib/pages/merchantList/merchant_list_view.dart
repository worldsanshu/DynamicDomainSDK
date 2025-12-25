import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:openim/pages/merchantList/merchant_list_logic.dart';
import 'package:openim/widgets/merchant_item.dart';
import 'package:openim/widgets/empty_view.dart';
import 'package:openim_common/openim_common.dart';
import '../../widgets/gradient_scaffold.dart';

class MerchantListView extends StatelessWidget {
  MerchantListView({super.key});

  final logic = Get.find<MerchantListLogic>();
  final merchantLogic = Get.find<MerchantController>();

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: StrRes.myCompany,
      showBackButton: true,
      bodyColor: const Color(0xFFF9FAFB),
      searchBox: WechatStyleSearchBox(
        enabled: true,
        controller: logic.searchController,
        hintText: StrRes.searchCompanyCode,
        onSubmitted: (_) {},
        onCleared: logic.clearSearch,
      ),
      body: Obx(() {
        final filteredList = logic.filteredMerchantList;

        if (logic.noData.isTrue ||
            (filteredList.isEmpty && logic.searchQuery.value.isNotEmpty)) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: 100.h),
              child: EmptyView(
                message: StrRes.searchNotResult,
                icon: Ionicons.search_outline,
              ),
            ),
          );
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
}
