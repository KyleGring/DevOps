# monitor_system
# Created: 2025-02-23
# Purpose: Script for Project Browser setup

# Ensure admin rights
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File "C:\Users\Kyle\Desktop\Development\Project_Browser\initial-setup.ps1"" -Verb RunAs
    exit
}

# Main script content

