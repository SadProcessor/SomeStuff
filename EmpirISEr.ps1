#######################################################
#region EmpirISEr #####################################

<#
.Synopsis
    ISE ScriptPane To PowerShell Empire Module
.DESCRIPTION
    ISE ScriptPane Content to PowerShell Empire modules
    Outputs Function-Name.ps1 + Name.py + ReadMe.txt
    (will create output folder on desktop)
.EXAMPLE
    Invoke-EmpirISEr
    Run with all default settings (will choose top function (if any))
.EXAMPLE
    Invoke-EmpirISEr -Function Invoke-Something
    Choose specific function
.EXAMPLE
    Invoke-EmpirISEr -Function Invoke-Something -Category 'Code_Execution' 
    Choose specific Empire Folder/Category - Defaults to 'Fun'
.EXAMPLE
    Invoke-EmpirISEr -Function Invoke-Something -Massage '| Out-String'
    Add Post Exec Data Format Massage
.EXAMPLE
    EmpirISEr -Category 'Code_Execution' -Authors '@SadProcessor','@notherGuy' -links 'https://twitter.com/SadProcessor'
    All other switches for Module Metadata
.INPUTS
    ISE ScriptPane
.OUTPUTS
    PowerShell Script (Redux)
    Python Module data
    ReadMe
.NOTES
    Requires PoSh v3+ (Abstract Syntax Tree)
    Requires Invoke-SyntaxISEr & Invoke-CyberISEr
.ROLE
    ISE Utility
.FUNCTIONALITY
    ISE ScriptPane Content to PoSh Empire Module
