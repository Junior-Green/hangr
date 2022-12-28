import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

// ignore: avoid_classes_with_only_static_members
class Logger {
  static void log(String message) {
    if (kDebugMode) {
      print(message);
    } else {
      FirebaseCrashlytics.instance.log(message);
    }
  }

  static void reportError([StackTrace? trace, Exception? e]) {
    if (kDebugMode) {
      print(e);
    } else {
      FirebaseCrashlytics.instance.recordError(e, trace);
    }
  }
}
