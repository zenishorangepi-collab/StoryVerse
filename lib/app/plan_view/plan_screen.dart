import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/routes/app_routes.dart';
import 'plan_controller.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlanController>(
      init: PlanController(),
      builder: (controller) {
        return Scaffold(
          // backgroundColor: const Color(0xff1B1B1B),
          appBar: AppBar(
            backgroundColor: AppColors.colorBgGray02,
            elevation: 0,
            automaticallyImplyLeading: false,

            // centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 5,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: const Icon(Icons.keyboard_arrow_left_sharp, size: 28, color: AppColors.colorWhite),
                ),
                Row(children: [Icon(Icons.access_time, size: 16), Text(CS.vHoursLeft, style: AppTextStyles.body16WhiteMedium)]),
                IconButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.referScreen);
                  },
                  icon: Icon(Icons.card_giftcard, color: AppColors.colorWhite),
                ),
              ],
            ),
          ),

          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(CS.vChooseWhatWorks, style: AppTextStyles.heading20WhiteSemiBold),

                  const SizedBox(height: 6),

                  Text(CS.vChooseSubText, style: AppTextStyles.body16GreyRegular, strutStyle: StrutStyle(height: 1.5)),

                  const SizedBox(height: 20),

                  _planCard(controller: controller, name: CS.vUnlimited, price: "₹1,150/month", subtitle: CS.vUnlimitedSub, isPopular: true),

                  const SizedBox(height: 12),
                  Divider().paddingSymmetric(horizontal: MediaQuery.of(context).size.width / 3),

                  _planCard(controller: controller, name: CS.vHour30, price: "₹887.41", subtitle: CS.vPayAsYouGo),

                  const SizedBox(height: 5),

                  _planCard(controller: controller, name: CS.vHour15, price: "₹443.71", subtitle: CS.vPayAsYouGo),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(CS.vPlanBottomNote, style: AppTextStyles.body14GreySemiBold, strutStyle: StrutStyle(height: 1.5), textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _planCard({required PlanController controller, required String name, required String price, required String subtitle, bool isPopular = false}) {
    bool selected = controller.selectedPlan == name;
    return GestureDetector(
      onTap: () => controller.selectPlan(name),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            margin: EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppColors.colorChipBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? AppColors.colorWhite : AppColors.colorTransparent, width: 1.2),
            ),

            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(spacing: 5, children: [Icon(Icons.access_time_filled_outlined, size: 16), Text(name, style: AppTextStyles.body16WhiteMedium)]),

                      const SizedBox(height: 3),

                      Text(subtitle, style: AppTextStyles.body14GreyRegular),
                    ],
                  ),
                ),

                Text(price, style: AppTextStyles.body16WhiteBold),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              right: 25,
              child: Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Text(CS.vMostPopular.toUpperCase(), style: AppTextStyles.body12BlackMedium),
              ),
            ),
        ],
      ),
    );
  }
}
