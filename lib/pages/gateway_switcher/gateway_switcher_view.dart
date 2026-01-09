import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:openim/widgets/gradient_scaffold.dart';
import 'package:openim_common/openim_common.dart';

class GatewaySwitcherView extends StatelessWidget {
  final logic = Get.find<GatewayDomainController>();

  GatewaySwitcherView({super.key});

  void onSwitch(String domain) {
    logic.switchTo(domain);
    if (Get.arguments != null && Get.arguments['onSwitch'] != null) {
      Get.arguments['onSwitch'].call();
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.back(result: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: StrRes.switchRoute,
      showBackButton: true,
      body: Obx(() {
        final current = logic.currentDomain.value;
        final list = logic.fullList;

        return AnimationLimiter(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            itemCount: list.length,
            itemBuilder: (_, index) {
              final domain = list[index];
              final isCurrent = domain == current;
              final unavailableDomainsMap = logic.unavailableDomainsMap;
              final isUnavailable = unavailableDomainsMap.containsKey(domain);

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  curve: Curves.fastOutSlowIn,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildItem(
                        domain: domain,
                        isCurrent: isCurrent,
                        isUnavailable: isUnavailable,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildItem({
    required String domain,
    required bool isCurrent,
    required bool isUnavailable,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isCurrent
              ? Get.theme.primaryColor
              : (isUnavailable
                  ? Colors.red.withOpacity(0.3)
                  : const Color(0xFFE5E7EB)),
          width: isCurrent ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.06),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSwitch(domain),
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        logic.getDomainLabel(domain),
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: isUnavailable
                              ? Colors.red
                              : (isCurrent
                                  ? Get.theme.primaryColor
                                  : const Color(0xFF1F2937)),
                        ),
                      ),
                      if (isUnavailable) ...[
                        4.verticalSpace,
                        Text(
                          'Unavailable',
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 12.sp,
                            color: Colors.red.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isCurrent)
                  Icon(
                    Icons.check_circle_rounded,
                    color: Get.theme.primaryColor,
                    size: 24.w,
                  )
                else
                  Icon(
                    Icons.radio_button_unchecked_rounded,
                    color: const Color(0xFFD1D5DB),
                    size: 24.w,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
