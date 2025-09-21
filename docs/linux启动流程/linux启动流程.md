1.在芯片上有一个bootrom分区，bootrom分区里放的厂家的代码，支持iap，一般bootrom支持哪些启动方式都会有一个说明，比如给几个io，系统上电的时候读取io的高低电平决定从sd卡启动或者是emmc启动或者是nor flash启动

2.我们将uboot烧录到某个flash，系统启动时，第一个程序uboot也就启动了，接着要将内核加载到ram



考虑问题

- 既然是要将内核加载到ram，那么这个过程必定是要初始化ram的，是bootrom区域的固化程序初始化ram还是bootloader的程序初始化ram?
- 其次，要知道内核以及根文件系统在哪一个位置我要去对应的位置读取
- 然后要将内核以及根文件系统加载到内存的什么位置
- 文件系统是由内核加载到ram还是uboot加载到ram?



## 问题1. ram是由bootrom区域的代码初始化还是uboot初始化

**RAM（DRAM/SRAM）的初始化分阶段：**



1. **BootROM 阶段：**

- **BootROM** 是芯片内部固化的“第一阶段启动程序”，存放在芯片内部，只能读不能改。
- BootROM 的主要任务：**完成极其简单的硬件初始化**（比如设置时钟、检查引脚状态、选择启动设备，如NAND、eMMC、SD、QSPI等），
- **大多数情况下，BootROM还无法操作外部RAM**（比如DRAM），
- 它**从启动设备加载U-Boot的前一小部分（SPL/TPL）到芯片内部的SRAM（很小，一般几十K或几百K）**。

2. **SPL/TPL 阶段（有的SoC有，有的没有）：**

- **SPL**（Secondary Program Loader）或**TPL**（Third Program Loader），是U-Boot的精简版本，
- **主要任务就是初始化外部RAM（比如DDR/LPDDR）**，因为正式的U-Boot很大，必须先把DRAM初始化好，才能加载U-Boot到DRAM中执行。
- SPL在片内SRAM中运行，完成**外部RAM初始化**（通过配置DDR控制器、执行DDR初始化序列）。
- 有些简单MCU/SoC，BootROM直接初始化了RAM，那就不需要SPL阶段。

3. **U-Boot阶段（main U-Boot）：**

- **等外部RAM初始化好后，SPL把完整的U-Boot加载到RAM（DRAM）里**，跳转过去继续执行。
- U-Boot就可以在更大更快的内存空间里运行，加载内核、dtb等。

------

**整体流程（举例说明）**

以常见ARM Cortex-A芯片为例：

1. **BootROM**
    →（在芯片内部ROM，初始化片内资源，加载SPL到SRAM）
2. **SPL**
    →（在SRAM里跑，初始化外部RAM/DRAM）
3. **main U-Boot**
    →（加载到DRAM里，继续执行，做后续工作）

- 只有当DRAM初始化好以后，系统才能用大容量内存做后续操作。
- **外部RAM的初始化通常是在SPL完成的！**

------

**特殊情况**

- 有的单片机/SoC有“引导RAM”或“on-chip RAM”足够大，BootROM阶段可以直接初始化外部RAM，这种情况下就没有SPL/TPL。
- 极简系统（无DDR/只有SRAM）直接BootROM后进U-Boot。

------

**总结**

- **RAM（外部DRAM）通常是由U-Boot的SPL阶段初始化的。**
  - BootROM 只做最基本的事情，把SPL拉到SRAM里执行。
  - SPL初始化外部RAM，加载main U-Boot。
  - main U-Boot 之后就能任意用大RAM了。
- **只有部分简单芯片，BootROM就能初始化外部RAM。绝大部分SoC，都依赖SPL来完成DRAM初始化。**









## 问题2 .uboot只是加载内核文件到ram么，文件系统呢？



**文件系统（rootfs）是由内核挂载的，而不是由U-Boot加载到RAM的。**

1. **U-Boot只负责加载内核（zImage/Image）、设备树（.dtb）、有时还会加载initrd/initramfs到RAM。**

- U-Boot的任务是：把内核镜像、设备树、（可选）initrd 这些文件从Flash/SD卡/存储介质**加载到RAM的指定地址**，然后跳转到内核入口，启动内核。

2. **真正的“挂载文件系统”动作发生在Linux内核启动之后**

- 内核启动后，会根据启动参数（bootargs，通常是`root=/dev/mmcblk0p2`这样的参数）去**挂载你指定的根文件系统**，比如eMMC/SD卡/NAND等存储介质的某个分区上的ext4、squashfs、jffs2等文件系统。
- 这种情况下，**文件系统（rootfs）依然在存储介质上，只有你访问文件时，数据才被按需读入RAM（通过缓存）**，不是一开机就整体加载到RAM。

