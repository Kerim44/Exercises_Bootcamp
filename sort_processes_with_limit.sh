#!/bin/bash

# Prompt the user for sorting criteria
echo "How would you like to sort the processes?"
echo "1. By memory usage"
echo "2. By CPU usage"
read -p "Enter the number of your choice (1 or 2): " choice

# Validate user input
if [[ "$choice" != "1" && "$choice" != "2" ]]; then
    echo "Invalid choice. Exiting."
    exit 1
fi

# Define sorting options
if [ "$choice" -eq 1 ]; then
    sort_option="rss"
    sort_field="MEM%"
elif [ "$choice" -eq 2 ]; then
    sort_option="pcpu"
    sort_field="CPU%"
fi

# Get the list of processes
echo "Fetching process list sorted by $sort_field..."

# Extract and sort processes based on user choice
ps -eo pid,comm,%mem,%cpu --sort=-$sort_option | awk '
BEGIN {
    printf "%-10s %-30s %-10s %-10s\n", "PID", "COMMAND", "MEMORY", "CPU"
}
NR>1 {
    printf "%-10s %-30s %-10s %-10s\n", $1, $2, $3, $4
}'

# Note: The ps options are:
# -e: Select all processes
# -o: Format output
# --sort: Sort processes by specified field (e.g., -rss for memory, -pcpu for CPU)

