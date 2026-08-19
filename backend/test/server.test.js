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

  const invalidJson = await fetch(`${baseUrl}/api/trivia`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: "{",
  });

  assert.equal(invalidJson.status, 400);
  assert.deepEqual(await invalidJson.json(), {
    error: "Request body must be valid JSON.",
  });
});
