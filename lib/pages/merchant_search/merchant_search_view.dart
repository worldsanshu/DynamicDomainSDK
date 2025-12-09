// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/pages/merchantList/merchant_list_logic.dart';
import 'package:openim/pages/merchant_search/merchant_serarch_logic.dart';
import 'package:openim/widgets/merchant_item.dart';
import 'package:openim_common/openim_common.dart';
import '../../widgets/base_page.dart';

class MerchantSearchPage extends StatelessWidget {
  MerchantSearchPage({super.key});

  final logic = Get.find<MerchantSearchLogic>();
  final merchantListLogic = Get.find<MerchantListLogic>();
  final merchantLogic = Get.find<MerchantController>();

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      title: StrRes.searchCompany,
      centerTitle: false,
      showLeading: true,
      customAppBar: WechatStyleSearchBox(
        controller: logic.merchantCodeCtrl,
        focusNode: logic.focusNode,
        hintText: StrRes.search,
        enabled: true,
        autofocus: true,
        onSubmitted: logic.searchMerchantInfo,
        onCleared: () => logic.focusNode.requestFocus(),
        margin: EdgeInsets.zero,
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      body: TouchCloseSoftKeyboard(
        isGradientBg: false,
        child: Column(
          children: [
            Obx(() {
              final text = logic.inputText.value;
              if (!logic.tipShow.value) return const SizedBox.shrink();

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
                child: Material(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  elevation: 4,
                  shadowColor: Colors.black26,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => logic.searchMerchantInfo(text),
                    splashColor: Styles.c_0089FF.withOpacity(0.1),
                    highlightColor: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 12.h, horizontal: 16.w),
                      child: Row(
                        children: [
                          Container(
                            width: 36.w,
                            height: 36.h,
                            decoration: BoxDecoration(
                              color: Styles.c_0089FF,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.search,
                                color: Colors.white, size: 20.sp),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              StrRes.searchFor.replaceFirst('%s', text),
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                color: Colors.grey[800],
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            Expanded(child: Obx(
              () {
                return logic.isSearchNotResult
                    ? _buildEmptyListView()
                    : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: logic.merchantList.length,
                        itemBuilder: (context, index) {
                          final merchant = logic.merchantList[index];
                          bool isExists = merchantListLogic.isExists(merchant);
                          return MerchantItemCupertino(
                            merchant: merchant,
                            btnStr: StrRes.bind,
                            isDefault: merchant.id == logic.defaultMerchantID,
                            onBtnTap:
                                isExists ? null : () => logic.onBind(merchant),
                          );
                        },
                      );
              },
            ))
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyListView() => SizedBox(
        width: 1.sw,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            44.verticalSpace,
            StrRes.searchNotFound.toText..style = Styles.ts_8E9AB0_17sp,
          ],
        ),
      );
}
