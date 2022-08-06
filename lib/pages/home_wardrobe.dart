import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hangr/services/custom_icons.dart';
import 'package:hangr/widgets/no_opacity_flexible_space_bar.dart';
import 'package:provider/provider.dart';

class HomeWardrobe extends StatefulWidget {
  @override
  State<HomeWardrobe> createState() => _HomeWardrobeState();
}

class _HomeWardrobeState extends State<HomeWardrobe> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxScrolled) => <Widget>[
              createSilverAppBar1(),
              createSilverAppBar2(),
              createSliverGrid()
            ],
            body: Container(),
          ),
        ),
      );

  SliverAppBar createSilverAppBar1() => SliverAppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        expandedHeight: 125,
        elevation: 0,
        flexibleSpace: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              child: const NoOpacityFlexibleSpaceBar(
                title: Text(
                  'Wardrobe',
                  textAlign: TextAlign.start,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                ),
                titlePadding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                centerTitle: false,
                stretchModes: [],
                expandedTitleScale: 1,
              ),
            ),
          ),
        ),
      );

  SliverAppBar createSilverAppBar2() {
    return SliverAppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      pinned: true,
      primary: false,
      floating: true,
      toolbarHeight: 160,
      expandedHeight: 110,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) =>
            Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                constraints: const BoxConstraints.expand(
                  height: 32,
                  width: double.infinity,
                ),
                child: CupertinoSlidingSegmentedControl<bool>(
                  thumbColor: Theme.of(context).colorScheme.tertiary,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  onValueChanged: (value) {},
                  groupValue: true,
                  children: const <bool, Widget>{
                    true: Text('Clothes'),
                    false: Text('Outfits')
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      flex: 5,
                      child: CupertinoSearchTextField(
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        icon: const Icon(Icons.filter_alt_rounded),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(CupertinoIcons.sort_down),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(CustomIcons.top),
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(CustomIcons.bottom),
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(CustomIcons.footwear),
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(CustomIcons.accessory),
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(CustomIcons.headwear),
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverGrid createSliverGrid() => SliverGrid.count(
        crossAxisCount: 4,
        children: context.watch<>(),
      );
}
