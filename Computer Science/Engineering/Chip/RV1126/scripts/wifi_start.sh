#!/bin/bash

WIFISSID=${1:-AHGZ-2.4}
WIFIPWD=${2:-cdjp123123}

# 加载模块
insmod /root/wifi/bcmdhd.ko

# 关闭wlan0
ifconfig wlan0 down

# 修改/etc/wpa_supplicant.conf的内容
cat > /etc/wpa_supplicant.conf <<EOL
ctrl_interface=/var/run/wpa_supplicant
ap_scan=1
update_config=1

network={
        ssid="$WIFISSID"
        psk="$WIFIPWD"
        key_mgmt=WPA-PSK
}
EOL

# 创建目录
mkdir -p /var/run/wpa_supplicant

# 在后台运行wpa_supplicant
wpa_supplicant -dd -Dwext -iwlan0 -c /etc/wpa_supplicant.conf &

# 扫描可用的无线网络
wpa_cli -i wlan0 -p /var/run/wpa_supplicant scan

# 显示扫描结果
wpa_cli -i wlan0 -p /var/run/wpa_supplicant scan_results

# 显示连接状态
wpa_cli -i wlan0 status

# 获取IP地址
udhcpc -i wlan0