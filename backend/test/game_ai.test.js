const assert = require("node:assert/strict");
const test = require("node:test");

const {
  DEFAULT_GEMINI_FALLBACK_MODEL,
  DEFAULT_GEMINI_MODEL,
  GameAiConfigurationError,
  createGameAi,
} = require("../game_ai");

function fakeClient(handler) {
  return {
    models: {
      generateContent: handler,
    },
  };
}

test("game AI uses Gemini primary model without exposing a key", async () => {
  const requests = [];
  const gameAi = createGameAi({
    client: fakeClient(async (request) => {
      requests.push(request);
      return { text: '{"questions":[]}' };
    }),
  });

  const result = await gameAi.generateContent({
    contents: "family-safe prompt",
    config: { responseMimeType: "application/json" },
  });

  assert.equal(result.text, '{"questions":[]}');
  assert.equal(requests.length, 1);
  assert.equal(requests[0].model, DEFAULT_GEMINI_MODEL);
  assert.equal(requests[0].contents, "family-safe prompt");
  assert.equal("apiKey" in requests[0], false);
});

test("game AI retries temporary errors then falls back to stable Gemini", async () => {
  const models = [];
  const gameAi = createGameAi({
    client: fakeClient(async (request) => {
      models.push(request.model);
      if (request.model === DEFAULT_GEMINI_MODEL) {
        const error = new Error("provider busy");
        error.status = 503;
        throw error;
      }
      return { text: '{"ok":true}' };
    }),
    sleep: async () => {},
  });

  const result = await gameAi.generateContent({ contents: "prompt" });

  assert.equal(result.text, '{"ok":true}');
  assert.deepEqual(models, [
    DEFAULT_GEMINI_MODEL,
    DEFAULT_GEMINI_MODEL,
    DEFAULT_GEMINI_FALLBACK_MODEL,
  ]);
});

test("game AI fails closed when the server has no Gemini key", async () => {
  const gameAi = createGameAi({ apiKey: "" });

  await assert.rejects(
    () => gameAi.generateContent({ contents: "prompt" }),
    (error) => {
      assert.ok(error instanceof GameAiConfigurationError);
      assert.equal(error.statusCode, 503);
      return true;
    },
  );
});

test("game AI does not hide permanent provider errors", async () => {
  let calls = 0;
  const gameAi = createGameAi({
    client: fakeClient(async () => {
      calls += 1;
      const error = new Error("bad request");
      error.status = 400;
      throw error;
    }),
  });

  await assert.rejects(
    () => gameAi.generateContent({ contents: "prompt" }),
    /bad request/,
  );
  assert.equal(calls, 1);
});
