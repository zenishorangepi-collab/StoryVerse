import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/add_collection_view/add_collection_controller.dart';
import 'package:utsav_interview/app/create_collection_view/create_collection_model.dart';
import 'package:utsav_interview/app/library_view/library_controller.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/pref.dart';

class CreateCollectionController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  bool isContinueEnabled = false;

  // Selected icon type
  String selectedIconType = 'folder';

  // Available icon types
  final List<Map<String, dynamic>> iconTypes = [
    {'type': 'folder', 'icon': Icons.folder_outlined},
    {'type': 'bookmark', 'icon': Icons.bookmark_outline},
    {'type': 'edit', 'icon': Icons.edit_outlined},
    {'type': 'article', 'icon': Icons.article_outlined},
    {'type': 'mic', 'icon': Icons.mic_outlined},
    {'type': 'photo', 'icon': Icons.photo_outlined},
    {'type': 'star', 'icon': Icons.star_outline},
    {'type': 'palette', 'icon': Icons.palette_outlined},
    {'type': 'music', 'icon': Icons.music_note_outlined},
    {'type': 'restaurant', 'icon': Icons.restaurant_outlined},
  ];

  // Loading state
  bool isLoading = false;
  bool isAddingBookToCollection = false;
  bool isEditMode = false;
  CollectionModel? existingCollection;
  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;

      // Check for isAddingBookToCollection
      isAddingBookToCollection = args["isAddingBookToCollection"] ?? false;

      // Check for collection (edit mode)
      final collection = args["collection"];
      if (collection != null && collection is CollectionModel) {
        isEditMode = true;
        existingCollection = collection;

        // Pre-fill the form
        nameController.text = existingCollection!.name;
        selectedIconType = existingCollection!.iconType;
      }
    }
  }

  // Select icon
  void selectIcon(String iconType) {
    selectedIconType = iconType;
    update();
  }

  // Create or Update collection
  Future<void> createCollection() async {
    try {
      isLoading = true;
      update();

      final collection = CollectionModel(
        id: existingCollection?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        iconType: selectedIconType,
        createdAt: existingCollection?.createdAt ?? DateTime.now(),
        bookIds: existingCollection?.bookIds ?? [],
      );

      await saveCollection(collection);

      if (isAddingBookToCollection) {
        final addToCollectionController = Get.find<AddToCollectionController>();
        addToCollectionController.addCollection(collection);
      } else {
        final libraryController = Get.find<LibraryController>();
        if (isEditMode) {
          libraryController.updateCollection(collection);
        } else {
          libraryController.addCollection(collection);
        }
      }

      Get.back(result: collection);

      // Show success message
      // Get.snackbar(
      //   isEditMode ? 'Updated' : 'Created',
      //   isEditMode ? 'Collection updated successfully' : 'Collection created successfully',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      // );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to ${isEditMode ? 'update' : 'create'} collection: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  // Save collection to preferences
  Future<void> saveCollection(CollectionModel collection) async {
    final collections = await getAllCollections();

    // Check if collection already exists (for update)
    final existingIndex = collections.indexWhere((c) => c.id == collection.id);

    if (existingIndex != -1) {
      // Update existing
      collections[existingIndex] = collection;
    } else {
      // Add new
      collections.add(collection);
    }

    // Save to preferences
    final jsonList = collections.map((c) => jsonEncode(c.toJson())).toList();
    await AppPrefs.setStringList(CS.keyCollections, jsonList);
  }

  // Get all collections
  Future<List<CollectionModel>> getAllCollections() async {
    final jsonList = await AppPrefs.getStringList(CS.keyCollections) ?? [];
    return jsonList.map((json) => CollectionModel.fromJson(jsonDecode(json))).toList();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
