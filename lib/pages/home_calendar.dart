import 'package:flutter/material.dart';
import 'package:hangr/helpers/calendar_builder.dart';

class HomeCalendar extends StatefulWidget {
  const HomeCalendar({Key? key}) : super(key: key);

  @override
  State<HomeCalendar> createState() => _HomeCalendarState();
}

class _HomeCalendarState extends State<HomeCalendar> {
  static final _today = DateTime.now();
  static final _firstDay = DateTime(1900);
  static final _startingIndex =
      (_today.difference(_firstDay).inDays ~/ 365) * 12;
  static const appBarTextStyle =
      TextStyle(fontSize: 10, fontWeight: FontWeight.bold);

  static const calendarBuilder = CalendarBuilder();

  late int _currentPage;
  late DateTime _currentDate;
  late final PageController _pageController;

  navigateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  getCurrentPage(int page) {
    int currYear = _currentDate.year;
    int currMonth = _currentDate.month;

    if (_currentPage - page < 1) {
      _currentDate = DateTime(currYear, currMonth + 1);
    } else {
      _currentDate = DateTime(currYear, currMonth - 1);
    }
    _currentPage = page;
  }

  Widget getPage(DateTime date) {
    return calendarBuilder.build(date);
  }

  @override
  void initState() {
    _currentPage = 0;
    _currentDate = _today;
    _pageController = PageController(initialPage: _startingIndex);
    _currentPage = _startingIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        bottom: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: _daysOfWeek,
            ),
            preferredSize: Size.zero),
      ),
      body: Center(
        child: Container(
          color: Theme.of(context).colorScheme.primary,
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            allowImplicitScrolling: true,
            onPageChanged: getCurrentPage,
            itemBuilder: (context, _index) {
              int currYear = _currentDate.year;
              int monthDiff = _currentDate.month + _currentPage - _index;
              return getPage(DateTime(currYear, monthDiff));
            },
          ),
        ),
      ),
    );
  }

  Widget get _daysOfWeek => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const <Text>[
            Text("S", style: appBarTextStyle),
            Text("M", style: appBarTextStyle),
            Text("T", style: appBarTextStyle),
            Text("W", style: appBarTextStyle),
            Text("T", style: appBarTextStyle),
            Text("F", style: appBarTextStyle),
            Text("S", style: appBarTextStyle)
          ]);
}
