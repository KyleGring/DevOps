# Project\_Git: Step-by-Step Execution Order

## ðŸ“Œ Overview

This document provides a structured execution order for setting up Project\_Git from start to finish. Follow these steps carefully to ensure a smooth and successful installation.

---

## **ðŸ”¹ Step 1: Run the Master Setup Script**

### **Purpose:** Creates all required folders, repositories, and scripts.

### **Run:**

1. **Open PowerShell as Administrator**
2. **Execute the following command:**
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   C:\Development\setup_project_git.ps1
   ```
3. **Wait for the script to complete.** It will:
   - Create all necessary directories.
   - Generate setup and validation scripts.
   - Clone and initialize GitHub repositories.
   - Commit and push initial files.

### **Script (**``**):**

```powershell
# Set up Project_Git environment
$BaseDir = "C:\Development\Project_Git"
$RepoDir = "$BaseDir\repos"
$InstallDir = "$BaseDir\install"
$ValidationDir = "$BaseDir\validation"
$DocsDir = "$BaseDir\docs"

# Ensure all required directories exist
$Folders = @($BaseDir, $RepoDir, $InstallDir, $ValidationDir, $DocsDir)
foreach ($folder in $Folders) {
    if (-Not (Test-Path $folder)) { New-Item -ItemType Directory -Path $folder -Force }
}
Write-Output "âœ… Project_Git setup files are ready!"
Write-Output "Run: C:\Development\Project_Git\install\setup_repos.bat"
```

---

## **ðŸ”¹ Step 2: Run the Setup Script**

### **Purpose:** Automates GitHub repo creation, cloning, and initialization.

### **Run:**

1. Open File Explorer and navigate to:
   ```
   C:\Development\Project_Git\install
   ```
2. **Right-click** `setup_repos.bat` and select **Run as Administrator**.
3. Follow the on-screen instructions.

### **Script (**``**):**

```batch
@echo off
echo Setting up GitHub repositories...
powershell -ExecutionPolicy Bypass -File "%~dp0setup_repos.ps1"
pause
```

### **Script (**``**):**

```powershell
# PowerShell script to automate GitHub repo creation
$GitHubUser = "KyleGring"
$RepoDir = "C:\Development\Project_Git\repos"
$Repos = @(
    @{Name="Ops-Optimizer"; Desc="Optimized GitHub Automation & DevOps"},
    @{Name="AI-Data-Toolkit"; Desc="AI-powered data processing & automation"},
    @{Name="DevOps-Deploy"; Desc="Infrastructure as code & CI/CD automation"},
    @{Name="Notion-AutoSync"; Desc="Sync GitHub issues & docs to Notion"},
    @{Name="Secure-Credentials-Manager"; Desc="1Password CLI & secure credential automation"}
)
foreach ($Repo in $Repos) {
    $RepoPath = "$RepoDir\$($Repo.Name)"
    if (-Not (Test-Path $RepoPath)) {
        gh repo create "$($Repo.Name)" --private --description "$($Repo.Desc)"
        gh repo clone "$GitHubUser/$($Repo.Name)" "$RepoPath"
    }
    Set-Content -Path "$RepoPath\README.md" -Value "# $($Repo.Name)"
    git -C "$RepoPath" add .
    git -C "$RepoPath" commit -m "Initial commit"
    git -C "$RepoPath" push origin main
}
```

---

## **ðŸ”¹ Step 3: Validate Setup**

### **Purpose:** Ensures everything is correctly installed and configured.

### **Run:**

1. Open File Explorer and navigate to:
   ```
   C:\Development\Project_Git\validation
   ```
2. **Right-click** `verify_setup.bat` and select **Run as Administrator**.

### **Script (**``**):**

```batch
@echo off
echo Verifying GitHub CLI authentication...
gh auth status
echo Checking repositories...
cd C:\Development\Project_Git\repos
for /D %%G in (*) do (
    echo Checking repository: %%G
    cd %%G
    git status
    cd ..
)
pause
```

---

## **ðŸ”¹ Step 4: Open and Start Working in VS Code**

### **Purpose:** Start coding with GitHub Copilot enabled.

### **Run:**

1. Open PowerShell and run:
   ```powershell
   cd C:\Development\Project_Git\repos\Ops-Optimizer
   code .
   ```

---

## âœ… **Final Checklist**

âœ” Master setup script ran successfully (`setup_project_git.ps1`) âœ” Setup script executed (`setup_repos.bat`) âœ” Validation completed (`verify_setup.bat`) âœ” Repositories cloned and initialized âœ” VS Code opened and ready to work

ðŸš€ **Project\_Git is now fully set up!**



