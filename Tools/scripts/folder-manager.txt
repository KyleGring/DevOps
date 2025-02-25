function Create-HierarchyVisual {
    param(
        [string]$SourcePath,
        [string]$OutputPath,
        [int]$MaxDepth = 3,
        [switch]$IncludeFiles
    )
    
    $folderHierarchy = @"
# Folder Hierarchy Visualization
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Path: $SourcePath

```mermaid
graph TD
    classDef folder fill:#f9d77e,stroke:#e6b73e,stroke-width:1px
    classDef file fill:#d4e6f1,stroke:#7fb3d5,stroke-width:1px
    classDef root fill:#a9dfbf,stroke:#7dcea0,stroke-width:2px

"@

    # Create a safe node ID (mermaid compatible)
    function Get-SafeNodeId {
        param([string]$Path)
        
        # Replace problematic characters
        $safeId = $Path -replace '[^a-zA-Z0-9]', '_'
        
        # Ensure ID starts with a letter
        if ($safeId -match '^[^a-zA-Z]') {
            $safeId = "n$safeId"
        }
        
        return $safeId
    }
    
    # Get the root node ID
    $rootFolder = Split-Path -Path $SourcePath -Leaf
    if ([string]::IsNullOrEmpty($rootFolder)) {
        $rootFolder = $SourcePath # For drive roots
    }
    $rootId = Get-SafeNodeId -Path $rootFolder
    
    # Add root node
    $folderHierarchy += "    $rootId[$rootFolder]:::root`n"
    
    # Process folder recursively
    function Process-Folder {
        param(
            [string]$FolderPath,
            [string]$ParentId,
            [int]$CurrentDepth = 1
        )
        
        # Skip if reached max depth
        if ($CurrentDepth -gt $MaxDepth) {
            return
        }
        
        $folderName = Split-Path -Path $FolderPath -Leaf
        if ([string]::IsNullOrEmpty($folderName)) {
            $folderName = $FolderPath # For drive roots
        }
        $folderId = Get-SafeNodeId -Path "$ParentId\_$folderName"
        
        # Add connection from parent to this folder
        if ($ParentId -ne "") {
            $script:folderHierarchy += "    $ParentId --> $folderId`n"
        }
        
        # Add folder node
        $script:folderHierarchy += "    $folderId[$folderName]:::folder`n"
        
        # Get subfolders
        $subfolders = Get-ChildItem -Path $FolderPath -Directory -ErrorAction SilentlyContinue
        
        foreach ($subfolder in $subfolders) {
            # Skip system folders
            if ($systemExclusions -contains $subfolder.Name.ToLower()) {
                continue
            }
            
            Process-Folder -FolderPath $subfolder.FullName -ParentId $folderId -CurrentDepth ($CurrentDepth + 1)
        }
        
        # Include files if requested
        if ($IncludeFiles) {
            $files = Get-ChildItem -Path $FolderPath -File -ErrorAction SilentlyContinue
            
            foreach ($file in $files) {
                # Skip system files
                if ($systemExclusions -contains $file.Name.ToLower()) {
                    continue
                }
                
                # Limit files per folder to avoid overly complex diagrams
                if ($files.Count -gt 5) {
                    $fileId = Get-SafeNodeId -Path "$folderId\_files"
                    $script:folderHierarchy += "    $folderId --> $fileId`n"
                    $script:folderHierarchy += "    $fileId[($($files.Count) files)]:::file`n"
                    break
                } else {
                    $fileId = Get-SafeNodeId -Path "$folderId\_$($file.Name)"
                    $script:folderHierarchy += "    $folderId --> $fileId`n"
                    $script:folderHierarchy += "    $fileId[$($file.Name)]:::file`n"
                }
            }
        }
    }
    
    # Start processing from the root
    Process-Folder -FolderPath $SourcePath -ParentId $rootId
    
    # Close the mermaid diagram
    $folderHierarchy += "```"
    
    # Generate the report file
    $folderHierarchy | Out-File -FilePath $OutputPath -Encoding utf8
    Write-Host "Folder hierarchy visualization created at: $OutputPath" -ForegroundColor $colors.Success
    
    return $OutputPath
}

