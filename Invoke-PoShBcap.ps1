#BETA###################################################
#                                                      #
#     Invoke-PoShBcap  -  Bettercap2 PoSh Client       #
#                                                      #
########################################SadProcessor2018

########################################################
#region ########################################## STUFF

## NoSSL Check
Add-Type @"
using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;           
public class ServerCertificateValidationCallback{
    public static void Ignore(){
        ServicePointManager.ServerCertificateValidationCallback += 
            delegate(
                Object obj, 
                X509Certificate certificate, 
                X509Chain chain, 
                SslPolicyErrors errors
                ){return true;};}}
"@


## "String".ToB64
Update-TypeData -TypeName String -MemberName "ToB64" -MemberType ScriptProperty -Value {
    [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($this))
    } -ErrorAct SilentlyContinue


## Bettercap Sessions
[Array]$Bcap = @()


#endregion #############################################

########################################################
#region ###################################### FUNCTIONS


########################################## BettercapCall

<#
.Synopsis
   Bettercap API Call
.DESCRIPTION
   Call Bettercap REST API - Internal
.EXAMPLE
   BettercapCall -ID $ID -Route $Route -Method $Method
.EXAMPLE
   BettercapCall -ID $ID -Route $Route -Method Post -Body $Body
.EXAMPLE
   BettercapCall -Server $Server -Key $key -Port $Port -Route $Route -Method $Method
.LINKS
   https://github.com/bettercap/bettercap/wiki
#>
function BettercapCall{
    [CmdletBinding()]
    Param(
        # ID
        [Parameter(Mandatory=1,ParameterSetName='ID')][Int]$ID,
        # Server
        [Parameter(Mandatory=1,ParameterSetName='IP')][String]$Server,
        # Key
        [Parameter(Mandatory=1,ParameterSetName='IP')][String]$Key,
        # Port
        [Parameter(Mandatory=1,ParameterSetName='IP')][String]$Port,
        # Method
        [Parameter(Mandatory=1)][String]$Method,
        # API Route
        [Parameter(Mandatory=1)][String]$Route,
        # Body
        [Parameter(Mandatory=0)][HashTable]$Body=$Null
        )
    # If by ID
    if($PSCmdlet.ParameterSetName -eq 'ID'){
        $Session = $Script:Bcap | where ID -eq $ID
        $S=$Session.Server
        $K=$Session.Key
        $P=$Session.Port
        if(-Not$K){Write-Warning "Invalid Session ID: $ID";Return}
        }
    # If by IP
    else{$S=$Server;$K=$Key;$P=$Port}
    # URI
    $URI = "Https://${S}:${P}${Route}"
    # Headers
    $Header = @{Authorization="Basic $K"}
    # Call API
    if($Body){
         $B = $Body | ConvertTo-Json
         try{$Reply = Invoke-RestMethod -Method $Method -Uri $URI -Headers $Header -Body $B -ea Sil}catch{$Oops = $Error[0]}}
    else{try{$Reply = Invoke-RestMethod -Method $Method -Uri $URI -Headers $Header -ea Sil}catch{$Oops = $Error[0]}} 
    # if error
    if($Oops){Write-Warning ("$S - " + $Oops.ErrorDetails.message)}
    # Else result
    else{Return $Reply}
    }
#End



################################### New-BettercapSession

<#
.Synopsis
   New Bettercap Session
.DESCRIPTION
   Connect to Bettercap server via REST API
.EXAMPLE
   New-BettercapSession 10.1.2.3 sadProcessor [-Port 1234]
   Will prompt for password if ommitted
.EXAMPLE
   $ServerIPList | Bcap.New sadProcessor -NoSSL
   Accepts multiple servers over pipeline.
   (same Username/Passsword)
.LINKS
   https://github.com/bettercap/bettercap/wiki
#>
function New-BettercapSession{
    [Cmdletbinding(HelpURI='https://github.com/bettercap/bettercap/wiki')]
    [Alias('Bcap.New')]
    Param(
        # Server
        [Parameter(Mandatory=1,ValueFromPipeline=1)][String]$Server,
        # Username
        [Parameter(Mandatory=0)][String]$User,
        # Password (prompt if ommitted)
        [Parameter(Mandatory=0)][String]$Password,
        # Port (default=8083)
        [Parameter(Mandatory=0)][int]$Port=8083,
        # No SSL Check
        [Parameter(Mandatory=0)][Alias('Insecure')][Switch]$NoSSL
        )
    Begin{
        # No SSL
        if($NoSSL){[ServerCertificateValidationCallback]::Ignore()}
        # No Password
        if(-Not$Password){
            $Cred = Get-Credential -UserName $User -Message 'Please insert creds'
            if(-Not$User){$User=$Cred.GetNetworkCredential().UserName}
            $Password = $Cred.GetNetworkCredential().Password
            }
        # Key
        $Key = "${User}:${Password}".ToB64
        }
    Process{
        # Test Connection
        $TestCall = BettercapCall -Server $Server -Key $Key -Port $Port -Method 'GET' -Route '/api/session' -WarningAction SilentlyContinue
        if(-Not$TestCall.options){Write-Warning "Could Not Connect to server $Server";Break}
        # Add to Bcap Session List
        $IDList = $Script:Bcap.ID
        if($IDList.count){$ID = ($IDlist | Sort | Select -Last 1) +1}
        else{$ID = 0} 
        $Obj =  New-Object PSCustomObject -Property @{
            X        = ''
            ID       = $ID
            Server   = $Server
            Port     = $Port
            UserName = $User
            Key      = $Key
            }
        $Script:Bcap += $Obj
        }
    End{Select-BettercapSession -ID $Obj.ID}
    }
