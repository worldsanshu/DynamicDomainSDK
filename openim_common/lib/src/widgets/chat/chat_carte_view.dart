// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class ChatCarteView extends StatelessWidget {
  const ChatCarteView({
    super.key,
    required this.cardElem,
  });
  final CardElem cardElem;

  @override
  Widget build(BuildContext context) => Container(
        width: locationWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 10,
            ),
          ],
          border: Border.all(
            color: Styles.c_E8EAEF,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  AvatarView(
                    width: 44.w,
                    height: 44.h,
                    url: cardElem.faceURL,
                    text: cardElem.nickname,
                    isCircle: true,
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Text(
                      cardElem.nickname ?? '',
                      style: Styles.ts_0C1C33_17sp,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Styles.c_E8EAEF, thickness: 1),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.person_rounded,
                    size: 14.w,
                    color: Styles.c_8E9AB0,
                  ),
                  6.horizontalSpace,
                  Text(
                    StrRes.carte,
                    style: Styles.ts_8E9AB0_12sp,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
