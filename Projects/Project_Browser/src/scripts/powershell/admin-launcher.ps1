﻿# Auto-elevate to admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -File """
    exit
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {     Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""     exit }  # Now run with admin rights $scriptPath = "C:\Users\Kyle\Desktop\Development\Project_Browser\secure-system-info.ps1" . $scriptPath

