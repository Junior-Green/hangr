import 'package:flutter/foundation.dart';
import 'package:hangr/widgets/toggable_image.dart';

class ToggableImageGroup<T> extends ChangeNotifier {
  late final List<ToggableImage<T>> _images;
  int _selectedIndex = -1;

  ToggableImageGroup(List<ToggableImage<T>> images, [int initialToggle = -1]) {
    final List<ToggableImage<T>> newImages = [];
    for (int i = 0; i < images.length; i++) {
      newImages.add(
        ToggableImage<T>(
          images[i].toggleOn,
          images[i].toggleOff,
          images[i].value,
          images[i].label,
          () {
            _buttonToggled(i);
            images[i].onTap();
          },
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

  ToggableImage<T>? getSelectedImage() =>
      isSelected() ? _images[_selectedIndex] : null;

  void _buttonToggled(int index) {
    _selectedIndex = index;
    for (var i = 0; i < _images.length; i++) {
      if (_images[i].isToggled && index != i) {
        _images[i].toggle();
      }
    }
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    for (var i = 0; i < _images.length; i++) {
      if (_images[i].isToggled && index != i) {
        _images[i].toggle();
      }
      if (i == index && !_images[i].isToggled) {
        _images[i].toggle();
      }
    }
    notifyListeners();
  }

  List<ToggableImage<T>> get toggableImages => _images;
}
