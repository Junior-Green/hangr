import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hangr/pages/calendar_outfit.dart';
import 'package:hangr/pages/home_calendar.dart';
import 'package:hangr/pages/home_camera.dart';
import 'package:hangr/pages/home_wardrobe.dart';
import 'package:hangr/services/calendar_map.dart';
import 'package:hangr/services/custom_icons.dart';
import 'package:hangr/services/outfit.dart';
import 'package:hangr/services/page_transition.dart';
import 'package:hangr/services/shortcut_items.dart';
import 'package:hangr/services/wearable.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';

enum DateJump { none, today, tomorrow }

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late final TabController _controller;
  DateJump _date = DateJump.none;
  final ValueNotifier<bool> _isVisible = ValueNotifier(true);

  @override
  void initState() {
    _controller =
        TabController(length: _tabs.length, vsync: this, initialIndex: 1);
    _handleQuickActions();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: TabBarView(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            HomeCamera(_controller),
            ListenableProvider.value(
              value: _isVisible,
              child: HomeCalendar(
                date: _date,
              ),
            ),
            HomeWardrobe(_controller),
          ],
        ),
        bottomNavigationBar: ValueListenableBuilder<bool>(
          builder: (BuildContext context, value, Widget? child) =>
              AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: value ? 1 : 0,
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              child: ColoredBox(
                color: Theme.of(context).colorScheme.primary,
                child: TabBar(
                  onTap: (index) {
                    if ((_controller.indexIsChanging &&
                            _controller.previousIndex == 0) ||
                        _controller.index == 0) {
                      _controller.index = 0;
                    } else {
                      HapticFeedback.mediumImpact();
                    }
                  },
                  enableFeedback: true,
                  controller: _controller,
                  tabs: _tabs,
                  indicatorWeight: 3,
                  labelPadding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                  indicatorPadding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                  labelColor: Theme.of(context).colorScheme.tertiary,
                  unselectedLabelColor:
                      Theme.of(context).colorScheme.onSecondary,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
          ),
          valueListenable: _isVisible,
        ),
        extendBody: true,
      );

  List<Widget> get _tabs => [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Tab(icon: Icon(CupertinoIcons.camera_fill, size: 25)),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          child: Tab(icon: Icon(CupertinoIcons.calendar, size: 50)),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Tab(icon: Icon(CustomIcons.hanger, size: 30)),
        )
      ];

  void _handleQuickActions() {
    const QuickActions quickActions = QuickActions();
    quickActions.initialize((shortcutType) {
      if (shortcutType == addClothing.type) {
        if (_controller.index != 0) {
          Navigator.popUntil(context, (route) => route.isFirst);
          _controller.animateTo(0);
        }
      }
      if (shortcutType == planTomorrow.type) {
        Navigator.popUntil(context, (route) => route.isFirst);
        fadeInPageTransition(
          context,
          CalendarOutfit(
            map: context.read<CalendarMap>(),
            outfits: context.read<MyOutfits>(),
            wearables: context.read<MyWearables>(),
            date: context.read<DateTime>().add(const Duration(days: 1)),
            isEditable: true,
          ),
          const Duration(milliseconds: 100),
        );
      }
      if (shortcutType == planToday.type) {
        Navigator.popUntil(context, (route) => route.isFirst);
        slideDownPageTransition(
          context,
          CalendarOutfit(
            map: context.read<CalendarMap>(),
            outfits: context.read<MyOutfits>(),
            wearables: context.read<MyWearables>(),
            date: context.read<DateTime>(),
            isEditable: true,
          ),
          const Duration(milliseconds: 100),
        );
      }
      if (shortcutType == viewWardrobe.type) {
        if (_controller.index == 1) {
          Navigator.popUntil(context, (route) => route.isFirst);
          _controller.animateTo(2);
        }
      }
    });
    quickActions.setShortcutItems(shortcutItems);
  }
}
