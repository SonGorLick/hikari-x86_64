## <p align="center">`_KVER_`</p>

<p align="center"><i>~ optimized for multitasking under extreme loads ~</i></p>

## [kernel.sources](./kernel.sources) <img alt="" align="right" src="https://badges.pufler.dev/visits/owl4ce/kurisu-x86_64?style=flat-square&label=&color=000000&logo=GitHub&logoColor=white&labelColor=373e4d"/>
<a href="#kernelsources-"><img alt="logo" align="right" width="402px" src="https://i.imgur.com/YSZAzT8.png"/></a>

- [New LRNG](https://github.com/smuellerDD/lrng)
- 500Hz tick rate
- [EFI Stub supports](https://www.kernel.org/doc/Documentation/efi-stub.txt)
- [LZ4](https://github.com/lz4/lz4) compressed bzImage
- [BFQ I/O Scheduler](https://www.kernel.org/doc/html/latest/block/bfq-iosched.html) as default
- [Governor performance](https://www.kernel.org/doc/Documentation/cpu-freq/governors.txt) as default
- Disabled NUMA, kexec, debugging, etc.
- AMD and Intel SoC, disabled other SoCs
- Use [LZ4](https://github.com/lz4/lz4) with [z3fold](https://www.kernel.org/doc/html/latest/vm/z3fold.html) zswap compressed block
- [Xanmod-~~CacULE~~ patchset with Gentoo patches](https://gitlab.com/src_prepare/src_prepare-overlay/-/tree/master/sys-kernel/xanmod-sources)

**What's the picture beside?** [牧瀬 紅莉栖](./kernel.sources/drivers/video/logo/logo_linux_clut224.ppm) <kbd>1366x768</kbd>

##  
> **General Linux kernel compilation**
```sh
cp .config_kurisu .config

make -j$(nproc) menuconfig # or `nconfig`

make -j$(nproc)

make -j$(nproc) modules_install
make -j$(nproc) install
```
> Good options is build with [LLVM](https://www.kernel.org/doc/html/latest/kbuild/llvm.html) with ThinLTO which enabled by default, needs LLVM integrated assembler.  
> 
> It's estimated may be longer than the GCC and Binutils, but significally improving performance on specific CPU by using ThinLTO and optimization level 3 using [Graysky's patch](https://github.com/graysky2/kernel_compiler_patch) which enabled by default.
> 
> ```sh
> make LLVM=1 LLVM_IAS=1 -j$(nproc) menuconfig # or `nconfig`
> 
> make LLVM=1 LLVM_IAS=1 -j$(nproc)
> 
> make LLVM=1 LLVM_IAS=1 -j$(nproc) modules_install
> make LLVM=1 LLVM_IAS=1 -j$(nproc) install
> ```
>   
> ![ThinLTO](https://raw.githubusercontent.com/owl4ce/kurisu-x86_64/kurisu-x86_64/.github/screenshots/2021-06-29-062643_1301x748_scrot.png)
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
> LC_ALL=POSIX LANG=POSIX; W='\033[1;37m' R='\033[1;31m' G='\033[1;32m' NC='\033[0m'
> 
> INIT='/sbin/openrc sysinit'
> 
> kern() { printf " ${G}* ${W}Booting with ${R}$(uname -r) "; }
> dots() {
>     for S in $(seq 1 4); do
>         if [ "$S" -gt 1 ]; then
>             printf "${W}.${NC}"
>         fi
>         sleep .1s
>     done
> }
> 
> kern; dots; clear; exec ${INIT}
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
> **:** `Device Drivers` 🡲 `Graphics support` 🡲 `Console display driver support`

##  
### How to convert my own framebuffer logo?
Simply install `netpbm` then convert your own logo, for example is **.png** file into 224 24-bit colors ASCII pixmap.

> Generally, the Linux kernel framebuffer logo size is **80**x**80** pixels, but if you want to adjust the full screen size, you have to set up your logo with a size that matches your screen resolution e.g **1366**x**768**.

Below will replace the default Tux logo with our custom logo. ~Initially I made a patch, but I think it's less effective because it's enough to replace then build the kernel.~ Created [linucc224](https://github.com/owl4ce/linucc224) for auto-patching. :tada:
```sh
pngtopnm /path/to/your_logo.png | ppmquant -fs 223 | pnmtoplainpnm > logo_linux_clut224.ppm

doas cp -fv logo_linux_clut224.ppm /usr/src/linux/drivers/video/logo/logo_linux_clut224.ppm
```

> In order for the logo to appear on boot, ensure to use `loglevel=4` in the [kernel parameters](https://wiki.archlinux.org/index.php/Kernel_parameters).

<p align="center"><img src="https://i.imgur.com/R82KVaB.gif"/></p>

> If you want silent boot, simply use `quiet` instead.

##  
### Generate the initramfs
> If using.

**Dracut**  
Adjust version of the kernel that you build. Below is an example, run the following commands as root.
```sh
dracut --kver _KVER_ /boot/initramfs-_KVER_.img --force
```

##  
### EFI Stub Examples
You must have separate `/boot` type **vfat** (12/16/32) partition, then run one of the two commands below as root.  

**With initramfs**
```sh
efibootmgr --create --part 1 --disk /dev/sda --label "GENTOO_kurisu-x86_64" --loader "\vmlinuz-_KVER_" \
-u "loglevel=4 initrd=\initramfs-_KVER_.img"
```
**Without initramfs**
```sh
efibootmgr --create --part 1 --disk /dev/sda --label "GENTOO_kurisu-x86_64" --loader "\vmlinuz-_KVER_" \
-u "root=PARTUUID=a157257a-6617-cd4c-b07f-2c33d4cb89f8 rootfstype=f2fs rootflags=gc_merge,compress_algorithm=lz4,compress_extension=*,compress_chksum,compress_cache,atgc rw,noatime loglevel=4"
```
**Show detailed entry**
```sh
efibootmgr -v
```
**Delete entry**
```sh
efibootmgr -BbXXXX
```

##  
### Acknowledgements
* All Linux Kernel Developers and Contributors;
* [Alexandre Frade](https://github.com/xanmod) as Linux-Xanmod Maintainer;
  * https://xanmod.org
* [Hamad Al Marri](https://github.com/hamadmarri) as CacULE Scheduler Author;
  * https://github.com/hamadmarri/cacule-cpu-scheduler
* [src_prepare Group](https://src_prepare.gitlab.io), the home of Systems Developers especially Gentoo/Linux.
