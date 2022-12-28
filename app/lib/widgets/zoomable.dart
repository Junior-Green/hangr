import 'dart:io';

import 'package:flutter/cupertino.dart';
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
  final String? _bottomLabel;
  final bool isUploaded;
  static const _aspectRatio = 3 / 4;

  const Zoomable(
    this._options,
    this._title,
    this._subtitle,
    this._imagePath,
    this._time,
    this._bottomLabel, {
    this.isUploaded = false,
  });

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    child: AspectRatio(
                      aspectRatio: _aspectRatio,
                      child: File(_imagePath).existsSync()
                          ? Image.file(
                              File(_imagePath),
                              fit: BoxFit.fill,
                            )
                          : ColoredBox(
                              color: Theme.of(context).colorScheme.onSecondary,
                              child: const Center(
                                child: Text(
                                  'No Image',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (isUploaded)
                    Padding(
                      padding: const EdgeInsets.only(right: 4, bottom: 4),
                      child: Icon(
                        CupertinoIcons.cloud_download_fill,
                        color: Colors.grey.withOpacity(0.5),
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
            if (_bottomLabel != null)
              Text(
                _bottomLabel!,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              const SizedBox.shrink()
          ],
        ),
      );

  void _zoom(BuildContext context) {
    final dialog = Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
            AspectRatio(
              aspectRatio: 3 / 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: File(_imagePath).existsSync()
                    ? Image.file(
                        File(_imagePath),
                        fit: BoxFit.fill,
                      )
                    : ColoredBox(
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondary
                            .withAlpha(255),
                        child: const Center(
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Text(
                              'No Image',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              'Added: ${DateFormat.yMMMMd().format(_time)}',
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
