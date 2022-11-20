import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hangr/services/alert.dart';
import 'package:hangr/services/custom_icons.dart';
import 'package:hangr/services/firebase.dart' as fb;

// ignore: avoid_classes_with_only_static_members
class HangrPro {
  static Future<void> showProDialog(BuildContext context, String featureDesc) {
    final screenHeight = MediaQuery.of(context).size.height;

    final dialog = Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
      backgroundColor: Colors.transparent,
      alignment: Alignment.center,
      shape: const RoundedRectangleBorder(), //this right here
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                CupertinoIcons.xmark,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
              width: double.infinity,
              height: screenHeight * 0.60,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 210, 3, 79),
                    Color.fromARGB(255, 231, 47, 114)
                  ],
                ),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    const Text(
                      'You ran into a Hangr Pro exlusive feature!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      featureDesc,
                      style: const TextStyle(
                        color: Colors.white,
                        height: 1.5,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    TextButton(
                      onPressed: () => showPremiumBottomSheet(context),
                      style: ButtonStyle(
                        backgroundColor:
                            const MaterialStatePropertyAll(Colors.white),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: const MaterialStatePropertyAll(
                          Colors.transparent,
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 30,
                        ),
                        child: Text(
                          'LEARN MORE',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                    const Icon(
                      CustomIcons.logo,
                      size: 40,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
    return showDialog(
      context: context,
      builder: (context) => dialog,
      barrierColor: Colors.black87,
      barrierDismissible: false,
    );
  }

  static Future<void> showPremiumBottomSheet(BuildContext context) async =>
      showCupertinoModalPopup(
        context: context,
        builder: (context) => _getbottomSheet(context),
      );

  static Widget _getbottomSheet(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 100),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: Scaffold(
            appBar: const PreferredSize(
              preferredSize: Size.zero,
              child: SizedBox.shrink(),
            ),
            body: ListView(
              physics: const ClampingScrollPhysics(),
              primary: false,
              children: [
                Container(
                  height: 125,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 210, 3, 79),
                        Color.fromARGB(255, 230, 60, 122)
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.elliptical(300, 75),
                      bottomLeft: Radius.elliptical(300, 75),
                    ),
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  child: const Center(
                    child:
                        Icon(CustomIcons.logo, color: Colors.white, size: 75),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Text(
                    'Upgrade to Hangr Pro Now!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Build your digital wardrobe like a real pro with several premium features and benefits.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                _generateFeatureHighlight(
                  context,
                  'Ultra Quality Photos',
                  "Have a better looking digital wardrobe by taking photos of the highest quality.",
                  CupertinoIcons.camera,
                ),
                _generateFeatureHighlight(
                  context,
                  'Unlimited Wardrobe Space',
                  'Create and store as many clothing pieces and outfits as you want.',
                  CustomIcons.hanger,
                ),
                _generateFeatureHighlight(
                  context,
                  'Cloud Storage',
                  'Keep a backup of your wardrobe on the Cloud in case anything goes wrong.',
                  CupertinoIcons.cloud,
                ),
              ],
            ),
            backgroundColor: Colors.white,
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              height: 150,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Text(
                      'One-time cost of 14.99',
                      style: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextButton(
                      onPressed: () async {
                        if (fb.user == null) {
                          await showMessageAlert(
                            context,
                            'Login Required',
                            'You must be logged into an existing account to upgrade to Hangr Pro.',
                          );

                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                          Theme.of(context).colorScheme.tertiary,
                        ),
                        minimumSize: const MaterialStatePropertyAll(
                          Size(double.infinity, 75),
                        ),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: const MaterialStatePropertyAll(
                          Colors.transparent,
                        ),
                      ),
                      child: const Text(
                        'Upgrade to Pro',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  static Widget _generateFeatureHighlight(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 30),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    description,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
