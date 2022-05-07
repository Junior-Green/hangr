import 'package:camera/camera.dart';

class Camera {
  final List<CameraDescription> _cameras;
  CameraController? _controller;
  double? _maxZoom;

  Camera(List<CameraDescription> cameras) : _cameras = cameras;

  bool isCameraAvailiable() => _cameras.isNotEmpty;

  Future<void> initCamera(CameraLensDirection dir) async {
    if (!isCameraAvailiable()) return;

    for (var camera in _cameras) {
      if (camera.lensDirection == dir) {
        _controller = CameraController(camera, ResolutionPreset.max);
        await _controller!.initialize();
        _maxZoom = await _controller!.getMaxZoomLevel();
        break;
      }
    }
  }

  CameraController? get getController => _controller;
  double? get getMaxZoom => _maxZoom;
}
