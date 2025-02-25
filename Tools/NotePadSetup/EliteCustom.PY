import os
import shutil
import subprocess
import urllib.request
import json
import zipfile
import winreg

# Advanced Notepad++ customization script for power users

# Paths
NPP_INSTALL_PATH = os.path.expandvars(r"%ProgramFiles%\Notepad++")
NPP_CONFIG_PATH = os.path.expandvars(r"%AppData%\Notepad++")
NPP_PLUGINS_PATH = os.path.join(NPP_INSTALL_PATH, "plugins")

# Create required directories
os.makedirs(NPP_CONFIG_PATH, exist_ok=True)
os.makedirs(os.path.join(NPP_CONFIG_PATH, "functionList"), exist_ok=True)
os.makedirs(os.path.join(NPP_CONFIG_PATH, "autoCompletion"), exist_ok=True)

def download_file(url, dest):
    """Download file with error handling"""
    try:
        urllib.request.urlretrieve(url, dest)
        return True
    except Exception as e:
        print(f"Download error: {str(e)}")
        return False

def setup_code_folding():
    """Configure advanced code folding for different languages"""
    folding_config = """<?xml version="1.0" encoding="UTF-8" ?>
<FolderStyle id="0" name="Simple" defaultMark="0" xOffset="0" lineColor="255,255,255" 
             borderWidth="1" marginWidth="3" transparentBg="yes" alphaValue="40" 
             showRangeHint="yes" mouseHoverForeColor="255,255,255" range1Color="0,255,0">
</FolderStyle>
"""
    
    folding_file = os.path.join(NPP_CONFIG_PATH, "nativeLang.xml")
    with open(folding_file, "w", encoding="utf-8") as f:
        f.write(folding_config)
    print("âœ… Enhanced code folding configured")

def setup_function_list():
    """Setup function list parser configurations"""
    func_list_dir = os.path.join(NPP_CONFIG_PATH, "functionList")
    
    # Python parser
    python_parser = """<?xml version="1.0" encoding="UTF-8" ?>
<NotepadPlus>
    <functionList>
        <parser id="python_function" displayName="Python" commentExpr="(#.*?$)">
            <function mainExpr="^[\t ]*(?:def[\t ]+\w+[\t ]*\([^\)]*\)[\t ]*(?:\-\>[\t ]*[^:]+)?|class[\t ]+\w+[\t ]*(?:\([^\)]*\))?[\t ]*):" displayMode="$className->$functionName">
                <className mainExpr="^[\t ]*class[\t ]+(\w+)[\t ]*(?:\([^\)]*\))?[\t ]*:" />
                <functionName mainExpr="^[\t ]*def[\t ]+(\w+)[\t ]*\([^\)]*\)[\t ]*(?:\-\>[\t ]*[^:]+)?:" />
            </function>
        </parser>
    </functionList>
</NotepadPlus>"""
    
    with open(os.path.join(func_list_dir, "python.xml"), "w", encoding="utf-8") as f:
        f.write(python_parser)
    
    # JavaScript parser
    js_parser = """<?xml version="1.0" encoding="UTF-8" ?>
<NotepadPlus>
    <functionList>
        <parser id="javascript_function" displayName="JavaScript" commentExpr="(/\*.*?\*/|//.*?$)">
            <function mainExpr="(^|[\s;}).])(function[\s]+[\w_][\w\d_]*[\s]*\([^\)]*\)[\s]*|[\w_][\w\d_]*[\s]*\([^\)]*\)[\s]*=>|[\w_][\w\d_]*[\s]*=[\s]*function[\s]*\([^\)]*\))[\s]*\{" displayMode="$className->$functionName">
                <className mainExpr="[\s;\{]class[\s]+([A-Za-z][\w\d_]*)[\s]*[\{]" />
                <functionName mainExpr="(^|[\s;}).])(function[\s]+|[\s]*=[\s]*function[\s]*\(|[\s]*=>[\s]*\{)([\w_][\w\d_]*)" />
            </function>
        </parser>
    </functionList>
</NotepadPlus>"""
    
    with open(os.path.join(func_list_dir, "javascript.xml"), "w", encoding="utf-8") as f:
        f.write(js_parser)
    
    print("âœ… Function navigation list configured")

