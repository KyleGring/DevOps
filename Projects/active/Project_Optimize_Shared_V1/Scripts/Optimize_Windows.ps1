# Run as Admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Optimizing Firewall Rules..."

New-NetFirewallRule -DisplayName "Allow ICMP (Ping)" -Direction Inbound -Protocol ICMPv4 -Action Allow -Profile Any
New-NetFirewallRule -DisplayName "Allow RDP" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Allow -Profile Any
New-NetFirewallRule -DisplayName "Allow SMB" -Direction Inbound -Protocol TCP -LocalPort 445 -Action Allow -Profile Any

New-NetFirewallRule -DisplayName "Block Telnet" -Direction Inbound -Protocol TCP -LocalPort 23 -Action Block -Profile Any
New-NetFirewallRule -DisplayName "Block FTP" -Direction Inbound -Protocol TCP -LocalPort 21 -Action Block -Profile Any

Write-Host "Firewall Rules Optimized!"

