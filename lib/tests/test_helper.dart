import 'package:hangr/services/calendar_map.dart';
import 'package:hangr/services/outfit.dart';
import 'package:hangr/services/wearable.dart';

List<Wearable> getListWearable() {
  const wearable1 = Wearable(
    '342gw',
    WearableType.headwear,
    "Nike",
    "blue",
    "pants.png",
    "track pants",
  );
  const wearable2 = Wearable(
    '34qfw2gw',
    WearableType.footwear,
    "Puma",
    "black",
    "footwear.png",
    "running shoes",
  );
  const wearable3 = Wearable(
    '342wqfgw',
    WearableType.accessory,
    "Gucci",
    "brown",
    "accessory.png",
    "gucci bag",
  );

  return [wearable1, wearable2, wearable3];
}

List<Outfit> getListOutfit() {
  const outfit1 = Outfit(['1', '2', '3'], OutfitType.casual);
  const outfit2 = Outfit(['3', '4', '5'], OutfitType.business);
  const outfit3 = Outfit(['6', '7', '8'], OutfitType.formal);

  return [outfit1, outfit2, outfit3];
}

CalendarMap getCalendarMap() {
  final outfits = getListOutfit();
  final map = CalendarMap.empty();
  map.addOutfit(DateTime.now(), outfits[0]);
  map.addOutfit(DateTime.now().add(const Duration(days: 7)), outfits[1]);
  map.addOutfit(DateTime.now().add(const Duration(days: 30)), outfits[2]);
  return map;
}
