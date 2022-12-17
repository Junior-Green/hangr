import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:hangr/constants.dart';
import 'package:hangr/logic/firebase_notifier.dart';
import 'package:hangr/model/outfit.dart';
import 'package:hangr/model/transfer_type.dart';
import 'package:hangr/model/wearable.dart';
import 'package:hangr/repo/iap_repo.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CloudStorage extends ChangeNotifier {
  late FirebaseStorage _storage;
  late final FirebaseAuth _auth;
  final FirebaseNotifier notifier;
  final MyWearables wearables;
  final IAPRepo repo;
  final MyOutfits outfits;

  bool _transferring = false;

  bool get isTransferring => _transferring;

  CloudStorage(
    this.notifier,
    this.wearables,
    this.outfits,
    this.repo,
  ) {
    notifier.storage.then((value) {
      _auth = FirebaseAuth.instance;
      Stream.periodic(
        const Duration(minutes: 2),
        _handleUpload,
      );

      return _storage = value;
    });
  }

  Future<bool> _transfer(TransferType type) async {
    final user = _auth.currentUser;
    if (user == null || _transferring) {
      return false;
    }
    final storageRef = _storage.ref();
    final Directory directory = await getTemporaryDirectory();
    final File fWearables = File('${directory.path}/$wearablesPath');
    final File fOutfits = File('${directory.path}/$wearablesPath');
    final File fCalendarMap = File('${directory.path}/$wearablesPath');
    if (!await fWearables.exists() ||
        !await fOutfits.exists() ||
        !await fCalendarMap.exists()) {
      return false;
    }
    bool res = true;

    Reference ref = storageRef.child('users/${user.uid}/data/$wearablesPath');
    res &= type == TransferType.upload
        ? await _uploadFile(fWearables, ref)
        : await _downloadFile(fWearables, ref);

    ref = storageRef.child('users/${user.uid}/data/$outfitsPath');
    res &= type == TransferType.upload
        ? await _uploadFile(fOutfits, ref)
        : await _downloadFile(fOutfits, ref);

    ref = storageRef.child('users/${user.uid}/data/$calendarMapPath');
    res &= type == TransferType.upload
        ? await _uploadFile(fCalendarMap, ref)
        : await _downloadFile(fCalendarMap, ref);

    if (!res) return false;

    for (final element in wearables.getWearables) {
      final file = File(element.imagePath);
      final fileName = basename(file.path);
      if (!await file.exists()) {
        continue;
      }
      final ref = storageRef.child(
        'users/${user.uid}/photos/$fileName',
      );
      try {
        type == TransferType.upload
            ? await _uploadFile(file, ref)
            : await _downloadFile(file, ref);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }

    for (final element in outfits.getOutfits) {
      final file = File(element.imagePath);
      final fileName = basename(file.path);
      if (!await file.exists()) {
        continue;
      }
      final ref = storageRef.child(
        'users/${user.uid}/photos/$fileName',
      );
      try {
        type == TransferType.upload
            ? await _uploadFile(file, ref)
            : await _downloadFile(file, ref);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
    return true;
  }

  Future<bool> _uploadFile(File file, Reference ref) async {
    final task = ref.putFile(file);
    return _handleTask(task);
  }

  Future<bool> _downloadFile(File file, Reference ref) async {
    final task = ref.writeToFile(file);
    return _handleTask(task);
  }

  Future<bool> _handleTask(Task task) async {
    bool result = false;
    await task.then(
      (snapshot) {
        switch (snapshot.state) {
          case TaskState.paused:
            result = false;
            break;

          case TaskState.running:
            result = false;
            break;

          case TaskState.success:
            result = true;
            break;

          case TaskState.canceled:
            result = false;
            break;

          case TaskState.error:
            result = false;
            break;
        }
      },
      onError: (error, trace) => result = false,
    );
    return result;
  }

  Future<bool> _handleUpload(int computationCount) async {
    if (!await _isEnabled()) return false;

    _transferring = true;
    notifyListeners();
    final res = await _transfer(TransferType.upload);
    _transferring = false;
    notifyListeners();

    return res;
  }

  Future<bool> download() async {
    if (!await _isEnabled()) return false;

    _transferring = true;
    notifyListeners();
    final res = await _transfer(TransferType.download);
    _transferring = false;
    notifyListeners();

    return res;
  }

  Future<bool> _isEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('backup') ?? false) &&
        _auth.currentUser != null &&
        repo.hasActiveSubscription;
  }
}
