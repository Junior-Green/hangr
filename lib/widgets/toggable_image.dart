import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ToggableImage extends StatefulWidget {
  final String _label;
  final Image _toggleOn;
  final Image _toggleOff;
  final Function? _onTap;
  final ValueNotifier<bool> _toggled = ValueNotifier(false);

  ToggableImage(
    this._toggleOn,
    this._toggleOff, [
    this._label = "",
    this._onTap,
  ]);

  // ignore: avoid_dynamic_calls, prefer_null_aware_method_calls
  void toggle() => _toggled.value = !_toggled.value;

  void onTap() => _onTap != null ? _onTap!() : null;

  bool get isToggled => _toggled.value;
  String get label => _label;
  Image get toggleOn => _toggleOn;
  Image get toggleOff => _toggleOff;

  @override
  State<ToggableImage> createState() => _ToggableImageState();
}

class _ToggableImageState extends State<ToggableImage> {
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        builder: (BuildContext context, value, Widget? child) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _toggleImage,
                child: value ? widget._toggleOn : widget._toggleOff,
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                widget._label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        valueListenable: widget._toggled,
      );

  void _toggleImage() {
    widget.onTap();
    widget.toggle();
  }
}
