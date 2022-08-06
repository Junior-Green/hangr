import 'package:hangr/widgets/toggable_image.dart';

class ToggableImageGroup {
  late final List<ToggableImage> _images;
  late int _selectedIndex;

  ToggableImageGroup(List<ToggableImage> images) {
    _selectedIndex = -1;
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
  }

  List<ToggableImage> get toggableImages => _images;
}
