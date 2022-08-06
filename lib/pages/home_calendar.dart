import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hangr/widgets/calendar_date.dart';
import 'package:indexed_list_view/indexed_list_view.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeCalendar extends StatefulWidget {
  const HomeCalendar({Key? key}) : super(key: key);

  @override
  State<HomeCalendar> createState() => _HomeCalendarState();
}

class _HomeCalendarState extends State<HomeCalendar> {
  static final _today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  late final IndexedScrollController _controller;
  DateTime _currentDate = _today;

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
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: _onNotification,
      child: Scaffold(
        appBar: _appBar,
        body: _body,
        extendBodyBehindAppBar: true,
      ),
    );
  }

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
          child: Container(
            color: Theme.of(context).colorScheme.secondary.withAlpha(150),
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 10.0),
                child: AppBar(
                  elevation: 0,
                  titleSpacing: 0,
                  centerTitle: true,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(
                        flex: 3,
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "${_monthToString[_currentDate.month]!} ${_currentDate.year}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 2,
                        ),
                      ),
                      const Spacer(
                        flex: 2,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.settings,
                          size: 30,
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
        itemBuilder: (context, index) {
          return VisibilityDetector(
            key: Key(index.toString()),
            onVisibilityChanged: (VisibilityInfo info) {
              if (info.visibleFraction == 1) {
                setState(() {
                  _currentDate =
                      DateTime(_today.year, _today.month, _today.day + index);
                });
              }
            },
            child: CalendarDate(
              DateTime(_today.year, _today.month, _today.day + index),
            ),
          );
        },
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
}
