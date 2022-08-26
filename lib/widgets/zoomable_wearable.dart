import 'package:focused_menu/modals.dart';
import 'package:hangr/services/wearable.dart';
import 'package:hangr/widgets/zoomable.dart';

class ZoomableWearable extends Zoomable {
  final Wearable _wearable;
  ZoomableWearable(List<FocusedMenuItem> options, this._wearable)
      : super(
          options,
          _wearable.name,
          _wearable.brand,
          _wearable.imagePath,
          _wearable.timeTaken,
        );

  Wearable get wearable => _wearable;
}
