import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hangr/logic/alert.dart';
import 'package:hangr/logic/iap.dart';
import 'package:hangr/pages/hangr_pro.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Account extends StatefulWidget {
  final IAP iap;
  const Account(this.iap, {Key? key}) : super(key: key);

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  late final ValueNotifier<IAP> iap;
  @override
  void initState() {
    iap = ValueNotifier<IAP>(widget.iap);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<IAP>(
        valueListenable: iap,
        builder: (_, iap, __) => Scaffold(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: !iap.iapRepo.isLoggedIn
                    ? _getLoggedOutView()
                    : _getLoggedInView(),
              ),
            ),
          ),
        ),
      );

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

    if (!iap.value.iapRepo.isLoggedIn) {
      Navigator.pop(context);
      return [];
    }

    final providers = iap.value.iapRepo.user!.providerData;

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
              iap.value.iapRepo.hasActiveSubscription ? 'PRO' : 'FREE',
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
                      } catch (e) {
                        if (kDebugMode) {
                          print(e);
                        }
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
                      try {
                        await widget.iap.firebaseNotifier
                            .linkAccountWithApple();
                      } on FirebaseAuthException catch (e) {
                        if (kDebugMode) {
                          print(e);
                        }
                        final errorMessage = (e.code ==
                                'credential-already-in-use')
                            ? 'Account already exists under another email address.'
                            : 'Something went wrong when trying to link to your existing account.';
                        if (!mounted) return;
                        await showMessageAlert(
                          context,
                          'Linking Error',
                          errorMessage,
                        );
                      } catch (e) {
                        if (kDebugMode) {
                          print(e);
                        }
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
      if (!iap.value.iapRepo.hasActiveSubscription) ...[
        SizedBox(
          height: rowHeight,
          child: GestureDetector(
            onTap: () async {
              await HapticFeedback.lightImpact();
              if (!mounted) return;
              await HangrPro.showPremiumBottomSheet(context, widget.iap);
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
                  await Future.delayed(const Duration(milliseconds: 500));
                  setState(() {});
                } catch (e) {
                  if (kDebugMode) {
                    print(e);
                  }
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
                await Future.delayed(const Duration(milliseconds: 500));
                setState(() {});
              } catch (e) {
                if (kDebugMode) {
                  print(e);
                }
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
}
