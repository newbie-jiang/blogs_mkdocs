

```
Connecting to Local Access Point
Connected to following Access Point :
[cc:29:bd:d7:ae:71] Channel: 8 | RSSI: -51 | SSID: ZTE-45c476
App connected
[ERROR] [11913] [defaultTsk] (w61_at_sys.c:664) W61_AT_Query: W61_STATUS_TIMEOUT (no status). It can lead to unexpected behavior
[ERROR] [11913] [defaultTsk] (main_app.c:499) [TIMEOUT] in W6X_FS_GetSizeFile API
[ERROR] [11936] [defaultTsk] (w6x_sys.c:292) File not found in the Host LFS. Verify the filename and littlefs.bin generation
```

deepseek请求时会提示找不到证书，证书一般放在st67w61的固件里面

x-cube-st67w61\Projects\ST67W6X_Utilities\LittleFS\Certificates\lfs

![image-20250803010610328](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250803010610328.png)



- `.crt`（Certificate，证书文件）
- `.key`（Private Key，私钥文件）

在此处添加deepseek的证书

## **详细说明**

### **1. DeepSeek 官方 API 是什么模式？**

- DeepSeek、OpenAI、百度、Weather API 等大部分云服务，都是**标准单向认证 HTTPS**。
- 你的设备/PC/浏览器发起 HTTPS 请求时，**只校验服务端身份（即 DeepSeek 的服务器证书链），不需要客户端提供自己的证书或私钥**。

------

### **2. 什么时候才需要私钥？**

- 只有**“双向认证/客户端证书认证”**（如部分 MQTT 物联网云平台、银行安全接口）才要求设备必须有 `.key` 和 `.crt`（客户端证书+私钥）。
- DeepSeek 这种 SaaS API，**只用 API Key 鉴权，不需要私钥文件**。

## **再举例说明**

| 场景                    | 需不需要 .key 文件（私钥） | 说明                              |
| ----------------------- | -------------------------- | --------------------------------- |
| DeepSeek/OpenAI API     | ❌ 不需要                   | 只要服务器证书（crt），用 API Key |
| 阿里云 MQTT（双向认证） | ✅ 需要                     | 设备用自己的 crt + key 文件       |
| 你本地 HTTPS 服务器     | ❌ 不需要                   | 默认只要 crt，客户端只做校验      |



## **一、用 openssl 命令一键导出 DeepSeek 证书**

在 Linux/Mac/WSL/Windows（装了 openssl 的 git-bash/cygwin/msys2 也行）运行：

```
echo | openssl s_client -showcerts -connect api.deepseek.com:443
```

会看到很多证书段，例如：

```
CONNECTED(000001AC)
...
---
Certificate chain
 0 s:CN = api.deepseek.com
   i:C = US, O = Let's Encrypt, CN = R3
-----BEGIN CERTIFICATE-----
MIIG...
...很多行...
-----END CERTIFICATE-----
...
---
```

通常**最后一个 `-----BEGIN CERTIFICATE-----` 到 `-----END CERTIFICATE-----`**为“根证书”或“中间证书”。

------

### **快速导出最常用的“R3”根证书或“ISRG Root X1”**

用一条命令自动保存：

```
openssl s_client -showcerts -connect api.deepseek.com:443 </dev/null 2>/dev/null \
| awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/' > deepseek.crt
```

这样保存的就是 PEM 格式证书文件（deepseek.crt），可以直接用作 MCU 侧 TLS 校验。

------

## **二、用浏览器导出证书（适合 Windows）**

1. 用 Chrome/Edge/Firefox 打开 https://api.deepseek.com
2. 点击地址栏的小锁 > 连接安全 > 证书有效 > 证书路径
3. 选中最上层（一般为“ISRG Root X1”或“DST Root CA”），点击“查看证书”
4. 点击“详细信息” > “复制到文件” > 选择“Base-64编码X.509(.CER)”
    保存为 deepseek.crt



## 此处我使用第二种

浏览器输入

```
https://api.deepseek.com/v1/chat/completions
```

F12

![image-20250803124432164](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250803124432164.png)

![image-20250803012604779](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250803012604779.png)

Base64 编码 ASCII，单一证书 (*.pem;*.crt)

保存到此目录下并重命名

![image-20250803012911499](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250803012911499.png)

点击执行脚本重新生成littlefs固件

![image-20250803013108224](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250803013108224.png)

按照重新烧录到st67w61就好了