function Create-SizeTreemap {
    param(
        [string]$SourcePath,
        [string]$OutputPath
    )
    
    # Create HTML treemap visualization using here-string
    $htmlContent = @'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Folder Size Treemap</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
        }
        .header {
            text-align: center;
            margin-bottom: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        rect {
            stroke: #fff;
            stroke-width: 1px;
            transition: fill 0.3s;
        }
        rect:hover {
            stroke: #333;
            stroke-width: 2px;
        }
        .tooltip {
            position: absolute;
            padding: 8px;
            background: rgba(0, 0, 0, 0.8);
            color: #fff;
            border-radius: 4px;
            font-size: 12px;
            pointer-events: none;
            opacity: 0;
            transition: opacity 0.3s;
        }
        .legend {
            margin-top: 20px;
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
        }
        .legend-item {
            display: flex;
            align-items: center;
            margin: 0 10px 5px 0;
        }
        .legend-color {
            width: 15px;
            height: 15px;
            margin-right: 5px;
        }
        .path-info {
            margin-bottom: 10px;
            font-size: 14px;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Folder Size Treemap</h1>
            <div class="path-info">Path: SOURCEPATH</div>
            <div class="path-info">Generated: TIMESTAMP</div>
        </div>
        <div id="chart"></div>
        <div class="legend" id="legend"></div>
    </div>
    
    <script src="https://d3js.org/d3.v7.min.js"></script>
    <script>
        // Folder data will be replaced with actual data
        const data = {
            "name": "ROOT",
            "path": "SOURCEPATH",
            "children": []
        };
        
        // Function to create the treemap
        function createTreemap() {
            const width = 1100;
            const height = 600;
            
            const tooltip = d3.select("body").append("div")
                .attr("class", "tooltip");
                
            const color = d3.scaleOrdinal(d3.schemeCategory10);
            
            const treemap = d3.treemap()
                .size([width, height])
                .padding(1)
                .round(true);
                
            const root = d3.hierarchy(data)
                .sum(d => d.size)
                .sort((a, b) => b.value - a.value);
                
            treemap(root);
            
            const svg = d3.select("#chart").append("svg")
                .attr("width", width)
                .attr("height", height);
                
            const cell = svg.selectAll("g")
                .data(root.leaves())
                .enter().append("g")
                .attr("transform", d => `translate(${d.x0},${d.y0})`);
                
            cell.append("rect")
                .attr("width", d => d.x1 - d.x0)
                .attr("height", d => d.y1 - d.y0)
                .attr("fill", d => {
                    let parent = d.parent;
                    while (parent.depth > 1) parent = parent.parent;
                    return color(parent.data.name);
                })
                .on("mouseover", function(event, d) {
                    d3.select(this).attr("fill", d3.rgb(d3.select(this).attr("fill")).darker(0.7));
                    tooltip.style("opacity", 1);
                    tooltip.html(`
                        <div><strong>${d.data.name}</strong></div>
                        <div>Size: ${formatBytes(d.data.size)}</div>
                        <div>Path: ${d.data.path}</div>
                    `)
                    .style("left", (event.pageX + 10) + "px")
                    .style("top", (event.pageY - 28) + "px");
                })
                .on("mouseout", function() {
                    d3.select(this).attr("fill", d3.rgb(d3.select(this).attr("fill")).brighter(0.7));
                    tooltip.style("opacity", 0);
                });
                
            cell.append("text")
                .attr("x", 4)
                .attr("y", 14)
                .text(d => d.data.name)
                .attr("font-size", "10px")
                .attr("fill", "white")
                .each(function(d) {
                    const textWidth = this.getComputedTextLength();
                    const rectWidth = d.x1 - d.x0;
                    if (textWidth > rectWidth - 8) {
                        d3.select(this).text(d.data.name.substring(0, 8) + "...");
                    }
                });
                
            // Create legend
            const topFolders = root.children.sort((a, b) => b.value - a.value);
            const legend = d3.select("#legend");
            
            topFolders.forEach((folder, i) => {
                const legendItem = legend.append("div")
                    .attr("class", "legend-item");
                    
                legendItem.append("div")
                    .attr("class", "legend-color")
                    .style("background-color", color(folder.data.name));
                    
                legendItem.append("div")
                    .text(`${folder.data.name} (${formatBytes(folder.value)})`);
            });
        }
        
        // Format bytes to human-readable format
        function formatBytes(bytes, decimals = 2) {
            if (bytes === 0) return '0 Bytes';
            
            const k = 1024;
            const dm = decimals < 0 ? 0 : decimals;
            const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
            
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            
            return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
        }
        
        // Initialize visualization when data is available
        createTreemap();
    </script>
</body>
</html>
'@

    # Replace placeholder values
    $htmlContent = $htmlContent.Replace("SOURCEPATH", $SourcePath)
    $htmlContent = $htmlContent.Replace("TIMESTAMP", (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))

    # Get folder size data function
    function Get-FolderSizeData {
        param(
            [string]$FolderPath,
            [int]$Depth = 0,
            [int]$MaxDepth = 3
        )
        
        $folderInfo = @{
            name = Split-Path -Path $FolderPath -Leaf
            path = $FolderPath
        }
        
        if ([string]::IsNullOrEmpty($folderInfo.name)) {
            $folderInfo.name = $FolderPath
        }
        
        if ($Depth -lt $MaxDepth) {
            $subfolders = Get-ChildItem -Path $FolderPath -Directory -ErrorAction SilentlyContinue | 
                          Where-Object { $systemExclusions -notcontains $_.Name.ToLower() }
            
            if ($subfolders.Count -gt 0) {
                $folderInfo.children = @()
                
                foreach ($subfolder in $subfolders) {
                    $childData = Get-FolderSizeData -FolderPath $subfolder.FullName -Depth ($Depth + 1) -MaxDepth $MaxDepth
                    $folderInfo.children += $childData
                }
            } else {
                # Get files in the folder
                $files = Get-ChildItem -Path $FolderPath -File -ErrorAction SilentlyContinue | 
                         Where-Object { $systemExclusions -notcontains $_.Name.ToLower() }
                
                if ($files.Count -gt 0) {
                    $folderInfo.size = ($files | Measure-Object -Property Length -Sum).Sum
                } else {
                    $folderInfo.size = 0
                }
            }
        } else {
            # Calculate total size at max depth
            $size = 0
            $items = Get-ChildItem -Path $FolderPath -Recurse -ErrorAction SilentlyContinue | 
                    Where-Object { (-not $_.PSIsContainer) -and ($systemExclusions -notcontains $_.Name.ToLower()) }
            
            if ($items.Count -gt 0) {
                $size = ($items | Measure-Object -Property Length -Sum).Sum
            }
            
            $folderInfo.size = $size
        }
        
        return $folderInfo
    }
    
    # Get folder data
    Write-Host "Analyzing folder sizes (this may take a while for large directories)..." -ForegroundColor $colors.Info
    $folderData = Get-FolderSizeData -FolderPath $SourcePath
    
    # Convert to JSON and insert into HTML template
    $folderDataJson = $folderData | ConvertTo-Json -Depth 10
    $htmlContent = $htmlContent.Replace('        const data = {
            "name": "ROOT",
            "path": "SOURCEPATH",
            "children": []
        };', "        const data = $folderDataJson;")
    
    # Generate the HTML file
    $htmlContent | Out-File -FilePath $OutputPath -Encoding utf8
    Write-Host "Size treemap visualization created at: $OutputPath" -ForegroundColor $colors.Success
    
    return $OutputPath
}

function Export-VisualizationToPdf {
    param(
        [string]$HtmlPath,
        [string]$PdfPath
    )
    
    try {
        # Check if wkhtmltopdf is installed
        $wkhtmltopdf = "wkhtmltopdf"
        $testCmd = Get-Command $wkhtmltopdf -ErrorAction SilentlyContinue
        
        if ($testCmd) {
            Write-Host "Converting HTML to PDF..." -ForegroundColor $colors.Info
            & $wkhtmltopdf $HtmlPath $PdfPath
            Write-Host "PDF report created at: $PdfPath" -ForegroundColor $colors.Success
            return $true
        } else {
            Write-Host "wkhtmltopdf not found. Please install it to enable PDF export." -ForegroundColor $colors.Warning
            Write-Host "Download from: https://wkhtmltopdf.org/downloads.html" -ForegroundColor $colors.Info
            return $false
        }
    } catch {
        Write-Host "Error creating PDF: $_" -ForegroundColor $colors.Error
        return $false
    }
}

function Create-VisualReports {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [switch]$WhatIf
    )
    
    if ($WhatIf) {
        Write-Host "Would create visual reports, but running in preview mode" -ForegroundColor $colors.Warning
        return
    }
    
    # Create reports directory if it doesn't exist
    $reportsDir = Join-Path -Path $DestinationPath -ChildPath "Reports"
    if (-not (Test-Path -Path $reportsDir)) {
        New-Item -ItemType Directory -Path $reportsDir | Out-Null
    }
    
    # Create hierarchy visualization
    $hierarchyPath = Join-Path -Path $reportsDir -ChildPath "folder-hierarchy.md"
    Create-HierarchyVisual -SourcePath $SourcePath -OutputPath $hierarchyPath -MaxDepth 3 -IncludeFiles:$false
    
    # Create size treemap
    $treemapPath = Join-Path -Path $reportsDir -ChildPath "size-treemap.html"
    Create-SizeTreemap -SourcePath $SourcePath -OutputPath $treemapPath
    
    # Try to create PDF version
    $pdfPath = Join-Path -Path $reportsDir -ChildPath "folder-report.pdf"
    Export-VisualizationToPdf -HtmlPath $treemapPath -PdfPath $pdfPath
    
    # Create report index
    $indexContent = @"
# Folder Analysis Reports
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Available Reports

- [Folder Hierarchy](folder-hierarchy.md) - Visual tree diagram of folder structure
- [Size Treemap](size-treemap.html) - Interactive visualization of folder sizes

"@
    
    $indexPath = Join-Path -Path $reportsDir -ChildPath "index.md"
    $indexContent | Out-File -FilePath $indexPath -Encoding utf8
    
    Write-Host "`nVisual reports created in: $reportsDir" -ForegroundColor $colors.Success
    Write-Host "Open 'index.md' to access all reports" -ForegroundColor $colors.Info
}# Unified Folder Manager - Flatten or Rollup
# Handles both flattening and rolling up folder structures with interactive options

