// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../../widgets/custom_buttom.dart';
import '../../../widgets/gradient_scaffold.dart';
import '../../../widgets/settings_menu.dart';
import '../../../widgets/section_title.dart';
import 'chat_setup_logic.dart';

class ChatSetupPage extends StatelessWidget {
  final logic = Get.find<ChatSetupLogic>();

  ChatSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return GradientScaffold(
      title: StrRes.chatSettings,
      showBackButton: true,
      scrollable: false, // Disable full scroll
      avatar: _buildAvatar(),
      body: Obx(() => Column(
            children: [
              // ===== FIXED HEADER SECTION =====
              // User Info
              GestureDetector(
                onTap: logic.viewUserInfo,
                child: Text(
                  logic.conversationInfo.value.showName ?? '',
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              8.verticalSpace,
              GestureDetector(
                onTap: () => IMUtils.copy(
                    text: logic.conversationInfo.value.userID ?? ''),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      logic.conversationInfo.value.userID ?? '',
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    6.horizontalSpace,
                    Icon(
                      CupertinoIcons.doc_on_doc,
                      size: 14.sp,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),

              24.verticalSpace,

              // Action Buttons Row (Search Content)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(
                      icon: CupertinoIcons.search,
                      label: StrRes.search,
                      onTap: logic.searchChatHistory,
                      color: primaryColor,
                    ),
                    CustomButton(
                      icon: CupertinoIcons.photo,
                      label: StrRes.picture,
                      onTap: logic.searchChatHistoryPicture,
                      color: primaryColor,
                    ),
                    CustomButton(
                      icon: CupertinoIcons.video_camera,
                      label: StrRes.video,
                      onTap: logic.searchChatHistoryVideo,
                      color: primaryColor,
                    ),
                    CustomButton(
                      icon: CupertinoIcons.doc,
                      label: StrRes.file,
                      onTap: logic.searchChatHistoryFile,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),

              24.verticalSpace,
              const Divider(height: 1, color: Color(0xFFF3F4F6)),

              // ===== SCROLLABLE SECTION =====
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Menu Sections
                      SectionTitle(title: StrRes.chatSettings),
                      SettingsMenuItem(
                        label: StrRes.topContacts,
                        hasSwitch: true,
                        switchValue: logic.isPinned,
                        onSwitchChanged: (_) => logic.toggleTopContacts(),
                        showArrow: false,
                      ),
                      SettingsMenuItem(
                        label: StrRes.messageNotDisturb,
                        hasSwitch: true,
                        switchValue: logic.isNotDisturb,
                        onSwitchChanged: (_) => logic.toggleNotDisturb(),
                        showArrow: false,
                      ),

                      SectionTitle(title: StrRes.appearance),
                      SettingsMenuItem(
                        icon: CupertinoIcons.photo,
                        label: StrRes.setChatBackground,
                        onTap: logic.setBackgroundImage,
                      ),
                      SettingsMenuItem(
                        icon: CupertinoIcons.textformat,
                        label: StrRes.fontSize,
                        onTap: logic.setFontSize,
                      ),

                      SectionTitle(title: StrRes.actions),
                      SettingsMenuItem(
                        icon: CupertinoIcons.person_2,
                        label: StrRes.createGroup,
                        onTap: logic.createGroup,
                      ),
                      SettingsMenuItem(
                        icon: CupertinoIcons.flag,
                        label: StrRes.report,
                        onTap: logic.startReport,
                        color: Colors.amber,
                      ),
                      SettingsMenuItem(
                        icon: CupertinoIcons.delete,
                        label: StrRes.clearChatHistory,
                        onTap: logic.clearChatHistory,
                        isWarning: true,
                      ),

                      40.verticalSpace,
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildAvatar() {
    return Obx(() => GestureDetector(
          onTap: logic.viewUserInfo,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: AvatarView(
              url: logic.conversationInfo.value.faceURL,
              text: logic.conversationInfo.value.showName,
              width: 100.w,
              height: 100.w,
              textStyle: TextStyle(fontSize: 32.sp, color: Colors.white),
              isCircle: true,
              enabledPreview: false,
            ),
          ),
        ));
  }
}
