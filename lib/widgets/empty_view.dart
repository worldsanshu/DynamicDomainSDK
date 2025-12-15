import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import 'package:openim_common/openim_common.dart';

class EmptyView extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyView(
      {Key? key,
      this.message = "No Data Available",
      // icon chấm than
      this.icon = Ionicons.alert_circle_outline})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: primaryColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 60.w,
                  color: primaryColor,
                ),
              ),
            ),
            24.verticalSpace,
            Text(
              message.isNotEmpty ? message : StrRes.noGroupRequests,
              style: TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