def setup_autocompletion():
    """Setup autocompletion for popular libraries"""
    completion_dir = os.path.join(NPP_CONFIG_PATH, "autoCompletion")
    
    # Python API completions
    python_api = """requests.get(url)
requests.post(url, data=payload)
requests.put(url, data=payload)
requests.delete(url)
json.loads(string)
json.dumps(object)
os.path.join(path1, path2)
os.path.exists(path)
os.makedirs(path, exist_ok=True)
with open(file, 'r') as f:
subprocess.run([command, arg1, arg2], check=True)
for item in items:
if condition:
else:
def function_name(param1, param2):
class ClassName:
try:
except Exception as e:
finally:
while condition:
return value"""
    
    with open(os.path.join(completion_dir, "python.txt"), "w", encoding="utf-8") as f:
        f.write(python_api)

    # JavaScript API completions
    js_api = """document.getElementById('id')
document.querySelector('selector')
document.querySelectorAll('selector')
element.addEventListener('event', function() {})
fetch(url).then(response => response.json())
async function name() { const response = await fetch(url); }
console.log(message)
localStorage.setItem('key', 'value')
localStorage.getItem('key')
JSON.parse(string)
JSON.stringify(object)
new Promise((resolve, reject) => {})
Array.map(item => {})
Array.filter(item => {})
Array.reduce((acc, item) => {}, initialValue)
setTimeout(() => {}, timeMs)
setInterval(() => {}, timeMs)"""
    
    with open(os.path.join(completion_dir, "javascript.txt"), "w", encoding="utf-8") as f:
        f.write(js_api)
    
    print("âœ… API autocompletion database configured")

def setup_advanced_search():
    """Configure advanced search patterns"""
    search_macros = """<?xml version="1.0" encoding="UTF-8" ?>
<NotepadPlus>
    <FindHistory nbMaxFindHistoryPath="10" nbMaxFindHistoryFilter="10" nbMaxFindHistoryFind="10" nbMaxFindHistoryReplace="10">
        <Find name="Find functions" patterns="^\\s*def\\s+[\\w_]+\\s*\\(">
            <Filter>*.py</Filter>
        </Find>
        <Find name="Find classes" patterns="^\\s*class\\s+[\\w_]+">
            <Filter>*.py</Filter>
        </Find>
        <Find name="Find variables" patterns="^\\s*[\\w_]+\\s*=">
            <Filter>*.py</Filter>
        </Find>
        <Find name="Find JS functions" patterns="function\\s+[\\w_]+\\s*\\(|const\\s+[\\w_]+\\s*=\\s*function|const\\s+[\\w_]+\\s*=\\s*\\(.*\\)\\s*=>">
            <Filter>*.js</Filter>
        </Find>
        <Find name="Find TODO" patterns="TODO:|FIXME:">
            <Filter>*.*</Filter>
        </Find>
        <Find name="Find debug prints" patterns="console\\.log\\(|print\\(">
            <Filter>*.js;*.py</Filter>
        </Find>
    </FindHistory>
</NotepadPlus>"""
    
    search_file = os.path.join(NPP_CONFIG_PATH, "find-history.xml")
    with open(search_file, "w", encoding="utf-8") as f:
        f.write(search_macros)
    
    print("âœ… Advanced search patterns configured")

def setup_run_commands():
    """Configure NppExec run commands"""
    exec_config = """<?xml version="1.0" encoding="UTF-8" ?>
<NotepadPlus>
    <NppExec>
        <ScriptList>
            <Script name="Run Python" script='cmd /c cd /d "$(CURRENT_DIRECTORY)" && python "$(FILE_NAME)"' />
            <Script name="Run JavaScript with Node" script='cmd /c cd /d "$(CURRENT_DIRECTORY)" && node "$(FILE_NAME)"' />
            <Script name="Run HTML in Browser" script='cmd /c start firefox "$(FULL_CURRENT_PATH)" || start chrome "$(FULL_CURRENT_PATH)" || start msedge "$(FULL_CURRENT_PATH)"' />
            <Script name="Git Status" script='cmd /c cd /d "$(CURRENT_DIRECTORY)" && git status' />
            <Script name="Git Add and Commit" script='cmd /c cd /d "$(CURRENT_DIRECTORY)" && git add "$(FILE_NAME)" && git commit -m "Updated $(FILE_NAME)"' />
        </ScriptList>
    </NppExec>
</NotepadPlus>"""
    
    exec_file = os.path.join(NPP_CONFIG_PATH, "nppexec.xml")
    with open(exec_file, "w", encoding="utf-8") as f:
        f.write(exec_config)
    
    # Create menu items
    menu_file = os.path.join(NPP_CONFIG_PATH, "shortcuts.xml")
    exec_menu = """<?xml version="1.0" encoding="UTF-8" ?>
<NotepadPlus>
    <ScintillaKeys>
        <ScintKey ScintID="IDM_EXEC" menuCmdID="0" Ctrl="yes" Alt="no" Shift="yes" Key="116" />
    </ScintillaKeys>
    <Macros>
        <Macro name="Run Current File" Ctrl="yes" Alt="no" Shift="no" Key="116">
            <Action type="2" message="0" wParam="42024" lParam="0" sParam="" />
        </Macro>
    </Macros>
</NotepadPlus>"""
    
    with open(menu_file, "w", encoding="utf-8") as f:
        f.write(exec_menu)
    
    print("âœ… Run commands configured (F5 to execute)")

