#!/bin/bash

# Function to check if a process is running
check_process() {
    pgrep -x "$1" >/dev/null
    return $?
}

# Function to wait for process to start
wait_for_process() {
    local process_name=$1
    local max_attempts=30  # Maximum number of attempts (30 * 0.1 = 3 seconds)
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if check_process "$process_name"; then
            return 0
        fi
        sleep 0.1
        attempt=$((attempt + 1))
    done
    return 1
}

# 1. Check and kill ui_key if exists
if check_process "ui_key"; then
    echo "Stopping ui_key..."
    killall ui_key
    sleep 0.5  # Give some time for ui_key to clean up
fi

# 2. Check and kill weston if exists
if check_process "weston"; then
    echo "Stopping weston..."
    killall weston
    
    # 3. Wait for weston to completely stop
    while check_process "weston"; do
        sleep 0.1
    done
    echo "Weston stopped"
fi

# 4. Start weston in background
echo "Starting weston..."
weston &

# 5. Wait for weston to fully start
if wait_for_process "weston"; then
    echo "Weston started successfully"
    
    # Additional wait to ensure weston is fully initialized
    sleep 1
    
    # 6. Start ui_key
    echo "Starting ui_key..."
    /root/ui_key &
    
    # Wait for ui_key to start
    if wait_for_process "ui_key"; then
        echo "ui_key started successfully"
    else
        echo "Error: ui_key failed to start"
        exit 1
    fi
else
    echo "Error: Weston failed to start"
    exit 1
fi

echo "All processes started successfully"