#!/usr/bin/env bats

@test "Test memory usage script" {
    # Set the search term
    search_term="wom"

    # Get the current date for the log file name
    log_date=$(date +%Y-%m-%d)

    # Set the log file path with current date
    log_file="/path/to/log/file-$log_date.log"

    # Run the script in the background
    /path/to/memory-usage.sh &

    # Wait for the script to start writing to the log file
    sleep 5

    # Check that the log file exists
    [ -f "$log_file" ]

    # Check that the log file contains data
    [ "$(cat $log_file | wc -l)" -gt 0 ]

    # Stop the script
    pkill -f "memory-usage.sh"
}
