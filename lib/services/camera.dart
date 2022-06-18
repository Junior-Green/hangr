import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

class Camera {
  static const _resolution = ResolutionPreset.veryHigh; //1080p
  static const DeviceOrientation _orientation = DeviceOrientation.portraitUp;

  final List<CameraDescription> _cameras;
  CameraController? _controller;

  Camera(List<CameraDescription> cameras) : _cameras = cameras;

  bool setCamera(CameraLensDirection dir) {
    if (!_isCameraAvailiable()) return false;
    for (final camera in _cameras) {
      if (camera.lensDirection == dir) {
        _controller = CameraController(camera, _resolution);
        break;
      }
    }
    return true;
  }

  void toggleCamera() {
    if (_controller == null) {
      setCamera(CameraLensDirection.back);
    } else if (_controller!.description.lensDirection ==
        CameraLensDirection.back) {
      setCamera(CameraLensDirection.front);
    } else {
      setCamera(CameraLensDirection.back);
    }
  }

  Future<bool> initCamera() async {
    if (_controller == null) return false;
    await _controller!.initialize();
    await _controller!.lockCaptureOrientation(_orientation);
    return true;
  }

  CameraController? get controller => _controller;
  bool _isCameraAvailiable() => _cameras.isNotEmpty;
}
