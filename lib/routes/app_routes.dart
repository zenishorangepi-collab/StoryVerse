import 'package:get/get.dart';
import 'package:utsav_interview/app/account_delete_view/account_delete_binding.dart';
import 'package:utsav_interview/app/account_delete_view/account_delete_screen.dart';
import 'package:utsav_interview/app/account_view/account_binding.dart';
import 'package:utsav_interview/app/account_view/account_screen.dart';
import 'package:utsav_interview/app/add_collection_view/add_collection_binding.dart';
import 'package:utsav_interview/app/add_collection_view/add_collection_screen.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_binding.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_screen.dart';
import 'package:utsav_interview/app/auth_options_view/authoptions_screen.dart';
import 'package:utsav_interview/app/book_details_view/book_details_binding.dart';
import 'package:utsav_interview/app/book_details_view/book_details_screen.dart';
import 'package:utsav_interview/app/collection_view/collection_binding.dart';
import 'package:utsav_interview/app/collection_view/collection_screen.dart';
import 'package:utsav_interview/app/create_collection_view/create_collection_binding.dart';
import 'package:utsav_interview/app/create_collection_view/create_collection_screen.dart';
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
import 'package:utsav_interview/app/plan_view/plan_binding.dart';
import 'package:utsav_interview/app/plan_view/plan_screen.dart';
import 'package:utsav_interview/app/preference_view/preference_binding.dart';
import 'package:utsav_interview/app/preference_view/preference_screen.dart';
import 'package:utsav_interview/app/refer_view/refer_binding.dart';
import 'package:utsav_interview/app/refer_view/refer_screen.dart';
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
  static const String splashScreen = "/splashScreen";
  static const String homeScreen = "/homeScreen";
  static const String libraryScreen = "/libraryScreen";
  static const String tabBarScreen = "/tabBarScreen";
  static const String audioTextScreen = "/audioTextScreen";
  static const String soundSpacesScreen = "/soundSpacesScreen";
  static const String voiceScreen = "/voiceScreen";
  static const String authOptionsScreen = "/authOptionsScreen";
  static const String loginScreen = "/loginScreen";
  static const String onboardingScreen = "/onboardingScreen";
  static const String bookDetailsScreen = "/bookDetailsScreen";
  static const String dobScreen = "/dobScreen";
  static const String preference = "/preference";
  static const String interests = "/interests";
  static const String referral = "/referral";
  static const String subscription = "/subscription";
  static const String accountScreen = "/accountScreen";
  static const String deleteAccount = "/deleteAccount";
  static const String planScreen = "/planScreen";
  static const String referScreen = "/referScreen";
  static const String createCollectionScreen = '/create-collection';
  static const String collectionScreen = '/collectionScreen';
  static const String addToCollection = '/addToCollection';

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
    GetPage(name: planScreen, page: () => const PlanScreen(), binding: PlanBinding()),
    GetPage(name: referScreen, page: () => const ReferScreen(), binding: ReferBinding()),
    GetPage(name: createCollectionScreen, page: () => CreateCollectionScreen(), binding: CreateCollectionBinding()),
    GetPage(name: collectionScreen, page: () => CollectionScreen(), binding: CollectionBinding()),
    GetPage(name: addToCollection, page: () => const AddToCollectionScreen(), binding: AddToCollectionBinding()),

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
