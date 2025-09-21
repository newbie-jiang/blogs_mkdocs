# busybox根文件系统制作

（不推荐，可以简单了解一下，使用手工解决依赖问题，麻烦，推荐buildroot）



## 1. 交叉编译工具链准备

- **获取交叉编译工具链**（如`arm-linux-gnueabihf-gcc`等），确保在开发机上可用，且`$PATH`已包含其bin目录。

```
export CROSS_COMPILE=arm-linux-gnueabihf-
export ARCH=arm
```

## 2. 编译BusyBox

1. **下载源码**

   ```
   wget https://busybox.net/downloads/busybox-1.36.1.tar.bz2
   tar xjf busybox-1.36.1.tar.bz2
   cd busybox-1.36.1
   ```

2. **配置BusyBox**
    推荐用`make menuconfig`，可以自定义功能：

   ```
   make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- menuconfig
   # 选择"Build static binary"（静态编译更方便裸机移植）
   ```

3. **编译并安装**

   ```
   make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j$(nproc)
   make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- install
   ```

   安装后生成`_install/`目录，里面是已编译好的BusyBox应用软链接。

------

## 3. 根文件系统目录结构搭建

- 按照Linux Filesystem Hierarchy Standard(FHS)创建基本目录结构。例如：

  ```
  mkdir -p rootfs/{bin,sbin,etc,proc,sys,usr/{bin,sbin},dev,tmp,var,lib,mnt,home}
  ```

- 将BusyBox的输出内容复制到根文件系统：

  ```
  cp -a busybox-1.36.1/_install/* rootfs/
  ```

------

## 4. 设备节点创建

- 必须有基本设备节点，如`/dev/console`和`/dev/null`，可用`sudo mknod`在PC下创建：

  ```
  sudo mknod -m 600 rootfs/dev/console c 5 1
  sudo mknod -m 666 rootfs/dev/null c 1 3
  ```

------

## 5. 基本配置文件准备

- **/etc/inittab**（BusyBox init的启动配置）：

  ```
  cat > rootfs/etc/inittab <<EOF
  ::sysinit:/etc/init.d/rcS
  ::askfirst:-/bin/sh
  ::ctrlaltdel:/sbin/reboot
  ::shutdown:/sbin/swapoff -a
  ::shutdown:/bin/umount -a -r
  ::shutdown:/sbin/reboot
  EOF
  ```

- **/etc/init.d/rcS**（启动脚本，务必加执行权限）：

  ```
  mkdir -p rootfs/etc/init.d
  cat > rootfs/etc/init.d/rcS <<EOF
  #!/bin/sh
  mount -t proc none /proc
  mount -t sysfs none /sys
  # 可选：mount -t tmpfs none /tmp
  EOF
  chmod +x rootfs/etc/init.d/rcS
  ```

- 其他如`/etc/passwd`, `/etc/group`可以简单创建，避免启动报错。

------

## 6. 库文件准备（仅动态编译需做）

- 如果BusyBox为**静态编译**，可跳过此步。
- 动态编译需将交叉工具链下的对应`lib/ld-linux*.so*`, `lib/libc.so*`等库复制到`rootfs/lib`或`rootfs/lib64`。

------

## 7. 其它（可选）

- 可添加自己的应用程序或脚本到`rootfs/bin`、`rootfs/sbin`等目录。
- 可配置`/etc/fstab`、`/etc/profile`等以便于挂载和环境变量设置。

------

## 8. 打包成文件系统映像

- **制作cpio/initramfs镜像**

  ```
  cd rootfs
  find . | cpio -o -H newc > ../rootfs.cpio
  ```

- **制作squashfs/ext4镜像**

  ```
  # ext4（适合SD/EMMC/flash，挂载为rootfs）
  dd if=/dev/zero of=../rootfs.ext4 bs=1M count=32
  mkfs.ext4 ../rootfs.ext4
  sudo mount -o loop ../rootfs.ext4 /mnt
  sudo cp -a * /mnt
  sudo umount /mnt
  ```

------

## 9. 挂载/测试

