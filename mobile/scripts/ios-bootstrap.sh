#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IOS_DIR="$ROOT_DIR/ios"
RES_DIR="$ROOT_DIR/../resources"

log() { echo -e "\033[1;34m[ios]\033[0m $*"; }
err() { echo -e "\033[1;31m[ios]\033[0m $*"; }

need() { command -v "$1" >/dev/null 2>&1 || { err "Missing command: $1"; exit 1; }; }

need flutter
need pod

log "Ensuring iOS platform files exist (flutter create --platforms=ios .)"
pushd "$ROOT_DIR" >/dev/null
flutter create --platforms=ios .
popd >/dev/null

# Bump minimum iOS target if needed
PODFILE="$IOS_DIR/Podfile"
if [[ -f "$PODFILE" ]]; then
  if ! grep -q "platform :ios" "$PODFILE"; then
    log "Setting platform :ios, '13.0' in Podfile"
    echo "platform :ios, '13.0'" | cat - "$PODFILE" >"$PODFILE.new" && mv "$PODFILE.new" "$PODFILE"
  else
    log "Ensuring iOS target >= 13.0"
    sed -i '' "s/platform :ios, *'\([0-9]\+\.[0-9]\+\)'/platform :ios, '13.0'/" "$PODFILE" || true
  fi
fi

log "Installing CocoaPods"
pushd "$IOS_DIR" >/dev/null
pod install
popd >/dev/null

## Sync App Icons from resources/ios to the Xcode asset catalog
IOS_ICON_SRC="$RES_DIR/ios"
APPICONSET_DIR="$IOS_DIR/Runner/Assets.xcassets/AppIcon.appiconset"
if [[ -d "$IOS_ICON_SRC" ]]; then
  log "Updating iOS AppIcon.appiconset from resources/ios"
  mkdir -p "$APPICONSET_DIR"
  # Clean existing PNGs to avoid stale icons
  find "$APPICONSET_DIR" -maxdepth 1 -type f -name '*.png' -delete || true
  # Copy PNGs and Contents.json
  cp -f "$IOS_ICON_SRC"/*.png "$APPICONSET_DIR"/ 2>/dev/null || true
  if [[ -f "$IOS_ICON_SRC/Contents.json" ]]; then
    cp -f "$IOS_ICON_SRC/Contents.json" "$APPICONSET_DIR/Contents.json"
  fi
  log "Icons synced to: $APPICONSET_DIR"
else
  warn "Icon source not found at $IOS_ICON_SRC; skipping iOS icon sync"
fi

log "Opening Xcode workspace (Runner.xcworkspace)"
if [[ -f "$IOS_DIR/Runner.xcworkspace/contents.xcworkspacedata" ]]; then
  open "$IOS_DIR/Runner.xcworkspace"
  log "If it doesn't open, open from Xcode: File > Open > ios/Runner.xcworkspace"
else
  err "Runner.xcworkspace not found. Check pod install output for errors."
  exit 1
fi
