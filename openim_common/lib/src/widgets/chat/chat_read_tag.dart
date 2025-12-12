import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

class ChatReadTagView extends StatelessWidget {
  const ChatReadTagView({
    super.key,
    required this.message,
    this.onTap,
  });
  final Message message;
  final Function()? onTap;

  int get _needReadMemberCount {
    final hasReadCount = message.attachedInfoElem?.groupHasReadInfo?.hasReadCount ?? 0;
    final unreadCount = message.attachedInfoElem?.groupHasReadInfo?.unreadCount ?? 0;
    return hasReadCount + unreadCount;
  }

  int get _unreadCount => message.attachedInfoElem?.groupHasReadInfo?.unreadCount ?? 0;

  bool get isRead => message.isRead!;

  @override
  Widget build(BuildContext context) {
    if (message.isSingleChat) {
      return Text(
        isRead ? StrRes.hasRead : StrRes.unread,
        style: isRead ? Styles.ts_8E9AB0_12sp : Styles.ts_0089FF_12sp,
      );
    } else {
      if (_needReadMemberCount == 0) return const SizedBox();
      bool isAllRead = _unreadCount == 0;
      // Fallback: use _needReadMemberCount as group member count if memberCount is not available
      int groupMemberCount = _needReadMemberCount;
      int selfExcludedCount = groupMemberCount > 0 ? groupMemberCount - 1 : 0;
      String text = isAllRead
          ? StrRes.allRead
          : (_unreadCount == selfExcludedCount)
              ? StrRes.sent
              : sprintf(StrRes.nPersonUnRead, [_unreadCount]);
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.translucent,
        child: Text(
          text,
          style: isAllRead ? Styles.ts_8E9AB0_12sp : Styles.ts_0089FF_12sp,
        ),
      );
    }
  }
}
