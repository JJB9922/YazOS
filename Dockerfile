FROM debian:bullseye-slim

WORKDIR /app

# Enable multi-architecture support and add i386 architecture
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
    xorriso \
    grub-common \
    grub-pc \
    mtools \
    build-essential \
    wget \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Zig
RUN wget https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz \
    && tar -xf zig-linux-x86_64-0.13.0.tar.xz \
    && mv zig-linux-x86_64-0.13.0 /usr/local/zig \
    && rm zig-linux-x86_64-0.13.0.tar.xz

ENV PATH="/usr/local/zig:${PATH}"

# Copy OS files into the container
COPY . .

RUN echo '#!/bin/sh\n\
set -e\n\
echo "Building project..."\n\
zig build\n\
echo "Creating isodir structure..."\n\
rm -rf isodir\n\
mkdir -p isodir/boot/grub\n\
cp zig-out/bin/YazOS.elf isodir/boot/\n\
cp grub.cfg isodir/boot/grub/\n\
echo "Directory structure:"\n\
ls -R isodir/\n\
echo "Creating ISO..."\n\
grub-mkrescue -v -o YazOS.iso isodir\n\
echo "ISO created, checking size:"\n\
ls -lh YazOS.iso\n\
mv YazOS.iso /output\n\
' > /build.sh

RUN chmod +x /build.sh

CMD ["/build.sh"]
