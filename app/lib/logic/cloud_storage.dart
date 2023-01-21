// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:hangr/constants.dart';
import 'package:hangr/logic/file_handler.dart';
import 'package:hangr/logic/firebase_notifier.dart';
import 'package:hangr/logic/logger.dart';
import 'package:hangr/model/calendar_map.dart';
import 'package:hangr/model/outfit.dart';
import 'package:hangr/model/wearable.dart';
import 'package:hangr/repo/iap_repo.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CloudStorage extends ChangeNotifier {
  late final FirebaseStorage _storage;
  late final String _directoryPath;
  late final StreamSubscription<User?> _userSubscription;
  final FirebaseNotifier notifier;
  final IAPRepo repo;
  final MyWearables wearables;
  final MyOutfits outfits;
  final CalendarMap calendarMap;

  bool _isSyncing = false;

  bool get isSyncing => _isSyncing;

  CloudStorage(
    this.notifier,
    this.wearables,
    this.outfits,
    this.calendarMap,
    this.repo,
  ) {
    init().then((value) {
      _handleSyncing(repo.user);
    });
    _userSubscription = repo.userStream.listen(_handleSyncing);
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    super.dispose();
  }

  Future<void> init() async {
    _storage = await notifier.storage;
    _directoryPath =
        await getTemporaryDirectory().then<String>((value) => value.path);
  }

  Future<void> syncStorage() async {
    final user = repo.user;
    if (user == null || !await _isEnabled() || _isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    try {
      Logger.log('Syncing wearables...');
      await _syncWearables(user);
      Logger.log('Syncing wearables complete');
      Logger.log('Syncing outfits...');
      await _syncOutfits(user);
      Logger.log('Syncing outfits complete');
      Logger.log('Syncing calendar map');
      await _syncCalendarMap(user);
      Logger.log('Syncing calendar map complete');
    } on Exception catch (e) {
      Logger.log(e.toString());
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _syncWearables(User user) async {
    final Directory tempDir = await Directory('$_directoryPath/temp').create();
    await Directory('${tempDir.path}/data').create();
    await Directory('${tempDir.path}/photos').create();
    final FileHandler handler = FileHandler.path(tempDir.path);
    final storageRef = _storage.ref();
    final tempWearables =
        await File('$_directoryPath/temp/data/$wearablesPath').create();
    if (!await tempWearables.exists()) {
      await tempDir.delete(recursive: true).catchError((e) {
        Logger.log(e.toString());
      });
      return;
    }

    //Retrieve wearables from cloud and merge with local storage
    try {
      final ref = storageRef.child('users/${user.uid}/data/$wearablesPath');
      await _downloadFile(tempWearables, ref);
      final downloadedWearables = await handler.readWearables();

      for (final wearable in downloadedWearables) {
        final fileName = basename(wearable.imagePath);
        final imagePath = '$_directoryPath/photos/$fileName';
        final downloadedImage = File('$_directoryPath/temp/photos/$fileName');
        final Reference imageRef =
            storageRef.child('users/${user.uid}/photos/$fileName');

        bool res = false;

        try {
          final meta = await imageRef.getMetadata();

          if (meta.contentType == 'image/jpeg' &&
              !await File(imagePath).exists()) {
            res = await _downloadFile(downloadedImage, imageRef);
          }

          final newWearable = Wearable(
            wearable.id,
            wearable.type,
            wearable.brand,
            wearable.primaryColor,
            imagePath,
            wearable.name,
            wearable.timeCreated,
            wearable.last,
            wearable.times,
          );
          newWearable.isUploaded = true;
          await wearables.addWearable(newWearable);
          if (res) await downloadedImage.copy(imagePath);
        } catch (_) {
          continue;
        }
      }
    } on FirebaseException catch (e, trace) {
      Logger.log(e.toString());
      if (e.code != 'object-not-found') {
        Logger.reportError(trace, e);
        await tempDir.delete(recursive: true).catchError((e) {
          Logger.log(e.toString());
        });
        return;
      }
    } on Exception catch (e, trace) {
      Logger.reportError(trace, e);
      await tempDir.delete(recursive: true).catchError((e) {
        Logger.log(e.toString());
      });
      return;
    }

    //Upload local wearables to cloud
    try {
      final ref = storageRef.child('users/${user.uid}/data/$wearablesPath');
      final fWearable = File('$_directoryPath/data/$wearablesPath');

      if (await fWearable.exists()) {
        final res = await _uploadFile(fWearable, ref);
        if (!res) {
          await tempDir.delete(recursive: true).catchError((e) {
            Logger.log(e.toString());
          });
          return;
        }
      }

      for (final wearable in wearables.getWearables) {
        final image = File(wearable.imagePath);
        final fileName = basename(wearable.imagePath);
        final ref = storageRef.child('users/${user.uid}/photos/$fileName');
        if (await image.exists()) {
          await ref.getMetadata().onError((e, trace) async {
            await _uploadFile(image, ref);
            return FullMetadata({});
          });
        }
      }
    } on Exception catch (e) {
      Logger.log(e.toString());
    }

    await tempDir.delete(recursive: true).catchError((e) {
      Logger.log(e.toString());
    });
  }

  Future<void> _syncOutfits(User user) async {
    final Directory tempDir = await Directory('$_directoryPath/temp').create();
    await Directory('${tempDir.path}/data').create();
    await Directory('${tempDir.path}/photos').create();
    final FileHandler handler = FileHandler.path(tempDir.path);
    final storageRef = _storage.ref();
    final tempOutfits =
        await File('$_directoryPath/temp/data/$outfitsPath').create();
    if (!await tempOutfits.exists()) {
      await tempDir.delete(recursive: true).catchError((e) {
        Logger.log(e.toString());
      });
      return;
    }

    //Retrieve wearables from cloud and merge with local storage
    try {
      final ref = storageRef.child('users/${user.uid}/data/$outfitsPath');
      await _downloadFile(tempOutfits, ref);
      final downloadedOutfits = await handler.readOutfits();

      for (final outfit in downloadedOutfits) {
        for (final id in outfit.wearableIds) {
          if (!wearables.getWearables.any((wearable) => wearable.id == id)) {
            continue;
          }
        }
        final fileName = basename(outfit.imagePath);
        final imagePath = '$_directoryPath/photos/$fileName';
        final downloadedImage = File('$_directoryPath/temp/photos/$fileName');
        final Reference imageRef =
            storageRef.child('users/${user.uid}/photos/$fileName');
        bool res = false;

        try {
          final meta = await imageRef.getMetadata();
          if (meta.contentType == 'image/jpeg') {
            res = await _downloadFile(downloadedImage, imageRef);
          }

          final newOutfit = Outfit(
            outfit.id,
            outfit.wearableIds,
            outfit.type,
            outfit.name,
            outfit.primaryColor,
            outfit.secondaryColor,
            imagePath,
            outfit.timeMade,
          );
          outfit.isUploaded = true;
          await outfits.addOutfit(newOutfit);
          if (res) await downloadedImage.copy(imagePath);
        } catch (_) {
          continue;
        }
      }
    } on FirebaseException catch (e, trace) {
      Logger.log(e.toString());
      if (e.code != 'object-not-found') {
        Logger.reportError(trace, e);
        await tempDir.delete(recursive: true).catchError((e) {
          Logger.log(e.toString());
        });
        return;
      }
    } on Exception catch (e, trace) {
      Logger.reportError(trace, e);
      await tempDir.delete(recursive: true).catchError((e) {
        Logger.log(e.toString());
      });
      return;
    }

    //Upload local outfits to cloud
    try {
      final ref = storageRef.child('users/${user.uid}/data/$outfitsPath');
      final fOutfit = File('$_directoryPath/data/$outfitsPath');

      if (await fOutfit.exists()) {
        final res = await _uploadFile(fOutfit, ref);
        if (!res) {
          await tempDir.delete(recursive: true).catchError((e) {
            Logger.log(e.toString());
          });
          return;
        }
      }

      for (final outfit in outfits.getOutfits) {
        final image = File(outfit.imagePath);
        final fileName = basename(outfit.imagePath);
        final ref = storageRef.child('users/${user.uid}/photos/$fileName');
        if (await image.exists()) {
          await _uploadFile(image, ref);
        }
      }
    } on Exception catch (e) {
      Logger.log(e.toString());
    }

    await tempDir.delete(recursive: true).catchError((e) {
      Logger.log(e.toString());
    });
  }

  Future<void> _syncCalendarMap(User user) async {
    final Directory tempDir = await Directory('$_directoryPath/temp').create();
    await Directory('${tempDir.path}/data').create();
    final tempCalMap =
        await File('${tempDir.path}/data/$calendarMapPath').create();

    final FileHandler handler = FileHandler.path(tempDir.path);
    final storageRef = _storage.ref();

    if (!await tempCalMap.exists()) {
      await tempDir.delete(recursive: true).catchError((e) {
        Logger.log(e.toString());
      });
      return;
    }

    //Retrieve wearables from cloud and merge with local storage
    try {
      final ref = storageRef.child('users/${user.uid}/data/$calendarMapPath');
      await _downloadFile(tempCalMap, ref);
      final downloadedCalMap = await handler.readCalendarMap();
      downloadedCalMap.entries.forEach(
        (entry) async {
          if (entry.value.isEmpty) return;
          await calendarMap.updateOutfit(entry.key, entry.value);
        },
      );
    } on FirebaseException catch (e, trace) {
      Logger.log(e.toString());
      if (e.code != 'object-not-found') {
        Logger.reportError(trace, e);
        await tempDir.delete(recursive: true).catchError((e) {
          Logger.log(e.toString());
        });
        return;
      }
    } on Exception catch (e, trace) {
      Logger.reportError(trace, e);
      await tempDir.delete(recursive: true).catchError((e) {
        Logger.log(e.toString());
      });
      return;
    }

    //Upload local wearables to cloud
    try {
      final ref = storageRef.child('users/${user.uid}/data/$calendarMapPath');
      final fCalMap = File('$_directoryPath/data/$calendarMapPath');

      if (await fCalMap.exists()) {
        final res = await _uploadFile(fCalMap, ref);
        if (!res) {
          await tempDir.delete(recursive: true).catchError((e) {
            Logger.log(e.toString());
          });
          return;
        }
      }
    } on Exception catch (e) {
      Logger.log(e.toString());
    }

    await tempDir.delete(recursive: true).catchError((e) {
      Logger.log(e.toString());
    });
  }

  Future<bool> _uploadFile(File file, Reference ref) async {
    final task = ref.putFile(file);
    return _handleTask(task);
  }

  Future<bool> _downloadFile(File file, Reference ref) async {
    final task = ref.writeToFile(file);
    return _handleTask(task);
  }

  Future<void> _deleteFile(Reference ref) async {
    return ref.delete();
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
    );
    return result;
  }

  Future<bool> _isEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('backup') ?? false) &&
        repo.user != null &&
        repo.hasActiveSubscription &&
        (wearables.getWearables.length + outfits.getOutfits.length <=
            storageLimit);
  }

  Future<void> _handleSyncing(User? user) async {
    if (!await _isEnabled() || _isSyncing) return;
    await syncStorage();
  }

  Future<bool> uploadImage(File image) async {
    if (!await _isEnabled()) return false;
    if (extension(image.path) != '.jpg' && extension(image.path) != '.jpeg') {
      return false;
    }

    final fileName = basename(image.path);
    final ref =
        _storage.ref().child('users/${repo.user?.uid}/photos/$fileName');

    return _uploadFile(image, ref);
  }

  Future<void> deleteImage(File image) async {
    if (!await _isEnabled()) return;
    if (extension(image.path) != '.jpg' && extension(image.path) != '.jpeg') {
      return;
    }
    if (!await image.exists()) return;

    final fileName = basename(image.path);
    final ref =
        _storage.ref().child('users/${repo.user?.uid}/photos/$fileName');

    return _deleteFile(ref);
  }

  Future<void> uploadWearables() async {
    if (!await _isEnabled()) return;
    final storageRef = _storage.ref();

    //Upload local wearables to cloud
    try {
      final ref =
          storageRef.child('users/${repo.user?.uid}/data/$wearablesPath');
      final fWearable = File('$_directoryPath/data/$wearablesPath');

      if (await fWearable.exists()) {
        final res = await _uploadFile(fWearable, ref);
        if (!res) {
          return;
        }
      }

      for (final wearable in wearables.getWearables) {
        final image = File(wearable.imagePath);
        final fileName = basename(wearable.imagePath);
        final ref =
            storageRef.child('users/${repo.user?.uid}/photos/$fileName');
        if (await image.exists()) {
          await ref.getMetadata().onError((e, trace) async {
            await _uploadFile(image, ref);
            return FullMetadata({});
          });
        }
      }
    } on Exception catch (e) {
      Logger.log(e.toString());
    }
  }

  Future<void> uploadOutfits() async {
    if (!await _isEnabled()) return;
    final storageRef = _storage.ref();

    //Upload local wearables to cloud
    try {
      final ref = storageRef.child('users/${repo.user?.uid}/data/$outfitsPath');
      final fOutfit = File('$_directoryPath/data/$outfitsPath');

      if (await fOutfit.exists()) {
        final res = await _uploadFile(fOutfit, ref);
        if (!res) {
          return;
        }
      }

      for (final outfit in outfits.getOutfits) {
        final image = File(outfit.imagePath);
        final fileName = basename(outfit.imagePath);
        final ref =
            storageRef.child('users/${repo.user?.uid}/photos/$fileName');
        if (await image.exists()) {
          await ref.getMetadata().onError((e, trace) async {
            await _uploadFile(image, ref);
            return FullMetadata({});
          });
        }
      }
    } on Exception catch (e) {
      Logger.log(e.toString());
    }
  }

  Future<void> uploadCalendarMap() async {
    try {
      if (!await _isEnabled()) return;
      final storageRef = _storage.ref();
      final ref =
          storageRef.child('users/${repo.user?.uid}/data/$calendarMapPath');
      final fCalMap = File('$_directoryPath/data/$calendarMapPath');

      if (await fCalMap.exists()) {
        await _uploadFile(fCalMap, ref);
      }
    } on Exception catch (e) {
      Logger.log(e.toString());
    }
  }
}
