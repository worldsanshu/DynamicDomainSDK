// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';
import 'package:search_keyword_text/search_keyword_text.dart';

class FriendItemView extends StatelessWidget {
  final ISUserInfo info;
  final bool showDivider;
  final bool? checked;
  final bool? enabled;
  final String? keyText;
  final VoidCallback? onTap;
  final bool? showRadioButton;

  const FriendItemView({
    super.key,
    required this.info,
    this.checked,
    this.enabled,
    this.showDivider = true,
    this.keyText,
    this.onTap,
    this.showRadioButton,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      color: Styles.c_FFFFFF,
      child: InkWell(
        onTap: () {
          if ((enabled ?? false) || (checked == null && enabled == null)) {
            onTap?.call();
          }
        },
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  if (checked != null && (showRadioButton ?? true))
                    Padding(
                      padding: EdgeInsets.only(right: 16.w),
                      child: ChatRadio(
                        checked: checked ?? false,
                        enabled: enabled ?? false,
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1.5.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9CA3AF).withOpacity(0.1),
                          blurRadius: 8.r,
                        ),
                      ],
                    ),
                    child: AvatarView(
                      url: info.faceURL,
                      text: info.showName,
                      width: 48.r,
                      height: 48.r,
                      isCircle: true,
                    ),
                  ),
                  16.horizontalSpace,
                  Expanded(
                    child: (keyText != null && keyText!.isNotEmpty)
                        ? SearchKeywordText(
                            text: info.showName,
                            keyText: keyText!,
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF374151),
                            ),
                            keyStyle: Styles.ts_0089FF_17sp,
                          )
                        : (info.showName.toText
                          ..maxLines = 1
                          ..overflow = TextOverflow.ellipsis
                          ..style = TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF374151),
                          )),
                  ),
                ],
              ),
            ),
            if (showDivider)
              Container(
                margin: EdgeInsets.only(left: checked != null ? 46.w : 70.w),
                height: 0.5,
                color: Styles.c_E8EAEF,
              ),
          ],
        ),
      ),
    );
  }
}
