import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hangr/constants.dart';
import 'package:hangr/firebase_options.dart';
import 'package:hangr/logic/logger.dart';
import 'package:hangr/model/firebase_state.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseNotifier extends ChangeNotifier {
  bool get loggedIn => FirebaseAuth.instance.currentUser != null;
  FirebaseState state = FirebaseState.loading;

  final Completer<bool> _isInitialized = Completer();
  late FirebaseFunctions? _functions;

  FirebaseNotifier() {
    load();
  }

  Future<FirebaseFunctions> get functions async {
    final isInitialized = await _isInitialized.future;
    if (!isInitialized) {
      throw Exception('Firebase is not initialized');
    }
    return _functions!;
  }

  Future<FirebaseFirestore> get firestore async {
    final isInitialized = await _isInitialized.future;
    if (!isInitialized) {
      throw Exception('Firebase is not initialized');
    }
    return FirebaseFirestore.instance;
  }

  Future<FirebaseCrashlytics> get crashlytics async {
    final isInitialized = await _isInitialized.future;
    if (!isInitialized) {
      throw Exception('Firebase is not initialized');
    }
    return FirebaseCrashlytics.instance;
  }

  Future<FirebaseStorage> get storage async {
    final isInitialized = await _isInitialized.future;
    if (!isInitialized) {
      throw Exception('Firebase is not initialized');
    }
    return FirebaseStorage.instance;
  }

  Future<void> load() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await FirebaseAppCheck.instance.activate();
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      };
      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack);
        return true;
      };

      Isolate.current.addErrorListener(
        RawReceivePort((err) async {
          await FirebaseCrashlytics.instance.recordError(
            err,
            null,
            fatal: true,
          );
        }).sendPort,
      );

      // if (kDebugMode) {
      //   FirebaseDatabase.instance.useDatabaseEmulator('localhost', 9000);
      //   await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      // }

      _functions = FirebaseFunctions.instanceFor(region: cloudRegion);
      state = FirebaseState.available;
      _isInitialized.complete(true);
      notifyListeners();
    } on Exception catch (e, trace) {
      Logger.log('Firebase initialization error');
      Logger.reportError(trace, e);
      state = FirebaseState.notAvailable;
      _isInitialized.complete(false);
      notifyListeners();
    }
  }

  Future<User?> get user async {
    final isInitialized = await _isInitialized.future;
    if (!isInitialized) {
      throw Exception('Firebase is not initialized');
    }
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> logOut() => FirebaseAuth.instance.signOut();

  Future<User?> unlinkWithApple() async {
    return FirebaseAuth.instance.currentUser?.unlink('apple.com');
  }

  Future<User?> unlinkWithGoogle() async =>
      FirebaseAuth.instance.currentUser?.unlink('google.com');

  Future<UserCredential?> logInWithGoogle() async =>
      FirebaseAuth.instance.signInWithCredential(await _getGoogleCredential());

  Future<UserCredential?> logInWithApple() async =>
      FirebaseAuth.instance.signInWithCredential(await _getAppleCredential());

  Future<void> linkAccountWithApple() async =>
      FirebaseAuth.instance.currentUser!
          .linkWithCredential(await _getAppleCredential());

  Future<void> linkAccountWithGoogle() async =>
      FirebaseAuth.instance.currentUser!
          .linkWithCredential(await _getGoogleCredential());

  Future<AuthCredential> _getGoogleCredential() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) throw Exception;
    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    if (googleAuth.accessToken == null || googleAuth.idToken == null) {
      throw Exception('Invalid google authentication token');
    }

    // Create a new credential
    return GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  Future<AuthCredential> _getAppleCredential() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    return OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