#End



################################### Get-BettercapSession

<#
.Synopsis
   Get Bettercap Session
.DESCRIPTION
   View Bettercap Session Object
.EXAMPLE
   Get-BettercapSession
.EXAMPLE
   Bcap.Session -ID 1 -Expand options
.EXAMPLE
   Bcap.List | Bcap.Session
.LINKS
   https://github.com/bettercap/bettercap/wiki
#>
function Get-BettercapSession{
    [Cmdletbinding(HelpURI='https://github.com/bettercap/bettercap/wiki')]
    [Alias('Bcap.Session')]
    Param(
        # Session ID
        [Parameter(Mandatory=0,ValueFromPipeline=1,ValueFromPipelineByPropertyName=1)][Int]$ID,
        # Expend Property
        [Parameter(Mandatory=0,ValueFromPipeline=0)][Alias('Select')][String]$Expand
        )
    Begin{
        $Result = @()
        # If Not ID
        if(-Not$ID){$ID=($Script:Bcap | Where X -eq 'X').ID}
        # Route & Method
        $Method = 'GET'
        $Route  = '/api/session'
        }
    Process{
        $Reply = BettercapCall -ID $ID -Method $Method -Route $Route
        if($reply){
            $Reply | Add-member -MemberType NoteProperty -Name ID -value $ID
            $Result += $Reply
            }}
    End{
        if($Expand){$Result = $Result | Select -ExpandProperty $Expand}
        Return $Result
        }
    }
#End



############################### Get-BettercapSessionList

<#
.Synopsis
   Get Bettercap Session List
.DESCRIPTION
   View Bettercap Session List
.EXAMPLE
   Get-BettercapSessionList
.EXAMPLE
   Bcap.List
.LINKS
   https://github.com/bettercap/bettercap/wiki
#>
function Get-BettercapSessionList{
    [Cmdletbinding(HelpURI='https://github.com/bettercap/bettercap/wiki')]
    [Alias('Bcap.List')]
    Param([Parameter(Mandatory=0)][Switch]$Key)
    if($Key){Return $Script:Bcap | Select X,ID,Server,Port,UserName,Key}
    else{Return $Script:Bcap | Select X,ID,Server,Port,UserName}
    }
#End



################################ Select-BettercapSession

<#
.Synopsis
   Select Bettercap Session
.DESCRIPTION
   Set default Bettercap Session ID
   Used by other cmdlets if -ID ommited
.EXAMPLE
   Select-BettercapSession -ID 1
   Select session ID 1 as default
   Note: specifying -ID in other cmdlets overrides default
.EXAMPLE
   Bcap.Select 1
   Same as above with short syntax
.NOTES
   Creating a new session automaticaly sets it as default
.LINKS
   https://github.com/bettercap/bettercap/wiki
#>
function Select-BettercapSession{
    [Cmdletbinding(HelpURI='https://github.com/bettercap/bettercap/wiki')]
    [Alias('Bcap.Select')]
    Param(
        # Session ID
        [Parameter(Mandatory=1)][Int]$ID
        )
    ## Begin
    if($ID -notin $Script:Bcap.ID){Write-Warning 'Invalid Session ID...';Return}
    ## Process
    # Remove old X
    try{($Script:Bcap | Where X -eq 'X').X = $Null}catch{}
    # Add New X
    ($Script:Bcap | Where ID -eq $ID).X = 'X'
    ## End
    Return $Script:Bcap | Select X,ID,Server,Port,UserName | ft
    }
#End



################################ Invoke-BettercapCommand

<#
.Synopsis
   Invoke Bettercap Command
.DESCRIPTION
   Run Bettercap Commands on server
.EXAMPLE
   Invoke-BettercapCommand -Cmd 'net.probe on'
   Run command ageinst default session ID

   Short: Bcap net.probe on
   Note: Can ommit quotes if no semi-colons in command
.EXAMPLE
   Bcap net.probe on -ID 0
   Run command ageinst specific session ID
.EXAMPLE
   1..3 | Bcap net.probe on
   Run commands against multiple sessions over pipeline
