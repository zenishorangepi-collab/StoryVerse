import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_controller.dart';
import 'package:utsav_interview/app/audio_text_view/widgets/mini_audio_player.dart';
import 'package:utsav_interview/app/book_details_view/book_details_controller.dart';
import 'package:utsav_interview/app/home_screen/home_controller.dart';
import 'package:utsav_interview/app/home_screen/models/home_model.dart';
import 'package:utsav_interview/app/home_screen/models/novel_model.dart';
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
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 20,
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
                        padding: const EdgeInsets.only(right: 20, top: 20),
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoutes.searchScreen);
                          },

                          child: Hero(
                            tag: CS.heroTag,
                            child: Container(
                              width: 34,
                              height: 34,
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(color: AppColors.colorBgWhite10, shape: BoxShape.circle),
                              child: Image.asset(CS.icSearch),
                            ),
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
                    title: Text(
                      "${CS.vWelcome} ${userData?.name.split(" ").first ?? "user"}",
                      style: AppTextStyles.heading24WhiteMedium,
                    ).paddingOnly(top: 20, left: 10),
                  ),

                  SliverToBoxAdapter(
                    child: StreamBuilder(
                      stream: listRecents.stream,
                      builder: (context, asyncSnapshot) {
                        return listRecents.isEmpty
                            ? SizedBox(height: 10)
                            : SizedBox(
                              height: 150,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20),
                                  Text(CS.vRecentsListening, style: AppTextStyles.body16GreyMedium).screenPadding(),

                                  Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.only(left: 25, top: 20, bottom: 0, right: 16),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: listRecents.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () async {
                                            if (bookInfo.value.id != listRecents[index].id) {
                                              isAudioInitCount.value = 0;
                                              Get.find<AudioTextController>().pause();
                                              Get.toNamed(AppRoutes.audioTextScreen, arguments: {"novelData": listRecents[index], "isInitCall": true})?.then((
                                                value,
                                              ) {
                                                controller.getRecentList();
                                              });
                                            } else {
                                              Get.toNamed(AppRoutes.audioTextScreen, arguments: {"isInitCall": true});
                                            }
                                          },
                                          child: SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.85, // adjusts
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                                                  decoration: BoxDecoration(color: AppColors.colorBgGray04, borderRadius: BorderRadius.circular(5)),
                                                  child: Card(
                                                    elevation: 2,
                                                    shadowColor: AppColors.colorBlack,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(2),
                                                      child: CachedNetworkImage(
                                                        height: 60,
                                                        fit: BoxFit.cover,
                                                        imageUrl: listRecents[index].bookCoverUrl ?? "",
                                                        errorWidget: (context, error, stackTrace) {
                                                          return Image.asset(CS.imgBookCover2, height: 60, fit: BoxFit.cover);
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 15),

                                                Expanded(
                                                  child: Column(
                                                    spacing: 3,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(listRecents[index].bookName ?? "", style: AppTextStyles.body14WhiteBold),

                                                      Text(
                                                        listRecents[index].summary ?? "",
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: AppTextStyles.body14GreySemiBold,
                                                      ),

                                                      Text(
                                                        secondsToMinSec(listRecents[index].totalAudioLength ?? 0.0),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: AppTextStyles.body14GreySemiBold,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                      },
                    ),
                  ),
                  // Display categories with novels
                  StreamBuilder(
                    stream: controller.listNovelData.stream,
                    builder: (context, novelSnapshot) {
                      if (!novelSnapshot.hasData) {
                        return SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: CircularProgressIndicator(color: AppColors.colorWhite).paddingOnly(top: 50),
                            ),
                          ),
                        );
                      }
                      final activeCategories = controller.getActiveCategoriesOnly();

                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, categoryIndex) {
                          final category = activeCategories[categoryIndex];
                          final categoryNovels = controller.getNovelsForCategory(category.id ?? "", category.name ?? '');

                          if (categoryNovels.isEmpty) {
                            return SliverToBoxAdapter(
                              child: Center(
                                child: Padding(padding: const EdgeInsets.all(20), child: Text(CS.vNoNovelFound, style: AppTextStyles.body14WhiteBold)),
                              ),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category title
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Text(category.name ?? '', style: AppTextStyles.heading18WhiteSemiBold),
                              ),

                              // Horizontal list of novels in this category
                              SizedBox(
                                height: 200,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: categoryNovels.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 20),
                                  itemBuilder: (context, novelIndex) {
                                    NovelsDataModel novel = categoryNovels[novelIndex];

                                    return GestureDetector(
                                      onTap: () {
                                        Get.toNamed(AppRoutes.bookDetailsScreen, arguments: novel)?.then((_) {
                                          controller.getRecentList();
                                        });
                                      },
                                      child: Column(
                                        spacing: 5,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: novel.bookCoverUrl ?? "",
                                            height: 150,
                                            width: 100,
                                            fit: BoxFit.cover,
                                            placeholder:
                                                (context, url) => Shimmer(
                                                  // duration: Duration(seconds: 3),
                                                  // interval: Duration(seconds: 5),
                                                  color: Colors.white,
                                                  colorOpacity: 100,
                                                  enabled: true,
                                                  direction: ShimmerDirection.fromLTRB(),
                                                  child: Container(height: 150, width: 100, color: AppColors.colorGrey),
                                                ),
                                            errorWidget:
                                                (context, url, error) => Container(height: 150, width: 100, color: Colors.grey, child: const Icon(Icons.book)),
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                              novel.bookName ?? "",
                                              style: AppTextStyles.body12GreyRegular,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }, childCount: activeCategories.length),
                      );
                    },
                  ),
                ],
              ).paddingOnly(bottom: isBookListening.value ? 60 : 0),
              StreamBuilder(
                stream: isBookListening.stream,
                builder: (context, snap) {
                  if (!isBookListening.value) return SizedBox.fromSize();

                  return StreamBuilder(
                    stream: isPlayAudio.stream,
                    builder: (context, asyncSnapshot) {
                      return StreamBuilder(
                        stream: bookInfo.stream,
                        builder: (context, bookSnapshot) {
                          return MiniAudioPlayer(
                            bookImage: bookInfo.value.bookCoverUrl ?? "",
                            authorName: bookInfo.value.author?.name ?? "",
                            bookName: bookInfo.value.bookName ?? "",
                            playIcon: isPlayAudio.value ? Icons.pause : Icons.play_arrow_rounded,

                            onPlayPause: () {
                              if (isAudioInitCount.value == 0) {
                                Get.toNamed(AppRoutes.audioTextScreen, arguments: {"isInitCall": false});
                              } else {
                                Get.find<AudioTextController>().togglePlayPause(isOnlyPlayAudio: true);
                              }
                            },
                            onForward10: () {
                              Get.find<AudioTextController>().skipForward();
                            },
                          );
                        },
                      );
                    },
                  );
                },
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
        const SizedBox(height: 20),
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
                  children: [Image.network(image), Text(title, style: AppTextStyles.body14GreyBold)],
                );
              },
            ).paddingOnly(left: 8),
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
