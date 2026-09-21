#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT="$ROOT/ios"
NAME="PoscatNfc"
FW="$OUT/$NAME.framework"
TMP="$ROOT/.build"
INC="$ROOT/ci-stubs/inc"

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This script must run on macOS. Use GitHub Actions on macos-latest." >&2
  exit 1
fi

rm -rf "$TMP" "$FW"
mkdir -p "$TMP" "$FW/Headers"

xcrun -sdk iphoneos clang \
  -dynamiclib -fobjc-arc -fmodules \
  -undefined dynamic_lookup \
  -framework Foundation -framework CoreNFC \
  -I"$INC" -miphoneos-version-min=11.0 \
  "$ROOT/src/PoscatNfc.m" -o "$FW/$NAME"

cp "$ROOT/src/PoscatNfc.h" "$FW/Headers/"
cat > "$FW/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key><string>PoscatNfc</string>
  <key>CFBundleIdentifier</key><string>com.poscat.PoscatNfc</string>
  <key>CFBundleName</key><string>PoscatNfc</string>
  <key>CFBundlePackageType</key><string>FMWK</string>
  <key>CFBundleShortVersionString</key><string>1.0.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>MinimumOSVersion</key><string>11.0</string>
</dict>
</plist>
PLIST

codesign -s - -f "$FW" >/dev/null 2>&1 || true
rm -rf "$TMP"
echo "Built $FW"
