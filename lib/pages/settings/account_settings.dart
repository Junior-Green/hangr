import 'package:flutter/material.dart';
import 'package:hangr/pages/hangr_pro.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  late final SharedPreferences prefs;
  bool isProMember = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      prefs = value;
      isProMember = prefs.getBool('is_premium_user') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text(
            'Reminders',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
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
                if (!isProMember) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Divider(
                      color: Theme.of(context).colorScheme.secondary,
                      thickness: 1.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await HangrPro.showPremiumBottomSheet(context);
                      setState(() {});
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Row(
                      children: [
                        Text(
                          'Upgrade',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Divider(
                      color: Theme.of(context).colorScheme.secondary,
                      thickness: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}
