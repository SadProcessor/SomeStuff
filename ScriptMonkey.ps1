#================#
#  ScriptMonkey  # 
##########################################

#region ###################### MONKEY
# If Script Monkey Object doesn't exist 
if(!$Monkey){
    # Init Script Monkey Object
    $Monkey = New-object PSCustomObject -Property @{
        AST            = $Null
        TOk            = $Null
        ERR            = $Null
        ASTList        = $Null
        TOKList        = $Null
        ERRMsg         = $Null
        FunctList      = $Null
        FocusFunction  = $Null
        ParamList      = $Null
        FocusParam     = $Null
        AttribList     = $Null
        }
    }
#endregion

#region ###################### TREE

<#
.Synopsis
   Parse Code
.DESCRIPTION
   Parse Current Scriptpane
.EXAMPLE
   Parse-Code
#>
function Parse-Code{
    [Alias('Parse','p')]
    param(
        # Path for Source Script
        [Parameter(Mandatory=$false)][String]$Path
        )
    # Determine Workspace
    $Space = $host.name
    # Break if Console Host (need ISE|VSCode)
    If($Space -eq 'ConsoleHost'){Write-Warning "Can't Load ScriptMonkey - Use Editor";Break}    
    
    ## ISE
    If($Space -eq 'Windows PowerShell ISE Host'-AND -not $Path){
        $SourceCode = $psISE.Currentfile.Editor.text
        }
    ## VSCode
    ElseIf($Space -eq 'Visual Studio Code Host' -AND -not $Path){
        $SourceCode = $psEditor.GetEditorContext().CurrentFile.AST.Extent.Text
        }
    # Parse Code to AST/TOK/ERR
    $TOK=$ERR=$null
    $AST = [System.Management.Automation.Language.Parser]::ParseInput($SourceCode,[ref]$TOK,[ref]$ERR)
    # Error warning
    if($ERR.count -gt 0){Write-Warning 'Found Error in Source Code...'}
    # Set Monkey Obj
    $Script:Monkey.AST = $AST
    $Script:Monkey.TOK = $TOK
    $Script:Monkey.ERR = $ERR
    $Script:Monkey.ASTList = $AST.FindAll({$true},$True) | %{$_.gettype().name} | sort -Unique
    $Script:Monkey.TOKList = ($TOK).Kind | Sort -Unique
    Try{$Script:Monkey.ERRMsg  = $Script:Monkey.Error[0].Message}Catch{}
    $Script:Monkey.FunctList = @(($AST.FindAll({$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]},$true)).Name)
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Get-Tree{
    [CmdletBinding()]
    [Alias('Tree')]
    Param(
        # Restrict search to Parent tree
        [Parameter()][System.Management.Automation.Language.Ast]$Parent
        )
    DynamicParam{
        # Prep VSet
        $VSet = @('*')
        $VSet += $Script:Monkey.ASTList
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $true
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)
        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Type', [String], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Type', $DynParam)
        ## Return Dictionary
        return $Dictionary       
        }
    Begin{}
    Process{
        $Dyn = $DynParam.Value
        if($Dyn -eq '*'){$Script:Monkey.ASTList;Break}
        $result = ($Script:Monkey.AST).findAll({$args[0] -is ("System.Management.Automation.Language.$Dyn" -as [Type])},$true)
        if($Parent){$Result = $Result | ?{$_.Extent.StartOffset -gt $Parent.Extent.StartOffset -AND $_.Extent.EndOffset -lt $Parent.Extent.EndOffset}}
        }
    End{Return $Result} 
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Get-Token{
    [CmdletBinding()]
    Param(
        # Restrict search to parent tree
        [Parameter()][System.Management.Automation.Language.AST]$Parent
        )
    DynamicParam{
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $True
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($Script:Monkey.TOKList)
        $Collection.Add($ValidateSet)
        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Kind', [String], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Kind', $DynParam)
        ## Return Dictionary
        return $Dictionary         
        }
    Begin{}
    Process{
        $Result =  $Script:Monkey.TOK | where kind -eq $DynParam.Value
        if($Parent){$Result = $Result | ?{$_.Extent.StartOffset -gt $Parent.Extent.StartOffset -AND $_.Extent.EndOffset -lt $Parent.Extent.EndOffset}}
        }
    End{Return $result}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
