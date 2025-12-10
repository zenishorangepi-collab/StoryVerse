import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/core/common_textfield.dart';

Future<Map<String, String>?> showLanguageBottomSheet(BuildContext context, {String? selectedLanguage}) {
  return showModalBottomSheet<Map<String, String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.colorBgGray02,
    useSafeArea: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
    builder: (context) {
      return SizedBox(height: MediaQuery.of(context).size.height * 0.92, child: _LanguageBottomSheet(selectedLanguage: selectedLanguage));
    },
  );
}

class _LanguageBottomSheet extends StatefulWidget {
  final String? selectedLanguage;

  const _LanguageBottomSheet({super.key, this.selectedLanguage});

  @override
  State<_LanguageBottomSheet> createState() => _LanguageBottomSheetState();
}

class _LanguageBottomSheetState extends State<_LanguageBottomSheet> {
  TextEditingController searchController = TextEditingController();

  List<Map<String, String>> allLanguages = [
    {"name": "English", "flag": "🇬🇧"},
    {"name": "Arabic", "flag": "🇸🇦"},
    {"name": "Bulgarian", "flag": "🇧🇬"},
    {"name": "Chinese", "flag": "🇨🇳"},
    {"name": "Croatian", "flag": "🇭🇷"},
    {"name": "Czech", "flag": "🇨🇿"},
    {"name": "Danish", "flag": "🇩🇰"},
    {"name": "Dutch", "flag": "🇳🇱"},
    {"name": "Filipino", "flag": "🇵🇭"},
    {"name": "Finnish", "flag": "🇫🇮"},
    {"name": "French", "flag": "🇫🇷"},
    {"name": "German", "flag": "🇩🇪"},
    {"name": "Greek", "flag": "🇬🇷"},
    {"name": "Hindi", "flag": "🇮🇳"},
    {"name": "Hungarian", "flag": "🇭🇺"},
    {"name": "Indonesian", "flag": "🇮🇩"},
    {"name": "Italian", "flag": "🇮🇹"},
    {"name": "Japanese", "flag": "🇯🇵"},
    {"name": "Korean", "flag": "🇰🇷"},
    {"name": "Malay", "flag": "🇲🇾"},
    {"name": "Norwegian", "flag": "🇳🇴"},
    {"name": "Polish", "flag": "🇵🇱"},
    {"name": "Portuguese", "flag": "🇵🇹"},
    {"name": "Romanian", "flag": "🇷🇴"},
    {"name": "Russian", "flag": "🇷🇺"},
    {"name": "Slovak", "flag": "🇸🇰"},
    {"name": "Spanish", "flag": "🇪🇸"},
    {"name": "Swedish", "flag": "🇸🇪"},
    {"name": "Tamil", "flag": "🇮🇳"},
    {"name": "Turkish", "flag": "🇹🇷"},
    {"name": "Ukrainian", "flag": "🇺🇦"},
    {"name": "Vietnamese", "flag": "🇻🇳"},
  ];

  List<Map<String, String>> filteredLanguages = [];

  @override
  void initState() {
    super.initState();
    filteredLanguages = List.from(allLanguages);

    searchController.addListener(() {
      final query = searchController.text.toLowerCase();

      setState(() {
        filteredLanguages = allLanguages.where((lang) => lang["name"]!.toLowerCase().contains(query)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SizedBox(height: 8),
            // Container(width: 50, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10))),
            // SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.colorDialogHeaderGray,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(CS.vFilters, style: AppTextStyles.heading3),
                  commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 12, padding: 12),
                ],
              ),
            ),

            SizedBox(height: 10),

            /// SEARCH BAR
            CommonTextFormField(
              controller: searchController,
              hint: CS.vSearchDot,
              prefix: Image.asset(CS.icSearch, scale: 25, color: AppColors.colorWhite),
            ).paddingSymmetric(horizontal: 20),

            SizedBox(height: 10),

            /// LANGUAGE LIST
            Expanded(
              child: ListView.builder(
                itemCount: filteredLanguages.length,
                itemBuilder: (context, index) {
                  final lang = filteredLanguages[index];
                  final isSelected = lang["name"] == widget.selectedLanguage;

                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    shape: Border(bottom: BorderSide(color: AppColors.colorWhite, width: 0.5)),
                    leading: Text(lang["flag"]!, style: TextStyle(fontSize: 22)),
                    title: Text(lang["name"]!, style: AppTextStyles.bodyLarge),
                    trailing: isSelected ? Icon(Icons.check_circle, color: AppColors.colorWhite) : null,
                    onTap: () {
                      Navigator.pop(context, {"name": lang["name"]!, "flag": lang["flag"]!});
                    },
                  ).paddingSymmetric(horizontal: 20);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