.LINKS
   https://github.com/bettercap/bettercap/wiki
#>
function Invoke-BettercapCommand{
    [Cmdletbinding(SupportsShouldProcess=1,ConfirmImpact='medium',
        HelpURI='https://github.com/bettercap/bettercap/wiki')]
    [Alias('Bcap.Cmd','Bcap')]
    Param(
        # Command
        [Parameter(Mandatory=1,Position=0,ValueFromRemainingArguments=1)][String]$Cmd,
        # Session ID
        [Parameter(Mandatory=0,ValueFromPipeline=1,ValueFromPipelineByPropertyName=1)][Int]$ID
        )
    Begin{
        $Result = @()
        # If Not ID
        if(-Not$ID){$ID=($Script:Bcap | Where X -eq 'X').ID}
        # Route & Method
        $Method = 'POST'
        $Route  = '/api/session'
        # Body
        $Body = @{Cmd="$Cmd"}
        }
    Process{
        if($PSCmdlet.ShouldProcess(($Script:Bcap| where ID -eq $ID).Server,$Cmd)){
            $Reply = BettercapCall -ID $ID -Method $Method -Route $Route -Body $Body
            if($reply){
                $Reply | Add-member -MemberType NoteProperty -Name ID -value $ID
                $Result += $Reply
                }}}
    End{Return $Result}
    }
#End



##################################### Get-BettercapEvent

<#
.Synopsis
   Get Bettercap Event
.DESCRIPTION
   List bettercap Events per session ID
   Multiple over pipeline 
.EXAMPLE
   Get-BettercapEvent
.EXAMPLE
   Bcap.Event -ID 0 -Limit 10
.EXAMPLE
   Bcap.Session -tag sys.log -Expand data
.LINKS
   https://github.com/bettercap/bettercap/wiki
#>
function Get-BettercapEvent{
    [Cmdletbinding(HelpURI='https://github.com/bettercap/bettercap/wiki')]
    [Alias('Bcap.Event')]
    Param(
        # Session ID
        [Parameter(Mandatory=0,ValueFromPipeline=1,ValueFromPipelineByPropertyName=1)][Int]$ID,
        # Event count limit
        [Parameter(Mandatory=0,ValueFromPipeline=0)][Alias('Limit')][Int]$Last,
        # Tag Filter
        [Parameter(Mandatory=0,ValueFromPipeline=0)][Alias('Filter')][String]$Tag,
        # Expand Property
        [Parameter(Mandatory=0,ValueFromPipeline=0)][Alias('Select')][String]$Expand
        )
    Begin{
        $Result = @()
        # If Not ID
        if(-Not$ID){$ID=($Script:Bcap | Where X -eq 'X').ID}
        # Route & Method
        $Method = 'GET'
        $Route  = '/api/events'
        # If Limit
        if($Last){$Route+="?n=$Last"}
        }
    Process{
        $Reply = BettercapCall -ID $ID -Method $Method -Route $Route
        if($reply){
            $Reply | Add-member -MemberType NoteProperty -Name ID -value $ID
            $Result += $Reply
            }}
    End{
        if($Tag){$Result = $Result | where Tag -eq $Tag}
        if($Expand){$Result = $Result | Select -ExpandProperty $Expand}
        Return $Result
        }
    }
#End



################################### Clear-BettercapEvent

<#
.Synopsis
   Clear Bettercap Event
.DESCRIPTION
   Clear Bettercap Event Buffer
.EXAMPLE
   Clear-BettercapEvent [-ID 0]
   Clear default/specified ID event buffer
.EXAMPLE
   Bcap.List | Bcap.Clear
   Clear Buffer for all sessions
.LINKS
   https://github.com/bettercap/bettercap/wiki
#>
function Clear-BettercapEvent{
    [Cmdletbinding(SupportsShouldProcess=1,ConfirmImpact='high',
        HelpURI='https://github.com/bettercap/bettercap/wiki')]
    [Alias('Bcap.Clear')]
    Param(
        # Session ID
        [Parameter(Mandatory=0,ValueFromPipeline=1,ValueFromPipelineByPropertyName=1)][Int]$ID
        )
    Begin{
        $Result = @()
        # If Not ID
        if(-Not$ID){$ID=($Script:Bcap | Where X -eq 'X').ID}
        # Route & Method
        $Method = 'DELETE'
        $Route  = '/api/events'
        }
    Process{
        if($PSCmdlet.ShouldProcess(($Script:Bcap| where ID -eq $ID).Server,'Delete Events')){
            $Reply = BettercapCall -ID $ID -Method $Method -Route $Route
            if($reply){
                $Reply | Add-member -MemberType NoteProperty -Name ID -value $ID
                $Result += $Reply
                }}}
    End{Return $Result}
    }
#End


#endregion #############################################

########################################################
#################################################### EOF