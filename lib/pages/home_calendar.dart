import 'package:flutter/material.dart';

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
  int _currentPage = 0;
  DateTime _currentDate = DateTime.now();

  final PageController _pageController =
      PageController(initialPage: _startingIndex);

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

  Widget getCalendar(DateTime date) {
    return Container();
  }

  @override
  void initState() {
    super.initState();
    _currentPage = _startingIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        onPageChanged: getCurrentPage,
        itemBuilder: (context, _index) {
          int currYear = _currentDate.year;
          int currMonth = _currentDate.month;

          if (_currentPage - _index < 1) {
            return getCalendar(DateTime(currYear, currMonth + 1));
          } else {
            return getCalendar(DateTime(currYear, currMonth - 1));
          }
        },
      ),
    );
  }
}
