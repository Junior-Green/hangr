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
    Camera _camera = Camera(await availableCameras());
    await _camera.initCamera(CameraLensDirection.back);

    Navigator.pushReplacementNamed(context, '/home',
        arguments: {'camera': _camera});
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
