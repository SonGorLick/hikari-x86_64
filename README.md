## <p align="center">`5.13.12-kurisu-x86_64`</p>

<p align="center"><i>~ optimized for multitasking under heavy load (hopefully) ~</i></p>

## [Kernel sources](./kernel.sources) <img alt="" align="right" src="https://badges.pufler.dev/visits/owl4ce/kurisu-x86_64?style=flat-square&label=&color=000000&logo=GitHub&logoColor=white&labelColor=373e4d"/>
<a href="#kernel-sources"><img alt="logo" align="right" width="439px" src="https://i.imgur.com/YSZAzT8.png"/></a>

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
**Gentoo/Linux** ( as root, required pkgs: `cpio` `lz4` )  
`/usr/src/linux`
```sh
cp .config_kurisu .config

make -j$(nproc) menuconfig

make -j$(nproc) -l$(nproc)

# Install (modules and kernel)
make -j$(nproc) modules_install
make -j$(nproc) install
```
> #### Warning!
> If you want multitasking responsiveness when using multiple jobs, set the load average to prevent slowdowned system ( or maybe even up to OOM ).

> Other options is compiling with [LLVM toolchain](https://www.kernel.org/doc/html/latest/kbuild/llvm.html) with ThinLTO ( enabled by default, but needs `LLVM_IAS=1` ).  
> 
> Its estimated that it may be longer than the GCC and Binutils, but significally improving performance on specific CPU by using ThinLTO and optimization level 3 ( enabled by default ). This also uses less memory than GCC.
> ```sh
> make LLVM=1 LLVM_IAS=1 -j$(nproc) menuconfig
> 
> make LLVM=1 LLVM_IAS=1 -j$(nproc) -l$(nproc)
> 
> make LLVM=1 LLVM_IAS=1 -j$(nproc) modules_install
> make LLVM=1 LLVM_IAS=1 -j$(nproc) install
> ```
>   
> ![ThinLTO](https://raw.githubusercontent.com/owl4ce/kurisu-x86_64/kurisu-x86_64/.github/screenshots/2021-06-29-062643_1301x748_scrot.png)

> Recommended to build with native CPU optimization, auto detected by GCC or Clang.   
>   
> ![-MARCH](https://raw.githubusercontent.com/owl4ce/kurisu-x86_64/kurisu-x86_64/.github/screenshots/2021-06-29-061857_1301x748_scrot.png)

##  

> #### Note!
> If you're using custom framebuffer logo like mine.  
> > The framebuffer logo must be cleared before init runs, you can modify your init. I've only ever tried this on **runit** and **sysvinit**+**openrc**, other than that I don't know.
> For example is **sysvinit**+**openrc** on Gentoo/Linux, I created a [wrapper script](https://github.com/owl4ce/hmg/blob/main/sbin/localh3art-init) to execute curses **clear** command before executing **openrc sysinit** (Runlevel 1). See my [inittab](https://github.com/owl4ce/hmg/blob/main/etc/inittab#L19-L20).  
> 
> **Below is an example of my trick ..**  
> Run the following commands as root.
> ```sh
> cat > /sbin/localh3art-init << "EOF"
> #!/bin/sh
> LC_ALL=C LANG=C; W="\033[1;37m" R="\033[1;31m" G="\033[1;32m" NC="\033[0m"
> 
> INIT="/sbin/openrc sysinit"
> 
> kern() { printf " ${G}* ${W}Booting with ${R}$(uname -r) "; }
> dots() {
>     for X in $(seq 1 4); do
>         if [ "$X" -gt 1 ]; then
>             printf "${W}.${NC}"
>         fi
>         sleep .1s
>     done && unset X
> }
> 
> kern; dots; clear; exec ${INIT}; exit $?
> EOF
> ```
> ```sh
> chmod +x /sbin/localh3art-init
> ```
> ```sh
> sed -i 's|si::sysinit:/sbin/openrc sysinit|si::sysinit:/sbin/localh3art-init|' /etc/inittab

> **Or, if you're actually don't care about framebuffer logo ..**  
> Simply enable this to disable the framebuffer logo that appears on boot.
> ```cfg  
> CONFIG_FRAMEBUFFER_CONSOLE_DEFERRED_TAKEOVER=y
> ```
> **: ᴘᴀᴛʜ**  
> **:** `Device Drivers` -> `Graphics support` -> `Console display driver support`

##  
### How to convert my own framebuffer logo?
Simply install `netpbm`, then convert your own logo for example is **.png** extension into 224 24-bit colors ASCII pixmap.

> Generally, the Linux kernel framebuffer logo size is **80**x**80** pixels, but if you want to adjust the full screen size, you have to set up your logo with a size that matches your screen resolution e.g **1366**x**768**.

Below will replace the default Tux logo with our custom logo. ~Initially I made a patch, but I think it's less effective because it's enough to replace then build the kernel.~ Created [linucc224](https://github.com/owl4ce/linucc224) for auto-patching. :tada:
```sh
pngtopnm /path/to/your_logo.png | ppmquant -fs 223 | pnmtoplainpnm > logo_linux_clut224.ppm

doas cp -fv logo_linux_clut224.ppm /usr/src/linux/drivers/video/logo/logo_linux_clut224.ppm
```

> In order for the logo to appear on boot, make sure to use `loglevel=4` in the [kernel parameters](https://wiki.archlinux.org/index.php/Kernel_parameters).

<p align="center"><img src="https://i.imgur.com/R82KVaB.gif"/></p>

> If you want silent boot, simply use `quiet` instead.

##  
### Generate the initramfs
> If using.

**Dracut**  
Adjust version of the kernel that you build. Below is an example, run the following commands as root.
```sh
dracut --kver 5.13.12-kurisu-x86_64 /boot/initramfs-5.13.12-kurisu-x86_64.img --force
```

##  
### EFI Stub Examples
You must have separate `/boot` partition with partition type **vfat**, then run one of the two commands below as root.  
**With initramfs**
```sh
efibootmgr --create --part 1 --disk /dev/sda --label "GENTOO_kurisu-x86_64" --loader "\vmlinuz-5.13.12-kurisu-x86_64" \
-u "loglevel=4 initrd=\initramfs-5.13.12-kurisu-x86_64.img"
```
**Without initramfs**
```sh
efibootmgr --create --part 1 --disk /dev/sda --label "GENTOO_kurisu-x86_64" --loader "\vmlinuz-5.13.12-kurisu-x86_64" \
-u "root=PARTUUID=a157257a-6617-cd4c-b07f-2c33d4cb89f8 rootfstype=f2fs rootflags=background_gc=sync,gc_merge,active_logs=2,compress_algorithm=lz4,compress_extension=*,compress_chksum rw,noatime loglevel=4"
```

##  
### Acknowledgements
* All Linux Kernel Developers and Contributors;
* [Alexandre Frade](https://github.com/xanmod) as Linux-Xanmod Maintainer;
* [Hamad Al Marri](https://github.com/hamadmarri) as CacULE Scheduler Author;
* [src_prepare Group](https://src_prepare.gitlab.io), the home of Systems Developers especially Gentoo/Linux.