3. **initramfs/initrd是例外，它确实会先加载到RAM，然后被内核挂载为临时根文件系统。**

- 有些嵌入式/桌面Linux会用initramfs/initrd（比如解压固件、做启动解锁等），
- 这时U-Boot会把initramfs/initrd镜像一块加载到RAM，内核启动时以RAM里的initramfs当作临时根文件系统，
- **但是最终根文件系统（rootfs）还是内核来挂载，并且通常是挂载在flash/eMMC/SD卡等介质上。**

4. **常见流程简述**

1. **U-Boot**：
   - 加载内核、设备树、（可选）initramfs到RAM。
   - 跳转到内核入口。
2. **内核**：
   - 启动，解析设备树，初始化驱动。
   - 根据bootargs，挂载根文件系统（rootfs），比如`/dev/mmcblk0p2`。
   - rootfs开始生效，进入用户空间（init进程）。

------

**总结一句话**

- **根文件系统（rootfs）是内核挂载的，不是U-Boot加载到RAM的。**
- **U-Boot只负责把内核、dtb、initramfs等文件加载到RAM。根文件系统通常仍然在存储设备（flash、SD、eMMC等）的分区里，内核挂载时才访问。**





## 问题3 “bootloader（如U-Boot）从哪里找到内核、加载到RAM哪里、这些信息哪里配置的？”

1. **U-Boot 如何“找到”内核映像的位置？**

**（1）“找内核”主要有两种方式：**

- **A. 通过文件系统（FAT/ext4等）查找内核文件**

  - 比如 SD卡、eMMC 有 FAT/ext4 文件系统，U-Boot 支持命令：

    ```
    fatload mmc 0:1 0x80000000 zImage
    ```

    含义：

    - `fatload`：用FAT文件系统读文件
    - `mmc 0:1`：设备0的分区1
    - `0x80000000`：加载到RAM的0x80000000地址
    - `zImage`：文件名

  - 这种方式下，“找文件”靠环境变量/脚本/命令行，文件名和路径灵活。

- **B. 按“固定物理偏移”直接从Flash等块设备读**

  - 有的系统（无文件系统）会在存储介质某个固定地址烧入内核映像，比如 SPI-NOR flash 偏移0x200000开始就是kernel。

  - 用命令如：

    ```
    nand read 0x80000000 0x200000 0x800000
    ```

    - `nand read`：从NAND flash读
    - `0x80000000`：加载到RAM的0x80000000地址
    - `0x200000`：flash内偏移
    - `0x800000`：大小

  - 这种是“裸数据分区”，无文件名。

------

2. **U-Boot 如何决定“加载到RAM哪里”？**

- RAM加载地址**通常由U-Boot脚本、环境变量、板级配置或者Makefile设定**。

- 常见的环境变量：

  - `kernel_addr_r`（如 `0x80000000`）
  - `fdt_addr_r`（设备树加载地址）
  - `ramdisk_addr_r`

- 在 U-Boot 命令行/脚本里引用这些变量：

  ```
  fatload mmc 0:1 ${kernel_addr_r} zImage
  ```

- **这些变量可以在 U-Boot 编译配置文件（如 board-specific defconfig、include/configs/xxx.h），也可以在 runtime 通过环境变量设置。**

------

3. **这些信息在U-Boot源码哪里配置？**

**（1）板级头文件**

- 许多常用地址在 `include/configs/你的板子名.h` 文件中定义，例如：

  ```
  #define CONFIG_SYS_LOAD_ADDR        0x80000000
  #define CONFIG_KERNEL_ADDR_R        0x80000000
  #define CONFIG_FDT_ADDR_R           0x83000000
  #define CONFIG_RAMDISK_ADDR_R       0x88000000
  ```

- 这些宏在编译时生效，影响默认环境变量。

**（2）环境变量/启动脚本（uEnv.txt / boot.cmd / boot.scr）**

- 可以在 SD 卡、NAND 分区中存放环境变量脚本（如`bootcmd`），如：

  ```
  setenv bootcmd 'fatload mmc 0:1 ${kernel_addr_r} zImage; bootz ${kernel_addr_r} - ${fdt_addr_r}'
  ```

- 这些脚本常在量产镜像里自动配置。

**（3）U-Boot命令行临时手动指定**

- 可以直接在U-Boot命令行手动运行命令：

  ```
  fatload mmc 0:1 0x80000000 zImage
  ```

------

4. **你可以通过 U-Boot 命令 `printenv` 查看当前环境变量**

- 比如：

  ```
  => printenv kernel_addr_r
  kernel_addr_r=0x80000000
  ```

------

5. **总结归纳**

