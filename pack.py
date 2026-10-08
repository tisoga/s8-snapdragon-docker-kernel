#!/usr/bin/env python3
"""Repack boot.img with new kernel. Updates header kernel_size to fit."""
import hashlib
import struct
import sys

if len(sys.argv) != 4:
    print("Usage: pack.py <base-boot.img> <new-kernel> <output-boot.img>")
    sys.exit(1)

BASE_BOOT, NEW_KERNEL, OUT_BOOT = sys.argv[1], sys.argv[2], sys.argv[3]
PAGE_SIZE = 4096

with open(BASE_BOOT, "rb") as f:
    base = f.read()
assert base[:8] == b"ANDROID!", "Not an Android boot image"

kernel_size = struct.unpack("<I", base[8:12])[0]
ramdisk_size = struct.unpack("<I", base[16:20])[0]
print("base kernel=%d ramdisk=%d" % (kernel_size, ramdisk_size))

kernel_offset = PAGE_SIZE
ramdisk_offset = PAGE_SIZE + ((kernel_size + PAGE_SIZE - 1) // PAGE_SIZE) * PAGE_SIZE

with open(NEW_KERNEL, "rb") as f:
    new_kernel = f.read()
print("new kernel=%d" % len(new_kernel))

ramdisk = base[ramdisk_offset:ramdisk_offset + ramdisk_size]
print("ramdisk=%d" % len(ramdisk))

header = bytearray(base[:PAGE_SIZE])
struct.pack_into("<I", header, 8, len(new_kernel))

sha = hashlib.sha1()
sha.update(new_kernel)
sha.update(ramdisk)
header[580:612] = sha.digest() + b"\x00" * 12

out = bytearray()
out += header
out += new_kernel
out += b"\x00" * ((PAGE_SIZE - (len(new_kernel) % PAGE_SIZE)) % PAGE_SIZE)
out += ramdisk
out += b"\x00" * ((PAGE_SIZE - (len(ramdisk) % PAGE_SIZE)) % PAGE_SIZE)
TARGET = 64 * 1024 * 1024
if len(out) < TARGET:
    out += b"\x00" * (TARGET - len(out))

with open(OUT_BOOT, "wb") as f:
    f.write(out)
print("Wrote %s: %d bytes" % (OUT_BOOT, len(out)))
