import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/subscription_view/subscription_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_elevated_button.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/routes/app_routes.dart';
import '../../core/common_string.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 35),

                  /// Top preview cards
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      reverse: true,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,

                      itemBuilder: (_, index) => Image.asset(CS.imgBookCover).paddingOnly(left: index == 4 ? 0 : 20),
                    ),
                  ).paddingOnly(right: 15),

                  const SizedBox(height: 40),
                  Text(CS.vUnlockUnlimited, style: AppTextStyles.body16BlackMedium).screenPadding(),

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

                  Center(child: Text(CS.vWhyJoinUltra, style: AppTextStyles.heading20BlackBold).screenPadding()),
                  const SizedBox(height: 6),
                  Center(child: Text(CS.vWhyJoinDesc, style: AppTextStyles.body16BlackMedium).screenPadding()),

                  const SizedBox(height: 25),

                  _infoTile(Icons.emoji_events_outlined, CS.vAwarded, CS.vAwardedDesc).screenPadding(),

                  const SizedBox(height: 25),

                  _infoTile(Icons.headphones_outlined, CS.vUnlimited, CS.vUnlimitedDesc).screenPadding(),

                  const SizedBox(height: 40),
                ],
              ),
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
                isDark: true,

                title: CS.vUpgradeUltra,
              ).screenPadding(),

              const SizedBox(height: 12),

              /// Continue Free
              CommonElevatedButton(
                onTap: () {
                  controller.onContinueFree();
                },
                backgroundColor: AppColors.colorBgWhite10,

                title: CS.vContinueFree,
              ).screenPadding(),

              const SizedBox(height: 40),
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
              border: Border.all(color: isSelected ? AppColors.colorDialogHeader : AppColors.colorGrey, width: isSelected ? 1.6 : 1),
              color: isSelected ? AppColors.colorWhite : Colors.grey.shade100,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.button16BlackBold),

                      const SizedBox(height: 4),
                      Text(price, style: AppTextStyles.button18BlackBold),
                      if (subtitle != null) Text(subtitle, style: AppTextStyles.body14GreyBold),
                    ],
                  ),
                ),
                if (isSelected) const Icon(Icons.check_circle, color: AppColors.colorBlack),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              right: 20,
              top: -1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(15)),
                child: Text(CS.vMostPopular, style: AppTextStyles.body12Regular),
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
        Text(title, style: AppTextStyles.body16BlackMedium),
        const SizedBox(height: 4),
        Text(desc, style: AppTextStyles.body14GreyRegular, textAlign: TextAlign.center),
      ],
    );
  }
}
