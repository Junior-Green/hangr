import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focused_menu/modals.dart';
import 'package:hangr/pages/edit_wearable.dart';
import 'package:hangr/services/custom_icons.dart';
import 'package:hangr/services/outfit.dart';
import 'package:hangr/services/wearable.dart';
import 'package:hangr/widgets/no_opacity_flexible_space_bar.dart';
import 'package:hangr/widgets/zoomable.dart';
import 'package:hangr/widgets/zoomable_wearable.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

enum SortType { none, name, color, brand }

enum WardrobeMode { clothes, outfits }

class HomeWardrobe extends StatefulWidget {
  final TabController homeTabController;

  const HomeWardrobe({Key? key, required this.homeTabController})
      : super(key: key);
  @override
  State<HomeWardrobe> createState() => _HomeWardrobeState();
}

class _HomeWardrobeState extends State<HomeWardrobe> {
  late final _wearables = Provider.of<MyWearables>(context);
  late final _outfits = Provider.of<MyOutfits>(context);
  late final TextEditingController _textController;
  late final FixedExtentScrollController _scrollController;
  final _wearableTypeFilters = HashSet<WearableType>();
  final _wearableAttributeFilter = HashSet<String>();
  final _mode = ValueNotifier<WardrobeMode>(WardrobeMode.clothes);

  SortType _sortType = SortType.none;
  bool _sortDown = true;

  @override
  void initState() {
    _textController = TextEditingController();
    _scrollController = FixedExtentScrollController();
    super.initState();
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
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxScrolled) => <Widget>[
              _createSilverAppBar1(),
              _createSilverAppBar2(),
              _createSliverGrid()
            ],
            body: Container(),
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

