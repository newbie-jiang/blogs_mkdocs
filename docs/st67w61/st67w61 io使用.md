![image-20250802221930169](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250802221930169.png)

用户必须确保 JP1 和 JP2 保持关闭状态。 以下列出了该插销的描述：

 CHIP_EN 引脚被置高以启动 ST67W611M1 设备。

 当需要向 ST67W611M1 设备加载新的二进制文件时，BOOT 引脚会被激活。 

SPI_CLK、SPI_MISO 和 SPI_MOSI 引脚用于数据通信。 

SPI_RDY 引脚由 ST67W611M1 控制激活，以此向主机请求 SPI 时钟。

SPL CS 引脚由主机使用来唤醒 ST67W611M1 设备。

UART 发送端和 UART 接收端用于同时对 ST67W611M1 进行加载操作以及进行射频测试（生产模式）。





## AT32f437接口

