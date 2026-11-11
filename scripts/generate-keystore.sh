#!/usr/bin/env bash
# Generates a NEW release keystore and prints its base64 for the KEYSTORE_BASE64 secret.
# Never commit the .jks file. Back it up somewhere safe: losing it means you can't update your Play Store app.
set -euo pipefail
OUT="${1:-release.jks}"
keytool -genkeypair -v -keystore "$OUT" -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000
echo
echo "Base64 (paste into the KEYSTORE_BASE64 secret):"
base64 -w0 "$OUT" 2>/dev/null || base64 "$OUT"
echo
