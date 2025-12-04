import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';
import '../../../widgets/base_page.dart';

class ServiceAgreementPage extends StatelessWidget {
  const ServiceAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      title: StrRes.serviceAgreement,
      centerTitle: false,
      showLeading: true,
      body: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: H5Container(url: Config.serviceAgreementLink),
      ),
    );
  }
}
