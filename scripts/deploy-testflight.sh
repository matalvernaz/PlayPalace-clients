#!/usr/bin/env bash
set -euo pipefail

# Deploy PlayPalace iOS to TestFlight
# Usage: ./scripts/deploy-testflight.sh
#
# Requires:
#   - Xcode with signing configured
#   - App Store Connect API key at $ASC_KEY_PATH (default: AuthKey_8LD279H5H9.p8)

PROJECT_DIR="$(cd "$(dirname "$0")/../clients/macos/PlayPalace" && pwd)"
PROJECT="$PROJECT_DIR/PlayPalace.xcodeproj"
SCHEME="PlayPalace"
EXPORT_OPTIONS="$PROJECT_DIR/ExportOptions.plist"
BUILD_DIR="$PROJECT_DIR/.build/archive"
ARCHIVE_PATH="$BUILD_DIR/PlayPalace.xcarchive"
EXPORT_PATH="$BUILD_DIR/export"

# App Store Connect API key — used by xcodebuild -exportArchive in upload mode
# so the upload doesn't need an Xcode-stored AppleID session (unreachable over SSH).
ASC_KEY_ID="${ASC_KEY_ID:-8LD279H5H9}"
ASC_ISSUER_ID="${ASC_ISSUER_ID:-4e69fbec-a077-43c2-aea0-55045fe3dddc}"
ASC_KEY_PATH="${ASC_KEY_PATH:-$HOME/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8}"

echo "=== PlayPalace TestFlight Deploy ==="

# Convert sounds from OGG to CAF for iOS
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Converting sounds for iOS..."
"$SCRIPT_DIR/convert-sounds-ios.sh"

# Increment build number (timestamp-based so it always increases)
BUILD_NUMBER=$(date +%Y%m%d%H%M%S)
echo "Build number: $BUILD_NUMBER"

# Clean previous archive
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Archive
echo "Archiving..."
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination "generic/platform=iOS" \
    -archivePath "$ARCHIVE_PATH" \
    CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
    -allowProvisioningUpdates \
    -quiet

echo "Archive complete."

# Export
echo "Exporting..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS" \
    -exportPath "$EXPORT_PATH" \
    -allowProvisioningUpdates \
    -authenticationKeyPath "$ASC_KEY_PATH" \
    -authenticationKeyID "$ASC_KEY_ID" \
    -authenticationKeyIssuerID "$ASC_ISSUER_ID" \
    -quiet

echo "Export complete."

# Add build to external beta group via App Store Connect API
echo "Adding build to beta group..."
NOTES="${1:-New build available.}"
python3 "$SCRIPT_DIR/testflight-add-to-group.py" "$BUILD_NUMBER" --notes "$NOTES"

echo "=== Deploy complete! Build $BUILD_NUMBER ==="
