#!/bin/sh

##### Part I: USB #####

insmod /lib/modules/libcomposite.ko
insmod /lib/modules/u_ether.ko 
insmod /lib/modules/usb_f_rndis.ko 
insmod /lib/modules/usb_f_ecm.ko 
insmod /lib/modules/g_ether.ko 

ifconfig usb0 169.254.43.1 netmask 255.255.0.0 up
route add default gw 169.254.43.10

##### Part II: Telnet & SSH #####

mkdir /dev/pts; mount -t devpts none /dev/pts;
telnetd &

[ ! -f /etc/dropbear/dropbear_rsa_host_key ] && dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key
[ ! -f /etc/dropbear/dropbear_dss_host_key ] && dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key
[ ! -f /etc/dropbear/dropbear_ecdsa_host_key ] && dropbearkey -t ecdsa -f /etc/dropbear/dropbear_ecdsa_host_key

dropbear &

##### Part III: load8x9 #####

/etc/load8x9.sh -i -sensor0 bg1336

echo "vii_dev_dump=1" > /proc/vssdk/vii

# 111111111111111111111

1v8
GPIO50, 466
RST
GPIO65, 417
3v3
GPIO51, 467
2v8
GPIO0, 480
ULLC_STDBY
GPIO47, 463

echo 466 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio466/direction
echo 1 > /sys/class/gpio/gpio466/value

echo 417 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio417/direction
echo 1 > /sys/class/gpio/gpio417/value

echo 467 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio467/direction
echo 1 > /sys/class/gpio/gpio467/value

echo 480 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio480/direction
devmem 0x0ce1c1f0 32 0x01885301
echo 1 > /sys/class/gpio/gpio480/value


echo 463 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio463/direction
echo 0 > /sys/class/gpio/gpio463/value

i2ctransfer -y 5 w2@0x32 0x00 0x78 r1