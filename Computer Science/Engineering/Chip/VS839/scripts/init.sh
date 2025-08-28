#!/bin/sh

#################### Part I: USB ####################

# 定义要加载的模块列表
MODULES="libcomposite u_ether usb_f_rndis usb_f_ecm g_ether"

# 函数：检查模块是否已加载
check_module_loaded() {
    local module_name=$1
    # 去掉.ko后缀和路径，只保留模块名
    module_name=$(basename "$module_name" .ko)
    
    # 检查模块是否在lsmod输出中
    if lsmod | grep -q "^$module_name "; then
        return 0  # 模块已加载
    else
        return 1  # 模块未加载
    fi
}

# 函数：加载模块并验证
load_module_safe() {
    local module_path=$1
    local module_name=$(basename "$module_path" .ko)
    
    echo "Loading module: $module_name"
    
    # 尝试加载模块
    if insmod "$module_path"; then
        # insmod成功，再次验证模块是否真正加载
        sleep 0.1  # 给系统一点时间来注册模块
        
        if check_module_loaded "$module_name"; then
            echo "Module $module_name loaded successfully"
            return 0
        else
            echo "Error: Module $module_name failed to load (not found in lsmod)"
            return 1
        fi
    else
        echo "Error: insmod failed for module $module_name"
        return 1
    fi
}

# 按顺序加载所有模块
for module in $MODULES; do
    module_path="/lib/modules/${module}.ko"
    
    # 检查模块文件是否存在
    if [ ! -f "$module_path" ]; then
        echo "Error: Module file $module_path not found"
        exit 1
    fi
    
    # 检查模块是否已经加载
    if check_module_loaded "$module"; then
        echo "Module $module is already loaded, skipping"
        continue
    fi
    
    # 加载模块
    if ! load_module_safe "$module_path"; then
        echo "Failed to load module $module, aborting"
        exit 1
    fi
done

echo "All USB modules loaded successfully"

# 配置网络接口
ifconfig usb0 169.254.43.1 netmask 255.255.0.0 up
route add default gw 169.254.43.10

#################### Part II: Telnet & SSH ####################

mkdir -p /dev/pts
mount -t devpts none /dev/pts 2>/dev/null || echo "Warning: Failed to mount /dev/pts"
telnetd &

[ ! -f /etc/dropbear/dropbear_rsa_host_key ] && dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key
[ ! -f /etc/dropbear/dropbear_dss_host_key ] && dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key
[ ! -f /etc/dropbear/dropbear_ecdsa_host_key ] && dropbearkey -t ecdsa -f /etc/dropbear/dropbear_ecdsa_host_key

dropbear &

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