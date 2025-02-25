@echo off
NET SESSION >nul 2>&1
if %errorLevel% == 0 (
    echo Success: Administrative permissions confirmed.
) else (
    echo Failure: Current permissions inadequate.
    powershell Start-Process '%~dpnx0' -Verb RunAs
    exit /b
)

# Folder Structure Script $rootPath = "C:\Users\Kyle\Desktop\Development\Project_Browser"  $folders = @(     "src",     "src\scripts",     "src\scripts\powershell",     "src\scripts\batch",     "config",     "docs",     "tools",     "logs",     "backups" )  # Create folders foreach ($folder in $folders) {     $path = Join-Path $rootPath $folder     if (-not (Test-Path $path)) {         New-Item -Path $path -ItemType Directory -Force         Write-Host "Created folder: $path"     } }  # Move files to appropriate folders $fileMapping = @{     "src\scripts\powershell" = @("*.ps1")     "src\scripts\batch" = @("*.bat")     "config" = @("*.json", "*.template")     "docs" = @("*.md") }  foreach ($folder in $fileMapping.Keys) {     $targetPath = Join-Path $rootPath $folder     foreach ($pattern in $fileMapping[$folder]) {         Get-ChildItem -Path $rootPath -Filter $pattern |          Move-Item -Destination $targetPath -Force     } }  Write-Host "Folder structure organized."

