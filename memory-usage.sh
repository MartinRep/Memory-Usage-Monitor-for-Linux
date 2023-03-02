#!/bin/bash

# Set the search term to look for in process names
search_term="wom"

# Set the log file path to save memory usage data
log_path="/var/log/memory-usage.log"

# Set the minimum disk space percentage to check for
min_disk_space=3

# Function to check available disk space and stop script if below minimum threshold
function check_disk_space {
    # Get available disk space in bytes
    available_space=$(df / | awk 'NR==2 {print $4}')

    # Get total disk space in bytes
    total_space=$(df / | awk 'NR==2 {print $2}')

    # Calculate available disk space percentage
    available_percent=$((available_space * 100 / total_space))

    # Check if available disk space is below minimum threshold
    if [ $available_percent -lt $min_disk_space ]; then
        echo "Stopping script - low disk space"
        exit 1
    fi
}

# Loop continuously until script is stopped
while true; do
    # Get process IDs of processes containing search term
    pids=$(pgrep $search_term)

    # Loop through each process and record memory usage
    for pid in $pids; do
        # Get process name
        process_name=$(ps -p $pid -o comm=)

        # Get memory usage in MB
        memory_usage=$(pmap $pid | tail -1 | awk '{print $2}' | sed 's/K//' | awk '{print $1/1024}')

        # Get current date and time
        current_date=$(date +"%Y-%m-%d %H:%M:%S")

        # Save memory usage data to log file
        echo "$current_date - $process_name - $memory_usage MB" >> $log_path
    done

    # Calculate average memory usage of all processes
    average_memory=$(pmap $(pgrep $search_term) | tail -1 | awk '{print $2}' | sed 's/K//' | awk '{s+=$1} END {print s/1024}')

    # Get current date and time
    current_date=$(date +"%Y-%m-%d %H:%M:%S")

    # Save average memory usage data to log file
    echo "$current_date - Average memory usage: $average_memory MB" >> $log_path

    # Check available disk space and stop script if below minimum threshold
    check_disk_space

    # Wait for 60 seconds before starting next iteration
    sleep 60
done
