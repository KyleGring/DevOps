import subprocess
import winreg

def set_default_browser():
    chrome_prog_id = "ChromeHTML"
    
    # File types to update
    file_types = [".htm", ".html", ".mhtml", ".pdf", ".shtml", ".svg", ".xml", ".xhtml", ".php", ".asp", ".json"]
    
    # Protocols to update
    protocols = ["http", "https", "mailto", "mms", "sms", "tel", "webcal"]

    try:
        # Set file associations
        for ext in file_types:
            cmd = f'ftype {ext}="C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe" "%1"'
            subprocess.run(cmd, shell=True)

        # Set protocol handlers in registry
        for protocol in protocols:
            reg_path = fr"Software\Microsoft\Windows\Shell\Associations\UrlAssociations\{protocol}\UserChoice"
            with winreg.OpenKey(winreg.HKEY_CURRENT_USER, reg_path, 0, winreg.KEY_SET_VALUE) as key:
                winreg.SetValueEx(key, "ProgId", 0, winreg.REG_SZ, chrome_prog_id)

        print("Successfully updated default browser and protocol settings to Google Chrome.")
    except Exception as e:
        print(f"Error updating default browser: {e}")

if __name__ == "__main__":
    set_default_browser()


