# RV1126 Debug日志

## 一、GC2155启动失败

```sh
[    6.489080] rockchip-pinctrl pinctrl: pin gpio3-6 already requested by ff5a0000.serial; cannot claim for 1-003c
[    6.489152] rockchip-pinctrl pinctrl: pin-102 (1-003c) status -22
[    6.489186] rockchip-pinctrl pinctrl: could not request pin 102 (gpio3-6) from group cif_m0_VOCs_16bit  on device rockchip-pinctrl
[    6.489228] gc2155 1-003c: Error applying setting, reverse things back
[    6.489290] gc2155: probe of 1-003c failed with error -22
```

&emsp;&emsp;关键点`gpio3-6 already requested by ff5a0000.serial`，我们计算出来`gpio3-6`或`pin-102`对应`GPIO3 PA6`，查找到在设备树中，被`UART5`占用：

```c
&uart5 {
	pinctrl-0 = <&uart5m0_xfer>;
	dma-names = "tx","rx";
	status = "okay";
};
```

这里我们将其`disable`：

```c
&uart5 {
	pinctrl-0 = <&uart5m0_xfer>;
	dma-names = "tx","rx";
	// status = "okay";
	status = "disable";
};
```