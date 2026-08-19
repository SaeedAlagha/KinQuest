const assert = require("node:assert/strict");
const test = require("node:test");

const {
  authenticationRequired,
  createFirebaseAuthMiddleware,
  createRateLimiter,
  isOriginAllowed,
  securityHeaders,
} = require("../security");

function createResponse() {
  return {
    body: null,
    headers: new Map(),
    statusCode: 200,
    setHeader(name, value) {
      this.headers.set(name, value);
    },
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(body) {
      this.body = body;
      return this;
    },
  };
}

test("production authentication is fail-closed by default", () => {
  assert.equal(authenticationRequired({ NODE_ENV: "production" }), true);
  assert.equal(authenticationRequired({ NODE_ENV: "development" }), false);
  assert.equal(
    authenticationRequired({
      NODE_ENV: "production",
      KINQUEST_REQUIRE_AUTH: "false",
    }),
    false,
  );
});

test("CORS allows configured origins and local development only", () => {
  assert.equal(
    isOriginAllowed("https://sila.example", {
      NODE_ENV: "production",
      KINQUEST_ALLOWED_ORIGINS: "https://sila.example",
    }),
    true,
  );
  assert.equal(
    isOriginAllowed("https://attacker.example", {
      NODE_ENV: "production",
      KINQUEST_ALLOWED_ORIGINS: "https://sila.example",
    }),
    false,
  );
  assert.equal(
    isOriginAllowed("http://localhost:8080", { NODE_ENV: "development" }),
    true,
  );
  assert.equal(
    isOriginAllowed("https://attacker.example", { NODE_ENV: "development" }),
    false,
  );
  assert.equal(isOriginAllowed(undefined, { NODE_ENV: "production" }), true);
});

test("security middleware applies privacy-preserving headers", () => {
  const response = createResponse();
  let called = false;

  securityHeaders({}, response, () => {
    called = true;
  });

  assert.equal(called, true);
  assert.equal(response.headers.get("Cache-Control"), "no-store");
  assert.equal(response.headers.get("X-Content-Type-Options"), "nosniff");
  assert.equal(response.headers.get("X-Frame-Options"), "DENY");
});

test("rate limiter blocks requests beyond the configured window quota", () => {
  let currentTime = 1_000;
  const middleware = createRateLimiter({
    limit: 2,
    windowMs: 10_000,
    now: () => currentTime,
  });
  const request = { ip: "203.0.113.4" };

  for (let index = 0; index < 2; index += 1) {
    const response = createResponse();
    let called = false;
    middleware(request, response, () => {
      called = true;
    });
    assert.equal(called, true);
  }

  const blocked = createResponse();
  middleware(request, blocked, () => assert.fail("request should be blocked"));
  assert.equal(blocked.statusCode, 429);
  assert.equal(blocked.headers.get("Retry-After"), "10");

  currentTime += 10_001;
  const reset = createResponse();
  let calledAfterReset = false;
  middleware(request, reset, () => {
    calledAfterReset = true;
  });
  assert.equal(calledAfterReset, true);
});

test("auth middleware rejects missing tokens and accepts verified users", async () => {
  const middleware = createFirebaseAuthMiddleware({
    environment: { NODE_ENV: "production" },
    verifyToken: async (token) => ({ uid: `verified-${token}` }),
  });

  const missingRequest = { get: () => undefined };
  const missingResponse = createResponse();
  await middleware(missingRequest, missingResponse, () => {
    assert.fail("missing token should not continue");
  });
  assert.equal(missingResponse.statusCode, 401);

  const request = { get: () => "Bearer family-token" };
  const response = createResponse();
  let called = false;
  await middleware(request, response, () => {
    called = true;
  });

  assert.equal(called, true);
  assert.deepEqual(request.auth, { uid: "verified-family-token" });
});

test("auth middleware never exposes verifier errors", async () => {
  const middleware = createFirebaseAuthMiddleware({
    environment: { KINQUEST_REQUIRE_AUTH: "true" },
    verifyToken: async () => {
      throw new Error("sensitive provider details");
    },
  });
  const response = createResponse();

  await middleware({ get: () => "Bearer invalid" }, response, () => {
    assert.fail("invalid token should not continue");
  });

  assert.equal(response.statusCode, 401);
  assert.equal(JSON.stringify(response.body).includes("sensitive"), false);
});
