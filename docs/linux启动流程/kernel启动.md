

**Linux内核在启动后，只会启动一个“第一个用户空间进程”——也就是`init`（通常是 `/sbin/init` 或 `/init`），**
 **后面所有的应用程序、服务、shell、后台守护进程，都是由`init`进程（或systemd、busybox init等）来负责启动和管理的。**

## 

1. **内核启动后发生了什么？**

- 内核初始化硬件、挂载根文件系统后，
- 会寻找一个可执行文件作为第一个用户空间进程。这个进程必须是：
  - `/sbin/init`
  - `/etc/init`
  - `/bin/init`
  - `/bin/sh`
  - 或者通过启动参数`init=/xxx`指定
     只要有一个能找到并运行，就当作第1号进程（PID 1）。

2. **init进程的作用是什么？**

- 这个`init`进程，是所有其它用户空间进程的祖先、父亲、控制者。
- 它**按照配置（比如`/etc/inittab`、`/etc/init.d/`、systemd的unit文件等），**决定启动哪些应用程序、后台服务、登录shell等。
- **它可以启动和管理任意多个应用程序（进程），并可以对它们进行监控、重启等管理。**

3. **实际表现**

- 内核：只负责“拉起第一个进程”。
- `init`：根据配置批量启动shell、web服务器、后台守护进程、你的App等，系统里就会有很多进程和服务。

------

**举例说明**

**嵌入式极简系统（init就是你自己的程序）**

- 你把自己的应用编译成`/init`，其他什么都没有。
- 系统启动后，只运行你的程序。

**正常Linux系统**

- `init`会按照配置自动启动：
  - `getty`（串口/终端登录shell）
  - `sshd`（远程登录服务）
  - `cron`（定时任务）
  - `dbus`、`networkd`、`udevd`等
  - 你自己的app

------

**小结**

- **内核本身不会主动启动多个应用。它“启动第一个进程init”，之后所有进程的启动和管理全交给init。**
- **init才是用户空间所有进程的“祖宗”，决定了整个系统“跑什么程序”。**





## 在我自己的ubuntu上如何找到第一个进程，以及如何知道第一个进程之后启动默认会启动什么？

1. **如何找到第一个进程？**

- **第一个进程的特点是：PID（进程号）为1。**
- 在现代Ubuntu（比如18.04/20.04/22.04/24.04），**PID 1 通常是 `systemd` 进程**（更早以前是 `/sbin/init`）。

你可以直接在终端执行：

```
ps -p 1 -o pid,ppid,user,comm,args
```

```
hdj@hdj-virtual-machine:~$ ps -p 1 -o pid,ppid,user,comm,args
    PID    PPID USER     COMMAND         COMMAND
      1       0 root     systemd         /sbin/init auto noprompt splash

```

说明PID 1是systemd（即`/sbin/init`的软链接），用户是root，父进程是0（内核）。

2. **如何知道init（第一个进程）之后会默认启动什么？**

- 在Ubuntu、Debian等现代Linux，**init其实就是systemd**，它通过一堆“unit文件”决定系统服务的启动顺序和内容。
- **systemd的配置和服务管理都集中在 `/etc/systemd/` 以及 `/lib/systemd/` 下面**。

2.1 查看所有自启动的服务（显示所有服务的开机启动状态）

```
systemctl list-unit-files --type=service
```

```
hdj@hdj-virtual-machine:~$ systemctl list-unit-files --type=service
UNIT FILE                                  STATE           VENDOR PRESET
accounts-daemon.service                    enabled         enabled      
acpid.service                              disabled        enabled      
alsa-restore.service                       static          -            
alsa-state.service                         static          -            
alsa-utils.service                         masked          enabled      
anacron.service                            enabled         enabled      
app.service                                enabled         enabled      
apparmor.service                           enabled         enabled      
apport-autoreport.service                  static          -            
apport-forward@.service                    static          -            
apport.service                             generated       -            
apt-daily-upgrade.service                  static          -            
apt-daily.service                          static          -            
apt-news.service                           static          -            
autovt@.service                            alias           -            
avahi-daemon.service                       enabled         enabled      
binfmt-support.service                     enabled         enabled      
bluetooth.service                          enabled         enabled      
bolt.service                               static          -            
brltty-udev.service                        static          -            
brltty.service                             disabled        enabled      
bt.service                                 generated       -            
colord.service                             static          -            
configure-printer@.service                 static          -            
console-getty.service                      disabled        disabled     
console-setup.service                      enabled         enabled      
container-getty@.service                   static          -            
cron.service                               enabled         enabled      
cryptdisks-early.service                   masked          enabled      
cryptdisks.service                         masked          enabled      
cups-browsed.service                       enabled         enabled      
cups.service                               enabled         enabled      
dbus-fi.w1.wpa_supplicant1.service         alias           -            
dbus-org.bluez.service                     alias           -            
dbus-org.freedesktop.Avahi.service         alias           -            
dbus-org.freedesktop.hostname1.service     alias           -            
dbus-org.freedesktop.locale1.service       alias           -            
dbus-org.freedesktop.login1.service        alias           -            

```

