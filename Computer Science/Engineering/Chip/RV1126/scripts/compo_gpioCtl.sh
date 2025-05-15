#!/bin/bash

cat /sys/kernel/debug/pinctrl/pinctrl-rockchip-pinctrl/pinmux-pins

# VI_EN GPIO3_A7
echo 103 > /sys/class/gpio/export
# output
echo out > /sys/class/gpio/gpio103/direction
# high
echo 1 > /sys/class/gpio/gpio103/value
# low
echo 0 > /sys/class/gpio/gpio103/value

# VI_IN1 GPIO3_B0
echo 104 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio104/direction
echo 1 > /sys/class/gpio/gpio104/value
echo 0 > /sys/class/gpio/gpio104/value

# VI_IN1 GPIO3_B1
echo 105 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio105/direction
echo 1 > /sys/class/gpio/gpio105/value
echo 0 > /sys/class/gpio/gpio105/value