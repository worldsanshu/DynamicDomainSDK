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
        height: 91.h,
        decoration: BoxDecoration(
          // Gradient pastel tươi sáng cho card
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFF1F5F9),
            ],
          ),
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            // Outer shadow tối (hiệu ứng lõm)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
            // Outer shadow sáng (hiệu ứng nổi)
            BoxShadow(
              color: Colors.white.withOpacity(0.95),
              offset: const Offset(-4, -4),
              blurRadius: 12,
            ),
            // Viền trắng glow mờ để nổi bật
            BoxShadow(
              color: Colors.white.withOpacity(0.4),
              offset: const Offset(0, 0),
              blurRadius: 3,
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.6),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar với hiệu ứng Claymorphism
                    Container(
                      width: 45.w,
                      height: 45.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF7F8FA),
                        boxShadow: [
                          // Inner shadow cho avatar
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                            spreadRadius: -1,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            offset: const Offset(-2, -2),
                            blurRadius: 4,
                            spreadRadius: -1,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.8),
                          width: 2,
                        ),
                      ),
                      child: AvatarView(
                        width: 45.w,
                        height: 45.h,
                        url: cardElem.faceURL,
                        text: cardElem.nickname,
                        isCircle: true,
                        textStyle: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    16.horizontalSpace,
                    Flexible(
                      child: Text(
                        cardElem.nickname ?? '',
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.9),
                              offset: const Offset(0.5, 0.5),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Divider với hiệu ứng đôi
            Container(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                boxShadow: [
                  // Line trên (tối)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    offset: const Offset(0, 0),
                    blurRadius: 1,
                  ),
                  // Line dưới (sáng)
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    offset: const Offset(0, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
            ),
            // Footer container
            Container(
              height: 26.h,
              padding: EdgeInsets.only(top: 4.h, bottom: 4.h, left: 20.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28.r),
                  bottomRight: Radius.circular(28.r),
                ),
              ),
              child: Row(
                children: [
                  // Icon container cho "carte"
                  Container(
                    width: 18.w,
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          offset: const Offset(-1, -1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 12.w,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  6.horizontalSpace,
                  Text(
                    StrRes.carte,
                    style: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.9),
                          offset: const Offset(0.5, 0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
