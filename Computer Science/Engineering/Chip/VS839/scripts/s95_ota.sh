#!/bin/sh

# S95_ota.sh - Enhanced OTA boot validation and slot management
# Compatible with new ab_boot system with boot_attempts counter

OTA_TOOL="/usr/bin/xOTA"
MISC_DEVICE="/dev/mmcblk0p4"
PROC_CMDLINE="/proc/cmdline"

# Function to get current slot
get_current_slot()
{
    if grep -q "root=/dev/mmcblk0p9" "$PROC_CMDLINE"; then
        echo "A"
    elif grep -q "root=/dev/mmcblk0p10" "$PROC_CMDLINE"; then
        echo "B"
    else
        echo ""
    fi
}

# Function to get slot info
get_slot_info()
{
    "$OTA_TOOL" --slot 2>/dev/null
}

# Parsing the print information provided by xOTA
parse_slot_attribute()
{
    local slot=$1
    local attribute=$2
    local slot_info=$3

    echo "DEBUG: Parsing slot=$slot, attribute='$attribute'" >&2

    local slot_section
    if [ "$slot" = "A" ]; then
        slot_section=$(echo "$slot_info" | sed -n '/^Slot A:/,/^Slot B:/p' | sed '$d')
    else
        slot_section=$(echo "$slot_info" | sed -n '/^Slot B:/,$p')
    fi

    echo "DEBUG: Slot section:" >&2
    echo "$slot_section" >&2

    local value
    case "$attribute" in
        "Bootable")
            value=$(echo "$slot_section" | grep "Bootable:" | awk '{print $2}')
            ;;
        "Successful")
            value=$(echo "$slot_section" | grep "Successful:" | awk '{print $2}')
            ;;
        "Active")
            value=$(echo "$slot_section" | grep "Active:" | awk '{print $2}')
            ;;
        "Retry count")
            value=$(echo "$slot_section" | grep "Retry count:" | awk '{print $3}')
            ;;
        "Boot attempts")
            value=$(echo "$slot_section" | grep "Boot attempts:" | awk '{print $3}')
            ;;
        *)
            echo "DEBUG: Unknown attribute: $attribute" >&2
            value=""
            ;;
    esac

    echo "DEBUG: Parsed value='$value'" >&2
    echo "$value"
}

reset_boot_attempts()
{
    local current_slot=$1

    echo "Resetting boot attempts for slot $current_slot..."

    if ! "$OTA_TOOL" --set-label -t "$current_slot" -n boot_attempts -v 0; then
        echo "Warning: Failed to reset boot_attempts for slot $current_slot"
        return 1
    fi

    echo "Boot attempts reset to 0 for slot $current_slot"
    return 0
}

reset_all_boot_attempts()
{
    echo "Resetting boot attempts for all slots..."

    # reset boot_attempts of Slot A and Slot B
    "$OTA_TOOL" --set-label -t A -n boot_attempts -v 0
    "$OTA_TOOL" --set-label -t B -n boot_attempts -v 0

    echo "All boot attempts counters reset"
}

# Function to mark current slot as successful
mark_slot_successful()
{
    local current_slot=$1

    echo "Marking slot $current_slot as successful..."

    if ! "$OTA_TOOL" --set-label -t "$current_slot" -n successful -v 1; then
        echo "Failed to mark slot $current_slot as successful"
        return 1
    fi

    echo "Slot $current_slot marked as successful"
    return 0
}

# Function to check if this is first boot after OTA
is_first_boot_after_ota() {
    local current_slot=$1
    local slot_info=$2

    local successful=$(parse_slot_attribute "$current_slot" "Successful" "$slot_info")

    echo "DEBUG: successful value for slot $current_slot = '$successful'" >&2

    if [ "$successful" = "0" ]; then
        return 0  # This is first boot after OTA
    else
        return 1  # Not first boot after OTA
    fi
}

# 修复：更健壮的boot_attempts检查
should_reset_boot_attempts()
{
    local current_slot=$1
    local slot_info=$2

    local boot_attempts=$(parse_slot_attribute "$current_slot" "Boot attempts" "$slot_info")
    
    echo "DEBUG: boot_attempts value for slot $current_slot = '$boot_attempts'" >&2

    if [ -n "$boot_attempts" ] && [ "$boot_attempts" -gt 0 ] 2>/dev/null; then
        echo "DEBUG: Should reset boot_attempts (value=$boot_attempts)" >&2
        return 0  # Should reset
    else
        echo "DEBUG: No need to reset boot_attempts (value='$boot_attempts')" >&2
        return 1  # No need to reset
    fi
}

