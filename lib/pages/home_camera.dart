import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hangr/pages/add_wearable.dart';
import 'package:hangr/pages/hangr_pro.dart';
import 'package:hangr/services/page_transition.dart';
import 'package:hangr/services/wearable.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeCamera extends StatefulWidget {
  final TabController _controller;
  const HomeCamera(this._controller);

  @override
  State<HomeCamera> createState() => _HomeCameraState();
}

class _HomeCameraState extends State<HomeCamera> {
  @override
  void initState() {
    super.initState();
    _getImage(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Theme.of(context).colorScheme.primary);
  }

  Future<void> _getImage(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isPremiumMember = prefs.getBool('is_premium_user') ?? false;

    if (!mounted) return widget._controller.animateTo(1);

    final wearableCount = context.read<MyWearables>().getWearables.length;

    if (!isPremiumMember && wearableCount >= 25) {
      await HangrPro.showProDialog(
        context,
        'Create and store an unlimited amount of clothing with Hangr Pro.',
      );
      return widget._controller.animateTo(1);
    }

    final ImagePicker picker = ImagePicker();
    final ImageSource? source = await _getImageSource(context);
    if (source == null || !mounted) {
      widget._controller.animateTo(1);
      return;
    }

    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: prefs.getInt('camera_quality') ?? 50,
    );

    if (image == null || !mounted) {
      widget._controller.animateTo(1);
      return;
    }

    final croppedImage = await _cropImage(image.path, context);

    if (croppedImage == null || !mounted) {
      widget._controller.animateTo(1);
      return;
    }

    await fadeInPageTransition(
      context,
      ChangeNotifierProvider.value(
        value: context.read<MyWearables>(),
        child: AddWearable(croppedImage),
      ),
      const Duration(milliseconds: 100),
    ).then((val) => widget._controller.animateTo(1));
  }

  Future<ImageSource?> _getImageSource(BuildContext context) async {
    ImageSource? source;
    await Alert(
      context: context,
      type: AlertType.none,
      title: 'Select Photo',
      desc: "Do you want to take a picture or use an existing one?",
      style: AlertStyle(
        animationType: AnimationType.grow,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        alertBorder: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        isCloseButton: false,
        titleStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
        descStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 15,
        ),
      ),
      buttons: [
        DialogButton(
          height: 35,
          radius: const BorderRadius.all(Radius.circular(8)),
          color: Theme.of(context).colorScheme.tertiary,
          onPressed: () {
            source = ImageSource.gallery;
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text(
            'Choose Photo',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        DialogButton(
          height: 35,
          color: Theme.of(context).colorScheme.tertiary,
          radius: const BorderRadius.all(Radius.circular(8)),
          onPressed: () {
            source = ImageSource.camera;
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text(
            'Take Photo',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        )
      ],
    ).show();
    return source;
  }

  Future<Uint8List?> _cropImage(String path, BuildContext context) async {
    final primaryColor = Theme.of(context).colorScheme.secondary;
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      compressQuality: 100,
      aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 4),
      uiSettings: [
        IOSUiSettings(
          showCancelConfirmationDialog: true,
          rotateButtonsHidden: true,
          aspectRatioLockEnabled: true,
          title: 'Crop Image',
        ),
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          statusBarColor: primaryColor,
          toolbarWidgetColor: primaryColor,
          cropFrameColor: primaryColor,
        )
      ],
    );
    if (croppedFile == null) {
      return null;
    }
    return croppedFile.readAsBytes();
  }
}
