#!/bin/bash

ssid=
password=
encrypt=psk
mode="station"
config_file="/data/wifi_configure.txt"
router_ip="192.168.168.1"
router_connted="no"
ap_ip="192.168.2.1"
ping_period="6"
retry="1"
onoff_test="0"
debug="1"
module_pid_file="/sys/bus/mmc/devices/mmc1:0001/mmc1:0001:1/device"
init_config=0
ERROR_FLAG=0
wifi_results_file=/data/wifi_results.txt
wifi_results_ok=
wifi_results_fail=

wpa_pid=
dhcpcd_pid=

NAME1=wpa_supplicant
DAEMON1=/usr/sbin/$NAME1
PIDFILE1=/var/run/$NAME1.pid

NAME2=hostapd
DAEMON2=/usr/sbin/$NAME2
PIDFILE2=/var/run/$NAME2.pid

NAME3=dnsmasq
DAEMON3=/usr/sbin/$NAME3
PIDFILE3=/var/run/$NAME3.pid

NAME4=dhcpcd
DAEMON4=/usr/sbin/$NAME4
PIDFILE4=/var/run/${NAME4}-wlan0.pid

check_wlan() {
    ifconfig wlan0 2> /dev/null
}
check_hostapd() {
    hostapd_cli status 2> /dev/null | grep state=ENABLED
}
check_dnsmasq() {
    if [ -f "$PIDFILE3" ]; then
        if ps -p $(cat "$PIDFILE3") > /dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

function end_script() {
if [ ${ERROR_FLAG} -ne 0 ]
then
    exit 11
else
    exit
fi
}

function check_in_loop() {
local cnt=1
while [ $cnt -lt $1 ]; do
    echo "check_in_loop processing..."
    case "$2" in
        check_wlan)
        check_wlan
        ;;
        check_hostapd)
        check_hostapd
        ;;
        check_dnsmasq)
        check_dnsmasq
        ;;
    esac
    if [ $? -eq 0 ];then
        return
    else
        cnt=$((cnt + 1))
        sleep 1
        continue
    fi
done

echo "fail!!"
ERROR_FLAG=1
end_script
}

function load_driver() {
if [ $1 = "0" ];then
	echo "removing driver if loaded"
else
	echo "start driver loading..."
	##########check wlan0############################
	echo "checking wlan0..."
	check_in_loop 15 check_wlan
	echo "wlan0 shows up"
fi
}

function stop_wifi() {

load_driver 0

echo "#########stoping wifi#####################"
#####stop wpa_supplicant hostapd dhcpcd dnsamas##
echo "Stop prev wpa_supplicant first"
wpa_pid=`ps | grep wpa_supplicant | awk '{print $1}' | sed -n "1p"`
echo "wpa_pid: $wpa_pid"
if [ -n "$wpa_pid" ]; then
    kill $wpa_pid
fi
sleep 1
echo "Stop prev dhcpcd first"  
dhcpcd_pid=`ps | grep dhcpcd | awk '{print $1}' | sed -n "1p"`
echo "dhcpcd_pid: $dhcpcd_pid"
if [ -n "$dhcpcd_pid" ]; then
    kill $dhcpcd_pid  
fi
sleep 1
}

function wifi_bcm_init()
{
	if [ ! -f ${module_pid_file} ];then
		ifconfig wlan0 up
		sleep 2  
	fi
}

function initial_configure() {
# 优先从参数获取配置
if [ $# -eq 3 ]; then 
    ssid=$1
    password=$2 
    mode=$3
    
    #写入配置文件
    echo "ssid=$ssid
password=$password  
mode=$mode
encrypt=psk
onoff_test=0
retry=5
debug=1  
"  > /data/wifi_configure.txt
elif [ -f $config_file ];then
########load from txt##################
echo "reading from txt...." 
while read line ; do
    key=`echo $line | awk -F "=" '{print $1}'`
    val=`echo $line | awk -F "=" '{print $2}'`
    case "$key" in
        ssid)
        ssid=$val
        ;;  
        password)
        password=$val
        ;;
        mode)   
        mode=$val
        ;;
        debug)
        debug=$val  
        ;;
    esac
done < $config_file

else
    echo "No config found!"
    end_script
fi

echo "user set:
ssid=$ssid, password=$password, mode=$mode, debug=$debug
4s to check your configure
"  
if [ "`echo $password |wc -L`" -lt "8" ];then
    echo "warning: password length is less than 8, it is not fit for WPA-PSK"
fi

}

function usage() {
echo "
##################################################################  
#usage:
#first choice:
#   write configure in /data/wifi/wifi_configure.txt
#second choice:  
#   $0  \"ssid\" \"password\" \"mode\"
#   example:$0 MyAP 12345678 ap
#   version:1.5  
##################################################################
"
}

