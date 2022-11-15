import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future<bool?> showMessageAlert(
  BuildContext context,
  String title,
  String message,
) =>
    Alert(
      context: context,
      type: AlertType.none,
      title: title,
      desc: message,
      style: AlertStyle(
        isOverlayTapDismiss: false,
        animationType: AnimationType.grow,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        alertBorder: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        isCloseButton: false,
        titleStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
        descStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 15,
        ),
      ),
      buttons: [
        DialogButton(
          height: 35,
          margin: const EdgeInsets.symmetric(horizontal: 50),
          radius: const BorderRadius.all(Radius.circular(10)),
          color: Theme.of(context).colorScheme.tertiary,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text('Okay'),
        )
      ],
    ).show();