Function Get-Error{
    [Alias('Err')]
    Param()
    $er ='-'
    if($Error[0].Errors.Exception -ne $Null){$er = $Error[0].Errors.Exception}
    if($Error[0].Message -ne $Null){$er = $error[0].Message}
    if($Error[0].Exception -ne $Null){$er = $error[0].Exception.Message}
    $L = $Error[0].InvocationInfo.ScriptLineNumber
    $C = $Error[0].InvocationInfo.OffsetInLine
    Write-Host "[$L-$C] $er :(" -ForegroundColor Green
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Get-FunctionTree{
    [CmdletBinding()]
    [Alias('FunctionTree')]
    Param()
    DynamicParam{
        # Prep VSet
        $VSet = @('*')
        #  function names
        $VSet += (Get-Tree -Type FunctionDefinitionAst).name

        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $false
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)
        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [String], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Name', $DynParam)
        ## Return Dictionary
        return $Dictionary       
        }
    Begin{}
    Process{
        $Dyn = $DynParam.Value
        $result = Get-Tree -Type FunctionDefinitionAst
        if($Dyn -eq '*'){$Result = $result.name}
        if($DynParam.IsSet -AND $Dyn -ne '*'){$result = $result | ? {$_.Name -eq $DynParam.Value}}
        }
    End{Return $result}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Get-ParamTree{
    [CmdletBinding()]
    [Alias('ParamTree')]
    Param()
    DynamicParam{
        # Get function names
        $VSet = (Get-Tree -Type ParameterAst -Parent (Get-FunctionTree $Script:Monkey.FocusFunction)).Name.VariablePath.UserPath
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $false
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)
        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [String], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Name', $DynParam)
        ## Return Dictionary
        return $Dictionary       
        }
    Begin{}
    Process{
        $result = Get-Tree -Type ParameterAst -Parent (Get-FunctionTree -Name $Script:Monkey.FocusFunction)
        if($DynParam.IsSet){$result = $result | ? {$_.Name.VariablePath.UserPath -eq $DynParam.Value}}
        Else{$result = $result.name}
        }
    End{Return $result}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
Function Get-Extent{
    [Alias('Extent')]
    Param(
        # Specify target tree
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$True)][System.Management.Automation.Language.AST]$Tree
        )
    # Return Position
    Return $Tree.Extent
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
Function Select-Tree{
    [Alias('TreeSelect','st')]
    Param(
        # Specify target tree
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$True)][System.Management.Automation.Language.AST]$Tree
        )
    # Select Text    
    $Pos = Get-Extent $tree
    #ISE
    if($Host.Name -eq 'Windows PowerShell ISE Host'){        
        $Editor = $psISE.CurrentFile.Editor
        $Editor.select($Pos.StartLineNumber,$Pos.startColumnNumber,$Pos.EndLineNumber,$Pos.EndColumnNumber)
        $psISE.CurrentPowerShellTab.ConsolePane.Focus()
        }
    #VSCode
    ElseIf($Host.Name -eq 'Visual Studio Code Host'){
        $psEditor.GetEditorContext().SetSelection($Pos.StartLineNumber,$Pos.startColumnNumber,$Pos.EndLineNumber,$Pos.EndColumnNumber)
        }
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Get-Selected{
    # ISE
    If($Host.Name -eq 'Windows PowerShell ISE Host'){
        Return $psISE.CurrentFile.Editor.SelectedText
        }
    # VSCode
    ElseIf($Host.Name -eq 'Visual Studio Code Host'){
        # Get Selected range
        $range = $psEditor.GetEditorContext().SelectedRange
        # Return Selected Text
        Return $psEditor.GetEditorContext().CurrentFile.GetText($Range)
        }
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#> 
function Set-Selected{
    [Alias('Insert','i')]
    Param([AllowEmptyString()][Parameter(Mandatory=$true,Position=0)][String]$String)
    # ISE
    If($Host.Name -eq 'Windows PowerShell ISE Host'){
        $psISE.CurrentFile.Editor.InsertText("$String")
        $psISE.CurrentPowerShellTab.ConsolePane.Focus()
        }
    # VSCode
    ElseIf($Host.Name -eq 'Visual Studio Code Host'){
        # Get Range
        $range = $psEditor.GetEditorContext().SelectedRange
        # Insert Text Range
        If($Range -ne $Null){$psEditor.GetEditorContext().CurrentFile.InsertText("$String",$Range)}
        Else{$psEditor.GetEditorContext().CurrentFile.InsertText("$String")}
        }    
    Parse-Code
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Clear-Selected{
    [Alias('Delete')]
    Param()
    Set-Selected ''
    Parse-Code
    } 

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
Function Get-Text{
    Param(
        # Specify target tree
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$True)][System.Management.Automation.Language.AST]$Tree
        )
    # return Tree Text
    Return $tree.Extent.Text
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Get-SubTree{
    [Alias('Sub','gs')]
    Param(
        [ValidateSet(
            'Binding',
            'AliasF',
            'Output',
            'DefaultPSN',
            'ShouldProcess',
            'PosBinding',
            'HelpUri',
            'HelpMess',
            'ConfImpact',
            'NameP',
            'Attrib',
            'AliasP',
            'Type',
            'DefaultVal',
            'Mandatory',
            'Position',
            'ParamSetName',
            'Pipeline',
            'PipelineByProp',
            'RemainingArgs',
            'ValSet',
            'ValLength',
            'ValCount',
            'ValRange',
            'ValPattern',
            'ValScript',
            'ValNotNull',
            'ValNotNullEmpty',
            'AllowNull',
            'AllowEString',
            'AllowECollect')]
        [Parameter(Mandatory=$true)]$Type,
        [Parameter()][String]$PSN
        )
    # Focused FunctionBlock
    $FFTree = Get-FunctionTree $Script:Monkey.FocusFunction
    # focused ParamBlock
    try{$FPTree = Get-ParamTree $Script:Monkey.FocusParam}Catch{}
    # Find sub tree
    Switch($type){
        <# Function #>
        'Binding'          {$SubT = ( Get-Tree ParamBlockAST -Parent $FFtree).Attributes | ? {$_.TypeName.Name -eq 'CmdletBinding'}}
        'AliasF'           {$SubT = ( Get-Tree ParamBlockAST -Parent $FFtree).Attributes | ? {$_.TypeName.Name -eq 'Alias'}}
        'Output'           {$SubT = ( Get-Tree ParamBlockAST -Parent $FFtree).Attributes | ? {$_.TypeName.Name -eq 'OutputType'}}
        'DefaultPSN'       {$SubT = ((Get-Tree ParamBlockAST -Parent $FFtree).Attributes | ? {$_.TypeName.Name -eq 'CmdletBinding'}).NamedArguments | ? {$_.ArgumentName -eq 'DefaultParameterSetName'}}
        'ShouldProcess'    {$SubT = ((Get-Tree ParamBlockAST -Parent $FFtree).Attributes | ? {$_.TypeName.Name -eq 'CmdletBinding'}).NamedArguments | ? {$_.ArgumentName -eq 'SupportsShouldProcess'}}
        'PosBinding'       {$SubT = ((Get-Tree ParamBlockAST -Parent $FFtree).Attributes | ? {$_.TypeName.Name -eq 'CmdletBinding'}).NamedArguments | ? {$_.ArgumentName -eq 'PositionalBinding'}}
        'HelpURI'          {$SubT = ((Get-Tree ParamBlockAST -Parent $FFtree).Attributes | ? {$_.TypeName.Name -eq 'CmdletBinding'}).NamedArguments | ? {$_.ArgumentName -eq 'HelpUri'}}
        'ConfImpact'       {$SubT = ((Get-Tree ParamBlockAST -Parent $FFtree).Attributes | ? {$_.TypeName.Name -eq 'CmdletBinding'}).NamedArguments | ? {$_.ArgumentName -eq 'ConfirmImpact'}}
        <# Param #>
        'NameP'            {$SubT =  $FPTree.Name}
        'Mandatory'        {$SubT = ($FPTree.Attributes  | ? {$_.TypeName.Name -eq 'Parameter'}).NamedArguments | ? {$_.ArgumentName -eq 'Mandatory'}}
        'Position'         {$SubT = ($FPTree.Attributes  | ? {$_.TypeName.Name -eq 'Parameter'}).NamedArguments | ? {$_.ArgumentName -eq 'Position'}}
        'ParamSetname'     {$SubT = ($FPTree.Attributes  | ? {$_.TypeName.Name -eq 'Parameter'}).NamedArguments | ? {$_.ArgumentName -eq 'ParameterSetName'}}
        'Pipeline'         {$SubT = ($FPTree.Attributes  | ? {$_.TypeName.Name -eq 'Parameter'}).NamedArguments | ? {$_.ArgumentName -eq 'ValueFromPipeline'}}
        'PipelineByProp'   {$SubT = ($FPTree.Attributes  | ? {$_.TypeName.Name -eq 'Parameter'}).NamedArguments | ? {$_.ArgumentName -eq 'ValueFromPipelineByPropertyName'}}
        'RemainingArgs'    {$SubT = ($FPTree.Attributes  | ? {$_.TypeName.Name -eq 'Parameter'}).NamedArguments | ? {$_.ArgumentName -eq 'ValueFromRemainingArguments'}}
        'HelpMess'         {$SubT = ($FPTree.Attributes  | ? {$_.TypeName.Name -eq 'Parameter'}).NamedArguments | ? {$_.ArgumentName -eq 'HelpMessage'}}
        'AliasP'           {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'Alias'}}
        'ValSet'           {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'ValidateSet'}}
        'ValLength'        {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'ValidateLength'}}
        'ValRange'         {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'ValidateRange'}}
        'ValPattern'       {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'ValidatePattern'}}
        'ValCount'         {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'ValidateCount'}}
        'ValScript'        {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'ValidateScript'}}
        'ValNotNull'       {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'ValidateNotNull'}}
        'ValNotNullEmpty'  {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'ValidateNotNullOrEmpty'}}
        'AllowNull'        {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'AllowNull'}}
        'AllowEString'     {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'AllowEmptyString'}}
        'AllowECollect'    {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'AllowEmptyCollection'}}
        'Attrib'           {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'Parameter'}
            If($SubT.count -gt 1 -AND !$PSN){$SubT=$Null;Write-Warning "Multiple PSN - please Specify..."}
            If($PSN){$SubT = (($FPTree.Attributes | ? {$_.TypeName.Name -eq 'Parameter'}).NamedArguments | ? {$_.ArgumentName -eq 'ParameterSetName'} | ?{$_.Argument.Value -eq $PSN}).Parent}}
        'Type'             {$FPTree.Attributes  | ? {($_| GM | ? Membertype -eq 'Property').count -eq 3}}
        'DefaultVal'       {$SubT = $FPTree.DefaultValue}       
        }
    return $SubT
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Nice-Up{
    [Alias('NiceUp')]
    Param(
        [Parameter(Mandatory=$true,Position=0,ValuefromPipeline=$true)][String[]]$String
        )
    Begin{$Result = @()}
    Process{foreach($Str in $String){($Str.split('-')|%{($_[0] -as [String]).toupper()+$_.Substring(1)})-join'-'}}
    End{Return $Result}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Write-Block{
    [CmdletBinding(DefaultParameterSetName='NoString')]
    [Alias('wb')]
    Param(
        [Parameter(Mandatory=$true )][String]$Key,
        [Parameter(Mandatory=$False)][String]$Field,
        [Parameter(Mandatory=$False)][String]$Value,
        [Parameter(Mandatory=$False)][Switch]$Clip,
        [Parameter(Mandatory=$true,ParameterSetName='String',ValueFromPipeline=$true,Position=0)][String]$String
        )
    if($PSCmdlet.ParameterSetName -eq 'String'){
        $Block = [String]$String.trimend().TrimEnd(')]')
        if($field){$Block += ",$field="}
        if($Value){$Block += "$Value"}
        $Block = $Block -replace "\[$Key\(,","[$Key("
        }
    Else{
        $Block = "[$Key("
        if($field){$Block += "$field="}
        if($Value){$Block += "$Value"}
        }
    $block += ')]'
    #if clipboard
    if($Clip){$Block | Clip}
    Return $Block
    }

#endregion

#region ###################### CONTROLS

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function New-Script{
    [Alias('New','n')]
    Param()
    If($host.Name -eq 'Windows PowerShell ISE Host'){
        $psise.CurrentPowerShellTab.Files.Add()
        $psISE.CurrentPowerShellTab.ConsolePane.Focus()
        }
    ElseIf($Host.Name -eq 'Visual Studio Code Host'){
        $WS = New-Object -ComObject WScript.Shell
        $WS.SendKeys('^`')
        $WS.SendKeys('^n')
        $WS.SendKeys('^`')
        $WS = $Null
        }
    Try{Parse-Code}Catch{Write-Warning "Empty Scriptpane..."}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
Function Set-Cursor{
    [CmdletBinding()]
    [Alias('Cursor')]
    Param(
        [Parameter(Mandatory=$false,Position=0,ValueFromPipeline=$true)][System.Management.Automation.Language.AST]$Tree=$Script:Monkey.AST,
        [Parameter(Mandatory=$true,ParameterSetName='Top')][Switch]$Top,
        [Parameter(Mandatory=$true,ParameterSetName='Bottom')][Switch]$Bottom
        )
    $T=$tree.Extent
    $LnT=$T.StartLineNumber
    $CnT=$t.StartColumnNumber
    $LnB=$t.EndLineNumber
    $CnB=$t.EndColumnNumber
    If($Host.Name -eq 'Windows PowerShell ISE Host'){
        $Editor = $psISE.CurrentFile.Editor
        try{$Editor.SetCaretPosition($LnB,$cnB)}Catch{}
        if($Top){try{$Editor.SetCaretPosition($LnT,$cnT)}Catch{Write-Warning 'Need to focus...'}}
        $psISE.CurrentPowerShellTab.ConsolePane.Focus()
        }
    ElseIf($Host.Name -eq 'Visual Studio Code Host'){
        Try{$Editor = $psEditor.GetEditorContext()}Catch{}
        Try{GoTo-Line $LnB}Catch{}
        if($Top){GoTo-Line $LnT}
        if($Bottom){try{$Editor.SetSelection($LnB,$cnB,$LnB,$CnB)}Catch{}}
        if($Top){try{$Editor.SetSelection($LnT,$cnT,$LnT,$cnT)}Catch{Write-Warning 'Need to focus...'}}
        }
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function GoTo-Line{ 
    [Alias('GoTo','Line','l')]
    Param(
        [Parameter(Mandatory=$true,Position=1)][int]$Line
        )
    if($Line -gt $Script:Monkey.AST.Extent.EndLineNumber){Write-Warning "Out Of Range";Break}
    if($Host.Name -eq 'Visual Studio Code Host'){
        $WS = New-Object -ComObject WScript.Shell
        $WS.SendKeys('^`')
        $WS.SendKeys("^g")
        foreach($Key in $Line.ToString().Split()){$Ws.SendKeys("$Key")}
        $WS.SendKeys("ENTER")
        $WS.SendKeys('^`')
        $WS = $null
        }
    if($Host.Name -eq 'Windows PowerShell ISE Host'){
        $psISE.CurrentFile.Editor.SetCaretPosition($psISE.CurrentFile.Editor.LineCount,1)
        $psISE.CurrentFile.Editor.SetCaretPosition($Line,1)
        $psISE.CurrentPowerShellTab.ConsolePane.Focus()
        }
    }
    
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function GoTo-Bottom{
    [Alias('b','Bottom')]
    Param()
    Cursor -Bottom
    }
    
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function GoTo-Top{
    [Alias('t','Top')]
    Param()
    Cursor -Top
    } 
    
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
Function Clear-Console{
    [Alias('c','cl')]
    Param()
    Clear
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Undo-Script{
    [Alias('Undo','z','u')]
    Param([ValidateRange(1,10)][Parameter()][int]$time=1)
    $WS = New-Object -ComObject WScript.Shell
    if($Host.Name -eq 'Windows PowerShell ISE Host'){$WS.SendKeys("^i")}
    if($Host.Name -eq 'Visual Studio Code Host'){$WS.SendKeys('^`')}
    0..$time | %{$WS.SendKeys("^z")}
    if($Host.Name -eq 'Windows PowerShell ISE Host'){$Ws.SendKeys("^d")}
    if($Host.Name -eq 'Visual Studio Code Host'){$WS.SendKeys('^`')}
    $WS = $null 
    Parse-code
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Redo-Script{
    [Alias('Redo','zz')]
    Param([ValidateRange(1,10)][Parameter()][int]$time=1)
    $WS = New-Object -ComObject WScript.Shell
    if($Host.Name -eq 'Windows PowerShell ISE Host'){$WS.SendKeys("^i")}
    if($Host.Name -eq 'Visual Studio Code Host'){$WS.SendKeys('^`')}
    0..$time | %{$WS.SendKeys("^y")}
    if($Host.Name -eq 'Windows PowerShell ISE Host'){$Ws.SendKeys("^d")}
    if($Host.Name -eq 'Visual Studio Code Host'){$WS.SendKeys('^`')}
    $WS = $null 
    Parse-code
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Run-Script{
    [Alias('Run','r')]
    Param()
    $WS = New-Object -ComObject WScript.Shell
    $WS.SendKeys("{F5}")
    $WS = $null
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Load-Script{
    [Alias('Load','x')]
    Param()
    Run-Script
    Clear
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Save-Script{
    [Alias('Save','s')]
    Param()
    $WS = New-Object -ComObject WScript.Shell
    if($Host.Name -eq 'Visual Studio Code Host'){$WS.SendKeys('^`')}
    $WS.SendKeys("^s")
    if($Host.Name -eq 'Visual Studio Code Host'){$WS.SendKeys('^`')}
    if($Host.Name -eq 'Windows PowerShell ISE Host'){$Ws.SendKeys("^d")}
    $WS = $null 
    } 

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
Function View-Syntax{
    [CmdletBinding()]
    [Alias('Syntax','vs','v')]
    Param()
    DynamicParam{
        # Validation values
        $Vset = @('*')
        $VSet += $Script:Monkey.FunctList

        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $False
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)

        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)

        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Function', [String[]], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Function', $DynParam)
        
        ## Return Dictionary
        return $Dictionary    
        }
    Begin{
        $Result=@()
        if($DynParam.IsSet){$dyn =$DynParam.Value}
        else{$Dyn = $Script:Monkey.FocusFunction}
        If($DynParam.Value -eq '*'){$Dyn = Focus-Function}
        }
    Process{
        Foreach($DynP in $Dyn){
            $result += (Get-Help $dynP).Syntax
            }
        }
    End{Return $result}
    }

<#
.Synopsis
   View Help
.DESCRIPTION
   Get Help for specified script function
.EXAMPLE
   Example of how to use this cmdlet
#>
Function View-Help{
    [CmdletBinding(DefaultParameterSetname='Short')]
    [Alias('vh')]
    Param(
        [Parameter(Mandatory=$false,ParametersetName='Short')][Switch]$Short,
        [Parameter(Mandatory=$true,ParametersetName='Full')][Switch]$Full,
        [Parameter(Mandatory=$true,ParametersetName='Description')][Switch]$Description,
        [Parameter(Mandatory=$true,ParametersetName='Parameter')][Switch]$Parameter,
        [Parameter(Mandatory=$true,ParametersetName='Examples')][Switch]$Examples,
        [Parameter(Mandatory=$true,ParametersetName='Detailed')][Switch]$Detailed,
        [Parameter(Mandatory=$true,ParametersetName='Online')][Switch]$Online,
        [Parameter(Mandatory=$true,ParametersetName='ShowWindow')][Switch]$ShowWindow,
        [Parameter(Mandatory=$true,ParametersetName='Synopsis')][Switch]$Synopsis,
        [Parameter(Mandatory=$true,ParametersetName='Syntax')][Switch]$Syntax,
        [Parameter(Mandatory=$true,ParametersetName='Details')][Switch]$Details,
        [Parameter(Mandatory=$true,ParametersetName='Alias')][Switch]$Alias,
        [Parameter(Mandatory=$true,ParametersetName='Memo')][Switch]$Memo
        )
    DynamicParam{
        # Validation values
        $VSet = $Script:Monkey.FunctList

        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $False
        $Attrib.Position = 0
        $Attrib.ValueFromPipeline = $true
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)

        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)

        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Function', [String[]], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Function', $DynParam)
        
        ## Return Dictionary
        return $Dictionary    
        }
    Begin{
        if(!$DynParam.IsSet){$DynParam.Value=$Script:Monkey.FocusFunction}
        # Prep empty res
        $result = @()
        }
    Process{
        foreach($Fn in $DynParam.Value){
            Switch($PSCmdlet.ParameterSetName){
                'Short'       {Get-Help $Fn}
                'Full'        {Get-Help $Fn -full}
                'Description'{(Get-Help $Fn).description}
                'Parameter'   {Get-Help $Fn -Parameter}
                'Examples'    {Get-Help $Fn -Examples}
                'Detailed'    {Get-Help $Fn -Detailed}
                'Online'      {Get-Help $Fn -Online}
                'ShowWindow'  {Get-Help $Fn -ShowWindow}
                'Synopsis'   {(Get-Help $Fn).Synopsis}
                'Syntax'     {(Get-Help $Fn).Syntax}
                'Details'    {(Get-Help $Fn).Details}
                'Alias'      {(Get-Alias -Definition $Fn)}
                'Memo'{
                    $Prm = @((Get-Tree -Type ParameterAst -Parent (Get-FunctionTree -Name $Fn)).Name.VariablePath.UserPath)
                    $Result += New-Object PSCustomObject -Property @{
                        'Function' = $Fn
                        'Alias'    = @($(Gal -Definition $Fn -ErrorAct SilentlyContinue))
                        'Synopsis' = (Get-Help $Fn -ea sil).Synopsis
                        'Parameter'= $Prm
                        }
                    }
                }
            }
        }
    End{if($Result){Return $Result | Select Function,Synopsis,Alias,Parameter}}
    }  

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
 function View-Memo{
    [CmdletBinding()]
    [Alias('Memo','vm','m')]
    Param()
    DynamicParam{
       # Validation values
        $VSet = $Script:Monkey.FunctList
        $VSet += '*'
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $False
        $Attrib.Position = 0
        $Attrib.ValueFromPipeline = $true
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)

        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)

        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Function', [String[]], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Function', $DynParam)
        
        ## Return Dictionary
        return $Dictionary   
    }
    Begin{
        $result = @()
        if(!$DynParam.IsSet){$DynParam.Value=$Script:Monkey.FocusFunction}
        if($dynParam.Value -eq '*'){$dynParam.Value = $Script:Monkey.FunctList}
        }
    Process{
        foreach($Obj in $DynParam.Value){
            $result += $Obj | View-Help -Memo
            }
        }
    End{Return $Result}
    }

