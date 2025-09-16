#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/android/app"
KEY_PROPS="$ROOT_DIR/android/key.properties"
LOCAL_PROPS="$ROOT_DIR/android/local.properties"

log() { echo -e "\033[1;34m[build-aab]\033[0m $*"; }
warn() { echo -e "\033[1;33m[build-aab]\033[0m $*"; }
err() { echo -e "\033[1;31m[build-aab]\033[0m $*"; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { err "Missing required command: $1"; exit 1; }
}

# 1) Basic tool checks
require_cmd flutter
require_cmd keytool

# 2) Key properties validation
if [[ ! -f "$KEY_PROPS" ]]; then
  err "Signing file not found: $KEY_PROPS"
  echo "Create it from: $ROOT_DIR/android/key.properties.example"
  exit 1
fi

# macOS ships an older bash (3.2) without associative arrays.
# Parse key.properties using sed/grep for portability.
get_prop() {
  local key="$1"
  sed -n "s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*//p" "$KEY_PROPS" | tail -n1
}

STORE_FILE="$(get_prop storeFile)"
STORE_PASS="$(get_prop storePassword)"
KEY_ALIAS="$(get_prop keyAlias)"
KEY_PASS="$(get_prop keyPassword)"

for k in storeFile storePassword keyAlias keyPassword; do
  val="$(get_prop "$k")"
  if [[ -z "$val" ]]; then
    err "Missing '$k' in $KEY_PROPS"
    exit 1
  fi
done

# Resolve keystore path relative to app module when not absolute
if [[ "$STORE_FILE" != /* ]]; then
  STORE_FILE="$APP_DIR/$STORE_FILE"
fi

if [[ ! -f "$STORE_FILE" ]]; then
  err "Keystore not found at: $STORE_FILE"
  exit 1
fi

log "Validating keystore alias and passwords..."
set +e
KEYTOOL_OUT=$(keytool -list -v -keystore "$STORE_FILE" -alias "$KEY_ALIAS" -storepass "$STORE_PASS" -keypass "$KEY_PASS" 2>&1)
KT_RC=$?
set -e
if [[ $KT_RC -ne 0 ]]; then
  err "Keystore validation failed. keytool output:\n$KEYTOOL_OUT"
  echo "Hints:"
  echo "- 'Given final block not properly padded' usually means a wrong password."
  echo "- Ensure keyAlias matches the alias you used when generating the keystore."
  exit 1
fi

log "Keystore looks valid (alias: $KEY_ALIAS)."

# 3) Versioning checks
if [[ ! -f "$LOCAL_PROPS" ]]; then
  err "Missing $LOCAL_PROPS. Flutter usually writes it; ensure it exists with flutter.versionCode and flutter.versionName."
  exit 1
fi

VC=$(grep -E '^flutter.versionCode=' "$LOCAL_PROPS" | cut -d= -f2- || true)
VN=$(grep -E '^flutter.versionName=' "$LOCAL_PROPS" | cut -d= -f2- || true)
if [[ -z "${VC:-}" || -z "${VN:-}" ]]; then
  err "flutter.versionCode and/or flutter.versionName missing in $LOCAL_PROPS"
  echo "Add lines like:\n  flutter.versionCode=2\n  flutter.versionName=1.0.1"
  exit 1
fi
if ! [[ "$VC" =~ ^[0-9]+$ ]]; then
  err "flutter.versionCode must be an integer; got: '$VC'"
  exit 1
fi
log "Version: code=$VC, name=$VN"

# 4) Flutter env
log "Flutter doctor (brief)..."
flutter --version || true

# 5) Clean + get deps
log "Cleaning project..."
(cd "$ROOT_DIR" && flutter clean)
log "Fetching dependencies..."
(cd "$ROOT_DIR" && flutter pub get)

# 6) Build AAB
log "Building Android App Bundle (release)..."
(cd "$ROOT_DIR" && flutter build appbundle --release --verbose)

OUT_DIR="$ROOT_DIR/build/app/outputs/bundle/release"
AAB="$OUT_DIR/app-release.aab"
if [[ -f "$AAB" ]]; then
  log "Success: $AAB"
  log "Upload this bundle to Google Play Console."
else
  err "Build finished but bundle not found at $AAB"
  exit 1
fi
