import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ToggableImage<T> extends StatefulWidget {
  final Widget? _label;
  final Widget _toggleOn;
  final Widget _toggleOff;
  final Function? _onTap;
  final ValueNotifier<bool> _toggled = ValueNotifier(false);
  final T _value;

  ToggableImage(
    this._toggleOn,
    this._toggleOff,
    this._value, [
    this._label,
    this._onTap,
  ]);
  void toggle() => _toggled.value = !_toggled.value;
  // ignore: avoid_dynamic_calls, prefer_null_aware_method_calls
  void onTap() => _onTap != null ? _onTap!() : null;

  bool get isToggled => _toggled.value;
  Widget get toggleOn => _toggleOn;
  Widget? get label => _label;
  Widget get toggleOff => _toggleOff;
  T get value => _value;

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
                onTap: !widget.isToggled ? _toggle : null,
                child: value ? widget._toggleOn : widget._toggleOff,
              ),
              if (widget._label != null) ...[
                const SizedBox(
                  height: 5,
                ),
                widget._label!
              ]
            ],
          ),
        ),
        valueListenable: widget._toggled,
      );

  void _toggle() {
    widget.onTap();
    widget.toggle();
  }
}