function ping_test() {
if [ ! -f $wifi_results_file ];then  
echo "
wifi_ok=0
wifi_fail=0  
" > $wifi_results_file
fi

########load from txt##################
echo "reading from txt...."
while read line ; do
	key=`echo $line | awk -F "=" '{print $1}'`
	val=`echo $line | awk -F "=" '{print $2}'`  
	echo $key $val
	case "$key" in
		wifi_ok)   
		wifi_results_ok=$val
		;;
		wifi_fail) 
		wifi_results_fail=$val
		;;  
	esac
done < $wifi_results_file

router_ip=$(ip route | awk '/default/ {print $3}')
echo "  
now going to ping router's ip: $router_ip for $ping_period seconds"
ping $router_ip -w $ping_period

if [ $? -eq 1 ];then
	echo "ping fail!! please check"
	let wifi_results_fail+=1
else 
	echo "ping successfully"
	router_connted="yes"
	dmesg > /data/wifi_reboot_ok.txt

	let wifi_results_ok+=1  
fi

echo "wifi_ok=$wifi_results_ok
wifi_fail=$wifi_results_fail  
" > $wifi_results_file
}

############start wpa_supplicant##########
function start_sta() {
echo "starting wpa_supplicant..."
ifconfig wlan0 0.0.0.0

mkdir -p /data/wpa_supplicant 
echo "ctrl_interface=/data/wpa_supplicant
ap_scan=1

network={  
	ssid=\"$ssid\"
	psk=\"$password\"
	key_mgmt=WPA-PSK
}  
" > /data/wpa_supplicant.conf

/sbin/start-stop-daemon -S -m -p $PIDFILE1 -b -x $DAEMON1 -- -Dnl80211 -iwlan0 -c/data/wpa_supplicant.conf

echo "start wpa_supplicant successfully!!"

sleep 5

############start dhcp#######################
echo "starting wifi dhcp..."
/sbin/dhcpcd wlan0
echo "sta connected!!"  
}

function start_ap() {
echo "starting hostapd..."

# 直接使用wlan0接口，不再创建ap0虚拟接口
ifconfig wlan0 down
ifconfig wlan0 $ap_ip netmask 255.255.255.0 up

# 配置 hostapd.conf
echo "interface=wlan0
driver=nl80211
ssid=$ssid
hw_mode=g
channel=7
wpa=3
wpa_passphrase=$password
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP CCMP
ctrl_interface=/var/run/hostapd
" > /etc/hostapd.conf

# 启动 hostapd
echo "hostapd starting."
if [ -e "/var/run/hostapd/wlan0" ]; then
    rm "/var/run/hostapd/wlan0"
fi
/usr/sbin/hostapd /etc/hostapd.conf &

sleep 2

check_in_loop 10 check_hostapd

echo "hostapd started successfully!"

echo "AP started successfully!"
}

function start_dnsmasq() {
echo "starting dnsmasq..."

# 检查 dnsmasq 是否已经在运行，如果在运行则先停止
if pgrep dnsmasq > /dev/null; then
    killall dnsmasq
fi

# 检查53端口（DNS端口）和67端口（DHCP端口）是否被其他程序占用
echo "Checking if port 53 is in use..."
fuser 53/tcp
echo "Checking if port 67 is in use..."
fuser 67/udp

# 配置 dnsmasq.conf
echo "interface=wlan0
listen-address=$ap_ip
dhcp-range=192.168.2.100,192.168.2.200,255.255.255.0,12h
" > /etc/dnsmasq.conf

# 启动 dnsmasq
echo "dnsmasq starting."
/usr/sbin/dnsmasq -C /etc/dnsmasq.conf
if [ $? -ne 0 ]; then
    echo "Failed to start dnsmasq!"
    # 在这里可以添加更详细的错误处理逻辑
    exit 1
fi

sleep 2

check_in_loop 5 check_dnsmasq

echo "dnsmasq started successfully!"
}
function start_wifi() {

echo "########starting wifi#####################"   
###############load wifi driver##################
load_driver 1  
#####start wpa_supplicant hostapd dhcpcd dnsamasq bridge##

if [ "${mode}" = "station" ]; then 
	start_sta
	ping_test wlan0
elif [ "${mode}" = "ap" ]; then
	start_ap
	start_dnsmasq
else
	echo "bad mode!"  
	end_script
fi

}

function main() {
###########show usage first#####################
usage  
initial_configure $@
stop_wifi
start_wifi

}

wifi_bcm_init
main $@