- **内核在哪里找，怎么加载到RAM，加载到哪**，全由U-Boot配置决定。
- 一般来说：
  - **找的方式**：文件名（需有文件系统） 或 固定偏移（原始分区）。
  - **加载地址**：通过环境变量/头文件/命令行指定。
  - **U-Boot启动脚本** 决定整个启动流程。
- **你板子的U-Boot源码目录下 configs、include/configs/ 下的头文件，以及分区里的uEnv.txt、boot.cmd，就是这些“入口”。**



## 问题4  既然是内核将文件系统从flash挂载到ram上，那么如何配置，从哪里找以及加载到哪里？

**内核通过驱动访问flash上的文件系统，用户操作文件时按需读取一部分到ram中**（利用页缓存等机制）



**常见的 rootfs（如 ext4，squashfs，jffs2 等）加载方式**

**加载流程与配置**

**A. 内核怎么知道“从哪里加载rootfs”？**

- **启动参数（bootargs）中的`root=`指定了根文件系统的位置。**

  - 例如：

    ```
    root=/dev/mmcblk0p2         # SD卡第二分区
    root=/dev/nandc             # NAND的某个分区
    root=/dev/mtdblock4         # MTD块设备
    root=LABEL=rootfs           # 按标签挂载
    root=PARTUUID=xxxx-xxxx     # 按UUID挂载
    ```

- 这些参数**由U-Boot在启动时传递**，通过环境变量配置。例如：

  ```
  setenv bootargs "console=ttyS0,115200 root=/dev/mmcblk0p2 rootfstype=ext4 rw"
  bootz ${kernel_addr_r} - ${fdt_addr_r}
  ```

**B. 内核怎么“加载”文件系统？**

- 内核启动后会**初始化块设备驱动、MTD驱动等**，通过`root=`参数去挂载指定的设备为`/`根文件系统。
- 这不是“整体加载到RAM”，而是：**内核访问flash的某个分区，将其作为根文件系统，每次你操作文件才把一小部分读入RAM**（比如用ext4、squashfs、jffs2、ubifs等）。
- 内核中的页缓存（page cache）会自动管理哪些内容常驻RAM，加速访问。

**C. 挂载点在哪里？**

- 总是**挂载为 `/` 根目录**。
- 用户空间进程看到的 `/etc /bin /usr` 等，其实都在flash的这个分区上，只是通过内核驱动“虚拟成”内存里的样子，实际上数据还是在flash中。



 **总结：配置方法和流程**

**最常见的配置流程如下：**

**（1）制作rootfs镜像**

- 用ext4、squashfs、jffs2等工具制作一个完整的根文件系统镜像，烧录到指定分区。

**（2）U-Boot设置启动参数**

- 通过bootargs（通常是setenv命令）配置rootfs的挂载位置，比如

  ```
  setenv bootargs "root=/dev/mmcblk0p2 rootfstype=ext4 rw"
  ```

- 也可以写到环境变量脚本或uEnv.txt、boot.cmd等文件。

**（3）内核挂载过程**

- 启动时自动挂载为`/`，不是整体加载，只是访问文件时从flash读取数据到RAM。

------

**举个完整例子：SD卡启动的嵌入式Linux**

- 分区表：

  ```
  mmcblk0p1   FAT32    /boot       （内核zImage, dtb等）
  mmcblk0p2   ext4     /           （rootfs）
  ```

- U-Boot命令/脚本:

  ```
  setenv bootargs "console=ttyS0,115200 root=/dev/mmcblk0p2 rootfstype=ext4 rw"
  fatload mmc 0:1 ${kernel_addr_r} zImage
  fatload mmc 0:1 ${fdt_addr_r} xxx.dtb
  bootz ${kernel_addr_r} - ${fdt_addr_r}
  ```

- 启动后 `/` 就是你烧录进 mmcblk0p2 里的ext4 rootfs内容，文件按需读入RAM。



## 问题5：内核和文件系统是否可以存在同一个分区？



1. **嵌入式Linux主流做法（通常是分开分区）**

- **绝大多数嵌入式板卡、量产固件，内核（zImage/Image）和根文件系统（rootfs）都存在不同的分区：**

  - 这样有利于升级、分区管理和容错。

  - 例如：

    ```
    mmcblk0p1  FAT32    /boot      (内核、设备树、可能还有U-Boot、ramdisk)
    mmcblk0p2  ext4     /          (根文件系统)
    ```

    启动时U-Boot从p1加载zImage、dtb到RAM，然后内核挂载p2为/。

------

2. **PC/服务器通用Linux（常在同一分区）**

- **x86/桌面/服务器Linux（比如Ubuntu、Debian）通常只有一个分区，内核和rootfs同在此分区：**
  - `/boot` 目录下存放内核（vmlinuz、initrd、dtb等），根文件系统同分区下的其他目录如 `/etc /usr /lib`。
  - 文件系统类型通常是ext4、xfs等。

