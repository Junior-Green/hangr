// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focused_menu/modals.dart';
import 'package:hangr/logic/iap.dart';
import 'package:hangr/logic/page_transition.dart';
import 'package:hangr/model/calendar_map.dart';
import 'package:hangr/model/custom_icons.dart';
import 'package:hangr/model/outfit.dart';
import 'package:hangr/model/wearable.dart';
import 'package:hangr/pages/add_outfit.dart';
import 'package:hangr/pages/edit_outfit.dart';
import 'package:hangr/pages/edit_wearable.dart';
import 'package:hangr/pages/hangr_pro.dart';
import 'package:hangr/repo/iap_repo.dart';
import 'package:hangr/widgets/no_opacity_flexible_space_bar.dart';
import 'package:hangr/widgets/zoomable_outfit.dart';
import 'package:hangr/widgets/zoomable_wearable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum WearableSortType { none, name, color, brand, timesWorn, lastWorn }

enum OutfitSortType { none, name, primaryColor, secondaryColor }

enum WardrobeMode { clothes, outfits }

class HomeWardrobe extends StatefulWidget {
  final TabController homeTabController;

  const HomeWardrobe(this.homeTabController);
  @override
  State<HomeWardrobe> createState() => _HomeWardrobeState();
}

class _HomeWardrobeState extends State<HomeWardrobe> {
  late final _wearables = Provider.of<MyWearables>(context);
  late final _outfits = Provider.of<MyOutfits>(context);
  late final TextEditingController _textController;
  late final FixedExtentScrollController _scrollController;

  final _wearableTypeFilters = HashSet<WearableType>();
  final _outfitTypeFilters = HashSet<OutfitType>();
  final _attributeFilters = HashSet<String>();
  final _mode = ValueNotifier<WardrobeMode>(WardrobeMode.clothes);

  WearableSortType _wearableSortType = WearableSortType.none;
  OutfitSortType _outfitSortType = OutfitSortType.none;
  bool _sortDown = true;

  @override
  void initState() {
    _textController = TextEditingController();
    _scrollController = FixedExtentScrollController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(Duration.zero, () async {
      for (final wearable in _wearables.getWearables) {
        if (!mounted) return;
        final file = File(wearable.imagePath);
        if (await file.exists()) {
          await precacheImage(FileImage(file), context);
        }
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ValueListenableBuilder<WardrobeMode>(
            builder: (BuildContext context, value, Widget? child) =>
                NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxScrolled) => <Widget>[
                _createSilverAppBar1(),
                _createSilverAppBar2(value),
              ],
              body: _createGrid(value),
            ),
            valueListenable: _mode,
          ),
        ),
      );

