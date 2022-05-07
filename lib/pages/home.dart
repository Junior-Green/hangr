// ignore_for_file: prefer_const_constructors
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hangr/pages/home_calendar.dart';
import 'package:hangr/pages/home_camera.dart';
import 'package:hangr/pages/home_wardrobe.dart';

class Home extends StatefulWidget {
  
  const Home({
    Key? key,
    required this.cameras,
  }) : super(key: key);

  static final tabs = [
    const Tab(icon: Icon(Icons.camera_alt_rounded, size: 50)),
    const Tab(icon: Icon(Icons.calendar_month_rounded, size: 50)),
    const Tab(icon: Icon(Icons.inventory, size: 50))
  ];

  final List<CameraDescription> cameras;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        children: [
          HomeCamera(),
          HomeCalendar(),
          HomeWardrobe(),
        ],
      ),
      bottomNavigationBar: TabBar(
        enableFeedback: true,
        tabs: Home.tabs,
        indicatorWeight: 3,
        labelPadding: EdgeInsets.fromLTRB(0, 0, 0, 40),
        indicatorPadding: EdgeInsets.fromLTRB(0, 0, 0, 30),
        labelColor: Color.fromARGB(255, 210, 3, 79),
        unselectedLabelColor: Color.fromARGB(255, 255, 255, 255),
        indicatorSize: TabBarIndicatorSize.label,
        overlayColor: MaterialStateProperty.all(Colors.white),
        indicatorColor: Color.fromARGB(255, 210, 3, 79),
      ),
      extendBody: true,
    );
  }
}
