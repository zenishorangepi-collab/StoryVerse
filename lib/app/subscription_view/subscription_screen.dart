import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scroll_loop_auto_scroll/scroll_loop_auto_scroll.dart';
import 'package:utsav_interview/app/subscription_view/subscription_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_elevated_button.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_style.dart';
import '../../core/common_string.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isArguments = Get.arguments ?? false;
    return GetBuilder<SubscriptionController>(
      builder: (controller) {
        return Scaffold(
          // backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: !isArguments ? 40 : 80),

                      /// Top preview cards
                      ScrollLoopAutoScroll(
                        scrollDirection: Axis.horizontal,
                        //required
                        delay: Duration(seconds: 1),
                        duration: Duration(seconds: 50),
                        gap: 10,
                        reverseScroll: false,
                        duplicateChild: 25,
                        enableScrollInput: true,
                        delayAfterScrollInput: Duration(seconds: 1),
                        child: Row(
                          children: [
                            Container(
                              height: 140,
                              margin: const EdgeInsets.only(right: 10),
                              child: ClipRRect(borderRadius: BorderRadius.circular(5), child: Image.asset(CS.imgBookCover, fit: BoxFit.cover)),
                            ),
                            Container(
                              height: 140,
                              margin: const EdgeInsets.only(right: 10),
                              child: ClipRRect(borderRadius: BorderRadius.circular(5), child: Image.asset(CS.imgBookCover2, fit: BoxFit.cover)),
                            ),
                          ],
                        ),
                      ),

                      if (!isArguments) const SizedBox(height: 40),
                      if (!isArguments) Text(CS.vUnlockUnlimited, style: AppTextStyles.body16WhiteMedium).screenPadding(),

                      const SizedBox(height: 16),
                      const Text(CS.vUnlockEverything, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)).screenPadding(),

                      const SizedBox(height: 20),

                      _feature(CS.vFeatureUnlimited).screenPadding(),
                      _feature(CS.vFeatureVoices).screenPadding(),
                      _feature(CS.vFeatureDownload).screenPadding(),
                      _feature(CS.vFeatureSkip).screenPadding(),

                      const SizedBox(height: 24),

                      _planCard(
                        title: CS.vUltraYearly,
                        price: "₹9,900.00 / yr",
                        subtitle: "Best value — ₹825.00/mo, paid annually.",
                        isPopular: true,
                        isSelected: controller.selectedPlan == SubscriptionPlan.yearly,
                        onTap: () => controller.selectPlan(SubscriptionPlan.yearly),
                      ).screenPadding(),

                      _planCard(
                        title: CS.vUltraMonthly,
                        price: "₹999.00 / mo",
                        isSelected: controller.selectedPlan == SubscriptionPlan.monthly,
                        onTap: () => controller.selectPlan(SubscriptionPlan.monthly),
                      ).screenPadding(),

                      const SizedBox(height: 30),

                      Center(child: Text(CS.vWhyJoinUltra, style: AppTextStyles.heading20WhiteSemiBold).screenPadding()),
                      const SizedBox(height: 6),
                      Center(child: Text(CS.vWhyJoinDesc, style: AppTextStyles.body14GreyRegular).screenPadding()),

                      const SizedBox(height: 25),

                      _infoTile(Icons.emoji_events_outlined, CS.vAwarded, CS.vAwardedDesc).screenPadding(),

                      const SizedBox(height: 25),

                      _infoTile(Icons.headphones_outlined, CS.vUnlimitedListening, CS.vUnlimitedDesc).screenPadding(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                if (isArguments)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(CS.imgSplashLogo, height: 30, color: AppColors.colorWhite),
                      commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 12, padding: 12),
                    ],
                  ).paddingSymmetric(horizontal: 25, vertical: 20),
              ],
            ),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Upgrade
              CommonElevatedButton(
                onTap: () {
                  controller.onUpgrade();
                },

                title: CS.vUpgradeUltra,
              ).screenPadding(),

              const SizedBox(height: 12),

              isArguments
                  ? Text(CS.vCancelGooglePlay, style: AppTextStyles.body12GreyRegular)
                  : CommonElevatedButton(
                    onTap: () {
                      controller.onContinueFree();
                    },
                    backgroundColor: AppColors.colorBgWhite10,

                    title: CS.vContinueFree,
                    textStyle: AppTextStyles.body16WhiteMedium,
                  ).screenPadding(),

              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }

  Widget _feature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [const Icon(Icons.check, size: 18), const SizedBox(width: 10), Expanded(child: Text(text, style: AppTextStyles.body14GreyBold))]),
    );
  }

  Widget _planCard({
    required String title,
    required String price,
    String? subtitle,
    bool isPopular = false,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isSelected ? AppColors.colorWhite : AppColors.colorTransparent, width: isSelected ? 1.6 : 1),
              color: AppColors.colorBgWhite10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.button16WhiteBold),

                      const SizedBox(height: 4),
                      Text(price, style: AppTextStyles.button18WhiteBold),
                      if (subtitle != null) Text(subtitle, style: AppTextStyles.body14GreyBold),
                    ],
                  ),
                ),
                if (isSelected) const Icon(Icons.check_circle, color: AppColors.colorWhite),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              right: 20,
              top: -1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Text(CS.vMostPopular.toUpperCase(), style: AppTextStyles.body12BlackMedium),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 35),
        const SizedBox(height: 10),
        Text(title, style: AppTextStyles.body16WhiteMedium),
        const SizedBox(height: 4),
        Text(desc, style: AppTextStyles.body14GreyRegular, textAlign: TextAlign.center),
      ],
    );
  }
}
