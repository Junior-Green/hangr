import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hangr/logic/togglable_image_group.dart';
import 'package:hangr/model/wearable.dart';
import 'package:hangr/widgets/toggable_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';

class AddWearable extends StatefulWidget {
  final Uint8List _image;
  const AddWearable(this._image);

  @override
  State<AddWearable> createState() => _AddWearableState();
}

class _AddWearableState extends State<AddWearable>
    with TickerProviderStateMixin {
  static const _aspectRatio = 3 / 4;
  late final TabController _controller;
  late final TextEditingController _nameEditingController;
  late final TextEditingController _brandEditingController;
  late final TextEditingController _colorEditingController;
  late final List<ToggableImage<WearableType>> _images;
  late final ToggableImageGroup<WearableType> _group;
  late final AudioPlayer _player;
  List<String> brands = [];
  List<String> colors = [];
  bool _canScroll = false;
  double _opacity = 0.0;

  @override
  void initState() {
    _player = AudioPlayer();

    _controller = TabController(length: _tabs.length, vsync: this)
      ..addListener(
        () {
          setState(() {
            FocusScope.of(context).unfocus();
            _checkValidity();
            if (_controller.index == 4) {
              _changeOpacity();
              _finalize();
            }
          });
        },
      );
    _nameEditingController = TextEditingController();
    _brandEditingController = TextEditingController();
    _colorEditingController = TextEditingController();

    _initImages();
    _getAutoCompleteQueries();
    super.initState();
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: Column(
                children: [
                  IconButton(
                    iconSize: 30,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      CupertinoIcons.trash_fill,
                      color: Colors.red,
                    ),
                    padding: const EdgeInsets.only(bottom: 10),
                  ),
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: AspectRatio(
                        aspectRatio: _aspectRatio,
                        child: Image.memory(
                          widget._image,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: _canScroll
                          ? null
                          : const NeverScrollableScrollPhysics(),
                      controller: _controller,
                      children: _inputFields,
                    ),
                  )
                ],
              ),
            ),
          ),
          bottomNavigationBar: IgnorePointer(
            child: TabBar(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              enableFeedback: true,
              controller: _controller,
              tabs: _tabs,
              indicatorWeight: 1,
              indicatorColor: Colors.transparent,
              labelColor: Theme.of(context).colorScheme.tertiary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSecondary,
              labelPadding: const EdgeInsets.only(bottom: 15),
            ),
          ),
        ),
      );

  List<Widget> get _tabs => [
        const Tab(icon: Icon(Icons.circle, size: 15)),
        const Tab(icon: Icon(Icons.circle, size: 15)),
        const Tab(icon: Icon(Icons.circle, size: 15)),
        const Tab(icon: Icon(Icons.circle, size: 15)),
        const Tab(icon: Icon(Icons.check_rounded, size: 25)),
      ];

  List<Widget> get _inputFields => [
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Theme(
              data: textFieldTheme,
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
                onChanged: (text) =>
                    setState(() => _canScroll = text.replaceAll(' ', '') != ''),
                decoration: InputDecoration(
                  errorText: _canScroll ? "" : "empty field",
                  labelText: "name",
                  hintText: 'enter name',
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                controller: _nameEditingController,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                style: const TextStyle(fontSize: 35),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 30,
                cursorColor: Theme.of(context).colorScheme.onPrimary,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 75,
            children: _group.toggableImages,
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Theme(
              data: textFieldTheme,
              child: TypeAheadField<String>(
                direction: AxisDirection.up,
                hideOnLoading: true,
                hideOnEmpty: true,
                suggestionsBoxDecoration: const SuggestionsBoxDecoration(
                  elevation: 0.0,
                  hasScrollbar: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                suggestionsBoxVerticalOffset: 10,
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _brandEditingController,
                  onChanged: (text) => setState(
                    () => _canScroll = text.replaceAll(' ', '') != '',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 25),
                  maxLength: 30,
                  cursorColor: Theme.of(context).colorScheme.onPrimary,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "brand",
                    hintText: 'enter brand',
                    floatingLabelAlignment: FloatingLabelAlignment.center,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
                suggestionsCallback: (input) => _getBrands(input),
                itemBuilder: (context, suggestion) => ListTile(
                  title: Text(
                    suggestion,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                onSuggestionSelected: (suggestion) =>
                    _brandEditingController.text = suggestion,
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Theme(
              data: textFieldTheme,
              child: TypeAheadField<String>(
                direction: AxisDirection.up,
                hideOnLoading: true,
                hideOnEmpty: true,
                suggestionsBoxDecoration: const SuggestionsBoxDecoration(
                  elevation: 0.0,
                  hasScrollbar: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                suggestionsBoxVerticalOffset: 10,
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _colorEditingController,
                  onChanged: (text) => setState(
                    () => _canScroll = text.replaceAll(' ', '') != '',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 25),
                  maxLength: 30,
                  cursorColor: Theme.of(context).colorScheme.onPrimary,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "primary color",
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
                onSuggestionSelected: (suggestion) =>
                    _colorEditingController.text = suggestion,
              ),
            ),
          ),
        ),
        Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _opacity,
            child: const Text(
              "You're Good to Go !",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ];

  Future<void> _finalize() async {
    final dir = await getTemporaryDirectory();
    final dirPath = dir.path;
    const generator = Uuid();
    final generatedId = generator.v1();
    final imagePath = '$dirPath/photos/$generatedId.jpg';
    final wearableType = _getWearableType();

    if (wearableType == null) {
      await _dialog();
      if (!mounted) return;
      Navigator.pop(context);
    }

    try {
      final newWearable = Wearable(
        generatedId,
        wearableType!,
        _brandEditingController.text,
        _colorEditingController.text,
        imagePath,
        _nameEditingController.text,
        DateTime.now(),
      );
      if (!mounted) return;

      await context.read<MyWearables>().addWearable(newWearable);
      await File(imagePath).writeAsBytes(widget._image);

      await _player.play(
        AssetSource('audio/clothing_creation_sfx.mp3'),
        volume: 1,
        mode: PlayerMode.lowLatency,
      );
      HapticFeedback.heavyImpact();

      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      await _dialog();
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void _initImages() {
    _images = List<ToggableImage<WearableType>>.from(
      WearableType.values.map(
        (type) {
          final val = type.toString().substring(13);

          return ToggableImage(
            Image.asset(
              "assets/images/${val}_filled.png",
              width: 50,
              height: 50,
            ),
            Image.asset(
              "assets/images/${val}_outlined.png",
              width: 50,
              height: 50,
            ),
            type,
            Text(
              val.replaceFirst(val[0], val[0].toUpperCase()),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
      growable: false,
    );
    _group = ToggableImageGroup<WearableType>(_images)
      ..addListener(() => setState(() => _checkValidity()));
  }

  ThemeData get textFieldTheme => Theme.of(context).copyWith(
        hintColor: Theme.of(context).colorScheme.onSecondary,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: _canScroll
                  ? Theme.of(context).colorScheme.tertiary
                  : Colors.red,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 3,
              color: _canScroll
                  ? Theme.of(context).colorScheme.tertiary
                  : Colors.red,
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

  void _checkValidity() {
    switch (_controller.index) {
      case 0:
        _canScroll = _nameEditingController.text.replaceAll(' ', '') != '';
        break;
      case 1:
        _canScroll = _group.getSelectedImage() != null;
        break;
      case 2:
        _canScroll = _brandEditingController.text.replaceAll(' ', '') != '';
        break;
      case 3:
        _canScroll = _colorEditingController.text.replaceAll(' ', '') != '';
        break;
      default:
        _canScroll = false;
        break;
    }
  }

  Future<void> _getAutoCompleteQueries() async {
    final brandsJson = json.decode(
      await DefaultAssetBundle.of(context)
          .loadString('assets/data/brands.json'),
    ) as List<dynamic>;
    if (!mounted) return;
    final colorsJson = json.decode(
      await DefaultAssetBundle.of(context)
          .loadString('assets/data/colors.json'),
    ) as List<dynamic>;

    setState(() {
      brands = List<String>.from(brandsJson.map((e) => e.toString()));
      colors = List<String>.from(colorsJson.map((e) => e.toString()));
    });
  }

  List<String> _getBrands(String input) {
    final allSuggestions = brands
        .where((brand) => brand.toLowerCase().contains(input.toLowerCase()))
        .toList();

    return input.replaceAll(' ', '') != ''
        ? allSuggestions.sublist(
            0,
            allSuggestions.length <= 5 ? allSuggestions.length : 5,
          )
        : [];
  }

  List<String> _getColors(String input) {
    final allSuggestions = colors
        .where((color) => color.toLowerCase().contains(input.toLowerCase()))
        .toList();

    return input.replaceAll(' ', '') != ''
        ? allSuggestions.sublist(
            0,
            allSuggestions.length <= 5 ? allSuggestions.length : 5,
          )
        : [];
  }

  void _disposeAll() {
    _player.dispose();
    _colorEditingController.dispose();
    _controller.dispose();
    _nameEditingController.dispose();
    _brandEditingController.dispose();
    _group.dispose();
  }

  WearableType? _getWearableType() => _group.getSelectedImage() == null
      ? null
      : _group.getSelectedImage()!.value;

  void _changeOpacity() =>
      setState(() => _opacity = _opacity == 0.0 ? 1.0 : 0.0);

  Future<void> _dialog() async {
    await Alert(
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
          color: Theme.of(context).colorScheme.tertiary,
          radius: const BorderRadius.all(Radius.circular(8)),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text('Okay'),
        )
      ],
    ).show();
  }
}
