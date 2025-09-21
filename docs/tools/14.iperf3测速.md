**Windows** 和 **Ubuntu** 都可以运行 `iperf3`，下面是详细操作步骤：

------

## 一、准备工作

### 1. **Windows 上安装 iperf3**

- 下载 Windows 版 iperf3   https://iperf.fr/iperf-download.php#windows
- 解压后，得到 `iperf3.exe`，比如放在 `D:\iperf3\` 目录下。
- 打开“命令提示符”窗口（Win+R 输入 `cmd`）。

### 2. **Ubuntu 上安装 iperf3**

```
sudo apt update
sudo apt install iperf3
```

------

## 二、测试流程

假设：

- **Windows 作为客户端**（你操作的本机，测速入口）
- **Ubuntu 作为服务器**（一直监听，等你连接）

### 1. **在 Ubuntu 上运行 iperf3 服务端**

```
iperf3 -s
```

运行后会看到“Server listening on 5201”。

### 2. **在 Windows 上运行客户端**

- 假设 Ubuntu 的局域网 IP 是 `192.168.0.99`（可以用 `ifconfig` 或 `ip a` 查到）。

- 在 Windows 的命令行里进入 `iperf3.exe` 所在目录：

  ```
  cd D:\iperf3
  ```

- 测试“上传速度”（Windows → Ubuntu）:

  ```
  iperf3.exe -c 192.168.0.99
  ```

  > **注意**：`-c` 后面跟的是 Ubuntu 的 IP 地址。

- 测试“下载速度”（Ubuntu → Windows）:

  ```
  iperf3.exe -c 192.168.0.99 -R
  ```

------

## 三、结果解读

- 运行完后，会看到如下结尾输出：

  ```
  matlab复制编辑[ ID] Interval           Transfer     Bandwidth
  [  5]   0.00-10.00 sec   1.10 GBytes   944 Mbits/sec  sender
  [  5]   0.00-10.00 sec   1.10 GBytes   944 Mbits/sec  receiver
  ```

- `944 Mbits/sec` 就是两台设备间的真实传输带宽。