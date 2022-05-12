import 'package:flutter/material.dart';
import 'package:hangr/helpers/outfit.dart';

class CalendarDate extends StatefulWidget {
  static final _today = DateTime.now();
  final DateTime _date;
  Outfit? _outfit;

  CalendarDate(this._date, {Key? key}) : super(key: key);

  @override
  State<CalendarDate> createState() => _CalendarDateState();
}

class _CalendarDateState extends State<CalendarDate> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(
                    color: Theme.of(context).colorScheme.secondary))),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: _getContents(context)));
  }

  List<Widget> _getContents(BuildContext context) {
    final List<Widget> list = [];

    list.add(
      Padding(
          padding: EdgeInsets.all(5),
          child: Text(widget._date.day.toString(),
              style: TextStyle(
                  color: widget._date.isBefore(CalendarDate._today)
                      ? Theme.of(context).colorScheme.onSecondary
                      : null))),
    );

    if (widget._outfit != null) {
      list.add(Icon(
        Icons.check_circle_rounded,
        color: Theme.of(context).colorScheme.tertiary,
      ));
    }

    return list;
  }
}
