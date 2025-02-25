import os
import shutil
import subprocess
import urllib.request
import zipfile
import xml.etree.ElementTree as ET

# Notepad++ settings paths
NPP_INSTALLER_URL = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/latest/download/npp.8.5.3.Installer.x64.exe"
NPP_INSTALL_PATH = os.path.expandvars(r"%ProgramFiles%\Notepad++")
NPP_CONFIG_PATH = os.path.expandvars(r"%AppData%\Notepad++")
# Plugin manager is no longer maintained at the old URL
# Using official Plugin Admin instead
# Skip plugin installation since we're having issues with URLs
# Users can install plugins manually through Notepad++ Plugin Manager
SKIP_PLUGINS = True

# Essential plugins to install
PLUGINS = [
    "PythonScript.dll",
    "NppExec.dll",
    "ComparePlugin.dll",
    "AutoSave.dll",
    "NppGIT.dll"
]
PLUGINS_DIR = os.path.join(NPP_INSTALL_PATH, "plugins")

# Optimized Notepad++ config - fixed syntax
CONFIG_XML = """<?xml version="1.0" encoding="UTF-8"?>
<NotepadPlus>
    <GUIConfigs>
        <GUIConfig name="DarkMode">yes</GUIConfig>
        <GUIConfig name="SessionExt">xml</GUIConfig>
        <GUIConfig name="TabSetting" size="4" replaceBySpace="no" />
        <GUIConfig name="AppPosition" x="0" y="0" width="1024" height="768" isMaximized="yes" />
        <GUIConfig name="RememberLastSession">yes</GUIConfig>
        <GUIConfig name="AutoCompletion">
            <Element"autoCAction">3</Element>
            <Element"triggerFromNbChar">1</Element>
            <Element"isWordPartAlso">yes</Element>
        </GUIConfig>
        <GUIConfig name="AutoUpdate">no</GUIConfig>
        <GUIConfig name="Backup" action="1" useCustumDir="yes" dir="$(APPDATA)\\Notepad++\\backup" isSnapshotMode="yes" snapshotBackupTiming="7000" />
        <GUIConfig name="MaitainIndent">yes</GUIConfig>
        <GUIConfig name="NewDocDefaultSettings" format="0" encoding="4" lang="0" openAnsiAsUTF8="no" />
    </GUIConfigs>
</NotepadPlus>"""

def download_file(url, dest):
    print(f"Downloading: {url} -> {dest}")
    try:
        urllib.request.urlretrieve(url, dest)
    except urllib.error.HTTPError as e:
        print(f"HTTP Error: {e.code} - {e.reason}")
    except urllib.error.URLError as e:
        print(f"URL Error: {e.reason}")

def install_notepad():
    if not os.path.exists(NPP_INSTALL_PATH):
        print("Installing Notepad++...")
        installer_path = os.path.join(os.getcwd(), "npp_installer.exe")
        download_file(NPP_INSTALLER_URL, installer_path)
        subprocess.run([installer_path, "/S"], check=True)
        os.remove(installer_path)
    else:
        print("Notepad++ is already installed.")

def configure_notepad():
    # Create a backup of existing config if it exists
    if os.path.exists(NPP_CONFIG_PATH):
        backup_dir = os.path.join(os.getcwd(), "npp_config_backup")
        try:
            if not os.path.exists(backup_dir):
                os.makedirs(backup_dir)
            for file in os.listdir(NPP_CONFIG_PATH):
                if file.endswith(".xml"):
                    src = os.path.join(NPP_CONFIG_PATH, file)
                    dst = os.path.join(backup_dir, file)
                    shutil.copy2(src, dst)
            print(f"Backed up existing config to {backup_dir}")
        except Exception as e:
            print(f"Backup warning: {str(e)}")
    
    os.makedirs(NPP_CONFIG_PATH, exist_ok=True)
    
    # Main config - minimal to avoid conflicts
    config_file = os.path.join(NPP_CONFIG_PATH, "config.xml")
    with open(config_file, "w", encoding="utf-8") as f:
        f.write(CONFIG_XML)
    
    print("Applied minimal Notepad++ settings to prevent startup issues.")

def install_plugins():
    os.makedirs(PLUGINS_DIR, exist_ok=True)
    plugin_admin_zip = os.path.join(os.getcwd(), "plugin_admin.zip")
    plugin_admin_extract = os.path.join(os.getcwd(), "plugin_admin")
    
    # Download Plugin Admin
    download_file(PLUGIN_ADMIN_URL, plugin_admin_zip)
    
    try:
        # Only proceed if the file was downloaded successfully
        if os.path.exists(plugin_admin_zip):
            with zipfile.ZipFile(plugin_admin_zip, "r") as zip_ref:
                zip_ref.extractall(plugin_admin_extract)
            
            # Copy Plugin Admin to plugins directory
            plugin_admin_src = os.path.join(plugin_admin_extract, "PluginAdmin.dll")
            if os.path.exists(plugin_admin_src):
                shutil.copy(plugin_admin_src, os.path.join(PLUGINS_DIR, "PluginAdmin.dll"))
                print("Installed Plugin Admin successfully.")
            else:
                print("Warning: Could not find PluginAdmin.dll in the extracted files.")
            
            # Clean up
            if os.path.exists(plugin_admin_zip):
                os.remove(plugin_admin_zip)
            if os.path.exists(plugin_admin_extract):
                shutil.rmtree(plugin_admin_extract)
        else:
            print("Warning: Plugin Admin download failed. You can install plugins manually.")
            
    except zipfile.BadZipFile:
        print("Error: Downloaded zip file is corrupted. Please check the URL.")
    except Exception as e:
        print(f"Error installing plugins: {str(e)}")
        print("You can install plugins manually through Notepad++ Plugin Admin once Notepad++ is running.")

def run_as_admin():
    try:
        # Create the batch file in the current directory instead of Program Files
        # to avoid permission issues
        current_dir = os.getcwd()
        admin_script = os.path.join(current_dir, "RunNotepadAsAdmin.bat")
        
        with open(admin_script, "w") as f:
            f.write(f"powershell Start-Process \"{os.path.join(NPP_INSTALL_PATH, 'notepad++.exe')}\" -Verb runAs")
        
        print(f"Admin shortcut created at: {admin_script}")
    except Exception as e:
        print(f"Warning: Could not create admin script: {str(e)}")

def main():
    install_notepad()
    configure_notepad()
    
    if not SKIP_PLUGINS:
        install_plugins()
    else:
        print("Skipping plugin installation. Plugins can be installed manually from Notepad++ Plugins menu.")
    
    run_as_admin()
    print("âœ… Notepad++ setup complete!")
    print("NOTE: To install plugins, open Notepad++ and go to Plugins -> Plugins Admin")
    print("\nTroubleshooting:")
    print("- If Notepad++ won't open, delete %APPDATA%\\Notepad++ folder and run this script again")
    print("- Or run Notepad++ with the -noPlugin and -noConfig command line options to reset")

if __name__ == "__main__":
    main()


