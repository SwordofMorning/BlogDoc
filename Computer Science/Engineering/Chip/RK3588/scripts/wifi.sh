#!/bin/bash

# Default action is connect
ACTION=${1:-Unknown}
WIFISSID=${2:-AHGZ-AP}
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

# Brief: Reset network interface completely
# Return: 0 success; 1 failed
Func_ResetInterface()
{
    local INTERFACE="wlan0"
    
    echo "Resetting network interface ${INTERFACE}..."
    
    # Stop all services first
    pkill -f "hostapd" 2>/dev/null
    pkill -f "dnsmasq" 2>/dev/null
    pkill -f "udhcpc.*${INTERFACE}" 2>/dev/null
    sleep 1
    
    # Reset interface
    ifconfig ${INTERFACE} down 2>/dev/null
    
    # Clear any IP configuration
    ip addr flush dev ${INTERFACE} 2>/dev/null
    
    # Remove any routes
    ip route flush dev ${INTERFACE} 2>/dev/null
    
    sleep 1
    echo "Interface ${INTERFACE} reset completed"
    return 0
}

# Brief: config wpa_supplicant.conf with SSID and PWD
# Return:   0 success; 
#           1 interface reset failed; 
#           2 config write failed; 
#           3 interface check failed
Func_ConfWpa()
{
    local WPA_CONF="/etc/wpa_supplicant.conf"
    local INTERFACE="wlan0"

    # Step 1: Reset interface completely
    echo "Resetting interface for station mode..."
    Func_ResetInterface
    if [ $? -ne 0 ]; then
        echo "Failed to reset interface"
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

    # Step 3: Bring up interface
    echo "Bringing up ${INTERFACE}..."
    if ! ifconfig ${INTERFACE} up; then
        echo "Failed to bring up ${INTERFACE}"
        return 3
    fi

    # Verify interface is up
    if ifconfig ${INTERFACE} | grep -q "UP"; then
        echo "Successfully configured ${INTERFACE} for station mode"
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
        if [ -n "$ip" ] && [ "$ip" != "192.168.4.1" ]; then  # Exclude AP mode IP
            echo "Current IP address: $ip"
            return 0
        fi
        return 1
    }

    # Force clear any existing IP (especially AP mode IP)
    echo "Clearing any existing IP configuration..."
    ip addr flush dev ${INTERFACE} 2>/dev/null

    # Try to get IP via DHCP
    echo "Attempting DHCP for new IP..."
    for attempt in $(seq 1 $MAX_RETRY); do
        echo "DHCP attempt $attempt of $MAX_RETRY"
        
        # Kill any existing udhcpc processes for this interface
        pkill -f "udhcpc.*${INTERFACE}"
        sleep 1

        # Start DHCP client with force renew
        if udhcpc -i ${INTERFACE} -T ${DHCP_TIMEOUT} -t ${MAX_RETRY} -n -q; then
            sleep 2  # Wait for IP configuration to settle
            
            # Verify IP was obtained
            if check_ip; then
                echo "Successfully obtained IP address via DHCP"
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
        
        echo "wpa_supplicant stopped successfully (after forced kill)"
        return 0
    fi
}

