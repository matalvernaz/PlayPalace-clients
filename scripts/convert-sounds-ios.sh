#!/usr/bin/env bash
set -euo pipefail

# Convert OGG sounds to CAF (Apple Core Audio Format with AAC) for iOS.
# Source: clients/desktop/sounds/  (OGG files, the source of truth)
# Output: clients/macos/PlayPalace/Sources/sounds/  (CAF files for iOS bundle)
#
# Uses a two-step pipeline: ffmpeg (OGG->WAV) then afconvert (WAV->AAC CAF).
# afconvert ships with macOS; ffmpeg must be installed (brew install ffmpeg).
#
# Resilience (added after a single transient failure silently aborted an
# entire TestFlight release): each conversion is retried, the converter's
# stderr is captured and shown on failure instead of being discarded, and a
# handful of failed/orphan assets warn loudly but DO NOT fail the build --
# only a total wipeout (zero successes => broken toolchain) aborts.
#
# Usage: ./scripts/convert-sounds-ios.sh [--force]
#   --force: re-convert all files even if CAF already exists

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="$ROOT_DIR/clients/desktop/sounds"
DST_DIR="$ROOT_DIR/clients/macos/PlayPalace/Sources/sounds"
FORCE=false
MAX_ATTEMPTS=2          # one retry, to ride out a transient runner hiccup
TMP_DIR="$(mktemp -d)"

trap 'rm -rf "$TMP_DIR"' EXIT

if [[ "${1:-}" == "--force" ]]; then
    FORCE=true
fi

if ! command -v afconvert &>/dev/null; then
    echo "Error: afconvert is required but not found (ships with macOS)." >&2
    exit 1
fi

if [[ ! -d "$SRC_DIR" ]]; then
    echo "Error: Source sounds directory not found: $SRC_DIR" >&2
    exit 1
fi

# Enumerate every OGG source once, reading find's output to completion. The
# previous version broke out of a scan loop early while find was still
# writing into the process-substitution pipe, which left find writing to a
# dead reader and surfaced as the spurious "find: stdout: Undefined error: 0"
# line in CI logs. Collecting the full list first avoids that entirely.
ogg_files=()
while IFS= read -r -d '' f; do
    ogg_files+=("$f")
done < <(find "$SRC_DIR" -name "*.ogg" -print0)

# ffmpeg is only needed when some OGG isn't already converted (or --force), so
# a fully-up-to-date tree still builds on a machine without ffmpeg installed.
needs_ffmpeg=0
for ogg_file in "${ogg_files[@]}"; do
    rel_path="${ogg_file#"$SRC_DIR/"}"
    caf_file="$DST_DIR/${rel_path%.ogg}.caf"
    if [[ "$FORCE" == true || ! -f "$caf_file" || "$caf_file" -ot "$ogg_file" ]]; then
        needs_ffmpeg=1
        break
    fi
done

if [[ "$needs_ffmpeg" == 1 ]] && ! command -v ffmpeg &>/dev/null; then
    echo "Error: ffmpeg is required to convert OGG sources but was not found." >&2
    echo "Install with: brew install ffmpeg" >&2
    exit 1
fi

mkdir -p "$DST_DIR"

converted=0
skipped=0
failed=0
failed_files=()

# Convert one OGG to CAF, retrying up to MAX_ATTEMPTS. Captures converter
# stderr so a genuine failure is diagnosable rather than swallowed. Returns 0
# on success, 1 once attempts are exhausted (the last error is printed).
convert_one() {
    local ogg_file="$1" caf_file="$2" rel_path="$3"
    local attempt err
    local tmp_wav="$TMP_DIR/convert.wav"
    for ((attempt = 1; attempt <= MAX_ATTEMPTS; attempt++)); do
        rm -f "$tmp_wav"
        # OGG -> WAV (resample to 44100 for AAC compat) -> AAC CAF.
        if err="$(ffmpeg -y -i "$ogg_file" -ar 44100 -c:a pcm_s16le "$tmp_wav" -loglevel error 2>&1 \
                  && afconvert "$tmp_wav" "$caf_file" -d aac -f caff -b 128000 2>&1)"; then
            rm -f "$tmp_wav"
            return 0
        fi
        rm -f "$caf_file"   # drop any partial output before retry/give-up
        if (( attempt < MAX_ATTEMPTS )); then
            echo "Retry $rel_path (attempt $attempt failed): ${err:-<no stderr>}" >&2
            sleep 1
        else
            echo "Failed after $MAX_ATTEMPTS attempts: $rel_path" >&2
            echo "  last converter error: ${err:-<no stderr>}" >&2
        fi
    done
    return 1
}

for ogg_file in "${ogg_files[@]}"; do
    rel_path="${ogg_file#"$SRC_DIR/"}"
    caf_rel="${rel_path%.ogg}.caf"
    caf_file="$DST_DIR/$caf_rel"

    # Skip if CAF exists and is newer than OGG (unless --force)
    if [[ "$FORCE" == false && -f "$caf_file" && "$caf_file" -nt "$ogg_file" ]]; then
        skipped=$((skipped + 1))
        continue
    fi

    mkdir -p "$(dirname "$caf_file")"

    if convert_one "$ogg_file" "$caf_file" "$rel_path"; then
        converted=$((converted + 1))
    else
        failed=$((failed + 1))
        failed_files+=("$rel_path")
    fi
done

# Also copy any non-OGG files (wav, mp3, caf, m4a) as-is
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

if (( failed > 0 )); then
    # Surface failures loudly (visible in the CI run summary) but don't block
    # the release on a few un-convertible/orphan assets -- a single transient
    # afconvert/find hiccup used to abort the whole build silently.
    printf '::warning::Sound conversion skipped %d file(s): %s\n' "$failed" "${failed_files[*]}"
    if (( converted == 0 )); then
        echo "::error::Every sound conversion failed -- ffmpeg/afconvert toolchain likely broken. Aborting." >&2
        exit 1
    fi
fi

exit 0
