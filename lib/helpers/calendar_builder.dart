import 'package:flutter/material.dart';
import 'package:hangr/helpers/calendar_date.dart';

class CalendarBuilder {
  
  const CalendarBuilder();

  Widget build(DateTime date) {
    return GridView.count(
      crossAxisCount: 7,
      physics: NeverScrollableScrollPhysics(),
      children: _getWidgetList(date),
    );
  }

  List<Widget> _getWidgetList(DateTime date) {
    List<Widget> list = [];

    DateTime curr = DateTime(date.year, date.month, 1);
    final int month = curr.month;
    int counter = 7;

    while (counter != curr.weekday) {
      if (counter > 7) counter = 1;
      list.add(Container());
      counter++;
    }

    while (curr.month == month) {
      list.add(CalendarDate(curr));
      curr = curr.add(Duration(days: 1));
    }

    return list;
  }
}
