import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../../widgets/custom_buttom.dart';
import 'chat_setup_logic.dart';

class ChatSetupPage extends StatelessWidget {
  final logic = Get.find<ChatSetupLogic>();

  ChatSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // 1. Header Background
            Container(
              height: 180.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withOpacity(0.7),
                    primaryColor,
                    primaryColor.withOpacity(0.9),
                  ],
                ),
              ),
            ),

            // 2. Main Content Card
            Container(
              margin: EdgeInsets.only(top: 120.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Obx(() => Column(
                    children: [
                      SizedBox(height: 60.h), // Space for avatar

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
                            _buildActionButtonWithCustomButtom(
                              context: context,
                              icon: CupertinoIcons.search,
                              label: StrRes.search,
                              onTap: logic.searchChatHistory,
                            ),
                            _buildActionButtonWithCustomButtom(
                              context: context,
                              icon: CupertinoIcons.photo,
                              label: StrRes.picture,
                              onTap: logic.searchChatHistoryPicture,
                            ),
                            _buildActionButtonWithCustomButtom(
                              context: context,
                              icon: CupertinoIcons.video_camera,
                              label: StrRes.video,
                              onTap: logic.searchChatHistoryVideo,
                            ),
                            _buildActionButtonWithCustomButtom(
                              context: context,
                              icon: CupertinoIcons.doc,
                              label: StrRes.file,
                              onTap: logic.searchChatHistoryFile,
                            ),
                          ],
                        ),
                      ),

                      24.verticalSpace,
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),

                      // Menu Sections
                      _buildSectionTitle(StrRes.chatSettings),
                      _buildToggleMenuItem(
                        label: StrRes.topContacts,
                        isOn: logic.isPinned,
                        onChanged: (_) => logic.toggleTopContacts(),
                      ),
                      _buildToggleMenuItem(
                        label: StrRes.messageNotDisturb,
                        isOn: logic.isNotDisturb,
                        onChanged: (_) => logic.toggleNotDisturb(),
                      ),

                      _buildSectionTitle(StrRes.appearance),
                      _buildMenuItem(
                        icon: CupertinoIcons.photo,
                        label: StrRes.setChatBackground,
                        onTap: logic.setBackgroundImage,
                      ),
                      _buildMenuItem(
                        icon: CupertinoIcons.textformat,
                        label: StrRes.fontSize,
                        onTap: logic.setFontSize,
                      ),

                      _buildSectionTitle(StrRes.actions),
                      _buildMenuItem(
                        icon: CupertinoIcons.person_2,
                        label: StrRes.createGroup,
                        onTap: logic.createGroup,
                      ),
                      _buildMenuItem(
                        icon: CupertinoIcons.flag,
                        label: StrRes.report,
                        onTap: logic.startReport,
                        textColor: Colors.amber,
                      ),
                      _buildMenuItem(
                        icon: CupertinoIcons.delete,
                        label: StrRes.clearChatHistory,
                        onTap: logic.clearChatHistory,
                        textColor: const Color(0xFFF87171),
                      ),

                      40.verticalSpace,
                    ],
                  )),
            ),

            // 3. Avatar (Overlapping)
            Positioned(
              top: 70.h,
              child: Obx(() => GestureDetector(
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
                        textStyle:
                            TextStyle(fontSize: 32.sp, color: Colors.white),
                        isCircle: true,
                        enabledPreview: true,
                      ),
                    ),
                  )),
            ),

            // 4. Custom AppBar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonWithCustomButtom({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      children: [
        CustomButtom(
          onPressed: onTap,
          icon: icon,
          colorButton: primaryColor.withOpacity(0.15),
          colorIcon: primaryColor,
          padding: EdgeInsets.all(16.w),
        ),
        8.verticalSpace,
        Text(
          label,
          style: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 24.w, top: 24.h, bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'FilsonPro',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20.w,
                color: textColor ?? const Color(0xFF1F2937),
              ),
              12.horizontalSpace,
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? const Color(0xFF1F2937),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.w,
              color: const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleMenuItem({
    required String label,
    required bool isOn,
    required ValueChanged<bool> onChanged,
  }) =>
      InkWell(
        onTap: () => onChanged(!isOn),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              _buildToggleSwitch(isOn: isOn, onChanged: onChanged),
            ],
          ),
        ),
      );

  Widget _buildToggleSwitch({
    required bool isOn,
    required ValueChanged<bool> onChanged,
  }) =>
      GestureDetector(
        onTap: () => onChanged(!isOn),
        child: Container(
          width: 52.w,
          height: 30.h,
          decoration: BoxDecoration(
            color: isOn ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF64748B).withOpacity(0.1),
                offset: const Offset(0, 2),
                blurRadius: 6,
                spreadRadius: 0,
              ),
            ],
          ),
          child: AnimatedAlign(
            alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Container(
              width: 26.w,
              height: 26.h,
              margin: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF64748B).withOpacity(0.15),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}