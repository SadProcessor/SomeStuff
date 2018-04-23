<#
.Synopsis
   Write Empire Module
.DESCRIPTION
   Auto Generate Empire Module files from PowerShell Script/Functions.
   Parses input Code using AST (Posh 3+).
   Extracts function/Parameters/Attributes needed to generate module file.
   Generates folder on desktop containing
   - ClonedPowerShell.ps1
   - MatchingPython.py.txt
   - ReadMe.txt
   Works against scriptpane (ISE & VSCode) or specified file.
   Must specify -SourceFile when console host.
   Uses AST iso Regex. Should work against various writing styles.
   Works with Empire 2.1
   
   If no -SourceFile specified, uses current scriptPane (ISE|VSCode).
   If no -Function specified, uses last non-nested one (bottom).
   If no functions in script, creates Invoke-CustomScript (and no parameters).
   
   Use -Function to run against specific function from script
   Add -Only to only extract specified as code .ps1 (vs. full source)

   Following metadata defaults are used if nothing specified:
   
     Field               Default
     -----               -------
     Category            Custom
     Author              Unknown
     Description         No Description
     Background          true
     OutputExtention     None
     NeedsAdmin          false
     OpsecSafe           false
     MinPSVersion        2
     Comments            No Comments

   All parameters are optional (metadata uses default unless specified)
   
   
   # Notes: 
   SourceFile accepts single pipeline Input 
   (use '$List|%{WEM $_}' for multiple)
   
   # Python Option Parameters: 
   Description -> Only found if in #Comment above each parameter (not in help)
   Required    -> Incorrect true/false if multiple ParameterSets in function

   # Tips: 
   Set own name as default author iso unknown (line 113)
   Create/use 'custom' folders in Empire for DIY stuff
   Module.py  -> empire/lib/module/powershell/custom/
   Code.ps1   -> empire/data/module_source/custom/
.EXAMPLE
   WEM
   Uses current scriptpane (ISE|VSCode). 
   Throws error in console (specify source)
   Uses last non-nested function when several (bottom main)
.EXAMPLE
   WEM -SourceFile $FilePath
   Uses specified source
   Uses last non-nested function
   Works in ISE|VSCode & Console
.EXAMPLE
   WEM -Function Do-Thing
   Uses specified function and associated parameters
.EXAMPLE
   WEM -Function Do-Thing -Only
   Uses specified function and associated parameters
   Extracts only this code as .ps1 file for module source
.EXAMPLE
   WEM -Category Recon -Author SadProcessor -OpsecSafe True
   Uses specifed params for module metadata iso defaults

   Following module metadata can be set

   Category | Author |Description | Background | OutputExtention
   NeedsAdmin | OpsecSafe | MinPSVersion | Comments

   All have default values if not specified
.EXAMPLE
   WEM -Massage '| ConvertTo-Json'
   Appends massage string to module
.INPUTS
   Scriptpane (ISE|VSCode) content or Sourcefile
   Must specify -SourceFile when working in console host
.OUTPUTS
   Python module file -> ModuleFile.py.txt
   Posh source code   -> SourceCode.ps1
   Text Read-Me       -> ReadMe.txt
.NOTES
   Empire is an Open-Source Post-Exploitation Framework
   designed by @harmj0y & Crew
   
   More Info:
   https://github.com/EmpireProject/Empire/wiki/ 
.LINK
   https://github.com/EmpireProject/Empire/wiki/Module-Development
