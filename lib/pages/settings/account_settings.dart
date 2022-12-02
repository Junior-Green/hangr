import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hangr/pages/hangr_pro.dart';
import 'package:hangr/services/alert.dart';
import 'package:hangr/services/firebase.dart' as fb;
import 'package:shared_preferences/shared_preferences.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  late SharedPreferences prefs;
  bool isProMember = false;
  late final Future<void> future;

  @override
  void initState() {
    super.initState();
    future = initData();
  }

  Future<void> initData() async {
    prefs = await SharedPreferences.getInstance();
    isProMember = prefs.getBool('is_premium_user') ?? false;
  }

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
            child: FutureBuilder(
              future: future,
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) =>
                  snapshot.connectionState == ConnectionState.done
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: fb.user == null
                              ? _getLoggedOutView()
                              : _getLoggedInView(),
                        )
                      : const SizedBox.shrink(),
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
    final user = fb.user;

    if (user == null) {
      Navigator.pop(context);
      return [];
    }

    final providers = user.providerData;

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
              isProMember ? 'PRO' : 'FREE',
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
                        await fb.linkAccountWithGoogle();
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
                        await fb.linkAccountWithApple();
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
      if (!isProMember) ...[
        SizedBox(
          height: rowHeight,
          child: GestureDetector(
            onTap: () async {
              await HapticFeedback.lightImpact();
              if (!mounted) return;
              await HangrPro.showPremiumBottomSheet(context);
              prefs = await SharedPreferences.getInstance();
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
            await fb.logOut();
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
                  await fb.logInWithApple();
                  prefs = await SharedPreferences.getInstance();
                  isProMember = prefs.getBool('is_premium_user') ?? false;
                  setState(() {});
                } catch (e) {
                  if (kDebugMode) {
                    print(e);
                  }
                }
              },
              child: SizedBox(
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
                await fb.logInWithGoogle();
                await Future.delayed(const Duration(milliseconds: 500));
                prefs = await SharedPreferences.getInstance();
                isProMember = prefs.getBool('is_premium_user') ?? false;
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
