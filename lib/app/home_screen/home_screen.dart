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
                expandedHeight: 70,
                floating: true,
                // shows AppBar when scrolling down
                snap: true,
                // smooth animation
                pinned: false,
                // disappears when scrolling up
                backgroundColor: AppColors.colorBg,
                elevation: 0,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {},

                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.colorBgWhite10,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 20,
                        ),
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
                        child: ClipOval(
                          child: Image.network(
                            "https://i.pravatar.cc/100",
                            fit: BoxFit.cover,
                            height: 34,
                            width: 34,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                title: Text(
                  "${CS.vWelcome} User",
                  style: AppTextStyles.heading2,
                ),
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
                            _buildChip(Icons.star, CS.vForYou),
                            _buildChip(Icons.people, CS.vFollowing),
                            _buildChip(Icons.history, CS.vRecents),
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
                          buildActionBox(Icons.edit, CS.vWriteText),
                          buildActionBox(Icons.upload_file, CS.vUploadFile),
                          buildActionBox(Icons.document_scanner, CS.vScanText),
                          buildActionBox(Icons.link, CS.vPasteLink),
                        ],
                      ),
                      const SizedBox(height: 20),
                      commonHeadingText(CS.vRecommendedCollection),
                      const SizedBox(height: 14),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              controller.dummyCategoryList
                                  .map((item) => categoryCard(item))
                                  .toList(),
                        ),
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

  Widget _buildChip(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        avatar: Icon(icon, size: 18, color: AppColors.colorWhite),

        label: Text(label, style: AppTextStyles.bodyMedium),
        color: WidgetStatePropertyAll(AppColors.colorBgWhite02),

        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      ),
    );
  }

  Widget buildActionBox(IconData icon, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.colorBgWhite02,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.pink.shade300, Colors.purple.shade300],
              ),
            ),
            padding: EdgeInsets.all(20),
          ),

          SizedBox(height: 12),

          Text(item.title, style: AppTextStyles.bodyLarge),

          SizedBox(height: 4),

          Text(
            item.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMediumGrey,
          ),
        ],
      ),
    );
  }
}