  SliverAppBar _createSilverAppBar2() {
    return SliverAppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      pinned: true,
      primary: false,
      floating: true,
      elevation: 0,
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
                child: CupertinoSlidingSegmentedControl<WardrobeMode>(
                  thumbColor: Theme.of(context).colorScheme.tertiary,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  onValueChanged: (value) =>
                      setState(() => _mode.value = value!),
                  groupValue: _mode.value,
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
                          _wearableAttributeFilter.clear();
                          HapticFeedback.lightImpact();
                        }),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _showFilterPicker(context),
                          icon: Icon(
                            Icons.filter_alt_rounded,
                            color: _wearableAttributeFilter.isEmpty
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
                            color: _sortType == SortType.none
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              ValueListenableBuilder<WardrobeMode>(
                builder: (BuildContext context, value, Widget? child) =>
                    Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: value == WardrobeMode.clothes
                        ? _clothesFilterButtons(context)
                        : _outfitsFilterButtons(context),
                  ),
                ),
                valueListenable: _mode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverPadding _createSliverGrid() => SliverPadding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        sliver: SliverGrid.count(
          childAspectRatio: 3 / 4,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          crossAxisCount: 3,
          children: List<Widget>.from(_getWearables())..add(_wardrobeAddHint),
        ),
      );

  List<IconButton> _clothesFilterButtons(BuildContext context) => [
        IconButton(
          onPressed: () => setState(
            () => _wearableTypeFilters.contains(WearableType.top)
                ? _wearableTypeFilters.remove(WearableType.top)
                : _wearableTypeFilters.add(WearableType.top),
          ),
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
          icon: const Icon(CustomIcons.headwear),
          color: _wearableTypeFilters.contains(WearableType.headwear)
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.onSecondary,
        ),
      ];

  List<IconButton> _outfitsFilterButtons(BuildContext context) => [
        IconButton(
          onPressed: () => setState(
            () => _wearableTypeFilters.contains(WearableType.top)
                ? _wearableTypeFilters.remove(WearableType.top)
                : _wearableTypeFilters.add(WearableType.top),
          ),
          icon: const Icon(CustomIcons.top),
          color: _wearableTypeFilters.contains(WearableType.top)
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.onSecondary,
          iconSize: 25,
        ),
        IconButton(
          onPressed: () => setState(
            () => _wearableTypeFilters.contains(WearableType.bottom)
                ? _wearableTypeFilters.remove(WearableType.bottom)
                : _wearableTypeFilters.add(WearableType.bottom),
          ),
          icon: const Icon(CustomIcons.formal),
          color: _wearableTypeFilters.contains(WearableType.bottom)
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.onSecondary,
          iconSize: 25,
        ),
        IconButton(
          onPressed: () => setState(
            () => _wearableTypeFilters.contains(WearableType.footwear)
                ? _wearableTypeFilters.remove(WearableType.footwear)
                : _wearableTypeFilters.add(WearableType.footwear),
          ),
          icon: const Icon(CustomIcons.business),
          color: _wearableTypeFilters.contains(WearableType.footwear)
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.onSecondary,
          iconSize: 30,
        ),
        IconButton(
          onPressed: () => setState(
            () => _wearableTypeFilters.contains(WearableType.accessory)
                ? _wearableTypeFilters.remove(WearableType.accessory)
                : _wearableTypeFilters.add(WearableType.accessory),
          ),
          icon: const Icon(CustomIcons.athletic),
          color: _wearableTypeFilters.contains(WearableType.accessory)
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.onSecondary,
          iconSize: 25,
        ),
      ];

  Widget get _wardrobeAddHint => GestureDetector(
        onTap: () {
          if (_mode.value == WardrobeMode.clothes) {
            widget.homeTabController.animateTo(0);
          } else {}
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

  List<Zoomable> _getWearables() => List<ZoomableWearable>.from(
        _wearables.getWearables
            .where(
              (element) =>
                  (_wearableTypeFilters.isEmpty ||
                      _wearableTypeFilters.contains(element.type)) &&
                  (_textController.text.isEmpty ||
                      element.name
                          .toLowerCase()
                          .contains(_textController.text.toLowerCase())) &&
                  (_wearableAttributeFilter.isEmpty ||
                      _wearableAttributeFilter
                          .contains(element.brand.toLowerCase()) ||
                      _wearableAttributeFilter
                          .contains(element.brand.toLowerCase())),
            )
            .map(
              (element) => ZoomableWearable(
                  _getWearableMenuOptions(
                    element,
                    context.read<MyWearables>(),
                  ),
                  element),
            )
            .toList()
          ..sort(_sorter),
      );

  List<ZoomableWearable> _getOutfits() => List<ZoomableWearable>.from(
        _wearables.getWearables
            .where(
              (element) =>
                  (_wearableTypeFilters.isEmpty ||
                      _wearableTypeFilters.contains(element.type)) &&
                  (_textController.text.isEmpty ||
                      element.name
                          .toLowerCase()
                          .contains(_textController.text.toLowerCase())) &&
                  (_wearableAttributeFilter.isEmpty ||
                      _wearableAttributeFilter
                          .contains(element.brand.toLowerCase()) ||
                      _wearableAttributeFilter
                          .contains(element.brand.toLowerCase())),
            )
            .map(
              (element) => ZoomableWearable(
                _getOutfitMenuOptions(
                  element,
                  _wearables,
                ),
                element,
              ),
            )
            .toList()
          ..sort(_sorter),
      );

  Future<void> _showFilterPicker(BuildContext context) async {
    await showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      isScrollControlled: true, // required for min/max child size
      context: context,
      elevation: 0,
      builder: (context) => Padding(
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
          items: _wearables.getWearables
              .map((element) => element.brand)
              .followedBy(
                _wearables.getWearables.map((element) => element.primaryColor),
              )
              .toSet()
              .map((element) => MultiSelectItem(element, element))
              .toList(),
          listType: MultiSelectListType.CHIP,
          initialValue: const [],
          onSelectionChanged: (filters) => setState(
            () => _wearableAttributeFilter
              ..clear()
              ..addAll(filters.toSet().map((e) => e.toLowerCase()).toList()),
          ),
          maxChildSize: 0.8,
        ),
      ),
    );
  }

  Future<void> _showSortPicker(BuildContext context) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => SizedBox(
        height: 200,
        child: CupertinoPicker(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          scrollController:
              FixedExtentScrollController(initialItem: _sortType.index),
          magnification: 1.25,
          useMagnifier: true,
          itemExtent: 30,
          onSelectedItemChanged: (index) => setState(() {
            switch (index) {
              case 0:
                _sortType = SortType.none;
                break;
              case 1:
                _sortType = SortType.name;
                break;
              case 2:
                _sortType = SortType.color;
                break;
              case 3:
                _sortType = SortType.brand;
                break;
              default:
            }
          }),
          children: [
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
            )
          ],
        ),
      ),
    );
  }

  int _sorter(ZoomableWearable a, ZoomableWearable b) {
    switch (_sortType) {
      case SortType.none:
        return 0;
      case SortType.name:
        return _sortDown
            ? a.wearable.name.compareTo(b.wearable.name)
            : a.wearable.name.compareTo(b.wearable.name) * -1;
      case SortType.brand:
        return _sortDown
            ? a.wearable.brand.compareTo(b.wearable.name)
            : a.wearable.brand.compareTo(b.wearable.name) * -1;
      case SortType.color:
        return _sortDown
            ? a.wearable.primaryColor.compareTo(b.wearable.name)
            : a.wearable.primaryColor.compareTo(b.wearable.name) * -1;
      default:
        return 0;
    }
  }

  List<FocusedMenuItem> _getWearableMenuOptions(
    Wearable w,
    MyWearables wearables,
  ) =>
      [
        _createEditButton(
          () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListenableProvider<MyWearables>.value(
                  value: wearables,
                  child: EditWearable(w),
                ),
              ),
            );
          },
        ),
        _createShareButton(
          () => Share.shareFiles(
            [w.imagePath],
            mimeTypes: ['images/jpg'],
            subject: 'Check out ${_getSubjectSuffix(w)}',
            text: 'Look at my ${w.name} I got from ${w.brand}.',
          ),
        ),
        _createDeleteButton(
          () => wearables.removeWearable(w),
        ),
      ];

  List<FocusedMenuItem> _getOutfitMenuOptions(
    Wearable element,
    MyWearables wearables,
  ) =>
      [
        _createEditButton(() {}),
      ];

  String _getSubjectSuffix(Wearable w) {
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
      );

  FocusedMenuItem _createDeleteButton(Function onPressed) => FocusedMenuItem(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: const Text(
          'Delete',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        onPressed: onPressed,
      );
}