# Bypass execution policy for current session
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# System folders/files to always exclude
$systemExclusions = @(
    "desktop.ini", "thumbs.db", "ntuser.dat", ".vscode", ".git", ".vs",
    "node_modules", "bin", "obj", "dist", "build", "target",
    "pagefile.sys", "hiberfil.sys", "swapfile.sys"
)

# Default organization categories
$defaultCategories = @{
    "Documents" = @(".doc", ".docx", ".pdf", ".txt", ".rtf", ".odt", ".md")
    "Images" = @(".jpg", ".jpeg", ".png", ".gif", ".bmp", ".svg", ".tiff", ".webp")
    "Audio" = @(".mp3", ".wav", ".ogg", ".flac", ".aac", ".wma")
    "Video" = @(".mp4", ".avi", ".mov", ".wmv", ".mkv", ".flv", ".webm")
    "Archives" = @(".zip", ".rar", ".7z", ".tar", ".gz")
    "Code" = @(".cs", ".py", ".js", ".html", ".css", ".ts", ".java", ".cpp", ".php", ".go")
    "Scripts" = @(".ps1", ".bat", ".cmd", ".sh", ".bash", ".vbs")
    "Data" = @(".csv", ".json", ".xml", ".sql", ".db", ".xlsx", ".xls")
    "Executables" = @(".exe", ".msi", ".appx")
    "Configuration" = @(".ini", ".config", ".yml", ".yaml", ".toml")
}

