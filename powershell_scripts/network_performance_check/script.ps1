# Define parameters
$interfaceName = "Ethernet 2"  # Change this to your actual network interface name
$logFile = "C:\Users\Admin\Desktop\NetworkPerformanceLog.txt"  # Change this to your desired log file path
$interval = 10  # Interval in seconds
$duration = 60  # Total duration to monitor in seconds

# Function to get network performance
function Get-NetworkPerformance {
    $interface = Get-NetAdapter -Name $interfaceName
    if ($null -eq $interface) {
        Write-Host "Network interface $interfaceName not found."
        return
    }

    # Get interface statistics
    $stats = Get-NetAdapterStatistics -Name $interfaceName

    # Check for outbound packets sent before calculating packet loss
    if ($stats.OutboundUnicastPacketsSent -gt 0) {
        $packetLoss = ($stats.OutboundUnicastPacketsDropped / $stats.OutboundUnicastPacketsSent) * 100
    } else {
        $packetLoss = 0  # Set packet loss to 0 if no outbound packets have been sent
    }

    # Test network connectivity
    $pingResult = Test-Connection -ComputerName 8.8.8.8 -Count 1 -ErrorAction SilentlyContinue
    if ($pingResult) {
        $latency = $pingResult.ResponseTime
    } else {
        $latency = "Request Timed Out"
    }

    # Log performance
    $logEntry = "$(Get-Date) - Interface: $interfaceName, " +
                "ReceivedBytes: $($stats.ReceivedBytes), " +
                "SentBytes: $($stats.SentBytes), " +
                "PacketLoss: $([math]::round($packetLoss, 2))%, " +
                "Latency: $latency ms"
    
    # Append log entry to file
    Add-Content -Path $logFile -Value $logEntry
    Write-Host $logEntry
}

# Start monitoring
$endTime = (Get-Date).AddSeconds($duration)
while ((Get-Date) -lt $endTime) {
    Get-NetworkPerformance
    Start-Sleep -Seconds $interval
}

Write-Host "Monitoring complete. Log saved to $logFile."
