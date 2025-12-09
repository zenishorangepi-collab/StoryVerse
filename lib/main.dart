import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/routes/app_routes.dart';

void main() {
  runApp(const AudioHighlighterApp());
}

class AudioHighlighterApp extends StatelessWidget {
  const AudioHighlighterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Audio Text Synchronizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: AppColors.colorBg, primarySwatch: Colors.blue, useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(scaffoldBackgroundColor: AppColors.colorBg, primarySwatch: Colors.blue, useMaterial3: true, brightness: Brightness.dark),
      // home: const AudioHighlighterScreen(),
      initialRoute: AppRoutes.splashScreen,
      getPages: AppRoutes.page,
    );
  }
}
