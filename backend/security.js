const { getAuth } = require("firebase-admin/auth");
const { ensureFirebaseAdmin } = require("./firebase_admin");

const DEFAULT_RATE_LIMIT = 60;
const DEFAULT_RATE_WINDOW_MS = 60_000;

function parsePositiveInteger(value, fallback) {
  const parsed = Number.parseInt(value, 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

function authenticationRequired(environment = process.env) {
  const configured = environment.KINQUEST_REQUIRE_AUTH?.trim().toLowerCase();

  if (configured === "true") return true;
  if (configured === "false") return false;

  return environment.NODE_ENV === "production";
}

function isOriginAllowed(origin, environment = process.env) {
  if (!origin) return true;

  const configuredOrigins = (environment.KINQUEST_ALLOWED_ORIGINS || "")
    .split(",")
    .map((value) => value.trim())
    .filter(Boolean);

  if (configuredOrigins.length > 0) {
    return configuredOrigins.includes(origin);
  }

  if (environment.NODE_ENV === "production") {
    return false;
  }

  return /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin);
}

function createCorsOptions(environment = process.env) {
  return {
    methods: ["GET", "POST", "OPTIONS"],
    allowedHeaders: ["Authorization", "Content-Type"],
    maxAge: 600,
    origin(origin, callback) {
      callback(null, isOriginAllowed(origin, environment));
    },
  };
}

function securityHeaders(request, response, next) {
  response.setHeader("Cache-Control", "no-store");
  response.setHeader(
    "Content-Security-Policy",
    "default-src 'none'; base-uri 'none'; frame-ancestors 'none'",
  );
  response.setHeader("Cross-Origin-Resource-Policy", "same-site");
  response.setHeader("Permissions-Policy", "camera=(), microphone=(), geolocation=()");
  response.setHeader("Referrer-Policy", "no-referrer");
  response.setHeader("X-Content-Type-Options", "nosniff");
  response.setHeader("X-Frame-Options", "DENY");
  next();
}

function requestKey(request) {
  return request.ip || request.socket?.remoteAddress || "unknown";
}

function createRateLimiter({
  limit = parsePositiveInteger(
    process.env.KINQUEST_RATE_LIMIT,
    DEFAULT_RATE_LIMIT,
  ),
  windowMs = parsePositiveInteger(
    process.env.KINQUEST_RATE_WINDOW_MS,
    DEFAULT_RATE_WINDOW_MS,
  ),
  now = Date.now,
} = {}) {
  const clients = new Map();

  return function rateLimit(request, response, next) {
    const currentTime = now();
    const key = requestKey(request);
    const previous = clients.get(key);
    const entry =
      previous && currentTime - previous.startedAt < windowMs
        ? previous
        : { count: 0, startedAt: currentTime };

    entry.count += 1;
    clients.set(key, entry);

    const remaining = Math.max(limit - entry.count, 0);
    const resetSeconds = Math.max(
      Math.ceil((entry.startedAt + windowMs - currentTime) / 1000),
      1,
    );

    response.setHeader("RateLimit-Limit", String(limit));
    response.setHeader("RateLimit-Remaining", String(remaining));
    response.setHeader("RateLimit-Reset", String(resetSeconds));

    if (entry.count > limit) {
      response.setHeader("Retry-After", String(resetSeconds));
      return response.status(429).json({
        error: "Too many requests. Please wait before trying again.",
      });
    }

    if (clients.size > 5_000) {
      for (const [clientKey, client] of clients) {
        if (currentTime - client.startedAt >= windowMs) {
          clients.delete(clientKey);
        }
      }
    }

    return next();
  };
}

function defaultTokenVerifier(token) {
  ensureFirebaseAdmin();
  return getAuth().verifyIdToken(token, true);
}

function createFirebaseAuthMiddleware({
  environment = process.env,
  verifyToken = defaultTokenVerifier,
} = {}) {
  return async function firebaseAuth(request, response, next) {
    const required = authenticationRequired(environment);
    const authorization = request.get?.("authorization") || "";

    if (!required && !authorization) {
      return next();
    }

    const match = authorization.match(/^Bearer ([^\s]+)$/);

    if (!match || match[1].length > 4_096) {
      return response.status(401).json({
        error: "Sign in is required to use Sila AI features.",
      });
    }

    try {
      request.auth = await verifyToken(match[1]);
      return next();
    } catch (_) {
      return response.status(401).json({
        error: "Your session is invalid or expired. Please sign in again.",
      });
    }
  };
}

module.exports = {
  authenticationRequired,
  createCorsOptions,
  createFirebaseAuthMiddleware,
  createRateLimiter,
  isOriginAllowed,
  securityHeaders,
};
