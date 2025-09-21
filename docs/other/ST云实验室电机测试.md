## ST云实验室电机评测

链接地址：https://livebench.tenxerlabs.com/app/motor_control_foc_sdk

基于STM32G4、STDRIVE101、STL90N10F7的永磁同步电机的磁场定向控制评估套件 概述

![image-20250701191710579](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250701191710579.png)



可以看到此云平台实际上是一套自动化流程，当登录用户点击PLUG IN 时，控制所有设备上电

- 点击连接后，设备上电，需要等待一会儿 设备启动完成，日志查看是否启动完成

  ![image-20250701200104863](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250701200104863.png)

![image-20250701200203789](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250701200203789.png)

界面展示

- 进程日志
- 示波器
- cli
- 视频直播
- 热图
- 相电流(被测电机)
- 电源

![image-20250701200315835](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250701200315835.png)

![image-20250701200402310](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250701200402310.png)

- 点击connect 连接上位机进行控制

![image-20250701200457379](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250701200457379.png)

- 成功连接上了，如下

![image-20250701200537455](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250701200537455.png)

- 设置目标转速启动电机

![image-20250701200736454](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250701200736454.png)

![image-20250701200849376](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250701200849376.png)

测量电机的电流

![image-20250701201242695](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250701201242695.png)

![image-20250701201339945](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250701201339945.png)

- 跑一会儿应该可以看到热图变化，有几个发热点，（光标放在哪儿可测量哪儿的温度）
- 现在温度不是很高，转速才1500，最大转速可以4500，提高转速看看温度

![image-20250701201525019](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250701201525019.png)







简介

欢迎评估基于STM32G4、STDRIVE101、STL90N10F7的永磁同步电机的磁场定向控制套件。

本实验旨在通过矢量控制（FOC）控制永磁同步电机（PMSM），并评估STM32电机控制软件开发套件（MCSDK）。

本评估套件构建的基于STM32G4, STDRIVE101, STL90N10F7的永磁同步电机FOC控制平台，将两个完全一样的永磁同步电机耦合起来，一个作为加载电机，一个作为被测电机。其中，被测电机使用B-G473E-ZEST1S+STEVAL-LVLP01进行控制，加载电机使用EVALKIT-ROBOT-1套件。用户可以通过Motor Pilot(MCSDK v6.3.0的一部分)控制被测电机的启停和期望速度；通过CLI命令界面控制加载电机的启停和加载大小。这个过程中的电流、电压、热数据以及两个电机的状态都可以通过右侧的显示栏进行监控。

使用指南

1.Motor Pilot GUI 连接 - 点击“Connect”以建立硬件连接，并确认驱动板的连接状态。

2.启动电机 - 确认电机状态，并设置目标速度（最高4000 RPM），点击“Start”以启动电机，并监控实时参数。

3.图形数据 - 点击顶部图标 --> 右键添加相电流（I_A和I_B），并使用“snapshots” 截图保存数据。

4.调整负载电机的负载

更多有关电机控制界面的信息，请参考ST Motor Pilot GUI 用户指南。

https://tenxer-sw-download.s3.us-east-1.amazonaws.com/CE+Projects/STMicroelectronics+Designs/C-0154/Motor_Pilot_GUI_QUG.pdf

该文档提供了使用意法半导体电机先导GUI软件配置和控制PMSM FOC评估套件的快速演示，它提供了如何将GUI连接到硬件，配置电机速度，扭矩，电压和电流参数的逐步说明。
该指南有助于启动电机，如何使用GUI的功能在图形上绘图。

如下：

![image-20250701192051573](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250701192051573.png)![image-20250701192103771](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250701192103771.png)![image-20250701192122157](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250701192122157.png)![image-20250701192144120](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250701192144120.png)![image-20250701192216504](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250701192216504.png)![image-20250701192227675](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250701192227675.png)