#>
function Invoke-EmpirISEr(){
    [CmdletBinding(DefaultParameterSetname='Default')]
    [Alias('EmpirISEr')]
    Param(
        # Module category (Empire destination Folder - Default: Fun)
        [Parameter(Mandatory=$false)]
        [ValidateSet('Test','Code_Execution','Collection','Collection/Vaults','Credentials','Exfil','Exploitation','Fun','Lateral_Movement','Management','Persistence','PrivEsc','Recon','Situational_Awareness/Host','Situational_Awareness/Network','TrollSploit')]
        [string]$Category = 'Fun',

        # List of one or more authors for the module (Tip: Hardcode your name as default)
        [Parameter(Mandatory=$false)]
        [string[]]$Authors = '@Author',
        
        # Verbose multi-line description of the module (max 111char/line)
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,111)]
        [string[]]$Descriptions = 'No Description',
                
        # True if the module needs to run in the background (default: True)
        [Parameter(Mandatory=$false)]
        [ValidateSet('True','False')]
        [string]$Background = 'True',
        
        # File extension to save the file as (default 'None')
        [Parameter(Mandatory=$false)]
        [string]$OutputExtension = 'None',
        
        # True if the module needs admin rights to run (default: False)
        [Parameter(Mandatory=$false)]
        [ValidateSet('True','False')]
        [string]$NeedsAdmin = 'False',
        
        # True if the method doesn t touch disk/is reasonably opsec safe (default: False)
        [Parameter(Mandatory=$false)]
        [ValidateSet('True','False')]
        [string]$OpsecSafe = 'False',
        
        # Minimum PowerShell version needed for the module to run (default: 2)
        [Parameter(Mandatory=$false)]
        [ValidateSet('2','3','4','5')]
        [string]$MinPSVersion = '2',
        
        # List of references and other comments (max 111char/line)
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,111)]
        [string[]]$Comments = 'No Comments',
        
        # Link to full code (with comments)
        [Parameter(Mandatory=$false)]
        [string[]]$Links = 'http://No/Link',

        # Function to use for module (defaults to top one)
        [Parameter(Mandatory=$false)]
        [string]$Function,

        # Post exec output massage (ex: '| Out-String')
        [Parameter(Mandatory=$false)]
        [ValidatePattern("^\s?\|\s?\w+")]
        [string]$Massage
        )

    ##PrepStuff
    # Set Default
    $Name = 'Invoke-Test'
    $ParamBlock = @()
    
    # If Script has function and none specified, take top Function
    $FunctionTree = (SyntaxISEr -TreeType FunctionDefinitionAst)
    if($FunctionTree){$FunctionTree = $FunctionTree[0]}

    # If -function Specified, select matching tree
    If($Function){$FunctionTree = (SyntaxISEr -TreeType FunctionDefinitionAst) | ? {$_.Name -eq $($Function.trim())}}
    # If no tree found
    If(!$FunctionTree){write-host "No Function Found - Using $Name" -ForegroundColor DarkYellow}
    # If tree found
    If($FunctionTree){
        $Name = $FunctionTree.Name
        # Get Param Tree
        $ParamTree = $functionTree.Body.ParamBlock
        If($ParamTree){
            #Prepare ParamCollection Object
            $ParamCollection = @()
            0..(($ParamTree).Parameters.count -1) | Foreach{
                # Get ParamBlock AST
                $AST = ($ParamTree).Parameters[$_]
                # Set Editor
                $Editor=$PsISE.CurrentFile.Editor
                $Editor.SetCaretPosition($AST.Extent.StartLineNumber - 1,1)
                # Get Prop Value
                $PName = $AST.Name.VariablePath.UserPath
                $PDescription = ''
                if($Editor.CaretLineText.Trim()[0] -eq '#'){$PDescription = ($Editor.CaretLineText).replace('#','').trim()}
                $PRequired = (($AST.attributes | where {$_.TypeName -match '^Parameter$'}).NamedArguments | ? {$_.ArgumentName -like 'Mandatory'}).expressionOmitted
                if(!$PRequired){$PRequired = 'False'}
                $PValue = $AST.Defaultvalue.Value
                # Return to top
                $Editor.SetCaretPosition(1,1)
                # Create Props
                $Props = @{
                    'Name' = "$PName"
                    'Description' = "$PDescription"
                    'Required' = "$PRequired"
                    'Value' = "$PValue"
                    }
                # Create Object
                $Obj = New-Object PSCustomObject -Property $Props
                # Add to Collection
                $ParamCollection += $Obj
                }

            #For each thing
            Foreach($Thing in $ParamCollection){
                # Create Param Snippet
                $Snippet = @("
            '$($Thing.Name)' : {
                'Description'   :   '$($thing.Description)',
                'Required'      :   $($thing.Required),
                'Value'         :   '$($thing.Value)'
            },
")
                $ParamBlock += $Snippet
                }
            }
        }
    
    #ParamBlock > remove last coma
    If($ParamBlock){$ParamBlock[$ParamBlock.Count -1] = $ParamBlock[$ParamBlock.Count -1].TrimEnd().TrimEnd(',')}
    # Category to lower
    $Category = $Category.ToLower()
    
    # Massage string format
    If($Massage){$MassageString = @("        script += `" $Massage`"")}   

    # Install Path
    $InstallPath = "/data/module_source/$Category/$Name.ps1"  
    
    ## Generate Python TextBlocks
    # Header
    $Head = @("from lib.common import helpers

class Module:

    def __init__(self, mainMenu, params=[]):")

    #Metadata
    $Meta = @("

        self.info = {

            'Name': '$Name',

            'Author': ['$($Authors -join `"','`")'],

            'Description': ('$($Descriptions -join `"','`")'),

            'Background' : $Background,

            'OutputExtension' : $OutputExtension,

            'NeedsAdmin' : $NeedsAdmin,

            'OpsecSafe' : $OpsecSafe,

            'MinPSVersion' : '$MinPSVersion',

            'Comments': [
                '$($Comments -join "',`r`n`t`t'")',
                '$($Links -join "',`r`n`t`t'")'
            ]
        }")

    #Options
    $Opt = @("
        # any options needed by the module, settable during runtime
        self.options = {
            # format:
            #   value_name : {description, required, default_value}
            'Agent' : {
                # The 'Agent' option is the only one that MUST be in a module
                'Description'   :   'Agent to run Module from',
                'Required'      :   True,
                'Value'         :   ''
            },
$ParamBlock
        }

        # save off a copy of the mainMenu object to access external functionality
        #   like listeners/agent handlers/etc.
        self.mainMenu = mainMenu

        # During instantiation, any settable option parameters
        #   are passed as an object set to the module and the
        #   options dictionary is automatically set. This is mostly
        #   in case options are passed on the command line
        if params:
            for param in params:
                # parameter format is [Name, Value]
                option, value = param
                if option in self.options:
                    self.options[option]['Value'] = value
")

    #Def
    $Def = @("
    def generate(self):

        # read in the common module source code
        moduleSource = self.mainMenu.installPath + `"$InstallPath`"

        try:
            f = open(moduleSource, 'r')
        except:
            print helpers.color(`"[!] Could not read module source path at: `" + str(moduleSource))
            return `"`"

        moduleCode = f.read()
        f.close()

        script = moduleCode

        script += `"$name `"

        for option,values in self.options.iteritems():
            if option.lower() != `"agent`":
                if values['Value'] and values['Value'] != '':
                    if values['Value'].lower() == `"true`":
                        # if we're just adding a switch
                        script += `" -`" + str(option)
                    else:
                        script += `" -`" + str(option) + `" `" + str(values['Value'])

$MassageString

        return script")

    # Make Final Block
    $Python = $Head+$Meta+$Opt+$Def

    ##Generate ReadMe.txt
    # Set Vars
    $PythonFile = ($Name.split("-")[1]).toLower() + '.py'
    $ModuleFolder = "/lib/Modules/$Category"

    # Generate ReadMe content
    $ReadMe = @("## Empire ##
## Module: $Name

## Copy files to the matching path in your Empire folder
#
# Install Path:
# -------------
# -PoSh: [EmpireFolder]$InstallPath
# -Pyth: [Empirefolder]$ModuleFolder/$PythonFile 
#
## Re-run Empire Setup
# Test
# Tweak Python Manually 
# (check Defaults/Massage ...)



# Module Generated by PowerShell for PowerShell #
")
    
    # Get ScriptPane Content
    $Editor = $psISE.CurrentFile.Editor
    $OldContent = $Editor.text
    
    # TrimEnd of lines + Strip Comments + Remove EmptyLines
    $Null = Invoke-CyberISEr -ChopTail
    $Null = Invoke-CyberISEr -StripComment
    $Null = Invoke-CyberISEr -CropEmpty


    #Prep Folder
    $Path = "C:\Users\$env:USERNAME\Desktop\Empire_$Name"
    # Create folder
    $Null = New-Item -ItemType Directory -Path $Path -Force
    
    # Save PowerShell Script
    $NewContent = $Editor.Text
    If(!$FunctionTree){$NewContent = "Function $Name {`r`n`t$($Editor.Text)`r`n`t}"}
    $Null = New-Item -ItemType File -Path $Path -Name "$Name.ps1" -Value "$NewContent" -Force

    # Revert to original content
    $Editor.Text = $OldContent

    # Save Phyton Module Data
    $Null = New-Item -ItemType File -Path $Path -Name "$PythonFile.txt" -Value "$Python" -Force
    # Save readMe
    $Null = New-Item -ItemType File -Path $Path -Name "ReadMe.txt" -Value "$ReadMe" -Force

    # Open Folder
    explorer $Path

}#End Function


#endregion EmpirISEr
#######################################################