import 'package:flutter/material.dart';
import 'package:openim_common/openim_common.dart';

import '../../../widgets/gradient_scaffold.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: StrRes.privacyPolicy,
      showBackButton: true,
      scrollable: false,
      body: H5Container(url: Config.privacyPolicyLink),
    );
  }
}
