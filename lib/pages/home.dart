import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hangr/pages/home_calendar.dart';
import 'package:hangr/pages/home_camera.dart';
import 'package:hangr/pages/home_wardrobe.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late final TabController _controller;
  final ValueNotifier<bool> _isVisible = ValueNotifier(true);

  @override
  void initState() {
    _controller =
        TabController(length: _tabs.length, vsync: this, initialIndex: 1);
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
              child: const HomeCalendar(),
            ),
            HomeWardrobe(homeTabController: _controller,),
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
          child: Tab(icon: Icon(CupertinoIcons.bag_fill, size: 25)),
        )
      ];
}
