import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatRadio extends StatelessWidget {
  const ChatRadio({
    super.key,
    required this.checked,
    this.onTap,
    this.enabled = true,
  });
  final bool checked;
  final Function()? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Icon(
          (checked || !enabled ? Icons.check_circle : Icons.circle_outlined),
          color: (checked || !enabled ? Colors.blue : Colors.grey)
              .withValues(alpha: enabled ? 1 : 0.5),
          size: 20.w,
        ));
  }
}
