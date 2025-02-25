# Set up Project_Git environment
$BaseDir = "C:\Development\Project_Git"
$RepoDir = "$BaseDir\repos"
$InstallDir = "$BaseDir\install"
$ValidationDir = "$BaseDir\validation"
$DocsDir = "$BaseDir\docs"

# List of repositories
$GitHubUser = "KyleGring"
$Repos = @(
    @{Name="Ops-Optimizer"; Desc="Optimized GitHub Automation & DevOps"},
    @{Name="AI-Data-Toolkit"; Desc="AI-powered data processing & automation"},
    @{Name="DevOps-Deploy"; Desc="Infrastructure as code & CI/CD automation"},
    @{Name="Notion-AutoSync"; Desc="Sync GitHub issues & docs to Notion"},
    @{Name="Secure-Credentials-Manager"; Desc="1Password CLI & secure credential automation"}
)

# Ensure all required directories exist
$Folders = @($BaseDir, $RepoDir, $InstallDir, $ValidationDir, $DocsDir)
foreach ($folder in $Folders) {
    if (-Not (Test-Path $folder)) { New-Item -ItemType Directory -Path $folder -Force }
}

# Create README.md
$ReadMePath = "$BaseDir\README.md"
$ReadMeContent = @"
# Project_Git

## Overview
This script automates the setup of multiple GitHub repositories, including folder structure, scripts, and validation.

## Repositories
- **Ops-Optimizer** - DevOps & automation scripts
- **AI-Data-Toolkit** - AI-powered file & metadata processing
- **DevOps-Deploy** - Infrastructure & CI/CD management
- **Notion-AutoSync** - GitHub â†” Notion synchronization
- **Secure-Credentials-Manager** - Secure credential automation

## Installation
1. Run `setup_project_git.ps1` as Administrator.
2. Follow on-screen instructions.
3. Verify repositories in GitHub.
4. Start working in `C:\Development\Project_Git\repos\Ops-Optimizer`.

## Validation
Run:
```sh
C:\Development\Project_Git\validation\verify_setup.bat


