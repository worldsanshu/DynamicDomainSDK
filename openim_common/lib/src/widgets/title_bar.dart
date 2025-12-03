import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class TitleBar extends StatelessWidget implements PreferredSizeWidget {
  const TitleBar({
    super.key,
    this.height,
    this.left,
    this.center,
    this.right,
    this.backgroundColor,
    this.showUnderline = false,
  });
  final double? height;
  final Widget? left;
  final Widget? center;
  final Widget? right;
  final Color? backgroundColor;
  final bool showUnderline;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Container(
        color: backgroundColor ?? Styles.c_FFFFFF,
        padding: EdgeInsets.only(top: mq.padding.top),
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: showUnderline
              ? BoxDecoration(
                  border: BorderDirectional(
                    bottom: BorderSide(
                        color: Styles.titleBarBottomBorder, width: .5),
                  ),
                )
              : null,
          child: Row(
            children: [
              if (null != left) left!,
              if (null != center) center!,
              if (null != right) right!,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? 44.h);

  TitleBar.conversation(
      {super.key,
      String? statusStr,
      bool isFailed = false,
      Function()? onClickCallBtn,
      Function()? onScan,
      Function()? onAddFriend,
      Function()? onAddGroup,
      Function()? onCreateGroup,
      CustomPopupMenuController? popCtrl,
      this.left})
      : backgroundColor = null,
        height = 62.h,
        showUnderline = false,
        center = null,
        right = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopButton(
              popCtrl: popCtrl,
              menus: [
                PopMenuInfo(
                  text: StrRes.scan,
                  icon: ImageRes.popMenuScan,
                  onTap: onScan,
                ),
                PopMenuInfo(
                  text: StrRes.addFriend,
                  icon: ImageRes.popMenuAddFriend,
                  onTap: onAddFriend,
                ),
                PopMenuInfo(
                  text: StrRes.addGroup,
                  icon: ImageRes.popMenuAddGroup,
                  onTap: onAddGroup,
                ),
                PopMenuInfo(
                  text: StrRes.createGroup,
                  icon: ImageRes.popMenuCreateGroup,
                  onTap: onCreateGroup,
                ),
              ],
              child: Icon(
                Icons.add_circle_outline,
                size: 28.w,
                color: Colors.black,
              ) /*..onTap = onClickAddBtn*/,
            ),
          ],
        );

  TitleBar.chat({
    super.key,
    String? title,
    String? member,
    String? subTitle,
    bool showOnlineStatus = false,
    bool isOnline = false,
    bool isMultiModel = false,
    bool showCallBtn = true,
    bool isMuted = false,
    this.backgroundColor,
    Function()? onClickCallBtn,
    Function()? onClickMoreBtn,
    Function()? onCloseMultiModel,
    Function()? onClickTitle,
  })  : height = 48.h,
        showUnderline = true,
        center = Flexible(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (null != title)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                      flex: 5,
                      child: Container(
                          child: title.trim().toText
                            ..style = Styles.ts_0C1C33_17sp_semibold
                            ..maxLines = 1
                            ..overflow = TextOverflow.ellipsis
                            ..textAlign = TextAlign.center
                            ..onTap = onClickTitle)),
                  if (null != member)
                    Flexible(
                        flex: 2,
                        child: Container(
                            child: member.toText
                              ..style = Styles.ts_0C1C33_17sp_semibold
                              ..maxLines = 1
                              ..onTap = onClickTitle))
                ],
              ),
            if (subTitle?.isNotEmpty == true)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showOnlineStatus)
                    Container(
                      width: 6.w,
                      height: 6.h,
                      margin: EdgeInsets.only(right: 4.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline ? Styles.c_18E875 : Styles.c_8E9AB0,
                      ),
                    ),
                  subTitle!.toText
                    ..style = Styles.ts_8E9AB0_10sp
                    ..onTap = onClickTitle,
                ],
              ),
          ],
        )),
        left = GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: 42.w,
            height: 42.h,
            decoration: BoxDecoration(
              color: const Color(0xFF4F42FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.back,
                size: 20.w,
                color: const Color(0xFF4F42FF),
              ),
            ),
          ),
        ),
        right = SizedBox(
            width: 16.w + (showCallBtn ? 56.w : 28.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showCallBtn)
                  GestureDetector(
                    onTap: isMuted ? null : onClickCallBtn,
                    child: Icon(Icons.call_outlined,
                        size: 28.w,
                        color: isMuted
                            ? Colors.black.withOpacity(0.4)
                            : Colors.black),
                  ),
                16.horizontalSpace,
                GestureDetector(
                  onTap: onClickMoreBtn,
                  child: Icon(
                    Icons.more_horiz,
                    color: Styles.c_0C1C33,
                    size: 28.w,
                  ),
                ),
              ],
            ));

  TitleBar.back({
    super.key,
    String? title,
    String? leftTitle,
    TextStyle? titleStyle,
    TextStyle? leftTitleStyle,
    String? result,
    Color? backgroundColor,
    Color? backIconColor,
    this.right,
    this.showUnderline = false,
    Function()? onTap,
  })  : height = 44.h,
        backgroundColor = backgroundColor ?? Styles.c_FFFFFF,
        center = Expanded(
            child: (title ?? '').toText
              ..style = (titleStyle ?? Styles.ts_0C1C33_17sp_semibold)
              ..textAlign = TextAlign.center),
        left = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onTap ?? (() => Get.back(result: result)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_ios, size: 24.w, color: backIconColor),
              if (null != leftTitle)
                leftTitle.toText
                  ..style = (leftTitleStyle ?? Styles.ts_0C1C33_17sp_semibold),
            ],
          ),
        );

  TitleBar.search({
    super.key,
    String? hintText,
    TextEditingController? controller,
    FocusNode? focusNode,
    bool autofocus = true,
    Function(String)? onSubmitted,
    Function()? onCleared,
    Widget? right,
    ValueChanged<String>? onChanged,
  })  : height = 44.h,
        backgroundColor = Styles.c_FFFFFF,
        center = Expanded(
          child: Container(
              child: SearchBox(
            enabled: true,
            autofocus: autofocus,
            hintText: hintText,
            controller: controller,
            focusNode: focusNode,
            onSubmitted: onSubmitted,
            onCleared: onCleared,
            onChanged: onChanged,
          )),
        ),
        showUnderline = true,
        right = right,
        left = GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: 42.w,
            height: 42.h,
            decoration: BoxDecoration(
              color: const Color(0xFF4F42FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.back,
                size: 20.w,
                color: const Color(0xFF4F42FF),
              ),
            ),
          ),
        );
}
