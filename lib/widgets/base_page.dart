import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim/widgets/custom_buttom.dart';

class BasePage extends StatefulWidget {
  BasePage({
    super.key,
    this.showAppBar = true,
    this.title,
    required this.body,
    this.bottomNavigationBar,
    this.actions,
    this.showLeading = true,
    this.centerTitle = true,
    this.customAppBar,
    this.leadingAction,
    this.leading,
  });
  final Function()? leadingAction;
  final bool showAppBar;
  final Widget body;
  final String? title;
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;
  final bool showLeading;
  final bool centerTitle;
  final Widget? customAppBar;
  final Widget? leading;

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    const appBarHeight = kToolbarHeight;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: widget.showAppBar
          ? AppBar(
              leadingWidth: 48.w,
              titleSpacing: 0,
              leading: widget.showLeading
                  ? widget.leading ??
                      CustomButtom(
                        margin: const EdgeInsets.only(left: 5, top: 5),
                        onPressed: () => widget.leadingAction != null
                            ? widget.leadingAction!()
                            : Get.back(),
                        icon: Icons.arrow_back_ios_new,
                        colorButton: Colors.white,
                        colorIcon: AppColor.iconColor,
                      )
                  : null,
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Padding(
                padding: EdgeInsets.only(left: widget.showLeading ? 0 : 12.w),
                child: widget.customAppBar ??
                    Text(
                      widget.title ?? '',
                      style: const TextStyle(
                        fontFamily: 'FilsonPro',
                        fontWeight: FontWeight.w500,
                        fontSize: 23,
                        color: Colors.black,
                      ).copyWith(fontSize: 23.sp),
                    ),
              ),
              centerTitle: widget.centerTitle,
              actions: widget.actions,
              automaticallyImplyLeading: widget.showLeading,
            )
          : null,
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          top: widget.showAppBar ? statusBarHeight + appBarHeight : 0,
        ),
        child: widget.body,
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}
