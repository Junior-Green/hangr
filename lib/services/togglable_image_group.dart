import 'package:flutter/foundation.dart';
import 'package:hangr/widgets/toggable_image.dart';

class ToggableImageGroup extends ChangeNotifier {
  late final List<ToggableImage> _images;
  int _selectedIndex = -1;

  ToggableImageGroup(List<ToggableImage> images, [int initialToggle = -1]) {
    final List<ToggableImage> newImages = [];
    for (int i = 0; i < images.length; i++) {
      newImages.add(
        ToggableImage(
          images[i].toggleOn,
          images[i].toggleOff,
          images[i].label,
          () => _buttonToggled(i),
        ),
      );
    }
    _images = newImages;
    if (initialToggle != -1) {
      _images[initialToggle].toggle();
      _selectedIndex = initialToggle;
    }
  }

  bool isSelected() => _selectedIndex != -1;

  ToggableImage? getSelectedImage() =>
      isSelected() ? _images[_selectedIndex] : null;

  void _buttonToggled(int index) {
    _selectedIndex = _images[index].isToggled ? -1 : index;
    for (var i = 0; i < _images.length; i++) {
      if (_images[i].isToggled && index != i) {
        _images[i].toggle();
      }
    }
    notifyListeners();
  }

  List<ToggableImage> get toggableImages => _images;
}
