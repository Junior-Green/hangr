import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hangr/helpers/camera.dart';
import 'package:hangr/themes.dart';
import 'package:flutter/services.dart';

class HomeCamera extends StatefulWidget {
  final Camera cameras;

  HomeCamera({Key? key, required this.cameras}) : super(key: key);

  @override
  State<HomeCamera> createState() => _HomeCameraState();
}

class _HomeCameraState extends State<HomeCamera> {
  static const _errorMessage = "No Camera Available";
  static const _maxZoomLevel = 5.0;
  static const _minZoomLevel = 1.0;
  static const _aspectRatio = 2 / 3;
  static const _cameraShutterImage = "images/camera_shutter.png";

  late CameraController? _controller;

  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;

  _toggleCamera() async {
    widget.cameras.toggleCamera();
    await widget.cameras.initCamera();
    setState(() {
      _controller = widget.cameras.controller;
    });
  }

  _setZoom(double multiplier) {
    setState(() {
      _scaleFactor = _baseScaleFactor * multiplier;
      if (_scaleFactor > _maxZoomLevel) {
        _scaleFactor = _maxZoomLevel;
      } else if (_scaleFactor < _minZoomLevel) {
        _scaleFactor = _minZoomLevel;
      }
      _controller!.setZoomLevel(_scaleFactor);
    });
  }

  @override
  initState() {
    _controller = widget.cameras.controller;
    super.initState();
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
            extendBody: true,
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onScaleStart: (details) {
                          _baseScaleFactor = _scaleFactor;
                        },
                        onScaleUpdate: (details) {
                          _setZoom(details.scale);
                        },
                        child: AspectRatio(
                            aspectRatio: _aspectRatio,
                            child: CameraPreview(_controller!))),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: SizedBox()),
                          Expanded(
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Image.asset(_cameraShutterImage),
                              iconSize: 125,
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                              },
                            ),
                          ),
                          Expanded(
                              child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,
                                shape: BoxShape.circle),
                            child: IconButton(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  _toggleCamera();
                                },
                                icon: Icon(
                                  Icons.threesixty_rounded,
                                  color: Colors.white,
                                  size: 30,
                                )),
                          ))
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
    return screen;
  }
}