# Default folders for rollup mode
$defaultRollupFolders = @(
    "Setup",
    "Automation",
    "Integration",
    "Configuration",
    "Monitoring",
    "Scripts",
    "Guides",
    "Conversion",
    "Management",
    "PowerShell"
)

# Color constants
$colors = @{
    "Title" = "Cyan"
    "Success" = "Green"
    "Warning" = "Yellow"
    "Error" = "Red"
    "Info" = "White"
    "Accent" = "Magenta"
}

function Show-Banner {
    Clear-Host
    Write-Host "`nâ”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”" -ForegroundColor $colors.Title
    Write-Host "  UNIFIED FOLDER MANAGER - FLATTEN OR ROLLUP" -ForegroundColor $colors.Accent
    Write-Host "â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”`n" -ForegroundColor $colors.Title
}

function Get-UserInput {
    param (
        [string]$Prompt,
        [string]$Default = "",
        [switch]$YesNo,
        [switch]$Required
    )
    
    $promptText = $Prompt
    if ($Default -ne "") {
        if ($YesNo) {
            $defaultValue = if ($Default -eq "y") { "y" } else { "n" }
            $promptText += " (y/n) [Default: $defaultValue]"
        } else {
            $promptText += " [Default: $Default]"
        }
    }
    
    do {
        $input = Read-Host $promptText
        
        # Handle default values
        if ([string]::IsNullOrEmpty($input) -and $Default -ne "") {
            return $Default
        }
        
        # Handle yes/no
        if ($YesNo) {
            if ($input -eq "y" -or $input -eq "n") {
                return $input
            } elseif ([string]::IsNullOrEmpty($input) -and $Default -ne "") {
                return $Default
            } else {
                Write-Host "Please enter 'y' or 'n'" -ForegroundColor $colors.Warning
                continue
            }
        }
        
        # Check if input is required
        if ($Required -and [string]::IsNullOrEmpty($input)) {
            Write-Host "This field is required" -ForegroundColor $colors.Warning
            continue
        }
        
        return $input
    } while ($true)
}

function Get-OperationMode {
    Write-Host "SELECT OPERATION MODE" -ForegroundColor $colors.Title
    Write-Host "â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”`n" -ForegroundColor $colors.Title
    
    Write-Host "1. FLATTEN - Extract files from subfolders and organize them"
    Write-Host "2. ROLLUP - Organize files from current directory into categorized folders"
    
    $mode = Get-UserInput -Prompt "`nSelect operation mode (1 or 2)" -Default "1"
    
    return $mode
}

function Get-SourceFolder {
    param(
        [string]$DefaultPath
    )
    
    Write-Host "`nSOURCE FOLDER SELECTION" -ForegroundColor $colors.Title
    Write-Host "â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”`n" -ForegroundColor $colors.Title
    
    $useDefaultSource = Get-UserInput -Prompt "Use current folder as source?" -Default "y" -YesNo
    
    if ($useDefaultSource -eq "y") {
        return $DefaultPath
    } else {
        $customPath = Get-UserInput -Prompt "Enter source folder path" -Required
        
        if (Test-Path -Path $customPath -PathType Container) {
            return $customPath
        } else {
            Write-Host "Invalid path. Using current directory." -ForegroundColor $colors.Warning
            return $DefaultPath
        }
    }
}

function Get-DestinationFolder {
    param(
        [string]$SourcePath,
        [string]$Mode
    )
    
    Write-Host "`nDESTINATION FOLDER SELECTION" -ForegroundColor $colors.Title
    Write-Host "â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”`n" -ForegroundColor $colors.Title
    
    $defaultName = if ($Mode -eq "1") { "Flattened" } else { "Organized" }
    $defaultDest = Join-Path -Path (Split-Path -Path $SourcePath -Parent) -ChildPath "${defaultName}_$(Split-Path -Path $SourcePath -Leaf)"
    
    $useSourceAsDestination = "n"
    if ($Mode -eq "2") {
        $useSourceAsDestination = Get-UserInput -Prompt "Organize files in the source folder? (No separate destination)" -Default "y" -YesNo
    }
    
    if ($useSourceAsDestination -eq "y") {
        return $SourcePath
    } else {
        $customDest = Get-UserInput -Prompt "Enter destination folder (will be created if it doesn't exist)" -Default $defaultDest
        return $customDest
    }
}

