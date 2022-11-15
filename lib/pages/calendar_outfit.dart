import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focused_menu/modals.dart';
import 'package:hangr/services/calendar_map.dart';
import 'package:hangr/services/custom_icons.dart';
import 'package:hangr/services/outfit.dart';
import 'package:hangr/services/wearable.dart';
import 'package:hangr/widgets/zoomable_wearable.dart';

class CalendarOutfit extends StatefulWidget {
  final DateTime date;
  final CalendarMap map;
  final MyOutfits outfits;
  final MyWearables wearables;
  final bool isEditable;

  const CalendarOutfit({
    Key? key,
    required this.map,
    required this.outfits,
    required this.wearables,
    required this.date,
    this.isEditable = false,
  }) : super(key: key);

  @override
  State<CalendarOutfit> createState() => _CalendarOutfitState();
}

class _CalendarOutfitState extends State<CalendarOutfit> {
  final _tops = <Wearable>[];
  final _bottoms = <Wearable>[];
  final _headwears = <Wearable>[];
  final _footwears = <Wearable>[];
  final _accessories = <Wearable>[];

  @override
  void initState() {
    final List<String> ids = widget.map.getOutfitFromDate(widget.date);
    final notFindable = <String>[];
    if (ids.isNotEmpty) {
      for (final id in ids) {
        final index = widget.wearables.getWearables
            .indexWhere((element) => element.id == id);

        if (index == -1) {
          notFindable.add(id);
          continue;
        }
        _addToList(widget.wearables.getWearables[index]);
      }
      while (notFindable.isNotEmpty) {
        ids.remove(notFindable.last);
        notFindable.remove(notFindable.last);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        persistentFooterAlignment: AlignmentDirectional.center,
        extendBody: true,
        appBar: _appBar,
        body: _body,
        floatingActionButton: widget.isEditable
            ? FloatingActionButton(
                onPressed: _getOutfitSelection,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                child: const Icon(CustomIcons.hanger, size: 25),
              )
            : null,
      );
  PreferredSizeWidget get _appBar => PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ColoredBox(
          color: Theme.of(context).colorScheme.secondary.withAlpha(150),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 10.0),
              child: AppBar(
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarIconBrightness:
                      Theme.of(context).colorScheme.brightness,
                  statusBarBrightness: Theme.of(context).colorScheme.brightness,
                ),
                automaticallyImplyLeading: false,
                elevation: 0,
                titleSpacing: 0,
                centerTitle: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _finalize,
                      icon: const Icon(CupertinoIcons.back),
                    ),
                    const Spacer(
                      flex: 4,
                    ),
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          '${widget.isEditable ? 'Build' : 'View'} Outfit',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(
                      flex: 6,
                    ),
                  ],
                ),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ),
      );

  Widget get _body => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Center(
          child: ListView(
            children: _getListChildren(),
          ),
        ),
      );

  List<Widget> _getListChildren() => [
        _getSectionHeader('Headwear'),
        _getListSection(WearableType.headwear, _headwears),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: Theme.of(context).colorScheme.onSecondary),
        ),
        _getSectionHeader('Top'),
        _getListSection(WearableType.top, _tops),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: Theme.of(context).colorScheme.onSecondary),
        ),
        _getSectionHeader('Bottom'),
        _getListSection(WearableType.bottom, _bottoms),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: Theme.of(context).colorScheme.onSecondary),
        ),
        _getSectionHeader('Footwear'),
        _getListSection(WearableType.footwear, _footwears),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: Theme.of(context).colorScheme.onSecondary),
        ),
        _getSectionHeader('Accessories'),
        _getListSection(WearableType.accessory, _accessories),
      ];

  Widget _getListSection(WearableType type, List<Wearable> wearables) =>
      ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 175,
        ),
        child: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          children: wearables
              .map<Widget>(
                (w) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ZoomableWearable(
                    widget.isEditable
                        ? [
                            FocusedMenuItem(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              title: const Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () => setState(() {
                                w.decrementTimeWorn();
                                wearables.remove(w);
                              }),
                              trailingIcon: const Icon(
                                CupertinoIcons.delete_solid,
                                color: Colors.red,
                                size: 25,
                              ),
                            )
                          ]
                        : [],
                    w,
                  ),
                ),
              )
              .toList()
            ..add(
              widget.isEditable ? _addPrompt(type, wearables) : Container(),
            ),
        ),
      );

  Widget _getSectionHeader(String s) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Text(
          s,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      );

  Widget _addPrompt(WearableType type, List<Wearable> wearables) =>
      GestureDetector(
        onTap: () async {
          await _getWearableSelection(type, wearables);
        },
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary,
                width: 2.5,
              ),
            ),
            position: DecorationPosition.foreground,
            child: Center(
              child: Icon(
                CupertinoIcons.add,
                color: Theme.of(context).colorScheme.secondary,
                size: 60,
              ),
            ),
          ),
        ),
      );

  Future<void> _getWearableSelection(
    WearableType type,
    List<Wearable> wearables,
  ) async {
    final List<Widget> wearablesToShow = widget.wearables.getWearables
        .where(
          (element) => element.type == type && !wearables.contains(element),
        )
        .map(
          (e) => Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() {
                wearables.add(e);
                e.incrementTimeWorn();
                Navigator.pop(context);
              }),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  child: Image.file(
                    File(e.imagePath),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 20.0,
            sigmaY: 10.0,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withAlpha(200),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: wearablesToShow.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 30),
                    height: 200,
                    child: Center(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: wearablesToShow,
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      'Nothing to add.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 25,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _getOutfitSelection() => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.transparent,
        builder: (context) => ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20.0,
              sigmaY: 10.0,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withAlpha(200),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: widget.outfits.getOutfits.isNotEmpty
                  ? Container(
                      margin: const EdgeInsets.fromLTRB(10, 20, 10, 30),
                      height: 200,
                      child: Center(
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: widget.outfits.getOutfits
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      _buildOuftit(e);
                                      Navigator.pop(context);
                                    }),
                                    child: AspectRatio(
                                      aspectRatio: 3 / 4,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(15),
                                        ),
                                        child: Image.file(
                                          File(e.imagePath),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        'No outfits saved.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 25,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      );

  Future<void> _finalize() async {
    await widget.map.updateOutfit(
      widget.date,
      _tops
          .followedBy(_headwears)
          .followedBy(_bottoms)
          .followedBy(_footwears)
          .followedBy(_accessories)
          .map((e) => e.id)
          .toList(),
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  void _buildOuftit(Outfit outfit) {
    _headwears.clear();
    _tops.clear();
    _bottoms.clear();
    _footwears.clear();
    _accessories.clear();
    final wearables = widget.wearables.getWearables;
    for (final id in outfit.wearableIds) {
      final wearable = wearables.firstWhere((element) => element.id == id);
      _addToList(wearable);
    }
  }

  void _addToList(Wearable wearable) {
    switch (wearable.type) {
      case WearableType.headwear:
        _headwears.add(wearable);
        break;
      case WearableType.top:
        _tops.add(wearable);
        break;
      case WearableType.bottom:
        _bottoms.add(wearable);
        break;
      case WearableType.footwear:
        _footwears.add(wearable);
        break;
      case WearableType.accessory:
        _accessories.add(wearable);
        break;
    }
  }
}
