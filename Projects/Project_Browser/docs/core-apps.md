# Windows 11 Core Applications Setup

## Browser Setup (Primary)
### Arc Browser
- Installation: Download from arc.net
- Features to enable:
  - Split view
  - Spaces for work/personal
  - Command bar
  - Boost for Notion
  - Tab management
  - Configure Little Arc for quick access

### Google Chrome (Secondary)
- Installation: `winget install -e --id Google.Chrome`
- Performance settings:
  - Enable hardware acceleration
  - Configure preload settings
  - Memory saver (except for Notion tabs)
  - Performance mode in Windows settings
- Essential Extensions (sync across browsers):
  1. Privacy & Security:
     - uBlock Origin: Advanced ad blocking
     - Bitwarden/1Password: Password management
     - Privacy Badger: Tracker blocking
     - HTTPS Everywhere: Secure browsing

  2. Productivity:
     - Notion Web Clipper: Enhanced with AI
     - Grammarly: Writing assistance
     - MultiLogin: Profile management
     - Tab Manager Plus: Organization

  3. Development:
     - React/Redux DevTools: React debugging
     - JSON Formatter: API response viewing
     - Wappalyzer: Tech stack analysis
     - GitHub Copilot: Code suggestions

  4. Quality of Life:
     - Dark Reader: Eye strain reduction
     - SponsorBlock: Video optimization
     - Picture-in-Picture: Video multitasking
     - Translation tools

## Essential Applications
```powershell
# Core apps installation script (Windows 11)
winget install -e --id Notion.Notion
winget install -e --id Microsoft.WindowsTerminal
winget install -e --id Git.Git
winget install -e --id Microsoft.PowerToys
winget install -e --id 7zip.7zip
winget install -e --id VideoLAN.VLC
winget install -e --id ShareX.ShareX
winget install -e --id Discord.Discord
```

## Windows 11 Optimizations
1. System Settings:
   - Enable Hardware-accelerated GPU scheduling
   - Set power mode to "Best performance"
   - Enable Virtual Memory optimization
   - Configure Windows Update for security patches

2. Notion Optimization:
   - Run as administrator first time
   - Set high priority in Task Manager
   - Allow through Windows Defender
   - Configure offline access
   - Set startup behavior

3. Browser Profile Organization:
   ```
   Arc:
   - Work Space: Notion, Email, Calendar
   - Personal Space: Entertainment, Shopping
   - Development Space: GitHub, Documentation
   
   Chrome:
   - Default: Alternative for compatibility
   - Testing: For web development
   ```

## Additional Tools
```powershell
# Optional tools based on usage
winget install -e --id Microsoft.PowerToys
winget install -e --id voidtools.Everything
winget install -e --id Spotify.Spotify
winget install -e --id CPUID.CPU-Z
winget install -e --id OBSProject.OBSStudio
```

## Comprehensive File & Protocol Associations

