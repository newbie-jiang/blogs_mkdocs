# buildroot根文件系统制作

## 前言

一般来说都是使用动态库来做，但是使用busybox需要手工去找动态库的依赖，很难搞，所以就有其他根文件系统制作工具，比如Buildroot

1. BusyBox “动态库依赖” 的问题

- **手动制作 rootfs 时**，如果你用动态链接编译 BusyBox，必须自己把 BusyBox 运行时所需的所有动态库（如 `libc.so.6`、`ld-linux.so.*` 等）都找到，并拷贝到根文件系统合适目录（通常 `/lib` 或 `/lib64`）。
- 这就需要你：
  - 确认 BusyBox 需要哪些库（可以用 `ldd busybox` 查看）。
  - 确认库的具体版本和软链接是否正确。
  - 还要考虑依赖链（glibc、libm、ld-linux等），缺一个就报错。
- 这种“手工找库拷贝”是初学者常见的麻烦事。

------

2. Buildroot 的优势

- **Buildroot 之所以更简单**，就在于它是全自动构建环境：
  - 你在配置 Buildroot 菜单时，选上 BusyBox（默认就是动态库模式）、选择工具链，它**自动分析依赖**，把所需的库都自动放进你的 rootfs。
  - **你无需手工找库。**
  - Buildroot 会自动搞定：
    - libc、libm、ld-linux 等所有依赖库
    - 必要的库文件软链接
    - 目录结构
    - 甚至动态库依赖的后续依赖（递归处理）
- 只要你的 buildroot 配置没问题，编译完的 rootfs 用于目标板（架构一致），通常不会遇到“找不到库”的错误。

------

3. 为什么 Buildroot 能自动搞定？

- Buildroot 懂得你的工具链用的是哪种 C 库（如 glibc、musl、uClibc），并知道它们要复制哪些库文件到 rootfs。
- 同时，Buildroot 用“包描述+依赖自动解析”机制，确保所选 BusyBox 的依赖一并处理。
- 所以最终生成的文件系统，已经自带完整动态库链。

------

4. 总结：手工 vs Buildroot

| 方式            | 依赖库处理                 | 容易出错 | 推荐用途       |
| --------------- | -------------------------- | -------- | -------------- |
| 手工制作 rootfs | 需自己查找、复制所有依赖库 | 容易     | 教学/极简实验  |
| Buildroot       | 自动分析、复制所有依赖库   | 很少     | 工程/量产/开发 |



------

5. 补充

- **Yocto** 也有类似机制，但比 Buildroot 更灵活、复杂、可自定义。
- 如果未来想轻松加包或升级，Buildroot 的自动化带来的简洁、可靠体验，是手动方式很难比的。

**结论**

> **Buildroot** 极大简化了动态库依赖处理流程，生成的 rootfs 直接可用，省去手工查找和复制动态库的麻烦，非常适合嵌入式Linux实际项目。





##  Buildroot使用方法



## 1. 获取 Buildroot 源码

官网下载稳定版或使用 git：

```
sh复制编辑git clone https://git.busybox.net/buildroot
cd buildroot
# 或下载指定版本
# wget https://buildroot.org/downloads/buildroot-2024.02.tar.gz
# tar xzf buildroot-2024.02.tar.gz
```

------

## 2. 选择目标平台（架构和处理器）

Buildroot 支持 ARM、MIPS、RISC-V、x86、PowerPC 等。可选预置板卡，也可自定义。

------

## 3. 配置 Buildroot

```
make menuconfig
```

会弹出图形界面（ncurses），你可以完成以下设置：

- **Target Architecture**：选择目标架构（如 ARM Cortex-A7、A53等）
- **Toolchain**：选择自带工具链（推荐初学者用 Buildroot 自动下载工具链）
- **Target packages**：选择需要的组件（如 BusyBox、Dropbear、OpenSSH、Python 等）
- **Filesystem images**：选择文件系统类型（如 ext4、squashfs、cpio、tar）
- **Kernel**：可选集成 Linux 内核，指定源码、配置、补丁
- **Bootloader**：可选集成 u-boot 等

**Tips**：

- 菜单内每一项都可详细配置。
- 可保存当前配置为 `.config` 文件，方便后续复用。

------

## 4. 开始构建

```
make -j$(nproc)
```

- 首次构建会下载/编译工具链、所有源码和依赖，耐心等待。
- 中途断网可能导致失败，建议用国内镜像源（可配置）。

------

## 5. 编译结果在哪里？

编译完成后，主要输出文件在 `output/images/` 目录：

- `rootfs.ext4`、`rootfs.squashfs` 等：根文件系统镜像
- `zImage`、`uImage`、`Image`：内核镜像（如果配置了内核）
- `bootloader`相关文件（如有）
- `rootfs.cpio`：用于initramfs启动
- 也可能有 dtb、u-boot等

------

## 6. 烧录/测试

- 可以把 `rootfs.ext4` 烧到 SD 卡/EMMC（适合开发板启动）

- 可将 `rootfs.cpio` 作为 initramfs 用于 QEMU 或开发板

