import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class WrapAzListView<T extends ISuspensionBean> extends StatelessWidget {
  const WrapAzListView({
    super.key,
    // this.itemScrollController,
    required this.data,
    required this.itemCount,
    required this.itemBuilder,
  });

  /// Controller for jumping or scrolling to an item.
  // final ItemScrollController? itemScrollController;
  final List<T> data;
  final int itemCount;
  final Widget Function(BuildContext context, T data, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return AzListView(
      data: data,
      // physics: AlwaysScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) {
        var model = data[index];
        return itemBuilder(context, model, index);
      },
      // itemScrollController: itemScrollController,
      susItemBuilder: (BuildContext context, int index) {
        var model = data[index];
        if ('↑' == model.getSuspensionTag()) {
          return Container();
        }
        return _buildTagView(model.getSuspensionTag());
      },
      susItemHeight: 23.h,
      indexBarData: SuspensionUtil.getTagIndexList(data),
      indexBarOptions: IndexBarOptions(
        needRebuild: true,
        selectTextStyle: TextStyle(
          fontFamily: 'FilsonPro',
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
        ),
        selectItemDecoration: const BoxDecoration(),
        indexHintWidth: 80,
        indexHintHeight: 80,
        indexHintDecoration: BoxDecoration(
          color: const Color(0xE6007AFF), // 0xFF007AFF with 90% opacity
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000), // Black with 15% opacity
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        indexHintAlignment: Alignment.centerRight,
        indexHintTextStyle: TextStyle(
          fontFamily: 'FilsonPro',
          color: Colors.white,
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
        ),
        indexHintOffset: const Offset(-20, 0),
      ),
    );
  }

  Widget _buildTagView(String tag) => Container(
        height: 23.h,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        alignment: Alignment.centerLeft,
        width: 1.sw,
        child: tag.toText
          ..style = const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'FilsonPro',
          ),
      );
}
