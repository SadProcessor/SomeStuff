
#######################################################
#region CyberISEr #####################################

<#
.Synopsis
   ISE ScriptPane to oneliner utility.
.DESCRIPTION 
   So you want to invoke scriptblocks to target nodes 
   in a oneliner of less than xxx Characters?
   Ok, that's cool... Won't ask why...
   This tool can hopefuly help slaughter that cool PoSh script of
   yours and shrink it into something ugly and unreadeable.
   
   Note: This is not ObFusKaTIOn. Unformat only. 
      
.EXAMPLE
   Invoke-CyberISEr
   Shows a list of available options/switches
.EXAMPLE
   Cyber -x
   PoSh for Slang Invoke-CyberISEr -AutoRun
   Runs the full stuff in one go.
   Switch to step-by-step if errors.
.EXAMPLE
   CyberISEr -GroupRun ShortenSyntax
   Runs steps from specified group 
    - CleanLine:      ChopTail + StripComment + CropEmpty + TrashWhite 
    - ShortenSyntax:  SwapAlias + TrimParam 
    - FlattenScript:  Folds + PutSemi + MakeOne + SqueezeFinal
.EXAMPLE
   Invoke-CyberISEr -StripComment
   Single Step
.INPUTS
   ISE scriptPane
.OUTPUTS
   ISE scriptPane
.NOTES
   TIP: Undo Steps >> ctrl-Z in script pane.
   Requires PoShv3++ (Abstract Syntax Tree).
   This tool is designed for resizing scripts to oneliner, 
   for oneliner obfuscation check Invoke-Obfuscation
   by @DanielBohannon.
.FUNCTIONALITY
   ISE scriptPane to oneliner
