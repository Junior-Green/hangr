import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hangr/constants.dart';
import 'package:hangr/logic/cloud_storage.dart';
import 'package:hangr/logic/iap.dart';
import 'package:hangr/model/outfit.dart';
import 'package:hangr/model/wearable.dart';
import 'package:hangr/pages/hangr_pro.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CloudBackup extends StatefulWidget {
  final IAP iap;
  final CloudStorage storage;
  final MyWearables wearables;
  final MyOutfits outfits;
  const CloudBackup(this.iap, this.storage, this.wearables, this.outfits);

  @override
  State<CloudBackup> createState() => _CloudBackupState();
}

class _CloudBackupState extends State<CloudBackup> {
  late bool _isToggled;
  late final SharedPreferences prefs;
  late final Future<void> future;
  late final double _storagePercentage;
  late final double _screenWidth;
  late final Color _percentageAccent;

  @override
  void initState() {
    final imageCount =
        widget.wearables.getWearables.length + widget.outfits.getOutfits.length;
    _storagePercentage =
        imageCount >= storageLimit ? 1.0 : imageCount / storageLimit;

    future = _initData();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _percentageAccent = _getColor();
    _screenWidth = MediaQuery.of(context).size.width;
  }

  Future<void> _initData() async {
    prefs = await SharedPreferences.getInstance();
    _isToggled = (prefs.getBool('backup') ?? false) &&
        widget.iap.iapRepo.hasActiveSubscription;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 275,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Backup',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                if (_isToggled)
                                  Text(
                                    'Syncing will automatically occur in the background',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            activeColor: Theme.of(context).colorScheme.tertiary,
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
                                widget.storage.syncStorage();
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
                      if (_isToggled)
                        SizedBox(
                          width: _screenWidth * 3 / 4,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 5,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Storage'),
                                    const Spacer(),
                                    Text(
                                      '% ${_storagePercentage * 100}',
                                      style:
                                          TextStyle(color: _percentageAccent),
                                    ),
                                  ],
                                ),
                              ),
                              Stack(
                                alignment: AlignmentDirectional.centerStart,
                                children: [
                                  Container(
                                    width: _screenWidth * 3 / 4,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: Container(
                                      width: (_screenWidth * 3 / 4) *
                                          _storagePercentage,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              if (_storagePercentage >= 1)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    'Storage limit reached. Syncing paused.',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                )
                              else if (_storagePercentage >= 0.8)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    'Your storage is running low.',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                )
                            ],
                          ),
                        )
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Color _getColor() {
    if (_storagePercentage >= 1) {
      return Colors.red;
    } else if (_storagePercentage >= 0.8) {
      return Colors.yellow;
    }
    return Theme.of(context).colorScheme.onSecondary;
  }
}
