import 'package:editvideo/config/color/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

EdgeInsets get safeAreaEdgeInsets => Get.mediaQuery.viewPadding;

double safeAreaTopDistance(double distance) =>
    safeAreaEdgeInsets.top + distance;

double safeAreaBottomDistance(double distance) =>
    safeAreaEdgeInsets.bottom + distance;

final theme = ThemeData(
  useMaterial3: false,
  primaryColor: CommonColors.primaryColor,
  scaffoldBackgroundColor: CommonColors.background,
  colorScheme: const ColorScheme.dark(),
  appBarTheme: AppBarTheme(
    backgroundColor: CommonColors.appBarColor,
    iconTheme: IconThemeData(color: CommonColors.appBarIconsColor),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: GetPlatform.isAndroid ? Brightness.light : Brightness.dark,
    ), // 设置状态栏颜
  ),
);