import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/audio_text_view/audio_notification_service/notification_service.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_binding.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_controller.dart';
import 'package:utsav_interview/core/binding.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/pref.dart';
import 'package:utsav_interview/routes/app_routes.dart';

import 'firebase_options.dart';

bool shouldUseFirestoreEmulator = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AppPrefs.init();
  await AudioNotificationService.initialize();

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

      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.colorBgGray02,
        primarySwatch: Colors.blue,
        useMaterial3: true,

        brightness: Brightness.dark,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder(), TargetPlatform.iOS: CupertinoPageTransitionsBuilder()},
        ),
      ),
      darkTheme: ThemeData(scaffoldBackgroundColor: AppColors.colorBgGray02, primarySwatch: Colors.blue, useMaterial3: true, brightness: Brightness.dark),
      // home: const AudioHighlighterScreen(),
      initialRoute: AppRoutes.splashScreen,
      getPages: AppRoutes.page,
      initialBinding: AppBindings(),
    );
  }
}