# Function to validate system health
validate_system_health()
{
    echo "Validating system health..."

    local health_ok=1

    # Check if basic system services are running
    if ! pidof init > /dev/null; then
        echo "ERROR: Init process not found"
        health_ok=0
    fi

    # Check if root filesystem is mounted properly
    if ! mountpoint -q /; then
        echo "ERROR: Root filesystem not properly mounted"
        health_ok=0
    fi

    # Check if we can write to filesystem
    if ! touch /tmp/ota_health_check 2>/dev/null; then
        echo "ERROR: Cannot write to filesystem"
        health_ok=0
    else
        rm -f /tmp/ota_health_check
    fi

    # Check essential directories
    for dir in /bin /sbin /lib /usr /etc; do
        if [ ! -d "$dir" ]; then
            echo "ERROR: Essential directory $dir missing"
            health_ok=0
        fi
    done

    # Check xOTA
    if [ ! -x "$OTA_TOOL" ]; then
        echo "ERROR: xOTA tool not accessible"
        health_ok=0
    fi

    # Check misc
    if [ ! -c "$MISC_DEVICE" ] && [ ! -b "$MISC_DEVICE" ]; then
        echo "ERROR: Misc device $MISC_DEVICE not accessible"
        health_ok=0
    fi

    if [ $health_ok -eq 1 ]; then
        echo "System health validation: PASSED"
    else
        echo "System health validation: FAILED"
    fi

    return $health_ok
}

# Function to handle boot failure  
handle_boot_failure()
{
    local current_slot=$1

    echo "CRITICAL: Boot validation failed for slot $current_slot"

    # Mark current slot as failed
    echo "Marking slot $current_slot as failed..."
    "$OTA_TOOL" --set-label -t "$current_slot" -n successful -v 0
    "$OTA_TOOL" --set-label -t "$current_slot" -n bootable -v 0

    # Switch to other slot
    local other_slot
    if [ "$current_slot" = "A" ]; then
        other_slot="B"
    else
        other_slot="A"
    fi

    echo "Switching to fallback slot $other_slot..."
    "$OTA_TOOL" --set-label -t "$other_slot" -n active -v 1

    # Reset the boot_attempts of the fallback slot
    "$OTA_TOOL" --set-label -t "$other_slot" -n boot_attempts -v 0

    echo "Rebooting to slot $other_slot in 3 seconds..."
    sync
    sleep 3
    reboot
}

handle_normal_boot()
{
    local current_slot=$1
    local slot_info=$2

    echo "Processing normal boot for slot $current_slot..."

    if should_reset_boot_attempts "$current_slot" "$slot_info"; then
        local boot_attempts=$(parse_slot_attribute "$current_slot" "Boot attempts" "$slot_info")
        echo "Detected boot_attempts=$boot_attempts for slot $current_slot"

        reset_boot_attempts "$current_slot"

        echo "Normal boot processing completed"
    else
        echo "Boot attempts already at 0, no reset needed"
    fi
}

# Main function
ota_validation()
{
    echo "=== Starting Enhanced OTA Validation ==="
    echo "Compatible with ab_boot boot_attempts system"

    # Check if xOTA tool exists
    if [ ! -x "$OTA_TOOL" ]; then
        echo "ERROR: xOTA tool not found at $OTA_TOOL"
        return 1
    fi

    # Get current slot
    current_slot=$(get_current_slot)
    if [ -z "$current_slot" ]; then
        echo "ERROR: Cannot determine current slot"
        return 1
    fi

    echo "Current active slot: $current_slot"

    # Get slot information
    slot_info=$(get_slot_info)
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to get slot information"
        return 1
    fi

    echo "Slot information retrieved successfully"

    echo "DEBUG: Complete slot info:" >&2
    echo "$slot_info" >&2

    # If first boot after OTA
    if is_first_boot_after_ota "$current_slot" "$slot_info"; then
        echo "=== FIRST BOOT AFTER OTA DETECTED ==="

        if validate_system_health; then
            echo "=== SYSTEM HEALTH CHECK: PASSED ==="

            mark_slot_successful "$current_slot"

            reset_boot_attempts "$current_slot"

            echo "=== OTA VALIDATION: SUCCESS ==="
        else
            echo "=== SYSTEM HEALTH CHECK: FAILED ==="
            handle_boot_failure "$current_slot"
            return 1
        fi
    # Not first, thus is normal boot
    else
        echo "=== NORMAL BOOT DETECTED ==="

        handle_normal_boot "$current_slot" "$slot_info"

        echo "=== NORMAL BOOT PROCESSING: COMPLETED ==="
    fi

    echo "=== FINAL SLOT STATUS ==="
    "$OTA_TOOL" --slot

    echo "=== OTA VALIDATION SERVICE: COMPLETED ==="
    return 0
}

# Script main logic
case "$1" in
    start)
        echo "Starting Enhanced OTA validation service..."
        ota_validation
        ;;
    stop)
        echo "OTA validation service stopped"
        ;;
    restart)
        $0 stop
        $0 start
        ;;
    status)
        if [ -x "$OTA_TOOL" ]; then
            echo "=== OTA VALIDATION SERVICE STATUS ==="
            current_slot=$(get_current_slot)
            echo "Current slot: $current_slot"
            "$OTA_TOOL" --slot
        else
            echo "ERROR: OTA tool not available"
        fi
        ;;
    reset-attempts)
        echo "Manually resetting all boot attempts..."
        reset_all_boot_attempts
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|reset-attempts}"
        echo ""
        echo "  start          - Run OTA boot validation"
        echo "  stop           - Stop OTA validation service"  
        echo "  restart        - Restart OTA validation service"
        echo "  status         - Show current OTA status"
        echo "  reset-attempts - Manually reset all boot attempts counters"
        echo ""
        echo "Enhanced version compatible with ab_boot boot_attempts system"
        exit 1
        ;;
esac

exit $?