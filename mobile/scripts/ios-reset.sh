#!/usr/bin/env bash

# iOS project hard reset for Flutter apps
# - Cleans Flutter artifacts
# - Removes Pods and lockfiles
# - Updates CocoaPods repo and installs pods
# - Regenerates Flutter iOS environment files
# - Opens Runner.xcworkspace

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IOS_DIR="$ROOT_DIR/ios"

cyan()  { printf "\033[1;36m%s\033[0m\n" "$*"; }
green() { printf "\033[1;32m%s\033[0m\n" "$*"; }
warn()  { printf "\033[1;33m%s\033[0m\n" "$*"; }
err()   { printf "\033[1;31m%s\033[0m\n" "$*"; }

need() { command -v "$1" >/dev/null 2>&1 || { err "Missing command: $1"; exit 1; }; }

need flutter
need pod

cyan "[1/9] Flutter clean + pub get"
pushd "$ROOT_DIR" >/dev/null
flutter clean
flutter pub get
popd >/dev/null

cyan "[2/9] Remove Pods, lockfile, ephemeral files"
rm -rf "$IOS_DIR/Pods" "$IOS_DIR/Podfile.lock" "$IOS_DIR/Flutter/ephemeral" || true

cyan "[3/9] Ensure Podfile has a reasonable iOS platform (>= 13.0)"
PODFILE="$IOS_DIR/Podfile"
if [[ -f "$PODFILE" ]]; then
  if ! grep -q "platform :ios" "$PODFILE"; then
    warn "No platform :ios line in Podfile; prepending platform :ios, '13.0'"
    { echo "platform :ios, '13.0'"; cat "$PODFILE"; } >"$PODFILE.new" && mv "$PODFILE.new" "$PODFILE"
  else
    # Normalize to 13.0 minimum
    sed -i '' "s/platform :ios, *'\([0-9]\+\.[0-9]\+\)'/platform :ios, '13.0'/" "$PODFILE" || true
  fi
else
  warn "Podfile not found; Flutter will create one on first iOS build."
fi

cyan "[4/9] CocoaPods repo update (this can take a while)"
pushd "$IOS_DIR" >/dev/null
pod repo update

cyan "[5/9] pod install"
pod install
popd >/dev/null

cyan "[6/9] Regenerate Flutter iOS env files"
pushd "$ROOT_DIR" >/dev/null
# Simulator build is enough to generate ios/Flutter/Generated.xcconfig & flutter_export_environment.sh
flutter build ios --simulator || true
popd >/dev/null

cyan "[7/9] Clear Xcode DerivedData for Runner"
rm -rf "$HOME/Library/Developer/Xcode/DerivedData/Runner-*" || true

cyan "[8/9] Try CLI build with xcodebuild (simulator)"
if [[ -f "$IOS_DIR/Runner.xcworkspace/contents.xcworkspacedata" ]]; then
  set +e
  xcodebuild -workspace "$IOS_DIR/Runner.xcworkspace" \
    -scheme Runner \
    -configuration Debug \
    -destination 'generic/platform=iOS Simulator' \
    clean build
  XCB_RC=$?
  set -e
  if [[ $XCB_RC -ne 0 ]]; then
    warn "xcodebuild returned non-zero (code $XCB_RC). Check the log above; continuing to open Xcode."
  else
    green "xcodebuild completed (Debug simulator)."
  fi
else
  warn "Workspace missing before xcodebuild; skipping CLI build."
fi

cyan "[9/9] Open Xcode workspace"
if [[ -f "$IOS_DIR/Runner.xcworkspace/contents.xcworkspacedata" ]]; then
  open "$IOS_DIR/Runner.xcworkspace"
  green "Opened ios/Runner.xcworkspace. If it didn't open, launch it manually from Xcode."
else
  err "Runner.xcworkspace not found. Check pod install output for errors."
  exit 1
fi

green "Done. Try building in Xcode or via 'flutter run'."
