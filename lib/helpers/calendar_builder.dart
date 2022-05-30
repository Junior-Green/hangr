import 'package:flutter/material.dart';
import 'package:hangr/helpers/calendar_date.dart';

class CalendarBuilder extends StatefulWidget {
  final DateTime _date;
  const CalendarBuilder(this._date, {Key? key}) : super(key: key);

  @override
  State<CalendarBuilder> createState() => _CalendarBuilderState();
}

class _CalendarBuilderState extends State<CalendarBuilder>
    with AutomaticKeepAliveClientMixin {
  static const Map<int, String> _months = {
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
    12: "December"
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          _months[widget._date.month]!,
          style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontWeight: FontWeight.bold,
              fontSize: 50),
        ),
        Text(
          widget._date.year.toString(),
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary, fontSize: 30),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
          child: GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: _getWidgetList(widget._date),
          ),
        ),
      ],
    );
  }

  List<Widget> _getWidgetList(DateTime date) {
    List<Widget> list = [];

    DateTime curr = DateTime(date.year, date.month, 1);
    final int month = curr.month;
    int counter = 7;

    while (counter != curr.weekday) {
      if (counter > 7) counter = 1;
      list.add(SizedBox.expand());
      counter++;
    }

    while (curr.month == month) {
      list.add(CalendarDate(curr));
      curr = curr.add(Duration(days: 1));
    }

    return list;
  }

  @override
  bool get wantKeepAlive => true;
}
