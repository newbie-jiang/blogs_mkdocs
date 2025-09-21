## nordic sdk安装  以及第一个测试程序





视频教程

https://www.youtube.com/watch?v=EAJdOqsL9m8&list=PLx_tBuQ_KSqEt7NK-H7Lu78lT2OijwIMl

doc

https://docs.nordicsemi.com/bundle/nrf-connect-vscode/page/get_started/quick_setup.html



## 1.安装命令行工具

https://www.nordicsemi.com/Products/Development-tools/nRF-Command-Line-Tools/Download?utm_campaign=Product%20Launches&utm_source=youtube&utm_medium=social&utm_content=Download%20nRF%20Command%20Line%20Tools

![image-20250804134717900](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250804134717900.png)

一路安装，最后可能要求安装j-link ,安装更新就行

## 2.在vscode中搜索nordic的扩展包并安装

![image-20250804135226408](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250804135226408.png)

##  3.手动安装sdk与工具链

- 这里可以选择安装最新版本，过程很慢
- 安装好默认在C盘ncs目录

![image-20250804135735742](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250804135735742.png)



## 4.安装 nrfutil

https://www.nordicsemi.com/Products/Development-tools/nRF-Util

下载一个nrfutil.exe 文件，直接添加到环境变量

- nRF Util`device `命令可以列出、编程、恢复、擦除以及对 Nordic 设备执行各种操作。它支持 MCUboot 和 J-Link。 



## 5.构建第一个应用程序

**以nrf52840-dk为例**

### 1.vscode打开sdk文件夹

![image-20250804203146025](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250804203146025.png)

### 2. 拷贝一个示例程序

![image-20250804203410509](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250804203410509.png)

**选择使用的sdk**

![image-20250804203510484](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250804203510484.png)

**输入要拷贝的示例并选择**

![image-20250804203642596](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250804203642596.png)

**输入要拷贝的路径作为工作目录**

- 输入好以后回车

![image-20250804203752045](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250804203752045.png)

### 3.打开拷贝好的示例工作目录

![image-20250804203829576](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250804203829576.png)

### 4. 添加编译配置项，编译，在此之前可以先打开一个终端查看编译过程

![image-20250804204811908](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250804204811908.png)



编译信息如下

