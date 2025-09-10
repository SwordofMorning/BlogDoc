#!/bin/sh

# S30_oled.sh - OLED display initialization script

case "$1" in
    start)
        echo "Starting OLED display initialization..."

        #GPIO67, PANEL RST, GPIO419
        echo 419 > /sys/class/gpio/export
        echo out > /sys/class/gpio/gpio419/direction
        devmem 0x0ce1c0d8 32 0x00086300
        echo 1 > /sys/class/gpio/gpio419/value
        echo 0 > /sys/class/gpio/gpio419/value

        # GPIO77
        # SPI1_SCLK
        devmem 0x0ce1c0b0 32 0x00037301

        # GPIO78, SPI1_SDO
        devmem 0x0ce1c0a8 32 0x00037301

        # GPIO80, SPI1_SDI
        devmem 0x0ce1c0a4 32 0x00037301

        # GPIO78, for SPI1_CSN, set as GPIO
        devmem 0x0ce1c0ac 32 0x00037305

        echo "OLED display initialized successfully"
        ;;
    stop)
        echo "Stopping OLED display..."
        echo "OLED display stopped"
        ;;
    restart)
        $0 stop
        $0 start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac

exit 0