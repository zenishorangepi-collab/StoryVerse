import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/account_view/account_controller.dart';
import 'package:utsav_interview/app/auth_options_view/service/auth_service.dart';
import 'package:utsav_interview/app/tabbar_screen/tabbar_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_elevated_button.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/core/pref.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountController>(
      init: AccountController(),
      builder: (controller) {
        return Scaffold(
          // backgroundColor: AppColors.colorBlack,
          appBar: AppBar(
            backgroundColor: AppColors.colorTransparent,surfaceTintColor: AppColors.colorTransparent,
            // elevation: 0,
            title: Text(CS.vAccount, style: AppTextStyles.heading24WhiteMedium).paddingOnly( left: 10),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.referScreen);
                },
                icon: Icon(Icons.card_giftcard, color: AppColors.colorWhite),
              ).paddingOnly( right: 10),
            ],
          ),

          body: SingleChildScrollView(
            child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),

                    /// ---------- PROFILE ----------
                    userData==null?
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.colorGreyBg,
                              child: Icon(Icons.person_outline),
                            ),
                            SizedBox(height: 10),
                            Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8),

                                decoration: BoxDecoration(borderRadius: BorderRadiusGeometry.circular(5), color: AppColors.colorBgWhite10),
                                child: Text("FREE", style: AppTextStyles.body14GreyBold),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text("Guest", style: AppTextStyles.heading20WhiteSemiBold),
                          ],
                        )
                        :
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: AppColors.colorTealDark,
                            child: Text(userData?.name.isNotEmpty??false?userData?.name[0].toUpperCase() ?? "":"", style: AppTextStyles.heading20WhiteSemiBold),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),

                              decoration: BoxDecoration(borderRadius: BorderRadiusGeometry.circular(5), color: AppColors.colorBgWhite10),
                              child: Text("FREE", style: AppTextStyles.body14GreyBold),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(userData?.name.toUpperCase() ?? "", style: AppTextStyles.heading20WhiteSemiBold),
                          SizedBox(height: 4),
                          Text(userData?.email ?? "", style: AppTextStyles.body16GreySemiBold),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),
                    Column(
                      children: [
                        Text(CS.vHoursListening, style: AppTextStyles.body16WhiteRegular),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(8)),
                              child: Text("1", style: AppTextStyles.body16WhiteMedium),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(8)),
                              child: Text("0", style: AppTextStyles.body16WhiteMedium),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey[600], size: 16),
                            const SizedBox(width: 6),
                            Text("10 hours refresh on ${2}", style: AppTextStyles.body14GreyRegular),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    /// ---------- SUBSCRIPTION CARD ----------
                    upgradeUltraBox(),
                    SizedBox(height: 20),

                    /// ---------- GET MORE HOURS ----------
                    CommonElevatedButton(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      title: CS.vGetMoreHours,
                      // onTap: controller.onGetMoreHoursTap,
                      backgroundColor: AppColors.colorDialogHeader,
                      side: BorderSide(color: AppColors.colorWhite, width: 0.1),
                      textStyle: AppTextStyles.body16WhiteMedium,
                      radius: 30,
                      onTap: () {
                        Get.toNamed(AppRoutes.planScreen);
                      },
                    ),

                    SizedBox(height: 20),
                    Divider(),

                    /// ---------- REFER & SAVE ----------
                    commonListTile(
                      title: CS.vReferAndSave,
                      icon: Icons.card_giftcard,
                      onTap: () {
                        Get.toNamed(AppRoutes.referScreen);
                      },
                    ),
                    commonListTile(
                      title: CS.vContentPreferences,
                      icon: Icons.tune,
                      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.colorGrey),
                      onTap: () {},
                    ),
                    commonListTile(
                      title: CS.vPurchases,
                      icon: Icons.receipt_long,
                      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.colorGrey),
                      onTap: () {},
                    ),
                    commonListTile(title: CS.vFeedback, icon: Icons.rate_review_outlined, onTap: () {}),

                    Divider(),
                    SizedBox(height: 20),
                    Text(CS.vHelpSupport, style: AppTextStyles.body16GreySemiBold),
                    SizedBox(height: 10),

                    commonListTile(title: CS.vReportCopyright, icon: Icons.error_outline, onTap: () {}),
                    commonListTile(title: CS.vFlagInappropriate, icon: Icons.flag_outlined, onTap: () {}),
                    commonListTile(title: CS.vFAQ, icon: Icons.help_outline, onTap: () {}),
                    commonListTile(title: CS.vHelpCenter, icon: Icons.support_agent, onTap: () {}),

                    Divider(),
                    SizedBox(height: 20),
                    Text(CS.vTermsConditions, style: AppTextStyles.body16GreySemiBold),
                    SizedBox(height: 16),

                    commonListTile(title: CS.vTermsOfService, icon: Icons.description_outlined, onTap: () {}),
                    commonListTile(title: CS.vPrivacyPolicy, icon: Icons.privacy_tip_outlined, onTap: () {}),

                    Divider(),
                    SizedBox(height: 20),
                    Text(CS.vOther, style: AppTextStyles.body16GreySemiBold),
                    SizedBox(height: 16),

                    commonListTile(title: CS.vOpenSourceLicenses, icon: Icons.menu_book_outlined, onTap: () {}),

                    Divider(),
                    SizedBox(height: 20),
                    Text(CS.vDangerZone, style: AppTextStyles.body16GreySemiBold),
                    SizedBox(height: 22),

                    /// ---------- DELETE ACCOUNT ----------
                    CommonElevatedButton(
                      title: CS.vDeleteAccount,
                      onTap: () {
                        Get.toNamed(AppRoutes.deleteAccount);
                      },
                      backgroundColor: AppColors.colorRed,
                      textStyle: AppTextStyles.body16WhiteMedium,
                      radius: 30,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),

                    // SizedBox(height: 16),
                    //
                    // /// ---------- RESET PASSWORD ----------
                    // CommonElevatedButton(
                    //   title: CS.vResetPassword,
                    //   onTap: controller.onResetPasswordTap,
                    //   backgroundColor: AppColors.colorBgGray04,
                    //   textStyle: AppTextStyles.body16WhiteMedium,
                    //   radius: 30,
                    //   padding: EdgeInsets.symmetric(vertical: 15),
                    // ),
                    SizedBox(height: 16),

                    /// ---------- SIGN OUT ----------
                    CommonElevatedButton(
                      title: CS.vSignOut,
                      onTap: () {
                        showSignOutDialog();
                      },
                      backgroundColor: AppColors.colorWhite,

                      textStyle: AppTextStyles.body16BlackMedium,
                      radius: 30,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),

                    SizedBox(height: 60),
                  ],
                ).screenPadding(),
          ),
        );
      },
    );
  }
}

