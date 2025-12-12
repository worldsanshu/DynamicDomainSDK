// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:openim_common/src/res/styles/app_colors.dart';

class ChatToolBox extends StatelessWidget {
  const ChatToolBox({
    super.key,
    this.onTapAlbum,
    this.onTapCall,
    this.onTapCamera,
    this.onTapCard,
    this.onTapFile,
    this.onTapVoice,
    this.onTapEmoji,
    this.showAudioCall = false,
    this.showVideoCall = false,
    this.height,
  });

  final Function()? onTapAlbum;
  final Function()? onTapCamera;
  final Function()? onTapCall;
  final Function()? onTapFile;
  final Function()? onTapCard;
  final Function()? onTapVoice;
  final Function()? onTapEmoji;
  final bool showAudioCall;
  final bool showVideoCall;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final albumCallback = onTapAlbum;
    final cameraCallback = onTapCamera;
    final fileCallback = onTapFile;
    
    final items = [
      ToolboxItemInfo(
        text: StrRes.toolboxAlbum,
        icon: ImageRes.toolboxAlbum1,
        iconData: Icons.photo_library_outlined,
        onTap: () => Permissions.photos(albumCallback),
      ),
      ToolboxItemInfo(
        text: StrRes.toolboxCamera,
        icon: ImageRes.toolboxCamera1,
        iconData: Icons.camera_alt_outlined,
        onTap: () => Permissions.cameraAndMicrophoneAndPhotos(cameraCallback),
      ),
      ToolboxItemInfo(
        text: StrRes.toolboxCard,
        icon: ImageRes.toolboxCard1,
        iconData: Icons.person_outline,
        onTap: onTapCard,
      ),
      ToolboxItemInfo(
        text: StrRes.toolboxFile,
        icon: ImageRes.toolboxFile1,
        iconData: Icons.insert_drive_file_outlined,
        onTap: () => Permissions.storage(fileCallback),
      ),
      if (onTapCall != null)
        ToolboxItemInfo(
          text: StrRes.toolboxCall,
          icon: ImageRes.callVoice,
          iconData: Icons.call_outlined,
          onTap: onTapCall,
        ),
    ];

    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 20.h,
        bottom: 28.h,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFFFFFFF),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: Color(0xFFF0F4F8),
            width: 1,
          ),
        ),
      ),
      height: height ?? 224.h,
      child: AnimationLimiter(
        child: GridView.builder(
          itemCount: items.length,
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 78.w / 105.h,
            crossAxisSpacing: 14.w,
            mainAxisSpacing: 16.h,
          ),
          itemBuilder: (_, index) {
            final item = items[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 400),
              columnCount: 4,
              child: ScaleAnimation(
                scale: 0.95,
                curve: Curves.easeOutCubic,
                child: FadeInAnimation(
                  curve: Curves.easeOutCubic,
                  child: _buildItemView(
                    icon: item.icon,
                    iconData: item.iconData,
                    text: item.text,
                    onTap: item.onTap,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildItemView({
    required String text,
    required String icon,
    required IconData iconData,
    Function()? onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.08),
                  offset: const Offset(0, 3),
                  blurRadius: 12,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.95),
                  offset: const Offset(0, -1),
                  blurRadius: 6,
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
                    AppColors.iconColor.withOpacity(0.12),
                    AppColors.iconColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Icon(
                  iconData,
                  size: 26.w,
                  color: AppColors.iconColor,
                ),
              ),
            ),
          ),
        ),
        10.verticalSpace,
        Text(
          text,
          style: TextStyle(
            fontFamily: 'FilsonPro',
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showFileSheet(BuildContext context) {
    final albumCallback = onTapAlbum;
    final cameraCallback = onTapCamera;
    final fileCallback = onTapFile;

    Get.bottomSheet(
      barrierColor: Colors.transparent,
      BottomSheetView(
        items: [
          SheetItem(
            label: StrRes.toolboxAlbum,
            customIcon: Icons.photo_library_outlined,
            onTap: () => Permissions.photos(albumCallback),
          ),
          SheetItem(
            label: StrRes.toolboxCamera,
            customIcon: Icons.camera_alt_outlined,
            onTap: () =>
                Permissions.cameraAndMicrophoneAndPhotos(cameraCallback),
          ),
          SheetItem(
            label: StrRes.toolboxFile,
            customIcon: Icons.file_present_outlined,
            onTap: () => Permissions.storage(fileCallback),
          ),
        ],
      ),
    );
  }
}

class ToolboxItemInfo {
  String text;
  String icon;
  IconData iconData;
  Function()? onTap;

  ToolboxItemInfo({
    required this.text,
    required this.icon,
    required this.iconData,
    this.onTap,
  });
}