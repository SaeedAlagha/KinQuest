#!/usr/bin/env bash

set -euo pipefail

source_icon="assets/mascot/sila_app_icon.png"

if [[ ! -f "$source_icon" ]]; then
  echo "Missing mascot icon source: $source_icon" >&2
  exit 1
fi

resize_icon() {
  local size="$1"
  local destination="$2"
  sips -z "$size" "$size" "$source_icon" --out "$destination" >/dev/null
}

# Web and installable PWA icons.
resize_icon 32 web/favicon.png
resize_icon 180 web/icons/Icon-180.png
resize_icon 192 web/icons/Icon-192.png
resize_icon 512 web/icons/Icon-512.png
resize_icon 192 web/icons/Icon-maskable-192.png
resize_icon 512 web/icons/Icon-maskable-512.png

# Android legacy launcher icons. The square artwork keeps the face and Shared
# Roots mark inside the safe area for launchers that apply their own mask.
resize_icon 48 android/app/src/main/res/mipmap-mdpi/ic_launcher.png
resize_icon 72 android/app/src/main/res/mipmap-hdpi/ic_launcher.png
resize_icon 96 android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
resize_icon 144 android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
resize_icon 192 android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

# iPhone, iPad, and App Store icon catalogue.
resize_icon 20 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png
resize_icon 40 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png
resize_icon 60 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png
resize_icon 29 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png
resize_icon 58 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png
resize_icon 87 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png
resize_icon 40 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png
resize_icon 80 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png
resize_icon 120 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png
resize_icon 120 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png
resize_icon 180 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png
resize_icon 76 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png
resize_icon 152 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png
resize_icon 167 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png
resize_icon 1024 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png

echo "Generated Sila launcher icons for web, Android, and iOS."
