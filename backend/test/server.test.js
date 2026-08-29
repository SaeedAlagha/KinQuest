const assert = require("node:assert/strict");
const test = require("node:test");

const app = require("../server");

test("server wires health, privacy headers, and JSON validation", async (t) => {
  const server = app.listen(0);
  t.after(() => server.close());

  await new Promise((resolve) => server.once("listening", resolve));

  const { port } = server.address();
  const baseUrl = `http://127.0.0.1:${port}`;
  const health = await fetch(baseUrl);

  assert.equal(health.status, 200);
  assert.equal(health.headers.get("cache-control"), "no-store");
  assert.equal(health.headers.get("x-content-type-options"), "nosniff");
  assert.equal(health.headers.has("x-powered-by"), false);

  const clearChatPreflight = await fetch(`${baseUrl}/api/sila/chat`, {
    method: "OPTIONS",
    headers: {
      origin: "http://localhost:8080",
      "access-control-request-method": "DELETE",
      "access-control-request-headers": "authorization,content-type",
    },
  });
  assert.equal(clearChatPreflight.status, 204);
  assert.match(
    clearChatPreflight.headers.get("access-control-allow-methods") || "",
    /DELETE/,
  );

  const catalog = await fetch(`${baseUrl}/api/digital-rewards`);
  assert.equal(catalog.status, 200);
  assert.equal((await catalog.json()).rewards.length, 30);

  const invalidJson = await fetch(`${baseUrl}/api/trivia`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: "{",
  });

  assert.equal(invalidJson.status, 400);
  assert.deepEqual(await invalidJson.json(), {
    error: "Request body must be valid JSON.",
  });

  const anonymousPurchase = await fetch(
    `${baseUrl}/api/digital-rewards/purchase`,
    {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ rewardId: "frame_gold" }),
    },
  );
  assert.equal(anonymousPurchase.status, 401);
  assert.deepEqual(await anonymousPurchase.json(), {
    error: "Sign in is required to manage Digital Rewards.",
  });

  const anonymousSilaChat = await fetch(`${baseUrl}/api/sila/chat`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ message: "Hello Sila" }),
  });
  assert.equal(anonymousSilaChat.status, 401);
  assert.deepEqual(await anonymousSilaChat.json(), {
    error: "Sign in is required to chat with Sila.",
  });
});
