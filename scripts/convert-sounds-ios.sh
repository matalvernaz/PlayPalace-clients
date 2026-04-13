#!/usr/bin/env bash
set -euo pipefail

# Convert OGG sounds to CAF (Apple Core Audio Format with AAC) for iOS.
# Source: clients/desktop/sounds/  (OGG files, the source of truth)
# Output: clients/macos/PlayPalace/Sources/sounds/  (CAF files for iOS bundle)
#
# Uses a two-step pipeline: ffmpeg (OGG->WAV) then afconvert (WAV->AAC CAF).
# afconvert ships with macOS; ffmpeg must be installed (brew install ffmpeg).
#
# Usage: ./scripts/convert-sounds-ios.sh [--force]
#   --force: re-convert all files even if CAF already exists

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="$ROOT_DIR/clients/desktop/sounds"
DST_DIR="$ROOT_DIR/clients/macos/PlayPalace/Sources/sounds"
FORCE=false
TMP_DIR="$(mktemp -d)"

trap 'rm -rf "$TMP_DIR"' EXIT

if [[ "${1:-}" == "--force" ]]; then
    FORCE=true
fi

if ! command -v ffmpeg &>/dev/null; then
    echo "Error: ffmpeg is required but not found."
    echo "Install with: brew install ffmpeg"
    exit 1
fi

if ! command -v afconvert &>/dev/null; then
    echo "Error: afconvert is required but not found (ships with macOS)."
    exit 1
fi

if [[ ! -d "$SRC_DIR" ]]; then
    echo "Error: Source sounds directory not found: $SRC_DIR"
    exit 1
fi

mkdir -p "$DST_DIR"

converted=0
skipped=0
failed=0

while IFS= read -r -d '' ogg_file; do
    # Get relative path from source dir
    rel_path="${ogg_file#"$SRC_DIR/"}"
    # Change extension to .caf
    caf_rel="${rel_path%.ogg}.caf"
    caf_file="$DST_DIR/$caf_rel"

    # Skip if CAF exists and is newer than OGG (unless --force)
    if [[ "$FORCE" == false && -f "$caf_file" && "$caf_file" -nt "$ogg_file" ]]; then
        skipped=$((skipped + 1))
        continue
    fi

    # Create output directory
    mkdir -p "$(dirname "$caf_file")"

    # Two-step: OGG -> WAV (ffmpeg, resample to 44100 for AAC compat) -> AAC CAF (afconvert)
    tmp_wav="$TMP_DIR/convert.wav"
    if ffmpeg -y -i "$ogg_file" -ar 44100 -c:a pcm_s16le "$tmp_wav" -loglevel error 2>/dev/null \
       && afconvert "$tmp_wav" "$caf_file" -d aac -f caff -b 128000 2>/dev/null; then
        converted=$((converted + 1))
    else
        echo "Failed: $rel_path"
        failed=$((failed + 1))
    fi
    rm -f "$tmp_wav"
done < <(find "$SRC_DIR" -name "*.ogg" -print0)

# Also copy any non-OGG files (wav, mp3) as-is
while IFS= read -r -d '' other_file; do
    rel_path="${other_file#"$SRC_DIR/"}"
    dst_file="$DST_DIR/$rel_path"
    if [[ "$FORCE" == false && -f "$dst_file" && "$dst_file" -nt "$other_file" ]]; then
        continue
    fi
    mkdir -p "$(dirname "$dst_file")"
    cp "$other_file" "$dst_file"
done < <(find "$SRC_DIR" \( -name "*.wav" -o -name "*.mp3" -o -name "*.caf" -o -name "*.m4a" \) -print0)

echo "Sound conversion complete: $converted converted, $skipped up-to-date, $failed failed."
if [[ $failed -gt 0 ]]; then
    exit 1
fi
