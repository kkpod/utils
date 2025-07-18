#!/bin/bash
#
# CPU Monitoring Script - cpu_monitor.sh
#
# Description:
#   This script monitors the system's CPU usage every 10 seconds for 24 hours.
#   If the CPU usage exceeds a specified threshold (default: 90%), it captures
#   a snapshot of the current system state using both `top` and `ps` commands.
#   This is useful for diagnosing high CPU usage by identifying the top
#   resource-consuming processes at the time of the spike.
#
# Features:
#   - Checks CPU usage every 10 seconds (configurable)
#   - Logs only when CPU usage exceeds the threshold
#   - Captures a 3-iteration sample of `top` output (with 1s delay between)
#   - Logs the top 20 CPU-consuming processes using `ps`
#   - Runs for 24 hours (configurable)
#
# Output:
#   - Appends logs to a file named `cpu_peak_log.txt` in the current directory
#
# Usage:
#   chmod +x cpu_monitor.sh
#   ./cpu_monitor.sh
#
#   You can also run it in the background:
#   nohup ./cpu_monitor.sh &
#
# Customization:
#   - Adjust INTERVAL for frequency (in seconds)
#   - Adjust CPU_THRESHOLD to set the alert level
#   - Adjust DURATION to change the total run time (in seconds)
#   - Change LOG_FILE to rename or redirect output
#

# CONFIGURATION
DURATION=86400               # Run for 1 day = 86400 seconds
INTERVAL=10                  # Sampling interval in seconds
CPU_THRESHOLD=90.0           # CPU usage threshold to trigger logging
LOG_FILE="cpu_peak_log.txt"  # Output log file

# Start time
START_TIME=$(date +%s)

echo "Monitoring started at $(date)" > "$LOG_FILE"

while [ $(( $(date +%s) - START_TIME )) -lt $DURATION ]; do
    # Get current CPU usage using top
    CPU_USAGE=$(top -b -n 1 | awk -F'id,' '/Cpu\(s\):/ { split($1, a, ","); print 100 - a[length(a)] }')
    CPU_USAGE=$(printf "%.1f" "$CPU_USAGE")  # Format to 1 decimal

    echo "$(date): CPU usage = $CPU_USAGE%"  # Optional live log

    usage_exceeded=$(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc)

    if [ "$usage_exceeded" -eq 1 ]; then
        echo "High CPU usage detected at $(date)! CPU = $CPU_USAGE%" >> "$LOG_FILE"
        echo "------ TOP SNAPSHOT (last 30 lines) ------" >> "$LOG_FILE"
        top -b -d 1 -n 3 | tail -n 30 >> "$LOG_FILE"
        echo "------ TOP PROCESSES (ps) ------" >> "$LOG_FILE"
        ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 20 >> "$LOG_FILE"
        echo "----------------------------------------" >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"
    fi

    sleep "$INTERVAL"
done

echo "Monitoring finished at $(date)" >> "$LOG_FILE"