------

3. **为什么嵌入式常常分开？**

- **分区更灵活、更安全**。升级rootfs不会影响内核，升级内核不影响用户数据。
- 支持多系统/备份分区/故障恢复（A/B分区方案）。

------

4. **也有特殊情况，内核和rootfs在同一分区**

- 有些精简系统、开发阶段、测试镜像，为了简单，**把内核和文件系统都放在同一分区**（比如单分区img镜像，所有内容都在一起）。
- 或者只有一个大分区，/boot、/ 都在一起，U-Boot/extlinux都能读。

------

5. **实际使用时如何决定？**

- **嵌入式正式产品/量产系统**：一般都会分区分开，方便维护和升级。
- **开发板/桌面系统**：可以在一个分区里，方便部署。

------

**总结表格：**

| 场景        | 分区结构      | 内核与文件系统位置              |
| ----------- | ------------- | ------------------------------- |
| 嵌入式常规  | 分区分开      | /boot 分区存内核，/分区存rootfs |
| 桌面/服务器 | 单分区/可分区 | /boot目录与rootfs在同一分区     |
| 精简系统    | 单分区        | 全部内容都在同一个分区          |



## 问题6：分区表的概念

1. **分区表是什么？**

- **分区表（Partition Table）**就是一张“存储空间地图”，**描述了一个存储设备（比如SD卡、eMMC、硬盘）被分成了哪些区域（分区）、每个分区的起止位置和用途**。
- 有了分区表，操作系统、bootloader等才能知道每个分区存放的是什么内容（比如 bootloader、内核、rootfs、数据区等），并正确地访问和管理它们。

------

2. **分区表的作用**

- 把一个大的物理存储（比如16GB的SD卡），**切分成若干“分区”**，每个分区可以有不同的文件系统、用途和权限。
- 操作系统和bootloader根据分区表“找分区、找文件”，实现升级、备份、安全、权限隔离等功能。

------

3. **常见的分区表类型**

（1）MBR（Master Boot Record，主引导记录）

- 最古老、最广泛的分区表类型，适合不超过2TB的存储设备。
- **MBR位于存储设备的第一个扇区（LBA0），前446字节是引导代码，接着64字节描述最多4个主分区。**
- **局限：**每个分区最大2TB，最多4个主分区（或3主分区+1扩展分区）。

（2）GPT（GUID Partition Table，全球唯一分区表）

- 新一代分区表标准（UEFI），突破MBR限制，支持更大容量、更多分区。
- **GPT分区表存放在磁盘前后，允许128个分区（或更多），每个分区都用GUID唯一标识。**
- 更安全（有备份表、CRC校验），大容量设备首选。

（3）自定义分区（嵌入式专用）

- 有些嵌入式平台（如MTD/UBI分区、裸flash）不用标准MBR/GPT分区表，而是通过分区配置（如`mtdparts`字符串、分区表文件）告诉内核/bootloader各分区的起止位置和类型。



4. **举例说明**

**一个标准SD卡（用MBR分区）分区表：**

```
sql复制编辑|--------|---------------------|--------------------|--------------------|
| 分区号 | 起始扇区            | 分区大小           | 用途               |
|--------|---------------------|--------------------|--------------------|
|   1    | 2048 (1MB)          | 256MB              | boot (FAT32)       |
|   2    | 526336              | 15GB               | rootfs (ext4)      |
|   3    | ...                 | ...                | data/user (ext4)   |
|--------|---------------------|--------------------|--------------------|
```

- 第一个分区：放内核、dtb、u-boot等启动文件。
- 第二个分区：放根文件系统。
- 第三个分区：数据存储区。



**嵌入式MTD分区表示例**

- 有些NAND/NOR flash没有标准分区表，用`mtdparts`参数配置：

  ```
  mtdparts=nand0:1M(bootloader),5M(kernel),16M(rootfs),-(data)
  ```

- 各分区按偏移、大小划分，内核、bootloader、应用各用一块。

------

5. **怎么查看和编辑分区表？**

- Linux下可以用 `fdisk -l`、`lsblk`、`parted`、`gdisk` 查看分区表和分区信息。
- 嵌入式开发时，经常用厂商工具、命令行脚本、烧录镜像配置分区表。

------

6. **分区表的物理结构**

- **MBR**：第一个扇区（512字节），前面是启动代码，后面4个主分区描述。
- **GPT**：第一个扇区是保护MBR，后面多个扇区是分区头和分区项。

------

总结

- **分区表就是告诉系统/bootloader：“哪些区域分别做什么用，起始和大小是多少”**
- 没有分区表，存储空间就是“一片大空地”，系统无法定位“地块”存放了什么内容！