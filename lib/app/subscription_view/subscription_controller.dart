import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/pref.dart';
import 'package:utsav_interview/routes/app_routes.dart';

enum SubscriptionPlan { yearly, monthly, free }
enum SubscriptionStatus { active, expired, trial, none }

class SubscriptionController extends GetxController {
  // In-App Purchase
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  bool _isLoading = false;

  // Product IDs (replace with your actual product IDs from Play Console/App Store)
  static const String yearlyProductId = 'ultra_yearly_subscription';
  static const String monthlyProductId = 'ultra_monthly_subscription';

  // Current selected plan
  SubscriptionPlan selectedPlan = SubscriptionPlan.yearly;

  // Current subscription status
  SubscriptionStatus currentStatus = SubscriptionStatus.none;

  // Subscription details
  String? currentPlanName;
  DateTime? subscriptionStartDate;
  DateTime? subscriptionEndDate;
  bool isTrialActive = false;
  int trialDaysRemaining = 0;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;

  @override
  void onInit() {
    super.onInit();
    _initializeInAppPurchase();
    _loadSubscriptionStatus();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  // ============================================================
  // INITIALIZE IN-APP PURCHASE
  // ============================================================
  Future<void> _initializeInAppPurchase() async {
    try {
      // Check if In-App Purchase is available
      _isAvailable = await _inAppPurchase.isAvailable();

      if (!_isAvailable) {
        print('❌ In-App Purchase not available');
        return;
      }

      // Listen to purchase updates
      final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) => print('❌ Purchase Stream Error: $error'),
      );

      // Load products
      await _loadProducts();

      // Restore previous purchases
      await _restorePurchases();

      update();
    } catch (e) {
      print('❌ Error initializing In-App Purchase: $e');
    }
  }

  // ============================================================
  // LOAD PRODUCTS
  // ============================================================
  Future<void> _loadProducts() async {
    try {
      _isLoading = true;
      update();

      final Set<String> productIds = {yearlyProductId, monthlyProductId};

      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        print('⚠️ Products not found: ${response.notFoundIDs}');
      }

      if (response.error != null) {
        print('❌ Error loading products: ${response.error}');
        _isLoading = false;
        update();
        return;
      }

      _products = response.productDetails;
      print('✅ Loaded ${_products.length} products');

      _isLoading = false;
      update();
    } catch (e) {
      print('❌ Error loading products: $e');
      _isLoading = false;
      update();
    }
  }

  // ============================================================
  // HANDLE PURCHASE UPDATES
  // ============================================================
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      print('📦 Purchase Status: ${purchaseDetails.status}');

      if (purchaseDetails.status == PurchaseStatus.pending) {
        _showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _verifyAndDeliverProduct(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  // ============================================================
  // VERIFY AND DELIVER PRODUCT
  // ============================================================
  Future<void> _verifyAndDeliverProduct(PurchaseDetails purchaseDetails) async {
    try {
      // TODO: Verify purchase with your backend server
      // This is crucial for security - never trust client-side verification alone

      final productId = purchaseDetails.productID;
      final now = DateTime.now();
      DateTime endDate;
      SubscriptionPlan plan;

      if (productId == yearlyProductId) {
        plan = SubscriptionPlan.yearly;
        endDate = now.add(Duration(days: 365));
      } else if (productId == monthlyProductId) {
        plan = SubscriptionPlan.monthly;
        endDate = now.add(Duration(days: 30));
      } else {
        print('⚠️ Unknown product ID: $productId');
        return;
      }

      // Save subscription
      await _saveSubscription(
        plan: plan,
        status: SubscriptionStatus.active,
        startDate: now,
        endDate: endDate,
        isTrial: false,
      );

      // Show success message
      Get.snackbar(
        '✅ Success',
        'Subscription activated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );

      // Close subscription screen
      if (Get.isDialogOpen ?? false) Get.back();
      Get.back();

      update();
    } catch (e) {
      print('❌ Error verifying purchase: $e');
    }
  }

  // ============================================================
  // SELECT PLAN
  // ============================================================
  void selectPlan(SubscriptionPlan plan) {
    selectedPlan = plan;
    update();
  }

  // ============================================================
  // UPGRADE TO ULTRA (PURCHASE)
  // ============================================================
  Future<void> onUpgrade() async {
    try {
      if (!_isAvailable) {
        Get.snackbar(
          '❌ Error',
          'In-App Purchase is not available on this device.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (_products.isEmpty) {
        Get.snackbar(
          '⚠️ Loading',
          'Products are still loading. Please wait...',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Find the selected product
      final productId = selectedPlan == SubscriptionPlan.yearly
          ? yearlyProductId
          : monthlyProductId;

      final ProductDetails? product = _products.firstWhereOrNull(
            (p) => p.id == productId,
      );

      if (product == null) {
        Get.snackbar(
          '❌ Error',
          'Product not found. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Show loading
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Create purchase param
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: null, // Optional: user identifier for your backend
      );

      // Buy subscription
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      // Close loading (will be closed by _onPurchaseUpdate if successful)
      if (!success) {
        if (Get.isDialogOpen ?? false) Get.back();
        Get.snackbar(
          '❌ Error',
          'Failed to initiate purchase. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        '❌ Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('❌ Error in onUpgrade: $e');
    }
  }

  // ============================================================
  // RESTORE PURCHASES
  // ============================================================
  Future<void> _restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      print('✅ Restore purchases initiated');
    } catch (e) {
      print('❌ Error restoring purchases: $e');
    }
  }

  Future<void> restorePurchase() async {
    try {
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _restorePurchases();

      // Wait a bit for the restore to complete
      await Future.delayed(Duration(seconds: 2));

      Get.back();

      if (hasActiveSubscription()) {
        Get.snackbar(
          '✅ Restored',
          'Your subscription has been restored!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'ℹ️ No Subscription Found',
          'No active subscription found to restore.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        '❌ Error',
        'Failed to restore purchases.',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('❌ Error restoring: $e');
    }
  }

  void onContinueFree() {
    Get.offAllNamed(AppRoutes.tabBarScreen);
  }
  // ============================================================
  // CONTINUE FREE (TRIAL)
  // ============================================================
  // Future<void> onContinueFree() async {
  //   try {
  //     final hasUsedTrial = AppPrefs.getBool(CS.keyHasUsedTrial);
  //
  //     if (!hasUsedTrial) {
  //       // Activate 7-day trial
  //       final now = DateTime.now();
  //       final endDate = now.add(Duration(days: 7));
  //
  //       await _saveSubscription(
  //         plan: SubscriptionPlan.free,
  //         status: SubscriptionStatus.trial,
  //         startDate: now,
  //         endDate: endDate,
  //         isTrial: true,
  //       );
  //
  //       await AppPrefs.setBool(CS.keyHasUsedTrial, true);
  //
  //       Get.snackbar(
  //         '🎉 Trial Activated',
  //         'Enjoy 7 days of free access!',
  //         snackPosition: SnackPosition.BOTTOM,
  //         duration: Duration(seconds: 3),
  //       );
  //     } else {
  //       // Continue with free version
  //       await _saveSubscription(
  //         plan: SubscriptionPlan.free,
  //         status: SubscriptionStatus.none,
  //         startDate: DateTime.now(),
  //         endDate: DateTime.now(),
  //         isTrial: false,
  //       );
  //     }
  //
  //     Get.back();
  //     update();
  //   } catch (e) {
  //     print('❌ Error continuing free: $e');
  //   }
  // }

  // ============================================================
  // UI HELPERS
  // ============================================================
  void _showPendingUI() {
    Get.dialog(
      Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );
  }

  void _handleError(IAPError error) {
    if (Get.isDialogOpen ?? false) Get.back();

    Get.snackbar(
      '❌ Purchase Failed',
      error.message,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
    );
  }

  // ============================================================
  // LOAD SUBSCRIPTION STATUS
  // ============================================================
  Future<void> _loadSubscriptionStatus() async {
    try {
      final statusString = AppPrefs.getString(CS.keySubscriptionStatus);
      final planString = AppPrefs.getString(CS.keySubscriptionPlan);
      final startDateString = AppPrefs.getString(CS.keySubscriptionStartDate);
      final endDateString = AppPrefs.getString(CS.keySubscriptionEndDate);
      final isTrialString = AppPrefs.getBool(CS.keyIsTrialActive);

      if (statusString.isNotEmpty) {
        currentStatus = SubscriptionStatus.values.firstWhere(
              (e) => e.toString() == statusString,
          orElse: () => SubscriptionStatus.none,
        );
      }

      if (planString.isNotEmpty) {
        final plan = SubscriptionPlan.values.firstWhere(
              (e) => e.toString() == planString,
          orElse: () => SubscriptionPlan.free,
        );
        selectedPlan = plan;
        currentPlanName = _getPlanDisplayName(plan);
      }

      if (startDateString.isNotEmpty) {
        subscriptionStartDate = DateTime.parse(startDateString);
      }
      if (endDateString.isNotEmpty) {
        subscriptionEndDate = DateTime.parse(endDateString);
      }

      isTrialActive = isTrialString;

      if (isTrialActive && subscriptionEndDate != null) {
        final now = DateTime.now();
        final difference = subscriptionEndDate!.difference(now);
        trialDaysRemaining = difference.inDays > 0 ? difference.inDays : 0;

        if (trialDaysRemaining == 0) {
          isTrialActive = false;
          await _updateSubscriptionStatus(SubscriptionStatus.expired);
        }
      }

      if (subscriptionEndDate != null && DateTime.now().isAfter(subscriptionEndDate!)) {
        await _updateSubscriptionStatus(SubscriptionStatus.expired);
      }

      update();
    } catch (e) {
      print('❌ Error loading subscription: $e');
    }
  }

  // ============================================================
  // SAVE SUBSCRIPTION
  // ============================================================
  Future<void> _saveSubscription({
    required SubscriptionPlan plan,
    required SubscriptionStatus status,
    required DateTime startDate,
    required DateTime endDate,
    required bool isTrial,
  }) async {
    await AppPrefs.setString(CS.keySubscriptionPlan, plan.toString());
    await AppPrefs.setString(CS.keySubscriptionStatus, status.toString());
    await AppPrefs.setString(CS.keySubscriptionStartDate, startDate.toIso8601String());
    await AppPrefs.setString(CS.keySubscriptionEndDate, endDate.toIso8601String());
    await AppPrefs.setBool(CS.keyIsTrialActive, isTrial);

    selectedPlan = plan;
    currentStatus = status;
    currentPlanName = _getPlanDisplayName(plan);
    subscriptionStartDate = startDate;
    subscriptionEndDate = endDate;
    isTrialActive = isTrial;

    if (isTrial) {
      final difference = endDate.difference(DateTime.now());
      trialDaysRemaining = difference.inDays > 0 ? difference.inDays : 0;
    }
  }

  Future<void> _updateSubscriptionStatus(SubscriptionStatus status) async {
    currentStatus = status;
    await AppPrefs.setString(CS.keySubscriptionStatus, status.toString());
    update();
  }

  // ============================================================
  // SUBSCRIPTION CHECKS
  // ============================================================
  bool hasActiveSubscription() {
    return currentStatus == SubscriptionStatus.active ||
        currentStatus == SubscriptionStatus.trial;
  }

  bool canAccessPremiumFeatures() {
    return hasActiveSubscription();
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================
  String _getPlanDisplayName(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.yearly:
        return 'Ultra Yearly';
      case SubscriptionPlan.monthly:
        return 'Ultra Monthly';
      case SubscriptionPlan.free:
        return 'Free';
    }
  }

  String getPlanPrice(SubscriptionPlan plan) {
    final product = _products.firstWhereOrNull(
          (p) => p.id == (plan == SubscriptionPlan.yearly ? yearlyProductId : monthlyProductId),
    );

    if (product != null) {
      return product.price;
    }

    return plan == SubscriptionPlan.yearly ? '₹9,900.00 / yr' : '₹999.00 / mo';
  }

  String getSubscriptionStatusText() {
    if (isTrialActive) {
      return 'Trial - $trialDaysRemaining days remaining';
    }

    switch (currentStatus) {
      case SubscriptionStatus.active:
        return 'Active - ${currentPlanName ?? 'Premium'}';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.trial:
        return 'Trial Active';
      case SubscriptionStatus.none:
        return 'Free Version';
    }
  }
}