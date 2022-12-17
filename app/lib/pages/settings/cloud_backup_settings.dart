import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hangr/logic/cloud_storage.dart';
import 'package:hangr/logic/iap.dart';
import 'package:hangr/pages/hangr_pro.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CloudBackup extends StatefulWidget {
  final IAP iap;
  final CloudStorage storage;
  const CloudBackup(this.iap, this.storage);

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
        widget.iap.iapRepo.hasActiveSubscription;
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
                                    widget.iap.iapRepo.hasActiveSubscription;
                                if (!isPremiumUser && _isToggled) {
                                  _isToggled = false;
                                  prefs.setBool('backup', false);
                                  await HangrPro.showProDialog(
                                    context,
                                    'Access your digital wardrobe anytime, anywhere with Hangr Pro.',
                                    widget.iap,
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
                            onTap: () async {
                              //TODO: SHOW WARNING MESSAGE THAT INFORMS THAT DATA WILL BE OVERWRITTEN ON CLOUD STORAGE
                              await HapticFeedback.lightImpact();
                            },
                            child: Visibility(
                              visible: _isToggled,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Upload Wardrobe',
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
                            onTap: () async {
                              final res = await _showWarningMessage(
                                context,
                                'Your',
                              );
                              await HapticFeedback.lightImpact();
                            },
                            child: Visibility(
                              visible: _isToggled,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Sync Wardrobe',
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

  Future<bool> _showWarningMessage(BuildContext context, String message) async {
    bool res = false;

    await Alert(
      context: context,
      type: AlertType.none,
      title: 'Warning',
      desc: message,
      style: AlertStyle(
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
          radius: const BorderRadius.all(Radius.circular(8)),
          color: Theme.of(context).colorScheme.tertiary,
          onPressed: () {
            res = true;
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text('Yes'),
        ),
        DialogButton(
          height: 35,
          color: Theme.of(context).colorScheme.tertiary,
          radius: const BorderRadius.all(Radius.circular(8)),
          onPressed: () {
            res = false;
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text('Cancel'),
        )
      ],
    ).show();
    return res;
  }
}
