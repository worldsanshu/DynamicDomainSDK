import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class ProfileHeaderAvatar extends StatelessWidget {
  final String? url;
  final String? text;
  final VoidCallback? onTap;
  final bool isGroup;
  final bool showEditIcon;
  final bool enabled;

  const ProfileHeaderAvatar({
    Key? key,
    this.url,
    this.text,
    this.onTap,
    this.isGroup = false,
    this.showEditIcon = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
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
              url: url,
              text: text,
              width: 100.w,
              height: 100.w,
              textStyle: TextStyle(fontSize: 32.sp, color: Colors.white),
              isCircle: true,
              isGroup: isGroup,
            ),
          ),
          if (showEditIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  CupertinoIcons.camera_fill,
                  size: 16.w,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
