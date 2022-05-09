import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hangr/helpers/camera.dart';
import 'package:camera/camera.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Future<void> initCamera() async {
    try {
      Camera _camera = Camera(await availableCameras());
      await _camera.setCamera(CameraLensDirection.back);
      await _camera.initCamera();

      Navigator.pushReplacementNamed(context, '/home',
          arguments: {'camera': _camera});
    } on Exception catch (e) {
      print(e);
      exit(1);
    }
  }

  @override
  void initState() {
    super.initState();
    initCamera();
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
