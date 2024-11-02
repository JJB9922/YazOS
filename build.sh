#!/bin/bash
# Build the Docker image
docker build --platform linux/amd64 -t yazos-builder .
# Run the container, mounting the current directory to copy out the ISO
docker run --rm --platform linux/amd64 -v "$(pwd)":/output yazos-builder
# Check if the ISO was successfully created
if [ -f YazOS.iso ]; then
    echo "ISO created successfully: YazOS.iso"
else
    echo "ISO creation failed."
    exit 1
fi
echo "Running OS in QEMU..."
qemu-system-i386 -cdrom YazOS.iso
