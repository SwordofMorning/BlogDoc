#!/bin/sh

# S90_mount.sh - Mount vendor, app and userdata partitions with auto-formatting

# Define partition devices and mount points
VENDOR_DEV="/dev/mmcblk0p11"
VENDOR_MOUNT="/vendor"

APP_DEV="/dev/mmcblk0p12" 
APP_MOUNT="/app"

USERDATA_DEV="/dev/mmcblk0p13"
USERDATA_MOUNT="/userdata"

# Function to check if partition exists
check_partition()
{
    local device=$1
    local name=$2

    if [ ! -b "$device" ]; then
        echo "Error: $name partition $device not found"
        return 1
    fi
    return 0
}

# Function to check if partition has filesystem
check_filesystem()
{
    local device=$1
    local name=$2

    echo "Checking $name partition filesystem..."

    # Use blkid to check if partition has filesystem
    local fs_info=$(blkid "$device" 2>/dev/null)

    if [ -n "$fs_info" ]; then
        # Extract filesystem type more reliably
        local fs_type=$(echo "$fs_info" | sed -n 's/.*TYPE="\([^"]*\)".*/\1/p')
        if [ -n "$fs_type" ]; then
            echo "$name partition has $fs_type filesystem"
            return 0
        fi
    fi

    echo "$name partition has no filesystem"
    return 1
}

