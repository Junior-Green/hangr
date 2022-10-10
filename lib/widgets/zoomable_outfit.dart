import 'package:focused_menu/modals.dart';
import 'package:hangr/services/outfit.dart';
import 'package:hangr/widgets/zoomable.dart';

class ZoomableOutfit extends Zoomable {
  final Outfit _outfit;
  ZoomableOutfit(List<FocusedMenuItem> options, this._outfit)
      : super(
          options,
          _outfit.name,
          '${_outfit.primaryColor} · ${_outfit.secondaryColor} \n ${_outfit.wearableIds.length} ${_outfit.wearableIds.length > 1 ? 'Pieces' : 'Piece'}',
          _outfit.imagePath,
          _outfit.timeMade,
        );

  Outfit get outfit => _outfit;
}
