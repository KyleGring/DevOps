import os
import shutil
import ctypes
import subprocess
import sys

def is_admin():
    """Checks if the script is running with administrative privileges."""
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

def run_as_admin():
    """Re-runs the script with admin privileges if not already elevated."""
    if not is_admin():
        print("[!] Relaunching script as Administrator...")
        script = os.path.abspath(sys.argv[0])
        params = ' '.join([f'"{arg}"' for arg in sys.argv[1:]])
        ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, f'"{script}" {params}', None, 1)
        sys.exit(0)

def take_ownership(folder_path):
    """Grants full control permissions to the current user for a given folder."""
    try:
        current_user = os.getlogin()
        subprocess.run(["icacls", folder_path, "/grant", f"{current_user}:F"], check=True, capture_output=True)
    except subprocess.CalledProcessError as e:
        print(f"[!] Failed to set permissions for {folder_path}: {e}")

def close_locking_processes():
    """Closes processes that may be locking DevOps folders (Explorer, VS Code, PowerShell)."""
    processes = ["explorer.exe", "code.exe", "powershell.exe"]
    for process in processes:
        subprocess.run(["taskkill", "/F", "/IM", process], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def create_folders(base_path, folder_structure):
    """Creates folders based on the given structure and assigns icons."""
    icon_mapping = {
        "projects": "C:\\Windows\\System32\\shell32.dll,1",
        "tools": "C:\\Windows\\System32\\shell32.dll,2",
        "environments": "C:\\Windows\\System32\\shell32.dll,3",
        "logs": "C:\\Windows\\System32\\shell32.dll,4",
        "backups": "C:\\Windows\\System32\\shell32.dll,5",
        "documentation": "C:\\Windows\\System32\\shell32.dll,6"
    }
    
    for folder in folder_structure:
        folder_path = os.path.join(base_path, folder)
        os.makedirs(folder_path, exist_ok=True)
        
        # Ensure folder is writable before modifying
        take_ownership(folder_path)
        os.system(f"attrib -r -s -h \"{folder_path}\"")
        
        # Create a README file for each folder
        readme_path = os.path.join(folder_path, "README.md")
        if not os.path.exists(readme_path):
            with open(readme_path, "w") as f:
                f.write(f"# {folder}\n\nThis directory is used for {folder.replace('_', ' ').title()}.")
        
        # Assign folder icon if applicable
        parent_folder = folder.split("\\")[0]  # Get the primary folder
        if parent_folder in icon_mapping:
            desktop_ini_path = os.path.join(folder_path, "desktop.ini")
            try:
                with open(desktop_ini_path, "w") as ini:
                    ini.write(f"[.ShellClassInfo]\nIconResource={icon_mapping[parent_folder]}\n[ViewState]\nMode=\nVid=\nFolderType=Generic")
                os.system(f"attrib +h +s \"{desktop_ini_path}\"")
                os.system(f"attrib +s \"{folder_path}\"")  # Set folder as a system folder
            except PermissionError:
                print(f"[!] Permission denied: {desktop_ini_path}. Trying to take ownership.")
                take_ownership(desktop_ini_path)

def refresh_explorer():
    """Restart Windows Explorer to apply icon changes."""
    subprocess.run(["explorer.exe"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def main():
    run_as_admin()
    close_locking_processes()
    base_path = "C:\\DevOps"
    
    # Define the DevOps directory structure
    folder_structure = [
        "projects",
        "projects\\active",
        "projects\\archived",
        "projects\\templates",
        "tools",
        "tools\\scripts",
        "tools\\binaries",
        "tools\\configs",
        "environments",
        "environments\\python",
        "environments\\node",
        "environments\\docker",
        "environments\\terraform",
        "logs",
        "logs\\system",
        "logs\\application",
        "logs\\automation",
        "backups",
        "backups\\daily",
        "backups\\weekly",
        "backups\\monthly",
        "documentation",
        "documentation\\best-practices",
        "documentation\\project-docs",
        "documentation\\tools-docs"
    ]
    
    # Create the directory structure
    create_folders(base_path, folder_structure)
    
    # Restart Windows Explorer to apply icon changes
    refresh_explorer()
    
    print(f"DevOps folder structure created successfully at {base_path}.")
    
if __name__ == "__main__":
    main()

