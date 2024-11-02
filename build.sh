#!/bin/bash

# Build the Docker image
docker build -t yazos-builder .

# Run the container and mount the current directory
docker run -v $(pwd):/os yazos-builder

# If you want to run the OS after building, uncomment these lines:
# echo "Running OS in QEMU..."
qemu-system-x86_64 -cdrom YazOS.iso

