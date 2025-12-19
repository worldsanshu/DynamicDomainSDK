import 'package:flutter/material.dart';
import 'package:openim_common/openim_common.dart';

import '../../../widgets/gradient_scaffold.dart';

class ServiceAgreementPage extends StatelessWidget {
  const ServiceAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: StrRes.serviceAgreement,
      showBackButton: true,
      scrollable: false,
      body: H5Container(url: Config.serviceAgreementLink),
    );
  }
}