#>
Function Invoke-CyberISEr(){
    [CmdletBinding(DefaultParameterSetName='NoParam')]
    [Alias('CyberISEr','Cyber')]
    Param(
        # Measure PayLoad > LineCount & CharLength 
        [Parameter(Position=0,Mandatory=$True,ParameterSetName='MeasureLoad')][Switch]$MeasureLoad,

        # Remove trailing white spaces
        [Parameter(Position=0,Mandatory=$True,ParameterSetName='ChopTail')][Switch]$ChopTail,
        # Remove Comments (incl. Inline/Help)
        [Parameter(Position=0,Mandatory=$True,ParameterSetName='StripComment')][Switch]$StripComment,
        # Remove Verbose commands
        [Parameter(Position=0,Mandatory=$True,ParameterSetName='StripVerbose')][Switch]$StripVerbose,
        # Remove Empty Lines
        [Parameter(Position=0,Mandatory=$True,ParameterSetName='CropEmpty')][Switch]$CropEmpty,
        # Remove superfluous inline WhiteSpace
        [Parameter(Position=0,Mandatory=$True,ParameterSetName='TrashWhite')][Switch]$TrashWhite,
        
        # Replace Commands with Alias when available
        [Parameter(Position=0,Mandatory=$True,ParameterSetName='SwapAlias')][Switch]$SwapAlias,
        # Use shortest possible Param notation 
        [Parameter(Position=0,Mandatory=$True,ParameterSetName='TrimParam')][Switch]$TrimParam,
        # Rename Variables with short random names 
        # > name length will depend on number of vars to rename
        #[Parameter(Position=0,Mandatory=$True,ParameterSetName='MaskVariable')][Switch]$MaskVariable,
        
        # Fold Parameter Binding 
        #[Parameter(Position=0,Mandatory=$True,ParameterSetName='FoldBind')][Switch]$FoldBind,
        # Fold Parameter Definition 
        #[Parameter(Position=0,Mandatory=$True,ParameterSetName='FoldParam')][Switch]$FoldDef,
        # Fold Arrays
        [Parameter(Position=0,Mandatory=$True,ParameterSetName='FoldArray')][Switch]$FoldArray,
        # Fold hashTables
        [Parameter(Position=0,Mandatory=$True,ParameterSetName='FoldHashT')][Switch]$FoldHashT,
        # Flatten Syntax
        [Parameter(Position=0,Mandatory=$True,ParameterSetName='FoldSynt')][Switch]$FoldSynt,
        # Terminate lines semi-colon where needed
        [Parameter(Position=0,Mandatory=$True,ParameterSetName='PutSemi')][Switch]$PutSemi,
        # Make One Liner > removes carriage-returns
        [Parameter(Position=0,Mandatory=$True,ParameterSetName='MakeOne')][Switch]$MakeOne,
        # Final Squeeze > last extra white space via $SqueezeKV dictionnary
        [Parameter(Position=0,Mandatory=$True,ParameterSetName='SqueezeFinal')][Switch]$SqueezeFinal,
        
        # Auto mode > Runs Default Sequence
        [Parameter(Position=0,Mandatory=$True,ParameterSetName='AutoRun')][Alias('X')][Switch]$AutoRun,
        
        # Group mode > Runs all steps of subGroup 
        # - CleanLine:      ChopTail + StripComment + StripVerbose+ CropEmpty + TrashWhite 
        # - ShortenSyntax:  SwapAlias + TrimParam + (MaskVariable) 
        # - FlattenScript:  Folds + Flat+ PutSemi + MakeOne + SqueezeFinal
        [ValidateSet("CleanLine", "ShortenSyntax", "FlattenScript")]
        [Parameter(Position=0,Mandatory=$True,ParameterSetName='GroupRun')][String]$GroupRun,


        # Base 64 encode + cmd launcher
        [Parameter(Position=1,Mandatory=$False,ParameterSetName='AutoRun')]
        [Parameter(Position=0,Mandatory=$True,ParameterSetName='EncodeB64')][Alias('B64')][Switch]$EncodeB64,

        # To ClipBoard
        [Parameter(Position=2,Mandatory=$False,ParameterSetName='AutoRun')]
        [Parameter(Position=0,Mandatory=$True,ParameterSetName='ToClipBoard')][Alias('Clip')][Switch]$ToClip
        
        )
    ##EndParam

    ## SUBs　
    ########################################### Measureload - Done
    Function MeasureLoad(){
        $Editor = $psISE.CurrentFile.Editor
        $MaxSize = 12190
        $LineCount = $Editor.LineCount
        $TextLength = $Editor.Text.Length
        $BelowMax = 'N'
        if($LineCount -eq 1 -AND $TextLength -lt $MaxSize){$BelowMax = 'Y'}
        $props = @{ 'Line' = $LineCount
                    'Char' = $TextLength
                    'OK' = $BelowMax
                    }
        $CountObj = New-Object PScustomObject -Property $props
        return $CountObj | select Line,Char,OK
        }#End
    #

    ############################################## ChopTail - Done
    Function ChopTail(){
        Write-Verbose -Message 'ChopTail     >> Removing trailing whiteSpace...'
        $Editor = $psISE.CurrentFile.Editor
        $LineCount = $Editor.LineCount
        #For each line in scriptPane
        Foreach($num in 1..$LineCount){
            # Set Position
            $Editor.SetCaretPosition($num,1)
            # Get Content
            $OldLine = $Editor.CaretLineText
            # Make a trimmed version
            $NewLine = $OldLine.TrimEnd(' ')
            #Select all & Replace Line with NewLine
            $editor.SelectCaretLine()
            $editor.InsertText($NewLine)
            }
        #Check for Error
        if(Syntax -ErrorList){Oups;Break}
        #return to top
        $Editor.SetCaretPosition(1,1)
        }#End
    #

    ########################################## StripComment - Done
    Function StripComment(){
    Write-Verbose -Message 'StripComment >> Removing Comments...'
    # Prep Editor
    $Editor = $psISE.CurrentFile.Editor
    # Get all comments and replace with nothing
    (SyntaxISEr -TokenKind Comment).extent | sort -Property EndOffset -Descending | %{
        $Editor.Select($_.StartLineNumber,$_.StartColumnNumber,$_.EndLineNumber,$_.EndColumnNumber)
        $Editor.InsertText('')
        }
    #Check for Error
    if(Syntax -ErrorList){Oups;Break}
    #Return to Top
    $Editor.SetCaretPosition(1,1)
    }#End
    #

    ########################################## StripComment - Done
    Function StripVerbose(){
        $Editor = $psISE.CurrentFile.Editor
        $Console = $psISE.CurrentPowerShellTab.ConsolePane
        $LineCount = $Editor.LineCount
        $LineCount..1 | %{
            $Editor.SetCaretPosition($_,1)
            $Editor.SelectCaretLine()
            If($Editor.SelectedText.trim() -match "^Write-Verbose*"){$Editor.InsertText('')}
            }
        $editor.SetCaretPosition(1,1)
        $Console.Focus()
        }#End
    #

    ############################################# CropEmpty - Done
    Function CropEmpty(){
    Write-Verbose -Message 'CropEmty     >> Removing Empty Lines...'
    $StringList=@()
    $Editor = $psISE.CurrentFile.Editor
    1..$Editor.LineCount | %{    
        $Editor.SetCaretPosition($_,1) 
        $Editor.SelectCaretLine()
        $ThisLine = $Editor.SelectedText
        If($ThisLine.trim() -ne ''){$StringList+=$Thisline}
        }
    $Editor.Select(1,1,$Editor.LineCount,$Editor.GetLineLength($Editor.LineCount)+1)
    $Editor.InsertText('')
    1..$StringList.count | %{
        $Editor.SetCaretPosition($_,1)
        $Editor.SelectCaretLine()
        $Editor.InsertText($StringList[$_-1]+"`r`n")
        }
    #Check for Error
    if(Syntax -ErrorList){Oups;Break}
    $Editor.text = $Editor.text.TrimEnd("`r`n")
    $Editor.SetCaretPosition(1,1)
    }#End
    #

    ############################################ TrashWhite - Done
    Function TrashWhite(){
        Write-Verbose -Message 'TrashWhite   >> Removing Extra WhiteSpace...'
        # Get Current State
        $Editor = $psISE.CurrentFile.Editor
        $LineCount = $Editor.LineCount
        #$TextLength = $Editor.Text.Length
        #For each line in scriptPane
        Foreach($num in 1..$LineCount){        
            # Set Position
            $Editor.SetCaretPosition($num,1)
            # Get actual content
            $OldLine = $Editor.CaretLineText
            # Make a copy
            $NewLine = $OldLine        
            #Check1
            IF($OldLine){
                #action1
                $NewLine = ($OldLine -replace '\s+',' ').TrimStart(' ')
                }      
            #Select all & Replace Line with NewLine
            $editor.SelectCaretLine()
            $editor.InsertText($NewLine)
            }
        # Reduce lines with only bracket
        $Editor.text = $Editor.text -replace "`r`n{`r","{`r"
        $Editor.text = $Editor.text -replace("`r`n}`r","}`r")
        #$Editor.text = $Editor.text.replace("`r`n{`r","{`r").replace("`r`n}`r","}`r")
        #$Editor.text = $Editor.text.replace("`r`n{`r","{`r").replace("`r`n}`r","}`r")
        #Check for Error
        #if(Syntax -ErrorList){Oups;Break}
        }#End
    #

    ############################################# SwapAlias - Done
    Function SwapAlias(){
    Write-Verbose -Message 'SwapAlias    >> Replacing commands with Alias...'
    # Prep Editor
    $Editor = $psISE.CurrentFile.Editor
    $List = @()
    # Get all Commands
    syntax -TreeType CommandAst | %{If($_.commandElements[0].value -in $AliasKV.Keys){$List += $_.commandElements[0]}}
    Foreach($Old in $List.extent | sort-Object -Property EndOffset -descending){
        IF($AliasKV.$Old.name.count -eq 1){$New = $AliasKV.$Old.name}
        Else{$New = $AliasKV.$Old.name[0]} 
        $Editor.Select($Old.StartLineNumber,$Old.StartColumnNumber,$Old.EndLineNumber,$Old.EndColumnNumber)
        $Editor.InsertText($New)
        }
    #Check for Error
    if(Syntax -ErrorList){Oups;Break}
    #Return to initial position
    $Editor.SetCaretPosition(1,1)
    }#End
    #

    ############################################# TrimParam - Done
    Function TrimParam(){
    Write-Verbose -Message 'TrimParam    >> Shortening Command Parameters...'
    # Prepare empty change list
    $Changelist = @()
    #Get List of commands
    $CommandList = (Syntax -TreeType CommandAst)
    # For each command
    foreach($ParentCommand in $CommandList){
        # prepare empty dictionnary
        $Dico = @{}
        # Get list of parameters
        if(get-command $ParentCommand.commandElements[0] -ErrorAction SilentlyContinue){$ParamList=(get-command $ParentCommand.commandElements[0]).Parameters.keys}
        #For each Parameter
        Foreach($Param in $ParamList -ne $Null){
            #Create short 1letter
            $i=0; $Short="$($Param[$i])"
            #While not the only one, add letter
            While((($ParamList -like "$Short*").count -ne 1) -and ($Param -ne $Short)){$i=$i+1;$Short+=$Param[$i]}
            #Once unique, add to dictionnary
            if(!$Dico.$Param){$Dico.Add("$Param","$Short")}
            }
        #Debug:
        #$Dico

        #For each parameter to replace
        foreach($Old in (syntax -TokenKind Parameter -ParentTree $ParentCommand)){
            #Populate properies
            $Props = @{ 'Name'= $Old.Parametername
                        'New' = $Dico.$($Old.Parametername)
                        'StartLine' = $old.extent.StartLineNumber
                        'StartColumn' = $old.extent.StartColumnNumber
                        'EndLine' = $old.extent.EndLineNumber
                        'EndColumn' = $old.extent.EndColumnNumber
                        'EndOffset' = $old.extent.EndOffset
                        }
            #Create object
            $Obj = New-Object PScustomObject -Property $props
            #Add to change list
            $ChangeList += $Obj
            }
    
        }
    # Debug
    #$Changelist |select -Property Name,New,StartLine,StartColumn,EndLine,EndColumn,EndOffset | sort -Property EndOffset -Descending | ft

    # Create Editor obj
    $Editor = $psISE.CurrentFile.Editor

    #For each element in changelist (/!\: Sort EndOffset Descending)
    $Changelist | where -Property New | sort -Property EndOffset -Descending | %{
        # Select Old 
        $Editor.Select($_.StartLine,$_.StartColumn,$_.EndLine,$_.EndColumn)
        # Replace with new
        $Editor.InsertText("-$($_.New)")
        }
    #Check for Error
    if(Syntax -ErrorList){Oups;Break}
    #return to top
    $Editor.SetCaretPosition(1,1)
    }#End
    #
    <#
    ########################################## MaskVariable - ToDo
    #Function MaskVariable(){'ToDo'}#End <----------------------------------/!\:FIX
    #

    ########################################### FoldBinding - ToDo
    Function FoldBind(){
    Write-Verbose -Message 'FoldBind     >> Flattening CmdletBindings...'
    # Create Editor obj
    $Editor = $psISE.CurrentFile.Editor
    # Create empty change list
    $ChangeList = @()
    # Get All functions
    $ParentFList = syntax -TreeType FunctionDefinitionAst
    # For each
    Foreach($ParentF in $ParentFList){
        $Old = (Syntax -TreeType NamedAttributeArgumentAst -ParentTree $ParentF)[0].Parent.extent
        $StartL = $old.StartLineNumber
        $StartC = $old.StartColumnNumber
        $EndL = $old.EndLineNumber
        $EndC = $old.EndColumnNumber
        $EndOffset = $old.EndOffset

        If($StartL -ne $EndL){
            #Rebuild
            $NewText = $old.text.replace("`r`n",'') -replace '\s+',' '
            #Debug
            #$NewText
            # Create Obj
            $Props = @{
                        'EndOffset'= $EndOffset
                        'StartL'= $StartL
                        'StartC' = $StartC
                        'EndL' = $EndL
                        'EndC' = $endC
                        'NewText' = $newText
                        }
            $Obj = New-Object PSCustomObject -Property $props
            $ChangeList += $Obj
            }
    }

    # Debug
    #$ChangeList | select EndOffset,StartL,StartC,EndL,EndC,NewText | sort EndOffset -Descending | ft



    #For each element in changelist (/!\: Sort EndOffset Descending)
    $Changelist | sort -Property EndOffset -Descending | %{
        # Select Old 
        $Editor.Select($_.StartL,$_.StartC,$_.EndL,$_.EndC)
        # Replace with new
        $Editor.InsertText($_.NewText)
        }
    #Check for Error
    #if(Syntax -ErrorList){Oups;Break}
    #return to top
    $Editor.SetCaretPosition(1,1)

    }#End <-----------------------------------------/!\:FIX
    #

    ############################################### FoldDef - ToDo
    Function FoldDef(){
    Write-Verbose -Message 'FoldDef      >> Flattening Parameter Definitions...'
    # Create Editor obj
    $Editor = $psISE.CurrentFile.Editor
    # Create empty change list
    $ChangeList = @()
    # Get All functions
    $ParentFList = syntax -TreeType FunctionDefinitionAst
    # For each
    Foreach($ParentF in $ParentFList){
        # Prep empty new text
        $New = ''
        # Get ParamBlock
        $PBlock = (Syntax -TreeType ParamBlockAst -ParentTree $ParentF).Extent.text.replace("`r`n",'').replace(' ','')
        # Get Attributes
        $Attr = ((Syntax -TreeType AttributeAst -ParentTree $ParentF) | ?{$_.TypeName.Fullname -ne 'Parameter'})
        #Safety Check
        #IF(($Attr.Parent | sort -Unique).count -ne 1){Oups;Break}
        # Get Location
        $StartL = $Attr[0].extent.StartLineNumber
        $StartC = $Attr[0].extent.StartColumnNumber
        $EndL = $Attr[0].parent.extent.EndLineNumber
        $EndC = $Attr[0].parent.extent.EndColumnNumber
        $EndOffset = $Attr[0].parent.extent.EndOffset
        #If MultiLine
        If($StartL -ne $EndL){
            #Rebuild
            $Attr | %{$New += "$($_.extent.text)"}
            $New += $PBlock
            #Debug
            #$New
            # Create Obj
            $Props = @{
                        'EndOffset'= $EndOffset
                        'StartL'= $StartL
                        'StartC' = $StartC
                        'EndL' = $EndL
                        'EndC' = $endC
                        'New' = $new
                        }
            $Obj = New-Object PSCustomObject -Property $props
            $ChangeList += $Obj
            }
        }

    # Debug
    #$ChangeList | select EndOffset,StartL,StartC,EndL,EndC,New | sort EndOffset -Descending | ft

    #For each element in changelist (/!\: Sort EndOffset Descending)
    $Changelist | sort -Property EndOffset -Descending | %{
        # Select Old 
        $Editor.Select($_.StartL,$_.StartC,$_.EndL,$_.EndC)
        # Replace with new
        $Editor.InsertText($_.New)
        }
    #Check for Error
    #if(Syntax -ErrorList){Oups;Break}
    #return to top
    $Editor.SetCaretPosition(1,1)

    }#End <------------------------------------------/!\:FIX
    #
    #>

    ############################################# FoldArray - Done
    Function FoldArray(){
    Write-Verbose -Message 'FoldArray    >> Flattening Arrays...'
    # Create Editor obj
    $Editor = $psISE.CurrentFile.Editor
    # Create empty Change list
    $ChangeList = @()
    # Get Multi-Line Arrays 
    $ArrayList = syntax -TreeType ArrayExpressionAst | where {$_.Extent.StartLineNumber -ne $_.Extent.EndLineNumber}
    # For Each
    foreach($Array in $ArrayList){
        # Get Location
        $StartL = $Array.Extent.StartLineNumber
        $StartC = $Array.Extent.StartColumnNumber
        $EndL = $Array.Extent.EndLineNumber
        $EndC = $Array.Extent.EndColumnNumber
        $EndOffset = $Array.Extent.EndOffset
        # Rewrite Array
        $Items = $Array.Subexpression.Statements.Extent.Text
        $New = '@('
        $Items | %{$New += "$_,"}
        # Replace last comma 
        $New = $New.remove($New.LastIndexOf(',')) + ')'
        # Create Object
        $Props = @{'EndOffset'=$EndOffset;'StartLine'=$StartL;'StartColumn'=$StartC;'Endline'=$EndL;'EndColumn'=$EndC;'New'=$New}
        $Obj = New-Object PSCustomObject -Property $Props
        # Add too change List
        $ChangeList += $Obj
    }
    # Debug
    #$ChangeList | Select -Property EndOffset,StartLine,StartColumn,EndLine,EndColumn,New | sort EndOffset -Descending | ft

    # Create Editor obj
    $Editor = $psISE.CurrentFile.Editor

    #For each element in changelist (/!\: Sort EndOffset Descending)
    $Changelist | sort -Property EndOffset -Descending | %{
        # Select Old 
        $Editor.Select($_.StartLine,$_.StartColumn,$_.EndLine,$_.EndColumn)
        # Replace with new
        $Editor.InsertText($_.New)
        }
    #Check for Error
    if(Syntax -ErrorList){Oups;Break}
    #return to top
    $Editor.SetCaretPosition(1,1)

    }#End
    #

    ############################################# FoldHashT - Done
    Function FoldHashT(){
    Write-Verbose -Message 'FoldHashT    >> Flattening HashTables...'
    # Create Editor obj
    $Editor = $psISE.CurrentFile.Editor
    # Create empty Change list
    $ChangeList = @()
    # Get Multi-Line Arrays 
    $HashTList = syntax -TreeType HashTableAst | where {$_.Extent.StartLineNumber -ne $_.Extent.EndLineNumber}
    # For Each
    foreach($HashT in $HashTList){
        # Get Location
        $StartL = $HashT.Extent.StartLineNumber
        $StartC = $HashT.Extent.StartColumnNumber
        $EndL = $HashT.Extent.EndLineNumber
        $EndC = $HashT.Extent.EndColumnNumber
        $EndOffset = $HashT.Extent.EndOffset
        # Rewrite Array
        $Num = $HashT.KeyValuePairs.count
        $New = '@{'
        0..($Num -1) | %{
        $Key = $HashT.KeyValuePairs.Item1.Extent.text[$_]
        $Value = $HashT.KeyValuePairs.Item2.Extent.text[$_]
        $New += "$Key=$Value;"
        }
        # Replace last comma 
        $New = $New.remove($New.LastIndexOf(';')) + '};'
        # Create Object
        $Props = @{'EndOffset'=$EndOffset;'StartLine'=$StartL;'StartColumn'=$StartC;'Endline'=$EndL;'EndColumn'=$EndC;'New'=$New}
        $Obj = New-Object PSCustomObject -Property $Props
        # Add too change List
        $ChangeList += $Obj
    }
    # Debug
    #$ChangeList | Select -Property EndOffset,StartLine,StartColumn,EndLine,EndColumn,New | sort EndOffset -Descending | ft

    # Create Editor obj
    $Editor = $psISE.CurrentFile.Editor

    #For each element in changelist (/!\: Sort EndOffset Descending)
    $Changelist | sort -Property EndOffset -Descending | %{
        # Select Old 
        $Editor.Select($_.StartLine,$_.StartColumn,$_.EndLine,$_.EndColumn)
        # Replace with new
        $Editor.InsertText($_.New)
        }
    #Check for Error
    if(Syntax -ErrorList){Oups;Break}
    #return to top
    $Editor.SetCaretPosition(1,1)
    }#End
    #

    ############################################# FoldHashT - Done
    Function FoldSynt(){
        function Bindings(){
        $Editor = $psISE.CurrentFile.Editor
        $Console = $psISE.CurrentPowerShellTab.ConsolePane
        #Get list of CmdletBinding Attritues
        $BindingList = syntax -TreeType AttributeAst | ? -Property TypeName -match 'CmdletBinding'
        #If BindingList
        If($BindingList){
            $ChangeList = @()
            foreach($Bind in $BindingList){
                #Create Change Object props
                $Props = @{
                    'EndOffset' = $Bind.Extent.Endoffset
                    'StartOffset' = $Bind.Extent.StartOffset
                    'StartLine' = $Bind.Extent.StartLineNumber
                    'StartColn' = $Bind.Extent.StartColumnNumber
                    'EndLine' = $Bind.Extent.EndLineNumber
                    'EndColn' = $Bind.Extent.EndColumnNumber
                    'OldText' = $Bind.Extent.Text
                    'NewText' = $Bind.Extent.Text.split("`r`n").trim()-join''
                    }
                #Create ChangeObject
                $ChangeObject = New-Object PSCustomObject -Property $props
                #Add to ChageList
                $ChangeList += $ChangeObject
                }
            #Make Changes
            $ChangeList | sort -Property EndOffset -Descending | foreach{
                $Editor.Select($_.StartLine,$_.StartColn,$_.EndLine,$_.EndColn)
                $Editor.InsertText("$($_.Newtext)")
                }
            }
        $Editor.SetCaretPosition($editor.CaretLine,1)
        $Console.Focus()
        }



        function Params(){
            $Editor = $psISE.CurrentFile.Editor
            $Console = $psISE.CurrentPowerShellTab.ConsolePane
            #Get list of CmdletBinding Attritues
            $ParamList = Syntax -TreeType ParameterAst
            #If BindingList
            If($ParamList){
                $ChangeList = @()
                foreach($Prm in $ParamList){
                    #Create Change Object props
                    $Props = @{
                        'EndOffset' = $Prm.Extent.Endoffset
                        'StartOffset' = $Prm.Extent.StartOffset
                        'StartLine' = $Prm.Extent.StartLineNumber
                        'StartColn' = $Prm.Extent.StartColumnNumber
                        'EndLine' = $Prm.Extent.EndLineNumber
                        'EndColn' = $Prm.Extent.EndColumnNumber
                        'OldText' = $Prm.Extent.Text
                        'NewText' = $Prm.Extent.Text.split("`r`n").trim()-join''
                        }
                    #Create ChangeObject
                    $ChangeObject = New-Object PSCustomObject -Property $props
                    #Add to ChangeList
                    $ChangeList += $ChangeObject
                    }
                #Make Changes
                $ChangeList | sort -Property EndOffset -Descending | foreach{
                    $Editor.Select($_.StartLine,$_.StartColn,$_.EndLine,$_.EndColn)
                    $Editor.InsertText("$($_.Newtext)")
                    }
                }
            $Editor.SetCaretPosition($editor.CaretLine,1)
            $Console.Focus()
            }


        function ParamBlocks(){
            $Editor = $psISE.CurrentFile.Editor
            $Console = $psISE.CurrentPowerShellTab.ConsolePane
            #Get list of CmdletBinding Attritues
            $ParamBlockList = syntax -TreeType ParamBlockAst
            #If BindingList
            If($ParamBlockList){
                $ChangeList = @()
                foreach($Blk in $ParamBlockList){
                    #Create Change Object props
                    $Props = @{
                        'EndOffset' = $Blk.Extent.Endoffset
                        'StartOffset' = $Blk.Extent.StartOffset
                        'StartLine' = $Blk.Extent.StartLineNumber
                        'StartColn' = $Blk.Extent.StartColumnNumber
                        'EndLine' = $Blk.Extent.EndLineNumber
                        'EndColn' = $Blk.Extent.EndColumnNumber
                        'OldText' = $Blk.Extent.Text
                        'NewText' = $Blk.Extent.Text.split("`r`n").trim()-join''
                        }
                    #Create ChangeObject
                    $ChangeObject = New-Object PSCustomObject -Property $props
                    #Add to ChageList
                    $ChangeList += $ChangeObject
                    }
                #Make Changes
                $ChangeList | sort -Property EndOffset -Descending | foreach{
                    $Editor.Select($_.StartLine,$_.StartColn,$_.EndLine,$_.EndColn)
                    $Editor.InsertText("$($_.Newtext)")
                    }
                }
            $Editor.SetCaretPosition($editor.CaretLine,1)
            $Console.Focus()
            }

        function TryStatements(){
            $Editor = $psISE.CurrentFile.Editor
            $Console = $psISE.CurrentPowerShellTab.ConsolePane
            #Get list of CmdletBinding Attritues
            $TryStatList = syntax -TreeType TryStatementAst
            #If BindingList
            If($TryStatList){
                $ChangeList = @()
                foreach($Try in $TryStatList){
                    # Format new Text
                    $New = $Try.Extent.text.replace("Try","try").replace("Catch","catch").replace("Finally","finally").replace("Throw",'throw')
                    #$New =  $New.replace("`r`n{","{").replace("`r`n}","}").replace("`r`nfinally","finally").replace("`r`ncatch","catch")
                    $New = ($New.replace("`r`ncatch",'catch').replace("`r`nfinally",'finally') -replace "`r`nthrow","throw").replace("catch {",'catch{').replace("finally {",'finally').replace("try {","try{").replace("try{`r`n","try{")
                    #Create Change Object props
                    $Props = @{
                        'EndOffset' = $Try.Extent.Endoffset
                        'StartOffset' = $Try.Extent.StartOffset
                        'StartLine' = $Try.Extent.StartLineNumber
                        'StartColn' = $Try.Extent.StartColumnNumber
                        'EndLine' = $Try.Extent.EndLineNumber
                        'EndColn' = $Try.Extent.EndColumnNumber
                        'OldText' = $Try.Extent.Text
                        'NewText' = "$New"
                        }
                    #Create ChangeObject
                    $ChangeObject = New-Object PSCustomObject -Property $props
                    #Add to ChageList
                    $ChangeList += $ChangeObject
                    }
                #Make Changes
                $ChangeList | sort -Property EndOffset -Descending | foreach{
                    $Editor.Select($_.StartLine,$_.StartColn,$_.EndLine,$_.EndColn)
                    $Editor.InsertText("$($_.Newtext)")
                    }
                }
            $Editor.SetCaretPosition($editor.CaretLine,1)
            $Console.Focus()
            }


        function IfStatements(){
            $Editor = $psISE.CurrentFile.Editor
            $Console = $psISE.CurrentPowerShellTab.ConsolePane
            #Get list of CmdletBinding Attritues
            $IfStatList = syntax -TreeType IfStatementAst
            #If BindingList
            If($IfStatList){
                $ChangeList = @()
                foreach($IfSt in $IfStatList){
                    # Format new Text
                    $New = $IfSt.Extent.text.replace("If","if").replace("ElseIf","elseif").replace("Elseif","elseif").replace("Else","else")
                    #$New =  $New.replace("`r`n{","{").replace("`r`n}","}").replace("`r`nElseIf","ElseIf").replace("`r`nElse","Else")
                    $New = ($New.replace("`r`nelseif",'elseif').replace("`r`nelse",'else') -replace "`r`nelseif","else").replace("if {",'if{').replace("elseif {",'elseif').replace("else {","else{")
                    
                    #Create Change Object props
                    $Props = @{
                        'EndOffset' = $IfSt.Extent.Endoffset
                        'StartOffset' = $IfSt.Extent.StartOffset
                        'StartLine' = $IfSt.Extent.StartLineNumber
                        'StartColn' = $IfSt.Extent.StartColumnNumber
                        'EndLine' = $IfSt.Extent.EndLineNumber
                        'EndColn' = $IfSt.Extent.EndColumnNumber
                        'OldText' = "$IfSt.Extent.Text"
                        'NewText' = "$New"
                        }
                    #Create ChangeObject
                    $ChangeObject = New-Object PSCustomObject -Property $props
                    #Add to ChageList
                    $ChangeList += $ChangeObject
                    }
                #Make Changes
                $ChangeList | sort -Property EndOffset -Descending | foreach{
                    $Editor.Select($_.StartLine,$_.StartColn,$_.EndLine,$_.EndColn)
                    $Editor.InsertText("$($_.Newtext)")
                    $Editor.SetCaretPosition($editor.CaretLine,1)
                    }
                }
            $Editor.SetCaretPosition($editor.CaretLine,1)
            $Console.Focus()
            }


function FoldBlocks{

# Editor
$editor = $psISE.CurrentFile.Editor

# remove empty lines
while($editor.text -match "`r`n`r`n"){$editor.text = $editor.Text -replace "`r`n`r`n","`r`n"}


# remove only curly on line
while($editor.text -match "`r`n{`r`n"){$editor.text = $editor.Text -replace "`r`n{`r`n","{`r`n"}
while($editor.text -match "`r`n}`r`n"){$editor.text = $editor.Text -replace "`r`n}`r`n","}`r`n"}



# Try Blocks
$editor.text = $editor.Text -ireplace "try",'try'
$editor.text = $editor.Text -ireplace "catch",'catch'
$editor.text = $editor.Text -ireplace "throw",'throw'
$editor.text = $editor.Text -ireplace "finally",'finally'
while($editor.text -match "`r`ncatch"){$editor.text = $editor.Text -ireplace "`r`ncatch","catch"}
while($editor.text -match "`r`nthrow"){$editor.text = $editor.Text -ireplace "`r`nthrow",";throw"}
while($editor.text -match "`r`nfinally"){$editor.text = $editor.Text -ireplace "`r`nfinally","finally"}


# if Blocks
$editor.text = $editor.Text -ireplace "if",'if'
$editor.text = $editor.Text -ireplace "elseif",'elseif'
$editor.text = $editor.Text -ireplace "else",'else'
while($editor.text -match "`r`nelseif"){$editor.text = $editor.Text -replace "`r`nelseif","elseif"}
while($editor.text -match "`r`nelse"){$editor.text = $editor.Text -replace "`r`nelse",'else'}

}



        Function FuncAttribParam(){
            $Editor = $psISE.CurrentFile.Editor
            $Console = $psISE.CurrentPowerShellTab.ConsolePane
            #Get list of CmdletBinding Attritues
            $BindingList = syntax -TreeType AttributeAst | ? -Property TypeName -match 'CmdletBinding'
            #If BindingList
            If($BindingList){
                $ChangeList = @()
                foreach($Bind in $BindingList){
                $NewText = @()
                $Part1 = "$($Bind.Extent.text)"
                $Part2 = "$($Bind.Parent.Extent.text)"
                $OldText = $Part1 + $Part2
                $NewText = $OldText.split("`r`n").trim()-join''
                #Create Change Object props
                $Props = @{
                        'EndOffset' = $Bind.Parent.Extent.Endoffset
                        'StartOffset' = $Bind.Extent.StartOffset
                        'StartLine' = $Bind.Extent.StartLineNumber
                        'StartColn' = $Bind.Extent.StartColumnNumber
                        'EndLine' = $Bind.Parent.Extent.EndLineNumber
                        'EndColn' = $Bind.Parent.Extent.EndColumnNumber
                        'OldText' = "$OldText"
                        'NewText' = "$NewText"
                        }
                #Create ChangeObject
                $ChangeObject = New-Object PSCustomObject -Property $props
                #Add to ChageList
                $ChangeList += $ChangeObject
                }
                #Make Changes
                $ChangeList | sort -Property EndOffset -Descending | foreach{
                    $Editor.Select($_.StartLine,$_.StartColn,$_.EndLine,$_.EndColn)
                    $Editor.InsertText("$($_.Newtext)")
                    }
                }
            $Editor.SetCaretPosition($editor.CaretLine,1)
            $Console.Focus()
            }
 
 
        function DefFinal{
            $Editor = $psISE.CurrentFile.Editor
            $Console = $psISE.CurrentPowerShellTab.ConsolePane
            $Text = $Editor.Text
            $NewText = $Text -replace "\r\n\[CmdletBinding","[CmdletBinding"
            $NewText = $NewText -replace "\r\n\[Alias","[Alias"
            $NewText = $NewText -replace "\r\n\[OutputType","[OutputType"
            $NewText = $NewText -replace "\r\nParam","Param"
            $Editor.Text = "$NewText"
            $Console.focus()
            }
        #Action
        Bindings
        Params
        ParamBlocks
        FoldBlocks
        DefFinal

    }#End
    #

    ############################################### PutSemi - Done
    Function PutSemi(){
    Write-Verbose -Message 'PutSemi      >> Adding SemiColons'
    # Get Editor
    $Editor = $psISE.CurrentFile.Editor 
    # Get line count
    $Num = $Editor.LineCount

    # For each line
    $Num..1 | %{
    
        #Select
        $Editor.SetCaretPosition($_,1)
        $Editor.SelectCaretLine()
        $Selection = $Editor.SelectedText
    
        # If not empty line
        If($Selection -ne ''){
            #Get last char
            $LastChar = $Selection.trimEnd(' ')[$Selection.length - 1]
        
            #Debug 
            #$lastChar
        
            # If not auth, add semi
            IF($LastChar -notin $NoSemiList){
                $Editor.SetCaretPosition($_,$Selection.length + 1)
                $Editor.InsertText(';')
            }
        }
    }
    #Check for Error
    if(Syntax -ErrorList){Oups;Break}
    # Return to top
    $Editor.SetCaretPosition(1,1)
    }#End
    #

    ############################################### MakeOne - Done
    function MakeOne{
    Write-Verbose -Message 'MakeOne      >> Folding to OneLiner...'
    $OneLiner=''
    $Editor = $psISE.CurrentFile.Editor
    1..$Editor.LineCount | %{    
        $Editor.SetCaretPosition($_,1)    
        $Editor.SelectCaretLine()    
        $ThisLine = $Editor.SelectedText    
        If($ThisLine.trim() -ne ''){$OneLiner += $ThisLine}
        }
    $Editor.Select(1,1,$Editor.LineCount,$Editor.GetLineLength($Editor.LineCount)+1)
    $Editor.InsertText($OneLiner)
    #Check for Error
    if(Syntax -ErrorList){Oups;Break}
    $Editor.SetCaretPosition(1,1)
    }#End
    #

    ########################################## SqueezeFinal - ToDo <---- Update List SqueezeKV
    Function SqueezeFinal(){
    Write-Verbose -Message 'SqueezeFinal >> Removing Last stuff...'
    $Editor=$psISE.CurrentFile.Editor
    foreach($Key in $SqueezeKV.Keys){if($Editor.text -match $Key){$Editor.text=$Editor.text.replace($Key,$($SqueezeKV.$key)).trimEnd(';5')}}
    #Check for Error
    if(Syntax -ErrorList){Oups;Break}
    $Editor.SetCaretPosition(1,1)
    }#End
    #

    ############################################# EncodeB64 - Done
    Function EncodeB64(){
    #Check IsOneLiner
    $Editor = $psISE.CurrentFile.Editor
    #If not >> error
    if($Editor.LineCount -ne 1){write-host 'Computer Says No... OneLiner Needed.';Break}
    #Else do it
    Else{$Text = $Editor.Text
        $Base64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UNICODE.GetBytes($Text))
        $Editor.Text = 'powershell.exe -enc ' + $base64
        }
    $Editor.SetCaretPosition(1,1)
    }
    #

    ############################################### AutoRun - Done
    Function AutoRun(){     ChopTail 
                            StripComment
                            StripVerbose 
                            CropEmpty 
                            TrashWhite
                            
                            SwapAlias
                            TrimParam 
                            <#MaskVariable#>
                            
                            #FoldBind
                            #FoldDef
                            FoldArray
                            FoldHashT
                            FoldSynt
                            PutSemi 
                            MakeOne
                            SqueezeFinal 
                            }#End
    #

    ################################################ ToClip - TEST
    Function ToClip(){
    $Editor = $psISE.CurrentFile.Editor
    $Editor.Text | Set-Clipboard
    $Editor.SetCaretPosition(1,1)
    }
    #

    ################################################# Oups!
    Function Oups{
        $Intro = @(
            'Computer says no...',
            'Daddy, I need your help...',
            '...Do you fancy DIY?',
            'Sorry man, I broke your stuff...',
            'Houston, we have a problem...',
            'Oups! I did it again...') | Get-Random
        $Err = (Syntax -ErrorList)[0].message
        $PosL = (Syntax -ErrorList)[0].extent.StartLineNumber
        $PosC = (Syntax -ErrorList)[0].extent.StartColumnNumber    
        $Message = @("
    `r`n
     $Intro
     > $Err
            /
      ¯\_(ツ)_/¯
    `r`n  
    ")
        Write-host $Message -ForegroundColor Magenta
        $Editor.SetCaretPosition($PosL,$PosC+1)
    }#End
    #

    ## Dictionaries
    # Collections of things for stuffs 
    #

    ## Common Alias Dictionnary
    # Create Alias (BuiltIn) Dictionnary
    $AliasKV = Get-Alias | Where-Object {$_.Options -Match "ReadOnly"} | Group -Prop ResolvedCommand -AsH -AsS

　
    ## 2Letter Combo Names (max 400)
    # > MaskVariables - Will Select X random Names from list
    $Combo = $null
    $Alphab = 100..119 | ForEach {[char]$_}
    Foreach($Ltr1 in $Alphab){Foreach ($Ltr2 in $Alphab){[array]$Combo += "$Ltr1$Ltr2"}}

　
    ## System vars - No Rename 
    # > Maskvariables - Will not be renamed if in list
    # Gerenrate List: (ls variable:).name -join "','" | Set-Clipboard
    $InvarVars = @('$',
    '_',
    '?',
    '^',
    'args',
    'ConfirmPreference',
    'ConsoleFileName',
    'DebugPreference',
    'Error',
    'ErrorActionPreference',
    'ErrorView',
    'ExecutionContext',
    'false',
    'FormatEnumerationLimit',
    'HOME',
    'Host',
    'InformationPreference',
    'input',
    'MaximumAliasCount',
    'MaximumDriveCount',
    'MaximumErrorCount',
    'MaximumFunctionCount',
    'MaximumHistoryCount',
    'MaximumVariableCount',
    'MyInvocation',
    'NestedPromptLevel',
    'null',
    'OutputEncoding',
    'PID',
    'PROFILE',
    'ProgressPreference',
    'PSBoundParameters',
    'PSCommandPath','PSCulture',
    'PSDefaultParameterValues',
    'PSEmailServer',
    'PSHOME',
    'PSScriptRoot',
    'PSSessionApplicationName',
    'PSSessionConfigurationName',
    'PSSessionOption',
    'PSUICulture',
    'PSVersionTable',
    'PWD',
    'ShellId',
    'StackTrace',
    'true',
    'VerbosePreference',
    'WarningPreference',
    'WhatIfPreference')


　
    ## Allowed string Endings without Semi  - List 
    #  > PutSemi - If value found, Will not add semicolon
    $NoSemiList = @(';','{','','`','=','|',',')
    #

　
    ## Superfluous syntax rules - KV
    #  > FinalSqueeze  - if key found, will replace Key with matching Value
    $SqueezeKV = @{
    ###################
    ';;'   = ';'
    '};}'  = '}}'
    ';}'   = '}'
    ###################
    ' = '  = '='
    ' ='   = '='
    '= '   = '='
    ###################
    ' \+\= '  = '+='
    '\+\= '   = '+='
    ' \+\='   = '+='
    ###################
    ' -= '  = '-='
    '-= '   = '-='
    ' -='   = '-='
    ###################
    'Foreach{'  = '%{'
    'Foreach {' = '%{'
    '% {'       = '%{'
    ###################
    'Where{'   = '?{'
    'Where {'  = '?{'
    '\? {'     = '?{'
    ###################
    }
    #

    ## IfBlock
    # Utility Stuff
    IF($PSCmdlet.ParameterSetName -eq 'NoParam'){Get-Help Invoke-CyberISEr}
    If($MeasureLoad){MeasureLoad}
    
    # Full Stuff
    If($AutoRun){MeasureLoad; AutoRun; MeasureLoad}
    
    # CleanLine Stuff
    If($ChopTail){MeasureLoad; ChopTail; MeasureLoad}
    If($StripComment){MeasureLoad; StripComment; MeasureLoad}
    If($StripVerbose){MeasureLoad; StripVerbose; MeasureLoad}
    If($CropEmpty){MeasureLoad; CropEmpty; ChopTail; MeasureLoad}
    If($TrashWhite){MeasureLoad; TrashWhite; MeasureLoad}
    If($GroupRun -eq 'CleanLine'){MeasureLoad;ChopTail;StripComment;StripVerbose;CropEmpty;TrashWhite;MeasureLoad}
    
    # ShortenSyntax Stuff
    If($SwapAlias){MeasureLoad; SwapAlias; MeasureLoad}
    If($TrimParam){MeasureLoad; TrimParam; MeasureLoad}
    #If($MaskVariable){MeasureLoad; MaskVariable; MeasureLoad} #<----------------------------------------/!\:FIX
    If($GroupRun -eq 'ShortenSyntax'){MeasureLoad;SwapAlias;TrimParam;<#MaskVariable#>;MeasureLoad}
    
    # FlattenScript Stuff
    #If($FoldBind){MeasureLoad; FoldBind; MeasureLoad} #<------------------------------------------------/!\:FIX
    #If($FoldDef){MeasureLoad; FoldDef; MeasureLoad} #<--------------------------------------------------/!\:FIX
    If($FoldArray){MeasureLoad; FoldArray; MeasureLoad}
    If($FoldHashT){MeasureLoad; FoldHashT; MeasureLoad}
    if($FoldSynt){MeasureLoad; FoldSynt; MeasureLoad}
    If($PutSemi){MeasureLoad; PutSemi; MeasureLoad}
    If($MakeOne){MeasureLoad; MakeOne; MeasureLoad}
    If($SqueezeFinal){MeasureLoad; SqueezeFinal; MeasureLoad}
    If($GroupRun -eq 'FlattenScript'){MeasureLoad;<#FoldBind;FoldDef;#>FoldArray;FoldHashT;FoldSynt;PutSemi;MakeOne;SqueezeFinal;MeasureLoad}
    
    # B64
    IF($EncodeB64){MeasureLoad; EncodeB64; MeasureLoad}
    #
    IF($ToClip){ToClip}
    # Back to Console
    $Console = $psISE.CurrentPowerShellTab.ConsolePane
    $Console.focus()
    ## Action: Subs
    #

    ## Output: Subs
    #
    }

#endregion MainFunction
#######################################################

