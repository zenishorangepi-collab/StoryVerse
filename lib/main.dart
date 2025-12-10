import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(const AudioHighlighterApp());
}

class AudioHighlighterApp extends StatelessWidget {
  const AudioHighlighterApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorObservers: [observer],
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
