import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hangr/services/notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Reminders extends StatefulWidget {
  final Notifications _notificationsHandler;
  const Reminders(this._notificationsHandler);

  @override
  State<Reminders> createState() => _RemindersState();
}

class _RemindersState extends State<Reminders> {
  late bool _isToggled;
  late DateTime _reminderTime;
  late final SharedPreferences prefs;
  late final Future<void> future;

  @override
  void initState() {
    tz.initializeTimeZones();
    future = _initData();
    super.initState();
  }

  Future<void> _initData() async {
    prefs = await SharedPreferences.getInstance();

    _reminderTime =
        _parseDateTime(prefs.getString('notifications_time') ?? '00:00');
    _isToggled = prefs.getBool('notifications') ?? false;

    tz.setLocalLocation(
      tz.getLocation(prefs.getString('time_zone') ?? 'Etc/Universal'),
    );
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
            'Reminders',
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
                              'Daily Reminders',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            CupertinoSwitch(
                              activeColor:
                                  Theme.of(context).colorScheme.tertiary,
                              value: _isToggled,
                              onChanged: (val) async {
                                _isToggled = val;
                                if (_isToggled) {
                                  final res = await widget._notificationsHandler
                                          .requestIOSPermissions() ??
                                      false;
                                  res
                                      ? await _scheduleReminders()
                                      : _isToggled = false;
                                } else {
                                  await widget._notificationsHandler
                                      .clearAllNotifications();
                                }
                                await prefs.setBool(
                                  'notifications',
                                  _isToggled,
                                );
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
                          padding: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                          child: GestureDetector(
                            onTap: () async {
                              await HapticFeedback.lightImpact();
                              _reminderTime = await _getTime(_reminderTime);
                              await prefs.setString(
                                'notifications_time',
                                DateFormat().add_Hm().format(_reminderTime),
                              );
                              await widget._notificationsHandler
                                  .clearAllNotifications();
                              await _scheduleReminders();
                              setState(() {});
                            },
                            child: Visibility(
                              visible: _isToggled,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Time:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    DateFormat().add_jm().format(_reminderTime),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      decoration: TextDecoration.underline,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      );
  Future<void> _scheduleReminders() async {
    final currentTime = tz.TZDateTime.now(tz.local);
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
      threadIdentifier: 'daily_reminder',
      categoryIdentifier: 'plan',
      interruptionLevel: InterruptionLevel.active,
    );
    const details = NotificationDetails(iOS: iOSDetails);
    return widget._notificationsHandler.scheduleReminders(
      'Daily Reminder',
      "Time to plan out tomorrow's outfit!",
      details,
      tz.TZDateTime.local(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        _reminderTime.hour,
        _reminderTime.minute,
      ),
      components: DateTimeComponents.time,
    );
  }

  Future<DateTime> _getTime(DateTime inititalTime) async {
    DateTime reminderTime = inititalTime;

    await showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        color: Theme.of(context).colorScheme.secondary,
        height: 300,
        child: CupertinoDatePicker(
          initialDateTime: reminderTime,
          mode: CupertinoDatePickerMode.time,
          onDateTimeChanged: (time) => reminderTime = time,
        ),
      ),
    );

    return reminderTime;
  }

  DateTime _parseDateTime(String time) => DateTime(
        1,
        1,
        1,
        int.parse(time.substring(0, 2)),
        int.parse(time.substring(3)),
      );
}
