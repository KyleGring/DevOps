import os
import shutil
import subprocess
import urllib.request
import json

# Advanced Notepad++ customization script

def create_custom_theme():
    """Create a modern dark theme for coding"""
    theme_dir = os.path.expandvars(r"%AppData%\Notepad++\themes")
    os.makedirs(theme_dir, exist_ok=True)
    
    # Elite Dark Pro theme
    theme_content = """<?xml version="1.0" encoding="utf-8"?>
<NotepadPlus>
    <LexerStyles>
        <LexerType name="python" desc="Python" ext="">
            <WordsStyle name="DEFAULT" styleID="0" fgColor="F8F8F2" bgColor="282C34" fontName="Consolas" fontStyle="0" fontSize="10" />
            <WordsStyle name="COMMENTLINE" styleID="1" fgColor="6A9955" bgColor="282C34" fontName="" fontStyle="0" fontSize="" />
            <WordsStyle name="NUMBER" styleID="2" fgColor="B5CEA8" bgColor="282C34" fontName="" fontStyle="0" fontSize="" />
            <WordsStyle name="STRING" styleID="3" fgColor="CE9178" bgColor="282C34" fontName="" fontStyle="0" fontSize="" />
            <WordsStyle name="CHARACTER" styleID="4" fgColor="CE9178" bgColor="282C34" fontName="" fontStyle="0" fontSize="" />
            <WordsStyle name="KEYWORDS" styleID="5" fgColor="569CD6" bgColor="282C34" fontName="" fontStyle="1" fontSize="" keywordClass="instre1" />
            <WordsStyle name="TRIPLE" styleID="6" fgColor="6A9955" bgColor="282C34" fontName="" fontStyle="0" fontSize="" />
            <WordsStyle name="TRIPLEDOUBLE" styleID="7" fgColor="6A9955" bgColor="282C34" fontName="" fontStyle="0" fontSize="" />
            <WordsStyle name="CLASSNAME" styleID="8" fgColor="4EC9B0" bgColor="282C34" fontName="" fontStyle="1" fontSize="" />
            <WordsStyle name="DEFNAME" styleID="9" fgColor="DCDCAA" bgColor="282C34" fontName="" fontStyle="0" fontSize="" />
            <WordsStyle name="OPERATOR" styleID="10" fgColor="D4D4D4" bgColor="282C34" fontName="" fontStyle="1" fontSize="" />
            <WordsStyle name="IDENTIFIER" styleID="11" fgColor="9CDCFE" bgColor="282C34" fontName="" fontStyle="0" fontSize="" />
            <WordsStyle name="COMMENTBLOCK" styleID="12" fgColor="6A9955" bgColor="282C34" fontName="" fontStyle="0" fontSize="" />
        </LexerType>
    </LexerStyles>
    <GlobalStyles>
        <WidgetStyle name="Global override" styleID="0" fgColor="F8F8F2" bgColor="282C34" fontName="Consolas" fontStyle="0" fontSize="10" />
        <WidgetStyle name="Default Style" styleID="32" fgColor="F8F8F2" bgColor="282C34" fontName="Consolas" fontStyle="0" fontSize="10" />
        <WidgetStyle name="Line number margin" styleID="33" fgColor="858585" bgColor="1E1E1E" fontName="Consolas" fontStyle="0" fontSize="8" />
        <WidgetStyle name="Current line background colour" styleID="0" bgColor="303030" />
        <WidgetStyle name="Selected text colour" styleID="0" bgColor="264F78" />
        <WidgetStyle name="Edge colour" styleID="0" fgColor="4C4C4C" />
    </GlobalStyles>
</NotepadPlus>"""

    # Write theme file
    with open(os.path.join(theme_dir, "EliteDarkPro.xml"), "w", encoding="utf-8") as f:
        f.write(theme_content)
    
    return True

