import '../../../l10n/app_localizations.dart';
import 'family_mission.dart';

class LocalizedFamilyMissionCopy {
  const LocalizedFamilyMissionCopy({
    required this.title,
    required this.description,
    required this.proofHint,
  });

  final String title;
  final String description;
  final String proofHint;

  factory LocalizedFamilyMissionCopy.forMission(
    AppLocalizations strings,
    FamilyMission mission,
  ) {
    return switch (mission.id) {
      'personal_appreciation' => LocalizedFamilyMissionCopy(
        title: strings.missionPersonalAppreciationTitle,
        description: strings.missionPersonalAppreciationDescription,
        proofHint: strings.missionPersonalAppreciationProofHint,
      ),
      'personal_help' => LocalizedFamilyMissionCopy(
        title: strings.missionPersonalHelpTitle,
        description: strings.missionPersonalHelpDescription,
        proofHint: strings.missionPersonalHelpProofHint,
      ),
      'personal_call_relative' => LocalizedFamilyMissionCopy(
        title: strings.missionPersonalCallRelativeTitle,
        description: strings.missionPersonalCallRelativeDescription,
        proofHint: strings.missionPersonalCallRelativeProofHint,
      ),
      'personal_family_story' => LocalizedFamilyMissionCopy(
        title: strings.missionPersonalFamilyStoryTitle,
        description: strings.missionPersonalFamilyStoryDescription,
        proofHint: strings.missionPersonalFamilyStoryProofHint,
      ),
      'personal_make_drink' => LocalizedFamilyMissionCopy(
        title: strings.missionPersonalMakeDrinkTitle,
        description: strings.missionPersonalMakeDrinkDescription,
        proofHint: strings.missionPersonalMakeDrinkProofHint,
      ),
      'personal_memory_question' => LocalizedFamilyMissionCopy(
        title: strings.missionPersonalMemoryQuestionTitle,
        description: strings.missionPersonalMemoryQuestionDescription,
        proofHint: strings.missionPersonalMemoryQuestionProofHint,
      ),
      'personal_small_cleanup' => LocalizedFamilyMissionCopy(
        title: strings.missionPersonalSmallCleanupTitle,
        description: strings.missionPersonalSmallCleanupDescription,
        proofHint: strings.missionPersonalSmallCleanupProofHint,
      ),
      'personal_kind_message' => LocalizedFamilyMissionCopy(
        title: strings.missionPersonalKindMessageTitle,
        description: strings.missionPersonalKindMessageDescription,
        proofHint: strings.missionPersonalKindMessageProofHint,
      ),
      'personal_learn_recipe' => LocalizedFamilyMissionCopy(
        title: strings.missionPersonalLearnRecipeTitle,
        description: strings.missionPersonalLearnRecipeDescription,
        proofHint: strings.missionPersonalLearnRecipeProofHint,
      ),
      'personal_memory_save' => LocalizedFamilyMissionCopy(
        title: strings.missionPersonalMemorySaveTitle,
        description: strings.missionPersonalMemorySaveDescription,
        proofHint: strings.missionPersonalMemorySaveProofHint,
      ),
      'personal_long_help' => LocalizedFamilyMissionCopy(
        title: strings.missionPersonalLongHelpTitle,
        description: strings.missionPersonalLongHelpDescription,
        proofHint: strings.missionPersonalLongHelpProofHint,
      ),
      'personal_surprise' => LocalizedFamilyMissionCopy(
        title: strings.missionPersonalSurpriseTitle,
        description: strings.missionPersonalSurpriseDescription,
        proofHint: strings.missionPersonalSurpriseProofHint,
      ),
      'family_walk' => LocalizedFamilyMissionCopy(
        title: strings.missionFamilyWalkTitle,
        description: strings.missionFamilyWalkDescription,
        proofHint: strings.missionFamilyWalkProofHint,
      ),
      'family_meal' => LocalizedFamilyMissionCopy(
        title: strings.missionFamilyMealTitle,
        description: strings.missionFamilyMealDescription,
        proofHint: strings.missionFamilyMealProofHint,
      ),
      'family_photo' => LocalizedFamilyMissionCopy(
        title: strings.missionFamilyPhotoTitle,
        description: strings.missionFamilyPhotoDescription,
        proofHint: strings.missionFamilyPhotoProofHint,
      ),
      'family_play' => LocalizedFamilyMissionCopy(
        title: strings.missionFamilyPlayTitle,
        description: strings.missionFamilyPlayDescription,
        proofHint: strings.missionFamilyPlayProofHint,
      ),
      'family_cook' => LocalizedFamilyMissionCopy(
        title: strings.missionFamilyCookTitle,
        description: strings.missionFamilyCookDescription,
        proofHint: strings.missionFamilyCookProofHint,
      ),
      'family_game_night' => LocalizedFamilyMissionCopy(
        title: strings.missionFamilyGameNightTitle,
        description: strings.missionFamilyGameNightDescription,
        proofHint: strings.missionFamilyGameNightProofHint,
      ),
      'family_screen_free' => LocalizedFamilyMissionCopy(
        title: strings.missionFamilyScreenFreeTitle,
        description: strings.missionFamilyScreenFreeDescription,
        proofHint: strings.missionFamilyScreenFreeProofHint,
      ),
      'family_cleanup' => LocalizedFamilyMissionCopy(
        title: strings.missionFamilyCleanupTitle,
        description: strings.missionFamilyCleanupDescription,
        proofHint: strings.missionFamilyCleanupProofHint,
      ),
      'family_outdoor' => LocalizedFamilyMissionCopy(
        title: strings.missionFamilyOutdoorTitle,
        description: strings.missionFamilyOutdoorDescription,
        proofHint: strings.missionFamilyOutdoorProofHint,
      ),
      'family_old_photos' => LocalizedFamilyMissionCopy(
        title: strings.missionFamilyOldPhotosTitle,
        description: strings.missionFamilyOldPhotosDescription,
        proofHint: strings.missionFamilyOldPhotosProofHint,
      ),
      'family_dessert' => LocalizedFamilyMissionCopy(
        title: strings.missionFamilyDessertTitle,
        description: strings.missionFamilyDessertDescription,
        proofHint: strings.missionFamilyDessertProofHint,
      ),
      'family_picnic' => LocalizedFamilyMissionCopy(
        title: strings.missionFamilyPicnicTitle,
        description: strings.missionFamilyPicnicDescription,
        proofHint: strings.missionFamilyPicnicProofHint,
      ),
      'family_visit_relative' => LocalizedFamilyMissionCopy(
        title: strings.missionFamilyVisitRelativeTitle,
        description: strings.missionFamilyVisitRelativeDescription,
        proofHint: strings.missionFamilyVisitRelativeProofHint,
      ),
      'family_recreate_photo' => LocalizedFamilyMissionCopy(
        title: strings.missionFamilyRecreatePhotoTitle,
        description: strings.missionFamilyRecreatePhotoDescription,
        proofHint: strings.missionFamilyRecreatePhotoProofHint,
      ),
      'family_kindness_project' => LocalizedFamilyMissionCopy(
        title: strings.missionFamilyKindnessProjectTitle,
        description: strings.missionFamilyKindnessProjectDescription,
        proofHint: strings.missionFamilyKindnessProjectProofHint,
      ),
      _ => LocalizedFamilyMissionCopy(
        title: mission.title,
        description: mission.description,
        proofHint: mission.proofHint,
      ),
    };
  }

  static String category(AppLocalizations strings, String category) {
    return switch (category) {
      'Outdoor' => strings.missionCategoryOutdoor,
      'Together Time' => strings.missionCategoryTogetherTime,
      'Memories' => strings.missionCategoryMemories,
      'Kindness' => strings.missionCategoryKindness,
      'Connection' => strings.missionCategoryConnection,
      'Fun' => strings.missionCategoryFun,
      'Teamwork' => strings.missionCategoryTeamwork,
      _ => category,
    };
  }
}
