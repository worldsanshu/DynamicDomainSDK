import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/core/controller/auth_controller.dart';
import 'package:openim/core/controller/client_config_controller.dart';
import 'package:openim/pages/chat/message_frequency_logic.dart';
import 'package:openim/pages/contacts/friend_list_logic.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim/core/controller/trtc_controller.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';

import 'core/controller/gateway_config_controller.dart';
import 'core/controller/im_controller.dart';
import 'core/controller/push_controller.dart';
import 'routes/app_pages.dart';
import 'widgets/app_view.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppView(
      builder: (locale, builder) => GetMaterialApp(
        title: 'CNL',
        debugShowCheckedModeBanner: false,
        enableLog: true,
        builder: builder,
        logWriterCallback: Logger.print,
        translations: TranslationService(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          // DefaultCupertinoLocalizations.delegate,
        ],
        fallbackLocale: TranslationService.fallbackLocale,
        locale: locale,
        localeResolutionCallback: (locale, list) {
          Get.locale ??= locale;
          return locale;
        },
        supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
        getPages: AppPages.routes,
        initialBinding: InitBinding(),
        initialRoute: AppRoutes.splash,
        theme: _themeData,
        navigatorObservers: [TUICallKit.navigatorObserver],
      ),
    );
  }

  ThemeData get _themeData => ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey.shade50,
        canvasColor: Colors.white,
        appBarTheme: const AppBarTheme(color: Colors.white),
        textSelectionTheme:
            const TextSelectionThemeData().copyWith(cursorColor: Colors.blue),
        checkboxTheme: const CheckboxThemeData().copyWith(
          checkColor: WidgetStateProperty.all(Colors.white),
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey;
            }
            if (states.contains(WidgetState.selected)) {
              return Colors.blue;
            }
            return Colors.white;
          }),
          side: BorderSide(color: Colors.grey.shade500, width: 1),
        ),
        dialogTheme: const DialogThemeData().copyWith(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            textStyle: WidgetStatePropertyAll(
              TextStyle(
                fontFamily: 'FilsonPro',
                fontSize: 16.sp,
                color: Colors.black,
              ),
            ),
            foregroundColor: const WidgetStatePropertyAll(Colors.black),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData().copyWith(
            color: Colors.white,
            linearTrackColor: Colors.grey[300],
            circularTrackColor: Colors.grey[300]),
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: CupertinoColors.systemBlue,
          barBackgroundColor: Colors.white,
          applyThemeToAll: true,
          textTheme: const CupertinoTextThemeData().copyWith(
            navActionTextStyle: TextStyle(
              fontFamily: 'FilsonPro',
              color: CupertinoColors.label,
              fontSize: 17.sp,
            ),
            actionTextStyle: TextStyle(
              fontFamily: 'FilsonPro',
              color: CupertinoColors.systemBlue,
              fontSize: 17.sp,
            ),
            textStyle: TextStyle(
              fontFamily: 'FilsonPro',
              color: CupertinoColors.label,
              fontSize: 17.sp,
            ),
            navLargeTitleTextStyle: TextStyle(
              fontFamily: 'FilsonPro',
              color: CupertinoColors.label,
              fontSize: 20.sp,
            ),
            navTitleTextStyle: TextStyle(
              fontFamily: 'FilsonPro',
              color: CupertinoColors.label,
              fontSize: 17.sp,
            ),
            pickerTextStyle: TextStyle(
              fontFamily: 'FilsonPro',
              color: CupertinoColors.label,
              fontSize: 17.sp,
            ),
            tabLabelTextStyle: TextStyle(
              fontFamily: 'FilsonPro',
              color: CupertinoColors.label,
              fontSize: 17.sp,
            ),
            dateTimePickerTextStyle: TextStyle(
              fontFamily: 'FilsonPro',
              color: CupertinoColors.label,
              fontSize: 17.sp,
            ),
          ),
        ),
        primaryColor: const Color(0xFF1510F0),
        colorScheme: const ColorScheme(
          brightness:
              Brightness.light, // 这里应该是 Brightness.light 或 Brightness.dark
          primary: Color(0xFF1510F0), // 主要颜色
          onPrimary: Colors.white, // 主要颜色上的文字和图标颜色
          secondary: Color(0xFF1510F0), // 辅助颜色
          onSecondary: Colors.white, // 辅助颜色上的文字和图标颜色
          error: Colors.red, // 错误颜色
          onError: Colors.white, // 错误颜色上的文字和图标颜色
          // background: Color.fromARGB(255, 255, 255, 255), // 背景颜色
          // onBackground: Colors.black, // 背景颜色上的文字和图标颜色
          surface: Color.fromARGB(255, 240, 240, 240), // 表面颜色
          onSurface: Colors.black, // 表面颜色上的文字和图标颜色
        ),
      );
}

class InitBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<GatewayConfigController>(GatewayConfigController());
    Get.put<ClientConfigController>(ClientConfigController());
    Get.put<IMController>(IMController());
    Get.put<FriendListLogic>(FriendListLogic());
    Get.put<PushController>(PushController());
    Get.put<CacheController>(CacheController());
    Get.put<DownloadController>(DownloadController());
    Get.put<MerchantController>(MerchantController());
    Get.put<GatewayDomainController>(GatewayDomainController());
    Get.put<OnlineInfoController>(OnlineInfoController());
    Get.put<AuthController>(AuthController());
    Get.put<MessageFrequencyController>(MessageFrequencyController());
    Get.put<TRTCController>(TRTCController());
  }
}