def setup_smart_save_paths():
    """Configure auto-backup and smart save paths"""
    config_dir = os.path.expandvars(r"%AppData%\Notepad++")
    backup_dir = os.path.join(config_dir, "backup")
    os.makedirs(backup_dir, exist_ok=True)
    
    # Create session config
    session_content = """<?xml version="1.0" encoding="UTF-8" ?>
<NotepadPlus>
    <Session activeView="0">
        <mainView>
            <File firstVisibleLine="0" xOffset="0" />
        </mainView>
    </Session>
</NotepadPlus>"""
    
    with open(os.path.join(config_dir, "session.xml"), "w", encoding="utf-8") as f:
        f.write(session_content)
    
    # Create file type associations
    associations = {
        ".py": "python",
        ".js": "javascript",
        ".html": "html",
        ".css": "css",
        ".json": "json",
        ".xml": "xml",
        ".md": "markdown",
        ".txt": "normal",
        ".ps1": "powershell",
        ".bat": "batch",
        ".sh": "bash"
    }
    
    langs_xml = """<?xml version="1.0" encoding="UTF-8" ?>
<NotepadPlus>
    <Languages>
"""
    
    for ext, lang in associations.items():
        langs_xml += f'        <Language ext="{ext}" name="{lang}" />\n'
    
    langs_xml += """    </Languages>
</NotepadPlus>"""
    
    with open(os.path.join(config_dir, "langs.xml"), "w", encoding="utf-8") as f:
        f.write(langs_xml)
    
    return True

def create_toolbar_macros():
    """Create useful macros for the toolbar"""
    macros_dir = os.path.expandvars(r"%AppData%\Notepad++\shortcuts.xml")
    
    macros_content = """<?xml version="1.0" encoding="UTF-8" ?>
<NotepadPlus>
    <InternalCommands>
        <!-- Comment/Uncomment -->
        <Shortcut id="42022" Ctrl="yes" Alt="no" Shift="yes" Key="191" />
        <Shortcut id="42023" Ctrl="yes" Alt="no" Shift="yes" Key="193" />
        
        <!-- Line operations -->
        <Shortcut id="43014" Ctrl="yes" Alt="no" Shift="no" Key="68" />  <!-- Duplicate current line -->
        <Shortcut id="43006" Ctrl="yes" Alt="no" Shift="no" Key="76" />  <!-- Delete current line -->
        <Shortcut id="42042" Ctrl="yes" Alt="no" Shift="yes" Key="38" />  <!-- Move line up -->
        <Shortcut id="42043" Ctrl="yes" Alt="no" Shift="yes" Key="40" />  <!-- Move line down -->
        
        <!-- File operations -->
        <Shortcut id="41008" Ctrl="yes" Alt="no" Shift="yes" Key="83" />  <!-- Save as -->
        <Shortcut id="41005" Ctrl="no" Alt="yes" Shift="no" Key="115" />  <!-- Save all -->
        
        <!-- Navigation -->
        <Shortcut id="43012" Ctrl="yes" Alt="no" Shift="yes" Key="66" />  <!-- Go to matching brace -->
        <Shortcut id="43014" Ctrl="yes" Alt="yes" Shift="no" Key="38" />  <!-- Go to previous function -->
        <Shortcut id="43015" Ctrl="yes" Alt="yes" Shift="no" Key="40" />  <!-- Go to next function -->
    </InternalCommands>
    <Macros>
        <Macro name="Trim Trailing Spaces" Ctrl="no" Alt="yes" Shift="yes" Key="84">
            <Action type="2" message="0" wParam="42024" lParam="0" sParam="" />
        </Macro>
        <Macro name="Convert Tabs to Spaces" Ctrl="no" Alt="yes" Shift="yes" Key="32">
            <Action type="2" message="0" wParam="42027" lParam="0" sParam="" />
        </Macro>
    </Macros>
</NotepadPlus>"""
    
    with open(macros_dir, "w", encoding="utf-8") as f:
        f.write(macros_content)
    
    return True

