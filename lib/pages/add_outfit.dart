import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/modals.dart';
import 'package:hangr/services/outfit.dart';
import 'package:hangr/services/wearable.dart';
import 'package:hangr/widgets/zoomable_wearable.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class AddOutfit extends StatefulWidget {
  final MyOutfits _outfits;
  final MyWearables _wearables;

  const AddOutfit(this._wearables, this._outfits);

  @override
  State<AddOutfit> createState() => _AddOutfitState();
}

class _AddOutfitState extends State<AddOutfit> {
  final _tops = <Wearable>[];
  final _bottoms = <Wearable>[];
  final _headwears = <Wearable>[];
  final _footwears = <Wearable>[];
  final _accessories = <Wearable>[];

  Uint8List? _outfitImage;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: <Widget>[
              _createSilverAppBar(),
              SliverPadding(
                padding: const EdgeInsets.only(left: 10),
                sliver: _createSilverList(),
              ),
              _createSliverFooter(),
            ],
          ),
        ),
        persistentFooterAlignment: AlignmentDirectional.center,
        extendBody: true,
        persistentFooterButtons: [
          TextButton(
            onPressed: () {},
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(
                Theme.of(context).colorScheme.tertiary,
              ),
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 15),
              child: Text(
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );

  SliverAppBar _createSilverAppBar() => SliverAppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        expandedHeight: 350,
        elevation: 0,
        flexibleSpace: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              FlexibleSpaceBar(
            centerTitle: true,
            background: _getOutfitImageDisplay(),
            collapseMode: CollapseMode.none,
          ),
        ),
      );

  SliverList _createSilverList() =>
      SliverList(delegate: SliverChildListDelegate.fixed(_getListChildren()));

  List<Widget> _getListChildren() => [
        _getSectionHeader('Headwear'),
        _getListSection(WearableType.headwear, _headwears),
        //
        _getSectionHeader('Top'),
        _getListSection(WearableType.top, _tops),

        _getSectionHeader('Bottom'),
        _getListSection(WearableType.bottom, _bottoms),

        _getSectionHeader('Footwear'),
        _getListSection(WearableType.footwear, _footwears),

        _getSectionHeader('Accessories'),
        _getListSection(WearableType.accessory, _accessories),
      ];

  Widget _getListSection(WearableType type, List<Wearable> wearables) =>
      ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 175,
        ),
        child: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          children: wearables
              .map<Widget>(
                (w) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ZoomableWearable(
                    [
                      FocusedMenuItem(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        title: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => setState(() => wearables.remove(w)),
                        trailingIcon: const Icon(
                          CupertinoIcons.delete_solid,
                          color: Colors.red,
                          size: 25,
                        ),
                      )
                    ],
                    w,
                  ),
                ),
              )
              .toList()
            ..add(_addPrompt(type, wearables)),
        ),
      );

  Widget _getSectionHeader(String s) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
        child: Text(
          s,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      );

  Widget _addPrompt(WearableType type, List<Wearable> wearables) =>
      GestureDetector(
        onTap: () => _getSelection(type, wearables),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary,
                width: 2.5,
              ),
            ),
            position: DecorationPosition.foreground,
            child: Center(
              child: Icon(
                CupertinoIcons.add,
                color: Theme.of(context).colorScheme.secondary,
                size: 60,
              ),
            ),
          ),
        ),
      );

  SliverFillRemaining _createSliverFooter() => const SliverFillRemaining(
        hasScrollBody: false,
        child: SizedBox(
          height: 100,
        ),
      );

  Widget _getOutfitImageDisplay() => Center(
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: GestureDetector(
            onTap: () => _getImage(),
            child: _outfitImage == null
                ? Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add_a_photo_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 60,
                        ),
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: Image.memory(_outfitImage!, fit: BoxFit.fill),
                  ),
          ),
        ),
      );

  Future<void> _getImage() async {
    final ImagePicker picker = ImagePicker();
    final ImageSource? source = await _getImageSource(context);

    if (source == null) {
      return;
    }

    final XFile? image = await picker.pickImage(source: source);
    if (image == null) {
      return;
    }
    // ignore: use_build_context_synchronously
    _outfitImage = await _cropImage(image.path, context);
    setState(() {});
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
          child: const Text('Choose Photo'),
        ),
        DialogButton(
          height: 35,
          color: Theme.of(context).colorScheme.tertiary,
          radius: const BorderRadius.all(Radius.circular(8)),
          onPressed: () {
            source = ImageSource.camera;
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text('Take Photo'),
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

  Future<void> _getSelection(
    WearableType type,
    List<Wearable> wearables,
  ) async {
    final List<Widget> wearablesToShow = widget._wearables.getWearables
        .where(
          (element) => element.type == type && !wearables.contains(element),
        )
        .map(
          (e) => Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() {
                wearables.add(e);
                Navigator.pop(context);
              }),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  child: Image.file(
                    File(e.imagePath),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 20.0,
            sigmaY: 10.0,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withAlpha(200),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: wearablesToShow.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 30),
                    height: 200,
                    child: Center(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: wearablesToShow,
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      'Nothing to add.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 25,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
