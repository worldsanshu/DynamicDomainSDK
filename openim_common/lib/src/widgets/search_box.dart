// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter/cupertino.dart';

class SearchBox extends StatefulWidget {
  const SearchBox({
    super.key,
    this.controller,
    this.focusNode,
    this.textStyle,
    this.hintStyle,
    this.hintText,
    this.searchIconColor,
    this.backgroundColor,
    this.searchIconHeight,
    this.searchIconWidth,
    this.margin,
    this.padding,
    this.enabled = false,
    this.autofocus = false,
    this.height,
    this.onSubmitted,
    this.onCleared,
    this.onChanged,
    this.onTap,
  });
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final String? hintText;
  final Color? searchIconColor;
  final Color? backgroundColor;
  final double? searchIconWidth;
  final double? searchIconHeight;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool enabled;
  final bool autofocus;
  final double? height;
  final Function(String)? onSubmitted;
  final Function()? onCleared;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();

  bool _showClearBtn = false;

  @override
  void initState() {
    widget.controller?.addListener(() {
      setState(() {
        _showClearBtn = widget.controller!.text.isNotEmpty;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 48,
      margin: widget.margin ??
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.06),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF3F4F6),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(24.r),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: widget.padding ??
                EdgeInsets.symmetric(
                  horizontal: 16.w,
                ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.search,
                  size: widget.searchIconWidth ?? 20.w,
                  color: widget.searchIconColor ?? const Color(0xFF4F42FF),
                ),
                12.horizontalSpace,
                widget.enabled
                    ? Expanded(
                        child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: widget.autofocus,
                        onChanged: widget.onChanged,
                        onSubmitted: widget.onSubmitted,
                        style: widget.textStyle ??
                            TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF374151
    ),
                            ),
                        decoration: InputDecoration(
                          hintText: widget.hintText ?? StrRes.search,
                          hintStyle: widget.hintStyle ??
                              TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF6B7280
    ),
                              ),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ))
                    : Expanded(
                        child: Text(
                          widget.hintText ?? StrRes.search,
                          style: widget.hintStyle ??
                              TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF6B7280
    ),
                              ),
                        ),
                      ),
                if (_showClearBtn) _clearBtn,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _clearBtn => GestureDetector(
        onTap: () {
          widget.controller?.clear();
          widget.onCleared?.call();
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
          width: 28.w,
          height: 28.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            child: Icon(
              CupertinoIcons.clear,
              size: widget.searchIconWidth ?? 18.w,
              color: widget.searchIconColor ?? const Color(0xFF6B7280),
            ),
          ),
        ),
      );
}
