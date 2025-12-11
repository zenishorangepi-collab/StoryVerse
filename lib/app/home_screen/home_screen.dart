import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/home_screen/home_controller.dart';
import 'package:utsav_interview/app/home_screen/models/home_model.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';

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
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {},

                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: AppColors.colorBgWhite10, shape: BoxShape.circle),
                        child: const Icon(Icons.search, color: Colors.white, size: 20),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {},
                      child: CircleAvatar(
                        radius: 17,
                        backgroundColor: Colors.white24,
                        child: ClipOval(child: Image.network("https://i.pravatar.cc/100", fit: BoxFit.cover, height: 34, width: 34)),
                      ),
                    ),
                  ),
                ],
                title: Text("${CS.vWelcome} User", style: AppTextStyles.heading2),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            buildChip(icon: Icons.star, label: CS.vForYou),
                            buildChip(icon: Icons.people, label: CS.vFollowing),
                            buildChip(icon: Icons.history, label: CS.vRecents),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      commonHeadingText(CS.vUploadAndListen),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildActionBox(icon: Icons.edit, label: CS.vWriteText),
                          buildActionBox(icon: Icons.upload_file, label: CS.vUploadFile),
                          buildActionBox(icon: Icons.document_scanner, label: CS.vScanText),
                          buildActionBox(icon: Icons.link, label: CS.vPasteLink),
                        ],
                      ),
                      const SizedBox(height: 20),
                      commonHeadingText(CS.vRecommendedCollection),
                      const SizedBox(height: 14),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: controller.dummyCategoryList.map((item) => categoryCard(item)).toList()),
                      ),
                    ],
                  ).screenPadding();
                }, childCount: 1),
              ),
            ],
          ),
        );
      },
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

          Text(item.title, style: AppTextStyles.bodyLarge),

          SizedBox(height: 4),

          Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodyMediumGrey),
        ],
      ),
    );
  }
}