  SliverAppBar _createSilverAppBar1() => SliverAppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        expandedHeight: 125,
        elevation: 0,
        flexibleSpace: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DecoratedBox(
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

  SliverAppBar _createSilverAppBar2(WardrobeMode mode) => SliverAppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        pinned: true,
        primary: false,
        floating: true,
        elevation: 0,
        toolbarHeight: 170,
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
                  child: CupertinoSlidingSegmentedControl<WardrobeMode>(
                    thumbColor: Theme.of(context).colorScheme.tertiary,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    onValueChanged: (value) {
                      _attributeFilters.clear();
                      _mode.value = value!;
                    },
                    groupValue: mode,
                    children: const <WardrobeMode, Widget>{
                      WardrobeMode.clothes: Text('Clothes'),
                      WardrobeMode.outfits: Text('Outfits')
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
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          prefixIcon: Icon(
                            CupertinoIcons.search,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                          suffixIcon: Icon(
                            CupertinoIcons.xmark_circle_fill,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                          onChanged: (input) => setState(() {}),
                          controller: _textController,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onLongPress: () => setState(() {
                            _attributeFilters.clear();
                            HapticFeedback.lightImpact();
                          }),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => _showFilterPicker(context),
                            icon: Icon(
                              Icons.filter_alt_rounded,
                              color: _attributeFilters.isEmpty
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onLongPress: () => setState(() {
                            _sortDown = !_sortDown;
                            HapticFeedback.lightImpact();
                          }),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => _showSortPicker(context),
                            icon: Icon(
                              _sortDown
                                  ? CupertinoIcons.sort_down
                                  : CupertinoIcons.sort_up,
                              color: (mode == WardrobeMode.clothes &&
                                          _wearableSortType ==
                                              WearableSortType.none) ||
                                      (mode == WardrobeMode.outfits &&
                                          _outfitSortType ==
                                              OutfitSortType.none)
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
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
                    children: mode == WardrobeMode.clothes
                        ? _clothesFilterButtons(context)
                        : _outfitsFilterButtons(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _createGrid(WardrobeMode mode) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: GridView.count(
          childAspectRatio:
              _wearableSortType == WearableSortType.none ? 3 / 4 : 9 / 13,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          crossAxisCount: 3,
          children: List<Widget>.from(
            mode == WardrobeMode.clothes ? _getWearables() : _getOutfits(),
          )..add(_wardrobeAddHint()),
        ),
      );

  List<IconButton> _clothesFilterButtons(BuildContext context) => [
        IconButton(
          onPressed: () => setState(
            () => _wearableTypeFilters.contains(WearableType.top)
                ? _wearableTypeFilters.remove(WearableType.top)
                : _wearableTypeFilters.add(WearableType.top),
          ),
          iconSize: 35,
          icon: const Icon(CustomIcons.top),
          color: _wearableTypeFilters.contains(WearableType.top)
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.onSecondary,
        ),
        IconButton(
          onPressed: () => setState(
            () => _wearableTypeFilters.contains(WearableType.bottom)
                ? _wearableTypeFilters.remove(WearableType.bottom)
                : _wearableTypeFilters.add(WearableType.bottom),
          ),
          iconSize: 35,
          icon: const Icon(CustomIcons.bottom),
          color: _wearableTypeFilters.contains(WearableType.bottom)
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.onSecondary,
        ),
        IconButton(
          onPressed: () => setState(
            () => _wearableTypeFilters.contains(WearableType.footwear)
                ? _wearableTypeFilters.remove(WearableType.footwear)
                : _wearableTypeFilters.add(WearableType.footwear),
          ),
          iconSize: 35,
          icon: const Icon(CustomIcons.footwear),
          color: _wearableTypeFilters.contains(WearableType.footwear)
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.onSecondary,
        ),
        IconButton(
          onPressed: () => setState(
            () => _wearableTypeFilters.contains(WearableType.accessory)
                ? _wearableTypeFilters.remove(WearableType.accessory)
                : _wearableTypeFilters.add(WearableType.accessory),
          ),
          iconSize: 35,
          icon: const Icon(CustomIcons.accessory),
          color: _wearableTypeFilters.contains(WearableType.accessory)
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.onSecondary,
        ),
        IconButton(
          onPressed: () => setState(
            () => _wearableTypeFilters.contains(WearableType.headwear)
                ? _wearableTypeFilters.remove(WearableType.headwear)
                : _wearableTypeFilters.add(WearableType.headwear),
          ),
          iconSize: 35,
          icon: const Icon(CustomIcons.headwear),
          color: _wearableTypeFilters.contains(WearableType.headwear)
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.onSecondary,
        ),
      ];

  List<IconButton> _outfitsFilterButtons(BuildContext context) => [
        IconButton(
          onPressed: () => setState(
            () => _outfitTypeFilters.contains(OutfitType.casual)
                ? _outfitTypeFilters.remove(OutfitType.casual)
                : _outfitTypeFilters.add(OutfitType.casual),
          ),
          icon: const Icon(CustomIcons.top),
          color: _outfitTypeFilters.contains(OutfitType.casual)
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.onSecondary,
          iconSize: 35,
        ),
        IconButton(
          onPressed: () => setState(
            () => _outfitTypeFilters.contains(OutfitType.semiFormal)
                ? _outfitTypeFilters.remove(OutfitType.semiFormal)
                : _outfitTypeFilters.add(OutfitType.semiFormal),
          ),
          icon: const Icon(CustomIcons.semiFormal),
          color: _outfitTypeFilters.contains(OutfitType.semiFormal)
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.onSecondary,
          iconSize: 35,
        ),
        IconButton(
          onPressed: () => setState(
            () => _outfitTypeFilters.contains(OutfitType.formal)
                ? _outfitTypeFilters.remove(OutfitType.formal)
                : _outfitTypeFilters.add(OutfitType.formal),
          ),
          icon: const Icon(CustomIcons.formal),
          color: _outfitTypeFilters.contains(OutfitType.formal)
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.onSecondary,
          iconSize: 35,
        ),
        IconButton(
          onPressed: () => setState(
            () => _outfitTypeFilters.contains(OutfitType.athletic)
                ? _outfitTypeFilters.remove(OutfitType.athletic)
                : _outfitTypeFilters.add(OutfitType.athletic),
          ),
          icon: const Icon(CustomIcons.athletic),
          padding: EdgeInsets.zero,
          color: _outfitTypeFilters.contains(OutfitType.athletic)
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.onSecondary,
          iconSize: 35,
        ),
      ];

  Widget _wardrobeAddHint() => GestureDetector(
        onTap: () async {
          await HapticFeedback.lightImpact();
          if (_mode.value == WardrobeMode.clothes) {
            widget.homeTabController.animateTo(0);
          } else {
            if (!mounted) return;
            final isPremiumMember =
                context.read<IAPRepo>().hasActiveSubscription;
            final outfitCount = _outfits.getOutfits.length;

            if (!mounted) return;

            if (!isPremiumMember && outfitCount >= 7) {
              await HangrPro.showProDialog(
                context,
                'Create and store an unlimited amount of outfits with Hangr Pro',
                context.read<IAP>(),
              );
              return;
            }

            if (!mounted) return;
            slideDownPageTransition(
              context,
              AddOutfit(_wearables, _outfits),
              const Duration(milliseconds: 300),
            );
          }
        },
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
      );

  List<Widget> _getWearables() {
    final filteredList = _wearables.getWearables
        .where(
          (element) =>
              (_wearableTypeFilters.isEmpty ||
                  _wearableTypeFilters.contains(element.type)) &&
              (_textController.text.isEmpty ||
                  element.name
                      .toLowerCase()
                      .contains(_textController.text.toLowerCase())) &&
              (_attributeFilters.isEmpty ||
                  _attributeFilters.contains(element.brand.toLowerCase()) ||
                  _attributeFilters
                      .contains(element.primaryColor.toLowerCase())),
        )
        .toList()
      ..sort(_wearableComparator);

    return filteredList
        .map<Widget>(
          (wearable) => ZoomableWearable(
            _getWearableMenuOptions(wearable, _outfits),
            wearable,
            _getWearableFilterLabel(wearable, _wearableSortType),
          ),
        )
        .toList();
  }

  List<Widget> _getOutfits() {
    final filteredList = _outfits.getOutfits
        .where(
          (element) =>
              (_outfitTypeFilters.isEmpty ||
                  _outfitTypeFilters.contains(element.type)) &&
              (_textController.text.isEmpty ||
                  element.name
                      .toLowerCase()
                      .contains(_textController.text.toLowerCase())) &&
              (_attributeFilters.isEmpty ||
                  (_attributeFilters
                          .contains(element.primaryColor.toLowerCase()) ||
                      _attributeFilters.contains(
                        element.secondaryColor.toLowerCase(),
                      ))),
        )
        .toList()
      ..sort(_outfitComparator);
    return filteredList
        .map(
          (outfit) => ZoomableOutfit(
            _getOutfitMenuOptions(outfit, _outfits),
            outfit,
          ),
        )
        .toList();
  }

  Future<void> _showFilterPicker(BuildContext context) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      isScrollControlled: true, // required for min/max child size
      context: context,
      elevation: 0,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 20.0,
            sigmaY: 10.0,
          ),
          child: ColoredBox(
            color: Theme.of(context).colorScheme.secondary.withAlpha(175),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: MultiSelectBottomSheet<String>(
                title: Text(
                  'Filters',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                searchable: true,
                selectedColor: Theme.of(context).colorScheme.tertiary,
                unselectedColor: Theme.of(context).colorScheme.onSecondary,
                selectedItemsTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                itemsTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                searchIcon: Icon(
                  CupertinoIcons.search,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                closeSearchIcon: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                confirmText: const Text(
                  'Confirm',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                cancelText: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                items: _getFilterOptions(),
                listType: MultiSelectListType.CHIP,
                initialValue: const [],
                onSelectionChanged: (filters) => setState(
                  () => _attributeFilters
                    ..clear()
                    ..addAll(
                      filters.toSet().map((e) => e.toLowerCase()).toList(),
                    ),
                ),
                maxChildSize: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<MultiSelectItem<String>> _getFilterOptions() {
    final filterSet = HashSet<String>();

    if (_mode.value == WardrobeMode.clothes) {
      for (final wearable in _wearables.getWearables) {
        filterSet.addAll([wearable.brand, wearable.primaryColor]);
      }
    } else {
      for (final outfit in _outfits.getOutfits) {
        filterSet.addAll([outfit.primaryColor, outfit.secondaryColor]);
      }
    }

    return filterSet
        .map((element) => MultiSelectItem(element, element))
        .toList();
  }

  Future<void> _showSortPicker(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 10.0),
          child: SizedBox(
            height: 200,
            child: CupertinoPicker(
              backgroundColor:
                  Theme.of(context).colorScheme.secondary.withAlpha(200),
              scrollController: FixedExtentScrollController(
                initialItem: _mode.value == WardrobeMode.clothes
                    ? _wearableSortType.index
                    : _outfitSortType.index,
              ),
              magnification: 1.25,
              useMagnifier: true,
              itemExtent: 30,
              onSelectedItemChanged: (index) => setState(
                () => _mode.value == WardrobeMode.clothes
                    ? _setWearableSortType(index)
                    : _setOutfitSortType(index),
              ),
              children: _getSortPickerOptions(context),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getSortPickerOptions(BuildContext context) {
    return _mode.value == WardrobeMode.clothes
        ? [
            Center(
              child: Text(
                'None',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            Center(
              child: Text(
                'Name',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            Center(
              child: Text(
                'Color',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            Center(
              child: Text(
                'Brand',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            Center(
              child: Text(
                'Times Worn',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            Center(
              child: Text(
                'Date Last Worn',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            )
          ]
        : [
            Center(
              child: Text(
                'None',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            Center(
              child: Text(
                'Name',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            Center(
              child: Text(
                'Primary Color',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            Center(
              child: Text(
                'Secondary Color',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ];
  }

  int _wearableComparator(Wearable a, Wearable b) {
    switch (_wearableSortType) {
      case WearableSortType.none:
        return 0;
      case WearableSortType.name:
        return _sortDown
            ? a.name.compareTo(b.name)
            : a.name.compareTo(b.name) * -1;
      case WearableSortType.brand:
        return _sortDown
            ? a.brand.compareTo(b.brand)
            : a.brand.compareTo(b.brand) * -1;
      case WearableSortType.color:
        return _sortDown
            ? a.primaryColor.compareTo(b.primaryColor)
            : a.primaryColor.compareTo(b.primaryColor) * -1;
      //TODO: LOOP FROM CURRENT DATE TO DATE CREATED TO FIND LAST WORN DATE
      case WearableSortType.lastWorn:
        _refreshLastWorn(a);
        _refreshLastWorn(b);
        if (a.last == null)
          return _sortDown ? 1 : -1;
        else if (b.last == null)
          return _sortDown ? 1 : -1;
        else {
          final res = a.last!.isAfter(b.last!) ? 1 : -1;
          return _sortDown ? res * -1 : res;
        }

      case WearableSortType.timesWorn:
        return _sortDown
            ? a.times.compareTo(b.times)
            : a.times.compareTo(b.times) * -1;
      default:
        return 0;
    }
  }

  int _outfitComparator(Outfit a, Outfit b) {
    switch (_outfitSortType) {
      case OutfitSortType.none:
        return 0;
      case OutfitSortType.name:
        return _sortDown
            ? a.name.compareTo(b.name)
            : a.name.compareTo(b.name) * -1;
      case OutfitSortType.primaryColor:
        return _sortDown
            ? a.primaryColor.compareTo(b.primaryColor)
            : a.primaryColor.compareTo(b.primaryColor) * -1;
      case OutfitSortType.secondaryColor:
        return _sortDown
            ? a.secondaryColor.compareTo(b.secondaryColor)
            : a.secondaryColor.compareTo(b.secondaryColor) * -1;
      default:
        return 0;
    }
  }

  List<FocusedMenuItem> _getWearableMenuOptions(
    Wearable w,
    MyOutfits outfits,
  ) =>
      [
        _createEditButton(
          () async {
            await slideDownPageTransition(
              context,
              EditWearable(w, _wearables),
              const Duration(milliseconds: 300),
            );
            setState(() {});
          },
        ),
        _createShareButton(
          () => Share.shareXFiles(
            [XFile(w.imagePath, mimeType: 'images/jpg')],
            subject: 'Check out ${_getWearableSubjectSuffix(w)}',
            text: 'Look at my ${w.name} I got from ${w.brand}.',
          ),
        ),
        _createDeleteButton(
          () async {
            if (outfits.containsWearable(w.id)) {
              await _showWearableDeleteAlert(w);
              return;
            }
            await _wearables.removeWearable(w);
          },
        ),
      ];
  List<FocusedMenuItem> _getOutfitMenuOptions(
    Outfit outfit,
    MyOutfits outfits,
  ) =>
      [
        _createEditButton(
          () async => slideDownPageTransition(
            context,
            EditOutfit(outfit, _outfits, _wearables),
            const Duration(milliseconds: 300),
          ),
        ),
        _createShareButton(
          () => Share.shareXFiles(
            [XFile(outfit.imagePath, mimeType: 'images/jpg')],
            subject: 'Check out ${_getOutfitSubjectSuffix(outfit)}',
          ),
        ),
        _createDeleteButton(() => outfits.removeOutfit(outfit)),
      ];

  String _getWearableSubjectSuffix(Wearable w) {
    switch (w.type) {
      case WearableType.accessory:
        return 'this piece of accessory!';
      case WearableType.bottom:
        return 'these bottoms!';
      case WearableType.top:
        return 'this top!';
      case WearableType.headwear:
        return 'this headwear';
      case WearableType.footwear:
        return 'these shoes!';
      default:
        return 'my clothing!';
    }
  }

  String _getOutfitSubjectSuffix(Outfit outfit) {
    switch (outfit.type) {
      case OutfitType.formal:
        return 'my formal outfit!';
      case OutfitType.casual:
        return 'my casual outfit!';
      case OutfitType.semiFormal:
        return 'my semi-formal outfit!';
      case OutfitType.athletic:
        return 'my sports outfit';
      default:
        return 'my outfit!';
    }
  }

  FocusedMenuItem _createEditButton(Function onPressed) => FocusedMenuItem(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(
          'Edit',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: onPressed,
        trailingIcon: Icon(
          CupertinoIcons.pen,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 25,
        ),
      );

  FocusedMenuItem _createShareButton(Function onPressed) => FocusedMenuItem(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(
          'Share',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: onPressed,
        trailingIcon: Icon(
          CupertinoIcons.share_solid,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 25,
        ),
      );

  FocusedMenuItem _createDeleteButton(Function onPressed) => FocusedMenuItem(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: const Text(
          'Delete',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        onPressed: onPressed,
        trailingIcon: const Icon(
          CupertinoIcons.delete_solid,
          color: Colors.red,
          size: 25,
        ),
      );

  void _setOutfitSortType(int index) {
    switch (index) {
      case 0:
        _outfitSortType = OutfitSortType.none;
        break;
      case 1:
        _outfitSortType = OutfitSortType.name;
        break;
      case 2:
        _outfitSortType = OutfitSortType.primaryColor;
        break;
      case 3:
        _outfitSortType = OutfitSortType.secondaryColor;
        break;
      default:
        _outfitSortType = OutfitSortType.none;
        break;
    }
  }

  void _setWearableSortType(int index) {
    switch (index) {
      case 0:
        _wearableSortType = WearableSortType.none;
        break;
      case 1:
        _wearableSortType = WearableSortType.name;
        break;
      case 2:
        _wearableSortType = WearableSortType.color;
        break;
      case 3:
        _wearableSortType = WearableSortType.brand;
        break;
      case 4:
        _wearableSortType = WearableSortType.timesWorn;
        break;
      case 5:
        _wearableSortType = WearableSortType.lastWorn;
        break;
      default:
        _wearableSortType = WearableSortType.none;
        break;
    }
  }

  Future<bool?> _showWearableDeleteAlert(Wearable w) => Alert(
        context: context,
        type: AlertType.none,
        title: 'Warning',
        desc:
            "Deleting this piece will delete all outfits that contain it. Would you like to delete?",
        style: AlertStyle(
          animationType: AnimationType.grow,
          isOverlayTapDismiss: false,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          alertBorder: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
          ),
          isCloseButton: false,
          titleStyle: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
          descStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 15,
          ),
        ),
        buttons: [
          DialogButton(
            height: 35,
            radius: const BorderRadius.all(Radius.circular(8)),
            color: Theme.of(context).colorScheme.tertiary,
            onPressed: () async {
              _outfits.removeOutfitsWithWearable(w.id);
              await _wearables.removeWearable(w);

              if (!mounted) {
                return;
              }

              Navigator.of(context, rootNavigator: true).pop();
            },
            child: const Text('Delete'),
          ),
          DialogButton(
            height: 35,
            color: Theme.of(context).colorScheme.tertiary,
            radius: const BorderRadius.all(Radius.circular(8)),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Cancel'),
          )
        ],
      ).show();

  String? _getWearableFilterLabel(
    Wearable w,
    WearableSortType wearableSortType,
  ) {
    switch (wearableSortType) {
      case WearableSortType.none:
        return null;
      case WearableSortType.name:
        return w.name;
      case WearableSortType.color:
        return w.primaryColor;

      case WearableSortType.brand:
        return w.brand;
      case WearableSortType.timesWorn:
        return w.timesWorn.toString();
      case WearableSortType.lastWorn:
        return _formatLastWornLabel(w.last);
    }
  }

  void _refreshLastWorn(Wearable w) {
    final map = context.read<CalendarMap>();
    DateTime startDate = context.read<DateTime>();
    final DateTime endDate = w.last ??
        DateTime(w.timeTaken.year, w.timeTaken.month, w.timeTaken.day);
    while (!startDate.isBefore(endDate)) {
      if (map.getOutfitFromDate(startDate).contains(w.id)) {
        _wearables.updateLastWorn(w, startDate);
        return;
      }
      startDate = startDate.subtract(const Duration(days: 1));
    }
  }

  String _formatLastWornLabel(DateTime? last) {
    if (last == null) return 'Not worn';
    final DateTime today = context.read<DateTime>();
    final int diff = today.difference(last).inDays;
    if (diff >= 365) {
      return '>1 year';
    } else if (diff >= 182) {
      return '>6 months';
    } else if (diff >= 91) {
      return '>3 months';
    } else if (diff >= 30) {
      return '1 month';
    } else if (diff == 1) {
      return 'yesterday';
    } else if (diff == 0) {
      return 'today';
    } else {
      return '$diff days';
    }
  }
}