```shell
 *  正在执行任务: nRF Connect: Generate config nrf52840dk/nrf52840 for c:\ncs\nrf52840\blinky 

Building blinky
C:\WINDOWS\system32\cmd.exe /d /s /c "west build --build-dir c:/ncs/nrf52840/blinky/build c:/ncs/nrf52840/blinky --pristine --board nrf52840dk/nrf52840 -- -DBOARD_ROOT=c:/ncs/nrf52840/blinky"

-- west build: generating a build system
Loading Zephyr module(s) (Zephyr base): sysbuild_default
-- Found Python3: C:/ncs/toolchains/0b393f9e1b/opt/bin/python.exe (found suitable version "3.12.4", minimum required is "3.10") found components: Interpreter 
-- Cache files will be written to: C:/ncs/v3.0.2/zephyr/.cache
-- Found west (found suitable version "1.2.0", minimum required is "0.14.0")
-- Board: nrf52840dk, qualifiers: nrf52840
Parsing C:/ncs/v3.0.2/zephyr/share/sysbuild/Kconfig
Loaded configuration 'C:/ncs/nrf52840/blinky/build/_sysbuild/empty.conf'
Merged configuration 'C:/ncs/nrf52840/blinky/build/_sysbuild/empty.conf'
Configuration saved to 'C:/ncs/nrf52840/blinky/build/zephyr/.config'
Kconfig header saved to 'C:/ncs/nrf52840/blinky/build/_sysbuild/autoconf.h'
-- 
   ****************************
   * Running CMake for blinky *
   ****************************

Loading Zephyr default modules (Zephyr base).
-- Application: C:/ncs/nrf52840/blinky
-- CMake version: 3.21.0
-- Found Python3: C:/ncs/toolchains/0b393f9e1b/opt/bin/python.exe (found suitable version "3.12.4", minimum required is "3.10") found components: Interpreter 
-- Cache files will be written to: C:/ncs/v3.0.2/zephyr/.cache
-- Zephyr version: 4.0.99 (C:/ncs/v3.0.2/zephyr)
-- Found west (found suitable version "1.2.0", minimum required is "0.14.0")
-- Board: nrf52840dk, qualifiers: nrf52840
-- Found host-tools: zephyr 0.17.0 (C:/ncs/toolchains/0b393f9e1b/opt/zephyr-sdk)
-- Found toolchain: zephyr 0.17.0 (C:/ncs/toolchains/0b393f9e1b/opt/zephyr-sdk)
-- Found Dtc: C:/ncs/toolchains/0b393f9e1b/opt/bin/dtc.exe (found suitable version "1.4.7", minimum required is "1.4.6") 
-- Found BOARD.dts: C:/ncs/v3.0.2/zephyr/boards/nordic/nrf52840dk/nrf52840dk_nrf52840.dts
-- Generated zephyr.dts: C:/ncs/nrf52840/blinky/build/blinky/zephyr/zephyr.dts
-- Generated pickled edt: C:/ncs/nrf52840/blinky/build/blinky/zephyr/edt.pickle
-- Generated zephyr.dts: C:/ncs/nrf52840/blinky/build/blinky/zephyr/zephyr.dts
-- Generated devicetree_generated.h: C:/ncs/nrf52840/blinky/build/blinky/zephyr/include/generated/zephyr/devicetree_generated.h
-- Including generated dts.cmake file: C:/ncs/nrf52840/blinky/build/blinky/zephyr/dts.cmake
Parsing C:/ncs/v3.0.2/zephyr/Kconfig
Loaded configuration 'C:/ncs/v3.0.2/zephyr/boards/nordic/nrf52840dk/nrf52840dk_nrf52840_defconfig'
Merged configuration 'C:/ncs/nrf52840/blinky/prj.conf'
Merged configuration 'C:/ncs/nrf52840/blinky/build/blinky/zephyr/.config.sysbuild'
Configuration saved to 'C:/ncs/nrf52840/blinky/build/blinky/zephyr/.config'
Kconfig header saved to 'C:/ncs/nrf52840/blinky/build/blinky/zephyr/include/generated/zephyr/autoconf.h'
-- Found GnuLd: c:/ncs/toolchains/0b393f9e1b/opt/zephyr-sdk/arm-zephyr-eabi/arm-zephyr-eabi/bin/ld.bfd.exe (found version "2.38") 
-- The C compiler identification is GNU 12.2.0
-- The CXX compiler identification is GNU 12.2.0
-- The ASM compiler identification is GNU
-- Found assembler: C:/ncs/toolchains/0b393f9e1b/opt/zephyr-sdk/arm-zephyr-eabi/bin/arm-zephyr-eabi-gcc.exe
-- Configuring done
-- Generating done
-- Build files have been written to: C:/ncs/nrf52840/blinky/build/blinky
-- Configuring done
-- Generating done
-- Build files have been written to: C:/ncs/nrf52840/blinky/build
-- west build: building application
[4/152] Generating include/generated/zephyr/version.h
-- Zephyr version: 4.0.99 (C:/ncs/v3.0.2/zephyr), build: v4.0.99-ncs1-2
[152/152] Linking C executable zephyr\zephyr.elf
Memory region         Used Size  Region Size  %age Used
           FLASH:       22012 B         1 MB      2.10%
             RAM:        7680 B       256 KB      2.93%
        IDT_LIST:          0 GB        32 KB      0.00%
Generating files from C:/ncs/nrf52840/blinky/build/blinky/zephyr/zephyr.elf for board: nrf52840dk
[10/10] Generating ../merged.hex
```

## 下载

![image-20250804205251343](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250804205251343.png)