import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hangr/pages/home_calendar.dart';
import 'package:hangr/pages/home_camera.dart';
import 'package:hangr/pages/home_wardrobe.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  Map _data = {};
  ThemeData _theme = ThemeData.light();
  TabController? _controller;
  bool _isTransparent = false;

  static const _tabs = [
    Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: const Tab(icon: Icon(Icons.add_a_photo_rounded, size: 30)),
    ),
    const Tab(icon: Icon(Icons.calendar_month_rounded, size: 50)),
    Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: const Tab(icon: Icon(Icons.inventory, size: 30)),
    )
  ];

  @override
  void initState() {
    _controller =
        new TabController(length: _tabs.length, vsync: this, initialIndex: 1);
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _data = ModalRoute.of(context)!.settings.arguments as Map;
    _theme = Theme.of(context);
    timeDilation = 0.25;

    _controller!.addListener(() {
      setState(() {
        _isTransparent = _controller!.index == 0 ? true : false;
      });
    });

    return Scaffold(
      body: TabBarView(
        controller: _controller,
        physics:
            (_controller!.index == 1) ? NeverScrollableScrollPhysics() : null,
        children: [
          HomeCamera(cameras: _data['camera']),
          HomeCalendar(),
          HomeWardrobe(),
        ],
      ),
      bottomNavigationBar: _isTransparent
          ? Container(width: 0, height: 0)
          : TabBar(
              onTap: (int index) {
                HapticFeedback.mediumImpact();
              },
              enableFeedback: true,
              isScrollable: false,
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
              overlayColor: null,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: _isTransparent
                  ? Colors.transparent
                  : _theme.colorScheme.tertiary,
            ),
      extendBody: true,
    );
  }
}
