import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hangr/helpers/camera.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeCamera extends StatefulWidget {
  final Camera cameras;

  HomeCamera({Key? key, required this.cameras}) : super(key: key);

  @override
  State<HomeCamera> createState() => _HomeCameraState();
}

class _HomeCameraState extends State<HomeCamera> with TickerProviderStateMixin {
  static const _errorMessage = "No Camera Available";
  static const _maxZoomLevel = 5.0;
  static const _minZoomLevel = 1.0;
  static const _aspectRatio = 2 / 3;
  static const _cameraButton = "assets/images/camera_button.png";
  static const _shutterSound = "camera_shutter.wav";

  late CameraController? _camera;
  late final AudioCache _audioCache;
  late final AnimationController _toggleAnimation;
  late final AnimationController _cameraAnimation;

  String _imagePath = "";
  bool _isPressed = false;

  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;
  late double _toggleScale;
  late double _cameraScale;

  @override
  initState() {
    _camera = widget.cameras.controller;
    _initAnimations();
    _initAudioCache();
    super.initState();
  }

  @override
  dispose() {
    _toggleAnimation.dispose();
    _cameraAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _setAnimationScale();
    return (_camera == null) ? _errorScreen : _cameraScreen;
  }

  Widget get _errorScreen => Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          _errorMessage,
          style: TextStyle(color: Colors.white),
        ),
      ));

  Widget get _cameraScreen => Scaffold(
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
                    onScaleStart: (details) => _baseScaleFactor = _scaleFactor,
                    onScaleUpdate: (details) => _setZoom,
                    child: AspectRatio(
                        aspectRatio: _aspectRatio,
                        child: CameraPreview(_camera!))),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: SizedBox()),
                      Expanded(
                        child: GestureDetector(
                          onTap: _takePicture,
                          child: Transform.scale(
                              scale: _cameraScale,
                              child:
                                  Container(child: Image.asset(_cameraButton))),
                        ),
                      ),
                      Expanded(
                          child: GestureDetector(
                        onTap: _switchLens,
                        child: Transform.scale(
                          scale: _toggleScale,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,
                                shape: BoxShape.circle),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.threesixty_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );

  Widget _dialogBuilder(BuildContext context) => AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(30, 15, 30, 10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Center(
            child: Text(
          "Use Image?",
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        content: Image.file(File(_imagePath)),
        actions: [
          TextButton(
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop('dialog'),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: const Text("Cancel",
                    style: TextStyle(color: Colors.red, fontSize: 18)),
              )),
          TextButton(
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop('dialog'),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: const Text("Use",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 18)),
              )),
        ],
      );

  void _initAnimations() {
    _toggleAnimation = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200),
        lowerBound: 0.0,
        upperBound: 0.1)
      ..addListener(() {
        setState(() {
          if (_toggleAnimation.isCompleted) {
            _toggleAnimation.reverse();
          }
        });
      });

    _cameraAnimation = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200),
        lowerBound: 0.0,
        upperBound: 0.05)
      ..addListener(() {
        setState(() {
          if (_cameraAnimation.isCompleted) {
            _cameraAnimation.reverse();
          }
        });
      });
  }

  void _initAudioCache() {
    _audioCache = AudioCache(
      respectSilence: true,
      prefix: 'assets/audio/',
      fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    );

    _audioCache.load(_shutterSound);
  }

  void _setAnimationScale() {
    _toggleScale = 1 - _toggleAnimation.value;
    _cameraScale = 1 - _cameraAnimation.value;
  }

  void _toggleCamera() async {
    widget.cameras.toggleCamera();
    await widget.cameras.initCamera();
    setState(() {
      _camera = widget.cameras.controller;
    });
  }

  void _setZoom(double multiplier) {
    setState(() {
      _scaleFactor = _baseScaleFactor * multiplier;
      if (_scaleFactor > _maxZoomLevel) {
        _scaleFactor = _maxZoomLevel;
      } else if (_scaleFactor < _minZoomLevel) {
        _scaleFactor = _minZoomLevel;
      }
      _camera!.setZoomLevel(_scaleFactor);
    });
  }

  void _takePicture() async {
    try {
      if (!_isPressed) {
        setState(() {
          _isPressed = true;
        });
        _audioCache.play(_shutterSound);
        _cameraAnimation.forward();
        HapticFeedback.mediumImpact();

        final image = await _camera!.takePicture();
        _imagePath = image.path;

        showDialog(
            context: context,
            builder: _dialogBuilder,
            barrierDismissible: false);

        setState(() {
          _isPressed = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void _switchLens() {
    if (!_toggleAnimation.isCompleted) _toggleAnimation.forward();

    HapticFeedback.lightImpact();
    _toggleCamera();
  }
}
