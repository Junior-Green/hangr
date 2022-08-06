import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hangr/pages/add_wearable.dart';
import 'package:hangr/services/wearable.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class HomeCamera extends StatefulWidget {
  final TabController _controller;
  const HomeCamera(this._controller);

  @override
  State<HomeCamera> createState() => _HomeCameraState();
}

class _HomeCameraState extends State<HomeCamera> with TickerProviderStateMixin {
  @override
  void initState() {
    _getImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Colors.black,
      );

  Future<void> _getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) {
      widget._controller.animateTo(1);
      return;
    }
    final croppedImage = await _cropImage(image.path);

    if (croppedImage == null || !mounted) {
      widget._controller.animateTo(1);
      return;
    }
    final wearables = context.read<List<Wearable>>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            Provider.value(value: wearables, child: AddWearable(croppedImage)),
      ),
    ).then((val) => widget._controller.animateTo(1));
  }

  Future<Uint8List?> _cropImage(String path) async {
    final primaryColor = Theme.of(context).colorScheme.secondary;
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      compressQuality: 100,
      aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 4),
      uiSettings: [
        IOSUiSettings(
          showCancelConfirmationDialog: true,
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