# Brief: Validate WiFi password for AP mode
# Return: 0 valid; 1 invalid
Func_ValidatePassword()
{
    local password="$1"
    local min_length=8
    local max_length=63
    
    if [ ${#password} -lt $min_length ] || [ ${#password} -gt $max_length ]; then
        echo "Error: WiFi password must be between $min_length and $max_length characters"
        echo "Current password length: ${#password}"
        return 1
    fi
    
    return 0
}

# Brief: Configure hostapd for AP mode
# Return: 0 success;
#         1 password validation failed;
#         2 interface configuration failed;
#         3 hostapd config write failed
Func_ConfAP()
{
    local HOSTAPD_CONF="/etc/hostapd.conf"
    local INTERFACE="wlan0"
    local AP_IP="192.168.4.1"

    # Step 1: Validate password
    echo "Validating WiFi password..."
    if ! Func_ValidatePassword "$WIFIPWD"; then
        return 1
    fi

    # Step 2: Stop any existing services and reset interface
    echo "Stopping existing services and resetting interface..."
    Func_StopWpa >/dev/null 2>&1
    pkill -f "hostapd" >/dev/null 2>&1
    pkill -f "dnsmasq" >/dev/null 2>&1
    
    # Reset interface completely
    Func_ResetInterface

    # Step 3: Configure interface for AP mode
    echo "Configuring ${INTERFACE} for AP mode..."
    if ! ifconfig ${INTERFACE} ${AP_IP} netmask 255.255.255.0 up; then
        echo "Failed to configure ${INTERFACE} with IP ${AP_IP}"
        return 2
    fi

    # Step 4: Create hostapd configuration
    echo "Creating hostapd configuration..."
    if ! cat > ${HOSTAPD_CONF} <<EOL
interface=${INTERFACE}
driver=nl80211
ssid=${WIFISSID}
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=${WIFIPWD}
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOL
    then
        echo "Failed to write ${HOSTAPD_CONF}"
        return 3
    fi

    echo "Successfully configured AP mode"
    echo "AP SSID: ${WIFISSID}"
    echo "Password length: ${#WIFIPWD} characters"
    return 0
}

# Brief: Start hostapd service
# Return: 0 success;
#         1 hostapd start failed;
#         2 hostapd not responding
Func_RunAP()
{
    local HOSTAPD_CONF="/etc/hostapd.conf"
    local MAX_WAIT=10

    # Start hostapd
    echo "Starting hostapd..."
    if ! hostapd -B ${HOSTAPD_CONF}; then
        echo "Failed to start hostapd"
        return 1
    fi

    # Wait for hostapd to start properly
    local counter=0
    while [ $counter -lt $MAX_WAIT ]; do
        if pgrep -f "hostapd" >/dev/null; then
            echo "hostapd started successfully"
            return 0
        fi
        sleep 1
        counter=$((counter + 1))
    done

    echo "hostapd failed to start properly"
    return 2
}

# Brief: Configure and start dnsmasq DHCP server for AP mode
# Return: 0 success;
#         1 dhcp config failed;
#         2 dhcp start failed;
#         3 dnsmasq not available
Func_DHCPServer()
{
    local DNSMASQ_CONF="/etc/dnsmasq.conf"
    local INTERFACE="wlan0"

    # Check if dnsmasq is available
    if ! command -v dnsmasq >/dev/null 2>&1; then
        echo "Error: dnsmasq command not found"
        return 3
    fi

    # Stop any existing dnsmasq
    pkill -f "dnsmasq" 2>/dev/null
    sleep 1

    # Create dnsmasq configuration for AP mode
    echo "Configuring dnsmasq DHCP server..."
    if ! cat > ${DNSMASQ_CONF} <<EOL
# Interface to use
interface=${INTERFACE}

# DHCP range
dhcp-range=192.168.4.20,192.168.4.200,255.255.255.0,12h

# Gateway and DNS
dhcp-option=3,192.168.4.1
dhcp-option=6,8.8.8.8,8.8.4.4

# Disable DNS resolution (only DHCP)
port=0

# Enable logging
log-dhcp

# Bind only to specified interface
bind-interfaces

# Don't read /etc/hosts
no-hosts

# Don't read /etc/resolv.conf
no-resolv
EOL
    then
        echo "Failed to write ${DNSMASQ_CONF}"
        return 1
    fi

    # Start dnsmasq
    echo "Starting dnsmasq DHCP server..."
    if ! dnsmasq -C ${DNSMASQ_CONF}; then
        echo "Failed to start dnsmasq"
        return 2
    fi

    # Verify dnsmasq is running
    sleep 2
    if pgrep -f "dnsmasq" >/dev/null; then
        echo "dnsmasq DHCP server started successfully"
        return 0
    else
        echo "dnsmasq failed to start properly"
        return 2
    fi
}

# Brief: Stop hostapd and related services
# Return: 0 success;
#         1 failed to stop services
Func_StopAP()
{
    local INTERFACE="wlan0"

    echo "Stopping AP mode services..."
    
    # Stop hostapd
    pkill -f "hostapd" 2>/dev/null
    
    # Stop dnsmasq
    pkill -f "dnsmasq" 2>/dev/null
    
    # Reset interface
    Func_ResetInterface
    
    sleep 2
    
    # Verify services are stopped
    if pgrep -f "hostapd" >/dev/null || pgrep -f "dnsmasq" >/dev/null; then
        echo "Failed to stop some AP services"
        return 1
    fi

    echo "AP mode services stopped successfully"
    return 0
}

##############################################################################################
######################################## Par II: APIs ########################################
##############################################################################################

# Brief: Insmod for init
# Return:   0 success
#           1 insmod fail
API_Insmod()
{
    local ret=0

    echo "Starting first time WiFi Init..."

    # Step 1: Load WiFi module
    echo "Step 1: Loading WiFi module..."
    Func_Insmod
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed at Step 1: Module loading failed with error $ret"
        return 1
    fi

    return 0
}

# Brief: Applicable to the first time connecting to WiFi after booting
# Return:   0 success; 
#           1-3 corresponding to the step that failed
API_Connect()
{
    local ret=0

    echo "Starting WiFi connection..."

    # Step 1: Configure WPA with SSID and Password
    echo "Step 1: Configuring WPA..."
    Func_ConfWpa
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed at Step 1: WPA configuration failed with error $ret"
        return 1
    fi

    # Step 2: Run wpa_supplicant
    echo "Step 2: Starting WPA supplicant..."
    Func_RunWpa
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed at Step 2: WPA supplicant failed with error $ret"
        return 2
    fi

    # Step 3: DHCP get IP address
    echo "Step 3: Obtaining IP address..."
    Func_UDHCPC
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed at Step 3: DHCP failed with error $ret"
        return 3
    fi

    echo "WiFi connection completed successfully!"
    return 0
}

# Brief: Used to reconnect to a new WiFi after already connected to WiFi
# Return: 0 success; 
#         1 stop wpa failed;
#         2-4 same as API_Connect return values
API_Reconnect()
{
    local ret=0
    echo "Starting WiFi reconnection process..."
    echo "Target Network: $WIFISSID"

    # Step 1: Stop existing services and reset interface
    echo "Step 1: Stopping existing services..."
    Func_StopWpa >/dev/null 2>&1
    Func_StopAP >/dev/null 2>&1

    # Brief pause to ensure clean state
    sleep 1

    # Step 2: Use API_Connect for the rest of the process
    echo "Step 2: Starting new connection process..."
    API_Connect
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed at Step 2: Connection process failed with error $ret"
        return $((ret + 1))  # Adjust return value to maintain error code consistency
    fi

    echo "WiFi reconnection completed successfully!"
    echo "Connected to: $WIFISSID"
    return 0
}

# Brief: Configure WiFi as Access Point mode
# Return: 0 success;
#         1 AP configuration failed;
#         2 hostapd start failed;
#         3 DHCP server start failed
API_AP()
{
    local ret=0

    echo "Starting WiFi AP mode..."
    echo "AP SSID: $WIFISSID"
    echo "Password: $WIFIPWD"

    # Step 1: Configure AP mode
    echo "Step 1: Configuring AP mode..."
    Func_ConfAP
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed at Step 1: AP configuration failed with error $ret"
        return 1
    fi

    # Step 2: Start hostapd
    echo "Step 2: Starting hostapd..."
    Func_RunAP
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed at Step 2: hostapd start failed with error $ret"
        return 2
    fi

    # Step 3: Start DHCP server
    echo "Step 3: Starting DHCP server..."
    Func_DHCPServer
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed at Step 3: DHCP server start failed with error $ret"
        return 3
    fi

    echo "WiFi AP mode started successfully!"
    echo "AP SSID: $WIFISSID"
    echo "AP IP: 192.168.4.1"
    echo "DHCP Range: 192.168.4.20 - 192.168.4.200"
    echo "DNS Servers: 8.8.8.8, 8.8.4.4"
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
        echo "  insmod            - Load WiFi module"
        echo "  scan              - Scan available WiFi networks"
        echo "  connect SSID PWD  - Connect to WiFi (first time)"
        echo "  reconnect SSID PWD- Reconnect to different WiFi"
        echo "  ap SSID PWD       - Start WiFi Access Point mode (PWD: 8-63 chars)"
        echo "Examples:"
        echo "  $0 insmod"
        echo "  $0 scan"
        echo "  $0 connect MyWiFi MyPassword"
        echo "  $0 reconnect NewWiFi NewPassword"
        echo "  $0 ap MyHotspot MyPassword123"
        return 0
    fi

    # Execute requested action
    case "$ACTION" in
        "insmod")
            echo "Loading WiFi module..."
            API_Insmod
            ret=$?
            case $ret in
                0) echo "Module loading successful" ;;
                1) echo "Module loading failed" ;;
                *) echo "Unknown error occurred" ;;
            esac
            ;;

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
            API_Connect
            ret=$?
            case $ret in
                0) echo "Connection successful" ;;
                1) echo "WPA configuration failed" ;;
                2) echo "WPA connection failed" ;;
                3) echo "DHCP configuration failed" ;;
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

        "ap")
            echo "Starting WiFi Access Point: $WIFISSID"
            API_AP
            ret=$?
            case $ret in
                0) echo "Access Point started successfully" ;;
                1) echo "AP configuration failed (check password length: 8-63 chars)" ;;
                2) echo "hostapd service failed" ;;
                3) echo "DHCP server failed (dnsmasq issue)" ;;
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