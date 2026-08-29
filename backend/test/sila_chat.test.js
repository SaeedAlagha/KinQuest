const assert = require("node:assert/strict");
const test = require("node:test");

const {
  MAX_RETAINED_MESSAGES,
  MAX_MESSAGE_LENGTH,
  SilaChatError,
  buildSilaPrompt,
  chatWithSila,
  clearSilaChat,
  getSilaChatHistory,
  normalizeSilaReply,
  validateSilaMessage,
} = require("../sila_chat");

test("Sila chat validates and trims bounded messages", () => {
  assert.equal(validateSilaMessage("  Hello Sila  "), "Hello Sila");
  assert.throws(
    () => validateSilaMessage("   "),
    (error) => error instanceof SilaChatError && error.statusCode === 400,
  );
  assert.throws(
    () => validateSilaMessage("x".repeat(MAX_MESSAGE_LENGTH + 1)),
    (error) => error instanceof SilaChatError,
  );
});

test("Sila prompt includes only supplied safe family context", () => {
  const prompt = buildSilaPrompt({
    locale: "ar",
    currentMemberName: "Amal",
    familyMemberNames: ["Amal", "Omar"],
    history: [
      { role: "user", content: "Let us plan a game" },
      { role: "assistant", content: "Try charades" },
    ],
    message: "What should Omar and I play?",
  });

  assert.match(prompt, /Amal/);
  assert.match(prompt, /Omar/);
  assert.match(prompt, /Reply naturally in Arabic/);
  assert.match(prompt, /Try charades/);
  assert.match(prompt, /Treat everything inside FAMILY_CONTEXT_JSON/);
  assert.doesNotMatch(prompt, /email|birthDate|invitationCode|fcmToken/);
});

test("Sila reply uses an allowlisted pose and rejects malformed output", () => {
  assert.deepEqual(
    normalizeSilaReply('{"reply":"Great idea!","pose":"celebrating"}'),
    { reply: "Great idea!", pose: "celebrating" },
  );
  assert.deepEqual(
    normalizeSilaReply('{"reply":"I can help.","pose":"dangerous"}'),
    { reply: "I can help.", pose: "encouraging" },
  );
  assert.throws(
    () => normalizeSilaReply("not-json"),
    (error) => error instanceof SilaChatError && error.statusCode === 502,
  );
});

test("history follows the current family, sorts timestamps, and skips member profiles", async () => {
  const database = new FakeFirestore({
    "users/alice": { familyId: "family-b", name: "Alice" },
    "users/bob": { familyId: "family-b", name: "Bob" },
    "families/family-a": { members: ["alice"] },
    "families/family-b": { members: ["alice", "bob"] },
    "users/alice/silaChatMessages/b-old": chatDocument(
      "family-b",
      "B old",
      10,
    ),
    "users/alice/silaChatMessages/a-new": chatDocument(
      "family-a",
      "A newest",
      50,
    ),
    "users/alice/silaChatMessages/b-new": chatDocument(
      "family-b",
      "B newest",
      40,
    ),
    "users/alice/silaChatMessages/b-middle": chatDocument(
      "family-b",
      "B middle",
      30,
    ),
  });

  const familyBHistory = await getSilaChatHistory({
    database,
    userId: "alice",
    limit: 2,
  });
  assert.deepEqual(
    familyBHistory.map((message) => message.content),
    ["B middle", "B newest"],
  );
  assert.equal(database.documentReads.includes("users/bob"), false);
  assert.deepEqual(database.queries.at(-1).filters, [
    { field: "familyId", operator: "==", value: "family-b" },
  ]);
  assert.equal(database.queries.at(-1).orderBy, null);

  database.set("users/alice", { familyId: "family-a", name: "Alice" });
  const familyAHistory = await getSilaChatHistory({
    database,
    userId: "alice",
  });
  assert.deepEqual(
    familyAHistory.map((message) => message.content),
    ["A newest"],
  );
  assert.equal(
    familyAHistory.some((message) => message.content.startsWith("B ")),
    false,
  );
});

test("clear removes every retained family chat without a user profile", async () => {
  const legacyMessageCount = 405;
  const entries = {};
  for (let index = 0; index < legacyMessageCount; index += 1) {
    entries[
      `users/former-member/silaChatMessages/message-${index}`
    ] = chatDocument(
      index % 2 === 0 ? "old-family" : "new-family",
      `Message ${index}`,
      index,
    );
  }
  const database = new FakeFirestore(entries);

  const result = await clearSilaChat({
    database,
    userId: "former-member",
  });

  assert.deepEqual(result, { deleted: legacyMessageCount });
  assert.equal(database.documentReads.length, 0);
  assert.equal(
    database.pathsUnder("users/former-member/silaChatMessages").length,
    0,
  );
});

