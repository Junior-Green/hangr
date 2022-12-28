import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hangr/logic/alert.dart';
import 'package:hangr/logic/cloud_storage.dart';
import 'package:hangr/logic/iap.dart';
import 'package:hangr/logic/notifications.dart';
import 'package:hangr/logic/page_transition.dart';
import 'package:hangr/model/outfit.dart';
import 'package:hangr/model/theme_handler.dart';
import 'package:hangr/model/wearable.dart';
import 'package:hangr/pages/settings/account_settings.dart';
import 'package:hangr/pages/settings/camera_settings.dart';
import 'package:hangr/pages/settings/cloud_backup_settings.dart';
import 'package:hangr/pages/settings/privacy_policy_settings.dart';
import 'package:hangr/pages/settings/reminders_settings.dart';
import 'package:hangr/pages/settings/theme_settings.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatelessWidget {
  late final List<Widget> _settingPages;

  Settings(
    ThemeHandler handler,
    Notifications notifications,
    IAP iap,
    CloudStorage storage,
    MyWearables wearables,
    MyOutfits outfits,
  ) {
    _settingPages = <Widget>[
      Account(iap),
      ThemeSettings(handler),
      Reminders(notifications),
      CameraSettings(iap),
      CloudBackup(
        iap,
        storage,
        wearables,
        outfits,
      ),
      const SizedBox.shrink(),
      const SizedBox.shrink(),
      const PrivacyPolicy(),
    ];
  }

  static const _settingTitles = <String>[
    'Account Status',
    'Theme',
    'Reminders',
    'Camera',
    'Cloud Backup',
    'Rate App',
    'Send Feedback',
    'Privacy Policy',
  ];

  static const _settingDescriptions = <String>[
    'View and manage your account.',
    'Change how the display of the app looks.',
    'Choose whether to enable reminders and what time you want them delivered.',
    'Select the resolution and quality of the photos taken and stored.',
    'Manage your cloud backup settings.',
    'Leave a review for the app.',
    'Send feedback on the app related to bugs, issues, and features you would like to see.',
    'Read our privacy policy.'
  ];

  static const _settingIcons = <IconData>[
    CupertinoIcons.person,
    CupertinoIcons.brightness,
    CupertinoIcons.bell,
    CupertinoIcons.camera,
    CupertinoIcons.cloud,
    CupertinoIcons.star,
    CupertinoIcons.text_bubble,
    CupertinoIcons.info
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text(
            'Settings',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: ListView.separated(
          itemBuilder: (_, index) => _generateSetting(index, context),
          separatorBuilder: (_, __) => Divider(
            thickness: 1.5,
            color: Theme.of(context).colorScheme.secondary,
          ),
          itemCount: _settingTitles.length,
        ),
      );

  Widget _generateSetting(int index, BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          HapticFeedback.lightImpact();
          if (index == 5) {
            _rateApp(context);
            return;
          }
          if (index == 6) {
            _sendFeedBack(context);
            return;
          }
          slideRightPageTransition(
            context,
            _settingPages[index],
            const Duration(milliseconds: 100),
          );
        },
        child: SizedBox(
          height: (MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight) /
              _settingTitles.length,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Icon(
                  _settingIcons[index],
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
                      _settingTitles[index],
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _settingDescriptions[index],
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(
                CupertinoIcons.right_chevron,
                color: Theme.of(context).colorScheme.onSecondary,
              )
            ],
          ),
        ),
      );

  Future<void> _rateApp(BuildContext context) async {
    const appStoreId = '6444371616';
    final InAppReview inAppReview = InAppReview.instance;
    await inAppReview.openStoreListing(
      appStoreId: appStoreId,
    );
  }

  Future<void> _sendFeedBack(BuildContext context) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appName = packageInfo.appName;
    final String version = packageInfo.version;

    final Uri params = Uri(
      scheme: 'mailto',
      path: 'hangr.canada@gmail.com',
      query: 'subject=$appName Feedback version - $version&body=',
    );
    if (await canLaunchUrl(params)) {
      await launchUrl(params);
    } else {
      // ignore: use_build_context_synchronously
      await showMessageAlert(
        context,
        'Error',
        'An error occured while trying to open the mail app.',
      );
    }
  }
}
