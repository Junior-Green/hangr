import 'package:flutter/material.dart';

Future<void> defaultPageTransition(
  BuildContext context,
  Widget w,
  double duration,
) async =>
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => w,
      ),
    );

Future<void> fadeInPageTransition(
  BuildContext context,
  Widget w,
  Duration duration,
) async =>
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) =>
            w,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn,
          ),
          child: child,
        ),
        transitionDuration: duration,
        reverseTransitionDuration: duration,
      ),
    );

Future<void> fadeInPageReplacement(
  BuildContext context,
  Widget page,
  Duration duration,
) async =>
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) =>
            page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn,
          ),
          child: child,
        ),
        transitionDuration: duration,
        reverseTransitionDuration: duration,
      ),
    );

Future<void> slideRightPageTransition(
  BuildContext context,
  Widget page,
  Duration duration,
) async =>
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) =>
            page,
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) =>
            SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
        transitionDuration: duration,
        reverseTransitionDuration: duration,
      ),
    );

Future<void> slideLeftPageTransition(
  BuildContext context,
  Widget page,
  Duration duration,
) async =>
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) =>
            page,
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) =>
            SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
        transitionDuration: duration,
        reverseTransitionDuration: duration,
      ),
    );
Future<void> slideUpPageTransition(
  BuildContext context,
  Widget page,
  Duration duration,
) async =>
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) =>
            page,
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) =>
            SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
        transitionDuration: duration,
        reverseTransitionDuration:
            Duration(milliseconds: duration.inMilliseconds ~/ 2),
      ),
    );
Future<void> slideDownPageTransition(
  BuildContext context,
  Widget page,
  Duration duration,
) async =>
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) =>
            page,
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) =>
            SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
        transitionDuration: duration,
        reverseTransitionDuration:
            Duration(milliseconds: duration.inMilliseconds ~/ 2),
      ),
    );
