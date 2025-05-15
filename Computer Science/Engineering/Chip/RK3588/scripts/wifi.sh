#!/bin/bash

# Default action is connect
ACTION=${1:-connect}
WIFISSID=${2:-AHGZ-2.4}
WIFIPWD=${3:-cdjp123123}

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

# Brief: Stop wpa_supplicant service
# Return: 0 success; 
#         1 no wpa_supplicant running; 
#         2 failed to stop process; 
#         3 process lingering after kill
Func_StopWpa()
{
    local INTERFACE="wlan0"
    local MAX_WAIT=5  # Maximum seconds to wait for process to stop
    local pid

    # Check if wpa_supplicant is running
    pid=$(pgrep -f "wpa_supplicant.*${INTERFACE}")
    if [ -z "$pid" ]; then
        echo "No wpa_supplicant process found for ${INTERFACE}"
        return 1
    fi

    echo "Stopping wpa_supplicant (PID: $pid)..."

    # First try graceful termination
    pkill -TERM -f "wpa_supplicant.*${INTERFACE}"
    
    # Wait for process to stop
    local counter=0
    while [ $counter -lt $MAX_WAIT ]; do
        if ! pgrep -f "wpa_supplicant.*${INTERFACE}" >/dev/null; then
            echo "wpa_supplicant stopped successfully"
            
            # Clean up any remaining socket files
            rm -f /var/run/wpa_supplicant/${INTERFACE} 2>/dev/null
            
            # Bring down the interface
            ifconfig ${INTERFACE} down 2>/dev/null
            
            return 0
        fi
        sleep 1
        counter=$((counter + 1))
    done

    # If still running, try forced kill
    echo "Process still running after ${MAX_WAIT} seconds, attempting forced kill..."
    pkill -KILL -f "wpa_supplicant.*${INTERFACE}"
    sleep 1

    # Final check
    if pgrep -f "wpa_supplicant.*${INTERFACE}" >/dev/null; then
        echo "Failed to stop wpa_supplicant"
        return 2
    else
        # Clean up any remaining socket files
        rm -f /var/run/wpa_supplicant/${INTERFACE} 2>/dev/null
        
        # Bring down the interface
        ifconfig ${INTERFACE} down 2>/dev/null
        
        echo "wpa_supplicant stopped successfully (after forced kill)"
        return 0
    fi
}

##############################################################################################
######################################## Par II: APIs ########################################
##############################################################################################

# Brief: Applicable to the first time connecting to WiFi after booting
# Return:   0 success; 
#           1-4 corresponding to the step that failed
API_FirstConnect()
{
    local ret=0

    echo "Starting first time WiFi connection..."

    # Step 1: Load WiFi module
    echo "Step 1: Loading WiFi module..."
    Func_Insmod
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed at Step 1: Module loading failed with error $ret"
        return 1
    fi

    # Step 2: Configure WPA with SSID and Password
    echo "Step 2: Configuring WPA..."
    Func_ConfWpa
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed at Step 2: WPA configuration failed with error $ret"
        return 2
    fi

    # Step 3: Run wpa_supplicant
    echo "Step 3: Starting WPA supplicant..."
    Func_RunWpa
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed at Step 3: WPA supplicant failed with error $ret"
        return 3
    fi

    # Step 4: DHCP get IP address
    echo "Step 4: Obtaining IP address..."
    Func_UDHCPC
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed at Step 4: DHCP failed with error $ret"
        return 4
    fi

    echo "WiFi connection completed successfully!"
    return 0
}

# Brief: Used to reconnect to a new WiFi after already connected to WiFi
# Return: 0 success; 
#         1 stop wpa failed;
#         2 config wpa failed;
#         3 run wpa failed;
#         4 DHCP failed
API_Reconnect()
{
    local ret=0
    echo "Starting WiFi reconnection process..."
    echo "Target Network: $WIFISSID"

    # Step 1: Stop existing wpa_supplicant
    echo "Step 1: Stopping existing WiFi connection..."
    Func_StopWpa
    ret=$?
    if [ $ret -ne 0 ] && [ $ret -ne 1 ]; then  # ret=1 means no wpa running, which is OK
        echo "Failed at Step 1: Could not stop existing WiFi connection (error $ret)"
        return 1
    fi

    # Brief pause to ensure clean state
    sleep 1

    # Step 2: Configure new WiFi parameters
    echo "Step 2: Configuring new WiFi parameters..."
    Func_ConfWpa
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed at Step 2: Could not configure new WiFi parameters (error $ret)"
        return 2
    fi

    # Step 3: Start wpa_supplicant
    echo "Step 3: Starting WiFi connection..."
    Func_RunWpa
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed at Step 3: Could not establish WiFi connection (error $ret)"
        return 3
    fi

    # Step 4: Obtain IP address
    echo "Step 4: Obtaining IP address..."
    Func_UDHCPC
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed at Step 4: Could not obtain IP address (error $ret)"
        return 4
    fi

    echo "WiFi reconnection completed successfully!"
    echo "Connected to: $WIFISSID"
    return 0
}

