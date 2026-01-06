#!/bin/bash
set -eou pipefail
# set -x

export APP_STORE_CONNECT_ISSUER_ID="$APP_STORE_CONNECT_API_KEY_ISSUER_ID"
export APP_STORE_CONNECT_KEY_IDENTIFIER="$APP_STORE_CONNECT_API_KEY_KEY_ID"
export APP_STORE_CONNECT_PRIVATE_KEY="$APP_STORE_CONNECT_API_KEY_KEY"
tmp=$(mktemp -d)

echo "$DEVELOPER_ID_APPLICATION_CERT" | base64 -d > "$tmp/developer-id-application-cert.p12"
openssl pkcs12 -in "$tmp/developer-id-application-cert.p12" -legacy -passin pass: -nodes -nocerts | openssl rsa -out "$tmp/developer-id-application-cert.key"

app-store-connect fetch-signing-files app.bubbletrail.bubbletrail \
    --platform MAC_OS \
    --type MAC_APP_DIRECT \
    --certificate-key=@file:"$tmp/developer-id-application-cert.key" \
    --create

keychain initialize
keychain add-certificates
xcode-project use-profiles

flutter pub get
flutter build macos \
    --release --no-pub \
    --build-number="${BUILD_NUMBER:-9000}" \
    --build-name="${MARKET_VERSION:=0.0.1}" \
    --dart-define=AZURE_MAPS_SUBSCRIPTION_KEY="${AZURE_MAPS_SUBSCRIPTION_KEY:-}" \
    --dart-define=BUILD="${BUILD_NUMBER:-9000}" \
    --dart-define=BUILDSECONDS="${SOURCE_DATE_EPOCH:-1234567890}" \
    --dart-define=GITSHA="${GIT_SHA:-g000000}" \
    --dart-define=MARKETINGVERSION="${MARKET_VERSION:-0.0.1}"

APP_NAME=$(find build/macos -name "*.app")
ZIP_NAME=$(basename "$APP_NAME" .app).zip

mv "$APP_NAME" .
zip -r --symlinks "$ZIP_NAME" $(basename "$APP_NAME")

# Notarize it

echo "$APP_STORE_CONNECT_API_KEY_KEY" > "$tmp/api.key"
xcrun notarytool submit -k "$tmp/api.key" -d "$APP_STORE_CONNECT_API_KEY_KEY_ID" -i "$APP_STORE_CONNECT_API_KEY_ISSUER_ID" "$ZIP_NAME"

keychain use-login
rm -rf "$tmp"
