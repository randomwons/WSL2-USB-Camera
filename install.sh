#!/bin/bash

# Update and upgrade the system
sudo apt-get -y update
sudo apt-get -y upgrade

# Install required packages
sudo apt-get -y install build-essential flex bison libssl-dev libelf-dev libncurses-dev autoconf libudev-dev libtool dwarves bc wslu hwdata

# Get kernel version checkout the corresponding branch
VERSION=$(uname -r | cut -d '-' -f1)
git clone -b linux-msft-wsl-${VERSION} https://github.com/microsoft/WSL2-Linux-Kernel.git
cd WSL2-Linux-Kernel

# config
sudo cp /proc/config.gz config.gz
sudo gunzip config.gz
sudo mv config .config

sudo scripts/config --enable CONFIG_MEDIA_SUPPORT
sudo scripts/config --enable CONFIG_MEDIA_SUPPORT_FILTER
sudo scripts/config --enable CONFIG_MEDIA_SUBDRV_AUTOSELECT
sudo scripts/config --enable CONFIG_MEDIA_CAMERA_SUPPORT
sudo scripts/config --enable CONFIG_VIDEO_V4L2_SUBDEV_API
sudo scripts/config --enable CONFIG_MEDIA_USB_SUPPORT
sudo scripts/config --enable CONFIG_USB_VIDEO_CLASS
sudo scripts/config --enable CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV
sudo scripts/config --enable CONFIG_USB_GSPCA

sudo make olddefconfig

# Build and install kernel
sudo make -j$(nproc) && sudo make modules_install -j$(nproc) && sudo make install -j$(nproc)

# Install USBIP
cd tools/usb/usbip
sudo ./autogen.sh
sudo ./configure
sudo make install -j$(nproc)

# Copy libusbip.so.0 to /lib
sudo cp libsrc/.libs/libusbip.so.0 /lib/libusbip.so.0

# Copy kerner image to Windows
cd ../../..
HOST_USERNAME=$(wslpath "$(wslvar USERPROFILE)" | cut -d '/' -f5)
sudo cp arch/x86/boot/bzImage /mnt/c/Users/${HOST_USERNAME}/usbip-bzImage

echo "[wsl2]" >> /mnt/c/Users/${HOST_USERNAME}/.wslconfig
echo "kernel=C:\\\\Users\\\\${HOST_USERNAME}\\\\usbip-bzImage" >> /mnt/c/Users/${HOST_USERNAME}/.wslconfig
