import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hangr/pages/settings/settings.dart';
import 'package:hangr/services/notifications.dart';
import 'package:hangr/services/page_transition.dart';
import 'package:hangr/services/theme_handler.dart';
import 'package:hangr/widgets/calendar_date.dart';
import 'package:indexed_list_view/indexed_list_view.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeCalendar extends StatefulWidget {
  final Notifications notifications;
  const HomeCalendar({Key? key, required this.notifications}) : super(key: key);

  @override
  State<HomeCalendar> createState() => _HomeCalendarState();
}

class _HomeCalendarState extends State<HomeCalendar> {
  late final DateTime _today = Provider.of<DateTime>(context, listen: false);
  late final IndexedScrollController _controller;
  late DateTime _currentDate = Provider.of<DateTime>(context, listen: false);

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

    super.initState();
  }

  @override
  Widget build(BuildContext context) => NotificationListener(
        onNotification: _onNotification,
        child: Scaffold(
          appBar: _appBar,
          body: _body,
          extendBodyBehindAppBar: true,
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
            color: Theme.of(context).colorScheme.secondary.withAlpha(200),
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
                      IconButton(
                          onPressed: goToDate,
                          icon: const Icon(CupertinoIcons.search),),
                      const Spacer(),
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
                        onPressed: () => slideRightPageTransition(
                          context,
                          Settings(
                            context.read<ThemeHandler>(),
                            context.read<Notifications>(),
                          ),
                          const Duration(milliseconds: 100),
                        ),
                        icon: Icon(
                          Icons.more_vert_rounded,
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
          child: Provider<DateTime>.value(
            value: _today,
            builder: (_, __) => CalendarDate(
              DateTime(_today.year, _today.month, _today.day + index),
              _today,
            ),
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

  Future<void> goToDate() async {
    DateTime date = context.read<DateTime>();

    await showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        color: Theme.of(context).colorScheme.secondary,
        height: 300,
        child: CupertinoDatePicker(
          initialDateTime: date,
          mode: CupertinoDatePickerMode.date,
          onDateTimeChanged: (time) => date = time,
        ),
      ),
    );
    if (!mounted) return;

    await _controller.animateToIndexAndOffset(
      index: date.difference(context.read<DateTime>()).inDays,
      offset: -200,
    );
  }
}
