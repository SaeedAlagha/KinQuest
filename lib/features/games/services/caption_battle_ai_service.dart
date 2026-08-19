import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

class CaptionBattleAiService {
  const CaptionBattleAiService();

  static const List<String> promptStyles = [
    'Surprise Me',
    'Storytelling',
    'Headlines & Posts',
    'Wild Ideas',
  ];

  static const Map<String, List<String>> _modesByStyle = {
    'Storytelling': [
      'What Happened Next?',
      'Before This Photo',
      'Plot Twist',
      'Future Memory',
      'Family Documentary',
    ],
    'Headlines & Posts': [
      'Breaking News',
      'Sports Commentary',
      'Movie Title',
      'Social Media Post',
      'Travel Postcard',
    ],
    'Wild Ideas': [
      'Wrong Answers Only',
      'Secret Thoughts',
      'Superhero Origin',
      'Advertisement',
      'One-Word Challenge',
    ],
  };

  static const Map<String, String> _arabicModes = {
    'What Happened Next?': 'ماذا حدث بعد ذلك؟',
    'Before This Photo': 'قبل هذه الصورة',
    'Plot Twist': 'تحول مفاجئ',
    'Future Memory': 'ذكرى من المستقبل',
    'Family Documentary': 'وثائقي عائلي',
    'Breaking News': 'خبر عاجل',
    'Sports Commentary': 'تعليق رياضي',
    'Movie Title': 'عنوان فيلم',
    'Social Media Post': 'منشور اجتماعي',
    'Travel Postcard': 'بطاقة سفر',
    'Wrong Answers Only': 'إجابات خاطئة فقط',
    'Secret Thoughts': 'أفكار سرية',
    'Superhero Origin': 'بداية بطل خارق',
    'Advertisement': 'إعلان',
    'One-Word Challenge': 'تحدي الكلمة الواحدة',
  };

