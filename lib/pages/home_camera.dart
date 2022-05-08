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
  static const _errorMessage = "No Camera Available";
  static const _maxZoomLevel = 5.0;
  static const _minZoomLevel = 1.0;
  static const _aspectRatio = 2 / 3;

  CameraController? _controller;
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
                _errorMessage,
                style: AppTheme.light.textTheme.displayLarge,
              ),
            ))
        : Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                        onScaleStart: (details) {
                          _baseScaleFactor = _scaleFactor;
                        },
                        onScaleUpdate: (details) {
                          setState(() {
                            _scaleFactor = _baseScaleFactor * details.scale;
                            if (_scaleFactor > _maxZoomLevel) {
                              _scaleFactor = _maxZoomLevel;
                            } else if (_scaleFactor < _minZoomLevel) {
                              _scaleFactor = _minZoomLevel;
                            }
                            _controller!.setZoomLevel(_scaleFactor);
                          });
                        },
                        child: AspectRatio(
                            aspectRatio: _aspectRatio,
                            child: CameraPreview(_controller!))),
                    Expanded(
                        child: Container(
                      color: Colors.black,
                    ))
                  ],
                ),
              ),
            ),
          );
    return screen;
  }
}
