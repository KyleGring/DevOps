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
# Latest valid URL for Plugin Admin as of 2024
PLUGIN_ADMIN_URL = "https://github.com/npp-plugins/pluginadmin/releases/download/v2.2.2/PluginAdmin_v2.2.2_x64.zip"

# Essential plugins to install
PLUGINS = [
    "PythonScript.dll",
    "NppExec.dll",
    "ComparePlugin.dll",
    "AutoSave.dll",
    "NppGIT.dll"
]
PLUGINS_DIR = os.path.join(NPP_INSTALL_PATH, "plugins")

# Optimized Notepad++ config
CONFIG_XML = """<?xml version="1.0" encoding="UTF-8"?>
<NotepadPlus>
    <GUIConfig name="DarkMode" enable="yes"/>
    <GUIConfig name="SessionPersistence" enable="yes"/>
    <GUIConfig name="AutoSave" enable="yes"/>
    <GUIConfig name="RememberLastSession" enable="yes"/>
    <GUIConfig name="Minimized" enable="no"/>
    <GUIConfig name="Language" format="English"/>
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
    os.makedirs(NPP_CONFIG_PATH, exist_ok=True)
    config_file = os.path.join(NPP_CONFIG_PATH, "config.xml")
    with open(config_file, "w", encoding="utf-8") as f:
        f.write(CONFIG_XML)
    print("Applied optimized Notepad++ settings.")

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
    install_plugins()
    run_as_admin()
    print("âœ… Notepad++ setup complete!")

if __name__ == "__main__":
    main()


