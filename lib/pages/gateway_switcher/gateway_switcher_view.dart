// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import '../../widgets/base_page.dart';

class GatewaySwitcherView extends StatelessWidget {
  final logic = Get.find<GatewayDomainController>();

  GatewaySwitcherView({super.key});

  void onSwitch(String domain) {
    logic.switchTo(domain);
    if (Get.arguments['onSwitch'] != null) {
      Get.arguments['onSwitch'].call();
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.back(result: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      title: StrRes.switchRoute,
      centerTitle: false,
      showLeading: true,
      body: Obx(() {
        final current = logic.currentDomain.value;

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: logic.fullList.length,
          separatorBuilder: (_, index) => Divider(
            color: Colors.grey[300],
            height: 0,
          ),
          itemBuilder: (_, index) {
            final domain = logic.fullList[index];
            final isCurrent = domain == current;
            final unavailableDomainsMap = logic.unavailableDomainsMap;
            final isUnavailable = unavailableDomainsMap.containsKey(domain);

            return ListTile(
              title: Text(
                logic.getDomainLabel(domain),
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontWeight: FontWeight.bold,
                  color: isUnavailable ? Colors.red : null, // 当前线路加绿色
                ),
              ),
              tileColor: isUnavailable ? Colors.red.withOpacity(0.1) : null,
              trailing: isCurrent
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ) // 当前线路使用勾选图标
                  : const Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.grey,
                    ),
              onTap: () => onSwitch(domain),
            );
          },
        );
      }),
    );
  }
}
