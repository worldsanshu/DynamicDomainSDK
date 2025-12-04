// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:search_keyword_text/search_keyword_text.dart';
import 'package:openim/widgets/base_page.dart';

import 'search_group_member_logic.dart';

class SearchGroupMemberPage extends StatelessWidget {
  final logic = Get.find<SearchGroupMemberLogic>();

  SearchGroupMemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: BasePage(
        showAppBar: true,
        title: StrRes.search,
        centerTitle: false,
        showLeading: true,
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
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
                      child: Row(
                        children: [
                          Icon(
                            Ionicons.search,
                            size: 20.w,
                            color: const Color(0xFF6B7280),
                          ),
                          8.horizontalSpace,
                          Expanded(
                            child: TextField(
                              focusNode: logic.focusNode,
                              controller: logic.searchCtrl,
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: StrRes.search,
                                hintStyle: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              onSubmitted: (_) => logic.search(),
                            ),
                          ),
                          if (logic.searchCtrl.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                logic.searchCtrl.clear();
                                logic.focusNode.requestFocus();
                              },
                              child: Icon(Icons.close,
                                  size: 18.sp, color: Styles.c_8E9AB0),
                            ),
                        ],
                      ),
                    ),
                  ),
                  8.horizontalSpace,
                  TextButton(
                    onPressed: () => Get.back(),
                    style: ButtonStyle(
                      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 12.h)),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.sp),
                        ),
                      ),
                      side: const WidgetStatePropertyAll(
                          BorderSide(color: Color(0xFFE5E7EB))),
                      shadowColor: const WidgetStatePropertyAll(Colors.black),
                      textStyle: WidgetStatePropertyAll(
                        TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 16.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      backgroundColor:
                          const WidgetStatePropertyAll(Color(0xFFF9FAFB)),
                    ),
                    child: Text(StrRes.cancel,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 16.sp,
                          color: const Color(0xFF6B7280),
                        )),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() => logic.isSearchNotResult
                  ? _emptyListView
                  : SmartRefresher(
                      controller: logic.controller,
                      enablePullUp: true,
                      enablePullDown: false,
                      footer: IMViews.buildFooter(),
                      onLoading: logic.load,
                      child: ListView.builder(
                        itemCount: logic.memberList.length,
                        itemBuilder: (_, index) {
                          final info = logic.memberList.elementAt(index);
                          if (logic.hiddenMembers(info)) {
                            return const SizedBox();
                          } else {
                            return _buildItemView(info);
                          }
                        },
                      ),
                    )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemView(GroupMembersInfo membersInfo) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => logic.clickMember(membersInfo),
        child: Container(
          height: 64.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          color: Styles.c_FFFFFF,
          child: Row(
            children: [
              // if (logic.isMultiSelMode)
              //   Padding(
              //     padding: EdgeInsets.only(right: 15.w),
              //     child: ChatRadio(checked: logic.isChecked(membersInfo)),
              //   ),
              AvatarView(
                url: membersInfo.faceURL,
                text: membersInfo.nickname,
              ),
              10.horizontalSpace,
              Expanded(
                // child: (membersInfo.nickname ?? '').toText
                //   ..style = Styles.ts_0C1C33_17sp
                //   ..maxLines = 1
                //   ..overflow = TextOverflow.ellipsis,
                child: SearchKeywordText(
                  text: membersInfo.nickname ?? '',
                  keyText: RegExp.escape(logic.searchCtrl.text.trim()),
                  style: Styles.ts_0C1C33_17sp,
                  keyStyle: Styles.ts_0089FF_17sp,
                ),
              ),
              if (membersInfo.roleLevel == GroupRoleLevel.owner)
                StrRes.groupOwner.toText..style = Styles.ts_8E9AB0_17sp,
              if (membersInfo.roleLevel == GroupRoleLevel.admin)
                StrRes.groupAdmin.toText..style = Styles.ts_8E9AB0_17sp,
            ],
          ),
        ),
      );

  Widget get _emptyListView => SizedBox(
        width: 1.sw,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 157.verticalSpace,
            // ImageRes.blacklistEmpty.toImage
            //   ..width = 120.w
            //   ..height = 120.h,
            // 22.verticalSpace,
            44.verticalSpace,
            StrRes.searchNotFound.toText..style = Styles.ts_8E9AB0_17sp,
          ],
        ),
      );
}
