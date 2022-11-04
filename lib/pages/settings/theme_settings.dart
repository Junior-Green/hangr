import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hangr/services/theme_handler.dart';
import 'package:hangr/services/togglable_image_group.dart';
import 'package:hangr/widgets/toggable_image.dart';

class ThemeSettings extends StatelessWidget {
  final Map<String, dynamic> config;
  final ThemeHandler handler;
  const ThemeSettings(this.config, this.handler, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ToggableImageGroup<String> group = ToggableImageGroup<String>(
        _getImages(context), _getInitialIndex(config['theme'] as String));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => _finalize(context),
          icon: const Icon(Icons.arrow_back_ios),
          padding: EdgeInsets.zero,
        ),
        title: const Text(
          'Theme',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theme mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      toggable
                    ],
                  ),
                )
                .toList()
          ],
        ),
      ),
    );
  }

  List<ToggableImage<String>> _getImages(BuildContext context) => [
        ToggableImage(
          _getToggleOn(context),
          _getToggleOff(context),
          'system',
          null,
          () => handler.setMode(ThemeMode.system),
        ),
        ToggableImage(
          _getToggleOn(context),
          _getToggleOff(context),
          'light',
          null,
          () => handler.setMode(ThemeMode.light),
        ),
        ToggableImage(
          _getToggleOn(context),
          _getToggleOff(context),
          'dark',
          null,
          () => handler.setMode(ThemeMode.dark),
        ),
      ];

  int _getInitialIndex(String themeMode) {
    switch (themeMode) {
      case 'system':
        return 0;
      case 'ligt':
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

  Future<void> _finalize(BuildContext context) async {
    Navigator.pop(context);
  }
}
