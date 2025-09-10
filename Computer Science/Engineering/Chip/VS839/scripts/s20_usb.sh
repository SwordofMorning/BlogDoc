#!/bin/sh

# S20_usb.sh - USB and network services initialization script

# USB Module List
MODULES="libcomposite u_ether usb_f_rndis usb_f_ecm g_ether"

check_module_loaded()
{
    local module_name=$1
    module_name=$(basename "$module_name" .ko)
    
    # Check if the module is in the lsmod output
    if lsmod | grep -q "^$module_name "; then
        return 0  # Module loaded
    else
        return 1  # Module unloaded
    fi
}

load_module_safe()
{
    local module_path=$1
    local module_name=$(basename "$module_path" .ko)

    echo "Loading module: $module_name"

    # Try to load ko
    if insmod "$module_path"; then
        # sleep for stabilizing
        sleep 0.1

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

start_usb()
{
    #################### Part I: Load USB ####################

    echo "Starting USB and network services..."

    # Load all modules in order
    for module in $MODULES; do
        module_path="/lib/modules/${module}.ko"

        # Check if the module file exists
        if [ ! -f "$module_path" ]; then
            echo "Error: Module file $module_path not found"
            return 1
        fi

        # Check if the module is loaded
        if check_module_loaded "$module"; then
            echo "Module $module is already loaded, skipping"
            continue
        fi

        # Load
        if ! load_module_safe "$module_path"; then
            echo "Failed to load module $module, aborting"
            return 1
        fi
    done

    echo "All USB modules loaded successfully"

    # Config network
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
    
    echo "USB and network services started successfully"
}

stop_usb()
{
    echo "Stopping USB and network services..."

    # Stop service
    killall telnetd 2>/dev/null
    killall dropbear 2>/dev/null

    # Down network
    ifconfig usb0 down 2>/dev/null

    # Unload modules
    for module in $(echo $MODULES | tr ' ' '\n' | tac | tr '\n' ' '); do
        if check_module_loaded "$module"; then
            echo "Unloading module: $module"
            rmmod "$module" 2>/dev/null
        fi
    done

    echo "USB and network services stopped"
}

case "$1" in
    start)
        start_usb
        ;;
    stop)
        stop_usb
        ;;
    restart)
        $0 stop
        sleep 2
        $0 start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac

exit 0