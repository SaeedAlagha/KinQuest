const assert = require("node:assert/strict");
const { readFileSync } = require("node:fs");
const { resolve } = require("node:path");
const test = require("node:test");

const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require("@firebase/rules-unit-testing");
const {
  arrayRemove,
  arrayUnion,
  collection,
  doc,
  getDoc,
  setDoc,
  updateDoc,
  writeBatch,
} = require("firebase/firestore");

const projectId = "demo-kinquest";
let testEnvironment;

test.before(async () => {
  const [host, portText] = (
    process.env.FIRESTORE_EMULATOR_HOST || "127.0.0.1:9090"
  ).split(":");

  testEnvironment = await initializeTestEnvironment({
    projectId,
    firestore: {
      host,
      port: Number(portText),
      rules: readFileSync(resolve(__dirname, "../../firestore.rules"), "utf8"),
    },
  });
});

test.after(async () => {
  await testEnvironment.cleanup();
});

test.beforeEach(async () => {
  await testEnvironment.clearFirestore();

  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const database = context.firestore();

    await Promise.all([
      setDoc(doc(database, "users/alice"), {
        familyId: "FAMILY_A",
        name: "Alice",
      }),
      setDoc(doc(database, "users/bob"), {
        familyId: "FAMILY_A",
        name: "Bob",
      }),
      setDoc(doc(database, "users/mallory"), {
        familyId: "FAMILY_B",
        name: "Mallory",
      }),
      setDoc(doc(database, "users/charlie"), {
        familyId: null,
        name: "Charlie",
      }),
      setDoc(doc(database, "families/FAMILY_A"), {
        ownerId: "alice",
        members: ["alice", "bob"],
        name: "Family A",
      }),
      setDoc(doc(database, "families/FAMILY_B"), {
        ownerId: "mallory",
        members: ["mallory"],
        name: "Family B",
      }),
      setDoc(doc(database, "families/FAMILY_A/memories/memory-1"), {
        createdBy: "alice",
        title: "Private family memory",
      }),
      setDoc(doc(database, "users/alice/ownedRewards/frame_gold"), {
        rewardId: "frame_gold",
        category: "profileFrame",
        assetKey: "gold",
        equipped: true,
      }),
      setDoc(doc(database, "users/alice/settings/digitalRewards"), {
        profileFrame: "gold",
        profileBadge: "default",
        profileTheme: "default",
        celebrationEffect: "default",
        nameplate: "default",
      }),
    ]);
  });
});

test("family content is readable only inside the authenticated family", async () => {
  const aliceDatabase = testEnvironment
    .authenticatedContext("alice")
    .firestore();
  const malloryDatabase = testEnvironment
    .authenticatedContext("mallory")
    .firestore();
  const memoryPath = "families/FAMILY_A/memories/memory-1";

  await assertSucceeds(getDoc(doc(aliceDatabase, memoryPath)));
  await assertFails(getDoc(doc(malloryDatabase, memoryPath)));
});

test("digital rewards are family-visible but backend-write-only", async () => {
  const aliceDatabase = testEnvironment
    .authenticatedContext("alice")
    .firestore();
  const bobDatabase = testEnvironment
    .authenticatedContext("bob")
    .firestore();
  const malloryDatabase = testEnvironment
    .authenticatedContext("mallory")
    .firestore();
  const ownedPath = "users/alice/ownedRewards/frame_gold";
  const settingsPath = "users/alice/settings/digitalRewards";

  await assertSucceeds(getDoc(doc(aliceDatabase, ownedPath)));
  await assertSucceeds(getDoc(doc(bobDatabase, ownedPath)));
  await assertFails(getDoc(doc(malloryDatabase, ownedPath)));
  await assertSucceeds(getDoc(doc(bobDatabase, settingsPath)));
  await assertFails(getDoc(doc(malloryDatabase, settingsPath)));

  await assertFails(
    setDoc(doc(aliceDatabase, "users/alice/ownedRewards/forged"), {
      rewardId: "forged",
      category: "profileFrame",
      assetKey: "gold",
      equipped: true,
    }),
  );
  await assertFails(
    updateDoc(doc(aliceDatabase, settingsPath), {
      profileFrame: "forged",
    }),
  );
});

