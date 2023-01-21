import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hangr/logic/togglable_image_group.dart';
import 'package:hangr/model/theme_handler.dart';
import 'package:hangr/widgets/toggable_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettings extends StatefulWidget {
  final ThemeHandler handler;
  const ThemeSettings(this.handler, {Key? key}) : super(key: key);

  @override
  State<ThemeSettings> createState() => _ThemeSettingsState();
}

class _ThemeSettingsState extends State<ThemeSettings> {
  late final SharedPreferences prefs;
  late final ToggableImageGroup<String> group;
  late final Future<void> future;

  @override
  void initState() {
    super.initState();
    future = initData();
  }

  Future<void> initData() async {
    await SharedPreferences.getInstance().then((value) {
      prefs = value;
      group = ToggableImageGroup<String>(
        _getImages(context),
        _getInitialIndex(prefs.getString('theme') ?? 'system'),
      );
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios),
            padding: EdgeInsets.zero,
          ),
          title: const Text(
            'Theme',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: FutureBuilder(
          future: future,
          builder: (_, snapshot) => snapshot.connectionState ==
                  ConnectionState.done
              ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Theme Mode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ...group.toggableImages
                          .map(
                            (toggable) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  toggable.value.replaceRange(
                                    0,
                                    1,
                                    toggable.value[0].toUpperCase(),
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                toggable
                              ],
                            ),
                          )
                          .toList()
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      );

  List<ToggableImage<String>> _getImages(BuildContext context) => [
        ToggableImage(
          _getToggleOn(context),
          _getToggleOff(context),
          'system',
          null,
          () async {
            await prefs.setString('theme', 'system');
            widget.handler.setMode(ThemeMode.system);
          },
        ),
        ToggableImage(
          _getToggleOn(context),
          _getToggleOff(context),
          'light',
          null,
          () async {
            await prefs.setString('theme', 'light');
            widget.handler.setMode(ThemeMode.light);
          },
        ),
        ToggableImage(
          _getToggleOn(context),
          _getToggleOff(context),
          'dark',
          null,
          () async {
            await prefs.setString('theme', 'dark');
            widget.handler.setMode(ThemeMode.dark);
          },
        ),
      ];

  int _getInitialIndex(String themeMode) {
    switch (themeMode) {
      case 'system':
        return 0;
      case 'light':
        return 1;
      case 'dark':
        return 2;
      default:
        return 0;
    }
  }

  Widget _getToggleOn(BuildContext context) => Icon(
        CupertinoIcons.check_mark_circled_solid,
        color: Theme.of(context).colorScheme.tertiary,
      );

  Widget _getToggleOff(BuildContext context) => Icon(
        CupertinoIcons.circle,
        color: Theme.of(context).colorScheme.onSecondary,
      );
}
