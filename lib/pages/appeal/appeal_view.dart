// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim/pages/appeal/appeal_logic.dart';
import 'package:openim/widgets/custom_buttom.dart';
import 'package:openim_common/openim_common.dart';
import '../../widgets/base_page.dart';

class AppealPage extends StatelessWidget {
  AppealPage({super.key});

  final logic = Get.find<AppealLogic>();

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: BasePage(
        showAppBar: true,
        title: StrRes.appealSubmit,
        centerTitle: false,
        showLeading: true,
        actions: [
          CustomButton(
            onTap: logic.submitAppeal,
            title: StrRes.confirm,
            colorButton: const Color(0xFF34D399).withOpacity(0.1),
            colorIcon: const Color(0xFF34D399),
          ),
        ],
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                StrRes.restrictedUseReason
                    .replaceFirst('%s', logic.blockReason.value),
                style: const TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: logic.descriptionController,
                focusNode: logic.descriptionFocusNode,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: StrRes.enterAppealDetails,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