2.2 查看当前正在运行的所有服务

```
systemctl
```

或者

```
systemctl list-units --type=service
```

2.3 查看默认会启动什么（开机时自动启动的服务/目标）

```
systemctl get-default
```

输出一般是 `graphical.target`（桌面） 或 `multi-user.target`（命令行多用户）。

可以用下面命令**查看这个target会启动哪些服务**：

```
systemctl list-dependencies default.target
```

或者

```
systemctl list-dependencies multi-user.target
```

------

3. **systemd配置文件在哪？**

- 系统自带服务配置：`/lib/systemd/system/`
- 用户或自定义服务配置：`/etc/systemd/system/`
- 你可以用 `cat` 或 `less` 查看这些目录下的 `.service` 文件内容，了解每个服务如何启动的。

------

4. **验证init进程之后启动了什么？**

- 你可以查看系统的启动日志：

```
journalctl -b
```

- 这个命令会显示自上次启动以来systemd管理的所有服务启动过程。

------

**总结**

- Ubuntu下，第一个进程（PID 1）几乎总是 `systemd`。
- systemd读取配置（unit文件），自动启动各种服务和目标（target），这些决定了系统启动后有哪些进程和服务。
- 你可以用 `ps -p 1`、`systemctl`、`journalctl -b` 等命令观察和分析系统启动流程。



## 如何查看自己开发板的 init 系统

，**嵌入式开发板的“初始化系统”和启动配置方式有多种**，并不是所有的嵌入式Linux都还用 `/etc/inittab`。能不能用、用不用，**取决于用的是什么 init 系统**。下面详细分情况解释：

1. **嵌入式开发板常见的 init 系统**

**A. busybox init（常用在极简嵌入式系统）**

- **busybox** 提供了极简的 `init` 实现，**依然支持 `/etc/inittab` 配置文件**。
- 在很多基于 busybox 的系统（如 OpenWRT、buildroot 默认配置、老的Yocto镜像）上，你会看到 `/etc/inittab` 决定了系统启动流程和后台进程。
- 适合资源有限、功能简单的嵌入式产品和开发板。

**B. sysvinit（早期Linux常用）**

- 比较重型的嵌入式Linux，也可能用传统 SysV init，这时也会用 `/etc/inittab`，但这种已经在主流桌面/服务器被淘汰。

**C. systemd/upstart（现代复杂系统、性能充裕的开发板）**

- 许多较新的开发板（比如基于 Ubuntu/Debian/Yocto 的 ARM 开发板，或树莓派等）**已经用上了 systemd**，此时 `/etc/inittab` 不再起作用。
- 系统启动流程和服务自启都通过 systemd 的 unit 文件控制。

------

2. **怎么判断你的开发板/固件用的是哪种 init？**

- **查看 `/sbin/init` 或 `/init` 是谁：**

  ```
  ls -l /sbin/init
  ps -p 1 -o comm,args
  ```

  - 如果显示 `init [busybox]` 或 `init [sysv]`，一般支持 `/etc/inittab`
  - 如果是 `systemd`，那一定没有 `/etc/inittab` 的用武之地。

- **查看文件是否存在：**

  ```
  ls /etc/inittab
  ```

  - 有并且内容丰富，十有八九在用。
  - 没有，基本就是 systemd 或别的init系统。

- **查看发行版文档/构建脚本/Yocto/Buildroot配置：**

  - busybox 默认用 `/etc/inittab`，除非你配置了别的 init。

------

3. **实际举例：**

**OpenWRT、Buildroot、极简Busybox根文件系统**

- **默认都用 busybox init + /etc/inittab**。
- 你可以通过修改 `/etc/inittab`，让系统自动运行你的程序、管理串口shell、守护进程等。

**树莓派官方Debian/Ubuntu、NXP官方Yocto、全志/瑞芯微最新SDK**

- **大多已经默认 systemd**，用 unit 文件启动服务，和桌面Linux一致。
- `/etc/inittab` 可能根本不存在。

------

4. **结论：**

- **在“精简嵌入式系统”中，busybox init + `/etc/inittab` 仍然很常见，是配置启动流程和后台进程的核心方式。**
- **但在越来越多的“高性能/新型嵌入式系统”里，已经用 systemd/upstart 等现代init替代了inittab。**
- **是否用 `/etc/inittab`，关键看用的是什么 init 系统。**



