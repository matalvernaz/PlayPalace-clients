#!/usr/bin/env bash
set -euo pipefail

# Deploy PlayPalace iOS to TestFlight
# Usage: ./scripts/deploy-testflight.sh
#
# Requires:
#   - Xcode with signing configured
#   - App-specific password stored in keychain as "PLAYPALACE_TESTFLIGHT"

APPLE_ID="matthew@cobd.ca"
KEYCHAIN_ITEM="PLAYPALACE_TESTFLIGHT"
PROJECT_DIR="$(cd "$(dirname "$0")/../clients/macos/PlayPalace" && pwd)"
PROJECT="$PROJECT_DIR/PlayPalace.xcodeproj"
SCHEME="PlayPalace"
EXPORT_OPTIONS="$PROJECT_DIR/ExportOptions.plist"
BUILD_DIR="$PROJECT_DIR/.build/archive"
ARCHIVE_PATH="$BUILD_DIR/PlayPalace.xcarchive"
EXPORT_PATH="$BUILD_DIR/export"

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
    -quiet

echo "Export complete."

# Add build to external beta group via App Store Connect API
echo "Adding build to beta group..."
NOTES="${1:-New build available.}"
python3 "$SCRIPT_DIR/testflight-add-to-group.py" "$BUILD_NUMBER" --notes "$NOTES"

echo "=== Deploy complete! Build $BUILD_NUMBER ==="