# Brief: Scan SSID and write to file
# Return: 0 success; 
#         1 wpa_state not ready;
#         2 scan failed;
#         3 failed to get results;
#         4 failed to write file
API_Scan()
{
    local INTERFACE="wlan0"
    local WPA_PATH="/var/run/wpa_supplicant"
    local SCAN_FILE="${WPA_PATH}/scan.txt"
    local MAX_RETRY=3
    local SCAN_WAIT=3  # seconds to wait for scan completion

    # Step 1: Check WPA state
    echo "Checking WPA state..."
    local state=$(wpa_cli -i ${INTERFACE} status | grep "wpa_state=" | cut -d'=' -f2)
    if [ "$state" != "COMPLETED" ]; then
        echo "WPA state not ready: $state"
        return 1
    fi

    # Step 2: Initiate scan
    echo "Starting network scan..."
    for attempt in $(seq 1 $MAX_RETRY); do
        echo "Scan attempt $attempt of $MAX_RETRY"
        
        if ! wpa_cli -i ${INTERFACE} scan >/dev/null 2>&1; then
            echo "Scan initiation failed"
            [ $attempt -eq $MAX_RETRY ] && return 2
            sleep 1
            continue
        fi

        # Wait for scan to complete
        sleep $SCAN_WAIT

        # Step 3: Get scan results and process them
        echo "Getting scan results..."
        local scan_results=$(wpa_cli -i ${INTERFACE} scan_results)
        if [ -z "$scan_results" ]; then
            echo "No scan results obtained"
            [ $attempt -eq $MAX_RETRY ] && return 3
            continue
        fi

        # Process and format scan results
        # Create header for the file
        {
            echo "# Scan Results ($(date '+%Y-%m-%d %H:%M:%S'))"
            echo "# BSSID / Frequency / Signal Level / Flags / SSID"
            echo "$scan_results" | while read -r line; do
                # Skip header line
                if [[ $line =~ "bssid / frequency" ]]; then
                    continue
                fi
                # Process and format each line
                if [ ! -z "$line" ]; then
                    echo "$line"
                fi
            done
        } > "${SCAN_FILE}.tmp"

        # Check if we got any results (more than just headers)
        if [ $(wc -l < "${SCAN_FILE}.tmp") -gt 2 ]; then
            # Move temporary file to final location
            mv "${SCAN_FILE}.tmp" "${SCAN_FILE}"
            echo "Scan results written to ${SCAN_FILE}"
            return 0
        else
            rm -f "${SCAN_FILE}.tmp"
            echo "No networks found in scan"
            [ $attempt -eq $MAX_RETRY ] && return 3
        fi
    done

    echo "Failed to get valid scan results after $MAX_RETRY attempts"
    return 3
}

###############################################################################################
######################################## Par III: main ########################################
###############################################################################################

main()
{
    # Print usage if help is requested
    if [ "$ACTION" = "-h" ] || [ "$ACTION" = "--help" ]; then
        echo "Usage: $0 [ACTION] [SSID] [PASSWORD]"
        echo "Actions:"
        echo "  scan              - Scan available WiFi networks"
        echo "  connect SSID PWD  - Connect to WiFi (first time)"
        echo "  reconnect SSID PWD- Reconnect to different WiFi"
        echo "Examples:"
        echo "  $0 scan"
        echo "  $0 connect MyWiFi MyPassword"
        echo "  $0 reconnect NewWiFi NewPassword"
        return 0
    fi

    # Execute requested action
    case "$ACTION" in
        "scan")
            echo "Scanning for WiFi networks..."
            API_Scan
            ret=$?
            case $ret in
                0) echo "Scan completed successfully" ;;
                1) echo "WPA not ready for scanning" ;;
                2) echo "Scan initiation failed" ;;
                3) echo "Failed to get scan results" ;;
                4) echo "Failed to write scan results" ;;
                *) echo "Unknown error occurred" ;;
            esac
            ;;
            
        "connect")
            echo "Connecting to WiFi network: $WIFISSID"
            API_FirstConnect
            ret=$?
            case $ret in
                0) echo "Connection successful" ;;
                1) echo "Module loading failed" ;;
                2) echo "WPA configuration failed" ;;
                3) echo "WPA connection failed" ;;
                4) echo "DHCP configuration failed" ;;
                *) echo "Unknown error occurred" ;;
            esac
            ;;
            
        "reconnect")
            echo "Reconnecting to WiFi network: $WIFISSID"
            API_Reconnect
            ret=$?
            case $ret in
                0) echo "Reconnection successful" ;;
                1) echo "Failed to stop existing connection" ;;
                2) echo "Failed to configure new connection" ;;
                3) echo "Failed to start WiFi service" ;;
                4) echo "Failed to obtain IP address" ;;
                *) echo "Unknown error occurred" ;;
            esac
            ;;
            
        *)
            echo "Error: Unknown action '$ACTION'"
            echo "Use '$0 --help' for usage information"
            return 1
            ;;
    esac

    return $ret
}
main