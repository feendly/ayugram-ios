#!/bin/bash
# Rewrites the bundle identifier of a built Telegram.ipa and ad-hoc re-signs it
# so it can be installed with TrollStore next to the stock Telegram app.
# Usage: reid.sh <input.ipa> <output.ipa> <new.bundle.id> <display name>
set -euo pipefail
IN="$1"; OUT="$2"; NEW_ID="$3"; NAME="$4"
OLD_ID="ph.telegra.Telegraph"
WORK="$(mktemp -d)"
unzip -q "$IN" -d "$WORK"
APP="$(ls -d "$WORK"/Payload/*.app | head -1)"

# The watch app is not needed and complicates signing.
rm -rf "$APP/Watch" "$APP/_CodeSignature" "$APP/embedded.mobileprovision"

sign_bundle() {
  local B="$1"
  local ENT="$WORK/ent-$(basename "$B").plist"
  local HAVE_ENT=0
  if codesign -d --entitlements "$ENT" --xml "$B" 2>/dev/null && [ -s "$ENT" ]; then
    sed -i '' "s/${OLD_ID//./\.}/$NEW_ID/g" "$ENT"
    HAVE_ENT=1
  fi
  rm -rf "$B/_CodeSignature" "$B/embedded.mobileprovision"
  local CUR
  CUR="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$B/Info.plist")"
  /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${CUR/$OLD_ID/$NEW_ID}" "$B/Info.plist"
  if [ "$HAVE_ENT" = 1 ]; then
    codesign -f -s - --entitlements "$ENT" "$B"
  else
    codesign -f -s - "$B"
  fi
}

# Inside out: frameworks, then extensions, then the app.
if [ -d "$APP/Frameworks" ]; then
  for F in "$APP"/Frameworks/*; do codesign -f -s - "$F"; done
fi
if [ -d "$APP/PlugIns" ]; then
  for X in "$APP"/PlugIns/*.appex; do
    if [ -d "$X/Frameworks" ]; then
      for F in "$X"/Frameworks/*; do codesign -f -s - "$F"; done
    fi
    sign_bundle "$X"
  done
fi
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $NAME" "$APP/Info.plist" || \
  /usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string $NAME" "$APP/Info.plist"
sign_bundle "$APP"

echo "Final entitlements of the app:"
codesign -d --entitlements - --xml "$APP" 2>/dev/null | plutil -p - || true

OUT_ABS="$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT")"
(cd "$WORK" && zip -qry "$OUT_ABS" Payload)
rm -rf "$WORK"
echo "Wrote $OUT_ABS"