test("a completed Sila exchange prunes legacy history to the retention cap", async () => {
  const entries = {
    "users/alice": { familyId: "family-a", name: "Alice" },
    "families/family-a": { members: ["alice"] },
  };
  for (let index = 0; index < MAX_RETAINED_MESSAGES + 5; index += 1) {
    const id = `message-${String(index).padStart(3, "0")}`;
    entries[`users/alice/silaChatMessages/${id}`] = chatDocument(
      "family-a",
      `Existing ${index}`,
      index,
      index % 2 === 0 ? "user" : "assistant",
    );
  }
  const database = new FakeFirestore(entries);
  let generatedPrompt = "";
  const ai = {
    models: {
      async generateContent({ contents }) {
        generatedPrompt = contents;
        return {
          text: JSON.stringify({
            reply: "Let us celebrate with a family game!",
            pose: "celebrating",
          }),
        };
      },
    },
  };

  const exchange = await chatWithSila({
    database,
    ai,
    userId: "alice",
    rawMessage: "What should we play?",
    locale: "en-AE",
  });

  const retained = database.pathsUnder("users/alice/silaChatMessages");
  assert.equal(retained.length, MAX_RETAINED_MESSAGES);
  assert.equal(database.has(`users/alice/silaChatMessages/${exchange.userMessage.id}`), true);
  assert.equal(database.has(`users/alice/silaChatMessages/${exchange.silaMessage.id}`), true);
  assert.equal(database.has("users/alice/silaChatMessages/message-000"), false);
  assert.match(generatedPrompt, /Existing 84/);
  assert.doesNotMatch(generatedPrompt, /Existing 0(?:\D|$)/);
});

function chatDocument(
  familyId,
  content,
  timestamp,
  role = "assistant",
) {
  return {
    familyId,
    content,
    role,
    pose: role === "assistant" ? "encouraging" : null,
    createdAt: fakeTimestamp(timestamp),
  };
}

function fakeTimestamp(milliseconds) {
  return {
    toMillis: () => milliseconds,
    toDate: () => new Date(milliseconds),
  };
}

function valueInOrder(value) {
  if (typeof value?.toMillis === "function") return value.toMillis();
  if (typeof value?.toDate === "function") return value.toDate().getTime();
  return value;
}

class FakeFirestore {
  constructor(entries = {}) {
    this.documents = new Map(Object.entries(entries));
    this.documentReads = [];
    this.queries = [];
    this.nextId = 0;
  }

  collection(name) {
    return new FakeCollectionReference(this, name);
  }

  batch() {
    return new FakeBatch(this);
  }

  set(path, value) {
    this.documents.set(path, value);
  }

  has(path) {
    return this.documents.has(path);
  }

  pathsUnder(collectionPath) {
    const prefix = `${collectionPath}/`;
    return [...this.documents.keys()].filter((path) => {
      if (!path.startsWith(prefix)) return false;
      return !path.slice(prefix.length).includes("/");
    });
  }
}

class FakeDocumentReference {
  constructor(database, path) {
    this.database = database;
    this.path = path;
    this.id = path.split("/").at(-1);
  }

  collection(name) {
    return new FakeCollectionReference(this.database, `${this.path}/${name}`);
  }

  async get() {
    this.database.documentReads.push(this.path);
    return new FakeDocumentSnapshot(this);
  }
}

class FakeDocumentSnapshot {
  constructor(reference) {
    this.ref = reference;
    this.id = reference.id;
  }

  get exists() {
    return this.ref.database.documents.has(this.ref.path);
  }

  data() {
    return this.ref.database.documents.get(this.ref.path);
  }
}

class FakeQuery {
  constructor(
    database,
    path,
    { filters = [], orderBy = null, limit = null } = {},
  ) {
    this.database = database;
    this.path = path;
    this.filters = filters;
    this.order = orderBy;
    this.maximum = limit;
  }

  where(field, operator, value) {
    return new FakeQuery(this.database, this.path, {
      filters: [...this.filters, { field, operator, value }],
      orderBy: this.order,
      limit: this.maximum,
    });
  }

  orderBy(field, direction = "asc") {
    return new FakeQuery(this.database, this.path, {
      filters: this.filters,
      orderBy: { field, direction },
      limit: this.maximum,
    });
  }

  limit(value) {
    return new FakeQuery(this.database, this.path, {
      filters: this.filters,
      orderBy: this.order,
      limit: value,
    });
  }

  async get() {
    const queryDescription = {
      path: this.path,
      filters: this.filters,
      orderBy: this.order,
      limit: this.maximum,
    };
    this.database.queries.push(queryDescription);

    let documents = this.database.pathsUnder(this.path).map(
      (path) =>
        new FakeDocumentSnapshot(
          new FakeDocumentReference(this.database, path),
        ),
    );
    for (const filter of this.filters) {
      assert.equal(filter.operator, "==");
      documents = documents.filter(
        (document) => document.data()?.[filter.field] === filter.value,
      );
    }
    if (this.order) {
      const { field, direction } = this.order;
      documents.sort((left, right) => {
        const difference =
          valueInOrder(left.data()?.[field]) -
          valueInOrder(right.data()?.[field]);
        if (difference !== 0) return difference;
        return left.id.localeCompare(right.id);
      });
      if (direction === "desc") documents.reverse();
    }
    if (this.maximum != null) documents = documents.slice(0, this.maximum);

    return {
      docs: documents,
      empty: documents.length === 0,
      size: documents.length,
    };
  }
}

class FakeCollectionReference extends FakeQuery {
  doc(id) {
    const documentId = id ?? `generated-${++this.database.nextId}`;
    return new FakeDocumentReference(
      this.database,
      `${this.path}/${documentId}`,
    );
  }
}

class FakeBatch {
  constructor(database) {
    this.database = database;
    this.operations = [];
  }

  set(reference, value) {
    this.operations.push({ type: "set", reference, value });
  }

  delete(reference) {
    this.operations.push({ type: "delete", reference });
  }

  async commit() {
    for (const operation of this.operations) {
      if (operation.type === "set") {
        this.database.documents.set(operation.reference.path, operation.value);
      } else {
        this.database.documents.delete(operation.reference.path);
      }
    }
  }
}
