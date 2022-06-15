import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hangr/helpers/camera.dart';
import 'package:camera/camera.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hangr/pages/home.dart';
import 'package:path_provider/path_provider.dart';

import '../helpers/calendar_map.dart';
import '../helpers/outfit.dart';
import '../helpers/wearable.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void getData() async {
    const outfitsPath = 'outfits.json';
    const wearablesPath = 'wearables.json';
    const calendarMapPath = 'calendar_map.json';

    try {
      List<Outfit>? outfits;
      List<Wearable>? wearables;
      CalendarMap? calendarMap;

      final Camera camera = Camera(await availableCameras());
      await camera.setCamera(CameraLensDirection.back);
      await camera.initCamera();

      final localDir = await getApplicationDocumentsDirectory();
      final path = localDir.path;

      if (await File('$path/$outfitsPath').exists()) {
        await File('$path/$outfitsPath').readAsString().then((contents) {
          Iterable l = jsonDecode(contents);
          outfits = List<Outfit>.from(l.map((model) => Outfit.fromJson(model)));
        });
      }
      if (await File('$path/$wearablesPath').exists()) {
        await File('$path/$wearablesPath').readAsString().then((contents) {
          Iterable l = jsonDecode(contents);
          wearables =
              List<Wearable>.from(l.map((model) => Wearable.fromJson(model)));
        });
      }

      if (await File('$path/$calendarMapPath').exists()) {
        await File('$path/$calendarMapPath').readAsString().then((contents) =>
            calendarMap = CalendarMap.fromJson(json.decode(contents)));
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Home(
                  camera: camera,
                  wearables: wearables,
                  calendarMap: calendarMap,
                  outfits: outfits,
                )),
      );
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: SpinKitFoldingCube(
      color: Theme.of(context).colorScheme.primary,
      size: 90.0,
    )));
  }
}
