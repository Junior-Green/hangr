import 'package:flutter/material.dart';
import 'package:hangr/pages/home.dart';
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<CameraDescription> cameras = [];

  try {
    cameras = await availableCameras();
  } on Exception catch (e) {
    exit(1);
  }

  runApp(MaterialApp(initialRoute: '/home', routes: {
    '/': (context) => SizedBox(),
    '/home': (context) => DefaultTabController(
        length: 3, child: Home(cameras: cameras), initialIndex: 1),
    '/location': (context) => SizedBox(),
  }));
}
