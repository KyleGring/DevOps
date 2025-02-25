import os
import subprocess
import json
import shutil

# -------------------------
# Install VS Code (Windows)
# -------------------------
def install_vscode():
    print("Checking for VS Code installation...")
    vscode_path = "C:\\Program Files\\Microsoft VS Code\\Code.exe"
    if not os.path.exists(vscode_path):
        print("VS Code not found. Installing...")
        subprocess.run(["winget", "install", "Microsoft.VisualStudioCode"], check=True)
    else:
        print("VS Code is already installed.")

# -------------------------
# Define VS Code User Settings
# -------------------------
def apply_settings():
    settings_dir = os.path.expandvars(r"%APPDATA%\\Code\\User")
    os.makedirs(settings_dir, exist_ok=True)
    settings_path = os.path.join(settings_dir, "settings.json")
    settings = {
        "editor.fontSize": 14,
        "editor.fontFamily": "Fira Code, Consolas, 'Courier New', monospace",
        "editor.tabSize": 4,
        "editor.formatOnSave": True,
        "editor.bracketPairColorization.enabled": True,
        "workbench.colorTheme": "One Dark Pro",
        "terminal.integrated.defaultProfile.windows": "PowerShell",
        "terminal.integrated.shell.windows": "C:\\Program Files\\Git\\bin\\bash.exe"
    }
    with open(settings_path, "w", encoding="utf-8") as f:
        json.dump(settings, f, indent=4)
    print("VS Code settings applied!")

# -------------------------
# Install Extensions
# -------------------------
def install_extensions():
    code_path = shutil.which("code.cmd") or r"C:\\Program Files\\Microsoft VS Code\\bin\\code.cmd"
    extensions = [
        "ms-python.python",
        "ms-vscode.cpptools",
        "esbenp.prettier-vscode",
        "dbaeumer.vscode-eslint",
        "eamodio.gitlens",
        "redhat.vscode-yaml",
        "ms-vscode-remote.remote-containers",
        "ms-vscode.powershell",
        "dracula-theme.theme-dracula",
        "pkief.material-icon-theme",
        "VisualStudioExptTeam.vscodeintellicode"
    ]
    for ext in extensions:
        subprocess.run([code_path, "--install-extension", ext], check=True)
    print("All extensions installed!")

# -------------------------
# Create an Admin Profile
# -------------------------
def create_admin_profile():
    settings_dir = os.path.expandvars(r"%APPDATA%\\Code\\User")
    tasks_path = os.path.join(settings_dir, "tasks.json")
    tasks = {
        "version": "2.0.0",
        "tasks": [
            {
                "label": "Run as Administrator",
                "type": "shell",
                "command": "powershell",
                "args": ["Start-Process", "code", "-Verb", "RunAs"]
            }
        ]
    }
    with open(tasks_path, "w", encoding="utf-8") as f:
        json.dump(tasks, f, indent=4)
    print("Admin profile created!")

# -------------------------
# Sync Settings Across Devices
# -------------------------
def sync_settings():
    code_path = shutil.which("code.cmd") or r"C:\\Program Files\\Microsoft VS Code\\bin\\code.cmd"
    subprocess.run([code_path, "--sync", "on"], check=True)
    print("VS Code settings sync enabled!")

if __name__ == "__main__":
    install_vscode()
    apply_settings()
    install_extensions()
    create_admin_profile()
    sync_settings()
    print("VS Code setup complete! Relaunch VS Code for changes to take effect.")