#>
function Write-EmpireModule{
    [CmdletBinding(DefaultParametersetname='Scriptpane')]
    [Alias('WEM','Modulizer')]
    Param(
        # Specify Function to use
        [Parameter(Mandatory=$true,ParameterSetName='Function')][String]$Function,
        # Specified function text only
        [Parameter(ParameterSetName='Function')][Switch]$Only,
        # Specify Category (folder)
        [ValidateSet('Code_Execution','Collection','Collection/Vaults','Credentials','Exfil','Exploitation',
                     'Lateral_Movement','Management','Persistence','PrivEsc','Recon','Situational_Awareness/Host',
                     'Situational_Awareness/Network','TrollSploit','Custom')]
        [Parameter()][String]$Category='Custom',
        # Specify Module Author(s)
        [Parameter()][String[]]$Author='Unknown',
        # Specify Module Description
        [Parameter()][String[]]$Description='No Module Description',
        # Specify if runs in background
        [ValidateSet('True','False')]
        [Parameter()][String]$Background='True',
        # Specify output extension
        [Parameter()][String]$OutExt='None',
        # Specify if requires Admin
        [ValidateSet('True','False')]
        [Parameter()][String]$NeedsAdmin='False',
        # Specify if Opsec Safe
        [ValidateSet('True','False')]
        [Parameter()][String]$OpsecSafe='False',
        # Specify minimum PowerShell version
        [ValidateSet('2','3','4','5')]
        [Parameter()][String]$MinPSVersion='2',
        # Specify Comments
        [Parameter()][String[]]$Comments='No Comments',
        # Specify extra massage Command
        [ValidatePattern("^\s?\|\s?\w+")]
        [Parameter()][String]$Massage,
        # Specify source file
        [Parameter(Position=0,ValueFromPipeline=$true)][Alias('Path')][String]$SourceFile
        )
    Begin{
        Write-Verbose "Host is $($Host.Name)..."
        }
    Process{
        $input = $Null
        # If No source file specified
        if(!$SourceFile){
            Write-Verbose "No Source File Specified..."
            switch($host.Name){
                # if Console -> Break
                'ConsoleHost'{Write-Warning 'Must specify Source File...'; Break}
                # if ISE -> use psISE obj
                'Windows PowerShell ISE Host'{$Input = $psISE.CurrentFile.Editor.Text}
                # if VSCode -> use psEditor obj
                'Visual Studio Code Host'{$Input = $psEditor.GetEditorContext().CurrentFile.AST.Extent.Text}
                }
            Write-Verbose "Reading from current script pane..."
            }
        # Else, get file content (if exist)
        Else{
            if(Test-Path $SourceFile){$Input = Get-Content $SourceFile -Raw}
            else{Write-Warning 'File not found...';Break}
            }

        # Parse Input (AST)
        Write-Verbose "Parsing input..."
        if($Input){$Tok=$Err=$Null; $AST = [System.Management.Automation.Language.Parser]::ParseInput($Input,[ref]$Tok,[ref]$Err)}
        Else{Write-Warning 'Empty Script Content...'; Break}
        # If empty AST -> Break
        if($AST.Extent.text -eq ''){Write-Warning 'Empty Script Content...'; Break}
        # If error in input > Break
        if($Err -ne $Null){Write-Warning 'Invalid Source code...';Break}

        # Select $posh (for later)
        $Posh = $Input
        # Get all functions from AST
        $AllFunctAST = $AST.FindAll({$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]},$true)
        # if function specified
        if($Function){
            Write-Verbose "Searching function '$Function'..."        
            # Select in All Function
            $FunctAST = $AllFunctAST | ? Name -eq $Function
            # if not found
            if(!$FunctAST){Write-Warning 'Function not found...';Break}
            }
        # if no function specifed -> use last non-nested one
        if(!$Function){
            Write-Verbose "No specified function..."
            Write-Verbose "Searching function..."
            # find all non-nested function and select last one
            $FunctAST = $AllFunctAST | ? {$_.Parent.Parent.Parent -eq $Null} | select -last 1
            # if no function exist -> use Invoke-Script
            if(!$FunctAST){
                $Name = 'Invoke-CustomScript'
                Write-Verbose "No functions found "
                Write-Warning "Using '$Name' & No Params..."
                }
            }

        # If no function exist
        if(!$FunctAST){
            # format script
            $Posh = @("function $Name{`r`n$($Input.trim())`r`n}")
            $ParamSnippet = $Null
            }
        # Else
        if($FunctAST){
            # Get function name
            $Name = $FunctAST.name
            write-Verbose "Found Function '$Name'..."
            #Look for function Params (ParamblockAST)
            $ParamBlockAST = $FunctAST.findall({$args[0] -is [System.Management.Automation.Language.ParamBlockAst]},$true) | Where {$_.Parent.Parent.name -eq $Name}
            # if found get param tree
            if($ParamBlockAST){
                Write-Verbose "Found Parameters..."
                $ParamSnippet = @("")
                $ParamAST = $ParamBlockAST.findAll({$args[0] -is [System.Management.Automation.Language.ParameterAst]},$true)
                $ParamCollection=@{}
                # Generate Param Snippet
                foreach($Param in $ParamAST){
                    # Prep vars
                    # Name
                    $PName = $Param.Name.VariablePath.UserPath
                    # Description
                    $ParamLine = $Param.extent.StartLineNumber
                    $CommentTok = $Tok | ? Kind -eq Comment | ?{$_.Extent.StartlineNumber -eq ($ParamLine -1)}
                    $PDescription = ($CommentTok.text -replace "^#",'').Trim()
                    if($PDescription -eq ''){$PDescription = 'No description for this parameter'}
                    # Required
                    $PRequired = 'False'
                    if(($Param.Attributes.NamedArguments | ? ArgumentName -eq 'Mandatory').Argument.VariablePath.UserPath -eq 'true'){$PRequired='True'}
                    # Value
                    $PValue = $Param.DefaultValue.Value
                    # If Mandatory false and value is set
                    # Mandatory is True (for empire)
                    if($PRequired -eq 'False' -and $PValue.count){$PRequired='True'}
                    # Append to snippet  
                    $ParamSnippet += @("          '$PName' : {
                'Description'   :   '$PDescription',
                'Required'      :   $PRequired,
                'Value'         :   '$PValue'
            },
 ")
                    }
                $ParamSnippet[$ParamSnippet.count -1] = $ParamSnippet[$ParamSnippet.count -1].ToString().TrimEnd().TrimEnd(",") + "`r`n"
                }
            # else (if no params in function)
            Else{$ParamSnippet = $Null; Write-Warning "No Parameters found in function..."}
            }
        
        ## Prepare text Blocks
        Write-verbose "Generating Python Module..."
        # prep vars
        $Category = $Category.ToLower()
        If($Massage){$MassageString = @("`r`n`tscriptEnd += `"$Massage`"`r`n")}
        # Top
        $HeadSnippet = @("import base64
from lib.common import helpers

class Module:

    def __init__(self, mainMenu, params=[]):

        self.info = {
            'Name': '$Name',

            'Author': ['$($Author -join `"','`")'],

            'Description': ('$($Description -join `"',`r`n`t`t`t`t`t`t`t'`")'),

            'Background' : $Background,

            'OutputExtension' : $OutExt,

            'NeedsAdmin' : $NeedsAdmin,

            'OpsecSafe' : $OpsecSafe,

            'Language' : 'powershell',

            'MinLanguageVersion' : '$MinPSVersion',

            'Comments': [
                '$($Comments -join `"',`r`n`t`t'`")'
            ]
        }
")
        # Option
        $OptionSnippet = @("       # any options needed by the module, settable during runtime
        self.options = {
            # format:
            #   value_name : {description, required, default_value}
            'Agent' : {
                'Description'   :   'Agent to run module on.',
                'Required'      :   True,
                'Value'         :   ''
            },
")
        # Bottom
        $FootSnippet = @("       }

        # save off a copy of the mainMenu object to access external functionality
        #   like listeners/agent handlers/etc.
        self.mainMenu = mainMenu

        for param in params:
            # parameter format is [Name, Value]
            option, value = param
            if option in self.options:
                self.options[option]['Value'] = value

    def generate(self, obfuscate=False, obfuscationCommand=`"`"):

        # read in the common module source code
        moduleSource = self.mainMenu.installPath + `"/data/module_source/$Category/$Name.ps1`"
        if obfuscate:
            helpers.obfuscate_module(moduleSource=moduleSource, obfuscationCommand=obfuscationCommand)
            moduleSource = moduleSource.replace(`"module_source`", `"obfuscated_module_source`")
        try:
            f = open(moduleSource, 'r')
        except:
            print helpers.color(`"[!] Could not read module source path at: `" + str(moduleSource))
            return `"`"

        moduleCode = f.read()
        f.close()

        script = moduleCode

        scriptEnd = `"\n$Name`"

        # showAll = self.options['ShowAll']['Value'].lower()

        for option,values in self.options.iteritems():
            if option.lower() != `"agent`" and option.lower() != `"showall`":
                if values['Value'] and values['Value'] != '':
                    if values['Value'].lower() == `"true`":
                        # if we're just adding a switch
                        scriptEnd += `" -`" + str(option)
                    else:
                        scriptEnd += `" -`" + str(option) + `" `" + str(values['Value'])
$MassageString
        if obfuscate:
            scriptEnd = helpers.obfuscate(psScript=scriptEnd, obfuscationCommand=obfuscationCommand)
        script += scriptEnd
        return script
")

        ## Prep output files
        # Prep Python
        $Python = $HeadSnippet+$OptionSnippet+$ParamSnippet+$FootSnippet
        
        # if -only > extract this function only (overwrites previous $PoSh)
        if($Only){
            # Select only function text
            if($FunctAST){$Posh = $FunctAST.Extent.Text}
            }
        Write-verbose "Copying PowerShell Source code..."
        
        # Set some vars
        $InstallPath = "/data/module_source/$Category/$Name.ps1"
        If($Name -match '-'){$PythonFile = ($Name.split("-")[1]).toLower()}
        Else{$PythonFile = $Name.tolower()}
        $ModuleFolder = "/lib/modules/powershell/$Category"
        $Date = (Get-Date).ToShortDateString()
        $Time = (Get-Date).ToShortTimeString()
        # Prep Read-Me
        Write-verbose "Generating Read-Me..."
        $ReadMe = @("
###########################################
# Empire : $Category 
# Module : $Name
# Author : $Author
###########################################
#
# ## Install:
#
# # Copy Files to Empire Folders:
# empire$InstallPath
# empire$ModuleFolder/$PythonFile.py 
#
# # [Re]Start Empire
#
# # Test & Tweak
#
# # Enjoy & Share...
#
###########################################
# Extracted from PoSh Tree - 99% Pure AST 
# $date @ $time 
###########################################
")
        # Check for folder
        $OutFolder = Join-Path (Join-Path $home "desktop") $Name.replace('-','')
        if(!(test-Path $OutFolder)){$Null = mkdir $OutFolder;Write-Verbose "Creating Folder on desktop..."}
        # Output to files (overwrites existing module files)
        $Null = New-Item -Path $OutFolder -Name "$name.ps1" -ItemType File -Value "$posh" -Force
        If($Host.name -eq 'ConsoleHost'){$Python = $Python -replace "`n","`r`n"}
        $Null = New-Item -Path $OutFolder -Name "$PythonFile.py.txt" -ItemType File -Value "$Python" -Force
        $Null = New-Item -Path $OutFolder -Name "ReadMe.txt" -ItemType File -Value "$ReadMe" -Force 
        Write-Verbose "Saved to $OutFolder...`r`nDone!"
        # open folder
        explorer $OutFolder
        # show ReadMe
        $readMe
        }
    End{}
    }
#End