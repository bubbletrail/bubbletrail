#!/bin/bash
set -eou pipefail
# set -x

export APP_STORE_CONNECT_ISSUER_ID="$APP_STORE_CONNECT_API_KEY_ISSUER_ID"
export APP_STORE_CONNECT_KEY_IDENTIFIER="$APP_STORE_CONNECT_API_KEY_KEY_ID"
export APP_STORE_CONNECT_PRIVATE_KEY="$APP_STORE_CONNECT_API_KEY_KEY"

echo "$MAC_APP_DISTRIBUTION_CERT" | base64 -d > mac-app-distribution-cert.p12
openssl pkcs12 -in mac-app-distribution-cert.p12 -legacy -passin pass: -nodes -nocerts | openssl rsa -out mac-app-distribution-cert.key

app-store-connect fetch-signing-files app.bubbletrail.bubbletrail \
    --platform MAC_OS \
    --type MAC_APP_STORE \
    --certificate-key=@file:mac-app-distribution-cert.key \
    --create

# app-store-connect certificates create \
#     --type MAC_INSTALLER_DISTRIBUTION \
#     --certificate-key=@file:mac-app-distribution-cert.key \
#     --save

app-store-connect certificates list \
    --type MAC_INSTALLER_DISTRIBUTION \
    --certificate-key=@file:mac-app-distribution-cert.key \
    --save

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
PACKAGE_NAME=$(basename "$APP_NAME" .app).pkg
xcrun productbuild --component "$APP_NAME" /Applications/ unsigned.pkg

INSTALLER_CERT_NAME=$(keychain list-certificates \
          | jq '[.[]
            | select(.common_name
            | contains("Mac Developer Installer"))
            | .common_name][0]' \
          | xargs)
xcrun productsign --sign "$INSTALLER_CERT_NAME" unsigned.pkg "$PACKAGE_NAME"
rm -f unsigned.pkg

app-store-connect publish \
    --path "$PACKAGE_NAME"

keychain use-login