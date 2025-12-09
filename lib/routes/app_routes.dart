import 'package:get/get.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_binding.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_screen.dart';
import 'package:utsav_interview/app/explor_view/explore_binding.dart';
import 'package:utsav_interview/app/explor_view/explore_screen.dart';
import 'package:utsav_interview/app/home_screen/home_binding.dart';
import 'package:utsav_interview/app/home_screen/home_screen.dart';
import 'package:utsav_interview/app/sound_spaces_view/sound_spaces_binding.dart';
import 'package:utsav_interview/app/sound_spaces_view/sound_spaces_screen.dart';
import 'package:utsav_interview/app/tabbar_screen/tabbar_binding.dart';
import 'package:utsav_interview/app/tabbar_screen/tabbar_screen.dart';
import 'package:utsav_interview/app/voice_view/voice_binding.dart';
import 'package:utsav_interview/app/voice_view/voice_screen.dart';

import '../app/splash_screen/splash_binding.dart';
import '../app/splash_screen/splash_screen.dart';

class AppRoutes {
  static String splashScreen = "/splashScreen";
  static String homeScreen = "/homeScreen";
  static String exploreScreen = "/exploreScreen";
  static String tabBarScreen = "/tabBarScreen";
  static String audioTextScreen = "/audioTextScreen";
  static String soundSpacesScreen = "/soundSpacesScreen";
  static String voiceScreen = "/voiceScreen";

  static List<GetPage> page = [
    GetPage(name: splashScreen, page: () => SplashScreen(), binding: SplashBinding()),
    GetPage(name: tabBarScreen, page: () => TabBarScreen(), binding: TabBarBinding()),
    GetPage(name: homeScreen, page: () => HomeScreen(), binding: HomeBinding()),
    GetPage(name: exploreScreen, page: () => ExploreScreen(), binding: ExploreScreenBinding()),
    GetPage(
      name: voiceScreen,
      page: () => VoiceScreen(),
      binding: VoiceBinding(),
      transition: Transition.downToUp,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: soundSpacesScreen,
      page: () => SoundSpacesScreen(),
      binding: SoundSpacesBinding(),
      transition: Transition.downToUp,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: audioTextScreen,
      page: () => AudioTextScreen(),
      binding: AudioTextBinding(),
      transition: Transition.downToUp,
      transitionDuration: Duration(milliseconds: 500),
    ),
  ];
}
