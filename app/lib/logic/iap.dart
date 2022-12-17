import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hangr/constants.dart';
import 'package:hangr/logic/firebase_notifier.dart';
import 'package:hangr/model/purchasable_product.dart';
import 'package:hangr/model/store_state.dart';
import 'package:hangr/repo/iap_repo.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IAP extends ChangeNotifier {
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final IAPRepo iapRepo;
  final iapConnection = InAppPurchase.instance;
  StoreState storeState = StoreState.notAvailable;
  List<PurchasableProduct> products = [];
  FirebaseNotifier firebaseNotifier;

  IAP(this.firebaseNotifier, this.iapRepo) {
    final purchaseUpdated = iapConnection.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );
    iapRepo.addListener(purchasesUpdate);
    loadPurchases();
    storeState = StoreState.loading;
  }

  Future<void> buy(PurchasableProduct product) async {
    final purchaseParam = PurchaseParam(productDetails: product.productDetails);
    switch (product.id) {
      case storeKeySubscription:
        await iapConnection.buyNonConsumable(purchaseParam: purchaseParam);
        break;
      default:
        throw ArgumentError.value(
          product.productDetails,
          '${product.id} is not a known product',
        );
    }
  }

  @override
  void dispose() {
    iapRepo.removeListener(purchasesUpdate);
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _onPurchaseUpdate(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      await _handlePurchase(purchaseDetails);
    }
    notifyListeners();
  }

  void _updateStreamOnDone() {
    _subscription.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    debugPrint(error.toString());
  }

  Future<void> loadPurchases() async {
    final available = await iapConnection.isAvailable();
    if (!available) {
      storeState = StoreState.notAvailable;
      notifyListeners();
      return;
    }
    try {
      await firebaseNotifier.functions;
    } catch (e) {
      storeState = StoreState.notAvailable;
      notifyListeners();
      return;
    }

    const ids = <String>{storeKeySubscription};
    final response = await iapConnection.queryProductDetails(ids);
    for (final element in response.notFoundIDs) {
      debugPrint('Purchase $element not found');
    }
    products =
        response.productDetails.map((e) => PurchasableProduct(e)).toList();
    storeState = StoreState.available;
    notifyListeners();
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.purchased) {
      // Send to server
      final validPurchase = await _verifyPurchase(purchaseDetails);

      if (validPurchase) {
        switch (purchaseDetails.productID) {
          case storeKeySubscription:
            _updateUserSubscription();
            break;
        }
      }
    }

    if (purchaseDetails.pendingCompletePurchase) {
      await iapConnection.completePurchase(purchaseDetails);
    }
  }

  Future<void> _updateUserSubscription() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (firebaseNotifier.loggedIn) {
      await prefs.setBool('is_premium_user', iapRepo.hasActiveSubscription);
    }
    if (!firebaseNotifier.loggedIn || !iapRepo.hasActiveSubscription) {
      prefs.setBool('is_premium_user', false);
      if ((prefs.getInt('camera_quality') ?? 0) == 100) {
        await prefs.setInt('camera_quality', 75);
      }
      prefs.setBool('backup', false);
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    final functions = await firebaseNotifier.functions;
    final callable = functions.httpsCallable('verifyPurchase');
    final results = await callable({
      'source': purchaseDetails.verificationData.source,
      'verificationData':
          purchaseDetails.verificationData.serverVerificationData,
      'productId': purchaseDetails.productID,
    });
    return results.data as bool;
  }

  void purchasesUpdate() {
    List<PurchasableProduct> subscriptions = <PurchasableProduct>[];
    // Get a list of purchasable products for the subscription and upgrade.
    // This should be 1 per type.
    if (products.isNotEmpty) {
      subscriptions = products
          .where((element) => element.productDetails.id == storeKeySubscription)
          .toList();
    }

    // Set the subscription in the counter logic and show/hide purchased on the
    // purchases page.
    if (iapRepo.hasActiveSubscription) {
      for (final element in subscriptions) {
        _updateStatus(element, ProductStatus.purchased);
      }
    } else {
      for (final element in subscriptions) {
        _updateStatus(element, ProductStatus.purchasable);
      }
    }
    _updateUserSubscription();
    notifyListeners();
  }

  void _updateStatus(PurchasableProduct product, ProductStatus status) {
    if (product.status != status) {
      product.status = status;
      notifyListeners();
    }
  }
}
