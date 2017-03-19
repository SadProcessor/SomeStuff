#######################################################
#region SyntaxISEr ####################################

## Function Invoke-SyntaxISEr
## BackBone Tool for Invoke-CyberISEr & Co

<#
.Synopsis
   ISE ScriptPane Explorer
.DESCRIPTION
   ISE ScriptPane Content Exploration Utility.
   Returns ASTree Elements, Tokens and Errors from Current ISE ScriptPane.
.EXAMPLE
   Invoke-SyntaxISEr -Tree
   Returns full Abstract Syntax Tree of Current ScriptPane
.EXAMPLE
   Invoke-SyntaxISEr -TokenKindList
   Returns a list of tokens present in current ISE Scriptpane
.EXAMPLE
   Invoke-SyntaxISEr -TokenKind Comment
   Returns all Comment Tokens
.EXAMPLE
   (SyntaxISEr -TreeType FunctionDefinitionAst)[1]
   Returns Second Function Definition Ast
.EXAMPLE
   $ParentTree = (SyntaxISEr -TreeType FunctionDefinitionAst)[1]; SyntaxISEr -TokenKind Comment -ParentTree $ParentTree 
   Returns all Comment Tokens from the second function in Scriptpane
.EXAMPLE   
   SyntaxISEr -ErrorList
   Returns Errors
.INPUTS
   ISE ScriptPane
.OUTPUTS
   Language: ASTree Obj | Token Obj | Error obj
   Use object .extent props to set Editor caret selection and manipulate content.
   Note: Sort Descending before editing multiple tokens (Foreach) 
         or things will get out of position.
.NOTES
   Requires PoSh v3+ (Abstract Syntax Tree)
.ROLE
   BackBone for Invoke-CyberISEr.
.FUNCTIONALITY
   ISE ScriptPane Content to PoSh Objects for further manipulation.
