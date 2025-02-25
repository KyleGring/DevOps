# Run as Administrator
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"

# Ensure Chrome is installed
if (!(Test-Path $chromePath)) {
    Write-Host "Chrome is not installed at expected location. Aborting!" -ForegroundColor Red
    exit 1
}

# File types and protocols to update
$fileTypes = @(".htm", ".html", ".mhtml", ".pdf", ".shtml", ".svg", ".xml", ".xhtml", ".php", ".asp", ".json")
$protocols = @("http", "https", "mailto", "mms", "sms", "tel", "webcal")

# Set default for file types
foreach ($type in $fileTypes) {
    Write-Host "Setting Chrome as default for $type..."
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c ftype $type=$chromePath %1" -NoNewWindow -Wait
}

# Set default for protocols
foreach ($protocol in $protocols) {
    Write-Host "Setting Chrome as default for $protocol..."
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\$protocol\UserChoice /v ProgId /t REG_SZ /d ChromeHTML /f" -NoNewWindow -Wait
}

Write-Host "All file types and protocols have been updated to use Google Chrome!" -ForegroundColor Green

