import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hangr/services/togglable_image_group.dart';
import 'package:hangr/services/wearable.dart';
import 'package:hangr/widgets/toggable_image.dart';
import 'package:provider/provider.dart';

class EditWearable extends StatefulWidget {
  final Wearable _wearable;
  const EditWearable(this._wearable);

  @override
  State<EditWearable> createState() => _EditWearableState();
}

class _EditWearableState extends State<EditWearable>
    with TickerProviderStateMixin {
  static const _aspectRatio = 3 / 4;
  late final TabController _controller;
  late final TextEditingController _nameEditingController;
  late final TextEditingController _brandEditingController;
  late final TextEditingController _colorEditingController;
  late final List<ToggableImage> _images;
  late final ToggableImageGroup _group;
  late final AudioPlayer _player;
  List<String> brands = [];
  List<String> colors = [];
  bool _canScroll = true;

  @override
  void initState() {
    _player = AudioPlayer();

    _controller = TabController(length: _tabs.length, vsync: this)
      ..addListener(
        () {
          setState(() {
            FocusScope.of(context).unfocus();
            if (_controller.index == 4) {
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
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: SafeArea(
                  bottom: false,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: AspectRatio(
                      aspectRatio: _aspectRatio,
                      child: Image.file(File(widget._wearable.imagePath)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics:
                      _canScroll ? null : const NeverScrollableScrollPhysics(),
                  controller: _controller,
                  children: _inputFields,
                ),
              )
            ],
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
                    return '';
                  }
                  final check = value.replaceAll(' ', '');
                  return check.isEmpty && value.isNotEmpty
                      ? 'name most contain at least 1 letter'
                      : null;
                },
                onChanged: (text) => setState(
                  () => _canScroll =
                      text.replaceAll(' ', '') != '' && text.isNotEmpty,
                ),
                decoration: InputDecoration(
                  labelText: "name",
                  hintText: widget._wearable.name,
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
                    () => _canScroll =
                        text.replaceAll(' ', '') != '' && text.isNotEmpty,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 25),
                  maxLength: 30,
                  cursorColor: Theme.of(context).colorScheme.onPrimary,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "brand",
                    hintText: widget._wearable.brand,
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
                    () => _canScroll =
                        text.replaceAll(' ', '') != '' && text.isNotEmpty,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 25),
                  maxLength: 30,
                  cursorColor: Theme.of(context).colorScheme.onPrimary,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "primary color",
                    hintText: widget._wearable.primaryColor,
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
        const Center(
          child: Text(
            "You're Good to Go !",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            textAlign: TextAlign.center,
          ),
        )
      ];

  Future<void> _finalize() async {
    final wearableType = _getWearableType();
    final newName = _nameEditingController.text.isNotEmpty
        ? _nameEditingController.text
        : widget._wearable.name;
    final newBrand = _brandEditingController.text.isNotEmpty
        ? _brandEditingController.text
        : widget._wearable.brand;
    final newColor = _colorEditingController.text.isNotEmpty
        ? _colorEditingController.text
        : widget._wearable.primaryColor;

    if (wearableType == null) {
      await _dialog();
      if (!mounted) return;
      Navigator.pop(context, false);
    }
    final newWearable = Wearable(
      widget._wearable.id,
      wearableType!,
      newBrand,
      newColor,
      widget._wearable.imagePath,
      newName,
      widget._wearable.timeTaken,
    );
    if (!mounted) return;

    context.read<MyWearables>()
      ..removeWearable(widget._wearable)
      ..addWearable(newWearable);

    await _player.play(
      AssetSource('audio/clothing_creation_sfx.mp3'),
      volume: 1,
      mode: PlayerMode.lowLatency,
    );
    HapticFeedback.heavyImpact();

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  void _initImages() {
    int currIndex = 0;
    int selected = -1;
    _images = List<ToggableImage>.from(
      WearableType.values.map(
        (type) {
          if (type == widget._wearable.type) {
            selected = currIndex;
          }
          final val = type.toString().substring(13);
          currIndex++;
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
            val.replaceFirst(val[0], val[0].toUpperCase()),
          );
        },
      ),
      growable: false,
    );
    _group = ToggableImageGroup(_images, selected)
      ..addListener(
        () => setState(() => _canScroll = _group.getSelectedImage() != null),
      );
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
  }

  WearableType? _getWearableType() {
    final label = _group.getSelectedImage() == null
        ? ''
        : _group.getSelectedImage()!.label.toLowerCase();

    switch (label) {
      case 'headwear':
        return WearableType.headwear;
      case 'footwear':
        return WearableType.footwear;
      case 'bottom':
        return WearableType.bottom;
      case 'top':
        return WearableType.top;
      case 'accessory':
        return WearableType.accessory;
      default:
        return null;
    }
  }

  Future<void> _dialog() {
    return showDialog(
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: const Center(
          child: Text(
            "Error",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: const Text(
          'An error occured.',
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Okay",
                    // ignore: unnecessary_const
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      context: context,
    );
  }
}
