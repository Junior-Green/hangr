import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:hangr/pages/home_calendar.dart';
import 'package:hangr/pages/home_camera.dart';
import 'package:hangr/pages/home_wardrobe.dart';
import 'package:hangr/services/calendar_map.dart';
import 'package:hangr/services/camera.dart';
import 'package:hangr/services/outfit.dart';
import 'package:hangr/services/wearable.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final List<Outfit>? outfits;
  final List<Wearable>? wearables;
  final CalendarMap? calendarMap;
  final Camera camera;

  const Home({
    Key? key,
    required this.outfits,
    required this.wearables,
    required this.camera,
    required this.calendarMap,
  }) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  static const _tabs = [
    Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Tab(icon: Icon(Icons.add_a_photo_rounded, size: 30)),
    ),
    Tab(icon: Icon(Icons.calendar_month_rounded, size: 50)),
    Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Tab(icon: Icon(Icons.inventory, size: 30)),
    )
  ];

  ThemeData _theme = ThemeData.light();
  late final TabController _controller;

  bool _isTransparent = false;

  @override
  void initState() {
    _controller =
        TabController(length: _tabs.length, vsync: this, initialIndex: 1)
          ..addListener(() {
            setState(
              () => _isTransparent = _controller.index == 0,
            );
          });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    timeDilation = 0.25;

    return MultiProvider(
      providers: [
        Provider.value(
          value: null,
        ),
        Provider(create: (context) => null),
        Provider(create: (context) => null)
      ],
      child: Scaffold(
        body: TabBarView(
          controller: _controller,
          physics:
              (_controller.index == 1) ? const NeverScrollableScrollPhysics() : null,
          children: [
            HomeCamera(cameras: widget.camera),
            const HomeCalendar(),
            HomeWardrobe(),
          ],
        ),
        bottomNavigationBar: _isTransparent
            ? const SizedBox(width: 0, height: 0)
            : TabBar(
                onTap: (index) => HapticFeedback.mediumImpact(),
                enableFeedback: true,
                controller: _controller,
                tabs: _tabs,
                indicatorWeight: 3,
                labelPadding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                indicatorPadding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                labelColor: _isTransparent
                    ? Colors.transparent
                    : _theme.colorScheme.tertiary,
                unselectedLabelColor: _isTransparent
                    ? Colors.transparent
                    : _theme.colorScheme.onSecondary,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: _isTransparent
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.tertiary,
              ),
      ),
    );
  }
}
