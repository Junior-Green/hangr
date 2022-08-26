
import 'package:focused_menu/modals.dart';
import 'package:hangr/services/outfit.dart';
import 'package:hangr/widgets/zoomable.dart';

class ZoomableOutfit extends Zoomable {
  ZoomableOutfit(List<FocusedMenuItem> options, Outfit outfit)
      : super(options, outfit.name, '', outfit.imagePath, outfit.timeMade);
}
