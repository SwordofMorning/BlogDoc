#!/bin/sh

#GPIO67, PANEL RST, GPIO419
echo 419 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio419/direction
# devmem 0x0ce1c0d8
devmem 0x0ce1c0d8 32 0x00086300
echo 1 > /sys/class/gpio/gpio419/value
echo 0 > /sys/class/gpio/gpio419/value
echo 1 > /sys/class/gpio/gpio419/value

# GPIO77
# SPI1_SCLK
devmem 0x0ce1c0b0 32 0x00037301

# GPIO78
# SPI1_SDO
devmem 0x0ce1c0a8 32 0x00037301

# GPIO80
# SPI1_SDI
devmem 0x0ce1c0a4 32 0x00037301

# GPIO78
devmem 0x0ce1c0ac 32 0x00037305
# SPI1_CSN
# devmem 0x0ce1c0ac 32 0x00037301

# SPI IO Swap
# devmem 0x0ce1c1f4
# default
# devmem 0x0ce1c1f4 32 0x000002A8
# devmem 0x0ce1c1f4 32 0x000102A8