#>
function Invoke-SyntaxISEr{

    [CmdletBinding(DefaultParameterSetName='NoParam')]
    [Alias('SyntaxISEr','Syntax')]
    Param(
        
        # Show Full Tree
        [Parameter(Position=0,Mandatory=$true,ParameterSetName='TreeAll')]
        [Switch]$Tree,
        
        # Show Tree with selected TreeType
        [Parameter(Position=0,Mandatory=$true,ParameterSetName='TreeByType')]
        [ValidateSet('ArrayExpressionAst',
                'ArrayLiteralAst',
                'AssignmentStatementAst',
                'Ast',
                'AttributeAst',
                'AttributeBaseAst',
                'AttributedExpressionAst',
                'BaseCtorInvokeMemberExpressionAst',
                'BinaryExpressionAst',
                'BlockStatementAst',
                'BreakStatementAst',
                'CatchClauseAst',
                'CommandAst',
                'CommandBaseAst',
                'CommandElementAst',
                'CommandExpressionAst',
                'CommandParameterAst',
                'ConfigurationDefinitionAst',
                'ConstantExpressionAst',
                'ContinueStatementAst',
                'ConvertExpressionAst',
                'DataStatementAst',
                'DoUntilStatementAst',
                'DoWhileStatementAst',
                'DynamicKeywordStatementAst',
                'ErrorExpressionAst',
                'ErrorStatementAst',
                'ExitStatementAst',
                'ExpandableStringExpressionAst',
                'ExpressionAst',
                'FileRedirectionAst',
                'ForEachStatementAst',
                'ForStatementAst',
                'FunctionDefinitionAst',
                'FunctionMemberAst',
                'HashtableAst',
                'IfStatementAst',
                'IndexExpressionAst',
                'InvokeMemberExpressionAst',
                'LabeledStatementAst',
                'LoopStatementAst',
                'MemberAst',
                'MemberExpressionAst',
                'MergingRedirectionAst',
                'NamedAttributeArgumentAst',
                'NamedBlockAst',
                'ParamBlockAst',
                'ParameterAst',
                'ParenExpressionAst',
                'PipelineAst',
                'PipelineBaseAst',
                'PropertyMemberAst',
                'RedirectionAst',
                'ReturnStatementAst',
                'ScriptBlockAst',
                'ScriptBlockExpressionAst',
                'StatementAst',
                'StatementBlockAst',
                'StringConstantExpressionAst',
                'SubExpressionAst',
                'SwitchStatementAst',
                'ThrowStatementAst',
                'TrapStatementAst',
                'TryStatementAst',
                'TypeConstraintAst',
                'TypeDefinitionAst',
                'TypeExpressionAst',
                'UnaryExpressionAst',
                'UsingExpressionAst',
                'UsingStatementAst',
                'VariableExpressionAst',
                'WhileStatementAst')]
        [String]$TreeType,

        # List Tree Types
        [Parameter(Position=0,Mandatory=$true,ParameterSetName='ListTreeType')] 
        [Switch]$TreeTypeList,

　
        # Show All Tokens
        [Parameter(Position=0,Mandatory=$true,ParameterSetName='TokenAll')]
        [Switch]$Token,        
        # Show Tokens with selected TokenFlag
        [Parameter(Position=0,Mandatory=$true,ParameterSetName='TokenByFlag')]
        [System.Management.Automation.Language.TokenFlags]$TokenFlag,
        # List Token Flags
        [Parameter(Position=0,Mandatory=$true,ParameterSetName='ListTokenFlag')] 
        [Switch]$TokenFlagList,
        # Show Tokens with selected TokenKind
        [Parameter(Position=0,Mandatory=$true,ParameterSetName='TokenByKind')]
        [System.Management.Automation.Language.TokenKind]$TokenKind,
        # List Token Kind
        [Parameter(Position=0,Mandatory=$true,ParameterSetName='ListTokenKind')] 
        [Switch]$TokenKindList,
       
        # Show Errors
        [Parameter(Position=0,Mandatory=$true,ParameterSetName='ErrorAll')]
        [Switch]$ErrorList,        
        
       
        # Restrict search to parent AST scope
        [Parameter(Mandatory=$false,ParameterSetName='TokenAll')]
        [Parameter(Mandatory=$false,ParameterSetName='ListTokenFlag')]
        [Parameter(Mandatory=$false,ParameterSetName='TokenByFlag')]
        [Parameter(Mandatory=$false,ParameterSetName='ListTokenKind')]
        [Parameter(Mandatory=$false,ParameterSetName='TokenByKind')]
        [Parameter(Mandatory=$false,ParameterSetName='TreeAll')]
        [Parameter(Mandatory=$false,ParameterSetName='ListTreeType')]
        [Parameter(Mandatory=$false,ParameterSetName='TreeByType')]
        [System.Management.Automation.Language.ast]$ParentTree=$null,
        
        # Do not recurse tree search
        [Parameter(Mandatory=$false,ParameterSetName='TreeByType')]
        [Parameter(Mandatory=$false,ParameterSetName='ListTreeType')]
        [Parameter(Mandatory=$false,ParameterSetName='TreeAll')]
        [Switch]$NoRecurse
        
        )
    

    ### PREP

    # Scriptpane
    $ScriptPane = $psISE.CurrentFile.Editor.text
    # Init collectors for Tok/Err
    $Tokens=$Errors=$null
    
    # Parse ScriptPane
    $AST = [System.Management.Automation.Language.Parser]::ParseInput($ScriptPane,[ref]$Tokens,[ref]$Errors)

    # Tree Recurse?
    [Bool]$Recurse = $True
    If($NoRecurse){$Recurse = $false}

    # WTF!?
    $WTF = '¯\_(ツ)_/¯ "Oups!?"'

　
　
    ### ACTION

    ## Help
    # If NoParam
    If($PSCmdlet.ParameterSetName -eq 'NoParam'){Help SyntaxISEr}
    

    ## Tree
    # If Tree
    ElseIf($PSCmdlet.ParameterSetName -eq 'TreeAll'){
        $AST.FindAll({$true},$Recurse) | where {
            $ParentTree -eq $Null -or ($_.Extent.StartOffset -ge $ParentTree.Extent.StartOffset -and $_.Extent.EndOffset -le $ParentTree.Extent.EndOffset)}}
    
    # If List TreeType
    ElseIf($PSCmdlet.ParameterSetName -eq 'ListTreeType'){
        $AST.FindAll({$true},$Recurse) | where {
            $ParentTree -eq $Null -or ($_.Extent.StartOffset -ge $ParentTree.Extent.StartOffset -and $_.Extent.EndOffset -le $ParentTree.Extent.EndOffset)} | %{
            $_.gettype().name} | sort -Unique
            }

    # If TreeType
    ElseIf($PSCmdlet.ParameterSetName -eq 'TreeByType'){
        $AST.findAll({$args[0] -is ("System.Management.Automation.Language.$TreeType" -as [Type])},$Recurse) | where {
            $ParentTree -eq $Null -or ($_.Extent.StartOffset -ge $ParentTree.Extent.StartOffset -and $_.Extent.EndOffset -le $ParentTree.Extent.EndOffset)}}
    

    ## Token
    # If Token
    ElseIf($PSCmdlet.ParameterSetName -eq 'TokenAll'){
        $Tokens | where {
        $ParentTree -eq $Null -or ($_.Extent.StartOffset -ge $ParentTree.Extent.StartOffset -and $_.Extent.EndOffset -le $ParentTree.Extent.EndOffset)}}
    
    # If List TokenFlag
    ElseIf($PSCmdlet.ParameterSetName -eq 'ListTokenFlag'){
        ($Tokens | where {
        $ParentTree -eq $Null -or ($_.Extent.StartOffset -ge $ParentTree.Extent.StartOffset -and $_.Extent.EndOffset -le $ParentTree.Extent.EndOffset)}).TokenFlags | sort -unique
        }

    # If List TokenKind
    ElseIf($PSCmdlet.ParameterSetName -eq 'ListTokenKind'){
        ($Tokens | where {
        $ParentTree -eq $Null -or ($_.Extent.StartOffset -ge $ParentTree.Extent.StartOffset -and $_.Extent.EndOffset -le $ParentTree.Extent.EndOffset)}).Kind | sort -unique
        }

    # If TokenKind
    ElseIf($PSCmdlet.ParameterSetName -eq 'TokenByKind'){$Tokens | where {
        $_.Kind -eq "$TokenKind" -and ($ParentTree -eq $Null -or ($_.Extent.StartOffset -ge $ParentTree.Extent.StartOffset -and $_.Extent.EndOffset -le $ParentTree.Extent.EndOffset))}}

    # If TokenFlag
    ElseIf($PSCmdlet.ParameterSetName -eq 'TokenByFlag'){$Tokens | where {
        $_.TokenFlags -eq "$TokenFlag" -and ($ParentTree -eq $Null -or ($_.Extent.StartOffset -ge $ParentTree.Extent.StartOffset -and $_.Extent.EndOffset -le $ParentTree.Extent.EndOffset))}}
    

    ## Errors
    # If ErrorAll    
    ElseIf($PSCmdlet.ParameterSetName -eq 'ErrorAll'){$Errors}
    

    ## DebugParam
    # If Something else ?!?!?!
    Else{write-host $WTF -ForegroundColor cyan}

    }
#EndFunction

　
#endregion SyntaxISEr
#######################################################
