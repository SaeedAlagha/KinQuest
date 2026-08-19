const { existsSync, readFileSync } = require("node:fs");
const { join } = require("node:path");
const {
  cert,
  getApps,
  initializeApp,
} = require("firebase-admin/app");

function loadServiceAccount(environment = process.env) {
  const configuredJson = environment.FIREBASE_SERVICE_ACCOUNT_JSON?.trim();

  if (configuredJson) {
    return JSON.parse(configuredJson);
  }

  const legacyPath = join(__dirname, "firebase-service-account.json");

  if (existsSync(legacyPath)) {
    return JSON.parse(readFileSync(legacyPath, "utf8"));
  }

  return null;
}

function ensureFirebaseAdmin(environment = process.env) {
  if (getApps().length > 0) {
    return getApps()[0];
  }

  const serviceAccount = loadServiceAccount(environment);

  if (serviceAccount) {
    return initializeApp({ credential: cert(serviceAccount) });
  }

  // Cloud Run, App Engine, and other Google environments use Application
  // Default Credentials. Local developers can keep using the ignored legacy
  // service-account file or FIREBASE_SERVICE_ACCOUNT_JSON.
  return initializeApp();
}

module.exports = { ensureFirebaseAdmin, loadServiceAccount };
