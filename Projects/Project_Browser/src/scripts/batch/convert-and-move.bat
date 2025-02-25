﻿@echo off
NET SESSION >nul 2>&1
if %errorLevel% == 0 (
    echo Success: Administrative permissions confirmed.
) else (
    echo Failure: Current permissions inadequate.
    powershell Start-Process '%~dpnx0' -Verb RunAs
    exit /b
)

# Script to convert text files and organize $rootPath = "C:\Users\Kyle\Desktop\Development\Project_Browser"  function Convert-TextToPs1 {     param($textFile)     $content = Get-Content $textFile     $ps1Content = @" # Auto-elevate to admin if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {     Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""     exit }  $content "@     $ps1File = [System.IO.Path]::ChangeExtension($textFile, "ps1")     $ps1Content | Set-Content $ps1File -Force     return $ps1File }  function Convert-TextToBat {     param($textFile)     $content = Get-Content $textFile     $batContent = @" @echo off NET SESSION >nul 2>&1 if %errorLevel% == 0 (     echo Success: Administrative permissions confirmed. ) else (     echo Failure: Current permissions inadequate.     powershell Start-Process '%~dpnx0' -Verb RunAs     exit /b )  $content "@     $batFile = [System.IO.Path]::ChangeExtension($textFile, "bat")     $batContent | Set-Content $batFile -Force     return $batFile }  # Get all text files $textFiles = Get-ChildItem -Path $rootPath -Filter "*.txt"  foreach ($file in $textFiles) {     # Skip specific files     if ($file.Name -match "README|LICENSE|CHANGELOG") { continue }          # Convert to PS1     $ps1File = Convert-TextToPs1 $file.FullName     Move-Item $ps1File "$rootPath\src\scripts\powershell\" -Force          # Convert to BAT     $batFile = Convert-TextToBat $file.FullName     Move-Item $batFile "$rootPath\src\scripts\batch\" -Force          # Move original text file to docs     Move-Item $file.FullName "$rootPath\docs\" -Force }  Write-Host "Files converted and organized."

