// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openim_common/openim_common.dart';
import 'package:uuid/uuid.dart';

typedef CustomAvatarBuilder = Widget? Function();

class AvatarView extends StatelessWidget {
  const AvatarView({
    super.key,
    this.width,
    this.height,
    this.onTap,
    this.url,
    this.file,
    this.builder,
    this.text,
    this.textStyle,
    this.onLongPress,
    this.isCircle = false,
    this.borderRadius,
    this.enabledPreview = false,
    this.lowMemory = false,
    this.nineGridUrl = const [],
    this.isGroup = false,
    this.showDefaultAvatar = true,
  });
  final double? width;
  final double? height;
  final Function()? onTap;
  final Function()? onLongPress;
  final String? url;
  final File? file;
  final CustomAvatarBuilder? builder;
  final bool isCircle;
  final BorderRadius? borderRadius;
  final bool enabledPreview;
  final String? text;
  final TextStyle? textStyle;
  final bool lowMemory;
  final List<String> nineGridUrl;
  final bool isGroup;
  final bool showDefaultAvatar;

  double get _avatarSize => min(width ?? 44.w, height ?? 44.h);

  TextStyle get _textStyle =>
      textStyle ??
      TextStyle(
        fontFamily: 'FilsonPro',
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  Color get _textAvatarBgColor =>
      isGroup ? const Color(0xFFA78BFA) : const Color(0xFF4F42FF);

  String? get _showName {
    if (isGroup) return null;
    if (text != null && text!.trim().isNotEmpty) {
      final characters = text!.characters;
      return characters.isNotEmpty ? characters.first : null;
    }
    return null;
  }

  bool get isUrlValid => IMUtils.isUrlValid(url);

  @override
  Widget build(BuildContext context) {
    var tag = const Uuid().v4();
    var child = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap ??
          ((enabledPreview && isUrlValid)
              ? () => IMUtils.previewUrlPicture([MediaSource(url!, url!)])
              : null),
      onLongPress: onLongPress,
      child: Container(
        width: _avatarSize,
        height: _avatarSize,
        decoration: BoxDecoration(
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius:
              isCircle ? null : (borderRadius ?? BorderRadius.circular(16.r)),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9CA3AF).withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: isCircle
              ? BorderRadius.circular(_avatarSize / 2)
              : (borderRadius ?? BorderRadius.circular(14.r)),
          child: builder?.call() ??
              (nineGridUrl.isNotEmpty ? _nineGridAvatar() : _normalAvatar()),
        ),
      ),
    );
    return Hero(
      tag: tag,
      child: child,
    );
  }

  Widget _normalAvatar() => !isUrlValid ? _textAvatar() : _networkImageAvatar();

  Widget _textAvatar() => Container(
        width: _avatarSize,
        height: _avatarSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: _textAvatarBgColor,
        ),
        child: null == _showName
            ? (showDefaultAvatar
                ? FaIcon(
                    isGroup
                        ? FontAwesomeIcons.users
                        : FontAwesomeIcons.solidUser,
                    color: Colors.white,
                    size: _avatarSize / 2.5,
                  )
                : null)
            : Text(_showName!, style: _textStyle),
      );

  Widget _networkImageAvatar() => file != null
      ? ImageUtil.fileImage(file: file!)
      : ImageUtil.networkImage(
          url: url!,
          width: _avatarSize,
          height: _avatarSize,
          fit: BoxFit.cover,
          lowMemory: lowMemory,
          loadProgress: false,
          errorWidget: _textAvatar(),
        );

  Widget _nineGridAvatar() => Container(
        width: _avatarSize,
        height: _avatarSize,
        color: const Color(0xFFF9FAFB),
        padding: const EdgeInsets.all(2.0),
        alignment: Alignment.center,
        child: _nineGridColumn(),
      );

  Widget _nineGridColumn() {
    final count = nineGridUrl.length;
    List<Widget> children = [];

    final len = min(9, count);
    var row = count <= 4 ? 2 : 3;
    var column = count <= 4 ? 2 : 3;
    final gridItemHeight = _avatarSize / row - 2;
    final gridItemWidth = _avatarSize / column - 2;

    for (var i = 0; i < len; i++) {
      var url = nineGridUrl[i];
      children.add(
        Container(
          width: gridItemWidth,
          height: gridItemHeight,
          margin: const EdgeInsets.all(1),
          child: IMUtils.isUrlValid(url)
              ? ImageUtil.networkImage(
                  url: url,
                  width: gridItemWidth,
                  height: gridItemHeight,
                  lowMemory: lowMemory,
                  loadProgress: false,
                )
              : Icon(
                  FontAwesomeIcons.solidUser,
                  color: Colors.white,
                  size: min(gridItemWidth, gridItemHeight) / 2,
                ),
        ),
      );
    }

    return Container(
      width: _avatarSize,
      height: _avatarSize,
      color: _textAvatarBgColor,
      alignment: Alignment.center,
      child: Wrap(
        alignment: WrapAlignment.center,
        children: children,
      ),
    );
  }
}

class RedDotView extends StatelessWidget {
  const RedDotView({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withOpacity(0.3),
              offset: Offset(2.w, 2.h),
              blurRadius: 8.r,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              offset: Offset(-1.w, -1.h),
              blurRadius: 4.r,
            ),
          ],
        ),
      );
}