  Future<List<String>> generateModes({
    required int count,
    String languageCode = 'en',
    String promptStyle = 'Surprise Me',
  }) async {
    final selectedStyle = promptStyles.contains(promptStyle)
        ? promptStyle
        : promptStyles.first;
    final response = await http
        .post(
          ApiConfig.endpoint('/api/caption-battle/modes'),
          headers: await ApiConfig.authenticatedJsonHeaders(),
          body: jsonEncode({
            'count': count,
            'language': languageCode,
            'style': selectedStyle,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Caption Battle server returned ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawModes = data['modes'] as List<dynamic>?;

    if (rawModes == null || rawModes.isEmpty) {
      throw Exception('Missing Caption Battle modes');
    }

    return rawModes
        .whereType<String>()
        .map((mode) => mode.trim())
        .where((mode) => mode.isNotEmpty)
        .toList();
  }

  static List<String> offlineModes({
    required int count,
    String promptStyle = 'Surprise Me',
    String languageCode = 'en',
    Random? random,
  }) {
    final selectedStyle = promptStyles.contains(promptStyle)
        ? promptStyle
        : promptStyles.first;
    final candidates = selectedStyle == 'Surprise Me'
        ? _modesByStyle.values.expand((modes) => modes).toList()
        : List<String>.from(_modesByStyle[selectedStyle]!);

    candidates.shuffle(random ?? Random.secure());
    final selected = candidates.take(count.clamp(1, 5)).toList();
    if (languageCode != 'ar') return selected;

    return selected.map((mode) => _arabicModes[mode] ?? mode).toList();
  }

  static String descriptionForStyle(
    String promptStyle, {
    String languageCode = 'en',
  }) {
    if (languageCode == 'ar') {
      return switch (promptStyle) {
        'Storytelling' => 'تخيل اللحظة السابقة أو التالية أو المستقبل البعيد.',
        'Headlines & Posts' =>
          'حوّل الصورة إلى خبر أو فيلم أو تعليق أو منشور اجتماعي.',
        'Wild Ideas' => 'ابتكر إجابات غير متوقعة وأفكارًا سرية وهويات مرحة.',
        _ => 'امزج القصص والعناوين والمنشورات والتحديات غير المتوقعة.',
      };
    }

    return switch (promptStyle) {
      'Storytelling' =>
        'Imagine the moment before, after, or far into the future.',
      'Headlines & Posts' =>
        'Turn the photo into news, a movie, commentary, or a social post.',
      'Wild Ideas' =>
        'Invent unexpected answers, secret thoughts, and playful identities.',
      _ => 'Mix storytelling, headlines, posts, and unexpected challenges.',
    };
  }

  static String examplesForStyle(
    String promptStyle, {
    String languageCode = 'en',
  }) {
    if (languageCode == 'ar') {
      return switch (promptStyle) {
        'Storytelling' => 'ماذا حدث بعد ذلك؟ • قبل هذه الصورة • تحول مفاجئ',
        'Headlines & Posts' => 'خبر عاجل • عنوان فيلم • منشور اجتماعي',
        'Wild Ideas' => 'إجابات خاطئة فقط • أفكار سرية • بداية بطل خارق',
        _ => 'ماذا حدث بعد ذلك؟ • خبر عاجل • إجابات خاطئة فقط',
      };
    }

    return switch (promptStyle) {
      'Storytelling' => 'What Happened Next? • Before This Photo • Plot Twist',
      'Headlines & Posts' => 'Breaking News • Movie Title • Social Media Post',
      'Wild Ideas' => 'Wrong Answers Only • Secret Thoughts • Superhero Origin',
      _ => 'What Happened Next? • Breaking News • Wrong Answers Only',
    };
  }

  static String instructionForMode(String mode, {String languageCode = 'en'}) {
    final canonicalMode = _arabicModes.entries
        .where((entry) => entry.value == mode)
        .map((entry) => entry.key)
        .firstOrNull;

    if (languageCode == 'ar') {
      return switch (canonicalMode ?? mode) {
        'What Happened Next?' => 'تخيل اللحظة التالية مباشرة في هذه القصة.',
        'Before This Photo' => 'ابتكر ما حدث قبل التقاط الصورة مباشرة.',
        'Plot Twist' => 'أضف تحولًا مفاجئًا إلى هذه اللحظة العائلية.',
        'Future Memory' => 'صف كيف ستتذكر العائلة هذه اللحظة بعد سنوات.',
        'Family Documentary' => 'اروِ الصورة بأسلوب وثائقي درامي.',
        'Breaking News' => 'اكتب عنوان الخبر العاجل لهذه القصة العائلية.',
        'Sports Commentary' => 'علّق على الحدث كأنه نهائي بطولة.',
        'Movie Title' => 'امنح هذه اللحظة عنوان الفيلم المثالي.',
        'Social Media Post' => 'اكتب المنشور المناسب لهذه الصورة.',
        'Travel Postcard' => 'حوّل الصورة إلى رسالة على بطاقة سفر.',
        'Wrong Answers Only' => 'فسّر الصورة بإجابة خاطئة وواثقة.',
        'Secret Thoughts' => 'اكتب ما قد يفكر فيه شخص في الصورة.',
        'Superhero Origin' => 'حوّل اللحظة إلى بداية قصة بطل خارق.',
        'Advertisement' => 'سوّق لهذه اللحظة العائلية كإعلان درامي.',
        'One-Word Challenge' => 'اختصر اللحظة كلها في كلمة واحدة رائعة.',
        _ => 'اكتب تعليقًا مبتكرًا يناسب فكرة هذه الجولة.',
      };
    }

    return switch (mode) {
      'What Happened Next?' => 'Imagine the very next moment in this story.',
      'Before This Photo' => 'Invent what happened just before the photo.',
      'Plot Twist' => 'Add an unexpected twist to this family moment.',
      'Future Memory' =>
        'Describe how the family will remember this years later.',
      'Family Documentary' => 'Narrate the photo like a dramatic documentary.',
      'Breaking News' => 'Write the headline for this breaking family story.',
      'Sports Commentary' => 'Call the action like a championship commentator.',
      'Movie Title' => 'Give this moment its perfect movie title.',
      'Social Media Post' => 'Write the post that would go with this photo.',
      'Travel Postcard' => 'Turn the photo into a postcard message.',
      'Wrong Answers Only' =>
        'Explain the photo with a confidently wrong answer.',
      'Secret Thoughts' => 'Write what someone in the photo might be thinking.',
      'Superhero Origin' => 'Turn this moment into a hero origin story.',
      'Advertisement' =>
        'Sell this family moment like a dramatic advertisement.',
      'One-Word Challenge' =>
        'Capture the entire moment in one brilliant word.',
      _ => 'Write a creative caption that matches this round theme.',
    };
  }

  static String hintForMode(String mode, {String languageCode = 'en'}) {
    final canonicalMode = _arabicModes.entries
        .where((entry) => entry.value == mode)
        .map((entry) => entry.key)
        .firstOrNull;

    if (languageCode == 'ar') {
      return switch (canonicalMode ?? mode) {
        'What Happened Next?' => 'ثم فجأة ومن دون سابق إنذار...',
        'Before This Photo' => 'قبل خمس ثوانٍ...',
        'Breaking News' => 'العائلة تصنع التاريخ بعد...',
        'Movie Title' => 'العائلة العظيمة...',
        'Secret Thoughts' => 'أتمنى حقًا ألا يلاحظ أحد...',
        'One-Word Challenge' => 'كلمة واحدة لا تُنسى...',
        _ => 'اكتب شيئًا ستتذكره عائلتك...',
      };
    }

    return switch (mode) {
      'What Happened Next?' => 'And then, without warning...',
      'Before This Photo' => 'Five seconds earlier...',
      'Breaking News' => 'Family makes history after...',
      'Movie Title' => 'The Great Family...',
      'Secret Thoughts' => 'I really hope nobody notices...',
      'One-Word Challenge' => 'One unforgettable word...',
      _ => 'Write something your family will remember...',
    };
  }
}
