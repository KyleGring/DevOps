@echo off
NET SESSION >nul 2>&1
if %errorLevel% == 0 (
    echo Success: Administrative permissions confirmed.
) else (
    echo Failure: Current permissions inadequate.
    powershell Start-Process '%~dpnx0' -Verb RunAs
    exit /b
)

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {     Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""     exit }  # Now run with admin rights $scriptPath = "C:\Users\Kyle\Desktop\Development\Project_Browser\secure-system-info.ps1" . $scriptPath