- 可用 QEMU 虚拟机直接测试镜像
   示例（ARM QEMU）：

  ```
  qemu-system-arm -M vexpress-a9 -kernel output/images/zImage \
    -dtb output/images/vexpress-v2p-ca9.dtb \
    -initrd output/images/rootfs.cpio \
    -append "console=ttyAMA0" -serial stdio -nographic
  ```

------

## 7. 常用高级技巧

- `make clean`：清理目标产物
- `make menuconfig`：随时修改配置
- `make savedefconfig`：保存自定义配置（`defconfig` 文件）
- `make <package>-menuconfig`：定制某个包的配置（如 `make busybox-menuconfig`）
- `output/target/`：实际的根文件系统目录，可以手动加文件

------

## 8. 配置保存与复用

- 保存配置：

  ```
  sh复制编辑make savedefconfig
  # 得到 defconfig 文件
  ```

- 加载配置：

  ```
  sh复制编辑make defconfig
  # 会恢复 defconfig 为 .config
  ```

------

## 9. 其它说明

- Buildroot 不能动态管理包（不像 Ubuntu apt/yum），所有包需编译期选定。
- 如需添加自定义包，可以写自定义包描述文件（package 目录）。
- 适合用于“固件生成”、“生产环境rootfs打包”，不适合开发板本地软件调试。

------

# 总结

| 步骤           | 命令/要点             |
| -------------- | --------------------- |
| 获取源码       | `git clone`/解压tar包 |
| 选择架构和配置 | `make menuconfig`     |
| 开始编译       | `make -j$(nproc)`     |
| 查找产物       | `output/images/`      |
| 烧录/测试      | 烧卡/QEMU/开发板启动  |







## 实践

下载链接   https://git.busybox.net/buildroot  

- 选一个稳定版

![image-20250806003701094](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250806003701094.png)

解压到buildroot目录

```
mkdir buildroot
tar --strip-components=1 -xjf buildroot-2025.05.tar.bz2 -C buildroot
```

查看

```
hdj@hdj-virtual-machine:~/buildroot$ tree -L 1
.
├── arch
├── board
├── boot
├── CHANGES
├── Config.in
├── Config.in.legacy
├── configs
├── COPYING
├── DEVELOPERS
├── docs
├── fs
├── linux
├── Makefile
├── Makefile.legacy
├── package
├── README
├── support
├── system
├── toolchain
└── utils

12 directories, 8 files

```



```
make menuconfig
```



![image-20250806004421325](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250806004421325.png)

imx6ull为例子配置

## Target options

![image-20250806005238886](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250806005238886.png)

## Toolchain



![image-20250806005726401](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250806005726401.png)

1. **Toolchain type**

- `(Buildroot toolchain)`：**保留默认即可**（Buildroot 自动构建交叉工具链），新手推荐这种。

------

2. **C library (glibc/uClibc/musl)**

- **推荐 `glibc` 或 `musl`**
  - `glibc`：兼容性最好，和主流Linux桌面系统一致，体积较大。
  - `musl`：极简，体积小，现代嵌入式也很常用，兼容性稍差，但非常适合极简系统。
  - 如果你对C库没有特殊需求，**开发板性能充裕就选 glibc，追求小体积选 musl**。

------

3. **Kernel Headers**

- `(Linux 6.14.x kernel headers)`：默认即可。这个只是用来编译库和应用，不影响你实际烧录的内核版本。

------

4. **Binutils / GCC 版本**

- 默认最新版通常都可用。
- 可以指定稳定老版本，但 Cortex-A7 用新版本没问题。

------

5. **Enable C++/Fortran/OpenMP/Graphite support**

- 一般只勾 `Enable C++ support`（如果你有C++应用）。
- 其余如不需要 Fortran/OpenMP/Graphite 都可以不勾。

------

6. **Host GDB / gconv libraries / Extra toolchain libraries**

- 一般开发可不勾选 GDB（除非你要调试）。
- `gconv libraries` 只对国际化有需求时才需拷贝。

------

7. **Target Optimizations**

- 可以为空，默认就好。
- 进阶玩家可填优化选项如：`-O2 -mcpu=cortex-a7 -mfpu=vfpv4-d16 -mfloat-abi=hard -mthumb`

------

8. **Bare metal toolchain**

- 不要勾选（你做的是Linux，不是裸机应用）。

**最关键的建议：**

**前面你问过 ABI/floating point/vfp/thumb2 这些问题，这些高级设置在 Buildroot “Toolchain” 菜单的后续选项（如 Target ABI, Floating Point, Instruction Set）中会有详细选择。你应该重点关注这些**，如果没找到，可以在 Toolchain 下级菜单逐项查找，
 常见设置如下：

- **Target ABI**：选 `EABIHF`
- **Floating Point Strategy**：选 `hardware (VFP)`
- **FPU type**：选 `vfpv4-d16`
- **Instruction Set**：用户空间推荐 `Thumb2`

------

### **结论：**

- 保留默认 `Buildroot toolchain`
- C库选 glibc（或 musl）
- 其余选项按默认或根据实际需求勾选
- 编译优化、高级ABI/FPU/指令集选项后面继续补充/微调



