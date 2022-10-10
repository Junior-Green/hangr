import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hangr/widgets/calendar_date.dart';
import 'package:indexed_list_view/indexed_list_view.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:ntp/ntp.dart';

class HomeCalendar extends StatefulWidget {
  const HomeCalendar({Key? key}) : super(key: key);

  @override
  State<HomeCalendar> createState() => _HomeCalendarState();
}

class _HomeCalendarState extends State<HomeCalendar> {
  late final DateTime _today;
  late final IndexedScrollController _controller;
  late DateTime _currentDate;
  late final Future<void> _future;

  static const _monthToString = {
    1: "January",
    2: "February",
    3: "March",
    4: "April",
    5: "May",
    6: "June",
    7: "July",
    8: "August",
    9: "September",
    10: "October",
    11: "November",
    12: "December",
  };

  @override
  void initState() {
    _controller = IndexedScrollController(initialScrollOffset: -200);
    _future = _fetchTime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => NotificationListener(
        onNotification: _onNotification,
        child: FutureBuilder<void>(
          future: _future,
          builder: (context, snapshot) =>
              snapshot.connectionState != ConnectionState.waiting
                  ? Scaffold(
                      appBar: _appBar,
                      body: _body,
                      extendBodyBehindAppBar: true,
                    )
                  : Container(),
        ),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  PreferredSizeWidget get _appBar => PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: context.watch<ValueNotifier<bool>>().value ? 1 : 0,
          child: ColoredBox(
            color: Theme.of(context).colorScheme.secondary.withAlpha(150),
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 10.0),
                child: AppBar(
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarIconBrightness:
                        Theme.of(context).colorScheme.brightness,
                    statusBarBrightness:
                        Theme.of(context).colorScheme.brightness,
                  ),
                  elevation: 0,
                  titleSpacing: 0,
                  centerTitle: true,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(
                        flex: 2,
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          "${_monthToString[_currentDate.month]!} ${_currentDate.year}",
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.more_horiz_rounded,
                          size: 30,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        padding: EdgeInsets.zero,
                      )
                    ],
                  ),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ),
      );

  Widget get _body => IndexedListView.separated(
        controller: _controller,
        itemBuilder: (context, index) => VisibilityDetector(
          key: Key(index.toString()),
          onVisibilityChanged: (VisibilityInfo info) {
            if (info.visibleFraction == 1) {
              setState(
                () => _currentDate =
                    DateTime(_today.year, _today.month, _today.day + index),
              );
            }
          },
          child: CalendarDate(
            DateTime(_today.year, _today.month, _today.day + index),
          ),
        ),
        separatorBuilder: (BuildContext context, int index) => const SizedBox(
          height: 50,
        ),
      );

  bool _onNotification(Object? notificationInfo) {
    setState(() {
      if (notificationInfo is ScrollStartNotification) {
        context.read<ValueNotifier<bool>>().value = false;
      } else if (notificationInfo is ScrollEndNotification) {
        context.read<ValueNotifier<bool>>().value = true;
      }
    });
    return true;
  }

  Future<void> _fetchTime() async {
    await NTP.now(timeout: const Duration(milliseconds: 3000)).then(
      (time) {
        _today = DateTime(time.year, time.month, time.day);
        _currentDate = _today;
      },
      onError: (error, trace) async {
        await _showErrorMessage();
        _today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        _currentDate = _today;
      },
    );
  }

  Future<bool?> _showErrorMessage() => Alert(
        context: context,
        type: AlertType.none,
        title: 'Connection Error',
        desc:
            "An error occured trying to connect to the internet. The device's time will be used.",
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
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: const Text('Okay'),
          )
        ],
      ).show();
}
