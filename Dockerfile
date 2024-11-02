FROM debian:bullseye-slim

# Install required packages
RUN apt-get update && apt-get install -y \
    xorriso \
    grub-pc-bin \
    grub-common \
    mtools \
    build-essential \
    wget \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install latest Zig
RUN wget https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz \
    && tar -xf zig-linux-x86_64-0.13.0.tar.xz \
    && mv zig-linux-x86_64-0.13.0 /usr/local/zig \
    && rm zig-linux-x86_64-0.13.0.tar.xz

ENV PATH="/usr/local/zig:${PATH}"

WORKDIR /os

# Copy your OS files into the container
COPY . .

# Build script that will run when container starts
RUN echo '#!/bin/sh\n\
zig build\n\
mkdir -p isofiles/boot/grub\n\
cp zig-out/bin/YazOS isofiles/boot/YazOS.bin\n\
echo "set timeout=0\n\
set default=0\n\
\n\
menuentry \\"YazOS\\" {\n\
    multiboot2 /boot/YazOS.bin\n\
    boot\n\
}" > isofiles/boot/grub/grub.cfg\n\
grub-mkrescue -o YazOS.iso isofiles\n\
' > /os/build.sh

RUN chmod +x /os/build.sh

CMD ["/os/build.sh"]
