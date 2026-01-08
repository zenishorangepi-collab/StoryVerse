import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/create_collection_view/create_collection_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_elevated_button.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/core/common_textfield.dart';

class CreateCollectionScreen extends StatelessWidget {
  const CreateCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateCollectionController>(
      init: CreateCollectionController(),
      builder: (controller) {
        return Scaffold(
          // backgroundColor: AppColors.colorBlack.withOpacity(0.5),
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 70),
                _buildHeader(controller),

                SizedBox(height: 30),

                // Book covers illustration
                _buildIllustration(),

                SizedBox(height: 16),

                // Description
                Text(CS.vOrganizeSavedContent, textAlign: TextAlign.center, style: AppTextStyles.body16GreyRegular).paddingSymmetric(horizontal: 32),

                SizedBox(height: 32),

                // Name input
                _buildNameInput(controller),

                SizedBox(height: 32),

                // Icon picker
                _buildIconPicker(controller),

                SizedBox(height: 80),

                // Create button
                _buildCreateButton(controller),

                SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(CreateCollectionController controller) {
    final isEditing = Get.arguments != null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: AppColors.colorBgGray02, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(isEditing ? CS.vEditCollection : CS.vCreateACollection, style: AppTextStyles.heading20WhiteSemiBold),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.colorChipBackground, shape: BoxShape.circle),
              child: Icon(Icons.close, color: AppColors.colorWhite, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Center(
      child: Container(
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Book 1
            Transform.rotate(
              angle: -0.2,
              child: Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.colorTealDark,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                ),
              ),
            ),
            // Book 2
            Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.colorRed,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
              ),
            ),
            // Book 3
            Transform.rotate(
              angle: 0.2,
              child: Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.colorBrown,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameInput(CreateCollectionController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(CS.vNameYourCollection, style: AppTextStyles.body16WhiteBold).paddingSymmetric(horizontal: 24),

        SizedBox(height: 12),

        CommonTextFormField(
          controller: controller.nameController,
          hint: "",
          maxLines: 1,
          onChanged: (value) {
            if (value.trim().isEmpty) {
              controller.isContinueEnabled = false;
            } else {
              controller.isContinueEnabled = true;
            }
            controller.update();
          },
        ).paddingSymmetric(horizontal: 24),
      ],
    );
  }

  Widget _buildIconPicker(CreateCollectionController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(CS.vPickAnIcon, style: AppTextStyles.body16WhiteBold).paddingSymmetric(horizontal: 24),

        SizedBox(height: 16),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              controller.iconTypes.map((iconData) {
                final isSelected = controller.selectedIconType == iconData['type'];

                return GestureDetector(
                  onTap: () => controller.selectIcon(iconData['type']),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.colorChipBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppColors.colorWhite : Colors.transparent, width: 2),
                    ),
                    child: Icon(iconData['icon'], color: AppColors.colorWhite, size: 25),
                  ),
                );
              }).toList(),
        ).paddingSymmetric(horizontal: 24),
      ],
    );
  }

  Widget _buildCreateButton(CreateCollectionController controller) {
    return CommonElevatedButton(
      onTap:
          controller.isContinueEnabled
              ? () {
                controller.createCollection();
              }
              : null,
      // isDark: true,
      backgroundColor: controller.isContinueEnabled ? AppColors.colorWhite : AppColors.colorGrey,
      title: Get.arguments != null ? CS.vUpdateCollection : CS.vCreateCollection,
      textStyle: controller.isContinueEnabled ? AppTextStyles.button16BlackBold : AppTextStyles.body16WhiteMedium,
    ).paddingSymmetric(horizontal: 24);
  }
}
