// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim/pages/chat/group_setup/group_setup_logic.dart';
import 'package:openim_common/openim_common.dart';

import '../../../../routes/app_navigator.dart';
import '../group_member_list/group_member_list_logic.dart';

class GroupManageLogic extends GetxController {
  final groupSetupLogic = Get.find<GroupSetupLogic>();

  Rx<GroupInfo> get groupInfo => groupSetupLogic.groupInfo;

  bool get allowLookProfiles => groupInfo.value.lookMemberInfo == 1;

  bool get allowAddFriend => groupInfo.value.applyMemberFriend == 1;

  bool get isOwner => groupSetupLogic.isOwner;

  void toggleGroupMute() {
    LoadingView.singleton.wrap(asyncFunction: () async {
      await OpenIM.iMManager.groupManager.changeGroupMute(
        groupID: groupInfo.value.groupID,
        mute: !(groupInfo.value.status == 3),
      );
    });
  }

  /// 不允许通过群获取成员资料 0：关闭，1：打开
  void toggleMemberProfiles() async {
    await LoadingView.singleton.wrap(
      // ignore: deprecated_member_use
      asyncFunction: () => OpenIM.iMManager.groupManager.setGroupLookMemberInfo(
        groupID: groupInfo.value.groupID,
        status: !allowLookProfiles ? 1 : 0,
      ),
    );
  }

  /// 0：关闭，1：打开
  void toggleAddMemberToFriend() async {
    await LoadingView.singleton.wrap(
      asyncFunction: () =>
          // ignore: deprecated_member_use
          OpenIM.iMManager.groupManager.setGroupApplyMemberFriend(
        groupID: groupInfo.value.groupID,
        status: !allowAddFriend ? 1 : 0,
      ),
    );
  }

  void modifyJoinGroupSet() async {
    final index = await Get.bottomSheet(
      barrierColor: Colors.transparent,
      Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32.r),
                topRight: Radius.circular(32.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.08),
                  offset: const Offset(0, -3),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: BoxConstraints(maxHeight: 400.h),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32.r),
                      topRight: Radius.circular(32.r),
                    ),
                    child: const _JoinGroupSettingView(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    if (null != index) {
      final value = index == 0
          ? GroupVerification.directly
          : (index == 1
              ? GroupVerification.applyNeedVerificationInviteDirectly
              : GroupVerification.allNeedVerification);
      await LoadingView.singleton.wrap(
        asyncFunction: () => OpenIM.iMManager.groupManager.setGroupVerification(
          groupID: groupInfo.value.groupID,
          needVerification: value,
        ),
      );
      groupInfo.update((val) {
        val?.needVerification = value;
      });
    }
  }

  String get joinGroupOption {
    final value = groupInfo.value.needVerification;
    if (value == GroupVerification.allNeedVerification) {
      return StrRes.needVerification;
    } else if (value == GroupVerification.directly) {
      return StrRes.allowAnyoneJoinGroup;
    }
    return StrRes.inviteNotVerification;
  }

  void transferGroupOwnerRight() async {
    var result = await AppNavigator.startGroupMemberList(
      groupInfo: groupInfo.value,
      opType: GroupMemberOpType.transferRight,
      isShowEveryone: false,
    );
    if (result is GroupMembersInfo) {
      await LoadingView.singleton.wrap(
        asyncFunction: () => OpenIM.iMManager.groupManager.transferGroupOwner(
          groupID: groupInfo.value.groupID,
          userID: result.userID!,
        ),
      );
      groupInfo.update((val) {
        val?.ownerUserID = result.userID;
      });
      Get.back();
    }
  }
}

class _JoinGroupSettingView extends StatelessWidget {
  const _JoinGroupSettingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFF3F4F6),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  StrRes.joinGroupSet,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF374151),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Options
          Container(
            padding: EdgeInsets.symmetric(vertical: 0.h),
            child: Column(
              children: [
                _buildOptionItem(
                  icon: HugeIcons.strokeRoundedUserAdd01,
                  title: StrRes.allowAnyoneJoinGroup,
                  subtitle: StrRes.anyoneCanJoinWithoutApproval,
                  onTap: () => Get.back(result: 0),
                ),
                _buildOptionItem(
                  icon: HugeIcons.strokeRoundedUserCheck01,
                  title: StrRes.inviteNotVerification,
                  subtitle: StrRes.membersCanInviteAdminApprovalRequired,
                  onTap: () => Get.back(result: 1),
                ),
                _buildOptionItem(
                  icon: HugeIcons.strokeRoundedUserLock01,
                  title: StrRes.needVerification,
                  subtitle: StrRes.allRequestsRequireAdminApproval,
                  onTap: () => Get.back(result: 2),
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required List<List<dynamic>> icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isLast ? Colors.transparent : const Color(0xFFF3F4F6),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Icon
              HugeIcon(
                icon: icon,
                size: 20.w,
                color: AppColor.iconColor,
              ),

              16.horizontalSpace,

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    4.verticalSpace,
                    Text(
                      subtitle,
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

              8.horizontalSpace,

              // Arrow
              const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 16,
                color: Color(0xFF6B7280),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
