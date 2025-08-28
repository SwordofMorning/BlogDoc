#!/bin/sh

#################### Part III: load8x9 ####################

/etc/load8x9.sh -i -sensor0 bg1336

sleep 1

devmem 0x0d254014 32 0x000AA320
devmem 0x0d254114 32 0x000AA320

echo "vii_dev_dump=1" > /proc/vssdk/vii

#################### Part IV: BG1336 Pwron ####################

# GPIO50, 1v8
echo 466 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio466/direction
echo 1 > /sys/class/gpio/gpio466/value

# GPIO65, RST
echo 417 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio417/direction
echo 1 > /sys/class/gpio/gpio417/value

# GPIO51, 3v3
echo 467 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio467/direction
echo 1 > /sys/class/gpio/gpio467/value

# GPIO0, 2v8
echo 480 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio480/direction
devmem 0x0ce1c1f0 32 0x01885301
echo 1 > /sys/class/gpio/gpio480/value

# GPIO47, ULLC_STDBY
echo 463 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio463/direction
echo 0 > /sys/class/gpio/gpio463/value