import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:focused_menu/modals.dart';
import 'package:hangr/logic/togglable_image_group.dart';
import 'package:hangr/model/custom_icons.dart';
import 'package:hangr/model/outfit.dart';
import 'package:hangr/model/wearable.dart';
import 'package:hangr/widgets/toggable_image.dart';
import 'package:hangr/widgets/zoomable_wearable.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';

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

  late final TextEditingController _nameEditingController;
  late final TextEditingController _primaryColorEditingController;
  late final TextEditingController _secondaryColorEditingController;
  late final List<String> _colors;

  late final ValueNotifier<bool> _isInfoValid;
  late final ValueNotifier<bool> _isPrimaryColorValid;
  late final ValueNotifier<bool> _isSecondaryColorValid;
  late final ValueNotifier<bool> _isNameValid;
  late final ValueNotifier<bool> _isEnabled;
  late final ValueNotifier<bool> _isOutfitImageValid;
  late final ValueNotifier<bool> _isPiecesValid;

  Uint8List? _outfitImage;
  ToggableImageGroup<OutfitType>? _toggleGroup;

  @override
  void initState() {
    _nameEditingController = TextEditingController();
    _primaryColorEditingController = TextEditingController();
    _secondaryColorEditingController = TextEditingController();

    _isInfoValid = ValueNotifier<bool>(false);
    _isPrimaryColorValid = ValueNotifier<bool>(false);
    _isSecondaryColorValid = ValueNotifier<bool>(false);
    _isNameValid = ValueNotifier<bool>(false);
    _isEnabled = ValueNotifier<bool>(false);
    _isOutfitImageValid = ValueNotifier<bool>(false);
    _isPiecesValid = ValueNotifier<bool>(false);

    _getAutoCompleteQueries();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => setState(
        () => _toggleGroup = ToggableImageGroup(_getTogglableImages()),
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.zero,
            // ignore: use_colored_box
            child: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: <Widget>[
                _createSliverHeader('Image', true, _isOutfitImageValid),
                SliverPadding(
                  padding: const EdgeInsets.only(top: 20),
                  sliver: _createSilverAppBar(),
                ),
                _createSliverHeader('Pieces', false, _isPiecesValid),
                SliverPadding(
                  padding: const EdgeInsets.only(left: 10),
                  sliver: _createSilverList(),
                ),
                _createSliverHeader('Information', false, _isInfoValid),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  sliver: _createSilverAppBar2(),
                ),
                _createSliverFooter(),
              ],
            ),
          ),
          persistentFooterAlignment: AlignmentDirectional.center,
          extendBody: true,
          persistentFooterButtons: [
            ValueListenableBuilder<bool>(
              valueListenable: _isEnabled,
              builder: (context, isEnabled, widget) => TextButton(
                onPressed: _isEnabled.value ? _finalize : null,
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    isEnabled
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).colorScheme.tertiary.withAlpha(50),
                  ),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: const MaterialStatePropertyAll(
                    Colors.transparent,
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 30),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 20,
                      color: isEnabled
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withAlpha(50),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );

  //Outfit Image
  SliverAppBar _createSilverAppBar() => SliverAppBar(
        automaticallyImplyLeading: false,
        primary: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        expandedHeight: 350,
        elevation: 0,
        flexibleSpace: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              FlexibleSpaceBar(
            background: _getOutfitImageDisplay(),
            collapseMode: CollapseMode.none,
          ),
        ),
      );

  SliverAppBar _createSilverAppBar2() => SliverAppBar(
        primary: false,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 425,
        centerTitle: true,
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _getNameTextField(_isNameValid),
              const SizedBox(
                height: 10,
              ),
              _getColorTextField(
                'Primary',
                _primaryColorEditingController,
                _isPrimaryColorValid,
              ),
              const SizedBox(
                height: 10,
              ),
              _getColorTextField(
                'Secondary',
                _secondaryColorEditingController,
                _isSecondaryColorValid,
              ),
              _getOufitTypeSelection()
            ],
          ),
        ),
      );

  SliverPadding _createSliverHeader(
    String title,
    bool implyLeading,
    ValueNotifier<bool> notifier,
  ) =>
      SliverPadding(
        padding: const EdgeInsets.only(top: 25),
        sliver: SliverAppBar(
          automaticallyImplyLeading: false,
          pinned: true,
          expandedHeight: 50.0,
          primary: implyLeading,
          toolbarHeight: 40,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          flexibleSpace: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    CupertinoIcons.back,
                    color: implyLeading
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    if (implyLeading) {
                      Navigator.pop(context);
                    }
                  },
                ),
                const Spacer(flex: 4),
                SizedBox(
                  width: 200,
                  height: 60,
                  child: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                    titlePadding: const EdgeInsets.only(bottom: 10),
                  ),
                ),
                const Spacer(flex: 5),
                ValueListenableBuilder<bool>(
                  valueListenable: notifier,
                  builder: (context, value, widget) => Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
                    child: Icon(
                      CupertinoIcons.checkmark_alt_circle_fill,
                      color: value ? Colors.green : Colors.transparent,
                      size: 30,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );

  SliverList _createSilverList() =>
      SliverList(delegate: SliverChildListDelegate.fixed(_getListChildren()));

  List<Widget> _getListChildren() => [
        _getSectionHeader('Headwear'),
        _getListSection(WearableType.headwear, _headwears),
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
                        onPressed: () => setState(() {
                          wearables.remove(w);
                          _isPiecesValid.value = _tops.isNotEmpty ||
                              _bottoms.isNotEmpty ||
                              _headwears.isNotEmpty ||
                              _accessories.isNotEmpty ||
                              _footwears.isNotEmpty;
                          _enableButton();
                        }),
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
        onTap: () async {
          await HapticFeedback.lightImpact();
          await _getWearableSelection(type, wearables);
        },
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

  Widget _getOutfitImageDisplay() => ValueListenableBuilder<bool>(
        valueListenable: _isOutfitImageValid,
        builder: (context, value, widget) => Center(
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: GestureDetector(
              onTap: () async {
                await HapticFeedback.lightImpact();
                await _getImage();
                _enableButton();
              },
              child: value
                  ? ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: Image.memory(_outfitImage!, fit: BoxFit.fill),
                    )
                  : DecoratedBox(
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
    _isOutfitImageValid.value = _outfitImage != null;
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

  Future<void> _getWearableSelection(
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
                HapticFeedback.lightImpact();
                wearables.add(e);
                _isPiecesValid.value = _tops.isNotEmpty ||
                    _bottoms.isNotEmpty ||
                    _headwears.isNotEmpty ||
                    _accessories.isNotEmpty ||
                    _footwears.isNotEmpty;
                _enableButton();
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

    await showModalBottomSheet(
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

  Widget _getNameTextField(ValueNotifier<bool> toggler) =>
      ValueListenableBuilder<bool>(
        valueListenable: toggler,
        builder: (context, toggle, widget) => Theme(
          data: getTextFieldTheme(toggle: toggle),
          child: TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null) {
                return 'empty field';
              }
              value = value.replaceAll(' ', '');
              return value.isEmpty
                  ? 'name most contain at least 1 letter'
                  : null;
            },
            decoration: const InputDecoration(
              labelText: "Name",
              hintText: 'enter name',
              floatingLabelAlignment: FloatingLabelAlignment.center,
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            controller: _nameEditingController,
            onChanged: (text) {
              toggler.value = text.replaceAll(' ', '') != '';
              _setIsInfoValid();
              _enableButton();
            },
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            style: const TextStyle(fontSize: 25),
            textCapitalization: TextCapitalization.sentences,
            maxLength: 30,
            cursorColor: Theme.of(context).colorScheme.onPrimary,
            textAlign: TextAlign.center,
          ),
        ),
      );

  Widget _getColorTextField(
    String name,
    TextEditingController controller,
    ValueNotifier<bool> toggler,
  ) =>
      ValueListenableBuilder<bool>(
        valueListenable: toggler,
        builder: (context, toggle, widget) => Theme(
          data: getTextFieldTheme(toggle: toggle),
          child: TypeAheadField<String>(
            direction: AxisDirection.up,
            hideOnLoading: true,
            hideOnEmpty: true,
            suggestionsBoxDecoration: SuggestionsBoxDecoration(
              elevation: 0.0,
              color: Theme.of(context).colorScheme.secondary,
              hasScrollbar: false,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
            ),
            suggestionsBoxVerticalOffset: 10,
            textFieldConfiguration: TextFieldConfiguration(
              controller: controller,
              onChanged: (text) {
                toggler.value = text.replaceAll(' ', '') != '';
                _setIsInfoValid();
                _enableButton();
              },
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 25),
              maxLength: 30,
              cursorColor: Theme.of(context).colorScheme.onPrimary,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: "$name Color",
                hintText: 'enter color',
                floatingLabelAlignment: FloatingLabelAlignment.center,
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
            suggestionsCallback: (input) => _getColors(input),
            itemBuilder: (context, suggestion) => ListTile(
              title: Text(
                suggestion,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            onSuggestionSelected: (suggestion) => controller.text = suggestion,
          ),
        ),
      );

  ThemeData getTextFieldTheme({required bool toggle}) =>
      Theme.of(context).copyWith(
        hintColor: Theme.of(context).colorScheme.onSecondary,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color:
                  toggle ? Theme.of(context).colorScheme.tertiary : Colors.red,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color:
                  toggle ? Theme.of(context).colorScheme.tertiary : Colors.red,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color:
                  toggle ? Theme.of(context).colorScheme.tertiary : Colors.red,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 3,
              color:
                  toggle ? Theme.of(context).colorScheme.tertiary : Colors.red,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          floatingLabelAlignment: FloatingLabelAlignment.center,
        ),
      );

  Future<void> _getAutoCompleteQueries() async {
    final colorsJson = json.decode(
      await DefaultAssetBundle.of(context)
          .loadString('assets/data/colors.json'),
    ) as List<dynamic>;

    setState(
      () => _colors = List<String>.from(colorsJson.map((e) => e.toString())),
    );
  }

  List<String> _getColors(String input) {
    final allSuggestions = _colors
        .where((color) => color.toLowerCase().contains(input.toLowerCase()))
        .toList();

    return input.replaceAll(' ', '') != ''
        ? allSuggestions.sublist(
            0,
            allSuggestions.length <= 5 ? allSuggestions.length : 5,
          )
        : [];
  }

  Widget _getOufitTypeSelection() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _toggleGroup == null ? [] : _toggleGroup!.toggableImages,
      );

  List<ToggableImage<OutfitType>> _getTogglableImages() {
    const iconSize = 50.0;
    final labelStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Theme.of(context).colorScheme.onPrimary,
    );

    return <ToggableImage<OutfitType>>[
      ToggableImage(
        Icon(
          CustomIcons.top,
          color: Theme.of(context).colorScheme.tertiary,
          size: iconSize,
        ),
        Icon(
          CustomIcons.top,
          color: Theme.of(context).colorScheme.onSecondary,
          size: iconSize,
        ),
        OutfitType.casual,
        Text(
          'Casual',
          textAlign: TextAlign.center,
          style: labelStyle,
        ),
        () {
          _setIsInfoValid();
          _enableButton();
        },
      ),
      ToggableImage(
        Icon(
          CustomIcons.athletic,
          color: Theme.of(context).colorScheme.tertiary,
          size: iconSize,
        ),
        Icon(
          CustomIcons.athletic,
          color: Theme.of(context).colorScheme.onSecondary,
          size: iconSize,
        ),
        OutfitType.athletic,
        Text(
          'Athletic',
          textAlign: TextAlign.center,
          style: labelStyle,
        ),
        () {
          _setIsInfoValid();
          _enableButton();
        },
      ),
      ToggableImage(
        Icon(
          CustomIcons.semiFormal,
          color: Theme.of(context).colorScheme.tertiary,
          size: iconSize,
        ),
        Icon(
          CustomIcons.semiFormal,
          color: Theme.of(context).colorScheme.onSecondary,
          size: iconSize,
        ),
        OutfitType.semiFormal,
        Text(
          'Semi-Formal',
          textAlign: TextAlign.center,
          style: labelStyle,
        ),
        () {
          _setIsInfoValid();
          _enableButton();
        },
      ),
      ToggableImage(
        Icon(
          CustomIcons.formal,
          color: Theme.of(context).colorScheme.tertiary,
          size: iconSize,
        ),
        Icon(
          CustomIcons.formal,
          color: Theme.of(context).colorScheme.onSecondary,
          size: iconSize,
        ),
        OutfitType.formal,
        Text(
          'Formal',
          textAlign: TextAlign.center,
          style: labelStyle,
        ),
        () {
          _setIsInfoValid();
          _enableButton();
        },
      ),
    ];
  }

  void _enableButton() {
    _isEnabled.value =
        _isOutfitImageValid.value && _isPiecesValid.value && _isInfoValid.value;
  }

  void _setIsInfoValid() {
    _isInfoValid.value = _isNameValid.value &&
        _isPrimaryColorValid.value &&
        _isSecondaryColorValid.value &&
        _toggleGroup!.isSelected();
  }

  Future<void> _finalize() async {
    final dir = await getApplicationDocumentsDirectory();
    final dirPath = dir.path;
    const generator = Uuid();
    final generatedId = generator.v1();
    final imagePath = '$dirPath/$generatedId.jpg';
    final outfitType = _getOutfitType();
    final ids = _tops
        .followedBy(_bottoms)
        .followedBy(_footwears)
        .followedBy(_headwears)
        .followedBy(_accessories)
        .map((e) => e.id)
        .toList();

    if (outfitType == null) {
      await _exit();
    }
    try {
      final newOutfit = Outfit(
        generatedId,
        ids,
        outfitType!,
        _nameEditingController.text,
        _primaryColorEditingController.text,
        _secondaryColorEditingController.text,
        imagePath,
        DateTime.now(),
      );
      await widget._outfits.addOutfit(newOutfit);
      await File(imagePath).writeAsBytes(_outfitImage!);

      if (!mounted) return;

      HapticFeedback.heavyImpact();
      Navigator.pop(context, true);
    } catch (e) {
      await _exit();
    }
  }

  Future<void> _exit() async {
    await _errorDialog();
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _disposeAll() {
    _nameEditingController.dispose();
    _primaryColorEditingController.dispose();
    _secondaryColorEditingController.dispose();
    _isInfoValid.dispose();
    _isPrimaryColorValid.dispose();
    _isSecondaryColorValid.dispose();
    _isNameValid.dispose();
    _isEnabled.dispose();
    _isOutfitImageValid.dispose();
    _isPiecesValid.dispose();
  }

  OutfitType? _getOutfitType() => _toggleGroup!.getSelectedImage() == null
      ? null
      : _toggleGroup!.getSelectedImage()!.value;

  Future<void> _errorDialog() async => Alert(
        context: context,
        type: AlertType.none,
        title: 'Error',
        desc: "An error occured.",
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
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: const Text('Okay'),
          )
        ],
      ).show();
}
