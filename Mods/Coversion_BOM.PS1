# Define paths to scan
$PathsToFix = @("C:\Users\Kyle\Docs", "C:\DevOps")

foreach ($Path in $PathsToFix) {
    Write-Host "🔄 Scanning: $Path" -ForegroundColor Cyan
    $filesToFix = Get-ChildItem -Path $Path -Recurse -File | Where-Object {
        (Get-Content $_.FullName -Raw) -match "[^\u0000-\u007F]"
    }

    foreach ($file in $filesToFix) {
        Write-Host "🔄 Fixing encoding: $($file.FullName)" -ForegroundColor Yellow
        (Get-Content $file.FullName -Raw) | Set-Content $file.FullName -Encoding UTF8
    }
}

Write-Host "✅ All detected files converted to UTF-8 Without BOM in C:\Users\Kyle & C:\DevOps!" -ForegroundColor Green

