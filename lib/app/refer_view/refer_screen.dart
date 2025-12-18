import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_style.dart';
import '../../core/common_string.dart';
import 'refer_controller.dart';

class ReferScreen extends StatelessWidget {
  const ReferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReferController>(
      init: ReferController(),
      builder: (controller) {
        return Scaffold(
          // backgroundColor: const Color(0xff1B1B1B),
          body: SafeArea(
            child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 12, padding: 12),
                    ).paddingOnly(top: 30),

                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time_filled_outlined, color: Colors.white, size: 28),
                            SizedBox(width: 6),
                            Text(CS.vFiveHrs, style: AppTextStyles.heading30WhiteBold),
                          ],
                        ),

                        const SizedBox(height: 30),

                        Text(CS.vReferMain, textAlign: TextAlign.center, style: AppTextStyles.heading20WhiteSemiBold),

                        const SizedBox(height: 10),

                        Text(CS.vReferSub, textAlign: TextAlign.center, style: AppTextStyles.body14GreySemiBold),
                      ],
                    ),

                    GestureDetector(
                      onTap: () => controller.shareReferLink(),
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        child: Text(CS.vShareBtn, style: AppTextStyles.button16BlackBold),
                      ),
                    ).paddingOnly(bottom: 30),
                  ],
                ).screenPadding(),
          ),
        );
      },
    );
  }
}
