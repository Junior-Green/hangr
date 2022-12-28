import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hangr/logic/alert.dart';
import 'package:hangr/logic/iap.dart';
import 'package:hangr/logic/logger.dart';
import 'package:hangr/pages/hangr_pro.dart';

class Account extends StatefulWidget {
  final IAP iap;
  const Account(this.iap, {Key? key}) : super(key: key);

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool _isUprgradeDisabled = false;
  @override
  void initState() {
    widget.iap.addListener(_handleIAPUpdate);
    super.initState();
  }

  void _handleIAPUpdate() => setState(() {});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text(
            'Account',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: AbsorbPointer(
              absorbing: _isUprgradeDisabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: !widget.iap.iapRepo.isLoggedIn
                    ? _getLoggedOutView()
                    : _getLoggedInView(),
              ),
            ),
          ),
        ),
      );

  @override
  void dispose() {
    super.dispose();
    widget.iap.removeListener(_handleIAPUpdate);
  }

  List<Widget> _getLoggedInView() {
    const rowHeight = 40.0;
    const appleLogoSize = 34.0;
    const googleLogoSize = 40.0;
    bool isAppleLinked = false;
    bool isGoogleLinked = false;
    final isLightMode =
        Theme.of(context).colorScheme.brightness == Brightness.light;
    final appleButtonPath =
        'assets/images/apple_logo_button_${isLightMode ? 'light' : 'dark'}.png';
    final googleButtonPath =
        'assets/images/btn_google_${isLightMode ? 'light' : 'dark'}_normal.png';

    final widgets = <Widget>[];

    if (!widget.iap.iapRepo.isLoggedIn) {
      Navigator.pop(context);
      return [];
    }

    final providers = widget.iap.iapRepo.user!.providerData;

    for (final data in providers) {
      if (data.providerId == 'google.com') {
        isGoogleLinked = true;
      }
      if (data.providerId == 'apple.com') {
        isAppleLinked = true;
      }
    }

    widgets.addAll([
      SizedBox(
        height: rowHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Account Status:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              widget.iap.iapRepo.hasActiveSubscription ? 'PRO' : 'FREE',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ),
      ),
      Divider(
        color: Theme.of(context).colorScheme.secondary,
        thickness: 1.5,
      ),
    ]);

    if ((!isAppleLinked && Platform.isIOS) || !isGoogleLinked) {
      widgets.addAll([
        SizedBox(
          height: rowHeight,
          child: Row(
            children: [
              const Text(
                'Link Account:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (!isGoogleLinked)
                Padding(
                  padding: EdgeInsets.only(right: !isAppleLinked ? 2.0 : 0.0),
                  child: GestureDetector(
                    onTap: () async {
                      await HapticFeedback.mediumImpact();
                      try {
                        await widget.iap.firebaseNotifier
                            .linkAccountWithGoogle();
                      } on Exception catch (e, trace) {
                        Logger.reportError(trace, e);
                        if (!mounted) return;
                        await showMessageAlert(
                          context,
                          'Linking Error',
                          'Something went wrong when trying to link to your existing account.',
                        );
                      }
                      setState(() {});
                    },
                    child: SizedBox(
                      height: googleLogoSize,
                      width: googleLogoSize,
                      child: Image(
                        image: AssetImage(googleButtonPath),
                      ),
                    ),
                  ),
                ),
              if (!isAppleLinked && Platform.isIOS)
                Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: GestureDetector(
                    onTap: () async {
                      await HapticFeedback.mediumImpact();
                      await _handleAppleLinking();
                      setState(() {});
                    },
                    child: SizedBox(
                      height: appleLogoSize,
                      width: appleLogoSize,
                      child: Image(
                        image: AssetImage(appleButtonPath),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Divider(
          color: Theme.of(context).colorScheme.onSecondary,
        )
      ]);
    }

    widgets.addAll([
      if (!widget.iap.iapRepo.hasActiveSubscription) ...[
        SizedBox(
          height: rowHeight,
          child: GestureDetector(
            onTap: () async {
              if (!_isUprgradeDisabled) {
                await HapticFeedback.lightImpact();
                if (!mounted) return;
                await HangrPro.showPremiumBottomSheet(context, widget.iap);
                _isUprgradeDisabled = true;
                Future.delayed(
                  const Duration(seconds: 5),
                  () => setState(() => _isUprgradeDisabled = false),
                );
              }
              setState(() {});
            },
            behavior: HitTestBehavior.translucent,
            child: Row(
              children: [
                Text(
                  'Upgrade to Pro',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          color: Theme.of(context).colorScheme.secondary,
          thickness: 1.5,
        ),
      ],
      SizedBox(
        height: rowHeight,
        child: GestureDetector(
          onTap: () async {
            await HapticFeedback.lightImpact();
            await widget.iap.firebaseNotifier.logOut();
            setState(() {});
          },
          behavior: HitTestBehavior.translucent,
          child: Row(
            children: const [
              Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      Divider(
        color: Theme.of(context).colorScheme.secondary,
        thickness: 1.5,
      ),
    ]);

    return widgets;
  }

  List<Widget> _getLoggedOutView() {
    final isLightMode =
        Theme.of(context).colorScheme.brightness == Brightness.light;
    final appleButtonPath =
        'assets/images/apple_logo_button_${isLightMode ? 'light' : 'dark'}.png';
    final googleButtonPath =
        'assets/images/btn_google_${isLightMode ? 'light' : 'dark'}_normal.png';

    final widgets = <Widget>[
      const Text(
        'Sign In',
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
      ),
      Divider(
        color: Theme.of(context).colorScheme.onSecondary,
      )
    ];

    widgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (Platform.isIOS)
            GestureDetector(
              onTap: () async {
                try {
                  await HapticFeedback.mediumImpact();
                  await widget.iap.firebaseNotifier.logInWithApple();
                } on Exception catch (e, trace) {
                  Logger.reportError(trace, e);
                }
              },
              child: Container(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: -2,
                      blurRadius: 3,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                height: 58,
                child: Image(
                  image: AssetImage(appleButtonPath),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          const SizedBox(
            width: 20,
          ),
          GestureDetector(
            onTap: () async {
              try {
                await HapticFeedback.mediumImpact();
                await widget.iap.firebaseNotifier.logInWithGoogle();
              } on Exception catch (e, trace) {
                Logger.reportError(trace, e);
              }
            },
            child: SizedBox(
              height: 70,
              child: Image(
                image: AssetImage(googleButtonPath),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );

    return widgets;
  }

  Future<void> _handleAppleLinking() async {
    try {
      await widget.iap.firebaseNotifier.linkAccountWithApple();
    } on FirebaseAuthException catch (e, trace) {
      Logger.reportError(trace, e);
      final errorMessage = (e.code == 'credential-already-in-use')
          ? 'Account already exists under another email address.'
          : 'Something went wrong when trying to link to your existing account.';
      if (!mounted) return;
      await showMessageAlert(
        context,
        'Linking Error',
        errorMessage,
      );
    } on Exception catch (e, trace) {
      Logger.reportError(trace, e);
      if (!mounted) return;
      await showMessageAlert(
        context,
        'Linking Error',
        'Something went wrong when trying to link to your existing account.',
      );
    }
  }
}
