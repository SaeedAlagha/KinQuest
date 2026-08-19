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
  arrayUnion,
  collection,
  doc,
  getDoc,
  setDoc,
  updateDoc,
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

  await assertSucceeds(
    updateDoc(familyReference, { members: arrayUnion("charlie") }),
  );
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
