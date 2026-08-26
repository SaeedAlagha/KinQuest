const { readFileSync } = require("node:fs");
const { join } = require("node:path");
const { FieldValue } = require("firebase-admin/firestore");

class DigitalRewardError extends Error {
  constructor(message, statusCode = 400) {
    super(message);
    this.name = "DigitalRewardError";
    this.statusCode = statusCode;
  }
}

function loadCatalog() {
  const path = join(
    __dirname,
    "..",
    "assets",
    "config",
    "digital_rewards.json",
  );
  const decoded = JSON.parse(readFileSync(path, "utf8"));

  if (!Array.isArray(decoded)) {
    throw new Error("Digital Reward catalog must be a list.");
  }

  const identifiers = new Set();
  for (const reward of decoded) {
    if (
      typeof reward.id !== "string" ||
      !reward.id ||
      typeof reward.name !== "string" ||
      !reward.name ||
      !Number.isInteger(reward.cost) ||
      reward.cost <= 0 ||
      typeof reward.category !== "string" ||
      !reward.category ||
      typeof reward.assetKey !== "string" ||
      !reward.assetKey
    ) {
      throw new Error("Digital Reward catalog contains an invalid item.");
    }

    if (identifiers.has(reward.id)) {
      throw new Error(`Duplicate Digital Reward identifier: ${reward.id}`);
    }
    identifiers.add(reward.id);
  }

  return Object.freeze(
    decoded
      .filter((reward) => reward.isActive === true)
      .sort((a, b) => a.sortOrder - b.sortOrder)
      .map((reward) => Object.freeze({ ...reward })),
  );
}

const digitalRewardCatalog = loadCatalog();
const rewardsById = new Map(
  digitalRewardCatalog.map((reward) => [reward.id, reward]),
);

function rewardById(rewardId) {
  const reward = rewardsById.get(rewardId);
  if (!reward) {
    throw new DigitalRewardError(
      "This Digital Reward is not currently available.",
      404,
    );
  }
  return reward;
}

function unequippedAssetFor(category) {
  return ["profileBadge", "mascotAccessory", "mascotOutfit", "mascotAura"]
    .includes(category)
    ? "none"
    : "default";
}

async function purchaseDigitalReward({ database, userId, rewardId }) {
  const reward = rewardById(rewardId);
  const userRef = database.collection("users").doc(userId);
  const ownedRewardRef = userRef.collection("ownedRewards").doc(reward.id);
  const tokenTransactionRef = userRef.collection("tokenTransactions").doc();

  return database.runTransaction(async (transaction) => {
    const userSnapshot = await transaction.get(userRef);
    if (!userSnapshot.exists) {
      throw new DigitalRewardError("User not found.", 404);
    }

    const userData = userSnapshot.data();
    const familyId = userData.familyId;
    if (typeof familyId !== "string" || !familyId) {
      throw new DigitalRewardError(
        "Join a family before purchasing Digital Rewards.",
      );
    }

    const familyRef = database.collection("families").doc(familyId);
    const familySnapshot = await transaction.get(familyRef);
    const ownedSnapshot = await transaction.get(ownedRewardRef);

    if (!familySnapshot.exists) {
      throw new DigitalRewardError("Family not found.", 404);
    }

    const members = familySnapshot.data().members || [];
    if (!Array.isArray(members) || !members.includes(userId)) {
      throw new DigitalRewardError("You are not a member of this family.", 403);
    }

    if (ownedSnapshot.exists) {
      throw new DigitalRewardError("You already own this Digital Reward.", 409);
    }

    const tokens = Number(userData.tokens) || 0;
    if (tokens < reward.cost) {
      throw new DigitalRewardError("You do not have enough Tokens.");
    }

    transaction.update(userRef, {
      tokens: FieldValue.increment(-reward.cost),
      updatedAt: FieldValue.serverTimestamp(),
    });
    transaction.set(ownedRewardRef, {
      rewardId: reward.id,
      name: reward.name,
      description: reward.description,
      cost: reward.cost,
      category: reward.category,
      assetKey: reward.assetKey,
      previewAsset: reward.previewAsset,
      purchasedAt: FieldValue.serverTimestamp(),
      equipped: false,
    });
    transaction.set(tokenTransactionRef, {
      userId,
      familyId,
      amount: -reward.cost,
      type: "spent",
      reason: `Digital reward: ${reward.name}`,
      relatedRewardId: reward.id,
      relatedRequestId: null,
      relatedCompetitionId: null,
      createdAt: FieldValue.serverTimestamp(),
    });

    return { reward, remainingTokens: tokens - reward.cost };
  });
}

async function equipDigitalReward({ database, userId, rewardId }) {
  const canonicalReward = rewardById(rewardId);
  const userRef = database.collection("users").doc(userId);
  const ownedRewardsRef = userRef.collection("ownedRewards");
  const selectedRef = ownedRewardsRef.doc(rewardId);
  const settingsRef = userRef.collection("settings").doc("digitalRewards");

  return database.runTransaction(async (transaction) => {
    const selectedSnapshot = await transaction.get(selectedRef);
    if (!selectedSnapshot.exists) {
      throw new DigitalRewardError("You do not own this Digital Reward.", 403);
    }

    const selected = selectedSnapshot.data();
    if (
      selected.category !== canonicalReward.category ||
      selected.assetKey !== canonicalReward.assetKey
    ) {
      throw new DigitalRewardError("This owned reward is invalid.", 409);
    }

    const sameCategory = await transaction.get(
      ownedRewardsRef.where("category", "==", canonicalReward.category),
    );

    for (const document of sameCategory.docs) {
      transaction.update(document.ref, {
        equipped: document.id === rewardId,
      });
    }

    transaction.set(
      settingsRef,
      {
        [canonicalReward.category]: canonicalReward.assetKey,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    return { reward: canonicalReward };
  });
}

async function unequipDigitalReward({ database, userId, rewardId }) {
  const canonicalReward = rewardById(rewardId);
  const userRef = database.collection("users").doc(userId);
  const ownedRewardRef = userRef.collection("ownedRewards").doc(rewardId);
  const settingsRef = userRef.collection("settings").doc("digitalRewards");

  return database.runTransaction(async (transaction) => {
    const ownedSnapshot = await transaction.get(ownedRewardRef);
    if (!ownedSnapshot.exists) {
      throw new DigitalRewardError("You do not own this Digital Reward.", 403);
    }

    const owned = ownedSnapshot.data();
    if (
      owned.category !== canonicalReward.category ||
      owned.assetKey !== canonicalReward.assetKey
    ) {
      throw new DigitalRewardError("This owned reward is invalid.", 409);
    }

    transaction.update(ownedRewardRef, { equipped: false });
    transaction.set(
      settingsRef,
      {
        [canonicalReward.category]: unequippedAssetFor(
          canonicalReward.category,
        ),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    return { reward: canonicalReward };
  });
}

module.exports = {
  DigitalRewardError,
  digitalRewardCatalog,
  equipDigitalReward,
  purchaseDigitalReward,
  rewardById,
  unequippedAssetFor,
  unequipDigitalReward,
};
