# <p align="center">`5.16.5-hikari-x86_64`</p>

<p align="center"><samp>✲ optimized for multitask under extreme loads, see <a href="https://github.com/igo95862/cfs-zen-tweaks">cfs-zen-tweaks</a>(<a href="https://github.com/owl4ce/cfs-zen-tweaks-openrc">-openrc</a>) ✲</samp></p>

## [linux](./linux) <img alt="" align="right" src="https://badges.pufler.dev/visits/owl4ce/hikari-x86_64?style=flat-square&label=&color=000000&logo=GitHub&logoColor=white&labelColor=373e4d"/>

<p align="center"><a href="#general-linux-kernel-compilation-with-gcc-toolchain"><img alt="" src="https://repository-images.githubusercontent.com/308812995/e978591c-11ed-452f-bab8-718c2fca29cf"/></a></p>

<details>
<summary>Featured configuration/tweaks</summary>
  
  <br>
  
  > * Use [LRNG](https://github.com/smuellerDD/lrng) framework to provide sufficient entropy during boot as well as in virtual environments and SSDs
  > * Use balanced 500Hz timer frequency for fast desktop interactivity and smoothness with energy-efficient
  > * Use [Clang/LLVM toolchain](https://kernel.org/doc/html/latest/kbuild/llvm.html) with O3 optimization for processor family x86-64-v3 and ThinLTO by default
  > * Majority use [LZ4](https://github.com/lz4/lz4) compression algorithm for fastest de/compression speeds with low-compression ratio
  > * Use [BFQ I/O scheduler](https://kernel.org/doc/html/latest/block/bfq-iosched.html) which guarantees high-system, applications responsiveness, and low-latency
  > * Use [Performance governor](https://kernel.org/doc/html/latest/admin-guide/pm/cpufreq.html) by default for max CPU speed, change if too high energy consumptions
  > * Disabled unused features like 5-level page tables, debugging, kexec, kprobes, NUMA, Xen, etc.
  > * Enabled F2FS (SSD) and EXT4 (HDD) as built-in which optimized, and BTRFS as module
  > * Enabled AMD-specific or Intel-specific features, other SoCs are all disabled
  > * Enabled [AMD-pstate](https://lore.kernel.org/lkml/20211029130241.1984459-1-ray.huang@amd.com/T) driver for schedutil and ondemand governor
  > * Enabled [Zstd](https://github.com/facebook/zstd) module compression support by default (KMOD)
  > * Enabled Google's BBRv2 TCP congestion control by default
  > * Enabled New Paragon's Software [NTFS3](https://kernel.org/doc/html/latest/filesystems/ntfs3.html) driver
  > * Full-support [EFI stub](https://kernel.org/doc/html/latest/admin-guide/efi-stub.html) w/o initramfs
  > * Many more as in [xanmod.org](https://xanmod.org).
  
  > This configuration based on Linux souces with [Xanmod patchset](https://xanmod.org) + [Gentoo patches](https://wiki.gentoo.org/wiki/Project:Kernel/Gentoo-sources) from [src_prepare-overlay](https://gitlab.com/src_prepare/src_prepare-overlay/-/tree/master/sys-kernel/xanmod-sources).

</details>

##  
> #### General Linux kernel compilation with GCC toolchain
```sh
# Copy my hikari configuration as default config.
cp -v .config_hikari .config

# Many people usually use `menuconfig`, use `nconfig` to use beautiful curses interface.
ionice -c2 -n0 make -j$(nproc) nconfig

# Build Linux kernel.
ionice -c2 -n0 make -j$(nproc)

# Install the kernel modules.
ionice -c2 -n0 make -j$(nproc) modules_install

# Install the bzImage, known as vmlinuz.
ionice -c2 -n0 make -j$(nproc) install
```
> #### General Linux kernel compilation with LLVM toolchain
```sh
# Copy my hikari configuration as default config.
cp -v .config_hikari .config

# Many people usually use `menuconfig`, use `nconfig` to use beautiful curses interface.
ionice -c2 -n0 make -j$(nproc) LLVM=1 LLVM_IAS=1 nconfig

# Build Linux kernel.
ionice -c2 -n0 make -j$(nproc) LLVM=1 LLVM_IAS=1

# Install the kernel modules.
ionice -c2 -n0 make -j$(nproc) LLVM=1 LLVM_IAS=1 modules_install

# Install the bzImage, known as vmlinuz.
ionice -c2 -n0 make -j$(nproc) LLVM=1 LLVM_IAS=1 install
```
> Estimated may be longer than the GCC toolchain, but significally improving performance by using ThinLTO.

> <p align="center"><img src="./.github/screenshots/2021-10-30-072210_1301x748_scrot.png" alt="O3"/></p>
> <p align="center"><img src="./.github/screenshots/2021-10-30-073344_1301x748_scrot.png" alt="thin.lto"/></p>
> <p align="center"><img src="./.github/screenshots/2021-10-30-072151_1301x748_scrot.png" alt="march"/></p>

> See also Linux kernel configuration at [Gentoo Wiki](https://wiki.gentoo.org/wiki/Kernel/Configuration).

##  
### How to convert my own framebuffer logo?
> Simply install `netpbm` then convert your own logo, an example **.png** file into 224 24-bit colors ASCII pixmap.
> 
> > Generally, the Linux kernel framebuffer logo size is **80**x**80** pixels, but if you want to adjust the full screen size, you have to set up your logo with a size that matches your screen resolution e.g **1366**x**768**.
>
> Below will replace the default Tux logo with our custom logo. ~Initially I made a patch, but I think it's less effective because it's enough to replace then build the kernel.~ Created [linucc224](https://github.com/owl4ce/linucc224) for auto-patching. :tada:
```sh
pngtopnm /path/to/your_logo.png | ppmquant -fs 223 | pnmtoplainpnm > logo_linux_clut224.ppm

doas cp -fv logo_linux_clut224.ppm /usr/src/linux/drivers/video/logo/logo_linux_clut224.ppm
```

> To make framebuffer logo to appear on boot, ensure to use `loglevel=4` in the [kernel parameters](https://wiki.archlinux.org/index.php/Kernel_parameters).

> #### NOTE
> If you're using custom framebuffer logo like mine.  
> > The framebuffer logo must be cleared before init runs, you can modify your init. I've only ever tried on **runit** and **sysvinit**+**openrc**, other than that I don't know. For example **sysvinit**+**openrc** on Gentoo/Linux, I created [wrapper script](https://github.com/owl4ce/hmg/blob/main/sbin/localh3art-init) to run curses **clear** command before executing **openrc sysinit**. See my [inittab](https://github.com/owl4ce/hmg/blob/main/etc/inittab#L19-L20).  
> 
> **Below is an example of my trick ..**  
> Run the following commands as root.
> ```sh
> install -m755 /dev/stdin /sbin/localh3art-init << "EOF"
> #!/bin/sh
> 
> exec 2>/dev/null
> 
> LANG='POSIX' SYSINIT='/sbin/openrc sysinit' \
> X='\033[0m' W='\033[1;37m' R='\033[1;31m' G='\033[1;32m'
> 
> read -r KVER </proc/version
> 
> KVER="${KVER%%\ (*}" \
> KVER="${KVER##*version\ }"
> 
> printf ' %b ' "${G}* ${W}Booting with ${R}${KVER:-$(uname -r)}"
> 
> for S in 1 2 3 4; do
>     [ "$S" -gt 1 ] || continue
>     printf '%b' "${W}.${X}"
>     sleep .1s
> done
> 
> clear
> 
> exec ${SYSINIT}
> EOF
> ```
> ```sh
> sed -e '/si::sysinit:/s|openrc sysinit|localh3art-init|' -i /etc/inittab

> **Or, if you're actually don't care about framebuffer logo ..**  
> Simply enable this to disable the framebuffer logo that appears on boot.
> ```cfg  
> CONFIG_FRAMEBUFFER_CONSOLE_DEFERRED_TAKEOVER=y
> ```
> `Device Drivers` 🡲 `Graphics support` 🡲 `Console display driver support`

##  
### Generating initramfs (optional)
> #### Dracut
> Adjust version of the kernel that you build. Below is an example, run the following commands as root.
```sh
dracut --kver 5.16.5-hikari-x86_64 /boot/initramfs-5.16.5-hikari-x86_64.img --force
```
> See also my [dracut.conf](https://github.com/owl4ce/hmg/blob/main/etc/dracut.conf). Read more at [Gentoo Wiki](https://wiki.gentoo.org/wiki/Dracut).

##  
### EFI Stub Examples
> You must have separate `/boot` type **vfat** (12/16/32) partition, run one of the two commands below as root.  

> #### With initramfs
```sh
efibootmgr --create --part 1 --disk /dev/sda --label "GENTOO.hikari-x86_64" --loader "\vmlinuz-5.16.5-hikari-x86_64" \
-u "loglevel=4 initrd=\initramfs-5.16.5-hikari-x86_64.img"
```
> #### Without initramfs
```sh
efibootmgr --create --part 1 --disk /dev/sda --label "GENTOO.hikari-x86_64" --loader "\vmlinuz-5.16.5-hikari-x86_64" \
-u "root=PARTUUID=13992175-d060-1948-b042-ade29f8af571 rootfstype=f2fs rootflags=gc_merge,checkpoint_merge,compress_algorithm=lz4,compress_extension=*,compress_chksum,compress_cache,atgc loglevel=4"
```
> #### Show detailed entry
```sh
efibootmgr -v
```
> #### Delete entry
```sh
efibootmgr -BbXXXX
```

##  
### Acknowledgements
> * All Linux kernel developers and contributors
> * [Alexandre Frade](https://github.com/xanmod) as [Linux-Xanmod](https://xanmod.org) maintainer
> * [Hamad Al Marri](https://github.com/hamadmarri) as [CacULE (and other) scheduler](https://github.com/hamadmarri/cacule-cpu-scheduler) author
> * [Peter Jung](https://github.com/ptr1337) as [CachyOS](https://cachyos.org) developer, optimized Arch-based Linux distribution
> * [src_prepare Group](https://src_prepare.gitlab.io), the home of systems developers especially Gentoo/Linux