function Get-ExcludedFolders {
    param(
        [string[]]$DefaultExclusions
    )
    
    Write-Host "`nEXCLUDED FOLDERS" -ForegroundColor $colors.Title
    Write-Host "â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”`n" -ForegroundColor $colors.Title
    
    Write-Host "Current exclusions: $($DefaultExclusions -join ', ')" -ForegroundColor $colors.Info
    
    $modifyExclusions = Get-UserInput -Prompt "Modify exclusion list?" -Default "n" -YesNo
    
    if ($modifyExclusions -eq "n") {
        return $DefaultExclusions
    }
    
    $addExclusions = Get-UserInput -Prompt "Enter additional folders to exclude (comma-separated)"
    $removeExclusions = Get-UserInput -Prompt "Enter folders to remove from exclusion list (comma-separated)"
    
    $exclusions = $DefaultExclusions.Clone()
    
    if (-not [string]::IsNullOrEmpty($addExclusions)) {
        $addList = $addExclusions.Split(',') | ForEach-Object { $_.Trim() }
        $exclusions += $addList
    }
    
    if (-not [string]::IsNullOrEmpty($removeExclusions)) {
        $removeList = $removeExclusions.Split(',') | ForEach-Object { $_.Trim() }
        $exclusions = $exclusions | Where-Object { $removeList -notcontains $_ }
    }
    
    Write-Host "Updated exclusions: $($exclusions -join ', ')" -ForegroundColor $colors.Success
    
    return $exclusions
}

function Get-OrganizationStrategy {
    Write-Host "`nORGANIZATION STRATEGY" -ForegroundColor $colors.Title
    Write-Host "â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”`n" -ForegroundColor $colors.Title
    
    Write-Host "Choose how to organize the files:" -ForegroundColor $colors.Info
    Write-Host "1. By file extension (default)"
    Write-Host "2. By file type category (Documents, Images, Code, etc.)"
    Write-Host "3. By modified date (Year-Month)"
    Write-Host "4. By file size (Small, Medium, Large)"
    Write-Host "5. No organization (flat structure)"
    
    $strategy = Get-UserInput -Prompt "Select organization strategy (1-5)" -Default "1"
    
    switch ($strategy) {
        "1" { return "Extension" }
        "2" { return "Category" }
        "3" { return "Date" }
        "4" { return "Size" }
        "5" { return "None" }
        default { return "Extension" }
    }
}

function Customize-Categories {
    param(
        [hashtable]$DefaultCategories
    )
    
    Write-Host "`nCUSTOMIZE CATEGORIES" -ForegroundColor $colors.Title
    Write-Host "â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”`n" -ForegroundColor $colors.Title
    
    $customizeCategories = Get-UserInput -Prompt "Customize file type categories?" -Default "n" -YesNo
    
    if ($customizeCategories -eq "n") {
        return $DefaultCategories
    }
    
    $categories = $DefaultCategories.Clone()
    
    Write-Host "`nCurrent categories:" -ForegroundColor $colors.Info
    foreach ($category in $categories.Keys) {
        Write-Host "$category : $($categories[$category] -join ', ')"
    }
    
    $action = Get-UserInput -Prompt "`nChoose action (1: Add category, 2: Remove category, 3: Modify category, 4: Done)" -Default "4"
    
    while ($action -ne "4") {
        switch ($action) {
            "1" {
                $newCategory = Get-UserInput -Prompt "Enter new category name" -Required
                $extensions = Get-UserInput -Prompt "Enter file extensions (comma-separated, include the dot)" -Required
                
                $extList = $extensions.Split(',') | ForEach-Object { $_.Trim() }
                $categories[$newCategory] = $extList
                
                Write-Host "Added category: $newCategory" -ForegroundColor $colors.Success
            }
            "2" {
                $removeCategory = Get-UserInput -Prompt "Enter category to remove" -Required
                
                if ($categories.ContainsKey($removeCategory)) {
                    $categories.Remove($removeCategory)
                    Write-Host "Removed category: $removeCategory" -ForegroundColor $colors.Success
                } else {
                    Write-Host "Category not found: $removeCategory" -ForegroundColor $colors.Warning
                }
            }
            "3" {
                $modifyCategory = Get-UserInput -Prompt "Enter category to modify" -Required
                
                if ($categories.ContainsKey($modifyCategory)) {
                    $newExtensions = Get-UserInput -Prompt "Enter new list of extensions (comma-separated)" -Required
                    
                    $extList = $newExtensions.Split(',') | ForEach-Object { $_.Trim() }
                    $categories[$modifyCategory] = $extList
                    
                    Write-Host "Updated category: $modifyCategory" -ForegroundColor $colors.Success
                } else {
                    Write-Host "Category not found: $modifyCategory" -ForegroundColor $colors.Warning
                }
            }
        }
        
        Write-Host "`nCurrent categories:" -ForegroundColor $colors.Info
        foreach ($category in $categories.Keys) {
            Write-Host "$category : $($categories[$category] -join ', ')"
        }
        
        $action = Get-UserInput -Prompt "`nChoose action (1: Add category, 2: Remove category, 3: Modify category, 4: Done)" -Default "4"
    }
    
    return $categories
}

function Customize-RollupFolders {
    param(
        [string[]]$DefaultFolders
    )
    
    Write-Host "`nCUSTOMIZE ORGANIZATION FOLDERS" -ForegroundColor $colors.Title
    Write-Host "â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”`n" -ForegroundColor $colors.Title
    
    Write-Host "Current folders: $($DefaultFolders -join ', ')" -ForegroundColor $colors.Info
    
    $customize = Get-UserInput -Prompt "Customize organization folders?" -Default "n" -YesNo
    
    if ($customize -eq "n") {
        return $DefaultFolders
    }
    
    $addFolders = Get-UserInput -Prompt "Enter additional folders to create (comma-separated, or press Enter to skip)"
    $removeFolders = Get-UserInput -Prompt "Enter folders to remove (comma-separated, or press Enter to skip)"
    
    $folders = $DefaultFolders.Clone()
    
    if (-not [string]::IsNullOrEmpty($addFolders)) {
        $addArray = $addFolders.Split(',') | ForEach-Object { $_.Trim() }
        $folders += $addArray
    }
    
    if (-not [string]::IsNullOrEmpty($removeFolders)) {
        $removeArray = $removeFolders.Split(',') | ForEach-Object { $_.Trim() }
        $folders = $folders | Where-Object { $removeArray -notcontains $_ }
    }
    
    Write-Host "Updated folders: $($folders -join ', ')" -ForegroundColor $colors.Success
    
    return $folders
}

