import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/explor_view/explore_screen.dart';
import 'package:utsav_interview/app/home_screen/home_screen.dart';
import 'package:utsav_interview/app/tabbar_screen/tabbar_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class TabBarScreen extends StatelessWidget {
  const TabBarScreen({super.key});

  final List<Widget> screens = const [HomeScreen(), ExploreScreen(), ExploreScreen()];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TabBarScreenController>(
      init: TabBarScreenController(),
      builder: (controller) {
        return Scaffold(
          body: screens[controller.currentIndex],

          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

          bottomNavigationBar: BottomAppBar(
            color: AppColors.colorBgGray02,
            shape: const CircularNotchedRectangle(),
            shadowColor: AppColors.colorWhite,
            notchMargin: 7,
            child: SizedBox(
              height: 65,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(controller, Icons.home, CS.vHome, 0),

                  // _buildNavItem(controller, Icons.explore, "Explore", 1),
                  // FloatingActionButton(
                  //   mini: true,
                  //   shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(50)),
                  //   onPressed: () {
                  //     Get.toNamed(AppRoutes.audioTextScreen);
                  //   },
                  //   backgroundColor: Colors.white,
                  //   child: const Icon(Icons.add, size: 25, color: AppColors.colorBlack),
                  // ),
                  _buildNavItem(controller, Icons.library_books, CS.vLibrary, 1),
                  _buildNavItem(controller, Icons.settings_rounded, CS.vVoices, 2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(TabBarScreenController controller, IconData icon, String label, int index) {
    final bool isSelected = controller.currentIndex == index;

    final Color color = isSelected ? AppColors.colorWhite : AppColors.colorGrey;

    return InkWell(
      splashColor: AppColors.colorTransparent,
      overlayColor: WidgetStatePropertyAll(AppColors.colorTransparent),
      onTap: () => controller.onTabTapped(index),
      child: SizedBox(
        width: 60,
        child: Column(
          spacing: 3,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, color: color), Text(label, style: isSelected ? AppTextStyles.tabTextSelectedWhite : AppTextStyles.tabTextSelectedGrey)],
        ),
      ),
    );
  }
}
