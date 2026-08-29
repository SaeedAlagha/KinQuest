import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';
import 'digital_reward_definition.dart';

String localizedDigitalRewardName(
  BuildContext context,
  DigitalRewardDefinition reward,
) {
  if (Localizations.localeOf(context).languageCode != 'ar') return reward.name;

  return _arabicRewardNames[reward.id] ?? reward.name;
}

String localizedDigitalRewardDescription(
  BuildContext context,
  DigitalRewardDefinition reward,
) {
  if (Localizations.localeOf(context).languageCode != 'ar') {
    return reward.description;
  }

  return _arabicRewardDescriptions[reward.id] ?? reward.description;
}

String localizedDigitalRewardCategoryLabel(
  AppLocalizations strings,
  DigitalRewardCategory category,
) => switch (category) {
  DigitalRewardCategory.profileFrame => strings.profileFrames,
  DigitalRewardCategory.profileBadge => strings.profileBadges,
  DigitalRewardCategory.profileTheme => strings.profileThemes,
  DigitalRewardCategory.celebrationEffect => strings.celebrationEffects,
  DigitalRewardCategory.nameplate => strings.nameplates,
  DigitalRewardCategory.mascotAccessory => strings.silaWardrobe,
  DigitalRewardCategory.mascotOutfit => strings.silaOutfits,
  DigitalRewardCategory.mascotAura => strings.silaAuras,
};

const _arabicRewardNames = <String, String>{
  'frame_gold': 'الإطار الذهبي للملف الشخصي',
  'frame_neon': 'إطار النيون للملف الشخصي',
  'frame_ocean': 'إطار المحيط للملف الشخصي',
  'badge_champion': 'شارة البطل',
  'badge_explorer': 'شارة المستكشف',
  'badge_family_star': 'شارة نجم العائلة',
  'theme_galaxy': 'سمة المجرّة للملف الشخصي',
  'theme_ocean': 'سمة المحيط للملف الشخصي',
  'theme_sunset': 'سمة الغروب للملف الشخصي',
  'celebration_confetti': 'احتفال قصاصات الورق',
  'celebration_fireworks': 'احتفال الألعاب النارية',
  'celebration_stars': 'احتفال تساقط النجوم',
  'nameplate_gold': 'لوحة الاسم الذهبية',
  'nameplate_neon': 'لوحة اسم النيون',
  'nameplate_champion': 'لوحة أسطورة العائلة',
  'mascot_guardian_crown': 'تاج حارس العائلة',
  'mascot_explorer_cap': 'قبعة مستكشف العائلة',
  'mascot_star_halo': 'هالة نجمة الإرث',
  'mascot_family_cape': 'رداء بطل العائلة',
  'mascot_game_jersey': 'زي ليلة الألعاب',
  'mascot_memory_keeper': 'عدة حارس الذكريات',
  'mascot_family_sparkles': 'هالة بريق العائلة',
  'mascot_cosmic_orbit': 'هالة المدار الكوني',
  'mascot_uae_ribbon': 'شريط وحدة الإمارات',
  'mascot_family_leaf_wreath': 'إكليل الجذور المشتركة',
  'mascot_scholar_cap': 'قبعة عالم المستقبل',
  'mascot_space_scout': 'بدلة مستكشف الفضاء',
  'mascot_desert_explorer': 'وشاح مستكشف الصحراء',
  'mascot_memory_hearts': 'هالة قلوب الذكريات',
  'mascot_victory_burst': 'هالة انفجار البطولة',
};

const _arabicRewardDescriptions = <String, String>{
  'frame_gold': 'إطار ذهبي دافئ يجعل ملف عائلتك يتألق.',
  'frame_neon': 'إطار نيون ساطع بلمسة تنافسية مرحة.',
  'frame_ocean': 'إطار أزرق هادئ مستوحى من ساحل الإمارات.',
  'badge_champion': 'اعرض شارة كأس بجانب اسم عائلتك.',
  'badge_explorer': 'أظهر استعدادك الدائم لمغامرة عائلية جديدة.',
  'badge_family_star': 'أضف علامة نجم العائلة إلى لوحة اسمك.',
  'theme_galaxy': 'امنح ترويسة ملفك تدرجًا كونيًا عميقًا.',
  'theme_ocean': 'استخدم تدرجًا ساحليًا منعشًا في ترويسة ملفك.',
  'theme_sunset': 'أضف ألوان الغروب الدافئة إلى مساحتك الشخصية.',
  'celebration_confetti': 'املأ لحظات الفوز الرسمية بقصاصات ورقية ملونة.',
  'celebration_fireworks':
      'احتفل بالانتصارات الرسمية بألعاب نارية ذهبية متحركة.',
  'celebration_stars': 'أرسل مسارًا من نجوم العائلة عبر بطاقة الفائز.',
  'nameplate_gold': 'اعرض اسمك بلمسة ذهبية أنيقة.',
  'nameplate_neon': 'امنح اسم عائلتك لمسة نيون حيوية.',
  'nameplate_champion': 'إطلالة الأبطال لأسطورة عائلية حقيقية.',
  'mascot_guardian_crown': 'تاج ذهبي لانتصارات العائلة المميزة.',
  'mascot_explorer_cap': 'قبعة خضراء لمغامرة صلة العائلية التالية.',
  'mascot_star_halo': 'مدار متوهج من نجوم العائلة حول صلة.',
  'mascot_family_cape': 'رداء أخضر وذهبي للحظات العائلة البطولية.',
  'mascot_game_jersey': 'زي رياضي مرح عندما يقود صلة الألعاب.',
  'mascot_memory_keeper': 'حقيبة كاميرا صغيرة لذكريات العائلة.',
  'mascot_family_sparkles': 'ألوان الجذور والروابط والنمو تدور حول صلة.',
  'mascot_cosmic_orbit': 'مدار فضائي متحرك لمغامرات صلة.',
  'mascot_uae_ribbon': 'قوس بألوان الإمارات يحتفي بوحدة العائلة.',
  'mascot_family_leaf_wreath':
      'تاج نابض من الأوراق الخضراء والذهبية مستوحى من جذور عائلة صلة.',
  'mascot_scholar_cap':
      'قبعة احتفالية للعائلات الفضولية التي تواصل التعلّم معًا.',
  'mascot_space_scout':
      'ألواح كتف كونية وتفاصيل متوهجة لمغامرات تتجاوز النجوم.',
  'mascot_desert_explorer':
      'وشاح دافئ بألوان الشروق لمغامرة صلة العائلية القادمة في الإمارات.',
  'mascot_memory_hearts':
      'قلوب متحركة تحمل ألوان اللحظات التي تتشاركها عائلتكم.',
  'mascot_victory_burst':
      'انفجار ضوئي متحرك صُمم لأبطال العائلة وانتصاراتهم السعيدة.',
};
