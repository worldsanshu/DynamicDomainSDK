import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// 图片验证UI组件
class Base64ImageWidget extends StatelessWidget {
  final dynamic base64String;

  const Base64ImageWidget({super.key, required this.base64String});

  @override
  Widget build(BuildContext context) {
    // 清理 Base64 字符串，去掉任何前缀
    final String cleanedBase64String = cleanBase64String(base64String as String);

    // 将清理后的 Base64 字符串解码为字节数组
    final Uint8List bytes = base64Decode(cleanedBase64String);
    // 使用 Image.memory 显示图片
    return Image.memory(bytes);
  }

  // 去掉 Base64 字符串中的前缀
  String cleanBase64String(String base64String) {
    final RegExp base64RegExp = RegExp(r'^(data:image\/[a-zA-Z]+;base64,)');
    return base64String.replaceAll(base64RegExp, '');
  }
}
