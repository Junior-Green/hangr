import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hangr/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

Future<void> initializeFireBase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user == null) {
      print('User is currently signed out!');
      await _handleUserSignOut();
    } else {
      //TODO: make query to firestore and check if they are premium. If they are set prefs to proper config.
      print('User is signed in!');
      _handleUserSignIn();
    }

    FirebaseAuth.instance.idTokenChanges().listen((User? user) async {
      if (user == null) {
        print('User is currently signed out!');
        await _handleUserSignOut();
      } else {
        //TODO: make query to firestore and check if they are premium. If they are set prefs to proper config.
        print('User is signed in!');

        _handleUserSignIn();
      }
    });

    FirebaseAuth.instance.userChanges().listen((User? user) async {
      if (user == null) {
        print('User is currently signed out!');
        await _handleUserSignOut();
      } else {
        //TODO: make query to firestore and check if they are premium. If they are set prefs to proper config.
        print('User is signed in!');

        await _handleUserSignIn();
      }
    });
  });
}

User? get user => FirebaseAuth.instance.currentUser;

Future<void> logOut() => FirebaseAuth.instance.signOut();

Future<User?> unlinkWithApple() async =>
    FirebaseAuth.instance.currentUser?.unlink('apple.com');

Future<User?> unlinkWithGoogle() async =>
    FirebaseAuth.instance.currentUser?.unlink('google.com');

Future<UserCredential?> logInWithGoogle() async {
  try {
    return FirebaseAuth.instance
        .signInWithCredential(await _getGoogleCredential());
  } on Exception catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
  return null;
}

Future<UserCredential?> logInWithApple() async =>
    FirebaseAuth.instance.signInWithCredential(await _getAppleCredential());

Future<void> linkAccountWithApple() async => FirebaseAuth.instance.currentUser!
    .linkWithCredential(await _getAppleCredential());

Future<void> linkAccountWithGoogle() async => FirebaseAuth.instance.currentUser!
    .linkWithCredential(await _getGoogleCredential());

Future<AuthCredential> _getGoogleCredential() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;
  // Create a new credential
  return GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
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

Future<void> _handleUserSignIn() async {}

Future<void> _handleUserSignOut() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('is_premium_member', false);
  if ((prefs.getInt('camera_quality') ?? 0) == 100) {
    await prefs.setInt('camera_quality', 75);
  }
  if (prefs.getBool('backup') ?? false) {
    prefs.setBool('backup', false);
  }
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
