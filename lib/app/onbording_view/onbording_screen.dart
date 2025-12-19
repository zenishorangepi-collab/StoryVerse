import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/onbording_view/onbording_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_elevated_button.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnboardingController>(
      init: OnboardingController(),
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Skip button
                // Align(alignment: Alignment.centerRight, child: TextButton(onPressed: controller.skip, child: const Text('Skip'))),

                // Slider
                Expanded(
                  child: PageView(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    children: const [
                      _OnboardingPage(title: 'Welcome', description: 'Discover new stories every day'),
                      _OnboardingPage(title: 'Listen Audio', description: 'Enjoy audio content anytime'),
                      _OnboardingPage(title: 'Save Favorites', description: 'Bookmark your favorite stories'),
                      _OnboardingPage(title: 'Get Started', description: 'Start your journey now'),
                    ],
                  ),
                ),

                // Dots indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    controller.totalPages,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.all(4),
                      width: controller.currentIndex.value == index ? 28 : 18,
                      height: 4,
                      decoration: BoxDecoration(
                        color: controller.currentIndex.value == index ? AppColors.colorWhite : AppColors.colorBgWhite10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Next button
                CommonElevatedButton(
                  onTap: controller.nextPage,
                  title: controller.currentIndex.value == controller.totalPages - 1 ? CS.vGetStarted : CS.vNext,
                ).screenPadding(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =======================
// onboarding_page_widget.dart
// =======================
class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData? icon;

  const _OnboardingPage({required this.title, required this.description, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.book, size: 120, color: AppColors.colorGrey),
          const SizedBox(height: 40),
          Text(title, style: AppTextStyles.heading20WhiteSemiBold),
          const SizedBox(height: 6),
          Text(description, textAlign: TextAlign.center, style: AppTextStyles.body16GreyMedium),
        ],
      ),
    );
  }
}

// =======================
// main.dart (Route setup)
// =======================
/*
void main() {
  runApp(GetMaterialApp(
    initialRoute: '/onboarding',
    getPages: [
      GetPage(
        name: '/onboarding',
        page: () => const OnboardingScreen(),
        binding: OnboardingBinding(),
      ),
    ],
  ));
}
*/
