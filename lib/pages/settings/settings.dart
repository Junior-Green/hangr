import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hangr/pages/settings/privacy_policy_settings.dart';
import 'package:hangr/pages/settings/theme_settings.dart';
import 'package:hangr/services/page_transition.dart';
import 'package:hangr/services/theme_handler.dart';

class Settings extends StatelessWidget {
  late final List<Widget> _settingPages;

  Settings(Map<String, dynamic> configurations, ThemeHandler handler) {
    _settingPages = <Widget>[
      ThemeSettings(configurations, handler),
      Container(),
      Container(),
      Container(),
      Container(),
      Container(),
      Container(),
      const PrivacyPolicy(),
    ];
  }

  static const _settingTitles = <String>[
    'Theme',
    'Reminders',
    'Camera Quality',
    'iCloud Backup',
    'Account Status',
    'Rate App',
    'Send Feedback',
    'Privacy Policy',
  ];

  static const _settingDescriptions = <String>[
    'Change how the display of the app looks.',
    'Select if you want reminders and what time you want them delivered to you.',
    'Select the resolution of photos taken by the camera when inside the app.',
    'Manage your iCloud backup settings.',
    'View and manage your account status.',
    'Leave a review for the app.',
    'Send feedback on the app related to bugs, issues, and features you would like to see.',
    'Read our privacy policy.'
  ];

  static const _settingIcons = <IconData>[
    CupertinoIcons.brightness,
    CupertinoIcons.bell,
    CupertinoIcons.camera,
    CupertinoIcons.cloud,
    CupertinoIcons.person,
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
        onTap: () => slideRightPageTransition(
          context,
          _settingPages[index],
          const Duration(milliseconds: 100),
        ),
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
}
