[toc]

## 一、经历

### 1.1 教育

1. 学士：西南科技大学 - 软件工程

### 1.2 工作

#### 1.德阳红外科技创新中心有限公司

&emsp;&emsp;2022.03 - 2024.07

&emsp;&emsp;嵌入式Linux系统工程师，负责嵌入式设备GNU/Linux和Android/Linux系统开发。

1. SoC选型；
2. 系统移植；
3. 驱动开发；
4. Linux应用程序开发；
5. Android应用程序开发；
6. Windows应用程序开发；
7. 图像处理与机器学习应用开发。

### 1.3 项目

#### 1.微型手持式近红外光谱仪

&emsp;&emsp;2022.03 - 2023.09

&emsp;&emsp;该项目为手持式微型光谱仪的研发。对于软件部分来说主要是对芯片的系统开发，芯片选用全志F1C100S。

其中：

1. 系统为Uboot + Kernel 5.20 + Buildroot，均为自行构建；
2. 芯片通过ADC读取光强度数据，ADC为ADS1110，通信协议为I2C；
3. 光谱仪带有一个5寸屏幕，接口为标准40pin RGB接口；交互通过触摸屏实现，驱动芯片为GT911，协议同样为I2C；
4. 应用程序使用C编写，UI界面为LVGL。

我主要负责的是：

1. 系统的移植与驱动适配；
2. 应用程序的开发；
3. 针对光谱数据的机器学习应用，例如：测量农残、水果甜度和布料分类等。

#### 2.手持式红外成像仪

&emsp;&emsp;2022.06 - 2023.09

&emsp;&emsp;该项目为手持式热成像仪的研发。选用的探测器包含国产与进口多种型号，FPGA选用Intel Altera系列产品，SoC为瑞星微RK3568。

其中：

1. 系统使用Kernel 4.19 + Buildroot，基于RK的SDK二次开发；
2. 探测器与FPGA的连接使用DVP或LVDS协议；
3. FPGA与SoC之间的协议采用DVP协议；
4. 热像仪有一块3.8寸单口LVDS屏幕，一块0.49寸EVF取景器，同时支持HDMI投屏，可以实现三屏同显；
5. 应用程序使用C/C++编写，视频接口使用V4L2，图像处理使用OpenCV，视频流编码使用FFmpeg和Gstreamer，UI界面使用LVGL。

我主要负责的是：

1. 根据SDK进行系统的剪裁与修改；
2. Linux驱动开发；
3. Linux应用程序开发；
4. OpenCV、FFmpeg的移植与配置。

#### 3.VOCs气体检漏红外热像仪

&emsp;&emsp;2023.09 - 2024.07

&emsp;&emsp;该项目为VOCs气体成像仪的研发。探测器选用瑞典IRNova的系列产品、SoC选用紫光展锐T820、FPGA选型为高云GW5A。

其中：

1. 系统使用Android13，基于紫光展锐官方的SDK进行二次开发；
2. 探测器与FPGA之间的连接使用CameraLink协议；
3. FPGA与SoC之间的连接使用MIPI-CSI协议；
4. 成像仪带有一块5.5寸OLED屏幕和一块0.49寸EVF取景器，二者使用相同的驱动芯片，可以实现双屏同显；
5. 热像仪带有一个全功能Type-C USB3.0，支持PD快充、DP协议投屏等功能；
6. 因为紫光展锐架构设计的原因，应用层的软件通过修改紫光展锐SDK中的默认相机的源代码（Dream Camera）得到。

我主要负责的是：

1. Android系统开发，包括摄像头（FPGA）、屏幕和其他芯片驱动开发（例如电源管理芯片）；
2. Android应用程序开发；
3. MIPI-CSI的物理层协议解析，与FPGA参数、时序校订；
4. 图像算法接口的配置，以及数据处理工作。

### 1.4 技术栈

1. **C/C++**: Linux Driver, Application and Windows Application;
2. **Java**: Android Application;
3. **MATLAB/Python**: Computer Vision, Machine Learning.

## 二、与我联系

<p align="center">

<a href="mailto:master@xiaojintao.email
"><img alt="Email" src="https://img.shields.io/badge/Email-master@xiaojintao.email-blue?style=flat-square&logo=gmail"></a>

<a href="https://github.com/SwordofMorning"><img alt="Website" src="https://img.shields.io/badge/Github-SwordofMorning-blue?style=flat-square&logo=google-chrome"></a>

</p>