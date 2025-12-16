import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/home_screen/home_controller.dart';
import 'package:utsav_interview/app/home_screen/models/home_model.dart';
import 'package:utsav_interview/app/tabbar_screen/tabbar_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 60,
                floating: true,
                // shows AppBar when scrolling down
                snap: true,
                // smooth animation
                pinned: false,
                // disappears when scrolling up
                backgroundColor: AppColors.colorBgGray02,
                elevation: 0,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20, top: 10),
                    child: GestureDetector(
                      onTap: () {},

                      child: Container(
                        width: 34,
                        height: 34,
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(color: AppColors.colorBgWhite10, shape: BoxShape.circle),
                        child: Image.asset(CS.icSearch),
                      ),
                    ),
                  ),

                  // Padding(
                  //   padding: const EdgeInsets.only(right: 12),
                  //   child: GestureDetector(
                  //     onTap: () {},
                  //     child: CircleAvatar(
                  //       radius: 17,
                  //       backgroundColor: Colors.white24,
                  //       child: ClipOval(child: Image.network("https://i.pravatar.cc/100", fit: BoxFit.cover, height: 34, width: 34)),
                  //     ),
                  //   ),
                  // ),
                ],
                title: Text("${CS.vWelcome} ${userData?.name.split(" ").first ?? "user"}", style: AppTextStyles.heading24WhiteMedium).paddingOnly(top: 10),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(3, (index) {
                      return bookHorizontalSection(
                        onTap: () {
                          Get.toNamed(AppRoutes.bookDetailsScreen);
                        },
                        title: index == 1 ? "Love" : "Action",
                        image: index == 1 ? CS.imgBookCover2 : CS.imgBookCover,
                      );
                    }),
                  );
                }, childCount: 1),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget bookHorizontalSection({required String title, required String image, int itemCount = 5, void Function()? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        commonHeadingText(title).screenPadding(),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: itemCount,
              separatorBuilder: (_, __) => const SizedBox(width: 20),
              itemBuilder: (context, index) {
                return Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Image.asset(image), Text("A Million To One", style: AppTextStyles.body14GreyBold)],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget categoryCard(CategoryItem item) {
    return Container(
      width: 260, // fixed width for horizontal scroll
      margin: EdgeInsets.only(right: 16), // spacing between cards
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.pink.shade300, Colors.purple.shade300]),
            ),
            padding: EdgeInsets.all(20),
          ),

          SizedBox(height: 12),

          Text(item.title, style: AppTextStyles.body16WhiteBold),

          SizedBox(height: 4),

          Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.body14GreyRegular),
        ],
      ),
    );
  }
}