<#
.Synopsis
   View Keyboard Shortcuts
.DESCRIPTION
   List all Keyboard Shortcut commands
   for Scripting Kung-Fu Pandas.
   Powerful stuff. Use with caution.
.EXAMPLE
   k
   List all Keyboard Shortcut commands
#>
Function View-Keyboard{
    [Alias('Key','k')]
    Param()
    # Make It So
    $List = New-object PSCustomObject -Property @{
        p   ='Parse-Code'
        f   ='Get-Focus'
        ff  ='Focus-Function'
        fp  ='Focus-Param'
        n   ='New-Script'
        nf  ='New-Function'
        sf  ='Set-Function'
        np  ='New-Param'
        spm ='Set-Param'
        spv ='Set-ParamValidation'
        a   ='Set-Attribute'
        v   ='View-Syntax'
        h   ='View-Help'
        m   ='View-Memo'
        k   ='View-Keyboard'
        l   ='GoTo-Line'
        b   ='GoTo-Bottom'
        t   ='GoTo-Top'
        c   ='Clear-Console'
        z   ='Undo-Script'
        zz  ='Redo-Script'
        r   ='Run-Script'
        x   ='Load-Script'
        s   ='Save-Script'
        }
    $Result = @()
    foreach($obj in $List|GM|? Membertype -eq NoteProperty){
        $result += New-Object PSCustomObject -Property @{Key=$obj.Name;Function=$List.($Obj.Name)}
        }
    $Result | Sort -Property Function
    }

#endregion

