import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hangr/helpers/camera.dart';
import 'package:hangr/themes.dart';

class HomeCamera extends StatefulWidget {
  final Camera camera;

  const HomeCamera({Key? key, required this.camera}) : super(key: key);

  @override
  State<HomeCamera> createState() => _HomeCameraState();
}

class _HomeCameraState extends State<HomeCamera> {
  late CameraController? _controller;

  final double _maxZoomLevel = 5.0;
  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = widget.camera.getController;
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = (_controller == null)
        ? Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                "No Camera Available",
                style: AppTheme.light.textTheme.displayLarge,
              ),
            ))
        : GestureDetector(
                    onScaleStart: (details) {
                      _baseScaleFactor = _scaleFactor;
                    },
                    onScaleUpdate: (details) {
                      setState(() {
                        _scaleFactor = _baseScaleFactor * details.scale;
                        if (_scaleFactor > _maxZoomLevel) {
                          _scaleFactor = _maxZoomLevel;
                        } else if (_scaleFactor < 1.0) {
                          _scaleFactor = 1.0;
                        }
                        _controller!.setZoomLevel(_scaleFactor);
                      });
                    },
                    child: CameraPreview(_controller!));
    return screen;
  }
}
