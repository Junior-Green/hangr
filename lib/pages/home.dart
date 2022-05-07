import 'package:flutter/material.dart';
import 'package:hangr/pages/home_calendar.dart';
import 'package:hangr/pages/home_camera.dart';
import 'package:hangr/pages/home_wardrobe.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  static final tabs = [
    const Tab(icon: Icon(Icons.camera_alt_rounded, size: 50)),
    const Tab(icon: Icon(Icons.calendar_month_rounded, size: 50)),
    const Tab(icon: Icon(Icons.inventory, size: 50))
  ];

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map data = {};
  ThemeData theme = ThemeData.light();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context)!.settings.arguments as Map;
    theme = Theme.of(context);

    return Scaffold(
      body: TabBarView(
        children: [
          HomeCamera(
              camera: data['camera']),
          HomeCalendar(),
          HomeWardrobe(),
        ],
      ),
      bottomNavigationBar: TabBar(
        enableFeedback: true,
        tabs: Home.tabs,
        indicatorWeight: 3,
        labelPadding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
        indicatorPadding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
        labelColor: theme.colorScheme.secondary,
        unselectedLabelColor: theme.colorScheme.tertiary,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: theme.colorScheme.secondary,
      ),
      extendBody: true,
    );
  }
}