# Check Current Associations Script
```powershell
# Check and Set File Associations
$defaultAssociations = @{
    # Web & Development
    '.html' = 'ArcHTML'  # Primary browser
    '.htm' = 'ArcHTML'
    '.mhtml' = 'ChromeHTML'  # Better compatibility
    '.css' = 'VSCode.css'    # Better for development
    '.js' = 'VSCode.js'
    '.jsx' = 'VSCode.jsx'
    '.ts' = 'VSCode.ts'
    '.tsx' = 'VSCode.tsx'
    '.json' = 'VSCode.json'
    '.md' = 'VSCode.md'
    '.xml' = 'VSCode.xml'
    '.yaml' = 'VSCode.yaml'
    '.yml' = 'VSCode.yml'
    '.env' = 'VSCode.env'
    '.config' = 'VSCode.config'
    '.gitignore' = 'VSCode.gitignore'
    '.npmrc' = 'VSCode.npmrc'
    
    # Documents
    '.pdf' = 'SumatraPDF'  # Lightweight, fast PDF reader
    '.epub' = 'SumatraPDF'
    '.mobi' = 'SumatraPDF'
    '.doc' = 'Word.Document.12'
    '.docx' = 'Word.Document.12'
    '.docm' = 'Word.Document.12'
    '.xls' = 'Excel.Sheet.12'
    '.xlsx' = 'Excel.Sheet.12'
    '.xlsm' = 'Excel.Sheet.12'
    '.csv' = 'Excel.Sheet.12'  # Better Excel handling for data
    '.ppt' = 'PowerPoint.Show.12'
    '.pptx' = 'PowerPoint.Show.12'
    '.txt' = 'VSCode.txt'
    '.rtf' = 'WordPad.Document.1'
    '.log' = 'VSCode.log'  # Better for log analysis
    '.conf' = 'VSCode.conf'
    '.ini' = 'VSCode.ini'
    
    # Media (VLC for all media - best codec support)
    '.mp4' = 'VLC.mp4'
    '.mkv' = 'VLC.mkv'
    '.avi' = 'VLC.avi'
    '.mov' = 'VLC.mov'
    '.wmv' = 'VLC.wmv'
    '.flv' = 'VLC.flv'
    '.webm' = 'VLC.webm'
    '.m4v' = 'VLC.m4v'
    '.mp3' = 'VLC.mp3'
    '.m4a' = 'VLC.m4a'
    '.wav' = 'VLC.wav'
    '.flac' = 'VLC.flac'
    '.aac' = 'VLC.aac'
    '.ogg' = 'VLC.ogg'
    '.wma' = 'VLC.wma'
    '.opus' = 'VLC.opus'
    
    # Images (IrfanView - better performance and format support)
    '.jpg' = 'IrfanView.jpg'
    '.jpeg' = 'IrfanView.jpeg'
    '.png' = 'IrfanView.png'
    '.gif' = 'IrfanView.gif'
    '.webp' = 'IrfanView.webp'
    '.svg' = 'IrfanView.svg'
    '.bmp' = 'IrfanView.bmp'
    '.tiff' = 'IrfanView.tiff'
    '.ico' = 'IrfanView.ico'
    '.heic' = 'IrfanView.heic'
    '.raw' = 'IrfanView.raw'
    '.cr2' = 'IrfanView.cr2'
    '.nef' = 'IrfanView.nef'
    '.psd' = 'PhotoshopElementsEditor.psd.14'  # If installed
    
    # Archives
    '.zip' = '7-Zip.zip'
    '.rar' = '7-Zip.rar'
    '.7z' = '7-Zip.7z'
    '.tar' = '7-Zip.tar'
    '.gz' = '7-Zip.gz'
    
    # Development Specific
    '.py' = 'VSCode.py'
    '.java' = 'VSCode.java'
    '.cpp' = 'VSCode.cpp'
    '.h' = 'VSCode.h'
    '.sql' = 'VSCode.sql'
    '.php' = 'VSCode.php'
}

# Check and Set Protocol Handlers
$protocolHandlers = @{
    'http' = 'ChromeHTML'
    'https' = 'ChromeHTML'
    'mailto' = 'outlook'  # Or 'ChromeHTML' for Gmail
    'tel' = 'teams'       # Or your preferred calling app
    'callto' = 'teams'
    'msteams' = 'teams'
    'slack' = 'slack'
    'discord' = 'discord'
    'zoommtg' = 'zoom'
}

# Verification and Setting Script
```powershell
# Function to check current association
function Get-FileAssociation {
    param (
        [string]$extension
    )
    try {
        $currentAssoc = (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$extension\UserChoice" -Name ProgId).ProgId
        return $currentAssoc
    }
    catch {
        return $null
    }
}

# Function to set association
function Set-FileAssociation {
    param (
        [string]$extension,
        [string]$progId
    )
    try {
        # Check if app is installed first
        $appPath = (Get-Command -ErrorAction SilentlyContinue $progId.Split('.')[0])
        if ($null -eq $appPath) {
            Write-Warning "Application for $progId not found. Skipping $extension"
            return $false
        }
        
        # Set association
        cmd /c "assoc $extension=$progId"
        return $true
    }
    catch {
        Write-Error "Failed to set association for $extension"
        return $false
    }
}

# Main execution
$results = @{
    'Success' = @()
    'Failed' = @()
    'Skipped' = @()
}

# Check and set file associations
foreach ($ext in $defaultAssociations.Keys) {
    $current = Get-FileAssociation $ext
    $desired = $defaultAssociations[$ext]
    
    if ($current -ne $desired) {
        $success = Set-FileAssociation -extension $ext -progId $desired
        if ($success) {
            $results.Success += $ext
        }
        else {
            $results.Failed += $ext
        }
    }
    else {
        $results.Skipped += $ext
    }
}

# Set protocol handlers
foreach ($protocol in $protocolHandlers.Keys) {
    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\$protocol\UserChoice"
        Set-ItemProperty -Path $regPath -Name "ProgId" -Value $protocolHandlers[$protocol]
        $results.Success += $protocol
    }
    catch {
        $results.Failed += $protocol
    }
}

