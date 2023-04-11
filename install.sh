#!/bin/bash

# Update and upgrade the system
sudo apt-get update
sudo apt-get -y upgrade

# Install required packages
sudo apt-get -y install \ 
  build-essential \
  flex \ 
  bison \
  libssl-dev \
  libelf-dev \
  libncurses-dev \
  autoconf \
  libudev-dev \
  libtool \
  dwarves \
  bc \
  wslu \
  hwdata

# Get kernel version checkout the corresponding branch
VERSION=$(uname -r | cut -d '-' -f1)
git clone https://github.com/microsoft/WSL2-Linux-Kernel.git
cd WSL2-Linux-Kernel
git checkout linux-msft-wsl-${VERSION}

# config
sudo mv ../config .config


# Build and install kernel
sudo make -j$(nproc) \
  && sudo make modules_install -j$(nproc) \
  && sudo make install -j$(nproc)

# Install USBIP
cd tools/usb/usbip
sudo ./autogen.sh
sudo ./configure
sudo make install -j$(nproc)

# Copy libusbip.so.0 to /lib
sudo cp libsrc/.libs/libusbip.so.0 /lib/libusbip.so.0

# Copy kerner image to Windows
HOST_USERNAME=$(wslpath "$(wslvar USERPROFILE)" | cut -d '/' -f5)
sudo cp arch/x86/boot/bzImage /mnt/c/Users/${HOST_USERNAME}/usbip-bzImage

echo "[wsl2]" >> /mnt/c/Users/${HOST_USERNAME}/.wslconfig
echo "kernel=C:\\Users\\${HOST_USERNAME}\\usbip-bzImage" >> /mnt/c/Users/${HOST_USERNAME}/.wslconfig
