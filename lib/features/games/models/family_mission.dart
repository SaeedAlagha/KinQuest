enum MissionDifficulty {
  easy,
  medium,
  hard,
}

enum MissionScope {
  personal,
  family,
}

class FamilyMission {
  const FamilyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.scope,
    required this.tokenReward,
    required this.cooldownDays,
    required this.proofHint,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final MissionDifficulty difficulty;
  final MissionScope scope;

  /// Personal mission:
  /// reward goes to the person who completes it.
  ///
  /// Family mission:
  /// this reward goes to EACH selected participant.
  final int tokenReward;

  final int cooldownDays;
  final String proofHint;
}

abstract final class FamilyMissionCatalog {
  static const List<FamilyMission> all = [
    // ============================================================
    // PERSONAL MISSIONS
    // ============================================================

    FamilyMission(
      id: 'personal_appreciation',
      title: 'Show Some Appreciation',
      description:
          'Tell one family member something specific that you genuinely appreciate about them.',
      category: 'Kindness',
      difficulty: MissionDifficulty.easy,
      scope: MissionScope.personal,
      tokenReward: 8,
      cooldownDays: 2,
      proofHint:
          'Submit a relevant photo or screenshot and briefly explain what you said or did.',
    ),
    FamilyMission(
      id: 'personal_help',
      title: 'Help Without Being Asked',
      description:
          'Do one genuinely helpful thing for a family member before they ask you.',
      category: 'Kindness',
      difficulty: MissionDifficulty.easy,
      scope: MissionScope.personal,
      tokenReward: 8,
      cooldownDays: 2,
      proofHint:
          'Submit a relevant or before-and-after photo and explain what you helped with.',
    ),
    FamilyMission(
      id: 'personal_call_relative',
      title: 'Call Someone You Love',
      description:
          'Call or video chat with a relative you have not spoken to recently.',
      category: 'Connection',
      difficulty: MissionDifficulty.easy,
      scope: MissionScope.personal,
      tokenReward: 10,
      cooldownDays: 7,
      proofHint:
          'A call screenshot is ideal. Avoid exposing private phone numbers when possible.',
    ),
    FamilyMission(
      id: 'personal_family_story',
      title: 'Discover a Family Story',
      description:
          'Ask a family member to tell you a funny, meaningful, or memorable story from their past.',
      category: 'Connection',
      difficulty: MissionDifficulty.easy,
      scope: MissionScope.personal,
      tokenReward: 10,
      cooldownDays: 4,
      proofHint:
          'Submit a relevant photo and briefly explain what story you learned.',
    ),
    FamilyMission(
      id: 'personal_make_drink',
      title: 'Make Something for Someone',
      description:
          'Prepare a drink, snack, or small treat for a family member.',
      category: 'Kindness',
      difficulty: MissionDifficulty.easy,
      scope: MissionScope.personal,
      tokenReward: 8,
      cooldownDays: 3,
      proofHint:
          'Submit a photo of what you prepared.',
    ),
    FamilyMission(
      id: 'personal_memory_question',
      title: 'Ask About an Old Memory',
      description:
          'Ask an older family member about a memorable moment from their childhood.',
      category: 'Memories',
      difficulty: MissionDifficulty.easy,
      scope: MissionScope.personal,
      tokenReward: 10,
      cooldownDays: 5,
      proofHint:
          'Submit a relevant photo and use the explanation box to briefly describe what you learned.',
    ),
    FamilyMission(
      id: 'personal_small_cleanup',
      title: 'Fix One Messy Spot',
      description:
          'Choose one small messy area at home and organize it properly.',
      category: 'Teamwork',
      difficulty: MissionDifficulty.easy,
      scope: MissionScope.personal,
      tokenReward: 10,
      cooldownDays: 3,
      proofHint:
          'A before-and-after photo is the strongest proof.',
    ),
    FamilyMission(
      id: 'personal_kind_message',
      title: 'Send a Kind Message',
      description:
          'Send a thoughtful message to a family member just to make their day better.',
      category: 'Kindness',
      difficulty: MissionDifficulty.easy,
      scope: MissionScope.personal,
      tokenReward: 8,
      cooldownDays: 3,
      proofHint:
          'Submit a screenshot with private or sensitive details hidden if necessary.',
    ),
    FamilyMission(
      id: 'personal_learn_recipe',
      title: 'Learn a Family Recipe',
      description:
          'Ask a relative how to make a family recipe and learn something about where it came from.',
      category: 'Memories',
      difficulty: MissionDifficulty.medium,
      scope: MissionScope.personal,
      tokenReward: 18,
      cooldownDays: 14,
      proofHint:
          'Submit a photo of the recipe, ingredients, preparation, or finished food.',
    ),
    FamilyMission(
      id: 'personal_memory_save',
      title: 'Save a Family Memory',
      description:
          'Choose one meaningful family photo and add it to your memories with a useful description.',
      category: 'Memories',
      difficulty: MissionDifficulty.medium,
      scope: MissionScope.personal,
      tokenReward: 15,
      cooldownDays: 7,
      proofHint:
          'Submit the family photo or a screenshot showing the memory you saved.',
    ),
    FamilyMission(
      id: 'personal_long_help',
      title: 'Take Over a Chore',
      description:
          'Take over a useful household chore for a family member and complete it properly.',
      category: 'Teamwork',
      difficulty: MissionDifficulty.medium,
      scope: MissionScope.personal,
      tokenReward: 15,
      cooldownDays: 5,
      proofHint:
          'Submit a relevant before, during, or after photo.',
    ),
    FamilyMission(
      id: 'personal_surprise',
      title: 'Plan a Small Surprise',
      description:
          'Do something thoughtful and unexpected for someone in your family.',
      category: 'Kindness',
      difficulty: MissionDifficulty.medium,
      scope: MissionScope.personal,
      tokenReward: 18,
      cooldownDays: 7,
      proofHint:
          'Submit reasonable proof and explain what the surprise was.',
    ),

    // ============================================================
    // FAMILY MISSIONS
    // ============================================================

    FamilyMission(
      id: 'family_walk',
      title: 'Take a Family Walk',
      description:
          'Spend at least 20 minutes walking together and enjoy the time without rushing.',
      category: 'Outdoor',
      difficulty: MissionDifficulty.easy,
      scope: MissionScope.family,
      tokenReward: 10,
      cooldownDays: 4,
      proofHint:
          'Submit a photo from the walk showing the activity or location.',
    ),
    FamilyMission(
      id: 'family_meal',
      title: 'Share a Meal Together',
      description:
          'Sit together for a proper meal and keep phones away while you eat.',
      category: 'Together Time',
      difficulty: MissionDifficulty.easy,
      scope: MissionScope.family,
      tokenReward: 10,
      cooldownDays: 3,
      proofHint:
          'Submit a photo showing the meal, table, or family activity.',
    ),
    FamilyMission(
      id: 'family_photo',
      title: 'Capture Today',
      description:
          'Take a new family photo together and turn an ordinary day into a memory.',
      category: 'Memories',
      difficulty: MissionDifficulty.easy,
      scope: MissionScope.family,
      tokenReward: 10,
      cooldownDays: 7,
      proofHint:
          'Submit the new family photo created for this mission.',
    ),
    FamilyMission(
      id: 'family_play',
      title: 'Play Together',
      description:
          'Spend at least 30 minutes playing a game together.',
      category: 'Fun',
      difficulty: MissionDifficulty.easy,
      scope: MissionScope.family,
      tokenReward: 10,
      cooldownDays: 4,
      proofHint:
          'Submit a photo showing the game setup or family activity.',
    ),
    FamilyMission(
      id: 'family_cook',
      title: 'Cook Something Together',
      description:
          'Prepare a meal, dessert, or snack together instead of leaving all the work to one person.',
      category: 'Together Time',
      difficulty: MissionDifficulty.medium,
      scope: MissionScope.family,
      tokenReward: 18,
      cooldownDays: 7,
      proofHint:
          'Submit a photo of the preparation or finished food.',
    ),
    FamilyMission(
      id: 'family_game_night',
      title: 'Family Game Night',
      description:
          'Set aside at least 45 minutes for everyone to play games together.',
      category: 'Fun',
      difficulty: MissionDifficulty.medium,
      scope: MissionScope.family,
      tokenReward: 18,
      cooldownDays: 7,
      proofHint:
          'Submit a photo of the game setup or family playing together.',
    ),
    FamilyMission(
      id: 'family_screen_free',
      title: 'One Screen-Free Hour',
      description:
          'Spend a full hour together without phones, television, tablets, or computers.',
      category: 'Connection',
      difficulty: MissionDifficulty.medium,
      scope: MissionScope.family,
      tokenReward: 20,
      cooldownDays: 7,
      proofHint:
          'Submit a photo of what your family did during the screen-free time.',
    ),
    FamilyMission(
      id: 'family_cleanup',
      title: 'Team Cleanup',
      description:
          'Choose one messy area and clean or organize it together from start to finish.',
      category: 'Teamwork',
      difficulty: MissionDifficulty.medium,
      scope: MissionScope.family,
      tokenReward: 18,
      cooldownDays: 7,
      proofHint:
          'A before-and-after photo is ideal.',
    ),
    FamilyMission(
      id: 'family_outdoor',
      title: 'Outdoor Family Time',
      description:
          'Spend at least 45 minutes doing an outdoor activity together.',
      category: 'Outdoor',
      difficulty: MissionDifficulty.medium,
      scope: MissionScope.family,
      tokenReward: 18,
      cooldownDays: 6,
      proofHint:
          'Submit a photo showing your outdoor activity or location.',
    ),
    FamilyMission(
      id: 'family_old_photos',
      title: 'Explore Old Family Photos',
      description:
          'Look through older family photos together and talk about the stories behind them.',
      category: 'Memories',
      difficulty: MissionDifficulty.medium,
      scope: MissionScope.family,
      tokenReward: 18,
      cooldownDays: 14,
      proofHint:
          'Submit a photo showing the album, older photos, or memory activity.',
    ),
    FamilyMission(
      id: 'family_dessert',
      title: 'Make Dessert Together',
      description:
          'Choose a dessert and make it together from preparation to the final result.',
      category: 'Together Time',
      difficulty: MissionDifficulty.medium,
      scope: MissionScope.family,
      tokenReward: 20,
      cooldownDays: 10,
      proofHint:
          'Submit a preparation or finished-dessert photo.',
    ),
    FamilyMission(
      id: 'family_picnic',
      title: 'Have a Family Picnic',
      description:
          'Prepare something to eat and enjoy a picnic together away from your normal dining table.',
      category: 'Outdoor',
      difficulty: MissionDifficulty.hard,
      scope: MissionScope.family,
      tokenReward: 25,
      cooldownDays: 21,
      proofHint:
          'Submit a photo showing the picnic setup, food, or location.',
    ),
    FamilyMission(
      id: 'family_visit_relative',
      title: 'Visit a Relative',
      description:
          'Spend meaningful face-to-face time visiting a relative you do not see every day.',
      category: 'Connection',
      difficulty: MissionDifficulty.hard,
      scope: MissionScope.family,
      tokenReward: 25,
      cooldownDays: 21,
      proofHint:
          'Submit respectful evidence from the visit without exposing unnecessary private information.',
    ),
    FamilyMission(
      id: 'family_recreate_photo',
      title: 'Recreate an Old Family Photo',
      description:
          'Choose an older family picture and recreate its pose or scene together.',
      category: 'Memories',
      difficulty: MissionDifficulty.hard,
      scope: MissionScope.family,
      tokenReward: 30,
      cooldownDays: 30,
      proofHint:
          'Submit the recreated photo and explain which old photo inspired it.',
    ),
    FamilyMission(
      id: 'family_kindness_project',
      title: 'Complete a Kindness Project',
      description:
          'Work together on something genuinely helpful for another person without expecting a reward from them.',
      category: 'Kindness',
      difficulty: MissionDifficulty.hard,
      scope: MissionScope.family,
      tokenReward: 30,
      cooldownDays: 21,
      proofHint:
          'Submit safe and respectful proof of what your family made or did.',
    ),
  ];

  static FamilyMission? byId(String id) {
    for (final mission in all) {
      if (mission.id == id) {
        return mission;
      }
    }

    return null;
  }

  static List<FamilyMission> get personal =>
      all.where((mission) => mission.scope == MissionScope.personal).toList();

  static List<FamilyMission> get family =>
      all.where((mission) => mission.scope == MissionScope.family).toList();
}