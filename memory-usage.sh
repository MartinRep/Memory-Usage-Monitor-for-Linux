#!/bin/bash

# Set the search term for processes to monitor
SEARCH_TERM="init"

# Set the log file path
LOG_FILE="./memory-usage.log"

# Get the total system memory in KB
MEM_TOTAL=$(grep 'MemTotal' /proc/meminfo | awk '{print $2}')

# Initialize an empty array to store the previous memory usage for each process
declare -A prev_mem_usage=()

# Loop indefinitely
while true; do
  # Get the current timestamp
  TIMESTAMP=$(date +%s)

  # Loop through all processes containing the search term
  while read -r pid pname; do
    # Get the current memory usage for the process
    mem_usage=$(pmap -x "$pid" | tail -1 | awk '{print $3}')
    mem_usage=${mem_usage/K/} # Remove the "K" at the end of the value

    # If the process was found in a previous iteration, calculate the memory usage delta
    if [[ ${prev_mem_usage[$pid]} ]]; then
      mem_usage_delta=$(echo "$mem_usage - ${prev_mem_usage[$pid]}" | bc)
      mem_usage_delta_pct=$(echo "scale=2; $mem_usage_delta / ${prev_mem_usage[$pid]} * 100" | bc)
      mem_usage_delta_pct=${mem_usage_delta_pct/-/} # Remove the "-" sign from negative percentages
    else
      mem_usage_delta=0
      mem_usage_delta_pct=0
    fi

    # Save the current memory usage as the previous memory usage for the next iteration
    prev_mem_usage[$pid]=$mem_usage

    # Write the memory usage data to the log file
    echo -e "${TIMESTAMP}\t${pid}\t${pname}\t${mem_usage}\t${mem_usage_delta}\t${mem_usage_delta_pct}" >> $LOG_FILE
  done < <(pgrep -f $SEARCH_TERM | xargs -I{} sh -c 'echo "{} $(ps -p {} -o comm=)"')

  # Calculate the average memory usage for each process and print the process with the biggest increase in memory usage
  echo "Average Memory Usage:"
  while read -r pname mem_usage mem_usage_delta mem_usage_delta_pct; do
    mem_usage_pct=$(echo "scale=2; $mem_usage / $MEM_TOTAL * 100" | bc)
    echo -e "${pname}\t${mem_usage}\t${mem_usage_pct}%\t${mem_usage_delta_pct}%"
  done < <(awk -F '\t' '{a[$3]+=$4;b[$3]+=$5}END{for(i in a){print i"\t"a[i]/NR"\t"b[i]/NR}}' $LOG_FILE | sort -k3rn | head -n 1 | awk '{print $1, $2, $3, $4 " (biggest increase)"}')

  # Check the available disk space and exit if it is below 3% of the total disk space
  disk_usage_pct=$(df --output=pcent / | tail -1 | sed 's/%//')
  if [[ $disk_usage_pct -gt 97 ]]; then
    echo "Error: Low disk space. Exiting..."
    exit 1
  fi

  # Wait for 10 seconds before checking again
  sleep 10
done
