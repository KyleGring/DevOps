# Force Admin Privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Define Log Directory & File
$LogDir = "C:\DevOps\Projects\active\Windows_Privacy_Optimization\Logs"
$LogFile = "$LogDir\NetworkOptimization.log"

# Ensure Log Directory Exists
if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Function to log output
function Log {
    param ([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -Append -FilePath $LogFile
}

# Start Logging
Clear-Content -Path $LogFile -ErrorAction SilentlyContinue
Log "=== Network & Firewall Optimization Started ==="

# Auto-detect network settings
$WiFiProfile = Get-NetConnectionProfile | Where-Object { $_.InterfaceAlias -match "Wi-Fi" }
$EthernetProfile = Get-NetConnectionProfile | Where-Object { $_.InterfaceAlias -match "Ethernet" }

# Determine which connection to use
if ($WiFiProfile) {
    $CurrentSSID = $WiFiProfile.Name
    $CurrentIP = (Get-NetIPAddress -InterfaceAlias "Wi-Fi" -AddressFamily IPv4).IPAddress
    $NetworkInterface = "Wi-Fi"
} elseif ($EthernetProfile) {
    $CurrentSSID = "Ethernet"
    $CurrentIP = (Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4).IPAddress
    $NetworkInterface = "Ethernet"
} else {
    Log "❌ No active network found! Please connect to a network and retry."
    Write-Host "❌ No active network detected. Opening log..." -ForegroundColor Red
    Start-Process notepad.exe -ArgumentList $LogFile
    exit
}

# Detect Gateway & DNS
$CurrentGateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Select-Object -First 1).NextHop
if (-not $CurrentGateway) { $CurrentGateway = "192.168.1.1" }  # Default fallback
$CurrentDNSList = (Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses
$DNS1 = $CurrentDNSList[0]; if (-not $DNS1) { $DNS1 = "8.8.8.8" }
$DNS2 = $CurrentDNSList[1]; if (-not $DNS2) { $DNS2 = "1.1.1.1" }

# Suggest a Static IP in the detected subnet
$IPParts = $CurrentIP -split "\."
$SuggestedStaticIP = if ($IPParts.Count -ge 3) { "$($IPParts[0]).$($IPParts[1]).$($IPParts[2]).50" } else { "192.168.1.50" }

# Ask user if they want to use detected values or customize
$UseDefaults = Read-Host "Do you want to use detected network settings? (yes/no)"
if ($UseDefaults -eq "no") {
    # Prompt user for input (allows manual overrides)
    $WiFiSSID = Read-Host "Enter your Wi-Fi SSID (Auto-detected: $CurrentSSID)" -Default $CurrentSSID
    $HomeIP = Read-Host "Enter your Home Device IP (Auto-detected: $CurrentIP)" -Default $CurrentIP
    $StaticIP = Read-Host "Enter your desired Static IP (Suggested: $SuggestedStaticIP)" -Default $SuggestedStaticIP
    $Gateway = Read-Host "Enter your Default Gateway (Auto-detected: $CurrentGateway)" -Default $CurrentGateway
    $DNS1 = Read-Host "Enter your Primary DNS (Auto-detected: $DNS1)" -Default $DNS1
    $DNS2 = Read-Host "Enter your Secondary DNS (Auto-detected: $DNS2)" -Default $DNS2
} else {
    # Use auto-detected values
    $WiFiSSID = $CurrentSSID
    $HomeIP = $CurrentIP
    $StaticIP = $SuggestedStaticIP
    $Gateway = $CurrentGateway
    $DNS1 = $DNS1
    $DNS2 = $DNS2
}

Log "Using network settings: SSID: $WiFiSSID, IP: $HomeIP, Gateway: $Gateway, DNS: $DNS1, $DNS2"

### Step 1: Ensure Network is Private ###
Log "Checking network profile for SSID: $WiFiSSID..."
$Network = Get-NetConnectionProfile | Where-Object { $_.Name -eq $WiFiSSID }
if ($Network) {
    if ($Network.NetworkCategory -ne "Private") {
        Log "Changing network '$WiFiSSID' to Private..."
        Set-NetConnectionProfile -Name $WiFiSSID -NetworkCategory Private
        Log "✔ Network '$WiFiSSID' successfully set to Private."
    } else {
        Log "✔ Network '$WiFiSSID' is already Private."
    }
} else {
    Log "❌ Network '$WiFiSSID' not found! Ensure you're connected."
}

### Step 2: Set Static IP & DNS ###
Log "Setting Static IP ($StaticIP) and DNS ($DNS1, $DNS2)..."
Start-Sleep -Seconds 3  # Allow network adapter to settle before applying changes
Try {
    New-NetIPAddress -InterfaceAlias $NetworkInterface -IPAddress $StaticIP -PrefixLength 24 -DefaultGateway $Gateway -ErrorAction Stop
    Set-DnsClientServerAddress -InterfaceAlias $NetworkInterface -ServerAddresses ($DNS1, $DNS2)
    $StaticIPAssigned = $true
} Catch {
    Log "❌ Failed to assign Static IP. Error: $_"
    $StaticIPAssigned = $false
}

### Step 3: Validation Summary ###
Log "=== Validation Summary ==="
if ($StaticIPAssigned) {
    Log "✔ Static IP successfully assigned."
} else {
    Log "❌ Static IP not assigned!"
}

if ($DNS1 -in (Get-DnsClientServerAddress -InterfaceAlias $NetworkInterface -AddressFamily IPv4).ServerAddresses) { 
    Log "✔ DNS settings applied successfully." 
} else { 
    Log "❌ DNS settings not applied!"
}

Log "=== Network & Firewall Optimization Completed ==="

# Check for errors and open log if necessary
if (-not $StaticIPAssigned) {
    Write-Host "❌ There was an error applying the Static IP. Opening log..." -ForegroundColor Red
    Start-Process notepad.exe -ArgumentList $LogFile
} else {
    Write-Host "✅ Optimization completed successfully. Log file saved at: $LogFile" -ForegroundColor Green
}


