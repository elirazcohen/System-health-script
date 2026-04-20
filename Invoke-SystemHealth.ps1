function Invoke-SystemHealth {
# assigning variables for CPU, RAM and Drives and the log file
$LogFile = "$PSScriptRoot\SystemHealth_log.txt"

$CPU = Get-Counter "\Processor(_Total)\% Processor Time"
$RAM = Get-CimInstance Win32_OperatingSystem
$Drives = Get-Volume | Where-Object { $_.DriveLetter -ne $null }

 # --- LOG SIZE PROTECTION ---
$maxSizeMB = 5

if (Test-Path $LogFile) {

$fileSizeMB = (Get-Item $LogFile).Length / 1MB

if ($fileSizeMB -gt $maxSizeMB) {

$lastLines = Get-Content $LogFile -Tail 1000

Set-Content -Path $LogFile -Value $lastLines

Write-Host "Log exceeded $maxSizeMB MB, trimmed to last 1000 lines." -ForegroundColor Yellow
}
}
# Calculating RAM with error handling in case it fails
try {
$TotalGB = [math]::Round($RAM.TotalVisibleMemorySize / 1MB, 2)
$FreeGB  = [math]::Round($RAM.FreePhysicalMemory / 1MB, 2)
$RAMUsedGB = $TotalGB - $FreeGB

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss" 

if ($RAMUsedGB / $TotalGB * 100 -gt 80) {
# Outputting and logging Warning of RAM usage 
Write-Host "$($timestamp) WARNING: RAM usage high ($RAMUsedGB GB / $TotalGB GB)" -ForegroundColor Red
Add-Content -Path $LogFile -Value "[$timestamp] WARNING: RAM usage high ($RAMUsedGB GB / $TotalGB GB)`n"
# Checking if RAM usage is normal
} else {
Write-Host "RAM usage normal ($RAMUsedGB GB / $TotalGB GB)" -ForegroundColor Green
}
# Checking for failure in case getting RAM usage fails
} catch {
Write-Host "FAILED to get RAM usage"
Add-Content -Path $LogFile -Value "[$timestamp] FAILED to get RAM usage"
} 
# Calculating CPU
try {
$CPUUsage = [math]::Round($CPU.CounterSamples[0].CookedValue, 2)
Write-Host "CPU Usage: $CPUUsage %" -ForegroundColor Cyan
if ($CPUUsage -gt 80) {
# Outputting and logging warning of high CPU usage
Write-Host "WARNING: CPU usage HIGH | CPU Usage: $CPUUsage %"
Add-Content -Path $LogFile -Value "[$timestamp] WARNING: CPU usage HIGH | CPU Usage: $CPUUsage %"
}
} catch {
# Outputting and logging failure of getting CPU usage
Write-Host "FAILED to get CPU usage"
Add-Content -Path $LogFile -Value "[$timestamp] FAILED to get CPU usage"
} 
# Looping through each drive and showing used and free space with error handling in case it fails
try {
foreach ($drive in $Drives) {
$DriveUsedGB = [math]::Round(($drive.Size - $drive.SizeRemaining)/1GB, 2)
$DriveFreeGB = [math]::Round($drive.SizeRemaining/1GB, 2)

Write-Host "Drive $($drive.DriveLetter): Used = $DriveUsedGB GB, Free = $DriveFreeGB GB" -ForegroundColor Yellow

# Warning the user of low space on drives and logging it to file
if ($drive.SizeRemaining -lt 10GB) {
Write-Host "WARNING: Low space on drive $($drive.DriveLetter)" -ForegroundColor DarkRed
Add-Content -Path $LogFile -Value "[$timestamp] WARNING: Low space on drive $($drive.DriveLetter) `n"
} else {
# Putting an else in case there is enough space on drives
Write-Host "There is enough space on drive $($drive.DriveLetter)" -ForegroundColor DarkGreen
}
}
# Checking for failure of getting disk usage on drives
} catch {
Write-Host "FAILED to get disk usage on drives"
Add-Content -Path $LogFile -Value "[$timestamp] FAILED to get space usage"
}
}