- 用QEMU或开发板挂载根文件系统（initramfs, NFS, SD/EMMC/flash等），启动测试。
- 可以通过串口或控制台观察`init`流程。

------

## 总结表格

| 步骤           | 说明                       |
| -------------- | -------------------------- |
| 工具链准备     | 交叉编译器、PATH设置       |
| 编译BusyBox    | 配置、静态/动态编译、安装  |
| 构建rootfs结构 | 创建标准目录、复制应用     |
| 创建设备节点   | mknod生成console/null等    |
| 编辑配置文件   | inittab、rcS等启动脚本     |
| 准备库文件     | 动态库复制（动态编译需做） |
| 可选添加       | 自定义程序、脚本、配置     |
| 打包成映像     | cpio、ext4、squashfs等     |
| 挂载测试       | QEMU/开发板启动测试        |



## BusyBox 制作根文件系统，使用动态库与使用静态库有什么优缺点？

## 1. 动态库 vs 静态库概念

- **静态库（Static linking）**
   BusyBox及其他程序在编译时，所有依赖的库代码都被打包进可执行文件，运行时不再依赖外部库文件。
- **动态库（Dynamic linking）**
   可执行文件本身只包含主程序，依赖的库（如libc.so、ld-linux.so等）在运行时由系统动态加载，需要根文件系统中有这些库。

------

## 2. 对比表

| 对比项       | 静态库 BusyBox                          | 动态库 BusyBox               |
| ------------ | --------------------------------------- | ---------------------------- |
| **体积**     | 单个可执行文件较大                      | 可执行文件小，但需额外的库   |
| **依赖**     | 无需libc等外部库，移植简单              | 需提供glibc/musl等动态库     |
| **兼容性**   | 更易跨平台、裸机适用                    | 依赖库版本、架构等匹配       |
| **RAM消耗**  | 多个静态编译程序各自带一份库，RAM占用多 | 多个程序共享内存的库，占用少 |
| **升级维护** | 升级需整体重编译替换程序                | 可单独升级库或应用           |
| **调试定位** | 问题定位更简单                          | 需考虑库兼容性与加载问题     |
| **安全性**   | 漏洞需重编所有程序                      | 升级库即可全局修复           |
| **启动速度** | 稍快（无需加载库）                      | 略慢（要加载库）             |



------

## 3. 优缺点详细说明

### 静态库优缺点

**优点：**

- 整个可执行文件自足（只有BusyBox一个文件），适合初学和极简/只读/ROM型系统。
- 移植极其简单，只要有/bin/busybox即可跑起来，出错点少。
- 避免“动态库找不到/版本不符”等问题。

**缺点：**

- 文件体积比动态版大（一般600~1000KB，动态版可<300KB）。
- RAM利用率低（如多个程序用同样的库，都各自独立占内存）。
- 更新或修复某一库漏洞，要重编整个可执行程序。

### 动态库优缺点

**优点：**

- 可执行文件体积小。
- RAM效率高，多个程序共享libc等库。
- 维护简单：升级glibc或musl等库即可全系统生效，无需重编所有应用。
- 更接近标准Linux发行版做法，便于日后增加自定义程序。

**缺点：**

- 根文件系统**必须包含所有依赖的动态库**（glibc、ld-linux等），否则启动报错。
- 需要处理库版本、路径、软链接等细节（对新手不友好）。
- 初次移植时易因库文件缺失或不匹配导致“找不到libc.so.6”等错误。

------

## 4. 实践建议

- **极简环境/初学实验/单一BusyBox场景**：优先用**静态库**。
- **多应用/维护升级/正式发行**：优先用**动态库**。
- **存储极度有限/裸机/无libc**：只能用静态库。
- **如需将busybox和自编小工具都静态编译，移植最方便，但整体文件大。**

------

## 5. 总结

> **静态库更简单，动态库更灵活高效。嵌入式首推静态库，小型Linux发行/后续扩展优选动态库。**

如果你要移植到资源很有限（比如SDRAM很小、flash很小、只要一个shell）的系统，静态BusyBox是首选；如果你要后续装更多程序或升级维护，建议搞动态库rootfs，把常用库一次拷全，后续可维护性好。















