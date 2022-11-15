import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hangr/pages/hangr_pro.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CloudBackup extends StatefulWidget {
  const CloudBackup();

  @override
  State<CloudBackup> createState() => _CloudBackupState();
}

class _CloudBackupState extends State<CloudBackup> {
  late bool _isToggled;
  late final SharedPreferences prefs;
  late final Future<void> future;

  @override
  void initState() {
    future = _initData();
    super.initState();
  }

  Future<void> _initData() async {
    prefs = await SharedPreferences.getInstance();
    _isToggled = (prefs.getBool('backup') ?? false) &&
        (prefs.getBool('is_premium_user') ?? false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios),
            padding: EdgeInsets.zero,
          ),
          title: const Text(
            'Cloud Backup',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: FutureBuilder(
          future: future,
          builder: (_, snapshot) => snapshot.connectionState ==
                  ConnectionState.done
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Backup',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            CupertinoSwitch(
                              activeColor:
                                  Theme.of(context).colorScheme.tertiary,
                              value: _isToggled,
                              onChanged: (val) async {
                                _isToggled = val;
                                final isPremiumUser =
                                    prefs.getBool('is_premium_user') ?? false;
                                if (!isPremiumUser && _isToggled) {
                                  _isToggled = false;
                                  prefs.setBool('backup', false);
                                  await HangrPro.showProDialog(
                                    context,
                                    'Access your digital wardrobe anytime, anywhere with Hangr Pro.',
                                  );
                                } else {
                                  prefs.setBool('backup', _isToggled);
                                }
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        Divider(
                          color: _isToggled
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.transparent,
                          thickness: 1.5,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                          child: GestureDetector(
                            onTap: () async {},
                            child: Visibility(
                              visible: _isToggled,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Backup',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          color: _isToggled
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.transparent,
                          thickness: 1.5,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                          child: GestureDetector(
                            onTap: () async {},
                            child: Visibility(
                              visible: _isToggled,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Sync',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          color: _isToggled
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.transparent,
                          thickness: 1.5,
                        ),
                        const SizedBox.shrink()
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      );
}
