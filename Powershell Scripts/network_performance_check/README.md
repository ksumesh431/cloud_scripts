# Network Performance Monitoring Script

## Overview

This PowerShell script is designed to monitor network performance by tracking metrics such as received and sent bytes, packet loss, and latency. It logs these metrics to a specified file for review. The script can be customized to monitor different network interfaces and intervals.

## Features

- Monitors specified network interface.
- Logs the following metrics:
  - Received Bytes
  - Sent Bytes
  - Packet Loss Percentage
  - Latency (in milliseconds)
- Saves the log to a specified file.

## Requirements

- Windows operating system with PowerShell.
- Administrative privileges may be required to access network adapter statistics.

## Usage

1. **Clone or Download the Script**
   - Save the script to a desired location on your computer, e.g., `MonitorNetworkPerformance.ps1`.

2. **Open PowerShell**
   - Run PowerShell as an administrator.

3. **Edit Parameters in the Script**
   - Open the script in a text editor (like Notepad) and update the following parameters:
     ```powershell
     $interfaceName = "Ethernet 2"  # Change this to your actual network interface name
     $logFile = "C:\Users\Admin\Desktop\NetworkPerformanceLog.txt"  # Change this to your desired log file path
     $interval = 10  # Interval in seconds
     $duration = 60  # Total duration to monitor in seconds
     ```
   - Make sure to set `$interfaceName` to the correct network adapter name as seen in your system.
   - Update `$logFile` to your preferred log file location.

4. **Run the Script**
   - In PowerShell, navigate to the directory where the script is saved.
   - Execute the script by typing:
     ```powershell
     .\MonitorNetworkPerformance.ps1
     ```

5. **View the Log**
   - After the monitoring is complete, check the log file specified in `$logFile` for the recorded metrics.

## Example Log Entry

An example log entry might look like this:

```
11/04/2024 21:19:05 - Interface: Ethernet 2, ReceivedBytes: 21259556, SentBytes: 1823922, PacketLoss: 0%, Latency: 1 ms
```

## Troubleshooting

- If you encounter an error regarding the network interface not found, verify the name of your network adapter by running:
  ```powershell
  Get-NetAdapter | Select-Object Name, Status
  ```
- If you see "Attempted to divide by zero", it means there were no outbound packets sent during the monitoring period. This is handled in the script, setting packet loss to 0.

## Conclusion

This script provides a simple way to monitor network performance over time. Feel free to modify the parameters to suit your monitoring needs.
