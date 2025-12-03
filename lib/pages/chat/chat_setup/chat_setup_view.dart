import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hugeicons/hugeicons.dart';

import 'chat_setup_logic.dart';
import '../../../widgets/base_page.dart';

class ChatSetupPage extends StatelessWidget {
  final logic = Get.find<ChatSetupLogic>();

  ChatSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      title: StrRes.personalChatSettings,
      centerTitle: false,
      showLeading: true,
      body: Obx(() => Column(
            children: [
              // Content Container
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9CA3AF).withOpacity(0.08),
                        offset: const Offset(0, 0),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: AnimationLimiter(
                    child: SingleChildScrollView(
                      child: Column(
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 400),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            verticalOffset: 40.0,
                            curve: Curves.easeOutCubic,
                            child: FadeInAnimation(
                              curve: Curves.easeOutCubic,
                              child: widget,
                            ),
                          ),
                          children: [
                            18.verticalSpace,

                            // Profile Card
                            _buildProfileCard(),

                            18.verticalSpace,

                            // Content Search Section
                            _buildContentSearchSection(),

                            18.verticalSpace,

                            // Chat Settings Section
                            _buildChatSettingsSection(),

                            18.verticalSpace,

                            // Appearance Section
                            _buildAppearanceSection(),

                            18.verticalSpace,

                            // Actions Section
                            _buildActionsSection(),

                            24.verticalSpace,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF9FAFB),
            Color(0xFFF3F4F6),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.07),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar with border
          GestureDetector(
            onTap: logic.viewUserInfo,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34.r),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9CA3AF).withOpacity(0.1),
                    offset: const Offset(0, 0),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: AvatarView(
                width: 68.w,
                height: 68.h,
                url: logic.conversationInfo.value.faceURL,
                text: logic.conversationInfo.value.showName,
                textStyle: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                isCircle: true,
              ),
            ),
          ),

          16.horizontalSpace,

          // User Info
          Expanded(
            child: GestureDetector(
              onTap: logic.viewUserInfo,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    logic.conversationInfo.value.showName ?? '',
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  6.verticalSpace,
                  Text(
                    '${StrRes.idLabel} ${logic.conversationInfo.value.userID ?? ''}',
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Create Group button
          GestureDetector(
            onTap: logic.createGroup,
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedUserAdd01,
              size: 25.w,
              color: AppColor.iconColor, //const Color(0xFF4F42FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSearchSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.08),
            offset: const Offset(0, 3),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF0F4F8),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Text(
              StrRes.chatContent,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF374151),
                letterSpacing: 0.3,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 0.5),
                    blurRadius: 1,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              bottom: 20.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildContentSearchItem(
                  hugeIcon: HugeIcons.strokeRoundedSearch01,
                  text: StrRes.search,
                  color: const Color(0xFF4F42FF),
                  onTap: logic.searchChatHistory,
                ),
                _buildContentSearchItem(
                  hugeIcon: HugeIcons.strokeRoundedImage02,
                  text: StrRes.picture,
                  color: const Color(0xFF34D399),
                  onTap: logic.searchChatHistoryPicture,
                ),
                _buildContentSearchItem(
                  hugeIcon: HugeIcons.strokeRoundedVideoReplay,
                  text: StrRes.video,
                  color: const Color(0xFFF87171),
                  onTap: logic.searchChatHistoryVideo,
                ),
                _buildContentSearchItem(
                  hugeIcon: HugeIcons.strokeRoundedFile02,
                  text: StrRes.file,
                  color: const Color(0xFFFBBF24),
                  onTap: logic.searchChatHistoryFile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSearchItem({
    required List<List<dynamic>> hugeIcon,
    required String text,
    required Color color,
    Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.08),
                  offset: const Offset(0, 3),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.95),
                  offset: const Offset(0, -1),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(
                color: const Color(0xFFF3F4F6),
                width: 0.5,
              ),
            ),
            child: Container(
              margin: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    // color.withOpacity(0.12),
                    // color.withOpacity(0.05),
                    AppColor.iconColor.withOpacity(0.12),
                    AppColor.iconColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Center(
                child: HugeIcon(
                  icon: hugeIcon,
                  size: 24.w,
                  color: AppColor.iconColor, //color,
                ),
              ),
            ),
          ),
          8.verticalSpace,
          Text(
            text,
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
              shadows: [
                Shadow(
                  offset: const Offset(0, 0.5),
                  blurRadius: 1,
                  color: Colors.white.withOpacity(0.8),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatSettingsSection() {
    return _buildMenuSection(
      title: StrRes.chatSettings,
      items: [
        _buildMenuItem(
          hugeIcon: HugeIcons.strokeRoundedPin,
          text: StrRes.topContacts,
          color: const Color(0xFFFB923C),
          switchOn: logic.isPinned,
          onChanged: (_) => logic.toggleTopContacts(),
        ),
        _buildMenuItem(
          hugeIcon: HugeIcons.strokeRoundedNotificationOff02,
          text: StrRes.messageNotDisturb,
          color: const Color(0xFFA78BFA),
          switchOn: logic.isNotDisturb,
          onChanged: (_) => logic.toggleNotDisturb(),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return _buildMenuSection(
      title: StrRes.appearance,
      items: [
        _buildMenuItem(
          hugeIcon: HugeIcons.strokeRoundedImage02,
          text: StrRes.setChatBackground,
          color: const Color(0xFF2DD4BF),
          onTap: logic.setBackgroundImage,
        ),
        _buildMenuItem(
          hugeIcon: HugeIcons.strokeRoundedTextFont,
          text: StrRes.fontSize,
          color: const Color(0xFFA78BFA),
          onTap: logic.setFontSize,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return _buildMenuSection(
      title: StrRes.actions,
      items: [
        _buildMenuItem(
          hugeIcon: HugeIcons.strokeRoundedFlag01,
          text: StrRes.report,
          color: const Color(0xFF34D399),
          onTap: logic.startReport,
        ),
        _buildMenuItem(
          hugeIcon: HugeIcons.strokeRoundedDelete02,
          text: StrRes.clearChatHistory,
          color: const Color(0xFFF87171),
          textStyle: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFF87171),
          ),
          onTap: logic.clearChatHistory,
          hideArrow: true,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF374151),
              letterSpacing: 0.3,
              shadows: [
                Shadow(
                  offset: const Offset(0, 0.5),
                  blurRadius: 1,
                  color: Colors.white.withOpacity(0.8),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9CA3AF).withOpacity(0.08),
                offset: const Offset(0, 3),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: const Color(0xFFF0F4F8),
              width: 1,
            ),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required List<List<dynamic>> hugeIcon,
    required String text,
    required Color color,
    String? value,
    TextStyle? textStyle,
    bool switchOn = false,
    bool hideArrow = false,
    bool isLast = false,
    ValueChanged<bool>? onChanged,
    Function()? onTap,
  }) {
    final bool isWarning = color == const Color(0xFFF87171);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  HugeIcon(
                    icon: hugeIcon,
                    size: 20.w,
                    color: AppColor.iconColor, //color,
                  ),
                  16.horizontalSpace,
                  Expanded(
                    child: Text(
                      text,
                      style: textStyle ??
                          TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: isWarning
                                ? const Color(0xFFF87171)
                                : const Color(0xFF374151),
                          ),
                    ),
                  ),

                  // Value text
                  if (value != null) ...[
                    8.horizontalSpace,
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 150.w),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],

                  // Switch
                  if (onChanged != null) ...[
                    8.horizontalSpace,
                    CupertinoSwitch(
                      value: switchOn,
                      activeColor: const Color(0xFF4F42FF),
                      trackColor: const Color(0xFFE5E7EB),
                      thumbColor: Colors.white,
                      onChanged: onChanged,
                    ),
                  ],

                  // Arrow - only show if no switch and not hideArrow
                  if (!hideArrow && onChanged == null) ...[
                    8.horizontalSpace,
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      size: 16.w,
                      color: const Color(0xFF6B7280),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        // Divider
        if (!isLast)
          Padding(
            padding: EdgeInsets.only(left: 52.w),
            child: const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF3F4F6),
            ),
          ),
      ],
    );
  }
}
