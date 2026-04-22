import 'package:editvideo/manager/app_manager.dart';
import 'package:editvideo/routes/app_pages.dart';
import 'package:editvideo/routes/route_util.dart';
import 'package:editvideo/utils/common_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'utils/constant.dart';

void main() async {
  await AppManager.instance.initial();

  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: GetMaterialApp(
        title: 'MoviX',
        theme: theme,
        getPages: AppPages.routes,
        initialRoute: RouterUtil.initialRoute(),
        fallbackLocale: USA,
        supportedLocales: const [
          USA,
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: EasyLoading.init(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child ?? Container(),
            );
          },
        ),
      ),
    ),
  );
}