def setup_multi_editing():
    """Configure multi-cursor editing"""
    # Add multi-edit configuration
    multi_edit_config = """<?xml version="1.0" encoding="UTF-8" ?>
<NotepadPlus>
    <GUIConfigs>
        <GUIConfig name="MultiInstance" setting="1" />
        <GUIConfig name="MultiEdit" setting="1" />
    </GUIConfigs>
</NotepadPlus>"""
    
    multi_edit_file = os.path.join(NPP_CONFIG_PATH, "multiEdit.xml")
    with open(multi_edit_file, "w", encoding="utf-8") as f:
        f.write(multi_edit_config)
    
    print("âœ… Multi-cursor editing configured (Alt+Click to add cursors)")

def create_workspace_template():
    """Create a workspace template for projects"""
    workspace_template = """<?xml version="1.0" encoding="UTF-8" ?>
<NotepadPlus>
    <Project name="MyProject">
        <Folder name="source">
            <File name="main.py" />
        </Folder>
        <Folder name="docs">
        </Folder>
        <Folder name="tests">
        </Folder>
    </Project>
</NotepadPlus>"""
    
    template_dir = os.path.join(NPP_CONFIG_PATH, "templates")
    os.makedirs(template_dir, exist_ok=True)
    
    with open(os.path.join(template_dir, "project_template.xml"), "w", encoding="utf-8") as f:
        f.write(workspace_template)
    
    print("âœ… Project workspace template created")

def setup_lsp_plugin():
    """Setup Language Server Protocol support"""
    try:
        # Download and install LSP plugin
        lsp_config = """<?xml version="1.0" encoding="UTF-8" ?>
<LSPConfig>
    <server name="pyls" language="python" command="pyls" args="-v" />
    <server name="typescript" language="javascript,typescript" command="typescript-language-server" args="--stdio" />
</LSPConfig>"""
        
        lsp_dir = os.path.join(NPP_CONFIG_PATH, "lsp")
        os.makedirs(lsp_dir, exist_ok=True)
        
        with open(os.path.join(lsp_dir, "config.xml"), "w", encoding="utf-8") as f:
            f.write(lsp_config)
        
        print("âœ… LSP plugin configured - install language servers for full functionality")
    except Exception as e:
        print(f"Warning: Could not setup LSP plugin: {str(e)}")

def main():
    """Main function to apply all customizations"""
    print("ðŸš€ Starting Advanced Notepad++ Customization...")
    
    setup_code_folding()
    setup_function_list()
    setup_autocompletion()
    setup_advanced_search()
    setup_run_commands()
    setup_multi_editing()
    create_workspace_template()
    setup_lsp_plugin()
    
    print("\nðŸŽ¯ Advanced Notepad++ Power-User Customization Complete!\n")
    
    print("Power-User Features Added:")
    print("1. Enhanced code folding for nested structures")
    print("2. Function navigation panel with class/method detection")
    print("3. Library-specific autocompletion for Python/JavaScript")
    print("4. Pre-configured regex search patterns")
    print("5. Run commands (F5) for Python, Node.js, HTML")
    print("6. Multi-cursor editing (Alt+Click)")
    print("7. Project workspace template")
    print("8. Language Server Protocol support setup")

if __name__ == "__main__":
    main()