test("an invite holder can add only their own membership", async () => {
  const database = testEnvironment
    .authenticatedContext("charlie")
    .firestore();
  const familyReference = doc(database, "families/FAMILY_A");

  await assertFails(
    updateDoc(familyReference, {
      members: arrayUnion("charlie"),
      name: "Hijacked family",
    }),
  );

  const joinBatch = writeBatch(database);
  joinBatch.update(familyReference, { members: arrayUnion("charlie") });
  joinBatch.update(doc(database, "users/charlie"), {
    familyId: "FAMILY_A",
  });

  await assertSucceeds(joinBatch.commit());
});

test("a member cannot join a second family or remove somebody else", async () => {
  const malloryDatabase = testEnvironment
    .authenticatedContext("mallory")
    .firestore();
  const bobDatabase = testEnvironment
    .authenticatedContext("bob")
    .firestore();

  await assertFails(
    updateDoc(doc(malloryDatabase, "families/FAMILY_A"), {
      members: arrayUnion("mallory"),
    }),
  );

  await assertFails(
    updateDoc(doc(bobDatabase, "families/FAMILY_A"), {
      members: arrayRemove("alice"),
    }),
  );
});

test("a non-owner can leave atomically without changing other members", async () => {
  const database = testEnvironment.authenticatedContext("bob").firestore();
  const batch = writeBatch(database);

  batch.update(doc(database, "families/FAMILY_A"), {
    members: arrayRemove("bob"),
    rewardApproverIds: arrayRemove("bob"),
  });
  batch.update(doc(database, "users/bob"), { familyId: null });

  await assertSucceeds(batch.commit());
});

test("the family owner can remove a member and clear their family link", async () => {
  const database = testEnvironment.authenticatedContext("alice").firestore();
  const batch = writeBatch(database);

  batch.update(doc(database, "families/FAMILY_A"), {
    members: arrayRemove("bob"),
    rewardApproverIds: arrayRemove("bob"),
  });
  batch.update(doc(database, "users/bob"), { familyId: null });

  await assertSucceeds(batch.commit());
});

test("only the family owner can manage reward definitions", async () => {
  const ownerDatabase = testEnvironment
    .authenticatedContext("alice")
    .firestore();
  const memberDatabase = testEnvironment
    .authenticatedContext("bob")
    .firestore();

  await assertSucceeds(
    setDoc(doc(collection(ownerDatabase, "families/FAMILY_A/rewards")), {
      title: "Family dinner",
      tokenCost: 350,
    }),
  );

  await assertFails(
    setDoc(doc(collection(memberDatabase, "families/FAMILY_A/rewards")), {
      title: "Unauthorized reward",
      tokenCost: 1,
    }),
  );
});

test("mission completions accept verdicts but reject retained proof images", async () => {
  const database = testEnvironment
    .authenticatedContext("alice")
    .firestore();
  const completions = collection(
    database,
    "families/FAMILY_A/missionCompletions",
  );

  await assertSucceeds(
    setDoc(doc(completions, "safe-completion"), {
      familyId: "FAMILY_A",
      submittedBy: "alice",
      proofRetained: false,
      verificationVerdict: "verified",
    }),
  );

  await assertFails(
    setDoc(doc(completions, "retained-proof"), {
      familyId: "FAMILY_A",
      submittedBy: "alice",
      proofRetained: true,
      proof: "base64-photo-data",
    }),
  );

  assert.ok(true);
});

test("wishlist negotiations stay between members of one family", async () => {
  const aliceDatabase = testEnvironment
    .authenticatedContext("alice")
    .firestore();
  const malloryDatabase = testEnvironment
    .authenticatedContext("mallory")
    .firestore();
  const proposals = collection(
    aliceDatabase,
    "families/FAMILY_A/rewardWishlistProposals",
  );

  await assertSucceeds(
    setDoc(doc(proposals, "family-proposal"), {
      familyId: "FAMILY_A",
      requesterId: "alice",
      recipientId: "bob",
      status: "requested",
    }),
  );

  await assertSucceeds(
    setDoc(doc(aliceDatabase, "users/bob/notifications/request"), {
      userId: "bob",
      familyId: "FAMILY_A",
      type: "wishlistRequest",
    }),
  );

  await assertFails(
    setDoc(doc(malloryDatabase, "users/bob/notifications/intrusion"), {
      userId: "bob",
      familyId: "FAMILY_A",
      type: "wishlistRequest",
    }),
  );
});
