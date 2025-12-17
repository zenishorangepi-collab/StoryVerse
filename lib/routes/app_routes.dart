import 'package:get/get.dart';
import 'package:utsav_interview/app/account_delete_view/account_delete_binding.dart';
import 'package:utsav_interview/app/account_delete_view/account_delete_screen.dart';
import 'package:utsav_interview/app/account_view/account_binding.dart';
import 'package:utsav_interview/app/account_view/account_screen.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_binding.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_screen.dart';
import 'package:utsav_interview/app/auth_options_view/authoptions_screen.dart';
import 'package:utsav_interview/app/book_details_view/book_details_binding.dart';
import 'package:utsav_interview/app/book_details_view/book_details_screen.dart';
import 'package:utsav_interview/app/dob_view/dob_binding.dart';
import 'package:utsav_interview/app/dob_view/dob_screen.dart';
import 'package:utsav_interview/app/home_screen/home_binding.dart';
import 'package:utsav_interview/app/home_screen/home_screen.dart';
import 'package:utsav_interview/app/interest_view/interest_binding.dart';
import 'package:utsav_interview/app/interest_view/interest_screen.dart';
import 'package:utsav_interview/app/library_view/library_binding.dart';
import 'package:utsav_interview/app/library_view/library_screen.dart';
import 'package:utsav_interview/app/login_view/login_binding.dart';
import 'package:utsav_interview/app/login_view/login_screen.dart';
import 'package:utsav_interview/app/onbording_view/onbording_binding.dart';
import 'package:utsav_interview/app/onbording_view/onbording_screen.dart';
import 'package:utsav_interview/app/preference_view/preference_binding.dart';
import 'package:utsav_interview/app/preference_view/preference_screen.dart';
import 'package:utsav_interview/app/referral_view/referral_binding.dart';
import 'package:utsav_interview/app/referral_view/referral_screen.dart';

import 'package:utsav_interview/app/sound_spaces_view/sound_spaces_binding.dart';
import 'package:utsav_interview/app/sound_spaces_view/sound_spaces_screen.dart';
import 'package:utsav_interview/app/subscription_view/subscription_binding.dart';
import 'package:utsav_interview/app/subscription_view/subscription_screen.dart';
import 'package:utsav_interview/app/tabbar_screen/tabbar_binding.dart';
import 'package:utsav_interview/app/tabbar_screen/tabbar_screen.dart';
import 'package:utsav_interview/app/voice_view/voice_binding.dart';
import 'package:utsav_interview/app/voice_view/voice_screen.dart';

import '../app/splash_screen/splash_binding.dart';
import '../app/splash_screen/splash_screen.dart';

class AppRoutes {
  static String splashScreen = "/splashScreen";
  static String homeScreen = "/homeScreen";
  static String libraryScreen = "/libraryScreen";
  static String tabBarScreen = "/tabBarScreen";
  static String audioTextScreen = "/audioTextScreen";
  static String soundSpacesScreen = "/soundSpacesScreen";
  static String voiceScreen = "/voiceScreen";
  static String authOptionsScreen = "/authOptionsScreen";
  static String loginScreen = "/loginScreen";
  static String onboardingScreen = "/onboardingScreen";
  static String bookDetailsScreen = "/bookDetailsScreen";
  static String dobScreen = "/dobScreen";
  static String preference = "/preference";
  static String interests = "/interests";
  static String referral = "/referral";
  static String subscription = "/subscription";
  static String accountScreen = "/accountScreen";
  static String deleteAccount = "/deleteAccount";

  static List<GetPage> page = [
    GetPage(name: splashScreen, page: () => SplashScreen(), binding: SplashBinding()),
    GetPage(name: tabBarScreen, page: () => TabBarScreen(), binding: TabBarBinding()),
    GetPage(name: homeScreen, page: () => HomeScreen(), binding: HomeBinding()),
    GetPage(name: libraryScreen, page: () => LibraryScreen(), binding: LibraryBinding()),
    GetPage(name: authOptionsScreen, page: () => AuthOptionsScreen(), binding: AudioTextBinding()),
    GetPage(name: loginScreen, page: () => LoginScreen(), binding: LoginBinding()),
    GetPage(name: onboardingScreen, page: () => OnboardingScreen(), binding: OnboardingBinding()),
    GetPage(name: bookDetailsScreen, page: () => BookDetailsScreen(), binding: BookDetailsBinding()),
    GetPage(name: dobScreen, page: () => DobScreen(), binding: DobBinding()),
    GetPage(name: preference, page: () => const PreferenceScreen(), binding: PreferenceBinding()),
    GetPage(name: interests, page: () => const InterestScreen(), binding: InterestBinding()),
    GetPage(name: referral, page: () => const ReferralSourceScreen(), binding: ReferralBinding()),
    GetPage(name: subscription, page: () => const SubscriptionScreen(), binding: SubscriptionBinding()),
    GetPage(name: accountScreen, page: () => const AccountScreen(), binding: AccountBinding()),
    GetPage(name: deleteAccount, page: () => const DeleteAccountScreen(), binding: DeleteAccountBinding()),
    GetPage(
      name: voiceScreen,
      page: () => VoiceScreen(),
      binding: VoiceBinding(),
      transition: Transition.downToUp,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: soundSpacesScreen,
      page: () => SoundSpacesScreen(),
      binding: SoundSpacesBinding(),
      transition: Transition.downToUp,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: audioTextScreen,
      page: () => AudioTextScreen(),
      binding: AudioTextBinding(),
      transition: Transition.downToUp,
      transitionDuration: Duration(milliseconds: 300),
    ),
  ];
}
