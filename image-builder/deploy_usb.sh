#!/bin/bash
set -e

# ═══════════════════════════════════════════════════════════════
#  GlowOS — Build, Test & Deploy Script
# ═══════════════════════════════════════════════════════════════

OS_IMAGE="target/uefi.img"
OVMF_CODE="/usr/share/edk2/x64/OVMF_CODE.4m.fd"
OVMF_VARS="/usr/share/edk2/x64/OVMF_VARS.4m.fd"
OVMF_VARS_COPY="target/OVMF_VARS.fd"

# ── 1. Build ────────────────────────────────────────────────────
echo "════════════════════════════════════════════════════════════"
echo "  GlowOS — Building kernel + packaging UEFI image..."
echo "════════════════════════════════════════════════════════════"

cargo build --package kernel
cargo run --package build

if [ ! -f "$OS_IMAGE" ]; then
    echo ""
    echo "Error: Build succeeded but image not found at $OS_IMAGE"
    echo "Check the output path inside build/src/main.rs"
    exit 1
fi

echo ""
echo "✓ Kernel packaged successfully → $OS_IMAGE"

# ── 2. Test in QEMU (optional) ──────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Test in QEMU"
echo "════════════════════════════════════════════════════════════"
read -p "Test in QEMU before deploying to USB? (y/n): " TEST

if [ "$TEST" = "y" ] || [ "$TEST" = "Y" ]; then
    if [ ! -f "$OVMF_CODE" ]; then
        echo "Error: OVMF firmware not found at $OVMF_CODE"
        echo "Install it with: sudo pacman -S edk2-ovmf  (or your distro equivalent)"
        exit 1
    fi

    mkdir -p target
    cp "$OVMF_VARS" "$OVMF_VARS_COPY"

    echo ""
    echo "Launching QEMU... (close the window or press Ctrl+C to exit)"
    echo ""
    qemu-system-x86_64 \
        -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
        -drive if=pflash,format=raw,file="$OVMF_VARS_COPY" \
        -drive format=raw,file="$OS_IMAGE" \
        -m 256M \
        -serial stdio

    echo ""
    read -p "Continue to USB deploy? (y/n): " CONTINUE
    if [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ]; then
        echo "Deploy cancelled."
        exit 0
    fi
fi

# ── 3. Deploy to USB ────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Deploy to USB"
echo "════════════════════════════════════════════════════════════"

# Must be root for raw-device writes
if [ "$EUID" -ne 0 ]; then
    echo "Re-launching with sudo for the deploy step..."
    exec sudo "$0" "$@"
fi

# List drives to help the user pick the right one
echo "Available disk drives on your system:"
echo "════════════════════════════════════════════════════════════"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    lsblk -d -o NAME,SIZE,MODEL,TRAN | grep -i usb || lsblk -d -o NAME,SIZE,MODEL
elif [[ "$OSTYPE" == "darwin"* ]]; then
    diskutil list external physical
else
    echo "Unsupported OS: $OSTYPE"; exit 1
fi
echo "════════════════════════════════════════════════════════════"

# Prompt for target device
echo ""
read -p "Enter the target USB drive identifier (e.g., sdb, sdc, or disk2): " TARGET_INPUT
TARGET_INPUT=$(basename "$TARGET_INPUT")

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    TARGET_DEVICE="/dev/$TARGET_INPUT"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    TARGET_DEVICE="/dev/r$TARGET_INPUT"   # raw disk = faster on macOS
fi

# Verify the device exists
if [ ! -b "$TARGET_DEVICE" ] && [ ! -c "$TARGET_DEVICE" ]; then
    echo "Error: Device $TARGET_DEVICE not found."
    exit 1
fi

# Show device info
echo ""
echo "Target device: $TARGET_DEVICE"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    lsblk "$TARGET_DEVICE" 2>/dev/null || true
fi

# Final confirmation
echo ""
echo "⚠  CRITICAL WARNING ⚠"
echo "You are about to completely overwrite $TARGET_DEVICE."
echo "ALL DATA ON THIS DRIVE WILL BE PERMANENTLY LOST."
echo ""
read -p "Type 'YES' to confirm: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    echo "Deployment cancelled."
    exit 1
fi

# Unmount before writing
echo ""
echo "Unmounting $TARGET_DEVICE..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    umount "${TARGET_DEVICE}"* 2>/dev/null || true
elif [[ "$OSTYPE" == "darwin"* ]]; then
    diskutil unmountDisk "$TARGET_DEVICE"
fi

# Write the image
echo "Writing GlowOS to $TARGET_DEVICE..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    dd if="$OS_IMAGE" of="$TARGET_DEVICE" bs=4M status=progress conv=fdatasync
elif [[ "$OSTYPE" == "darwin"* ]]; then
    dd if="$OS_IMAGE" of="$TARGET_DEVICE" bs=1m
fi

echo "Flushing write buffers..."
sync

echo ""
echo "✓ Deployment complete! Your USB is ready to boot GlowOS."