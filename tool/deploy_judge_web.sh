#!/usr/bin/env bash

set -euo pipefail

project_id="${FIREBASE_PROJECT_ID:-kinquest-af379}"
site_url="${KINQUEST_SITE_URL:-https://${project_id}.web.app}"
api_base_url="${KINQUEST_API_BASE_URL:-$site_url}"

if [[ ! "$api_base_url" =~ ^https://[^/[:space:]]+(/[^[:space:]]*)?$ ]]; then
  echo "KINQUEST_API_BASE_URL must be an absolute HTTPS URL." >&2
  exit 1
fi

echo "Building Sila for judges..."
flutter build web --release \
  --dart-define="KINQUEST_API_BASE_URL=$api_base_url"

echo "Deploying to Firebase Hosting project $project_id..."
npx --yes firebase-tools@15.27.0 deploy \
  --only hosting \
  --project "$project_id"

echo
echo "Judge URL: $site_url"
echo "The QR code should point to this exact HTTPS address."
