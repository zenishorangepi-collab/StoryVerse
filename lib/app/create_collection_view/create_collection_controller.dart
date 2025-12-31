import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  @override
  void onInit() {
    super.onInit();
    // If editing existing collection, load data here
    if (Get.arguments != null && Get.arguments is CollectionModel) {
      final collection = Get.arguments as CollectionModel;
      nameController.text = collection.name;
      selectedIconType = collection.iconType;
      update();
    }
  }

  // Select icon
  void selectIcon(String iconType) {
    selectedIconType = iconType;
    update();
  }

  // Create collection
  Future<void> createCollection() async {
    try {
      isLoading = true;
      update();

      // Check if editing existing collection
      final isEditing = Get.arguments != null && Get.arguments is CollectionModel;
      final existingCollection = isEditing ? Get.arguments as CollectionModel : null;

      final collection = CollectionModel(
        id: existingCollection?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        iconType: selectedIconType,
        createdAt: existingCollection?.createdAt ?? DateTime.now(),
        bookIds: existingCollection?.bookIds ?? [],
      );

      await saveCollection(collection);

      final libraryController = Get.find<LibraryController>();
      libraryController.addCollection(collection);

      Get.back(result: collection);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create collection: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
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

  // Get all collections from preferences
  Future<List<CollectionModel>> getAllCollections() async {
    final jsonList = AppPrefs.getStringList(CS.keyCollections);
    return jsonList.map((json) => CollectionModel.fromJson(jsonDecode(json))).toList();
  }

  // Add book to collection
  Future<void> addBookToCollection(String collectionId, String bookId) async {
    final collections = await getAllCollections();
    final collectionIndex = collections.indexWhere((c) => c.id == collectionId);

    if (collectionIndex != -1) {
      final collection = collections[collectionIndex];
      if (!collection.bookIds.contains(bookId)) {
        final updatedCollection = collection.copyWith(bookIds: [...collection.bookIds, bookId]);
        collections[collectionIndex] = updatedCollection;

        final jsonList = collections.map((c) => jsonEncode(c.toJson())).toList();
        await AppPrefs.setStringList(CS.keyCollections, jsonList);
      }
    }
  }

  // Remove book from collection
  Future<void> removeBookFromCollection(String collectionId, String bookId) async {
    final collections = await getAllCollections();
    final collectionIndex = collections.indexWhere((c) => c.id == collectionId);

    if (collectionIndex != -1) {
      final collection = collections[collectionIndex];
      final updatedBookIds = collection.bookIds.where((id) => id != bookId).toList();

      final updatedCollection = collection.copyWith(bookIds: updatedBookIds);
      collections[collectionIndex] = updatedCollection;

      final jsonList = collections.map((c) => jsonEncode(c.toJson())).toList();
      await AppPrefs.setStringList(CS.keyCollections, jsonList);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
