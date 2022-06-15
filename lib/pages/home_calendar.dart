import 'package:flutter/material.dart';
import 'package:indexed_list_view/indexed_list_view.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:hangr/helpers/calendar_date.dart';

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
  bool _visible = true;

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
    _controller =
        IndexedScrollController(initialIndex: 0, initialScrollOffset: -200);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      child: Scaffold(
        appBar: _appBar,
        body: _body,
        extendBodyBehindAppBar: true,
      ),
      onNotification: _onNotification,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  PreferredSizeWidget get _appBar => PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 1000),
          opacity: _visible ? 1 : 0,
          child: AppBar(
            elevation: 0,
            titleSpacing: 0,
            centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(
                  flex: 3,
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    _monthToString[_currentDate.month]! +
                        " " +
                        _currentDate.year.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    maxLines: 2,
                  ),
                ),
                Spacer(
                  flex: 2,
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.settings,
                    size: 30,
                  ),
                  padding: EdgeInsets.all(0),
                )
              ],
            ),
            backgroundColor:
                Theme.of(context).colorScheme.secondary.withAlpha(200),
          ),
        ),
      );

  Widget get _body => IndexedListView.separated(
        controller: _controller,
        itemBuilder: (context, index) {
          return VisibilityDetector(
              key: Key(index.toString()),
              onVisibilityChanged: (VisibilityInfo info) {
                if (info.visibleFraction == 1)
                  setState(() {
                    _currentDate =
                        DateTime(_today.year, _today.month, _today.day + index);
                  });
              },
              child: CalendarDate(
                  DateTime(_today.year, _today.month, _today.day + index),
                  null));
        },
        separatorBuilder: (BuildContext context, int index) => SizedBox(
          height: 50,
        ),
      );

  bool _onNotification(Object? notificationInfo) {
    setState(() {
      if (notificationInfo is ScrollStartNotification) {
        _visible = false;
      } else if (notificationInfo is ScrollEndNotification) {
        _visible = true;
      }
    });
    return true;
  }
}