# Function to get filesystem type
get_filesystem_type()
{
    local device=$1

    # Get filesystem type from blkid
    local fs_type=$(blkid -o value -s TYPE "$device" 2>/dev/null)

    # Clean up the output (remove any extra characters)
    fs_type=$(echo "$fs_type" | tr -d '\n\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Default to ext2 if detection fails
    if [ -z "$fs_type" ]; then
        fs_type="ext2"
    fi

    echo "$fs_type"
}

# Function to format partition
format_partition()
{
    local device=$1
    local name=$2

    echo "Formatting $name partition $device as ext2..."

    # Format with ext2 filesystem
    mkfs.ext2 -F "$device" > /dev/null 2>&1
    local format_result=$?

    if [ $format_result -eq 0 ]; then
        echo "$name partition formatted successfully"
        # Wait a moment for the filesystem to be recognized
        sleep 1
        return 0
    else
        echo "Error: Failed to format $name partition $device"
        return 1
    fi
}

# Function to ensure partition has filesystem
ensure_filesystem()
{
    local device=$1
    local name=$2

    # Check if partition exists
    if ! check_partition "$device" "$name"; then
        return 1
    fi

    # Check if partition has filesystem
    if ! check_filesystem "$device" "$name"; then
        echo "$name partition needs formatting"
        if ! format_partition "$device" "$name"; then
            return 1
        fi
    fi

    return 0
}

# Function to create mount point if not exists
create_mount_point()
{
    local mount_point=$1
    local name=$2

    if [ ! -d "$mount_point" ]; then
        echo "Creating $name mount point: $mount_point"
        mkdir -p "$mount_point"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to create $name mount point $mount_point"
            return 1
        fi
    fi
    return 0
}

# Function to mount partition
mount_partition()
{
    local device=$1
    local mount_point=$2
    local name=$3

    # Check if already mounted
    if mountpoint -q "$mount_point"; then
        echo "$name partition already mounted at $mount_point"
        return 0
    fi

    # Ensure partition has filesystem
    if ! ensure_filesystem "$device" "$name"; then
        return 1
    fi

    # Create mount point
    if ! create_mount_point "$mount_point" "$name"; then
        return 1
    fi

    # Get filesystem type for mounting
    local fs_type=$(get_filesystem_type "$device")

    # Attempt to mount
    echo "Mounting $name partition $device to $mount_point (filesystem: $fs_type)..."

    # Try mounting with detected filesystem type
    mount -t "$fs_type" "$device" "$mount_point"
    local mount_result=$?

    if [ $mount_result -eq 0 ]; then
        echo "$name partition mounted successfully"
        return 0
    else
        echo "Mount with $fs_type failed, trying without filesystem type specification..."
        # Try mounting without specifying filesystem type (auto-detect)
        mount "$device" "$mount_point"
        mount_result=$?
        
        if [ $mount_result -eq 0 ]; then
            echo "$name partition mounted successfully (auto-detected)"
            return 0
        else
            echo "Error: Failed to mount $name partition $device"
            return 1
        fi
    fi
}

# Function to unmount partition
unmount_partition()
{
    local mount_point=$1
    local name=$2

    if mountpoint -q "$mount_point"; then
        echo "Unmounting $name partition from $mount_point..."
        umount "$mount_point"
        if [ $? -eq 0 ]; then
            echo "$name partition unmounted successfully"
        else
            echo "Error: Failed to unmount $name partition from $mount_point"
            return 1
        fi
    else
        echo "$name partition not mounted"
    fi
    return 0
}

# Function to start mounting all partitions
start_mount()
{
    echo "Starting partition mounting..."

    local mount_failed=0

    # Mount vendor partition
    if ! mount_partition "$VENDOR_DEV" "$VENDOR_MOUNT" "vendor"; then
        mount_failed=1
    fi

    # Mount app partition
    if ! mount_partition "$APP_DEV" "$APP_MOUNT" "app"; then
        mount_failed=1
    fi

    # Mount userdata partition
    if ! mount_partition "$USERDATA_DEV" "$USERDATA_MOUNT" "userdata"; then
        mount_failed=1
    fi

    if [ $mount_failed -eq 0 ]; then
        echo ""
        echo "All partitions mounted successfully!"
        echo ""
        
        # Display mount status
        echo "Current mount status:"
        df -h "$VENDOR_MOUNT" "$APP_MOUNT" "$USERDATA_MOUNT" 2>/dev/null || true
    else
        echo "Some partitions failed to mount"
        return 1
    fi

    return 0
}

# Function to stop and unmount all partitions
stop_mount()
{
    echo "Stopping and unmounting partitions..."

    # Unmount in reverse order
    unmount_partition "$USERDATA_MOUNT" "userdata"
    unmount_partition "$APP_MOUNT" "app" 
    unmount_partition "$VENDOR_MOUNT" "vendor"

    echo "Partition unmounting completed"
}

# Function to format all partitions (dangerous operation)
format_all()
{
    echo "WARNING: This will format all data partitions!"
    echo "All data on vendor, app, and userdata partitions will be lost!"
    echo "Press Ctrl+C to cancel, or wait 5 seconds to continue..."

    sleep 5

    echo "Formatting all data partitions..."

    # Stop any mounted partitions first
    stop_mount

    # Format each partition
    for part_info in "$VENDOR_DEV:vendor" "$APP_DEV:app" "$USERDATA_DEV:userdata"; do
        device=$(echo "$part_info" | cut -d: -f1)
        name=$(echo "$part_info" | cut -d: -f2)
        
        if check_partition "$device" "$name"; then
            format_partition "$device" "$name"
        fi
    done

    echo "Formatting completed. Run 'start' to mount partitions."
}

# Function to show mount status
show_status()
{
    echo "Partition mount status:"
    echo "======================"

    for mount_info in "$VENDOR_DEV:$VENDOR_MOUNT:vendor" "$APP_DEV:$APP_MOUNT:app" "$USERDATA_DEV:$USERDATA_MOUNT:userdata"; do
        device=$(echo "$mount_info" | cut -d: -f1)
        mount_point=$(echo "$mount_info" | cut -d: -f2)
        name=$(echo "$mount_info" | cut -d: -f3)

        if [ -b "$device" ]; then
            # Check filesystem
            local fs_type=$(get_filesystem_type "$device")
            if [ "$fs_type" != "ext2" ] || [ -n "$(blkid "$device" 2>/dev/null)" ]; then
                fs_info="($fs_type)"
            else
                fs_info="(no filesystem)"
            fi

            if mountpoint -q "$mount_point"; then
                echo "$name: MOUNTED $fs_info ($device -> $mount_point)"
            else
                echo "$name: NOT MOUNTED $fs_info ($device)"
            fi
        else
            echo "$name: DEVICE NOT FOUND ($device)"
        fi
    done

    echo ""
    echo "Mounted filesystems:"
    df -h | grep -E "(vendor|app|userdata|Filesystem)" || echo "No data partitions mounted"
}

case "$1" in
    start)
        start_mount
        ;;
    stop)
        stop_mount
        ;;
    restart)
        $0 stop
        sleep 1
        $0 start
        ;;
    status)
        show_status
        ;;
    format)
        format_all
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|format}"
        echo ""
        echo "  start   - Mount vendor, app and userdata partitions (auto-format if needed)"
        echo "  stop    - Unmount all data partitions"
        echo "  restart - Stop and start partition mounting"
        echo "  status  - Show current mount status and filesystem types"
        echo "  format  - Format all data partitions (WARNING: destroys data)"
        exit 1
        ;;
esac

exit $?