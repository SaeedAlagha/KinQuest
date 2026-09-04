#!/usr/bin/env bash
set -euo pipefail

project_file="ios/Runner.xcodeproj/project.pbxproj"
api_base_url="${KINQUEST_API_BASE_URL:-}"

if [[ ! "$api_base_url" =~ ^https://[^[:space:]]+$ ]]; then
  echo "Set KINQUEST_API_BASE_URL to the deployed HTTPS Sila API URL." >&2
  exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "Install full Xcode, open it once, and select it with xcode-select." >&2
  exit 1
fi

developer_dir="$(xcode-select -p 2>/dev/null || true)"
if [[ "$developer_dir" != *"Xcode.app/Contents/Developer"* ]]; then
  echo "Full Xcode is not selected. Run: sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer" >&2
  exit 1
fi

if grep -q "PRODUCT_BUNDLE_IDENTIFIER = com.example.kinquest;" "$project_file"; then
  echo "Replace the placeholder iOS bundle ID, register it in Apple Developer, and regenerate the matching Firebase iOS configuration." >&2
  exit 1
fi

if ! security find-identity -v -p codesigning | grep -q '"Apple Distribution:'; then
  echo "No Apple Distribution signing identity is installed." >&2
  exit 1
fi

flutter build ipa --release \
  --dart-define="KINQUEST_API_BASE_URL=$api_base_url" \
  "$@"
