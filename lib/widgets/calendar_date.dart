import 'package:flutter/material.dart';
import 'package:hangr/services/calendar_map.dart';
import 'package:hangr/services/outfit.dart';
import 'package:provider/provider.dart';

class CalendarDate extends StatefulWidget {
  final DateTime _date;
  const CalendarDate(this._date);

  @override
  State<CalendarDate> createState() => _CalendarDateState();
}

class _CalendarDateState extends State<CalendarDate> {
  static final _today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  static const _dayToString = {
    1: "MON",
    2: "TUE",
    3: "WED",
    4: "THU",
    5: "FRI",
    6: "SAT",
    7: "SUN"
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                border: Border.all(
                    color: Theme.of(context).colorScheme.secondary, width: 5,),),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _getContents(context),),),
      ),
    );
  }

  List<Widget> _getContents(BuildContext context) {
    final List<Widget> list = [];

    list.add(const Spacer(
      flex: 2,
    ),);

    list.add(
      Text(_dayToString[widget._date.weekday]!,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontSize: 40,
              fontWeight: FontWeight.bold,),),
    );

    list.add(Text(widget._date.day.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: widget._date.isBefore(_today)
              ? Theme.of(context).colorScheme.onSecondary
              : Theme.of(context).colorScheme.onPrimary,
          fontSize: 200,
        ),),);

    final CalendarMap? map = context.read<CalendarMap?>();
    final Outfit? outfit  = map?.getFromDate(widget._date);

    if (outfit != null && widget._date.isBefore(_today)) {
      list.add(IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {},
          icon: const Icon(
            Icons.remove_red_eye_outlined,
            color: Colors.white,
            size: 50,
          ),),);
    } else if (!widget._date.isBefore(_today)) {
      list.add(Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.tertiary,),
        child: IconButton(
          padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
          onPressed: () {},
          icon: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
      ),);
    }

    list.add(const Spacer(
      flex: 2,
    ),);

    return list;
  }
}
