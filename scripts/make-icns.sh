#!/bin/sh
# make-icns.sh - build a macOS .icns file from an SVG source.
# Usage: make-icns.sh <input.svg> <output.icns>
# Requires: rsvg-convert (brew install librsvg) and iconutil (macOS).

set -eu

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input.svg> <output.icns>" >&2
    exit 2
fi

INPUT=$1
OUTPUT=$2

if [ ! -f "$INPUT" ]; then
    echo "Error: input SVG not found: $INPUT" >&2
    exit 1
fi

if ! command -v rsvg-convert >/dev/null 2>&1; then
    echo "Error: rsvg-convert not found. Install it with: brew install librsvg" >&2
    exit 1
fi

if ! command -v iconutil >/dev/null 2>&1; then
    echo "Error: iconutil not found. This script requires macOS (iconutil ships with Xcode command line tools)." >&2
    exit 1
fi

TMPDIR_ROOT=$(mktemp -d)
ICONSET="$TMPDIR_ROOT/icon.iconset"
mkdir -p "$ICONSET"
trap 'rm -rf "$TMPDIR_ROOT"' EXIT INT TERM

# base sizes; each also gets a @2x variant at double resolution
for SIZE in 16 32 128 256 512; do
    DOUBLE=$((SIZE * 2))
    rsvg-convert -w "$SIZE"   -h "$SIZE"   "$INPUT" -o "$ICONSET/icon_${SIZE}x${SIZE}.png"
    rsvg-convert -w "$DOUBLE" -h "$DOUBLE" "$INPUT" -o "$ICONSET/icon_${SIZE}x${SIZE}@2x.png"
done

iconutil -c icns "$ICONSET" -o "$OUTPUT"
echo "Wrote $OUTPUT"