function Get-FileCategory {
    param(
        [System.IO.FileInfo]$File,
        [hashtable]$Categories
    )
    
    foreach ($category in $Categories.Keys) {
        if ($Categories[$category] -contains $File.Extension.ToLower()) {
            return $category
        }
    }
    
    return "Other"
}

function Get-SizeCategory {
    param(
        [long]$FileSize
    )
    
    if ($FileSize -lt 100KB) {
        return "Small_0-100KB"
    } elseif ($FileSize -lt 1MB) {
        return "Medium_100KB-1MB"
    } elseif ($FileSize -lt 10MB) {
        return "Large_1-10MB"
    } elseif ($FileSize -lt 100MB) {
        return "XLarge_10-100MB"
    } else {
        return "Huge_100MB+"
    }
}

function Flatten-Folder {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [string[]]$ExcludeFolders,
        [string]$OrganizeBy,
        [hashtable]$Categories,
        [switch]$WhatIf,
        [switch]$PreserveStructure
    )
    
    # Create destination if it doesn't exist
    if (-not (Test-Path -Path $DestinationPath)) {
        if (-not $WhatIf) {
            New-Item -ItemType Directory -Path $DestinationPath | Out-Null
            Write-Host "Created destination directory: $DestinationPath" -ForegroundColor $colors.Success
        } else {
            Write-Host "[PREVIEW] Would create destination directory: $DestinationPath" -ForegroundColor $colors.Warning
        }
    }
    
    # Get all files from the source directory and subdirectories
    $allFiles = Get-ChildItem -Path $SourcePath -File -Recurse -ErrorAction SilentlyContinue | 
                Where-Object {
                    $skipFile = $false
                    
                    # Check if file is in excluded folder
                    foreach ($excludeFolder in $ExcludeFolders) {
                        if ($_.FullName -like "*\$excludeFolder\*") {
                            $skipFile = $true
                            break
                        }
                    }
                    
                    -not $skipFile
                }
    
    $totalFiles = $allFiles.Count
    Write-Host "Found $totalFiles files to process..." -ForegroundColor $colors.Info
    
    $processed = 0
    $skipped = 0
    $errors = 0
    
    # Process each file
    foreach ($file in $allFiles) {
        # Determine target subdirectory based on organization strategy
        $targetSubdir = ""
        
        switch ($OrganizeBy) {
            "Extension" {
                $targetSubdir = if ($file.Extension) { $file.Extension.TrimStart(".").ToUpper() } else { "NoExtension" }
            }
            "Category" {
                $targetSubdir = Get-FileCategory -File $file -Categories $Categories
            }
            "Date" {
                $targetSubdir = $file.LastWriteTime.ToString("yyyy-MM")
            }
            "Size" {
                $targetSubdir = Get-SizeCategory -FileSize $file.Length
            }
            "None" {
                $targetSubdir = ""
            }
        }
        
        # Create the target folder path
        $targetFolderPath = if ($targetSubdir) {
            Join-Path -Path $DestinationPath -ChildPath $targetSubdir
        } else {
            $DestinationPath
        }
        
        # Create target folder if it doesn't exist
        if ($targetSubdir -and -not (Test-Path -Path $targetFolderPath)) {
            if (-not $WhatIf) {
                New-Item -ItemType Directory -Path $targetFolderPath -Force | Out-Null
            }
        }
        
        # Prepare new filename
        $newFileName = $file.Name
        
        # Add original path info to filename if structure preservation is enabled
        if ($PreserveStructure) {
            $relativePath = $file.DirectoryName.Replace($SourcePath, "").Trim("\")
            if ($relativePath) {
                $pathSegment = $relativePath.Replace("\", "_")
                $newFileName = "{0}__FROM__{1}{2}" -f $file.BaseName, $pathSegment, $file.Extension
            }
        }
        
        # Full destination path
        $destinationFilePath = Join-Path -Path $targetFolderPath -ChildPath $newFileName
        
        # Handle duplicates by adding a counter to the filename
        $counter = 1
        while (Test-Path -Path $destinationFilePath) {
            $newFileName = "{0}_{1}{2}" -f $file.BaseName, $counter, $file.Extension
            $destinationFilePath = Join-Path -Path $targetFolderPath -ChildPath $newFileName
            $counter++
        }
        
        # Copy the file
        if (-not $WhatIf) {
            try {
                Copy-Item -Path $file.FullName -Destination $destinationFilePath -Force
                $processed++
                Write-Progress -Activity "Flattening folder structure" -Status "Processed $processed of $totalFiles files" -PercentComplete (($processed + $skipped) / $totalFiles * 100)
            } catch {
                Write-Host "Error processing $($file.FullName): $_" -ForegroundColor $colors.Error
                $errors++
            }
        } else {
            if ($targetSubdir) {
                Write-Host "[PREVIEW] Would copy $($file.FullName) to $targetSubdir\$newFileName" -ForegroundColor $colors.Warning
            } else {
                Write-Host "[PREVIEW] Would copy $($file.FullName) to $newFileName" -ForegroundColor $colors.Warning
            }
            $processed++
            Write-Progress -Activity "[SIMULATION] Flattening folder structure" -Status "Processed $processed of $totalFiles files" -PercentComplete (($processed + $skipped) / $totalFiles * 100)
        }
    }
    
    Write-Progress -Activity "Flattening folder structure" -Completed
    
    # Generate summary report
    Write-Host "`nâ”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”" -ForegroundColor $colors.Title
    Write-Host "  OPERATION SUMMARY" -ForegroundColor $colors.Accent
    Write-Host "â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”`n" -ForegroundColor $colors.Title
    
    Write-Host "Total files found: $totalFiles" -ForegroundColor $colors.Info
    
    if ($WhatIf) {
        Write-Host "Files that would be processed: $processed" -ForegroundColor $colors.Warning
    } else {
        Write-Host "Files successfully processed: $processed" -ForegroundColor $colors.Success
        Write-Host "Errors encountered: $errors" -ForegroundColor $colors.Error
    }
    
    Write-Host "Organization method: $OrganizeBy" -ForegroundColor $colors.Info
    Write-Host "Source path: $SourcePath" -ForegroundColor $colors.Info
    Write-Host "Destination path: $DestinationPath" -ForegroundColor $colors.Info
    
    # Generate organization report
    if (-not $WhatIf -and $OrganizeBy -ne "None") {
        $flattenedFiles = @{}
        $report = @"
# Folder Flattening Report
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Configuration
- Source: $SourcePath
- Destination: $DestinationPath
- Organization Method: $OrganizeBy
- File Preservation: $(if ($PreserveStructure) { "Structure preserved in filenames" } else { "Original structure not preserved" })

## Statistics
- Total Files Processed: $processed
- Errors: $errors

## Category Breakdown
"@
        
        $categories = Get-ChildItem -Path $DestinationPath -Directory
        
        foreach ($category in $categories) {
            $categoryFiles = Get-ChildItem -Path $category.FullName -File
            $fileCount = $categoryFiles.Count
            $report += "`n### $($category.Name): $fileCount files`n"
            
            # Add file listings to report
            if ($fileCount -gt 0) {
                $report += "```\n"
                foreach ($file in $categoryFiles) {
                    $report += "- $($file.Name)`n"
                }
                $report += "```\n"
            }
            
            # Add to tracking dictionary
            $flattenedFiles[$category.Name] = $categoryFiles.Name
        }
        
        $reportPath = Join-Path -Path $DestinationPath -ChildPath "flattening-report.md"
        $report | Out-File -FilePath $reportPath -Encoding utf8
        
        Write-Host "`nReport generated at: $reportPath" -ForegroundColor $colors.Success
    }
}

function Rollup-Folder {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [string[]]$OrganizationalFolders,
        [hashtable]$CustomExtensionRules = @{},
        [switch]$WhatIf
    )
    
    # Track files for summary
    $fileMoveTracker = @{}
    $unmappedFiles = @()
    
    # Create organizational folders if they don't exist
    foreach ($folder in $OrganizationalFolders) {
        $folderPath = Join-Path -Path $DestinationPath -ChildPath $folder
        if (-not (Test-Path -Path $folderPath)) {
            if (-not $WhatIf) {
                New-Item -Path $folderPath -ItemType Directory | Out-Null
                Write-Host "Created folder: $folder" -ForegroundColor $colors.Success
            } else {
                Write-Host "[PREVIEW] Would create folder: $folder" -ForegroundColor $colors.Warning
            }
        }
        
        # Initialize tracker for each folder
        $fileMoveTracker[$folder] = @()
    }
    
    # Get all files in the selected directory (only top level)
    $files = Get-ChildItem -Path $SourcePath -File
    
    $totalFiles = $files.Count
    Write-Host "Found $totalFiles files to organize..." -ForegroundColor $colors.Info
    
    $processed = 0
    $skipped = 0
    
    # Organize files based on patterns
    foreach ($file in $files) {
        # Get current script name for exclusion
        $scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
        
        # Skip system and special files
        if ($file.Name -eq $scriptName -or
            $file.Name -eq "organize-folder.ps1" -or
            $file.Name -eq "organization-map.md" -or
            $file.Name -eq "run-organizer.ps1" -or
            $file.Name -eq "flattening-report.md" -or
            $systemExclusions -contains $file.Name.ToLower() -or
            $file.Name.StartsWith("~$") -or
            $file.Attributes.HasFlag([System.IO.FileAttributes]::System)) {
            $skipped++
            continue
        }
        
        $destination = ""
        
        # Check custom extension rules first
        if ($CustomExtensionRules.ContainsKey($file.Extension)) {
            $destination = $CustomExtensionRules[$file.Extension]
        }
        # Special file types
        elseif ($file.Extension -eq ".lnk") {
            $destination = "Shortcuts"
        }
        elseif ($file.Extension -eq ".json") {
            $destination = "Configuration"
        }
        elseif ($file.Extension -eq ".js") {
            $destination = "Scripts"
        }
        elseif ($file.Extension -eq ".md") {
            $destination = "Documentation"
        }
        # Archive files
        elseif ($file.Extension -eq ".zip" -or $file.Extension -eq ".rar" -or
                $file.Extension -eq ".7z" -or $file.Extension -eq ".tar" -or
                $file.Extension -eq ".gz" -or $file.Extension -eq ".bz2") {
            $destination = "Archives"
        }
        # PowerShell scripts
        elseif ($file.Extension -eq ".ps1") {
            $destination = "PowerShell"
        }
        # Setup files
        elseif ($file.Name -like "*setup*") {
            $destination = "Setup"
        }
        # Automation files
        elseif ($file.Name -like "*automation*") {
            $destination = "Automation"
        }
        # Integration files
        elseif ($file.Name -like "*integration*") {
            $destination = "Integration"
        }
        # Configuration files
        elseif ($file.Name -like "*config*" -or $file.Name -like "*setting*") {
            $destination = "Configuration"
        }
        # Monitoring files
        elseif ($file.Name -like "*monitor*" -or $file.Name -like "*reporting*") {
            $destination = "Monitoring"
        }
        # Scripts
        elseif ($file.Name -like "*script*") {
            $destination = "Scripts"
        }
        # Guides
        elseif ($file.Name -like "*guide*") {
            $destination = "Guides"
        }
        # Conversion files
        elseif ($file.Name -like "*convert*" -or $file.Name -like "*conversion*") {
            $destination = "Conversion"
        }
        # Management files
        elseif ($file.Name -like "*manage*" -or $file.Name -like "*management*") {
            $destination = "Management"
        }
        
        # Move the file if a destination was determined
        if ($destination -ne "" -and $OrganizationalFolders -contains $destination) {
            $destinationPath = Join-Path -Path $DestinationPath -ChildPath $destination
            $destinationPath = Join-Path -Path $destinationPath -ChildPath $file.Name
            
            # Check if file already exists in destination
            if (Test-Path -Path $destinationPath) {
                Write-Host "WARNING: $($file.Name) already exists in $destination folder" -ForegroundColor $colors.Warning
                $skipped++
                continue
            }
            
            if ($WhatIf) {
                Write-Host "[PREVIEW] Would move $($file.Name) to $destination folder" -ForegroundColor $colors.Warning
            } else {
                Move-Item -Path $file.FullName -Destination $destinationPath
                Write-Host "Moved $($file.Name) to $destination folder" -ForegroundColor $colors.Success
            }
            
            # Add to tracking for summary
            $fileMoveTracker[$destination] += $file.Name
            
            $processed++
        } else {
            $skipped++
            $unmappedFiles += $file.Name
        }
        
        Write-Progress -Activity "Organizing files" -Status "Processed $($processed + $skipped) of $totalFiles files" -PercentComplete ((($processed + $skipped) / $totalFiles) * 100)
    }
    
    Write-Progress -Activity "Organizing files" -Completed
    
    # Generate summary report
    $summaryReport = @"
# Organization Summary Report
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Statistics
- Total Files Found: $totalFiles
- Files Organized: $processed
- Files Skipped: $skipped

## Folder Breakdown
"@
    
    foreach ($folder in $OrganizationalFolders) {
        $fileCount = $fileMoveTracker[$folder].Count
        $summaryReport += "`n### $folder - $fileCount files`n"
        
        if ($fileCount -gt 0) {
            $summaryReport += "````n"
            foreach ($fileName in $fileMoveTracker[$folder]) {
                $summaryReport += "- $fileName`n"
            }
            $summaryReport += "````n"
        }
    }
    
    if ($unmappedFiles.Count -gt 0) {
        $summaryReport += "`n### Unmapped Files - $($unmappedFiles.Count) files`n"
        $summaryReport += "````n"
        foreach ($fileName in $unmappedFiles) {
            $summaryReport += "- $fileName`n"
        }
        $summaryReport += "````n"
    }
    
    # Generate a relationship mapping file
    $relationshipMap = @"
# Folder Organization Map
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Overview
This document describes the organizational structure and relationships between folders.

"@
    
    foreach ($folder in $OrganizationalFolders) {
        $folderPath = Join-Path -Path $DestinationPath -ChildPath $folder
        $fileCount = if (Test-Path -Path $folderPath) { (Get-ChildItem -Path $folderPath -File -ErrorAction SilentlyContinue).Count } else { 0 }
        
        $relationshipMap += "`n## $folder`n"
        $relationshipMap += "- Files: $fileCount`n"
        
        # Add descriptions based on folder name
        switch ($folder) {
            "Setup" { $relationshipMap += "- Contains setup and installation files`n- Related to: Configuration, Management`n" }
            "Automation" { $relationshipMap += "- Contains automation scripts and tools`n- Related to: Scripts, Integration`n" }
            "Integration" { $relationshipMap += "- Contains integration files and connectors`n- Related to: Automation, Configuration`n" }
            "Configuration" { $relationshipMap += "- Contains configuration files and settings`n- Related to: Setup, Management`n" }
            "Monitoring" { $relationshipMap += "- Contains monitoring and reporting tools`n- Related to: Management, Automation`n" }

