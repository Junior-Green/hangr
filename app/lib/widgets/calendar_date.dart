import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hangr/logic/cloud_storage.dart';
import 'package:hangr/logic/page_transition.dart';
import 'package:hangr/model/calendar_map.dart';
import 'package:hangr/model/outfit.dart';
import 'package:hangr/model/wearable.dart';
import 'package:hangr/pages/calendar_outfit.dart';
import 'package:provider/provider.dart';

class CalendarDate extends StatefulWidget {
  final DateTime _date;

  const CalendarDate(this._date);

  @override
  State<CalendarDate> createState() => _CalendarDateState();
}

class _CalendarDateState extends State<CalendarDate> {
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
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary,
              width: 5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _getContents(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _getContents(BuildContext context) {
    final List<Widget> list = [];

    list.addAll([
      const Spacer(
        flex: 2,
      ),
      Text(
        _dayToString[widget._date.weekday]!,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        widget._date.day.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: widget._date.isBefore(context.read<DateTime>())
              ? Theme.of(context).colorScheme.onSecondary
              : Theme.of(context).colorScheme.onPrimary,
          fontSize: 200,
        ),
      ),
    ]);

    final CalendarMap map = context.read<CalendarMap>();
    final MyWearables wearables = context.read<MyWearables>();
    final MyOutfits outfits = context.read<MyOutfits>();

    final List<String> outfit = map.getOutfitFromDate(widget._date);

    if (outfit.isNotEmpty && widget._date.isBefore(context.read<DateTime>())) {
      list.add(
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            HapticFeedback.lightImpact();
            await fadeInPageTransition(
              context,
              ChangeNotifierProvider.value(
                value: context.read<CloudStorage>(),
                child: CalendarOutfit(
                  map: map,
                  outfits: outfits,
                  wearables: wearables,
                  date: widget._date,
                ),
              ),
              const Duration(milliseconds: 250),
            );
          },
          icon: Icon(
            CupertinoIcons.eye_fill,
            color: Theme.of(context).colorScheme.tertiary,
            size: 50,
          ),
        ),
      );
    } else if (!widget._date.isBefore(context.read<DateTime>())) {
      list.add(
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          child: IconButton(
            padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
            onPressed: () async {
              HapticFeedback.lightImpact();
              await fadeInPageTransition(
                context,
                ChangeNotifierProvider.value(
                  value: context.read<CloudStorage>(),
                  child: CalendarOutfit(
                    map: map,
                    outfits: outfits,
                    wearables: wearables,
                    date: widget._date,
                    isEditable: true,
                  ),
                ),
                const Duration(milliseconds: 250),
              );
            },
            icon: const Icon(
              CupertinoIcons.forward,
              color: Colors.white,
              size: 25,
            ),
          ),
        ),
      );
    }

    list.add(
      const Spacer(
        flex: 2,
      ),
    );

    return list;
  }
}
