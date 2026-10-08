#!/bin/bash
# Edit kernel config via menuconfig and save back to defconfig.
# Usage: ./edit.sh

set -e
trap 'echo; echo FAILED; echo' ERR

# --- SETUP (adjust to your machine) ---
SOURCE_PATH="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$HOME/pie-docker-out"
DEFCONFIG="dreamqlte_chn_open_defconfig"

export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-

cd "$SOURCE_PATH"
mkdir -p "$OUTPUT_DIR"

echo "Loading defconfig..."
make O="$OUTPUT_DIR" "$DEFCONFIG"

echo "Opening menuconfig (save & exit when done)..."
make O="$OUTPUT_DIR" menuconfig

echo "Saving back to defconfig..."
cp "$OUTPUT_DIR/.config" "arch/arm64/configs/$DEFCONFIG"

echo "Re-applying to verify..."
make O="$OUTPUT_DIR" "$DEFCONFIG"

echo
echo DONE
echo
