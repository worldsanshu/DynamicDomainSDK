// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'workbench_logic.dart';
import '../../widgets/base_page.dart';

class WorkbenchPage extends StatelessWidget {
  final logic = Get.find<WorkbenchLogic>();

  WorkbenchPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (logic.discoverPageURL.isNotEmpty) {
      return BasePage(
        showAppBar: true,
        title: StrRes.workbench,
        centerTitle: false,
        showLeading: false,
        body: _buildClayBody(),
      );
    } else {
      return const SizedBox.shrink(); // DailyQuotePage();
    }
  }

  // Removed old app bar builder in favor of BasePage app bar

  Widget _buildClayBody() {
    return AnimationLimiter(
      child: Container(
        margin: EdgeInsets.only(top: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFBFC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32.r),
            topRight: Radius.circular(32.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: const Offset(2, 2),
              blurRadius: 6,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              offset: const Offset(-5, -5),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: AnimationConfiguration.synchronized(
          duration: const Duration(milliseconds: 450),
          child: SlideAnimation(
            verticalOffset: 50.0,
            curve: Curves.easeOutQuart,
            child: FadeInAnimation(
              child: Obx(() => H5Container(url: logic.discoverPageURL)),
            ),
          ),
        ),
      ),
    );
  }
}
