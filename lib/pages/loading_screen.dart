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
    Camera camera = Camera(await availableCameras());
    await camera.initCamera(CameraLensDirection.back);

    Navigator.pushReplacementNamed(context, '/home',
        arguments: {'camera': camera});
  }

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[850],
        body: const Center(
            child: SpinKitFoldingCube(
          color: Colors.white,
          size: 90.0,
        )));
  }
}
