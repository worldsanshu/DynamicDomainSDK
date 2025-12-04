import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';
import '../../../widgets/base_page.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      title: StrRes.privacyPolicy,
      centerTitle: false,
      showLeading: true,
      body: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: H5Container(url: Config.privacyPolicyLink),
      ),
    );
  }
}
