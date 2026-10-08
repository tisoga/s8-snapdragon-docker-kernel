#!/bin/bash
# Clean the kernel source tree and output directory.
# Usage: ./clean.sh

set -e
trap 'echo; echo FAILED; echo' ERR

# --- SETUP (adjust to your machine) ---
SOURCE_PATH="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$HOME/pie-docker-out"

cd "$SOURCE_PATH"

echo "Cleaning source tree..."
make mrproper 2>/dev/null || true

echo "Removing output directory: $OUTPUT_DIR"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo
echo DONE
echo
