import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:hangr/constants.dart';
import 'package:hangr/logic/firebase_notifier.dart';
import 'package:hangr/model/past_purchase.dart';

class IAPRepo extends ChangeNotifier {
  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;

  bool get isLoggedIn => _user != null;
  User? get user => _user;
  User? _user;
  bool hasActiveSubscription = false;

  List<PastPurchase> purchases = [];

  StreamSubscription<User?>? _userSubscription;
  StreamSubscription<QuerySnapshot>? _purchaseSubscription;

  IAPRepo(FirebaseNotifier firebaseNotifier) {
    firebaseNotifier.firestore.then((value) {
      _auth = FirebaseAuth.instance;
      _firestore = value;
      updatePurchases();
      listenToLogin();
    });
  }

  void listenToLogin() {
    _user = _auth.currentUser;
    _userSubscription = FirebaseAuth.instance.userChanges().listen((user) {
      _user = user;
      updatePurchases();
      notifyListeners();
    });
  }

  void updatePurchases() {
    _purchaseSubscription?.cancel();
    final user = _user;
    if (user == null) {
      purchases = [];
      hasActiveSubscription = false;
      notifyListeners();
      return;
    }
    final purchaseStream = _firestore
        .collection('purchases')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
    _purchaseSubscription = purchaseStream.listen((snapshot) {
      purchases = snapshot.docs.map((document) {
        final data = document.data();
        return PastPurchase.fromJson(data);
      }).toList();

      hasActiveSubscription = purchases.any(
        (element) =>
            element.productId == storeKeySubscription &&
            element.status != Status.expired,
      );
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
