const assert = require("node:assert/strict");
const test = require("node:test");

const {
  DigitalRewardError,
  digitalRewardCatalog,
  rewardById,
} = require("../digital_rewards");

test("built-in Digital Reward catalog ships complete working categories", () => {
  assert.equal(digitalRewardCatalog.length, 15);
  assert.equal(
    new Set(digitalRewardCatalog.map((reward) => reward.id)).size,
    digitalRewardCatalog.length,
  );

  const categories = new Set(
    digitalRewardCatalog.map((reward) => reward.category),
  );
  assert.deepEqual(
    categories,
    new Set([
      "profileFrame",
      "profileBadge",
      "profileTheme",
      "celebrationEffect",
      "nameplate",
    ]),
  );

  for (const reward of digitalRewardCatalog) {
    assert.ok(reward.cost > 0);
    assert.ok(reward.assetKey);
    assert.equal(reward.isActive, true);
  }
});

test("server catalog is canonical and rejects unknown rewards", () => {
  assert.equal(rewardById("frame_gold").cost, 250);
  assert.throws(
    () => rewardById("client-invented-reward"),
    (error) =>
      error instanceof DigitalRewardError && error.statusCode === 404,
  );
});
