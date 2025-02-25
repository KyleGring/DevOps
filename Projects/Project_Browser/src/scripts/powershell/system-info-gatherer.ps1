﻿# Auto-elevate to admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -File """
    exit
}

# System Information Gathering Script function Get-SystemProfile {     # System Info     $systemInfo = Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber     $computerSystem = Get-CimInstance Win32_ComputerSystem     $processor = Get-CimInstance Win32_Processor     $memory = [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB)          # Chrome Info     $chrome = Get-ItemProperty HKCU:\Software\Google\Chrome\BLBeacon -ErrorAction SilentlyContinue          # Drive Info     $driveInfo = Get-PSDrive G | Select-Object Name, Used, Free          # Network Info     $network = Get-NetAdapter | Where-Object Status -eq 'Up'          # Create report     $report = @{         System = @{             OS = $systemInfo.Caption             Version = $systemInfo.Version             Build = $systemInfo.BuildNumber             RAM = "$memory GB"             CPU = $processor.Name             Manufacturer = $computerSystem.Manufacturer             Model = $computerSystem.Model         }         Chrome = @{             Version = $chrome.version             LastUpdate = $chrome.LastUpdateTime         }         Drive = @{             Name = $driveInfo.Name             FreeSpace = [math]::Round($driveInfo.Free/1GB)             UsedSpace = [math]::Round($driveInfo.Used/1GB)         }         Network = @{             Name = $network.Name             Speed = $network.LinkSpeed             Type = $network.InterfaceDescription         }     }      # Export to JSON     $report | ConvertTo-Json -Depth 4 |      Out-File "C:\Users\Kyle\Desktop\Development\Project_Browser\system_profile.json"      return $report }  # Execute and show results $systemProfile = Get-SystemProfile $systemProfile | Format-List

