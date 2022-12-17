import 'package:focused_menu/modals.dart';
import 'package:hangr/model/wearable.dart';
import 'package:hangr/widgets/zoomable.dart';

class ZoomableWearable extends Zoomable {
  final Wearable _wearable;
  ZoomableWearable(
    List<FocusedMenuItem> options,
    this._wearable, [
    String? bottomLabel,
  ]) : super(
          options,
          _wearable.name,
          _wearable.brand,
          _wearable.imagePath,
          _wearable.timeTaken,
          bottomLabel,
        );

  Wearable get wearable => _wearable;
}
