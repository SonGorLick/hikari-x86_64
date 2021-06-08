## <p align="center">`5.12.8-kurisu-x86_64`</p>

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

**Bonus?**
- [Kurisu Makise『牧瀬 紅莉栖』](./kernel.sources/drivers/video/logo/logo_linux_clut224.ppm) <kbd>1366x768</kbd>

##  
**Gentoo/Linux** (as root, required pkg: *cpio*, *lz4*)  
`/usr/src/linux`
```sh
cp .config_kurisu .config

make -j$(nproc) menuconfig

make -j$(nproc)

# Install (modules and kernel)
make -j$(nproc) modules_install
make -j$(nproc) install
```
> Other options is compiling with [`LLVM Toolchain`](https://www.kernel.org/doc/html/latest/kbuild/llvm.html)  
> **Note!** It's estimated that it may be longer than the GCC.
> ```sh
> make LLVM=1 -j$(nproc)
> ```

> If you find an area with a black background covering the console tty's font, please turn this on  
> ```cfg  
> FRAMEBUFFER_CONSOLE_DEFERRED_TAKEOVER=y`
> ```
> **PATH**:  
> Device Drivers **->** Graphics support **->** Console display driver support

##  
### Generate initramfs `if using`
**Dracut**  
Adjust <version> with the kernel version you compiled/use (as root)
```sh
dracut --kver <version> /boot/initramfs-<version>.img --force
```

##  
### EFI Stub example `/boot vfat`
(as root)  

**With initramfs**
```sh
efibootmgr --create --part 1 --disk /dev/sda --label "GENTOO_kurisu-x86_64" --loader "\vmlinuz-5.12.5-kurisu-x86_64" \
-u "loglevel=4 initrd=\initramfs-5.12.5-kurisu-x86_64.img"
```

**Without initramfs**
```sh
efibootmgr --create --part 1 --disk /dev/sda --label "GENTOO_kurisu-x86_64" --loader "\vmlinuz-5.12.5-kurisu-x86_64" \
-u "root=PARTUUID=a157257a-6617-cd4c-b07f-2c33d4cb89f8 rootfstype=f2fs rootflags=active_logs=2,compress_algorithm=lz4 rw,noatime loglevel=4"
```

> In order for the logo to appear on boot, make sure to use `loglevel=4` in the [kernel parameters](https://wiki.archlinux.org/index.php/Kernel_parameters).

<p align="center"><img src="https://i.ibb.co/1T0rYL4/final.gif"/></p>

> If you want silent boot, simply use `quiet` instead.

###### <p align="right">[`backup_gentoo_config`](https://github.com/owl4ce/hold-my-gentoo)</p>
