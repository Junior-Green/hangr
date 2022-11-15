import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hangr/pages/hangr_pro.dart';
import 'package:hangr/services/alert.dart';
import 'package:hangr/services/togglable_image_group.dart';
import 'package:hangr/widgets/toggable_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraSettings extends StatefulWidget {
  const CameraSettings();

  @override
  State<CameraSettings> createState() => _CameraSettingsState();
}

class _CameraSettingsState extends State<CameraSettings> {
  late ToggableImageGroup<String> _group;
  late int currentIndex;
  late final SharedPreferences prefs;
  late final Future<void> future;

  @override
  void initState() {
    future = initData();
    super.initState();
  }

  Future<void> initData() async {
    prefs = await SharedPreferences.getInstance();
    currentIndex = _getInitialIndex(prefs.getInt('camera_quality') ?? 25);
    _group = ToggableImageGroup<String>(
      _getImages(),
      currentIndex,
    );
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
            'Camera',
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
                        'Photo Quality',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ..._group.toggableImages
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

  List<ToggableImage<String>> _getImages() => [
        ToggableImage(
          _getToggleOn(context),
          _getToggleOff(context),
          'low',
          null,
          () async {
            currentIndex = 0;
            await prefs.setInt('camera_quality', 25);
          },
        ),
        ToggableImage(
          _getToggleOn(context),
          _getToggleOff(context),
          'medium',
          null,
          () async {
            currentIndex = 1;
            await prefs.setInt('camera_quality', 50);
          },
        ),
        ToggableImage(
          _getToggleOn(context),
          _getToggleOff(context),
          'high',
          null,
          () async {
            currentIndex = 2;
            await prefs.setInt('camera_quality', 75);
          },
        ),
        ToggableImage(
          _getToggleOn(context),
          _getToggleOff(context),
          'ultra',
          null,
          () async {
            if (prefs.getBool('is_premium_user') ?? false) {
              await showMessageAlert(
                context,
                'Warning',
                'This setting may take up a significant amount of device storage.',
              );
              prefs.setInt('camera_quality', 100);
              currentIndex = 3;
            } else {
              await HangrPro.showProDialog(
                context,
                "Take higher quality photos and much more with Hangr Pro.",
              );

              setState(() {
                _group = ToggableImageGroup<String>(
                  _getImages(),
                  currentIndex,
                );
              });
            }
          },
        ),
      ];

  int _getInitialIndex(int quality) {
    switch (quality) {
      case 25:
        return 0;
      case 50:
        return 1;
      case 75:
        return 2;
      case 100:
        return 3;
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