#region ###################### MAKEITSO

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Focus-Function{
    [CmdletBinding()]
    [Alias('Function','ff')]
    Param()
    DynamicParam{
        # Prep VSet
        $VSet = $Script:Monkey.FunctList
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $false
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # if functions exist
        if($Script:Monkey.FunctList -ne $Null){
            # Create Validate Set Obj & add to collection     
            $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
            $Collection.Add($ValidateSet)
            }
        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [String], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Name', $DynParam)
        ## Return Dictionary
        return $Dictionary        
        }
    Begin{}
    Process{
        if(!$DynParam.IsSet){Return $Script:Monkey.FunctList}
        # If existing function
        If($Script:Monkey.FunctList -ne $Null){
            # Set focusFunction
            $Script:Monkey.FocusFunction = $DynParam.Value
            # Reset Focus Param
            $Script:Monkey.FocusParam = $Null
            # Set Param List
            $Script:Monkey.ParamList = Try{@((Get-Tree -Type ParameterAst -Parent (Get-FunctionTree $Script:Monkey.FocusFunction)).name.VariablePath.UserPath)}Catch{}
            # Set cursor Top
            Get-FunctionTree $Script:Monkey.FocusFunction | Set-Cursor -Bottom
            Get-FunctionTree $Script:Monkey.FocusFunction | Set-Cursor -Top
            }
        # If no existing function
        Else{
            # Create function
            Write-Warning "Function Not Found"
            }
        }
    End{}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Focus-Param{
    [CmdletBinding()]
    [Alias('Param','fp')]
    Param()
    DynamicParam{
        # Prep VSet
        $VSet = $Script:Monkey.ParamList
        If($VSet -eq $Null){$VSet= @('NoParams')}
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $false
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
    
        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)
        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [String], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Name', $DynParam)
        ## Return Dictionary
        return $Dictionary  
        }
    Begin{}
    Process{
        if(!$DynParam.ISset){Return $Script:Monkey.ParamList}
        if($VSet -match 'NoParam'){Write-Warning "$VSet";Break}
        # If existing Param
        If($Script:Monkey.ParamList -ne $Null){
            # Set focusFunction
            $Script:Monkey.FocusParam = $DynParam.Value
            # Set Attrib List
            $Script:Monkey.AttribList = Try{(Get-Tree -Type AttributeAst -Parent (Get-Tree -type ParameterAst -Parent (Get-FunctionTree $Script:Monkey.FocusFunction)|? {$_.Name.VariablePath.UserPath -eq $Script:Monkey.FocusParam}))}Catch{Write-Warning 'No AttribList...'}
            # Select Text
            Get-ParamTree $Script:Monkey.FocusParam | Select-Tree
            }
        # If no existing Param
        Else{
            # Create function
            Write-Warning "Param Not Found"
            }
        }
    End{}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Get-Focus{
    [CmdletBinding()]
    [Alias('Focus','f')]
    Param()
    DynamicParam{
        $VSet = @('\')
        $VSet += $Script:Monkey.FunctList
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $False
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # if functions exist

        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)

        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Function', [String], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Function', $DynParam)
        ## Return Dictionary
        return $Dictionary        
        }
    Begin{Parse-Code}
    Process{
        if($DynParam.Value -eq '\'){Focus-Function $Script:Monkey.FocusFunction}
        if($DynParam.IsSet -AND $DynParam.Value -ne '\'){Focus-Function -Name $DynParam.Value}
        $Focus = New-Object PSCustomObject -Property @{
            Function = $Script:Monkey.FocusFunction
            Param    = $Script:Monkey.FocusParam
            }
        }
    End{if(-Not $DynParam.IsSet){Return $Focus}}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function New-Function{
    [Alias('FunctionNew','nf','fn','Draft')]
    Param(
        [Parameter()][String[]]$Name='Do-Stuff',
        [Parameter()][String]$Alias,
        [Parameter()][String]$Synopsis='Short-Description',
        [Parameter()][String[]]$Param,
        [ValidateSet('Min','Max','Dyn')]
        [Parameter()][String]$Template='Max',
        [Parameter()][Switch]$NewFile
        )
    Begin{
        # NiceUp
        if($Name){$Name = $Name | NiceUp}
        if($Alias){$Alias = $Alias | NiceUp}
        if($Param){$Param = $Param | NiceUp}
        # Prep Stuffs
        if($Alias){$Alias = "'$Alias'"}
        $ParamBlock =@()
        foreach($P in $Param){
            $ParamBlock += @("`t`t# Add Param Description`r`n`t`t[Parameter()]`$$P,`r`n")
            }
        # Remove last coma
        If($ParamBlock.count -gt 0){
            $ParamBlock[$ParamBlock.count-1]=$ParamBlock[$ParamBlock.count-1].TrimEnd().TrimEnd(',')
            $ParamBlock = "`r`n$ParamBlock`r`n`t`t"
            }
        # if New tab
        if($NewFile){$New = New-Script;ParseCode}
        # Go to bottom of page
        Set-cursor -bottom
        }
    Process{
        if($PSCmdlet.MyInvocation.InvocationName -match "^Draft$"){new-function -Template Min -NewFile;Break}
        # for each function to create
        Foreach($N in $Name){
            # Poplulate TextBlocks
            ## Mini
            if($Template -eq 'Min'){
                $txt=@("
######################################### $N

<#
.Synopsis
   $Synopsis
.DESCRIPTION
   Long Description
.EXAMPLE
   $N
   Example Description
#>
Function $N{
    [Alias($Alias)]
    Param($ParamBlock)
    ## Make It So
    Return `$Object
    }
#end
")
                }
            ## Maxi
            if($Template -eq 'Max'){               
                $txt=@("
######################################### $N

<#
.Synopsis
   $Synopsis
.DESCRIPTION
   Long Description
.EXAMPLE
   $N
   Example Description
.EXAMPLE
   $N
   Example Description
.INPUTS
   Inputs
.OUTPUTS
   Outputs
.NOTES
   Notes
.FUNCTIONALITY
   Functionality
.LINK
   https://github.com/EmpireProject
#>
Function $N{
    [CmdletBinding()]
    [Alias($Alias)]
    Param($ParamBlock)
    ## Make It So
    Begin{}
    Process{}
    End{Return `$Object}
    }
#end
")
                }
            ## Dynamic
            if($Template -eq 'Dyn'){   
                $txt=@("
######################################### $N

<#
.Synopsis
   $Synopsis
.DESCRIPTION
   Long Description
.PARAMETER
   Document Dynnamic Param
.EXAMPLE
   $N
   Example Description
.EXAMPLE
   $N
   Example Description
.INPUTS
   Inputs
.OUTPUTS
   Outputs
.NOTES
   Notes
.FUNCTIONALITY
   Functionality
.LINK
   https://github.com/EmpireProject
#>
Function $N{
    [CmdletBinding()]
    [Alias($Alias)]
    Param($ParamBlock)
    DynamicParam{
        # Validation values
        `$VSet = @('Insert','Values')

        ## Prep Dictionnary
        `$Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        
        ## Prep Dynamic Param
        # Create First Attribute Obj
        `$Attrib = New-Object System.Management.Automation.ParameterAttribute
        `$Attrib.Mandatory = `$False
        `$Attrib.Position = 0
        # Create AttributeCollection obj
        `$Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        `$Collection.Add(`$Attrib)

        # Create Validate Set Obj & add to collection     
        `$ValidateSet=new-object System.Management.Automation.ValidateSetAttribute(`$VSet)
        `$Collection.Add(`$ValidateSet)

        # Create Runtine DynParam from Collection
        `$DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('ItemName', [String], `$Collection)
        # Add dynamic Param to Dictionary
        `$Dictionary.Add('ItemName', `$DynParam)
        
        ## Return Dictionary
        return `$Dictionary    
        }
    ## Make It So
    Begin{
        if(`$DynParam.IsSet){`$dyn =`$DynParam.Value}
        }
    Process{}
    End{Return `$Object}
    }
#end
")
                }
            # Go to bottom
            try{Set-Cursor -Bottom}Catch{}
            #Insert Snippet
            # ISE
            if($Host.Name -eq 'Windows PowerShell ISE Host'){
                $Editor = $psise.CurrentFile.Editor
                if($NewFile){$editor = $New.Editor}
                $Editor.InsertText($txt)
                }
            # VSCODE
            ElseIf($Host.Name -eq 'Visual Studio Code Host'){
                If($NewFile){
                    $Txt | Set-Clipboard
                    $WS = New-Object -ComObject WScript.Shell
                    $WS.SendKeys('^`')
                    $WS.SendKeys('^v')
                    $WS.SendKeys('^`')
                    Save-Script
                    $WS.SendKeys('^`')
                    $WS.SendKeys('^`')                   
                    }
                Else{
                    Try{$psEditor.GetEditorContext().CurrentFile.InsertText("$txt")}Catch{}
                    }
                }
            # Parse & GoTo Bottom
            Try{Parse-Code}Catch{}
            Try{Set-Cursor -Bottom}Catch{}
            }
        }
    End{try{Focus-Function $n}Catch{}}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Set-Function{
    [Cmdletbinding()]
    [Alias('FunctionSet','sf','fs')]
    Param(
        [Parameter()][Alias('DPSN')][String]$DefaultParameterSetname,
        [ValidateSet('True','False')]
        [Parameter()][Alias('ShouldProcess')][String]$SupportsShouldProcess,
        [ValidateSet('True','False')]
        [Parameter()][Alias('PosBinding')][String]$PositionalBinding,
        [Parameter()][Alias('Uri')][String]$HelpUri,
        [ValidateSet('Low','Medium','High')]
        [Parameter()][Alias('Impact')][String]$ConfirmImpact,
        [Parameter()][String]$Alias,
        [Parameter()][Type]$OutputType,
        [Parameter()][String]$NewName
        )
    DynamicParam{
        $VSet = @('NoFunction')
        if($Script:Monkey.FunctList -ne $Null){$VSet = $Script:Monkey.FunctList}
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $False
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # if functions exist

        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)

        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [String], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Name', $DynParam)
        ## Return Dictionary
        return $Dictionary 
        }
    Begin{
        # NiceUp
        if($NewName){$NewName = $NewName | NiceUp}
        if($Alias){$Alias = $Alias | NiceUp}
        # If function other than current focus function > Focus
        If($DynParam.IsSet -AND $DynParam.Value -ne $Script:Monkey.FocusFunction){Focus-Function $DynParam.Value}
        }
    Process{
        # Break if no function
        if($Script:Monkey.FunctList -eq $Null){Write-Warning "No function. Parse/Focus...";Break}
        if($Script:Monkey.FocusFunction -eq $Null){Write-Warning "No Focus Function. Focus...";Break}
        
        # DefaultParameterSetname
        if($DefaultParameterSetname){
            # Find Sub
            $Sub = Get-SubTree DefaultPSN
            # If exist > overwite
            If($Sub){
                # Prep/Select/Insert
                $Sub | Select-tree
                $New = "DefaultParameterSetname='$DefaultParameterSetname'"
                Set-Selected $New
                }
            # Else, if not exist
            Else{
                # Search binding Block
                $Blk = Get-Subtree Binding 
                # If exists
                if($Blk){
                    # Prep/Select/Insert
                    $Blk | Select-tree
                    $Old = Get-Selected
                    $New = $Old | Write-Block -Key CmdletBinding -Field 'DefaultParameterSetname' -Value "'$DefaultParameterSetname'"
                    Set-Selected $New
                    }
                Else{
                    # Select Alias Block
                    $Sub = Get-SubTree AliasF
                    If($Sub){
                        # Select
                        $Sub | Select-Tree
                        $Old = Get-Selected
                        # Prep New
                        $Blk = Write-Block -Key CmdletBinding -Field 'DefaultParameterSetname' -Value "'$DefaultParameterSetname'"
                        # Insert
                        $New = "$Blk`r`n`t$Old"
                        Set-Selected $New
                        } 
                    }
                }
            Parse-Code
            }
        # SupportsShouldProcess
        if($SupportsShouldProcess){
            # Find Sub
            $Sub = Get-SubTree ShouldProcess
            # If exist > overwite
            If($Sub){
                # Prep/Select/Insert
                $Sub | Select-tree
                $New = "SupportsShouldProcess=`$$SupportsShouldProcess"
                Set-Selected $New
                }
            # Else, if not exist
            Else{
                # Search binding Block
                $Blk = Get-Subtree Binding 
                # If exists
                if($Blk){
                    # Prep/Select/Insert
                    $Blk | Select-tree
                    $Old = Get-Selected
                    $New = $Old | Write-Block -Key CmdletBinding -Field 'SupportsShouldProcess' -Value "`$$SupportsShouldProcess"
                    Set-Selected $New
                    }
                Else{
                    # Select Alias Block
                    $Sub = Get-SubTree AliasF
                    If($Sub){
                        # Select
                        $Sub | Select-Tree
                        $Old = Get-Selected
                        # Prep New
                        $Blk = Write-Block -Key CmdletBinding -Field 'SupportsShouldProcess' -Value "`$$SupportsShouldProcess"
                        # Insert
                        $New = "$Blk`r`n`t$Old"
                        Set-Selected $New
                        } 
                    }
                }
            Parse-Code
            }
        # PositionalBinding
        if($PositionalBinding){
            # Find Sub
            $Sub = Get-SubTree PosBinding
            # If exist > overwite
            If($Sub){
                # Prep/Select/Insert
                $Sub | Select-tree
                $New = "PositionalBinding=`$$PositionalBinding"
                Set-Selected $New
                }
            # Else, if not exist
            Else{
                # Search binding Block
                $Blk = Get-Subtree Binding 
                # If exists
                if($Blk){
                    # Prep/Select/Insert
                    $Blk | Select-tree
                    $Old = Get-Selected
                    $New = $Old | Write-Block -Key CmdletBinding -Field 'PositionalBinding' -Value "`$$PositionalBinding"
                    Set-Selected $New
                    }
                Else{
                    # Select Alias Block
                    $Sub = Get-SubTree AliasF
                    If($Sub){
                        # Select
                        $Sub | Select-Tree
                        $Old = Get-Selected
                        # Prep New
                        $Blk = Write-Block -Key CmdletBinding -Field 'PositionalBinding' -Value "`$$PositionalBinding"
                        # Insert
                        $New = "$Blk`r`n`t$Old"
                        Set-Selected $New
                        } 
                    }
                }
            Parse-Code
            }
        # HelpUri
        if($HelpUri){
            # Find Sub
            $Sub = Get-SubTree HelpUri
            # If exist > overwite
            If($Sub){
                # Prep/Select/Insert
                $Sub | Select-tree
                $New = "HelpUri='$HelpUri'"
                Set-Selected $New
                }
            # Else, if not exist
            Else{
                # Search binding Block
                $Blk = Get-Subtree Binding 
                # If exists
                if($Blk){
                    # Prep/Select/Insert
                    $Blk | Select-tree
                    $Old = Get-Selected
                    $New = $Old | Write-Block -Key CmdletBinding -Field 'HelpUri' -Value "'$HelpUri'"
                    Set-Selected $New
                    }
                Else{
                    # Select Alias Block
                    $Sub = Get-SubTree AliasF
                    If($Sub){
                        # Select
                        $Sub | Select-Tree
                        $Old = Get-Selected
                        # Prep New
                        $Blk = Write-Block -Key CmdletBinding -Field 'HelpUri' -Value "'$HelpUri'"
                        # Insert
                        $New = "$Blk`r`n`t$Old"
                        Set-Selected $New
                        } 
                    }
                }
            Parse-Code
            }
        # ConfirmImpact
        if($ConfirmImpact){
            # Find Sub
            $Sub = Get-SubTree ConfImpact
            # If exist > overwite
            If($Sub){
                # Prep/Select/Insert
                $Sub | Select-tree
                $New = "ConfirmImpact='$ConfirmImpact'"
                Set-Selected $New
                }
            # Else, if not exist
            Else{
                # Search binding Block
                $Blk = Get-Subtree Binding 
                # If exists
                if($Blk){
                    # Prep/Select/Insert
                    $Blk | Select-tree
                    $Old = Get-Selected
                    $New = $Old | Write-Block -Key CmdletBinding -Field 'ConfirmImpact' -Value "'$ConfirmImpact'"
                    Set-Selected $New
                    }
                Else{
                    # Select Alias Block
                    $Sub = Get-SubTree AliasF
                    If($Sub){
                        # Select
                        $Sub | Select-Tree
                        $Old = Get-Selected
                        # Prep New
                        $Blk = Write-Block -Key CmdletBinding -Field 'ConfirmImpact' -Value "'$ConfirmImpact'"
                        # Insert
                        $New = "$Blk`r`n`t$Old"
                        Set-Selected $New
                        } 
                    }
                }
            Parse-Code
            }
        # Alias
        if($Alias){
            # Find Sub
            $Sub = Get-SubTree AliasF
            # If exist > overwite
            If($Sub){
                # Prep/Select/Insert
                $Sub | Select-tree
                $New = Write-Block -Key Alias -Value "'$Alias'"
                Set-Selected $New
                }
            # Else, if not exist
            Else{
                # Search Param Block
                $Blk = Get-tree -Type ParamBlockAst -Parent (Get-functionTree $Script:Monkey.FocusFunction) 
                # If exists
                if($Blk){
                    # Select Block
                    $Blk | Select-Tree
                    $Old = Get-Selected
                    # Prep New
                    $New = Write-Block -Key Alias -Value "'$Alias'"
                    # Insert
                    $Str = "$New`r`n`t$Old"
                    Set-Selected $Str
                    }
                Else{Write-Warning "Need Param Block...";Break}
                }
            Parse-Code
            }
        # OutputType
        if($OutputType){
            # Find Sub
            $Sub = Get-SubTree Output
            # If exist > overwite
            If($Sub){
                # Prep/Select/Insert
                $Sub | Select-tree
                $New = Write-Block -Key OutputType -Value "[$OutputType]"
                Set-Selected $New
                }
            # Else, if not exist
            Else{
                # Search Param Block
                $Blk = Get-SubTree AliasF
                # If exists
                if($Blk){
                    # Select Block
                    $Blk | Select-Tree
                    $Old = Get-Selected
                    # Prep New
                    $New = Write-Block -Key OutputType -Value "[$OutputType]"
                    # Insert
                    $Str = "$Old`r`n`t$New"
                    Set-Selected $Str
                    }
                Else{Write-Warning "Need Alias Block...";Break}
                }
            Parse-Code
            }
        # NewName
        if($NewName){
            $FTree = Get-functionTree $Script:Monkey.FocusFunction
            $FTree | Select-tree
            $Old   = Get-Selected
            $New   = $Old -replace "^function.+(\r\n)*{","function $NewName{"
            Set-Selected $New
            Parse-code
            Focus-Function $NewName
            }
        }
    End{}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function New-Param{
    [Alias('ParamNew','np','pn')]
    Param(
        # names of Parameters to create
        [Parameter(Mandatory=$true,Position=0)][String[]]$Name,
        # Parameter Alias
        [Parameter()][String]$Alias,
        # Parameter Type
        [Parameter()][Type]$Type,
        # Parameter Validation
        [ValidateSet('Set','Range','Pattern','Length','Count','Script','NotNull','NotNullOrEmpty','Null','EmptyString','EmptyCollection')]
        [Parameter()][String[]]$Validate,
        # Attrib Mandatory
        [ValidateSet('True','False')]
        [Parameter()][String]$Mandatory,
        # Attrib Position
        [Parameter()][Int]$Position,
        # Atrrib Value from Pipeline
        [ValidateSet('True','False')]
        [Parameter()][Alias('Pipeline')][String]$ValueFromPipeline,
        # Attrib ParameterSetname
        [Parameter()][Alias('PSN')][String[]]$ParameterSetName,
        # Param Description
        [Parameter()][String]$Description='Param Description'
        )
    Begin{
        # Niceup
        $Name = $Name | NiceUp
        if($Alias){$Alias = $Alias | NiceUp}
        if($ParameterSetName){$ParameterSetName = $ParameterSetName | NiceUp}
        # Prep empty String
        $ParamString = ''
        If($ParameterSetName){
            Foreach($PSN in $ParameterSetName){
                $ParamString += "`r`n`t`t[Parameter("
                if($Mandatory){$paramString += "Mandatory=`$$Mandatory,"}
                if($Position){$paramString += "Position=$Position,"}
                if($ValueFromPipeline){$paramString += "ValueFromPipeline=`$$ValueFromPipeline,"}
                if($ParameterSetName){$paramString += "ParameterSetName='$PSN',"}
                $ParamString = ($ParamString + ')]').replace(',)]',')]')
                }
            }
        Else{
            $ParamString += "`r`n`t`t[Parameter("
            if($Mandatory){$paramString += "Mandatory=`$$Mandatory,"}
            if($Position){$paramString += "Position=$Position,"}
            if($ValueFromPipeline){$paramString += "ValueFromPipeline=`$$ValueFromPipeline,"}
            $ParamString = ($ParamString + ')]').replace(',)]',')]')
            }
        #$paramString += "`r`n`t`t"
        if($Alias){$paramString += "[Alias('$Alias')]"}
        if($Type){$paramString += "[$Type]"}
        if($Validate){
            $ValString = ''
            Foreach($V in $Validate){
                Switch($V){
                    'Set'{$val+="[Validate$V('One','Two')]"}
                    'Range'{$val+="[Validate$V(1,7)]"}
                    'Pattern'{$val+="[Validate$V(`".?`")]"}
                    'Length'{$val+="[Validate$V(0,7)]"}
                    'Count'{$val+="[Validate$V(1,2)]"}
                    'Script'{$val+="[Validate$V({`$_ -eq `$True})]"}
                    'NotNull'{$val+="[Validate$V()]"}
                    'NotNullOrEmpty'{$val+="[Validate$V()]"}
                    'Null'{$Val+="[Allow$V()]"}
                    'EmptyString'{$Val+="[Allow$V()]"}
                    'EmptyCollection'{$Val+="[Allow$V()]"}
                    }
                $ValString += "`r`n`t`t$Val"
                }
            $ParamString = $ValString+$ParamString
            }
        # Add Description
        $ParamString = "`r`n`t`t# $Description" + $ParamString
        }
    Process{
        foreach($N in $Name){
            $String = $paramString + "`$$N"
            # Select Param Block
            $Block = Try{Get-Tree -Type ParamBlockAst -Parent (Get-FunctionTree -Name $Script:Monkey.FocusFunction)}Catch{Write-Warning "Not focused...";Break}
            # Select block
            $Block | Select-Tree
            # Get Selected Text
            $OldText = $Block | Get-Text
            # trim to Append
            $NewText = $Oldtext.TrimEnd().TrimEnd(')').TrimEnd()
            # Add coma if needed
            if($OldText.replace("\s",'') -ne 'Param()'){$NewText += ','}
            # Append
            $NewText  = $NewText + $String + "`r`n`t`t)"
            # Insert
            Set-Selected $newText
            Parse-Code
            Try{Focus-Param $N}Catch{Get-Focus \}
            }
        }
    End{
        # Set Param List
        $Script:Monkey.ParamList = ((Get-Tree -Type ParameterAst -Parent (Get-FunctionTree $Script:Monkey.FocusFunction)).name.VariablePath.UserPath)
        }  
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Set-Param{
    [CmdletBinding()]
    [Alias('ParamSet','spm','ps')]
    Param(
        # Parameter Alias
        [Parameter()][String]$Alias,
        # Parameter Type
        [Parameter()][Type]$Type,
        # Parameter Validation
        [ValidateSet('ValidateSet','ValidateRange','ValidatePattern','ValidateLength','ValidateCount','ValidateScript','ValidateNotNull','ValidateNotNullOrEmpty','AllowNull','AllowEmptyString','AllowEmptyCollection')]
        [Parameter()][String[]]$Validate,
        # Def Value
        [Parameter()][Alias('Value')]$DefaultValue,
        # New Name
        [Parameter()][String]$NewName
        )
    DynamicParam{
        $VSet = 'NoFocusParam'
        if($Script:Monkey.ParamList -ne ''){$VSet = $Script:Monkey.ParamList}
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $False
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)
        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [String[]], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Name', $DynParam)
        ## Return Dictionary
        return $Dictionary 
        }
    Begin{
        # Focus & NiceUp Param
        If($DynParam.IsSet -AND $DynParam.Value -ne $Script:Monkey.FocusParam){
            $Param = $DynParam.Value | NiceUp
            Focus-Param $Param
            }
        Else{$Param = $Script:Monkey.FocusParam}
        # NiceUp DefaultValue
        If($Alias){$Alias = $Alias | NiceUp}
        }
    Process{
        $Main = Get-ParamTree -Name $Param
        # Alias
        If($Alias){
            # Prep new
            $New = Write-block -Key Alias -Value "'$Alias'"
            # Search for Sub
            $Sub = Get-Subtree -Type AliasP
            # If exists > overwite
            if($Sub){
                # Select
                $Sub | Select-tree
                Set-Selected $New
                }
            # Else
            Else{
                # Select Param Var
                (Get-Subtree -Type Attrib)[(Get-Subtree -Type Attrib).count-1] | Select-tree
                $old = Get-Selected
                Set-Selected "$Old$New"
                }
            Parse-Code
            }
        # Type
        if($type){
            $type = $type.name | NiceUp
            # Prep new
            $New = "[$Type]"
            # Search for Sub
            $Sub = Get-Subtree -Type Type
            # If exists > overwite
            if($Sub){
                # Select
                $Pos = $Sub.Extent
                if($Host.Name -eq 'Windows PowerShell ISE Host'){
                    $psISE.CurrentFile.Editor.select($Pos.StartLineNumber,$Pos.StartColumnNumber,$Pos.EndLineNumber,$Pos.EndColumnNumber)
                    }
                if($Host.Name -eq 'Visual Studio Code Host'){}
                Set-Selected $New
                }
            # Else
            Else{
                # Select Param Var
                (Get-Subtree -Type NameP) | Select-tree
                $old = Get-Selected
                Set-Selected "$New$Old"
                }
            Parse-Code
            }
        # Validation
        if($Validate){
            # Prep Stuff
            Switch($Validate){
                'ValidateSet'           {$Key='ValSet'         ; $str="[$Validate('A','B','C')]"}
                'ValidateRange'         {$Key='ValRange'       ; $str="[$Validate(0,100)]"}
                'ValidatePattern'       {$Key='ValPattern'     ; $str="[$Validate(`".+`")]"}
                'ValidateLength'        {$Key='ValLength'      ; $str="[$Validate(0,100)]"}
                'ValidateCount'         {$Key='ValCount'       ; $str="[$Validate(0,100)]"}
                'ValidateScript'        {$Key='ValScript'      ; $str="[$Validate({`$true})]"}
                'ValidateNotNull'       {$Key='ValNotNull'     ; $str="[$Validate()]"}
                'ValidateNotNullOrEmpty'{$Key='ValNotNullEmpty'; $str="[$Validate()]"}
                'AllowNull'             {$Key='AllowNull'      ; $str="[$Validate()]"}
                'AllowEmptyString'      {$Key='AllowEString'   ; $str="[$Validate()]"}
                'AllowEmptyCollection'  {$Key='AllowECollect'  ; $str="[$Validate()]"}
                }
            # Search Validate
            $Sub = Get-SubTree -Type $Key
            # if exists
            if($Sub){
                # Select
                $Sub | Select-tree
                # insert String
                Set-selected $Str
                }
            Else{
                # look for Parameter tree
                $blk = Get-ParamTree $Script:Monkey.focusParam
                # Select
                $blk | Select-tree
                $old = Get-Selected
                # Insert String
                Set-Selected "$Str`r`n`t`t$Old"
                }
            Parse-Code
            }
        # Default Value
        if($DefaultValue){
            # Prep
            if($DefaultValue.getType().Name -eq 'String'){$DefaultValue = "'$DefaultValue'"}
            if($DefaultValue -match ("^\'\$")){$DefaultValue = $DefaultValue.trim("'")}
            # Search if exist
            $Sub = Get-Subtree -Type DefaultVal
            # if exist
            if($Sub){
                # Select
                $Sub | Select-tree
                # Replace
                Set-Selected $DefaultValue
                }
            Else{
                # Get Block
                $Blk = Get-ParamTree $Script:Monkey.focusParam
                # Select
                $Blk | Select-Tree
                # Get Selected
                $Old = Get-Selected
                # Replace
                $New = "$Old=$DefaultValue"
                Set-Selected $New
                }
            parse-Code
            }
        # New Name
        if($NewName){
            # Get Sub
            $Sub = Get-SubTree -Type NameP
            $Sub | Select-Tree
            # Set new
            $NewName = $NewName | NiceUp
            Set-Selected "`$$NewName"
            # Parse
            Parse-Code
            # Set Param List
            $Script:Monkey.ParamList = Try{@((Get-Tree -Type ParameterAst -Parent (Get-FunctionTree $Script:Monkey.FocusFunction)).name.VariablePath.UserPath)}Catch{}
            # Focus
            focus-Param $NewName
            }
        }
    End{}  
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Set-Attribute{
    [CmdletBinding(DefaultParameterSetname='SameBlock')]
    [Alias('Attribute','Attrb','sa','as','a')]
    Param(
        # Attrib Mandatory
        [ValidateSet('True','False')]
        [Parameter()][String]$Mandatory,
        # Attrib Position
        [Parameter()][Int]$Position,
        # Attrib ParameterSetName
        [Parameter()][Alias('ParamSetName')][String]$NewPSN,
        # Atrrib Value from Pipeline
        [ValidateSet('True','False')]
        [Parameter()][Alias('Pipeline')][String]$ValueFromPipeline,
        # Attrib Value by Prop Name
        [ValidateSet('True','False')]
        [Parameter()][Alias('PipelineByProp')][String]$ValueFromPipelineByPropertyName,
        # Attrib Value By Remaining Args
        [ValidateSet('True','False')]
        [Parameter()][Alias('RemainingArgs')][String]$ValueFromRemainingArguments,
        # Attrib Mandatory
        [Parameter()][String]$HelpMessage,
        # New Pram Attrib Block
        [Parameter(Mandatory=$true,ParameterSetName='NewBlock')][Switch]$NewBlock
        )
    DynamicParam{
        # List Param PSN
        [Array]$List = (Get-SubTree -Type ParamSetName).Argument.Value
        IF($List.count -ne 0){$List+='*'}
        Else{$List+='.'}
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $false
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # Create Validate Set Obj & add to collection    
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($List)
        $Collection.Add($ValidateSet)
        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('PSN', [String[]], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('PSN', $DynParam)
        
        ## Return Dictionary
        return $Dictionary 
        }
    Begin{
        # Pos to Str
        if($Position){$Posit = $Position -as [String]}
        # List ParameterSet Names
        $List = (Get-SubTree -Type ParamSetName).Argument.Value}
    Process{
        if($NewBlock){
            if(!$NewPSN){Write-Warning 'Please Specify New PSN...';Return}
            # Select Existing Param Attrb Block
            $Sub = Get-SubTree -Type Attrib
            $Sub
            $Sub | Select-tree
            $Old = Get-Selected

            # Create New
            if($Mandatory)                      {$New = $New | Write-Block -Key Parameter -Field Mandatory -Value "`$$Mandatory"}
            if($Posit)                          {$New = $New | Write-Block -Key Parameter -Field Position -Value "$Posit"}
            <# Always ------------------------#> $New = Write-Block -Key Parameter -Field ParameterSetName -Value "'$NewPSN'"
            if($ValueFromPipeline)              {$New = $New | Write-Block -Key Parameter -Field ValueFromPipeline -Value "`$$ValueFromPipeline"}
            if($ValueFromPipelineByPropertyName){$New = $New | Write-Block -Key Parameter -Field ValueFromPipelineByPropertyName -Value "`$$ValueFromPipelineByPropertyName"}
            if($ValueFromRemainingArguments)    {$New = $New | Write-Block -Key Parameter -Field ValueFromRemainingArguments -Value "`$$ValueFromRemainingArguments"}
            if($HelpMessage)                    {$New = $New | Write-Block -Key Parameter -Field HelpMessage -Value "'$HelpMessage'"}
            
            # Add to old
            Set-Selected "$New`r`n`t`t$Old"
            Parse-Code
            }
        Else{
            # If PSN needed and not specified > Break
            if($List.count -gt 1 -AND $DynParam.IsSet -eq $false){Write-Warning 'Please Specify PSN...';Break}
            # If PSN not needed
            if($DynParam.IsSet -eq $false){$Set = @('.')}
            # If PSN Specified
            else{$set = @($DynParam.Value)}
            # If * (All)
            if($Set -contains '*'){$Set = @($List)}
    
            # Foreach PSN/NoPSN
            foreach($Name in $Set){ 
                
                ## Helper SetSub
                function SetSub{
                    # If name is '.'
                    if($Name -eq '.'){
                        # Get Param Attrib Block
                        $Sub = Get-Subtree -Type Attrib
                        }
                    # Any other
                    Else{
                        # Select Specified ParamBlock
                        $Sub = Get-Subtree -Type Attrib -PSN $Name
                        }
                    # If no Sub Found > Break
                    if($Sub.Extent -eq $Null){Write-Warning "Selection Error...";Return}
                    $Sub | Select-Tree
                    }

                ## Mandatory
                if($Mandatory){
                    SetSub
                    # Search Mandatory Field
                    if($Name -eq '.'){'d';$Sel = Get-SubTree -Type Mandatory}
                    Else{
                        $Sel = Get-Tree -type NamedAttributeArgumentAst -Parent $Sub | ? ArgumentName -eq Mandatory
                        $Sel = $Sel |? {$_.Parent.Extent.Text -match "ParameterSetName='$Name'"}
                        }
                    # Found > Change Value
                    if($Sel){
                        $Sel|Select-tree
                        Set-Selected "Mandatory=`$$Mandatory"
                        }
                    # Not Found > Create
                    Else{
                        # Get full Attrib Block
                        $Old = Get-Selected
                        $New = $Old | Write-Block -Key Parameter -Field Mandatory -Value "`$$Mandatory"
                        Set-Selected $New 
                        }
                    Parse-Code
                    }

                ## Position
                if($Posit){
                    SetSub
                    # Search Position Field
                    if($Name -eq '.'){$Sel = Get-SubTree -Type Position}
                    Else{$Sel = Get-Tree -type NamedAttributeArgumentAst -Parent $Sub | ? ArgumentName -eq Position}
                    # Found > Change Value
                    if($Sel){
                        $Sel|Select-tree
                        Set-Selected "Position=$Posit"
                        }
                    # Not Found > Create
                    Else{
                        # Get full Attrib Block
                        $Old = Get-Selected
                        $New = $Old | Write-Block -Key Parameter -Field Position -Value "$Posit"
                        Set-Selected $New 
                        }
                    Parse-Code
                    }
            
                ## ValueFromPipeline
                if($ValueFromPipeline){
                    SetSub
                    # Search ValueFromPipeline Field
                    if($Name -eq '.'){$Sel = Get-SubTree -Type Pipeline}
                    Else{$Sel = Get-Tree -type NamedAttributeArgumentAst -Parent $Sub | ? ArgumentName -eq ValueFromPipeline}
                    # Found > Change Value
                    if($Sel){
                        $Sel|Select-tree
                        Set-Selected "ValueFromPipeline=`$$ValueFromPipeline"
                        }
                    # Not Found > Create
                    Else{
                        # Get full Attrib Block
                        $Old = Get-Selected
                        $New = $Old | Write-Block -Key Parameter -Field ValueFromPipeline -Value "`$$ValueFromPipeline"
                        Set-Selected $New 
                        }
                    Parse-Code
                    }

                ## ValueFromPipelineByPropertyName
                if($ValueFromPipelineByPropertyName){
                    SetSub
                    # Search ValueFromPipelineByPropertyName Field
                    if($Name -eq '.'){$Sel = Get-SubTree -Type PipelineByProp}
                    Else{$Sel = Get-Tree -type NamedAttributeArgumentAst -Parent $Sub | ? ArgumentName -eq ValueFromPipelineByPropertyName}
                    # Found > Change Value
                    if($Sel){
                        $Sel|Select-tree
                        Set-Selected "ValueFromPipelineByPropertyName=`$$ValueFromPipelineByPropertyName"
                        }
                    # Not Found > Create
                    Else{
                        # Get full Attrib Block
                        $Old = Get-Selected
                        $New = $Old | Write-Block -Key Parameter -Field ValueFromPipelineByPropertyName -Value "`$$ValueFromPipelineByPropertyName"
                        Set-Selected $New 
                        }
                    Parse-Code
                    }
            
                ## ValueFromRemainingArguments
                if($ValueFromRemainingArguments){
                    SetSub
                    # Search ValueFromRemainingArguments Field
                    if($Name -eq '.'){$Sel = Get-SubTree -Type RemainingArgs}
                    Else{$Sel = Get-Tree -type NamedAttributeArgumentAst -Parent $Sub | ? ArgumentName -eq ValueFromRemainingArguments}
                    # Found > Change Value
                    if($Sel){
                        $Sel|Select-tree
                        Set-Selected "ValueFromRemainingArguments=`$$ValueFromRemainingArguments"
                        }
                    # Not Found > Create
                    Else{
                        # Get full Attrib Block
                        $Old = Get-Selected
                        $New = $Old | Write-Block -Key Parameter -Field ValueFromRemainingArguments -Value "`$$ValueFromRemainingArguments"
                        Set-Selected $New 
                        }
                    Parse-Code
                    }

                ## HelpMessage
                if($HelpMessage){
                    SetSub
                    # Search HelpMessage Field
                    if($Name -eq '.'){$Sel = Get-SubTree -Type HelpMess}
                    Else{$Sel = Get-Tree -type HelpMessage -Parent $Sub | ? ArgumentName -eq HelpMessage}
                    # Found > Change Value
                    if($Sel){
                        $Sel|Select-tree
                        Set-Selected "HelpMessage='$HelpMessage'"
                        }
                    # Not Found > Create
                    Else{
                        # Get full Attrib Block
                        $Old = Get-Selected
                        $New = $Old | Write-Block -Key Parameter -Field HelpMessage -Value "'$HelpMessage'"
                        Set-Selected $New 
                        }
                    Parse-Code
                    }
            
                ## New ParameterSetName
                if($NewPSN){
                    SetSub
                    
                    # Search ParameterSetName Field
                    $Sel = Get-SubTree -Type ParamSetName
                    if($Name){$Sel = Get-SubTree -Type ParamSetName | ? {$_.Argument.Value -eq $Name}}
                    if($Name -eq '.'){$Sel = Get-SubTree -Type ParamSetName}
                    #Else{$Sel = Get-Tree -type NamedAttributeArgumentAst -Parent $Sub | ? ArgumentName -eq ParameterSetName}
                    
                    # Found > Change Value
                    if($Sel){
                        $Sel|Select-tree
                        Set-Selected "ParameterSetName='$NewPSN'"
                        }
                    # Not Found > Create
                    Else{
                        # Get full Attrib Block
                        $Old = Get-Selected
                        $New = $Old | Write-Block -Key Parameter -Field ParameterSetName -Value "'$NewPSN'"
                        Set-Selected $New
                        }
                    Parse-Code
                    }
               
                }
            }         
        }
    End{}
    }

<#
.Synopsis
   Set Param Validation
.DESCRIPTION
   Set Param Validation
.EXAMPLE
   Set-ParamValidation -ValidateSet A,B,C
.EXAMPLE
   spv -ParamName ParamOne -ValidateSet A,B,C 
#>
Function Set-ParamValidation{
    [Alias('ParamValidation','spv','pv')]
    Param(
        # Target Folder. Defaults to PWD
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$True,ParameterSetName='ValidateSet')][String[]]$ValidateSet,
        [ValidateCount(1,2)]
        [Parameter(Mandatory=$True,ParameterSetName='ValidateCount')][int[]]$ValidateCount,
        [ValidateCount(2,2)]
        [Parameter(Mandatory=$True,ParameterSetName='ValidateRange')][int[]]$ValidateRange,
        [ValidateCount(1,2)]
        [Parameter(Mandatory=$True,ParameterSetName='ValidateLength')][int[]]$ValidateLength,
        [Parameter(Mandatory=$True,ParameterSetName='ValidatePattern')][Regex]$ValidatePattern,
        [Parameter(Mandatory=$True,ParameterSetName='ValidateScript')][ScriptBlock]$ValidateScript,
        [Parameter(Mandatory=$True,ParameterSetName='ValidateNotNull')][Switch]$ValidateNotNull,
        [Parameter(Mandatory=$True,ParameterSetName='ValidateNotNullOrEmpty')][Switch]$ValidateNotNullOrEmpty,
        [Parameter(Mandatory=$True,ParameterSetName='AllowNull')][Switch]$AllowNull,
        [Parameter(Mandatory=$True,ParameterSetName='AllowEmptyString')][Switch]$AllowEmptyString,
        [Parameter(Mandatory=$True,ParameterSetName='AllowEmptyCollection')][Switch]$AllowEmptyCollection
        )
    DynamicParam{
        $VSet = 'NoParam'
        if($Script:Monkey.ParamList -ne ''){$VSet = $Script:Monkey.ParamList}
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $False
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # Create Validate Set Obj & add to collection     
        $ValidSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidSet)
        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('ParamName', [String], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('ParamName', $DynParam)
        ## Return Dictionary
        return $Dictionary 
        }
    Begin{
        if(-Not$DynParam.IsSet){$DynParam.Value=$Script:Monkey.FocusParam}
        if($DynParam.Value -ne $Script:Monkey.FocusParam){Focus-Param $DynParam.Value}
        $PName = $DynParam.Value
        if($PName -ne $Script:Monkey.FocusParam){Focus-Param $PName}
        $Valid = $PSCmdlet.ParameterSetName
        $Value = GV -Name $PSCmdlet.ParameterSetName -ValueOnly
        }
    Process{
        # Generate String based on Validate type.
        Switch($Valid){
            'ValidateSet'           {$type = 'ValSet';$Value = "'$($Value -join `"','`")'"}
            'ValidateCount'         {$type = 'ValCount';if($Value.count -eq 1){$Value = $value + $value};$Value =  "$($Value -join ',')"}
            'ValidateRange'         {$type = 'ValRange';$Value =  "$($Value -join ',')"}
            'ValidateLength'        {$type = 'ValLength';if($Value.count -eq 1){$Value = $value + $value};$Value =  "$($Value -join ',')"}
            'ValidatePattern'       {$type = 'ValPattern';$Value =  "`"$Value`""}
            'ValidateScript'        {$type = 'ValScript';$Value =  "{$Value}"}
            'ValidateNotNull'       {$type = 'ValNotNull';$Value =  $Null}
            'ValidateNotNullOrEmpty'{$type = 'ValNotNullEmpty';$Value =  $Null}
            'AllowNull'             {$type = 'AllowNull';$Value =  $Null}
            'AllowEmptyString'      {$type = 'AllowEString';$Value =  $Null}
            'AllowEmptyCollection'  {$type = 'AllowECollect';$Value =  $Null}
            }
        $Str = "[$Valid($Value)]"
        # Check if Valid exist
        $Blk = Get-Subtree -Type $type 
        # If exit replace
        if($Blk){
            $Blk | Select-tree
            Set-selected $Str
            }
        # Else Insert
        Else{
            Get-Paramtree -Name $Pname | Select-tree
            $Old = Get-Selected
            Set-Selected "$Str`r`n`t`t$Old"
            }
        Parse-code
        }
    End{}
    }#>

#endregion

#region ###################### CSV

####################### FUNCTION: Invoke-CSVMonkey

<#
.Synopsis
   Generate Cmdlet from CSV Files
.DESCRIPTION
   Long Description
.EXAMPLE
   Invoke-CSVMonkey
   Example Description
#>
Function Invoke-CSVMonkey{
    [Alias('CSVMonkey')]
    Param(
		# Optional Path to Folder
        [ValidateScript({Test-Path $_})]
		[Parameter(Mandatory=$false,Position=0)][String]$TargetFolder=$pwd
		)
    Parse-Code
    # Require fresh scriptpane
    if($Script:Monkey.AST.Extent.Text.trim()){
        Write-Warning "Existing Data. Ninja Combo Required for Safety"
        Write-host "[n][enter][up][up][enter]" -ForegroundColor Green
        return
        }
    ## Check Function file
    $FunctionFile = Get-ChildItem $targetfolder | ? Name -match "^(.+)_F_CSV.csv$"
    # Stop if not found
    If($FunctionFile -eq $Null){Write-Warning "Function File Not Found. Exiting.";Return}
    # Import CSV / Stop if invalid Headers
    $FunctionCSV = Import-CSV $FunctionFile | ? FunctionName -ne ''
    # Headers
    $HeadList = 'FunctionName','Alias','Synopsis','Outputype','DefaultPSN','HelpURI'
    $Headers = ($FunctionCSV |GM|? Membertype -eq NoteProperty).name
    # Stop if mismatch
    If(Compare-Object -ref $HeadList -dif $Headers){Write-Warning 'Invalid Function CSV. Exiting';Return}

    ## FUNCTION ##
    # Get function list
    $FunctionList = $FunctionCSV.FunctionName
    # Foreach function
    foreach($F in $FunctionList){
        Write-Verbose "`r`n# FUNCTION $F"
        # Get Row
        $Row = $FunctionCSV |? FunctionName -eq $F
        # Prep CMD
        $CMD = "New-Function -Name $F"
        if($Row.Alias)     {$CMD += ' -Alias '      + $row.Alias}
        if($Row.Synopsis)  {$CMD += " -Synopsis '"  + $row.Synopsis +"'"}
        # Exec CMD
        Write-Verbose $CMD
        IEX $CMD
        # Extra
        if($Row.OutputType -OR $Row.DefaultPSN -OR $Row.HelpURI){
            # Prep CMD
            $CMD = "Set-Function -Name $F"
            if($Row.OutputType){$CMD += ' -OutputType '+$row.OutputType}
            if($Row.DefaultPSN){$CMD += ' -DefaultParameterSetname '+$row.DefaultPSN}
            if($Row.HelpURI)   {$CMD += ' -HelpURI '+$row.HelpURI}
            # Exec CMD
            Write-Verbose $CMD
            IEX $CMD
            }
        ## Check PSN file
        $ParamSetFile = Get-ChildItem $TargetFolder | ? Name -match "^(.+)_S_CSV.csv$"
        # Stop if not found
        If($ParamSetFile -eq $Null){Write-Warning "ParamSet File Not Found.";Return}        
        Else{
            # Import CSV / Stop if invalid Headers
            $ParamSetCSV = Import-CSV $ParamSetFile | ? FunctionName -eq $F 
            # Compare headers
            $HeadList = 'FunctionName','MandatoryParam','OptionalParam','ParameterSetName'
            $Headers = ($ParamSetCSV |GM|? Membertype -eq NoteProperty).name
            If(Compare-Object -ref $HeadList -dif $Headers){Write-Warning 'Invalid ParamSet CSV.';Return}        
            }
        ## Check Param file
        $ParamFile = Get-ChildItem $TargetFolder | ? Name -match "^(.+)_P_CSV.csv$"
        # Stop if not found
        If($ParamFile -eq $Null){Write-Warning "Param File Not Found. Exiting.";Return}        
        Else{
            # Import CSV / Stop if invalid Headers
            $ParamCSV = Import-CSV $ParamFile | ? FunctionName -eq $F 
            # Compare headers
            $HeadList = 'FunctionName','ParamName','Type','Defaultvalue','Description','ValidateSet','Validaterange','ValidateCount','ValidateLength','ValidatePattern','ValidateScript','ValidateNotNull','ValidayeNotNullOrEmpty','AllowNull','AllowEmptyString','AllowEmptyCollection'
            $Headers = ($ParamCSV |GM|? Membertype -eq NoteProperty).name
            If(Compare-Object -ref $HeadList -dif $Headers){Write-Warning 'Invalid Param CSV.';Return}        
            }
        # Foreach Param in CSV
        Foreach($ParamObj in $ParamCSV){
            ## Prep data
            $Pname = $ParamObj.ParamName
            # List mandatory PSNs for this param
            [Array]$ListPSN_M = ($ParamSetCSV | ?{[Array]$_.MandatoryParam.trim().Split(' ').trim() -contains $Pname}).ParameterSetName
            # list optional PSNs for this param
            [Array]$ListPSN_O = ($ParamSetCSV | ?{[Array]$_.OptionalParam.trim().Split(' ').trim() -contains $Pname}).ParameterSetName
            # Group data
            $ParamObj | Add-Member -MemberType NoteProperty -Name PSN_M -Value $ListPSN_M
            $ParamObj | Add-Member -MemberType NoteProperty -Name PSN_O -Value $ListPSN_O
            # make full list
            [Array]$FullList = $ListPSN_M + $ListPSN_O
            ## Prep command
            # full list to string
            $FLS = ($FullList -join "','").trim() -replace "','$",''
            # String command to Create All Param/PSN with Mandatory True
            $CMD = "New-Param -name $Pname -Mandatory True -ParameterSetname '$FLS'"
            # Append other if needed
            if($ParamObj.Type){$CMD += " -Type '"+$ParamObj.Type+"'"}
            if($ParamObj.Alias){$CMD += " -Alias '"+$ParamObj.Alias+"'"}
            if($ParamObj.Position){$CMD += ""+$ParamObj.Position}
            if($ParamObj.ValueFromPipeline){$CMD += " -ValueFromPipeline $"+$ParamObj.ValueFromPipeline}
            if($ParamObj.Description){$CMD += " -Description '"+$ParamObj.Description+"'"}
            ## Run Command
            Write-Verbose $CMD
            IEX $CMD
            # Add Default value if needed
            if($ParamObj.DefaultValue){
                ## prep data
                $Val = $ParamObj.DefaultValue
                If($Val -match "True|False"){$Val = "`$$Val"}
                ElseIf($Val -is [String]){$Val = "'$Val'"}
                ## prep command
                $CMD = "Set-Param -name $Pname -DefaultValue $Val"
                ## Run Command
                Write-Verbose $CMD
                IEX $CMD
                }
            Focus-Param $Pname
            # Set Mandatory to false where needed
            foreach($S in $ListPSN_O){
                # Prep and run
                $CMD = "Set-Attribute -Mandatory False -PSN $S"
                Write-Verbose $CMD
                IEX $CMD
                Parse-Code <# TMPFIX - MISSING SOMEWHERE IN IN SET-ATTRIBUE CMDLET? or NEED FOCUS-FUNCTION SOMEWHERE? or ?? #>
                }
            # Set Parameter Validation
            ## Run if needed
            if($ParamObj.ValidateSet){
                $Val = $ParamObj.ValidateSet.trim().split(' ') -join "','"
                Set-ParamValidation -ValidateSet "$Val"
                }
            if($ParamObj.ValidateCount){
                $Val = $ParamObj.ValidateCount.trim().split(' ') -join ','
                Set-ParamValidation -ValidateCount $Val
                }
            if($ParamObj.ValidateRange){
                $Val = $ParamObj.ValidateRange.trim().split(' ')  -join ','
                Set-ParamValidation -ValidateRange $val
                }
            if($ParamObj.ValidateLength){
                $Val = $ParamObj.ValidateLength.trim().split(' ') -join ','
                Set-ParamValidation -ValidateLength $val
                }
            if($ParamObj.ValidatePattern){
                $Val = $ParamObj.ValidatePattern.trim()
                Set-ParamValidation -ValidatePattern "$Val"
                }
            if($ParamObj.ValidateScript){
                $Val = $ParamObj.ValidateScript
                Set-ParamValidation -ValidateScript {$Val}
                }
            if($ParamObj.ValidateNotNull){Set-ParamValidation -ValidateNotNull}
            if($ParamObj.ValidateNotNullOrEmpty){Set-ParamValidation -ValidateNotNullOrEmpty}
            if($ParamObj.AllowNull){Set-ParamValidation -AllowNull}
            if($ParamObj.AllowEmptyString){Set-ParamValidation -AllowEmptyString}
            if($ParamObj.AllowEmptyCollection){Set-ParamValidation -AllowEmptyCollection}
            }#EndForEach Param
        }#EndForEach Function
    Focus-Function $FunctionList[0]
    }## EOFunction

#endregion 

###################################EOF Monkey