# Project_Git: Master Setup Guide

## ðŸ“Œ Overview
Project_Git automates the setup of multiple GitHub repositories, ensuring an efficient and structured workflow for automation, DevOps, and AI-driven projects.

## ðŸ”¥ Features
âœ… **Creates and initializes five key GitHub repositories**
âœ… **Sets up folder structures, .gitignore, and README.md**
âœ… **Automates initial commits and pushes to GitHub**
âœ… **Includes validation scripts to verify setup**
âœ… **Installs GitHub Copilot for AI-assisted coding**

---

## ðŸ“‚ Repositories Included
### 1ï¸âƒ£ `Ops-Optimizer`
*Purpose:* Main repository for DevOps automation, GitHub workflows, and Windows optimizations.
- `setup/` - Windows & DevOps automation scripts
- `automation/` - Python & PowerShell scripts
- `config/` - VS Code, Git, and Terminal settings
- `docs/` - Documentation & setup guides

### 2ï¸âƒ£ `AI-Data-Toolkit`
*Purpose:* AI-powered file processing, deduplication, and metadata extraction.
- `scripts/` - Python automation scripts
- `ai_models/` - Pre-trained AI tagging models
- `data_processing/` - File deduplication & metadata extraction
- `notion_integration/` - API scripts to push data into Notion

### 3ï¸âƒ£ `DevOps-Deploy`
*Purpose:* Infrastructure as Code (Terraform, Ansible, Docker, CI/CD pipelines).
- `terraform/` - Cloud infrastructure automation
- `ansible/` - Configuration management scripts
- `docker/` - Containerized development workflows
- `ci-cd/` - GitHub Actions & pipelines

### 4ï¸âƒ£ `Notion-AutoSync`
*Purpose:* Syncs GitHub issues and markdown documentation to Notion.
- `scripts/` - Python API scripts for Notion sync
- `github_actions/` - Automation workflows
- `notion_templates/` - Pre-built workspace templates

### 5ï¸âƒ£ `Secure-Credentials-Manager`
*Purpose:* Automates 1Password CLI setup, GitHub SSH key management, and secure credential storage.
- `op_cli/` - 1Password CLI automation scripts
- `ssh_keys/` - Secure GitHub SSH key management
- `secrets_manager/` - Secure credential handling scripts

---

## âš™ï¸ Installation & Execution
### ðŸ“¥ Step 1: Extract the Package
Extract `Project_Git_Setup.zip` to `C:\Development\`.

### ðŸš€ Step 2: Run the Setup Script
Run the following as **Administrator**:
```sh
C:\Development\Project_Git\install\setup_repos.bat
```

### âœ… Step 3: Validate the Setup
Run the validation script to confirm everything is configured correctly:
```sh
C:\Development\Project_Git\validation\verify_setup.bat
```

### ðŸ— Step 4: Start Coding
Navigate to your workspace and open `Ops-Optimizer` in VS Code:
```sh
cd C:\Development\Project_Git\repos\Ops-Optimizer
code .
```

---

## ðŸ›  Troubleshooting & Next Steps
- **GitHub CLI Authentication Issue?** Run `gh auth login`.
- **Repositories Not Cloning?** Ensure you have proper permissions.
- **GitHub Copilot Not Working?** Install it manually via VS Code extensions.
- **Expand Features**: Integrate additional workflows, automate Notion, optimize credentials storage.

ðŸš€ **Project_Git is now fully automated and optimized for execution!**



