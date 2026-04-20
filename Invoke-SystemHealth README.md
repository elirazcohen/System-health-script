A PowerShell function that performs a full real-time health check of a Windows machine — monitoring CPU usage, RAM consumption, and disk space across all active drives. Outputs color-coded results to the console and logs warnings to a persistent log file.
Built as part of the System Admin Toolkit — a self-taught PowerShell automation project.

Features

CPU Monitoring — Reads live CPU usage via Performance Counters and warns if usage exceeds 80%
RAM Monitoring — Calculates used/free memory in GB and warns if usage exceeds 80%
Disk Monitoring — Loops through all active drives and warns if free space drops below 10GB
Color-coded Console Output — Green for normal, Red/Yellow for warnings, Cyan for info
Persistent Logging — Appends timestamped warnings and errors to SystemHealth_log.txt
Auto Log Rotation — Automatically trims the log to the last 1000 lines if it exceeds 5MB
Error Handling — Every section wrapped in try/catch to capture and log failures gracefully


Demo
Show Image

Requirements

Windows OS
PowerShell 5.1 or later
Run as Administrator (required for Performance Counters)


Usage
powershell# Import and run the function
. .\Invoke-SystemHealth.ps1
Invoke-SystemHealth

Output Example
RAM usage normal (24.17 GB / 31.06 GB)
CPU Usage: 2.87 %
Drive C: Used = 519.41 GB, Free = 411.27 GB
There is enough space on drive C

Thresholds
MetricWarning ThresholdCPU Usage> 80%RAM Usage> 80%Drive Free Space< 10 GB

Log File
Warnings and errors are logged to SystemHealth_log.txt in the same directory as the script.
Example log entry:
[2026-04-20 17:22:01] WARNING: RAM usage high (26.5 GB / 31.06 GB)
[2026-04-20 17:22:01] WARNING: CPU usage HIGH | CPU Usage: 85.43 %
[2026-04-20 17:22:01] WARNING: Low space on drive D
The log file is automatically trimmed to the last 1000 lines if it exceeds 5MB, preventing it from growing indefinitely.

Author
Eliraz Cohen
Self-taught sysadmin enthusiast. Built this toolkit to understand how Windows systems and networks actually work — not just how to click through GUIs.
