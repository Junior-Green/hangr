import 'package:hangr/services/calendar_map.dart';
import 'package:hangr/services/outfit.dart';
import 'package:hangr/services/wearable.dart';

List<Wearable> getListWearable() {
  // const wearable1 = Wearable(
  //   '342gw',
  //   WearableType.headwear,
  //   "Nike",
  //   "blue",
  //   "pants.png",
  //   "track pants",
  // );
  // const wearable2 = Wearable(
  //   '34qfw2gw',
  //   WearableType.footwear,
  //   "Puma",
  //   "black",
  //   "footwear.png",
  //   "running shoes",
  // );
  // const wearable3 = Wearable(
  //   '342wqfgw',
  //   WearableType.accessory,
  //   "Gucci",
  //   "brown",
  //   "accessory.png",
  //   "gucci bag",
  // );

  return [];
}

List<Outfit> getListOutfit() {
  // const outfit1 = Outfit(['1', '2', '3'], OutfitType.casual);
  // const outfit2 = Outfit(['3', '4', '5'], OutfitType.business);
  // const outfit3 = Outfit(['6', '7', '8'], OutfitType.formal);

  //return [outfit1, outfit2, outfit3];
  return [];
}

CalendarMap getCalendarMap() {
  final outfits = getListOutfit();
  final map = CalendarMap.empty();
  map.updateOutfit(DateTime.now(), []);
  map.updateOutfit(DateTime.now().add(const Duration(days: 7)), []);
  map.updateOutfit(DateTime.now().add(const Duration(days: 30)), []);
  return map;
}
