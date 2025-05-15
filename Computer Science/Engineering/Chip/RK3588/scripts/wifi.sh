#!/bin/bash

WIFISSID=${1:-AHGZ-2.4}
WIFIPWD=${2:-cdjp123123}

##############################################################################################
######################################## Par I: Basic ########################################
##############################################################################################

# Brief: insmod bcmdhd.ko
# Return:   0 success; 
#           1 no such file; 
#           2 insmod fail
Func_Insmod()
{
    local MODULE_NAME="bcmdhd"
    local MODULE_PATH="/vendor/lib/modules/bcmdhd.ko"

    # Check if module is already loaded
    if lsmod | grep -q "^${MODULE_NAME}"; then
        echo "Module ${MODULE_NAME} is already loaded"
        return 0
    fi

    # Check if module file exists
    if [ ! -f "${MODULE_PATH}" ]; then
        echo "Error: Module file ${MODULE_PATH} not found"
        return 1
    fi

    # Try to load the module
    if insmod "${MODULE_PATH}" 2>/dev/null; then
        echo "Successfully loaded module ${MODULE_NAME}"
        return 0
    else
        echo "Failed to load module ${MODULE_NAME}"
        return 2
    fi
}

# Brief: config wpa_supplicant.conf with SSID and PWD
# Return:   0 success; 
#           1 interface down failed; 
#           2 config write failed; 
#           3 interface check failed
Func_ConfWpa()
{
    local WPA_CONF="/etc/wpa_supplicant.conf"
    local INTERFACE="wlan0"

    # Step 1: Turn down wlan0
    echo "Turning down ${INTERFACE}..."
    if ! ifconfig ${INTERFACE} down; then
        echo "Failed to turn down ${INTERFACE}"
        return 1
    fi

    # Step 2: Generate and write wpa_supplicant configuration
    echo "Configuring ${WPA_CONF}..."
    if ! cat > ${WPA_CONF} <<EOL
ctrl_interface=/var/run/wpa_supplicant
ap_scan=1
update_config=1

network={
        ssid="${WIFISSID}"
        psk="${WIFIPWD}"
        key_mgmt=WPA-PSK
}
EOL
    then
        echo "Failed to write ${WPA_CONF}"
        return 2
    fi

    # Step 3: Check wlan0 status
    echo "Checking ${INTERFACE} status..."
    if ! ifconfig ${INTERFACE} up; then
        echo "Failed to bring up ${INTERFACE}"
        return 3
    fi

    # Verify interface is up
    if ifconfig ${INTERFACE} | grep -q "UP"; then
        echo "Successfully configured ${INTERFACE}"
        return 0
    else
        echo "Interface ${INTERFACE} is not up"
        return 3
    fi
}

# Brief: Run wpa_supplicant
# Return:   0 wpa_state=COMPLETED;
#           1 directory creation failed; 
#           2 wpa_supplicant start failed;
#           3 connection failed
Func_RunWpa()
{
    local WPA_RUN_DIR="/var/run/wpa_supplicant"
    local INTERFACE="wlan0"
    local MAX_WAIT=30  # Maximum seconds to wait for connection
    local WPA_CONF="/etc/wpa_supplicant.conf"

    # Step 1: Create wpa_supplicant directory if not exists
    if ! mkdir -p ${WPA_RUN_DIR}; then
        echo "Failed to create directory ${WPA_RUN_DIR}"
        return 1
    fi

    # Step 2: Check if wpa_supplicant is already running
    if pgrep -f "wpa_supplicant.*${INTERFACE}" >/dev/null; then
        echo "wpa_supplicant is already running, killing existing process..."
        pkill -f "wpa_supplicant.*${INTERFACE}"
        sleep 1
    fi

    # Start wpa_supplicant
    echo "Starting wpa_supplicant..."
    if ! wpa_supplicant -B -Dnl80211 -c ${WPA_CONF} -i ${INTERFACE}; then
        echo "Failed to start wpa_supplicant"
        return 2
    fi

    # Step 3: Wait for connection (with timeout)
    echo "Waiting for WiFi connection..."
    local counter=0
    while [ $counter -lt $MAX_WAIT ]; do
        local state=$(wpa_cli -i ${INTERFACE} status | grep "wpa_state=" | cut -d'=' -f2)
        
        case "$state" in
            "COMPLETED")
                echo "WiFi connection completed successfully"
                return 0
                ;;
            "DISCONNECTED"|"INACTIVE"|"SCANNING")
                echo "Current state: $state, waiting..."
                ;;
            *)
                echo "Unexpected state: $state"
                ;;
        esac

        counter=$((counter + 1))
        sleep 1
    done

    echo "Connection timeout after ${MAX_WAIT} seconds"
    return 3
}

# Brief: Get IP address via DHCP
# Return:   0 success (IP obtained);
#           1 interface not found; 
#           2 DHCP failed;
#           3 IP verification failed
Func_UDHCPC()
{
    local INTERFACE="wlan0"
    local MAX_RETRY=3
    local DHCP_TIMEOUT=10

    # Check if interface exists
    if ! ifconfig ${INTERFACE} >/dev/null 2>&1; then
        echo "Interface ${INTERFACE} not found"
        return 1
    fi

    # Function to check IP address
    check_ip() {
        local ip=$(ifconfig ${INTERFACE} | grep 'inet ' | awk '{print $2}')
        if [ -n "$ip" ]; then
            echo "Current IP address: $ip"
            return 0
        fi
        return 1
    }

    # Check if we already have an IP
    if check_ip; then
        echo "IP address already configured"
        return 0
    fi

    # Try to get IP via DHCP
    echo "No IP address found, attempting DHCP..."
    for attempt in $(seq 1 $MAX_RETRY); do
        echo "DHCP attempt $attempt of $MAX_RETRY"
        
        # Kill any existing udhcpc processes for this interface
        pkill -f "udhcpc.*${INTERFACE}"
        sleep 1

        # Start DHCP client
        if udhcpc -i ${INTERFACE} -T ${DHCP_TIMEOUT} -t ${MAX_RETRY} -n -q; then
            sleep 2  # Wait for IP configuration to settle
            
            # Verify IP was obtained
            if check_ip; then
                echo "Successfully obtained IP address"
                return 0
            fi
        fi

        echo "DHCP attempt $attempt failed"
        sleep 2
    done

    echo "Failed to obtain IP address after $MAX_RETRY attempts"
    return 2
}

##############################################################################################
######################################## Par II: APIs ########################################
##############################################################################################

# Main Function
main()
{
    Func_Insmod
    Func_ConfWpa
    Func_RunWpa
    Func_UDHCPC
}
main