upgradeUltraBox() {
  return Container(
    padding: const EdgeInsets.all(20),
    // margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: AppColors.colorBgWhite10, // Deep charcoal background
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Horizontal Image List (Mocking the books in the image)
        SizedBox(
          height: 100,
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            children: [
              Image.asset(CS.imgBookCover),
              SizedBox(width: 10),
              Image.asset(CS.imgBookCover2),
              SizedBox(width: 10),
              Image.asset(CS.imgBookCover),
              SizedBox(width: 10),
              Image.asset(CS.imgBookCover2),
              SizedBox(width: 10),
              Image.asset(CS.imgBookCover),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Title
        Text(CS.vUpgradeToUltraTitle, style: AppTextStyles.heading18WhiteMedium),
        const SizedBox(height: 8),
        // Subtitle
        Text(CS.vUpgradeToUltraSubtitle, style: AppTextStyles.body14GreySemiBold),
        const SizedBox(height: 24),
        // The Pill-Shaped Action Button
        CommonElevatedButton(
          title: CS.vUpgradeToUltraButton,
          onTap: () {
            Get.toNamed(AppRoutes.subscription, arguments: true);
          },
          backgroundColor: AppColors.colorWhite,
          icon: Icons.bolt,
          // textStyle: AppTextStyles.body16BlackMedium,
          radius: 30,
          padding: EdgeInsets.symmetric(vertical: 10),
        ),
      ],
    ),
  );
}

void showSignOutDialog() {
  Get.dialog(
    Dialog(
      backgroundColor: AppColors.colorBgGray02,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),

            /// TITLE
            Text(CS.vSignOut, style: AppTextStyles.heading18WhiteMedium),
            SizedBox(height: 10),

            /// MESSAGE
            Text(CS.vSignOutMessage, style: AppTextStyles.body16GreySemiBold),
            SizedBox(height: 10),

            /// BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                /// CANCEL BUTTON
                TextButton(onPressed: () => Get.back(), child: Text(CS.vNoCancel, style: AppTextStyles.body14GreySemiBold)),

                SizedBox(width: 8),

                /// SIGN OUT BUTTON
                TextButton(
                  onPressed: () async {
                    Get.back();
                    await GoogleSignInService.signOut();
                  },
                  child: Text(CS.vYesSignOut, style: AppTextStyles.body14RedBold),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
}
