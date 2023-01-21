import 'package:quick_actions/quick_actions.dart';

const shortcutItems = <ShortcutItem>[
  addClothing,
  planToday,
  planTomorrow,
  viewWardrobe
];

const addClothing = ShortcutItem(
  type: 'add_clothing',
  localizedTitle: 'Add Clothing',
  icon: 'add_icon',
);

const planToday = ShortcutItem(
  type: 'plan_today',
  localizedTitle: "Plan Today's Outfit",
  icon: 'today_icon',
);

const planTomorrow = ShortcutItem(
  type: 'plan_tomorrow',
  localizedTitle: "Plan Tomorrow's Outfit",
  icon: 'tomorrow_icon',
);

const viewWardrobe = ShortcutItem(
  type: 'view_wardrobe',
  localizedTitle: 'View Wardrobe',
  icon: 'hanger_icon',
);