# Report results
Write-Host "`nAssociation Results:"
Write-Host "Successfully set: $($results.Success.Count)"
Write-Host "Failed to set: $($results.Failed.Count)"
Write-Host "Already correct: $($results.Skipped.Count)"

if ($results.Failed.Count -gt 0) {
    Write-Host "`nFailed associations:"
    $results.Failed | ForEach-Object { Write-Host "- $_" }
}
```
```powershell
# Create a .reg file with these contents
Windows Registry Editor Version 5.00

# Web Files -> Arc/Chrome
[HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice]
"ProgId"="ChromeHTML"
[HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice]
"ProgId"="ChromeHTML"

# HTML Files
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html\UserChoice]
"ProgId"="ChromeHTML"
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.htm\UserChoice]
"ProgId"="ChromeHTML"

# PDF Files -> Adobe/Foxit/Edge
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.pdf\UserChoice]
"ProgId"="AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723"

# Media Files -> VLC
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.mp4\UserChoice]
"ProgId"="VLC.mp4"
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.mkv\UserChoice]
"ProgId"="VLC.mkv"

# Image Files -> Default Photos App
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpg\UserChoice]
"ProgId"="PhotoViewer.FileAssoc.Tiff"
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.png\UserChoice]
"ProgId"="PhotoViewer.FileAssoc.Tiff"

# Archive Files -> 7-Zip
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.zip\UserChoice]
"ProgId"="7-Zip.zip"
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.rar\UserChoice]
"ProgId"="7-Zip.rar"
```

# Alternative PowerShell Method
```powershell
# Set default apps using DISM
$associations = @{
    '.html' = 'ChromeHTML'
    '.htm' = 'ChromeHTML'
    '.pdf' = 'MSEdgePDF'
    '.mp4' = 'VLC.mp4'
    '.mkv' = 'VLC.mkv'
    '.zip' = '7-Zip.zip'
    '.rar' = '7-Zip.rar'
}

foreach ($ext in $associations.Keys) {
    cmd /c "assoc $ext=$($associations[$ext])"
}
```

## Post-Installation Tasks
1. Configure Windows 11 Settings:
   - Snap layouts
   - Virtual desktops
   - Touch keyboard
   - Windows Hello
   - Focus assist

2. Browser Setup:
   - Import bookmarks
   - Configure sync settings
   - Set default browser preferences
   - Organize extensions

3. Notion Setup:
   - Configure offline access
   - Set up integrations
   - Import templates
   - Configure keyboard shortcuts

4. System Maintenance Schedule:
   - Weekly: Temp file cleanup
   - Monthly: Driver updates
   - Quarterly: Software audit
   - Yearly: System backup review

## Regular Updates
- Windows 11: Security updates
- Browsers: Check monthly for new features
- Notion: Keep desktop app updated
- Extensions: Review quarterly

Remember to:
- Create system restore points
- Document custom configurations
- Keep installation files organized
- Set up automated backups

