#!/usr/bin/env bash
# Build optimized release artifacts for sawalif_app.
#
# Outputs:
#   build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk  (older devices)
#   build/app/outputs/flutter-apk/app-arm64-v8a-release.apk    (modern devices)
#   build/app/outputs/flutter-apk/app-x86_64-release.apk       (emulators)
#   build/app/outputs/bundle/release/app-release.aab           (Play Store)
set -euo pipefail

echo "=== flutter clean ==="
flutter clean

echo "=== flutter pub get ==="
flutter pub get

echo "=== Building per-ABI APKs (release, minified, R8) ==="
flutter build apk --release --split-per-abi

echo "=== Building App Bundle (recommended for Play Store) ==="
flutter build appbundle --release

echo
echo "=== Done. Artifacts: ==="
ls -lh build/app/outputs/flutter-apk/*.apk
ls -lh build/app/outputs/bundle/release/*.aab
