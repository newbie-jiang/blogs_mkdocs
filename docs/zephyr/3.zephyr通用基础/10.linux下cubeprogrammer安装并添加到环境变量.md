# linux下cube Programmer安装并添加到环境变量

下载压缩包 stm32cubeprg-lin-v2-20-0.zip

解压后

![image-20250801202339987](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250801202339987.png)

## 给权限

```
sudo chmod 775 SetupSTM32CubeProgrammer-2.20.0.linux
sudo chmod 775 -R jre
```



## 安装

```
sudo ./SetupSTM32CubeProgrammer-2.20.0.linux
```

**一路安装选 1 或者 Y ,环境变量设置直接回车，默认路径**

```
/usr/local/STMicroelectronics/STM32Cube/STM32CubeProgrammer/
```

## 验证是否安装成功

```
/usr/local/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/STM32_Programmer_CLI --version
```



## 添加到用户的环境变量（永久添加）

每个用户都有的环境变量配置文件

```
~/.bashrc
```

![image-20250801203115992](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250801203115992.png)

编辑 `~/.bashrc` 文件，在末尾加一行：

```
export PATH=$PATH:/usr/local/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin
```

然后**使其生效**：

```
source ~/.bashrc
```



新打开一个终端，验证

```
STM32_Programmer_CLI --version
```

![image-20250801203332686](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250801203332686.png)
