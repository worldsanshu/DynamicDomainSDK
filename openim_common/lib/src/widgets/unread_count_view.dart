import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UnreadCountView extends StatelessWidget {
  const UnreadCountView({
    super.key,
    this.count = 0,
    this.size = 16,
    this.margin,
  });
  final int count;
  final double size;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: count > 0,
      child: Container(
        alignment: Alignment.center,
        margin: margin,
        padding: count > 99 ? EdgeInsets.symmetric(horizontal: 4.w) : null,
        constraints: BoxConstraints(maxHeight: size, minWidth: size),
        decoration: _decoration,
        child: _text,
      ),
    );
  }

  Text get _text => Text(
        '${count > 99 ? '99+' : count}',
        style: TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFFFFFFF
    ),
        ),
        textAlign: TextAlign.center,
      );

  Decoration get _decoration => BoxDecoration(
        color: const Color(0xFFF87171),
        shape: count > 99 ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: count > 99 ? BorderRadius.circular(10.r) : null,
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            offset: Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0.5,
          ),
          BoxShadow(
            color: Color(0x269CA3AF),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      );
}
