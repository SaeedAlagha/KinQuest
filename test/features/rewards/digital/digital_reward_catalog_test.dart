import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/rewards/digital/digital_reward_catalog.dart';
import 'package:kinquest/features/rewards/digital/digital_reward_definition.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('built-in catalog contains 18 unique functional rewards', () async {
    final rewards = await DigitalRewardCatalog.load();

    expect(rewards, hasLength(18));
    expect(rewards.map((reward) => reward.id).toSet(), hasLength(18));
    expect(
      rewards.map((reward) => reward.category).toSet(),
      containsAll(DigitalRewardCategory.values),
    );
    expect(rewards.every((reward) => reward.cost > 0), isTrue);
    expect(rewards.every((reward) => reward.assetKey.isNotEmpty), isTrue);
  });

  test('catalog rejects unknown categories', () {
    expect(
      () => DigitalRewardCatalog.decode('''
        [{
          "id": "unknown",
          "name": "Unknown",
          "description": "Unknown",
          "cost": 1,
          "category": "competitiveAdvantage",
          "assetKey": "unfair",
          "previewAsset": "",
          "isActive": true,
          "isLimited": false,
          "sortOrder": 1
        }]
      '''),
      throwsFormatException,
    );
  });
}