def configure_context_menu():
    """Add Notepad++ to Windows context menu"""
    try:
        # Create registry commands using PowerShell
        ps_command = """
        # Add 'Edit with Notepad++' to context menu
        $nppPath = "${env:ProgramFiles}\\Notepad++\\notepad++.exe"
        if (Test-Path $nppPath) {
            # For all files
            New-Item -Path "HKCU:\\Software\\Classes\\*\\shell\\EditWithNpp" -Force | Out-Null
            Set-ItemProperty -Path "HKCU:\\Software\\Classes\\*\\shell\\EditWithNpp" -Name "(Default)" -Value "Edit with Notepad++"
            Set-ItemProperty -Path "HKCU:\\Software\\Classes\\*\\shell\\EditWithNpp" -Name "Icon" -Value "`"$nppPath`",0"
            New-Item -Path "HKCU:\\Software\\Classes\\*\\shell\\EditWithNpp\\command" -Force | Out-Null
            Set-ItemProperty -Path "HKCU:\\Software\\Classes\\*\\shell\\EditWithNpp\\command" -Name "(Default)" -Value "`"$nppPath`" `"%1`""
            
            # For folders
            New-Item -Path "HKCU:\\Software\\Classes\\Directory\\shell\\EditWithNpp" -Force | Out-Null
            Set-ItemProperty -Path "HKCU:\\Software\\Classes\\Directory\\shell\\EditWithNpp" -Name "(Default)" -Value "Open folder in Notepad++"
            Set-ItemProperty -Path "HKCU:\\Software\\Classes\\Directory\\shell\\EditWithNpp" -Name "Icon" -Value "`"$nppPath`",0"
            New-Item -Path "HKCU:\\Software\\Classes\\Directory\\shell\\EditWithNpp\\command" -Force | Out-Null
            Set-ItemProperty -Path "HKCU:\\Software\\Classes\\Directory\\shell\\EditWithNpp\\command" -Name "(Default)" -Value "`"$nppPath`" `"%1`""
            
            Write-Output "Successfully added Notepad++ to context menu"
        } else {
            Write-Output "Notepad++ not found at $nppPath"
        }
        """
        
        # Write PowerShell script to temp file
        ps_script = os.path.join(os.environ.get('TEMP', os.getcwd()), "npp_context_menu.ps1")
        with open(ps_script, "w") as f:
            f.write(ps_command)
        
        # Execute the PowerShell script with bypassed execution policy
        subprocess.run(["powershell", "-ExecutionPolicy", "Bypass", "-File", ps_script], check=True)
        
        # Clean up
        os.remove(ps_script)
        return True
    except Exception as e:
        print(f"Error setting up context menu: {str(e)}")
        return False

def main():
    """Main function to customize Notepad++"""
    print("ðŸš€ Starting Elite Notepad++ Customization...")
    
    # Apply the custom dark theme
    if create_custom_theme():
        print("âœ… Applied Elite Dark Pro theme")
    
    # Setup smart save paths and file associations
    if setup_smart_save_paths():
        print("âœ… Configured smart save paths and file associations")
    
    # Create keyboard shortcuts and macros
    if create_toolbar_macros():
        print("âœ… Added productivity keyboard shortcuts and macros")
    
    # Configure Windows context menu integration
    if configure_context_menu():
        print("âœ… Added Notepad++ to Windows context menu")
    
    print("\nðŸŽ‰ Elite Notepad++ customization complete!")
    print("\nKeyboard Shortcuts:")
    print("- Ctrl+Shift+/ = Comment code")
    print("- Ctrl+Shift+\\ = Uncomment code")
    print("- Ctrl+D = Duplicate line")
    print("- Ctrl+L = Delete line")
    print("- Ctrl+Shift+Up/Down = Move line up/down")
    print("- Alt+Shift+T = Trim trailing spaces")

if __name__ == "__main__":
    main()


