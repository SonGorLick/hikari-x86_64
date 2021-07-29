## <p align="center">`_KVER_`</p>

<p align="center"><i>~ optimized for multitasking under heavy load (hopefully) ~</i></p>

## [Kernel sources](./kernel.sources) <img alt="" align="right" src="https://badges.pufler.dev/visits/owl4ce/kurisu-x86_64?style=flat-square&label=&color=000000&logo=GitHub&logoColor=white&labelColor=373e4d"/>
<a href="#kernel-sources"><img alt="logo" align="right" width="439px" src="https://i.ibb.co/TYdw4Md/kurisu.png"/></a>

- 500Hz tick rate
- EFI Stub supports
- Lz4 compressed bzImage
- BFQ I/O Scheduler as default
- Governor performance as default
- Disabled numa, kexec, debugging, etc.
- AMD and Intel SoC only, disabled other SoCs
- [Xanmod-~~CacULE~~ patchset + Gentoo patches](https://gitlab.com/src_prepare/src_prepare-overlay/-/tree/master/sys-kernel/xanmod-sources)
- Enabled lz4 + z3fold zswap compressed block

**Bonus?** For personal use only!
- [Kurisu Makise『牧瀬 紅莉栖』](./kernel.sources/drivers/video/logo/logo_linux_clut224.ppm) <kbd>1366x768</kbd>

##  
**Gentoo/Linux** (as root, required pkg: *cpio*, *lz4*)  
`/usr/src/linux`
```sh
cp .config_kurisu .config

make -j$(nproc) menuconfig

make -j$(nproc) -l$(($(nproc)+1))

# Install (modules and kernel)
make -j$(nproc) modules_install
make -j$(nproc) install
```
> **Warning!**  
> Always set multiple jobs with load average to prevent hangs nor system freeze. Above will use "core/threads + 1".

> Other options is compiling with [LLVM toolchain](https://www.kernel.org/doc/html/latest/kbuild/llvm.html) with ThinLTO (enabled by default, but needs `LLVM_IAS=1`).

> **Note!**  
> Its estimated that it may be longer than the GCC and Binutils, but significally improving performance on specific CPU by using ThinLTO and optimization level 3 (enabled by default).
> ```sh
> make LLVM=1 LLVM_IAS=1 -j$(nproc) menuconfig
> 
> make LLVM=1 LLVM_IAS=1 -j$(nproc) -l$(($(nproc)+1))
> 
> make LLVM=1 LLVM_IAS=1 -j$(nproc) modules_install
> make LLVM=1 LLVM_IAS=1 -j$(nproc) install
> ```
>   
> ![ThinLTO](https://raw.githubusercontent.com/owl4ce/kurisu-x86_64/kurisu-x86_64/.github/screenshots/2021-06-29-062643_1301x748_scrot.png)
>   
> ```sh
> CONFIG_LTO=y
> CONFIG_LTO_CLANG=y
> CONFIG_ARCH_SUPPORTS_LTO_CLANG=y
> CONFIG_ARCH_SUPPORTS_LTO_CLANG_THIN=y
> CONFIG_HAS_LTO_CLANG=y
> # CONFIG_LTO_NONE is not set
> # CONFIG_LTO_CLANG_FULL is not set
> CONFIG_LTO_CLANG_THIN=y
> ```

> Recommended to compile with native CPU optimization ( `-march` ), auto detected by GCC or Clang.   
>   
> ![-MARCH](https://raw.githubusercontent.com/owl4ce/kurisu-x86_64/kurisu-x86_64/.github/screenshots/2021-06-29-061857_1301x748_scrot.png)

> If you find an area with a black background covering the console tty's font, please turn this on!  
> It's basically caused by the framebuffer not being cleared before entering init.
> ```cfg  
> CONFIG_FRAMEBUFFER_CONSOLE_DEFERRED_TAKEOVER=y
> ```
> **: ᴘᴀᴛʜ**  
> **:** `Device Drivers` -> `Graphics support` -> `Console display driver support`

##  
### Generate initramfs `if using`
**Dracut**  
Adjust <version> with the kernel version you compiled/use (as root)
```sh
dracut --kver <version> /boot/initramfs-<version>.img --force
```

##  
### How to convert my own FB logo?
Simply install `netpbm`, then convert your own logo for example is `.png` extension into 224 colors 24-bit ASCII pixmap with the following command.

> Generally, the Linux kernel logo size is **80**x**80** pixels, but if you want to adjust the full screen size, you have to set up your logo with a size that matches your screen resolution e.g **1366**x**768**.

> Below will replace the default Linux logo with our custom logo. Initially I made a patch, but I think it's less effective because it's enough to replace and build the kernel.
```sh
pngtopnm /path/yourlogo.png | ppmquant -fs 223 | pnmtoplainpnm > logo_linux_clut224.ppm

doas cp -fv logo_linux_clut224.ppm /usr/src/linux/drivers/video/logo/logo_linux_clut224.ppm
```

> In order for the logo to appear on boot, make sure to use `loglevel=4` in the [kernel parameters](https://wiki.archlinux.org/index.php/Kernel_parameters).

<p align="center"><img src="https://i.ibb.co/1T0rYL4/final.gif"/></p>

> If you want silent boot, simply use `quiet` instead.

##  
### EFI Stub Examples
You must have a separate `/boot` partition with partition type vfat (fat32), and run one of the two commands below as root.

**With initramfs**
```sh
efibootmgr --create --part 1 --disk /dev/sda --label "GENTOO_kurisu-x86_64" --loader "\vmlinuz-_KVER_" \
-u "loglevel=4 initrd=\initramfs-_KVER_.img"
```

**Without initramfs**
```sh
efibootmgr --create --part 1 --disk /dev/sda --label "GENTOO_kurisu-x86_64" --loader "\vmlinuz-_KVER_" \
-u "root=PARTUUID=a157257a-6617-cd4c-b07f-2c33d4cb89f8 rootfstype=f2fs rootflags=active_logs=2,compress_algorithm=lz4 rw,noatime loglevel=4"
```

###### <p align="right">[`backup_gentoo_config`](https://github.com/owl4ce/hold-my-gentoo)</p>
