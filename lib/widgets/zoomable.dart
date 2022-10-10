import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:intl/intl.dart';

abstract class Zoomable extends StatelessWidget {
  final List<FocusedMenuItem> _options;
  final String _title;
  final String _subtitle;
  final String _imagePath;
  final DateTime _time;
  static const _aspectRatio = 3 / 4;

  const Zoomable(
    this._options,
    this._title,
    this._subtitle,
    this._imagePath,
    this._time,
  );

  @override
  Widget build(BuildContext context) => FocusedMenuHolder(
        menuWidth: MediaQuery.of(context).size.width * 0.66,
        blurSize: 5.0,
        menuItemExtent: 60,
        menuOffset: 10.0,
        bottomOffsetHeight: 80.0,
        menuBoxDecoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        blurBackgroundColor: Colors.black87,
        menuItems: _options,
        onPressed: () {
          HapticFeedback.mediumImpact();
          _zoom(context);
        },
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          child: AspectRatio(
            aspectRatio: _aspectRatio,
            child: Image.file(
              File(_imagePath),
              fit: BoxFit.fill,
            ),
          ),
        ),
      );

  void _zoom(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenPadding = MediaQuery.of(context).padding;

    final dialog = Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      backgroundColor: Colors.transparent,
      alignment: Alignment.center,
      shape: const RoundedRectangleBorder(), //this right here
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                _title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
            Text(
              _subtitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 40,
            ),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: AspectRatio(
                aspectRatio: _aspectRatio,
                child: Image.file(
                  File(_imagePath),
                  fit: BoxFit.fill,
                  height: screenHeight -
                      screenPadding.top -
                      screenPadding.bottom / 1.1,
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              DateFormat.yMMMMd().add_jm().format(_time),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
    showDialog(
      context: context,
      builder: (context) => dialog,
      barrierColor: Colors.black87,
    );
  }
}
