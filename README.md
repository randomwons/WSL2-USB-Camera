# WSL2-USB-Camera
All content has been referenced from [Microsoft Connect USB](https://learn.microsoft.com/ko-kr/windows/wsl/connect-usb).

모든 내용은 [Microsoft Connect USB](https://learn.microsoft.com/ko-kr/windows/wsl/connect-usb)를 참조하였습니다.


## Prerequisites
- Running windows 11 (Build 22000 or later), (Windows 10 support is possible, [Note this](https://learn.microsoft.com/en-gb/windows/wsl/connect-usb).)
- Windows 11 실행(빌드 22000 이상) (Windows 10 지원 가능, [참조](https://learn.microsoft.com/ko-kr/windows/wsl/connect-usb).)
- A machine with an x64/x84 processor is required. (Arm64 is currently not supported with usbipd-win).
- x64/x84 프로세서가 있는 컴퓨터가 필요합니다. (Arm64는 현재 usbipd-win에 지원되지 않습니다.)
- Linux distribution installed and set to WSL2
- Linux 배포판이 설치되고 WSL 2로 설정됩니다.
- Running Linx kernerl 5.10.60.1 or later.
- Linux 커널 5.10.60.1 이상을 실행합니다.

## Install WSL2
Before installing WSL2, check if CPU virtualization is enabled and if Hyper-V is supported.

WSL2를 설치하기 전에 CPU의 가상화가 켜져있는지, Hyper-V를 지원하는지 확인.

<img src="images/hyperv.png" width="70%" height="70%"/>

Powershell 관리자 권한으로 입력
```bash
wsl --install
```

## Install USBIPD-WIN
In Window Powershell
```bash
winget install --interactive --exact dorssel.usbipd-win
```

In WSL2 terminal
```bash
sudo apt-get update
sudo apt-get -y install linux-tools-generic hwdata
sudo update-alternatives --install /usr/local/bin/usbip usbip /usr/lib/linux-tools/*-generic/usbip 20
```

In Window Powershell, Check device list
```bash
usbipd list
```
![](images/usbipd_list.png)

In Window Powershell, Binding device
```bash
usbipd bind -b <BUSID> # (e.g. usbipd bind -b 5-3)
```
![](images/usbipd_bind.png)

In Window Powershell, Attach device
```bash
usbipd attach --wsl -b <BUSID> # (e.g. usbipd attach --wsl -b 5-3)
```
![](images/usbipd_attach.png)

In WSL2 terminal, Check device
```bash
lsusb
```
![](images/wsl2_lsusb.png)

## Update WSL2 Kernel
To use the camera in WSL2, you need to update the Linux kernel

You need to have the packages required for kernel update installed. If they are already installed, you can proceed.

In WSL2 terminal
```bash
sudo apt-get update
sudo apt-get -y upgrade

# Install required packages
sudo apt-get -y install build-essential flex bison libssl-dev libelf-dev libncurses-dev autoconf libudev-dev libtool dwarves bc wslu hwdata
```

In WSL2 terminal, clone a repository of WSL2-Linux-Kernel
```bash
WSL_VERSION=$(uname -r | cut -d '-' -f1)
git clone -b linux-msft-wsl-${WSL_VERSION} https://github.com/microsoft/WSL2-Linux-Kernel.git
cd WSL2-Linux-Kernerl
```
Copy config.gz
```bash
sudo cp /proc/config.gz config.gz
sudo gunzip config.gz
sudo mv config .config
```

Modifiy config
```bash
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
```

build
```bash
sudo make -j$(nproc)
sudo make modules_install -j$(nproc)
sudo make install -j$(nproc)
```

Install usbipd library
```bash
cd tools/usb/usbip
sudo ./autogen.sh
sudo ./configure
sudo make install -j$(nproc)
sudo cp libsrc/.libs/libusbip.so.0 /lib/libusbip.so.0
```

Copy bzImage to Host PC(windows)

```bash
HOST_USERNAME=$(wslpath "$(wslvar USERPROFILE)" | cut -d '/' -f5) 
sudo cp arch/x86/boot/bzImage /mnt/c/Users/${HOST_USERNAME}/usbip-bzImage
```

Set C:/Users/${HOST_USERNAME}/.wslconfig
```bash
[wsl2]
kernel=path_to_image # example kernel=C:\\Users\\{HOSTNAME}\\usbip-bzImage
```

Restart wsl
```bash
wsl --shutdown

or

wsl --terminate <Distro>
```












