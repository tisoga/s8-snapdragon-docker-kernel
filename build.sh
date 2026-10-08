#!/bin/bash
# Build the S8 Docker kernel and create a flashable zip.
# Usage: ./build.sh
#
# Produces: s8-docker-kernel.zip (TWRP-flashable)

set -e
trap 'echo; echo FAILED; echo' ERR

# --- SETUP (adjust to your machine) ---
SOURCE_PATH="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$HOME/pie-docker-out"
DEFCONFIG="dreamqlte_chn_open_defconfig"
N=$(nproc)
ZIP_NAME="s8-docker-kernel.zip"
BASE_BOOT="$SOURCE_PATH/base/base-boot.img"

# --- REQUIRED ENV VARS (do not remove) ---
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export PLATFORM_VERSION=9.0
export ANDROID_VERSION=9
export ANDROID_PLATFORM_VERSION=9

cd "$SOURCE_PATH"
mkdir -p "$OUTPUT_DIR"

# --- BUILD KERNEL ---
echo "=== Loading defconfig: $DEFCONFIG ==="
make O="$OUTPUT_DIR" "$DEFCONFIG"

echo "=== Building kernel (-j$N) ==="
make O="$OUTPUT_DIR" -j"$N" "$@"

IMAGE="$OUTPUT_DIR/arch/arm64/boot/Image.gz-dtb"
if [ ! -f "$IMAGE" ]; then
    echo "Build failed: $IMAGE not found"
    exit 1
fi
echo "Kernel built: $IMAGE"
ls -lh "$IMAGE"

# --- PACKAGE ---
echo ""
echo "=== Packaging ==="

if [ ! -f "$BASE_BOOT" ]; then
    echo "Base boot.img not found at $BASE_BOOT"
    exit 1
fi

echo "Repacking boot.img with Python..."
python3 "$SOURCE_PATH/pack.py" "$BASE_BOOT" "$IMAGE" "$SOURCE_PATH/boot.img"

# Create flashable zip
echo "Creating flashable zip..."
rm -f "$ZIP_NAME"
if [ ! -d "META-INF" ]; then
    echo "META-INF/ not found. boot.img is at $SOURCE_PATH/boot.img"
    exit 1
fi
zip -r "$ZIP_NAME" META-INF boot.img > /dev/null

echo ""
echo "Output: $SOURCE_PATH/$ZIP_NAME"
ls -lh "$ZIP_NAME"
echo ""
echo DONE
echo ""
