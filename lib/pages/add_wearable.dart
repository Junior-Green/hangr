import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hangr/services/togglable_image_group.dart';
import 'package:hangr/services/wearable.dart';
import 'package:hangr/widgets/toggable_image.dart';

class AddWearable extends StatefulWidget {
  final String _imagePath;
  const AddWearable(this._imagePath);

  @override
  State<AddWearable> createState() => _AddWearableState();
}

class _AddWearableState extends State<AddWearable>
    with TickerProviderStateMixin {
  static const _aspectRatio = 2 / 3;
  late final TabController _controller;
  late final TextEditingController _nameEditingController;
  late final TextEditingController _brandEditingController;
  late final List<ToggableImage> _images;
  late final ToggableImageGroup _group;
  List<String> brands = [];
  List<String> colors = [];
  bool _canScroll = false;

  @override
  void initState() {
    _controller = TabController(length: _tabs.length, vsync: this)
      ..addListener(
        () => setState(() {
          if (_controller.index == 1) {
            _canScroll = _group.getSelectedImage() != null;
          }
        }),
      );
    _nameEditingController = TextEditingController();
    _brandEditingController = TextEditingController();
    _initImages();
    _getAutoCompleteQueries();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameEditingController.dispose();
    _brandEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() {
            if (_controller.index == 1) {
              _canScroll = _group.getSelectedImage() != null;
            }
          });
        },
        child: Scaffold(
          body: Center(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: SafeArea(
                    bottom: false,
                    child: AspectRatio(
                      aspectRatio: _aspectRatio,
                      child: Image.asset(
                        "assets/images/iphone.jpg",
                      ) //Image.file(File(widget._imagePath)),),   // FIXME change back image file reference (Ln 27) when done
                      ,
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
                onChanged: (text) => setState(() {
                  text = text.replaceAll(' ', '');
                  _canScroll = text.isNotEmpty;
                }),
                decoration: InputDecoration(
                    errorText: _canScroll ? "" : "empty field",
                    labelText: "name",
                    hintText: 'enter name'),
                keyboardType: TextInputType.name,
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
        Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: TextField(
              keyboardType: TextInputType.name,
              onChanged: (text) => setState(() {
                _canScroll = text != "";
              }),
              decoration: const InputDecoration(
                hintText: 'enter brand',
                labelText: "brand",
              ),
              controller: _brandEditingController,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              style: const TextStyle(fontSize: 35),
              autofillHints: brands,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: Theme.of(context).colorScheme.onPrimary,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const Center(child: TextField())
      ];

  void _initImages() {
    _images = List<ToggableImage>.from(
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
            val.replaceFirst(val[0], val[0].toUpperCase()),
          );
        },
      ),
      growable: false,
    );
    _group = ToggableImageGroup(_images);
  }

  ThemeData get textFieldTheme => Theme.of(context).copyWith(
        hintColor: Theme.of(context).colorScheme.onSecondary,
        inputDecorationTheme: InputDecorationTheme(
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

    final colorsJson = json.decode(
      await DefaultAssetBundle.of(context)
          .loadString('assets/data/colors.json'),
    ) as List<dynamic>;

    setState(() {
      brands = List<String>.from(brandsJson.map((e) => e.toString()));
      colors = List<String>.from(colorsJson.map((e) => e.toString()));
    });
  }
}
