################################################
##############  EmpireStrikeX  #############Beta
#######################################Empire2.5

## KNOWN ISSUES
# /!\ AgentUploadFile    <------------------------- /!\ Check/Fix
# /!\ AgentDownloadFile  <------------------------- /!\ Check/Fix
# /!\ CredAdd            <------------------------- /!\ Check POST format
# /!\ Reporting (All)    <------------------------- /!\ Upcoming Changes (Breaking?)

## TWEAK/PR
# /?\ Stager OutFile API <------------------------- /?\ Maybe cool (w\ static) 

################################################
########################################### VARS
#region VARS

# Enum ListenerType   -> For Param Vset
# Enum ModuleCategory -> For Param Vset
# Glob EmpireSession  -> Empire Session Objs
# Glob EmpireTarget   -> Target Session + Agent
# Glob EmpireStrike   -> Target Module + Option
# Glob EmpireList     -> All Other Empire Objs



################################### ListenerType
enum ListenerType{
    dbx
    http
    http_com
    http_foreign
    http_hop
    http_mapi
    meterpreter
    onedrive
    redirector
    }



################################# ModuleCategory
enum ModuleCategory{
    code_execution
    collection
    credentials
    exfiltration
    exploitation
    lateral_movement
    management
    persistence
    privesc
    recon
    situational_awareness
    trollsploit
    exploit
    custom
    }



################################## EmpireSession
if(!$Global:EmpireSession){
    $Global:EmpireSession = New-Object Collections.ArrayList
    }



################################### EmpireTarget
if(!$Global:EmpireTarget){
    $Global:EmpireTarget = New-Object PSCustomObject -Prop @{
        ID            = '?'
        Agent         = '?'
        }}



################################### EmpireStrike
if(!$Global:EmpireStrike){
    $Global:EmpireStrike = New-Object PSCustomObject -Prop @{
        Module        = '?'
        Option        = '?'
        }}



##################################### EmpireList
if(!$Global:EmpireList){
    $Global:EmpireList  = New-Object PSCustomObject -Prop @{
        Module       = $Null
        ModuleName   = $Null
        AgentName    = $Null
        ListenerName = $Null
        StagerType   = $Null
        Temp         = $Null
        TempType     = $Null
        }}



######################################### Banner
$Banner = @('
                                         
                              `````````  
                         ``````.--::///+ 
                     ````-+sydmmmNNNNNNN 
                   ``./ymmNNNNNNNNNNNNNN 
                 ``-ymmNNNNNNNNNNNNNNNNN 
               ```ommmmNNNNNNNNNNNNNNNNN 
              ``.ydmNNNNNNNNNNNNNNNNNNNN 
             ```odmmNNNNNNNNNNNNNNNNNNNN 
            ```/hmmmNNNNNNNNNNNNNNNNMNNN 
           ````+hmmmNNNNNNNNNNNNNNNNNMMN 
          ````..ymmmNNNNNNNNNNNNNNNNNNNN 
          ````:.+so+//:---.......----::- 
         `````.`````````....----:///++++ 
        ``````.-/osy+////:::---...-dNNNN 
        ````:sdyyydy`         ```:mNNNNM 
       ````-hmmdhdmm:`      ``.+hNNNNNNM 
       ```.odNNmdmmNNo````.:+yNNNNNNNNNN 
       ```-sNNNmdh/dNNhhdNNNNNNNNNNNNNNN 
       ```-hNNNmNo::mNNNNNNNNNNNNNNNNNNN 
       ```-hNNmdNo--/dNNNNNNNNNNNNNNNNNN 
      ````:dNmmdmd-:+NNNNNNNNNNNNNNNNNNm 
      ```/hNNmmddmd+mNNNNNNNNNNNNNNds++o 
     ``/dNNNNNmmmmmmmNNNNNNNNNNNmdoosydd 
     `sNNNNdyydNNNNmmmmmmNNNNNmyoymNNNNN 
     :NNmmmdso++dNNNNmmNNNNNdhymNNNNNNNN 
     -NmdmmNNdsyohNNNNmmNNNNNNNNNNNNNNNN 
     `sdhmmNNNNdyhdNNNNNNNNNNNNNNNNNNNNN 
       /yhmNNmmNNNNNNNNNNNNNNNNNNNNNNmhh 
        `+yhmmNNNNNNNNNNNNNNNNNNNNNNmh+: 
          `./dmmmmNNNNNNNNNNNNNNNNmmd.   
            `ommmmmNNNNNNNmNmNNNNmmd:    
             :dmmmmNNNNNmh../oyhhhy:     
             `sdmmmmNNNmmh/++-.+oh.      
              `/dmmmmmmmmdo-:/ossd:      
                `/ohhdmmmmmmdddddmh/     
                   `-/osyhdddddhyo:      
                        ``.----.`        
                                         
 .-------------------------------------. 
 | EmpireStrikeX - 0.0 - @SadProcessor | 
 ''-------------------------------------'' 
')#


#endregion #####################################


################################################
###################################### INTERNALS
#region INTERNALS

# EmpireConnect  ->  Connect to Server
# EmpireCall     ->  Call Empire API
# DynDico        ->  Dyn Param Generator
# AutoSession    ->  Auto Session Update/Target
# AutoTarget     ->  Auto Target Agent + Warning
# UnpackOption   ->  Reformat Option Obj
# MFilter        ->  Module Name Filter
# Only           ->  Property Filter Pipe
# FixSession     ->  Re-Allocate Session IDs
# LastError      ->  Last Error to Warning
# DynSession     ->  Dyn Session Param List



################################## EmpireConnect

<#
.Synopsis
   New Empire Session
.DESCRIPTION
   # INTERNAL
   Connect to Empire Server
   Add Session Obj to $EmpireSession
.EXAMPLE
   EmpireConnect 10.1.2.3 Sadprocessor -NoSSL
   Connects to Empire
   Prompts for Password
#>
function EmpireConnect{
    [CmdletBinding()]
    Param(
        # Server IP
        [Parameter(Mandatory=1)][Alias('Host')][String]$Server,
        # UserName (Will Prompt for Password)
        [Parameter(Mandatory = $true)]
        [Management.Automation.CredentialAttribute()][Management.Automation.PSCredential]$User,
        # Switch Disable SSL
        [Parameter(Mandatory=0)][Switch]$NoSSL,
        # Optional Port
        [Parameter(Mandatory=0)][Int]$Port=1337
        )
    # If No SSL
    if($NoSSL){
        Try{
            # Dissable Cert Check ################################# <------------------------ /!\ Check /!\
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
            [ServerCertificateValidationCallback]::Ignore()}Catch{<#nothing#>}
            }
    # Cred to Json
    $Pass = ConvertTo-Json @{
        username=$User.UserName
        password=$User.GetNetworkCredential().Password
        }
    # Prep Call Options
    $Call = @{
        Content = 'application/json'
        Method  = 'POST'
        Uri     = "https://$($Server):$($Port)/api/admin/login"
        Body    = "$Pass"
        }
    # Make Call
    $Reply = Invoke-RestMethod @Call
    # If Reply Token    
    if($Reply.token){
        # Create Session Obj
        $session = New-Object PSCustomObject -Property @{
            ID   = $Global:EmpireSession.token.Count
            Host = $Server
            Port = $Port
            Token= $Reply.token
            }
        # Add to Empire Sessions
        $Null = $Global:EmpireSession.Add($Session)
        # Return Session Obj
        Return $Session | Select ID,Host,Port,Token 
        }}
#####end



##################################### EmpireCall

<#
.Synopsis
   Call Empire API
.DESCRIPTION
   # INTERNAL
   Invoke-WebRequest to Empire API
   Requires Action Parameter
   Optional Spec And BodyHash
   Defaults to target Session ID
.EXAMPLE
   EmpireCall ModuleList
#>
function EmpireCall{
    Param(
        # Call Action
        [ValidateSet(<#'AdminLogin',#>'AdminToken','AdminRestart','AdminShutDown','AdminConfig','AdminVersion','AdminFile','AdminMap',
            'AgentList','AgentRemove','AgentView','AgentClearBuffer','AgentKill','AgentRename','AgentResult','AgentDeleteResult','AgentExec',
            'AgentUploadFile','AgentDownloadFile','AgentListStale','AgentRemoveStale','CredList','CredAdd','ListenerList','ListenerView',
            'ListenerKill','ListenerNew','ListenerOptions','ModuleList','ModuleView','ModuleExec',<#'ModuleSearch','ModuleSearchAuth',
            'ModuleSearchComm','ModuleSearchDesc','ModuleSearchName',#>'EventList','EventView','EventMessage','EventType','StagerList',
            'StagerNew','StagerView')]
        [Parameter(Mandatory=1)][String]$Act,
        # Spec Param
        [Parameter(Mandatory=0)][String]$Spec,
        # Post Options
        [Parameter(Mandatory=0)][PSCustomObject]$Opt,
        # Session ID
        [Parameter(Mandatory=0)][Int]$ID=$Global:EmpireTarget.ID
        )
    # Prep Session Vars
    $Session = $Global:EmpireSession | where ID -eq $ID
    if(!$Session.token){Write-Warning "Session Not Found.";Break}
    $Server  = $Session.Host
    $Port    = $Session.Port
    $Token   = $Session.token
    # Action to Call Vars
    Switch($Act){
      ######################################################################################################
      <# ACTION          { METHOD    ; KEY                 ; ROUTE                               } TEST  #> 
      ##Admin ##############################################################################################
        AdminToken       {$M='GET'   ; $K=$Null            ; $R="/api/admin/permanenttoken"      } <# OK #>
        AdminRestart     {$M='GET'   ; $K=$Null            ; $R="/api/admin/restart"             } <# OK #>
        AdminShutDown    {$M='GET'   ; $K=$Null            ; $R="/api/admin/shutdown"            } <# OK #>
        AdminConfig      {$M='GET'   ; $K='config'         ; $R="/api/config"                    } <# OK #>
        AdminVersion     {$M='GET'   ; $K=$Null            ; $R="/api/version"                   } <# OK #>
        AdminFile        {$M='GET'   ; $K=$Null            ; $R="/static/$Spec"                  } <# OK #>
        AdminMap         {$M='GET'   ; $K='Routes'         ; $R="/api/map"                       } <# OK #>
      <#AdminLogin       {$M='POST'  ; $K=$Null            ; $R="/api/admin/login"               } <# XX #> #<------- EmpireConnect
      ##Agent ##############################################################################################
        AgentList        {$M='GET'   ; $K='agents'         ; $R="/api/agents"                    } <# OK #>
        AgentRemove      {$M='DELETE'; $K=$Null            ; $R="/api/agents/$Spec"              } <# OK #>
        AgentView        {$M='GET'   ; $K='agents'         ; $R="/api/agents/$Spec"              } <# OK #>
        AgentClearBuffer {$M='GET'   ; $K=$Null            ; $R="/api/agents/$Spec/clear"        } <# OK #>
        AgentKill        {$M='GET'   ; $K=$Null            ; $R="/api/agents/$Spec/kill"         } <# OK #>
        AgentRename      {$M='POST'  ; $K=$Null            ; $R="/api/agents/$Spec/rename"       } <# OK #>
        AgentResult      {$M='GET'   ; $K='results'        ; $R="/api/agents/$Spec/results"      } <# OK #>
        AgentDeleteResult{$M='DELETE'; $K=$Null            ; $R="/api/agents/$Spec/results"      } <# OK #>
        AgentExec        {$M='POST'  ; $K=$Null            ; $R="/api/agents/$Spec/shell"        } <# OK #>
        AgentUploadFile  {$M='POST'  ; $K=$Null            ; $R="/api/agents/$Spec/upload"       } <# ?? #> #<-------- /!\ Check/Fix
        AgentDownloadFile{$M='POST'  ; $K=$Null            ; $R="/api/agents/$Spec/download"     } <# ?? #> #<-------- /!\ Check/Fix
        AgentListStale   {$M='GET'   ; $K='agents'         ; $R="/api/agents/stale"              } <# OK #>
        AgentRemoveStale {$M='DELETE'; $K=$Null            ; $R="/api/agents/stale"              } <# OK #>
      ##Cred ###############################################################################################
        CredList         {$M='GET'   ; $K='creds'          ; $R="/api/creds"                     } <# OK #>
        CredAdd          {$M='POST'  ; $K=$Null            ; $R="/api/creds"                     } <# ?? #> #<-------- /!\ Check required POST format
      ##Listener ###########################################################################################
        ListenerList     {$M='GET'   ; $K='listeners'      ; $R="/api/listeners"                 } <# OK #>
        ListenerView     {$M='GET'   ; $K='listeners'      ; $R="/api/listeners/$Spec"           } <# OK #>
        ListenerKill     {$M='DELETE'; $K=$Null            ; $R="/api/listeners/$Spec"           } <# OK #>
        ListenerNew      {$M='POST'  ; $K=$Null            ; $R="/api/listeners/$Spec"           } <# OK #>
        ListenerOptions  {$M='GET'   ; $K='listeneroptions'; $R="/api/listeners/options/$Spec"   } <# OK #>
      ##Module #############################################################################################
        ModuleList       {$M='GET'   ; $K='modules'        ; $R="/api/modules"                   } <# OK #>
        ModuleView       {$M='GET'   ; $K='modules'        ; $R="/api/modules/$Spec"             } <# OK #>
        ModuleExec       {$M='POST'  ; $K=$Null            ; $R="/api/modules/$Spec"             } <# OK #>
      <#ModuleSearch     {$M='POST'  ; $K=$Null            ; $R="/api/modules/search"            } <# XX #>
      <#ModuleSearchAuth {$M='POST'  ; $K=$Null            ; $R="/api/modules/search/author"     } <# XX #>
      <#ModuleSearchComm {$M='POST'  ; $K=$Null            ; $R="/api/modules/search/comments"   } <# XX #>
      <#ModuleSearchDesc {$M='POST'  ; $K=$Null            ; $R="/api/modules/search/description"} <# XX #>
      <#ModuleSearchName {$M='POST'  ; $K=$Null            ; $R="/api/modules/search/modulename" } <# XX #>
      ##Event ##############################################################################################
        EventList        {$M='GET'   ; $K='reporting'      ; $R="/api/reporting"                 } <# OK #>
        EventView        {$M='GET'   ; $K='reporting'      ; $R="/api/reporting/agent/$Spec"     } <# OK #>
        EventMessage     {$M='GET'   ; $K='reporting'      ; $R="/api/reporting/msg/$Spec"       } <# OK #>
        EventType        {$M='GET'   ; $K='reporting'      ; $R="/api/reporting/type/$Spec"      } <# OK #>
      ##Stager #############################################################################################
        StagerList       {$M='GET'   ; $K='stagers'        ; $R="/api/stagers"                   } <# OK #>
        StagerNew        {$M='POST'  ; $K=$Null            ; $R="/api/stagers"                   } <# OK #>
        StagerView       {$M='GET'   ; $K='stagers'        ; $R="/api/stagers/$Spec"             } <# OK #>
        }###################################################################################################
    #                                                             <# XX = not used / ?? = Needs check/Fix #>
    # Prep Call Options
    $Uri = "https://$($Server):$($Port)${R}?token=$Token"
    $Call = @{Content='application/json'; Method=$M; Uri=$Uri}
    Write-Verbose "[$ID] - $Act $Spec"    
    # if POST add Body (Json)
    if($M -eq 'POST' -AND $Opt){
        $Json = ConvertTo-Json $Opt
        $Call.Add('Body',$Json)
        Write-Verbose "BODY`n`t$($Json.trim().trimEnd('}').trimStart('{').trim())"
        }
    # Make Call
    $Reply = Try{Invoke-RestMethod @Call}Catch{LastError}
    # Unpack & Return Reply 
    if($K -ne $Null){$Reply = $Reply.$K}
    Return $Reply
    }
#end



######################################## DynDico

<#
.Synopsis
   DynParam Dictionnary
.DESCRIPTION
   # INTERNAL
   Return Single DynParam Dictionnary
   Used for Dynamic Param Validation
.EXAMPLE
    DynParam: Switch on ParamSet
    DynamicParam{
        # Filter ParamSet
        if($PSCmdlet.ParameterSetName -in 'SetA','SetB'){
            # Populate Vars
            Switch($PSCmdlet.ParameterSetName){
                #SET { NAME     ; TYPE       ; MAND ; PIPE ; POS  ; VSET
                ###############################################################...
                SetA { $N='Name'; $T='String'; $M=1 ; $L=0 ; $P=0 ; $V=@('A1','A2')}
                SetB { $N='Num' ; $T='Int'   ; $M=0 ; $L=0 ; $P=0 ; $V=@(1,2,3)}
                }
            # Return Dico
            return DynDico -Name $N -Type $T -Mandat $M -Pipe $L -Pos $P -VSet $V    
            }}
#>
function DynDico{
    Param(
        [Parameter(Mandatory=1)][String]$Name,
        [Parameter(Mandatory=1)][String]$Type,
        [Parameter(Mandatory=0)][bool]$Mandat=0,
        [Parameter(Mandatory=0)][bool]$Pipe=0,
        [Parameter(Mandatory=0)][int]$Pos=$Null,
        [Parameter(Mandatory=0)][Array]$VSet=$Null
        )
    # Prep Empty Dico
    $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
    # Create Attribute Obj
    $Attrb = New-Object Management.Automation.ParameterAttribute
    $Attrb.Mandatory=$Mandat
    $Attrb.ValueFromPipeline=$Pipe
    $Attrb.ValueFromPipelineByPropertyName=$Pipe
    if($Pos -ne $null){$Attrb.Position=$Pos}
    # Create AttributeCollection
    $Cllct = New-Object Collections.ObjectModel.Collection[System.Attribute]
    # Add Attribute Obj to Collection
    $Cllct.Add($Attrb)
    if($VSet -ne $Null){
        # Create ValidateSet & add to collection     
        $VldSt=New-Object Management.Automation.ValidateSetAttribute($VSet)
        $Cllct.Add($VldSt)
        }
    # Create Runtine DynParam
    $DynP = New-Object Management.Automation.RuntimeDefinedParameter($Name,$($Type-as[type]),$Cllct)
    # Add dynParam to Dictionary
    $Dico.Add($Name,$DynP)      
    ## Return Dictionary
    return $Dico
    }
#end



#################################### AutoSession

<#
.Synopsis
   Auto Session
.DESCRIPTION
   # INTERNAL
   Auto Session ID
   Used when Connecting/Switching Session
   - Set Target Session ID
   - Sync Session Objects
   - Auto Target Agent / Warning 
.EXAMPLE
   AutoSession 0
#>
function AutoSession{
    Param([Parameter()][Int]$ID=$Global:EmpireTarget.ID)
    # Set Target Session
    $Global:EmpireTarget.ID = $ID
    # Update Session Vars
    Empire-Sync -Session
    # AutoTarget Agent
    AutoTarget
    }
#end



##################################### AutoTarget

<#
.Synopsis
   Auto Target Agent
.DESCRIPTION
   # INTERNAL
   Auto target Agent
   Used when Connecting/Switching Session
.EXAMPLE
   AutoTarget
#>
function AutoTarget{
    # If target not in Session
    if($Global:EmpireTarget.Agent -notin $Global:EmpireList.AgentName -OR $Global:EmpireTarget.Agent -eq $null){
        $Global:EmpireTarget.Agent = ''
        $L = [Array]$Global:EmpireList.AgentName
        Switch($L.count){
            0 {Write-Warning 'No Agents in Session'}
            1 {$Global:EmpireTarget.Agent = $L[0];Write-Warning "Auto Target - $($L[0])"}
            Default {Write-Warning 'Select Target Agent'}
            }}}
#########end



################################### UnpackOption

<#
.Synopsis
   Unpack Options
.DESCRIPTION
   # INTERNAL
   Make Nice Option Object
   Pipe after Module/Listener/Stager obj
.EXAMPLE
   $Object | Unpack
#>
function UnpackOptions{
    [Alias('Unpack')]
    Param(
        # Input Option Object
        [Parameter(Mandatory=1,ValueFromPipeline=1)]$In
        )
    Begin{$Out= @()}
    Process{
        if($In.Options){
            # For Each Object Property
            ($In.Options|gm|? MemberType -eq NoteProperty).name|%{
                # Add expanded object to Output
                $Out += New-Object PSCustomObject -Property @{
                    Name        = $_
                    Description = $In.Options.$_.Description
                    Required    = $In.Options.$_.Required
                    Value       = $In.Options.$_.Value
                    }}}
        # If .options Obj
        else{
            # For Each Object Property
            ($In|gm|? MemberType -eq NoteProperty).name|%{
                # Add expanded object to Output
                $Out += New-Object PSCustomObject -Property @{
                    Name        = $_
                    Description = $In.$_.Description
                    Required    = $In.$_.Required
                    Value       = $In.$_.Value
                    }}}}
    End{Return $Out|Select Name,Required,Value,Description}
    }
#end



#################################### WarnMissing

<#
.Synopsis
   Warn Missing Option
.DESCRIPTION
   # INTERNAL
   Missing Option Warning
   Used for Strike/Execute/Generate
.EXAMPLE
   WarnMissing $obj
.EXAMPLE
   if(WarnMissing $Global:EmpireList.temp){Return}
#>
function WarnMissing{
    [OutputType([bool])]
    Param([Parameter(Mandatory=1,ValueFromPipeline=1)][PSCustomObject]$Obj)
    Begin{$result=@()}
    Process{
        $Missing = [Array]($Obj | ? {($_.required -eq 'True' -AND ([String]$_.Value -eq ''))}).Name
        if($Missing.Count){
            Write-Warning "Required Option $($Missing-join',')"
            $result+=$true
            }}
    # Return $true/$Null
    End{if($Result.Count){Return $true}}
    }
#End



######################################## MFilter

<#
.Synopsis
   Filter Module List
.DESCRIPTION
   # INTERNAL
   Filter Module List
   Used for Dynamic Module Name
.EXAMPLE
   MFilter -Lang PowerShell
#>
function MFilter{
    Param(
        [ValidateSet('PowerShell','Python')]
        [Parameter()][String]$Lang,
        [Parameter()][String]$Cat
        )
    # Lang Only
    if($Lang -AND !$Cat){
        $Lang=$Lang.ToLower()
        $List = ($Global:EmpireList.ModuleName -match "$Lang/").replace("$Lang/",'')
        }
    # Cat Only
    elseif($Cat -AND !$Lang){
        $Cat=$Cat.ToLower()
        $List = $Global:EmpireList.ModuleName -match "$Cat/"
        $List = $List -replace "(.*)$Cat/",''
        }
    # Lang & Cat
    elseif($Lang -AND $Cat){
        $Lang=$Lang.ToLower()
        $List = ($Global:EmpireList.ModuleName -match "$Lang/").replace("$Lang/",'')
        $Cat=$cat.ToLower()
        $List = ($List -match "$Cat/").replace("$Cat/",'')
        }
    # No Filter
    elseif(!$Lang -AND !$Cat){$List = $Global:EmpireList.ModuleName}
    # Return List
    return $List
    }
#end



########################################### Only

<#
.Synopsis
   Pipe Prop Only
.DESCRIPTION
   # INTERNAL
   List Prop Value over Pipe
   Defaults to Name Property
.EXAMPLE
   $ObjectCollection | Name
.EXAMPLE
   $ObjectCollection | Only ThisOption
#>
function Only{
    [Alias('Name')]
    Param(
        # Prop Name
        [Parameter()][String]$Prop='Name',
        # Input Obj
        [Parameter(ValuefromPipeline=$true)]$Obj       
        )
    ## Prep Empty Collector
    Begin{$List=@()}
    ## Filter Prop
    Process{if($Obj.$Prop){$List += $Obj.$Prop}}
    ## Return List
    End{Return $List}
    }
#end



##################################### DynSession

<#
.Synopsis
   Dyn Session ID
.DESCRIPTION
   # INTERNAL
   Return Dyn Session List
   for ValidateSet 
.EXAMPLE
   FixSession
#>
function DynSession{
    Switch($Global:EmpireSession.token.count){
        1{[Array]"$($Global:EmpireSession.id)"}
        Default{[Array]$Global:EmpireSession.id}
        }}
#####end



##################################### FixSession

<#
.Synopsis
   Fix Session IDs
.DESCRIPTION
   # INTERNAL
   Re-Allocate Session IDs
   Used after Session -Remove 
.EXAMPLE
   FixSession
#>
function FixSession{
    Write-Warning "New Session IDs"
    1..($Global:EmpireSession.token.Count) | %{
        $Global:EmpireSession[$_-1].ID = $_-1
        }}
#####end



###################################### LastError

<#
.Synopsis
   Last Error Warning
.DESCRIPTION
   # INTERNAL
   Last Error Message to Warning
   Used in Try/Catch for EmpireCall
.EXAMPLE
   LastError
#>
function LastError{
    [Cmdletbinding()]
    Param()
    ## Make It So
    if($Error[0].Exception){Write-Warning $Error[0].Exception.message.replace('. ',".`n`t`t ")}
    else{Write-Warning $Error[0].PSMessageDetails.split("`n")[0]}
    if($Error[0].ErrorDetails.message){Write-Warning ('Error: '+($Error[0].ErrorDetails.message|COnvertfrom-Json).error)}
    }
#end


#endregion #####################################


################################################
###################################### EXTERNALS
#region EXTERNALS

# Empire-Admin     ->  Empire Admin Stuff
# Empire-Agent     ->  Interact with Empire Agents
# Empire-Cred      ->  Interact with Empire Cred DB
# Empire-Event     ->  View Empire Events           <----------------- /!\ upcoming (breaking) changes /!\
# Empire-Exec      ->  Execute Commands on agent
# Empire-Help      ->  View EmpireStrike Cheat Sheet
# Empire-Listener  ->  Interact with Empire Listeners
# Empire-Module    ->  Interact with Empire Modules
# Empire-Option    ->  Set Module Options
# Empire-Result    ->  Get Agent result
# Empire-Search    ->  Search Module|Agent
# Empire-Session   ->  Interact with Empire Sessions
# Empire-Sniper    ->  Shoot from Scriptpane (ISE/VSCode)    
# Empire-Speak     ->  Add Voice to Automations
# Empire-Stager    ->  Interact with Empire Stagers
# Empire-Strike    ->  Execute Empire Modules
# Empire-Sync      ->  Sync Empire Objects
# Empire-Target    ->  View/Set Target
# Empire-Tune      ->  Play Imperial March    
# Empire-Use       ->  Use Stager|Listener|Module
# Empire-View      ->  View Empire Objects




################################### Empire-Admin

<#
.Synopsis
   Empire Admin Actions
.DESCRIPTION
   Admin -Login        : Connect to Empire Server
   Admin -Token        : View session Token
   Admin -Restart      : Restart Empire
   Admin -ShutDown     : Stop Empire
   Admin -Config       : View Empire Config
   Admin -Version      : View Empire Version
   Admin -File         : View static file
   Admin -Map          : View API Routes

   More Info >> Help Admin -Examples
.EXAMPLE
   Empire-Admin -Login -Host 10.1.2.3 -User sadProcessor -Port 1337 -NoSSL
   Login to server
   Short: Admin -login 10.1.2.3 sadProcessor -NoSSL
.EXAMPLE
   Admin -Token
   View session token
   Same for Config/Version
.EXAMPLE
   Admin -Restart -ID 1
   Restart empire server ID 1
   Same for Shutdown
.EXAMPLE
   Admin -Map
   Display all rest API routes
.NOTES
   Notes
#>
Function Empire-Admin{
    [CmdletBinding(
        DefaultParameterSetname='AdminConfig',
        HelpUri='https://github.com/EmpireProject/Empire/wiki',
        SupportsShouldProcess=1,
        ConfirmImpact='High')]
    [Alias('Admin','Server','srv')]
    Param(
		# Connect to Server
		[Parameter(Mandatory=1,ParameterSetName='AdminLogin')][Alias('X','Connect ')][switch]$Login,
		# Get Permanent Token
		[Parameter(Mandatory=1,ParameterSetName='AdminToken')][switch]$Token,
		# Restart Empire
		[Parameter(Mandatory=1,ParameterSetName='AdminRestart')][switch]$Restart,
		# ShutDown Empire
		[Parameter(Mandatory=1,ParameterSetName='AdminShutDown')][switch]$ShutDown,
		# Empire Config
		[Parameter(Mandatory=0,ParameterSetName='AdminConfig')][switch]$Config,
		# Empire Version
		[Parameter(Mandatory=1,ParameterSetName='AdminVersion')][switch]$Version,
		# Empire File
		[Parameter(Mandatory=1,ParameterSetName='AdminFile')][string]$File,
		# Map Empire API
		[Parameter(Mandatory=1,ParameterSetName='AdminMap')][Alias('API')][switch]$Map,
		# Server IP
		[Parameter(Mandatory=1,ParameterSetName='AdminLogin',Position=0)][Alias('Host','Srv')][string]$Server,
		# UserName
		[Parameter(Mandatory=1,ParameterSetName='AdminLogin',Position=1)][Alias('Name','Usr')][string]$User,
		# Port Number
		[Parameter(Mandatory=0,ParameterSetName='AdminLogin',Position=2)][int]$Port,
		# No SSL Check
		[Parameter(Mandatory=0,ParameterSetName='AdminLogin')][switch]$NoSSL
		# Empire File
		#[Parameter(Mandatory=1,ParameterSetName='AdminFile')][Alias('Path')][string]$FileName
		)
    DynamicParam{
        # Filter ParamSet
        if($PSCmdlet.ParameterSetName -ne 'AdminLogin'){
            # Return Dico
            return DynDico -Name ID -Type int -Mandat 0 -Pipe 1 -Pos 0 -VSet (DynSession)
            }}
    ## Make It So
    Begin{$Result = @()}
    Process{
        # Session
        if($PSBoundParameters.ID.count){$Sess = $PSBoundParameters.ID}
        else{$Sess = $Global:EmpireTarget.ID}
        # Switch Action
        Switch($PsCmdlet.ParameterSetName){
            ## Login
            AdminLogin{
                $Null=$PSBoundParameters.Remove('Login')
                $Result = EmpireConnect @PSBoundParameters
                if($Result.token){AutoSession -ID ($Global:EmpireSession.count -1)}
                }
            ## Token
            AdminToken  {$Result += EmpireCall AdminToken   -ID $Sess}
            ## Config
            AdminConfig {$Result += EmpireCall AdminConfig  -ID $Sess}
            ## Version
            AdminVersion{$Result += EmpireCall AdminVersion -ID $Sess}
            ## File
            AdminFile{$Result += EmpireCall Adminfile -Spec $File  -ID $Sess}
            ## Restart
            AdminRestart{
                # Confirm [Use -Confirm:$false to skip]
                if($PSCmdlet.ShouldProcess("Session $Sess","Restart")){
                    $result += EmpireCall AdminRestart  -ID $Sess
                    }}
            ## ShutDown
            AdminShutDown{
                # Confirm [Use -Confirm:$false to skip]
                if($PSCmdlet.ShouldProcess("Session $Sess","Shutdown")){
                    $Result = EmpireCall AdminShutDown -ID $Sess
                    }}
            ## Map (API)
            AdminMap{
                # Fix Reply
                $All = EmpireCall AdminMap -ID $Sess -ErrorAction Stop
                $Obj = @()
                foreach($Route in $All.split("`n").trim()-ne''){
                    # Extract
                    $Act = ($Route | sls "\[ \{ '(.*)': \[ \{ 'methods':").Matches.Groups[1].Value
                    $Met = ($Route | sls "'methods': '(.*)', 'url':"     ).Matches.Groups[1].Value
                    $Rte = ($Route | sls "'url': '(.*)' } ] } ]"         ).Matches.Groups[1].Value
                    # Add to Result
                    $Obj += New-Object PSCustomObject -Property @{
                        Action = $Act
                        Method = $Met
                        Route  = $Rte
                        }}
                # Format
                $Result += $Obj | Select Action,Method,Route | Sort Route
                }}}
    ## Return Result
    End{Return $Result}
    }
#end



################################### Empire-Agent

<#
.Synopsis
   Interact with Agents
.DESCRIPTION
   Agent -View           : View Agent details
   Agent -List           : List all Agents
   Agent -Remove         : Remove Agent fronm DB
   Agent -ClearBuffer    : Clear Agent Buffer
   Agent -Kill           : Kill Agent
   Agent -Rename         : Rename Agent
   Agent -Result         : View Agent Result
   Agent -DeleteResult   : Delete Agent result
   Agent -Exec           : Execute command
   Agent -Upload         : Upload file
   #Agent -Download      : Download file <-------------- ToDo
   Agent -ListStale      : List stale Agents
   Agent -RemoveStale    : Remove Stale Agents
   Agent -Sync           : Sync local Agent list
   Agent -Target         : Set Target Agent

   More Info >> Help Agent -Examples
.EXAMPLE
   Agent -List
   List all agent in current session
.EXAMPLE
   Agent [-View] ABCDEFGH
   Show details of specified agent
.EXAMPLE
   Agent -Target ABCDEFGH
   Set specified agent as target
.EXAMPLE
   agent BCWGEZ3T -Exec -command Get-Date
   Task Agent command
.EXAMPLE
   Agent -ClearBuffer ABCDEFGH
   Clear specified agent buffer
.EXAMPLE
   Agent -Kill ABCDEFGH
   Kill specified agent
.EXAMPLE
   Agent -Remove ABCDEFGH
   Remove specified agent
.EXAMPLE
   Agent -ListStale
   List Stale agents
   Use -RemoveStale to remove
.EXAMPLE
   Agent -Download <---------------------- ToDo
.EXAMPLE
   Agent -Upload   <---------------------- ToDo
.EXAMPLE
   Agent -Sync
   Sync local agent name list
   Done in background for each Agent -List
.NOTES
   (Most) commands default to current target 
   when name parameter ommited
#>
Function Empire-Agent{
    [CmdletBinding(DefaultParameterSetname='AgentView',HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('Agent','Agt')]
    Param(
		# List all Agents
		[Parameter(Mandatory=1,ParameterSetName='AgentList')][switch]$List,
		# Remove Agent
		[Parameter(Mandatory=1,ParameterSetName='AgentRemove')][switch]$Remove,
		# View Agent
		[Parameter(Mandatory=0,ParameterSetName='AgentView')][switch]$View,
		# Clear Agent buffer
		[Parameter(Mandatory=1,ParameterSetName='AgentClearBuffer')][switch]$ClearBuffer,
		# Kill Agent
		[Parameter(Mandatory=1,ParameterSetName='AgentKill')][switch]$Kill,
		# Rename Agent
		[Parameter(Mandatory=0,ParameterSetName='AgentRename')][switch]$Rename,
		# Agent Result
		[Parameter(Mandatory=1,ParameterSetName='AgentResult')][switch]$Result,
		# Delete Agent Result
		[Parameter(Mandatory=1,ParameterSetName='AgentDeleteResult')][Alias('ResultDelete')][switch]$DeleteResult,
		# Execute Command
		[Parameter(Mandatory=0,ParameterSetName='AgentExec')][Alias('PoSh','X')][switch]$Exec,
		# Upload File
		[Parameter(Mandatory=1,ParameterSetName='AgentUploadFile')][switch]$Upload,
		# Download File
		#[Parameter(Mandatory=1,ParameterSetName='AgentUploadFile')][switch]$Download,
		# List Stale Agents
		[Parameter(Mandatory=1,ParameterSetName='AgentListStale')][Alias('Stale')][switch]$ListStale,
		# Remove Stale Agents
		[Parameter(Mandatory=1,ParameterSetName='AgentRemoveStale')][Alias('StaleRemove')][switch]$RemoveStale,
		# Sync Agent List
		[Parameter(Mandatory=1,ParameterSetName='AgentSync')][switch]$Sync,
		# Set Target Agent
		[Parameter(Mandatory=1,ParameterSetName='AgentTarget')][Alias('Tgt','Select')][switch]$Target,
		# New Agent Name
		[Parameter(Mandatory=1,ParameterSetName='AgentRename')][string]$NewName,
		# Command to run
		[Parameter(Mandatory=1,ParameterSetName='AgentExec')][Alias('Cmd')][string]$Command,
		# File Path
		[Parameter(Mandatory=1,ParameterSetName='AgentUploadFile')][string]$File
		)
    DynamicParam{
        # Filter ParamSet
        if($PSCmdlet.ParameterSetName -notin 'AgentList','AgentSync','AgentListStale','AgentRemoveStale'){
            # Populate Vars
            Switch($PSCmdlet.ParameterSetName){
                #SET        { NAME     ; TYPE       ; MAND ; PIPE ; POS  ; VSET
                #########################################################################################...
                AgentView   { $N='Name'; $T='String'; $M=0 ; $L=1 ; $P=0 ; $V=[Array]$Global:EmpireList.AgentName}
                AgentRename { $N='Name'; $T='String'; $M=1 ; $L=0 ; $P=0 ; $V=[Array]$Global:EmpireList.AgentName}
                Default     { $N='Name'; $T='String'; $M=0 ; $L=1 ; $P=0 ; $V=[Array]$Global:EmpireList.AgentName}
                }
            # Return Dico
            return DynDico -Name $N -Type $T -Mandat $M -Pipe $L -Pos $P -VSet $V
            }
        if($PSCmdlet.ParameterSetName -in 'AgentList','AgentListStale','AgentRemoveStale'){
            # Return Dico
            return DynDico -Name ID -Type String -Mandat 0 -Pipe 1 -Pos 0 -VSet (DynSession)
            }}
    ## Make It So
    Begin{$Reply=@()}
    Process{
        # Agent Name
        if($PSCmdlet.ParameterSetName -notin 'AgentList','AgentSync','AgentListStale','AgentRemoveStale'){
            if($PSBoundParameters.Name){$Agt = $PSBoundParameters.Name}
            else{if($PSCmdlet.ParameterSetName -notin 'AgentRemove','AgentKill'){$Agt=$Global:EmpireTarget.Agent}}
            if($Agt -eq $null){Write-Warning 'No Target Agent';Break}}
        # Session ID
        if($PSCmdlet.ParameterSetName -in 'AgentList','AgentListStale','AgentRemoveStale'){
            if($Global:EmpireTarget.ID.count){$Sess = $Global:EmpireTarget.ID}
            else{$Sess = $Global:EmpireTarget.ID}
            }
        # Switch Action
        Switch($PSCmdlet.ParameterSetName){
            # Sync
            AgentSync{Empire-Sync -Agent}
            # List Stale
            AgentListStale{$Reply += EmpireCall AgentListStale -ID $Sess}
            # Remove Stale
            AgentRemoveStale{$Reply += EmpireCall AgentRemoveStale -ID $Sess}
            # List
            AgentList{Empire-Sync -Agent;$Reply += (EmpireCall AgentList -ID $Sess) |Select * -ExcludeProperty 'results'}
            # Exec
            AgentExec{$Reply += Empire-Exec -Command $Command -Name $Agt}
            # Upload File
            AgentUploadFile{$Reply += EmpireCall AgentUploadFile -Spec $Agt -Opt @{path=$Command}}
            # Rename
            AgentRename{$Reply += EmpireCall AgentRename -Spec $Agt -Opt (New-Object PSCustomObject -Prop @{newname=$NewName})}
            # View
            AgentView{$Reply += EmpireCall AgentView -Spec $Agt | select * -ExcludeProperty results}
            # Result
            AgentResult{
                $Re = EmpireCall AgentResult -Spec $Agt
                $Reply += New-Object PSCustomObject -Property @{
                    Name = $Re.AgentName
                    Results = $Re.AgentResults|convertfrom-Json
                    }}
            # Target
            AgentTarget{$Global:EmpireTarget.Agent = $Agt}
            # Other
            Default{$Reply += EmpireCall $PSCmdlet.ParameterSetName -Spec $Agt}
            }}
    ## Return Result
    End{Return $Reply}
    }
#end



#################################### Empire-Cred <--------------------- /!\ Test Add

<#
.Synopsis
   Empire Cred DB
.DESCRIPTION
   Cred -List    : List Cred DB
   Cred -Add     : Add Creds to DB

   More Info >> Help Cred -Examples
.EXAMPLE
   Empire-Cred
   List all creds
.EXAMPLE
   Cred -Add           <---------------------- ToDo
   Example Description
.NOTES
   Notes
#>
Function Empire-Cred{
    [CmdletBinding(DefaultParameterSetname='CredList',HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('Cred')]
    Param(
		# List all Creds
		[Parameter(Mandatory=0,ParameterSetName='CredList')][switch]$List,
		# Add Creds to DB
		[Parameter(Mandatory=1,ParameterSetName='CredAdd')][switch]$Add,
        # Password to Add
		[Parameter(Mandatory=1,ParameterSetName='CredAdd',Position=0)][String]$domain,
        # Password to Add
		[Parameter(Mandatory=1,ParameterSetName='CredAdd',Position=1)][Alias('host')][String]$computer,
		# UserName to Add
		[Parameter(Mandatory=1,ParameterSetName='CredAdd',Position=2)][Alias('Name','Usr')][String]$username,
        # Password to Add
		[Parameter(Mandatory=1,ParameterSetName='CredAdd',Position=3)][Alias('Pwd')][String]$password,
        # Password to Add
		[Parameter(Mandatory=1,ParameterSetName='CredAdd',Position=4)][String]$credtype,
        # Password to Add
		[Parameter(Mandatory=0,ParameterSetName='CredAdd',Position=5)][String]$notes,
        # Password to Add
		[Parameter(Mandatory=0,ParameterSetName='CredAdd',Position=6)][String]$OS,
        # Password to Add
		[Parameter(Mandatory=0,ParameterSetName='CredAdd',Position=7)][String]$sid
		)
    DynamicParam{
        # Filter ParamSet
        if($PSCmdlet.ParameterSetName -in 'CredList'){
            return DynDico -Name ID -Type Int -Mandat 0 -Pipe 1 -Pos 0 -VSet (DynSession)
            }}
    ## Make It So
    Begin{}
    Process{
        # Session ID
        if($PSBoundParameters.ID.count){$Sess = $PSBoundParameters.ID}
        else{$Sess = $Global:EmpireTarget.ID}
        # Switch Action
        Switch($PSCmdlet.ParameterSetName){
            # List
            CredList{$Result = EmpireCall CredList -id $Sess}
            # Add
            CredAdd {
                $Null = $PSBoundParameters.Remove('Add')
                $Null = $PSBoundParameters.Remove('Verbose')
                $Null = $PSBoundParameters.Remove('Computer')
                $PSBoundParameters.Add('host',"$computer")
                $Opt  = $PSBoundParameters
                $Result = EmpireCall CredAdd -Opt $Opt
                }}}
    ## Return Result
    End{Return $Result}
    }
#end



################################### Empire-Event  <----------------- /!\ upcoming (breaking??) changes /!\

<#
.Synopsis
   Get empire Events
.DESCRIPTION
   Event -view        : View Events for Current Target Agent
   Event -List        : List All Events
   Event -Message     : View event by message term
   Event -type        : View Event by Type

   More Info >> Help Event -Examples
.EXAMPLE
   Empire-Event
   Example Description
.EXAMPLE
   Empire-Event
   Example Description
.NOTES
   Notes
#>
Function Empire-Event{
    [CmdletBinding(DefaultParameterSetname='EventView',HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('Event','Logs')]
    Param(
		# View all Events
		[Parameter(Mandatory=1,ParameterSetName='EventList')][switch]$List,
		# View Agent Event
		[Parameter(Mandatory=0,ParameterSetName='EventView')][switch]$View,
		# View Event Message
		[Parameter(Mandatory=1,ParameterSetName='EventMessage')][Alias('Msg')][Switch]$Message,
        [Parameter(Mandatory=1,ParameterSetName='EventMessage',Position=0,ValueFromRemainingArguments=1)][Alias('Key')][String]$Term,
		# View Event Type
		[Parameter(Mandatory=1,ParameterSetName='EventType')][switch]$Type,
        # Print event recap
		[Parameter(Mandatory=1,ParameterSetName='EventPrint')][switch]$Print
		)
    DynamicParam{
        # Filter ParamSet
        If($PSCmdlet.ParameterSetName -notin 'EventMessage','EventPrint'){
            # Populate Vars
            Switch($PSCmdlet.ParameterSetName){
                #SET        { NAME     ; TYPE       ; MAND ; PIPE ; POS  ; VSET
                #################################################################################...
                EventList   { $N='ID'  ; $T='Int'   ; $M=0 ; $L=0 ; $P=0 ; $V=DynSession                         }
                EventView   { $N='Name'; $T='String'; $M=0 ; $L=1 ; $P=0 ; $V=[Array]$Global:EmpireList.AgentName}
                EventType   { $N='Name'; $T='String'; $M=0 ; $L=0 ; $P=0 ; $V='checkin','task','result','rename'}
                }
        # Return Dico
        return DynDico -Name $N -Type $T -Mandat $M -Pipe $L -Pos $P -VSet $V
        }}
    ## Make It So
    Begin{$Result=@()}
    Process{
        # Switch Action
        Switch($PSCmdlet.ParameterSetName){
            # List All
            EventList{
                if($PSBoundParameters.ID.count){$Sess = $PSBoundParameters.ID}
                else{$Sess = $Global:EmpireTarget.ID}
                $result = EmpireCall EventList -ID $sess | where {$_.message.print}
                }
            # View Agent
            EventView{
                if($PSBoundParameters.Name){$result = EmpireCall EventList | where agentname -eq "agents/$($PSBoundParameters.Name)"}
                else{$result = EmpireCall EventList | where {$_.message.print}}
                }
            # Vew Message
            EventMessage{
                $term = $Term.replace(' ','*')
                $result = EmpireCall EventMessage -Spec $term}
            # View Type
            EventType{$result = EmpireCall EventType -Spec $PSBoundParameters.Name}
            # Event Print
            EventPrint{$result = (EmpireCall EventList).message | ? print | Select timestamp,message}
            }}
    # Return Result
    End{Return $Result}
    }
#end



#################################### Empire-Exec

<#
.Synopsis
   Execute Commands
.DESCRIPTION
   Exec -Command    : Task Agent command [+ Get Results]

   More Info >> Help Exec -Examples
.EXAMPLE
   Empire-Exec -Command Get-Date
   Task target agent command
.EXAMPLE
   Exec 'Get-Date | Select *' -Blind
   Do not wait for results
.EXAMPLE
   Exec 'Get-Date | Select *' -Json
   Return and unpack json >> Yay! Objects
.EXAMPLE
   Agent -list | Exec '(Get-Date).DateTime' -Blind
   Execute command against multiple agents over pipeline
.NOTES
   Vars in double quoted command strings are
   interpreted localy unles escaped (backtick)
#>
Function Empire-Exec{
    [CmdletBinding(DefaultParameterSetname='ExecCommand',HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('Exec','PoSh','xx')]
    Param(
		# Execute Given Command
		[Parameter(Mandatory=1,ParameterSetName='ExecCommand',Position=0)][Alias('Cmd')][string]$Command,
		# No Reply
		[Parameter(Mandatory=0,ParameterSetName='ExecCommand')][Switch]$Json,
        # No Reply
		[Parameter(Mandatory=0,ParameterSetName='ExecCommand')][Alias('NoReply')][switch]$Blind,
		# No Reply
		[Parameter(Mandatory=0,ParameterSetName='ExecCommand')][Alias('Sec')][Int]$MaxWait=10
		)
    DynamicParam{
        return DynDico -Name Name -Type String -Mandat 0 -Pipe 1 -Pos 1 -VSet $Global:EmpireList.AgentName     
        }
    ## Make It So
    Begin{
        $Result = @()
        if($Json){$Command +="|ConvertTo-Json"}
        }
    Process{
        # Name Agent
        if($PSBoundParameters.Name){$Agt=$PSBoundParameters.Name}
        else{$Agt=$Global:EmpireTarget.Agent}
        # Task Agent
        $Reply = EmpireCall AgentExec -Spec $Agt -Opt @{command=$Command}
        if($Reply.success -AND -Not$Blind){
            # Get Task ID
            $LastTask = Empire-Event -Type task -Verbose:$False | ? agentname -match $Agt | select -last 1
            #$LastTask = $Task[$Task.count -1]
            Write-Verbose "$Agt - $($LastTask.message) [TaskID $($LastTask.TaskID)]"
            # MaxWait TaskID Result
            $Loop = 0
            Write-Verbose "$Agt - Waiting for results [max $Maxwait]"
            Do{ Sleep 1
                $LastRes = Empire-Event -Type result -Verbose:$False | ? agentname -match $Agt | Select -last 1
                $Loop ++
            }Until($LastRes.TaskID -eq $LastTask.TaskID -OR $Loop -eq $MaxWait)
            # If too long...
            If($Loop -eq $MaxWait){Write-Warning "$Agt - Skipping Results: Too Slow...";Break}
            # Else result
            Else{
                $Re = (Empire-Result $Agt -Verbose:$False).results
                if($Json){$Re = $Re | Convertfrom-Json}
                $Result += $Re
                }}
        # If Blind or Error
        Else{$Result=$Null}
        }
    ## Return Result
    End{Return $Result}
    }
#end



################################ Empire-Listener

<#
.Synopsis
   Interact with Listeners
.DESCRIPTION
   Listener -View       : View Listener
   Listener -List       : List All Listeners
   Listener -Use        ; Use Specified listener type
   Listener -Option     : Set Listener Option Value
   Listener -Execute    : Start Listener
   Listener -Sync       : Sync Listener List
   Listener -Kill       : Kill Listener
.EXAMPLE
   Listener -Use http
   Select listener

   
   PS C:\>Listener -Option Name MyListener

   Set listener option

   
   PS C:\>Listener -Execute

   Start Listener with set options
.EXAMPLE
   Listener -List
   List all Listeners
.EXAMPLE
   Listener [-View] MyListener
   View specified listener
.EXAMPLE
   Listener -Kill MyListener
   Kill specified listener
.NOTES
   Notes
#>
Function Empire-Listener{
    [CmdletBinding(DefaultParameterSetname='ListenerView',HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('Listener','Lst')]
    Param(
		# List all Listeners
		[Parameter(Mandatory=1,ParameterSetName='ListenerList')][switch]$List,
		# View specified Listener
		[Parameter(Mandatory=0,ParameterSetName='ListenerView')][switch]$View,
		# View Listener Options
		[Parameter(Mandatory=1,ParameterSetName='ListenerUse')][Alias('Load','Select')][switch]$Use,
		# View Listener Options
		[Parameter(Mandatory=1,ParameterSetName='ListenerOption')][switch]$Option,
        # New Listener
		[Parameter(Mandatory=1,ParameterSetName='ListenerNew')][Alias('New','X','Start')][switch]$Execute,
		# Sync Listener List
		[Parameter(Mandatory=1,ParameterSetName='ListenerSync')][switch]$Sync,
		# Kill specified Listener
		[Parameter(Mandatory=1,ParameterSetName='ListenerKill')][Alias('Delete')][switch]$Kill,
        # Listener type to use
        [Parameter(Mandatory=1,ParameterSetName='ListenerUse',Position=0)][ListenerType]$Type
		)
    DynamicParam{
        # Filter ParamSet
        if($PSCmdlet.ParameterSetName -in 'ListenerView','ListenerKill','ListenerList'){
            # Populate Vars
            Switch($PSCmdlet.ParameterSetName){
                #SET        { NAME     ; TYPE       ; MAND ; PIPE ; POS  ; VSET
                ########################################################################...
                ListenerKill{ $N='Name'; $T='String'; $M=1 ; $L=0 ; $P=0 ; $V=$Global:EmpireList.ListenerName}
                ListenerView{ $N='Name'; $T='String'; $M=0 ; $L=0 ; $P=0 ; $V=$Global:EmpireList.ListenerName}
                ListenerList{ $N='ID'  ; $T='Int'   ; $M=0 ; $L=1 ; $P=0 ; $V=DynSession}
                }
            # Return Dico
            return DynDico -Name $N -Type $T -Mandat $M -Pipe $L -Pos $P -VSet $V
            }
        if($PSCmdlet.ParameterSetName -eq 'ListenerOption'){
            ## Prep Empty Dico
            $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
            ## Name
            # Create Attribute Obj
            $VSet = $Global:EmpireList.temp.Name
            $Attrb = New-Object Management.Automation.ParameterAttribute
            $Attrb.Mandatory=0
            $Attrb.Position=0
            # Create AttributeCollection
            $Cllct = New-Object Collections.ObjectModel.Collection[System.Attribute]
            # Add Attribute Obj to Collection
            $Cllct.Add($Attrb)
            # Create ValidateSet & add to collection     
            $VldSt=New-Object Management.Automation.ValidateSetAttribute($VSet)
            $Cllct.Add($VldSt)
            # Create Runtine DynParam
            $DynPar = New-Object Management.Automation.RuntimeDefinedParameter('Name',[String],$Cllct)
            # Add dynParam to Dictionary
            $Dico.Add('Name',$DynPar)      
            ## Value
            # Create Attribute Obj for Value
            $Attrb1 = New-Object Management.Automation.ParameterAttribute
            $Attrb1.Mandatory=0
            $Attrb1.Position=1
            # Create AttributeCollection
            $Cllct1 = New-Object Collections.ObjectModel.Collection[System.Attribute]
            # Add Attribute Obj to Collection
            $Cllct1.Add($Attrb1)
            # AllowEmptyString & add to collection     
            $EStr=New-Object Management.Automation.AllowEmptyStringAttribute
            $Cllct1.Add($EStr)
            # Create Runtine DynParam
            $DynVal = New-Object Management.Automation.RuntimeDefinedParameter('Value',[String],$Cllct1)
            # Add dynVal to Dictionary
            $Dico.Add('Value',$DynVal) 
            ## Return Dico
            Return $Dico
            }}
    ## Make It So
    Begin{$Result=@()}
    Process{
        # Switch Action
        Switch($PSCmdlet.ParameterSetName){
            ## Sync
            ListenerSync{Empire-Sync -Listener}
            ## List
            ListenerList{
                if($PSBoundParameters.ID.Count){$Sess = $PSBoundParameters.ID}
                else{$Sess = $Global:EmpireTarget.ID}
                $Result = EmpireCall ListenerList -ID $Sess
                # Sync Obj
                $Global:EmpireList.ListenerName = $Result.Name
                }
            ## View
            ListenerView{
                if($PSBoundParameters.Name){
                    $result = EmpireCall ListenerView -Spec $PSBoundParameters.Name
                    }
                else{$Result=Empire-Listener -list}
                }
            ## Use 
            ListenerUse{
                $Result =  EmpireCall ListenerOptions -Spec $Type | UnpackOptions | Select Name,Description,Required,Value
                if($Use){
                    $Global:EmpireList.Temp = $Result
                    $Global:EmpireList.TempType = $Type
                    Return <#NoOut#>
                    }}
            ## Option
            ListenerOption{
                # View
                if(-Not$DynPar.IsSet -and -Not$DynVal.IsSet){$Result = $Global:EmpireList.Temp}
                # Set
                elseif($DynPar.IsSet -and $DynVal.IsSet){($Global:EmpireList.Temp|? Name -eq $DynPar.Value).Value = $DynVal.Value}
                # Warning
                else{Write-Warning "Must Specify Value"}
                }
            ## New
            ListenerNew{
                if(WarnMissing $Global:EmpireList.temp){Return}
                $Obj = New-Object PSCustomObject
                $Tmp = $Global:EmpireList.temp | ? Value | Select Name,Value
                $Tmp | %{$Obj | Add-Member NoteProperty -Name $_.Name -Value "$($_.Value)"}
                $result = EmpireCall ListenerNew -Spec $($Global:EmpireList.TempType -as [String]) -Opt $Obj
                }
            ## Kill
            ListenerKill{$Result = EmpireCall ListenerKill -Spec $PSBoundParameters.Name}
            }}
    ## Return Result
    End{if(-Not$Use){Return $Result}}
    }
#end



#################################### Empire-Help

<#
.Synopsis
   Empire Help
.DESCRIPTION
    Cmdlet          Synopsis                           Help         
    ------          --------                           ----         
    Empire-Admin    Empire Admin Stuff                 Help Admin   
    Empire-Agent    Interact with Empire Agents        Help Agent   
    Empire-Cred     Interact with Empire Cred DB       Help Cred    
    Empire-Event    View Empire Events                 Help Event   
    Empire-Exec     Execute Commands on agent          Help Exec    
    Empire-Help     View EmpireStrike Cheat Sheet      Help Empire  
    Empire-Listener Interact with Empire Listeners     Help Listener
    Empire-Module   Interact with Empire Modules       Help Mod     
    Empire-Option   Set Module Options                 Help Option  
    Empire-Result   Get Agent result                   Help Result  
    Empire-Search   Empire Module Search               Help Search  
    Empire-Session  Interact with Empire Sessions      Help Session 
    Empire-Sniper   Shoot from Scriptpane (ISE/VSCode) Help Sniper  
    Empire-Speak    Add Voice to Automations           Help Speak   
    Empire-Stager   Interact with Empire Stagers       Help Stager  
    Empire-Strike   Execute Empire Modules             Help Strike  
    Empire-Sync     Sync Empire Objects                Help Sync    
    Empire-Target   View/Set Target                    Help Target  
    Empire-Tune     Play Imperial March                Help Tune    
    Empire-Use      USelect Stager|Listener|Module     Help Use     
    Empire-View     View Empire Objects                Help View
.EXAMPLE
   Empire
.NOTES
   See each Cmdlet Help pages for detailed help
#>
function Empire-Help{
    [CmdletBinding(HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('Empire')]
    Param()
    $CmdList=@(#######################################################################################
    # CMDLET                   | SYNOPSIS                                      | HELP                |
    ##################################################################################################
    @{Cmdlet='Empire-Admin'    ; Synopsis='Empire Admin Stuff'                 ; Help='Help Admin'   }
    @{Cmdlet='Empire-Agent'    ; Synopsis='Interact with Empire Agents'        ; Help='Help Agent'   }
    @{Cmdlet='Empire-Cred'     ; Synopsis='Interact with Empire Cred DB'       ; Help='Help Cred'    }
    @{Cmdlet='Empire-Event'    ; Synopsis='View Empire Events'                 ; Help='Help Event'   }
    @{Cmdlet='Empire-Exec'     ; Synopsis='Execute Commands on agent'          ; Help='Help Exec'    }
    @{Cmdlet='Empire-Help'     ; Synopsis='View EmpireStrike Cheat Sheet'      ; Help='Help Empire'  }
    @{Cmdlet='Empire-Listener' ; Synopsis='Interact with Empire Listeners'     ; Help='Help Listener'}
    @{Cmdlet='Empire-Module'   ; Synopsis='Interact with Empire Modules'       ; Help='Help Mod'     }
    @{Cmdlet='Empire-Option'   ; Synopsis='Set Module Options'                 ; Help='Help Option'  }
    @{Cmdlet='Empire-Result'   ; Synopsis='Get Agent result'                   ; Help='Help Result'  }
    @{Cmdlet='Empire-Search'   ; Synopsis='Empire Module Search'               ; Help='Help Search'  }
    @{Cmdlet='Empire-Session'  ; Synopsis='Interact with Empire Sessions'      ; Help='Help Session' }
    @{Cmdlet='Empire-Sniper'   ; Synopsis='Shoot from Scriptpane (ISE/VSCode)' ; Help='Help Sniper'  }
    @{Cmdlet='Empire-Speak'    ; Synopsis='Add Voice to Automations'           ; Help='Help Speak'   }
    @{Cmdlet='Empire-Stager'   ; Synopsis='Interact with Empire Stagers'       ; Help='Help Stager'  }
    @{Cmdlet='Empire-Strike'   ; Synopsis='Execute Empire Modules'             ; Help='Help Strike'  }
    @{Cmdlet='Empire-Sync'     ; Synopsis='Sync Empire Objects'                ; Help='Help Sync'    }
    @{Cmdlet='Empire-Target'   ; Synopsis='View/Set Target'                    ; Help='Help Target'  }
    @{Cmdlet='Empire-Tune'     ; Synopsis='Play Imperial March'                ; Help='Help Tune'    }
    @{Cmdlet='Empire-Use'      ; Synopsis='Select Stager|Listener|Module'      ; Help='Help Use'     }
    @{Cmdlet='Empire-View'     ; Synopsis='View Empire Objects'                ; Help='Help View'    }
    ##################################################################################################
    )
    # Return Help Obj
    Return $CmdList | %{New-Object PSCustomObject -Property $_} | Select Cmdlet,Synopsis,Help
    }
#End



################################## Empire-Module

<#
.Synopsis
   Interact with Empire Modules
.DESCRIPTION
   Mod -View     : View Module
   Mod -List     : List all Modules
   Mod -Sync     : Sync Module List
   Mod -Target   : Set target module
.EXAMPLE
   Empire-Module PowerShell trollsploit rick_astley
   View single Module details
   Tab-completes all the way
.EXAMPLE
   Mod PowerShell trollsploit rick_astley -Target
   Set as strike module
   Use Empire-Option to view selected module options
.EXAMPLE
   Mod -List
   List all modules
.EXAMPLE
   Mod -Sync
   Sync local module Object
.NOTES
   Cannot use 'module' as alias (because of existing Get-Module cmdlet)
   so alias is 'mod' or 'modul' (Tab-completes first... :)
#>
Function Empire-Module{
    [CmdletBinding(DefaultParameterSetname='ModuleView',HelpUri='https://github.com/EmpireProject/Empire/wiki'<#,Positionalbinding=0#>)]
    [Alias('Modul','Mod')]
    Param(
		# List all Modules
		[Parameter(Mandatory=1,ParameterSetName='ModuleList')][switch]$List,
		# View Module
		[Parameter(Mandatory=0,ParameterSetName='ModuleView')][switch]$View,
		# Sync Module Object
		[Parameter(Mandatory=1,ParameterSetName='ModuleSync')][switch]$Sync,
		# Module Language
        [ValidateSet('PowerShell','Python')]
        [Parameter(Mandatory=0,ParameterSetName='ModuleList',Position=0)]
        [Parameter(Mandatory=1,ParameterSetName='ModuleView',Position=0)][Alias('Language')][string]$Lang,
		# Module Category
        [Parameter(Mandatory=0,ParameterSetName='ModuleList',Position=1)]
        [Parameter(Mandatory=1,ParameterSetName='ModuleView',Position=1)][Alias('Category')][ModuleCategory]$Cat,
        # Set Target Module
        [Parameter(Mandatory=0,ParameterSetName='ModuleView')]
		[Parameter(Mandatory=1,ParameterSetName='ModuleTarget')][Alias('Tgt','Load','X','Use','Select')][switch]$Target
        )
    # Dyn
    DynamicParam{
        # Filter ParamSet View
        if($PSCmdlet.ParameterSetName -eq 'ModuleView'){
            # Return Dico
            return DynDico -Name Name -Type String -Mandat 1 -Pipe 0 -Pos 2 -VSet (MFilter -Lang $lang -Cat $Cat.ToString())
            }
        # Filter ParamSet Target      
        if($PSCmdlet.ParameterSetName -eq 'ModuleTarget'){
            return DynDico -Name Name -Type String -Mandat 1 -Pipe 1 -Pos 1 -VSet ([Array]$Global:EmpireList.ModuleName)
            }}
    ## Make It So
    Begin{}
    Process{
        # Switch Action
        Switch($PSCmdlet.ParameterSetName){
            ## List
            ModuleList{
                $Result = $EmpireList.Module
                if($Lang){$Result = $Result | ? Language -eq $Lang}
                if($Cat){$Result = $Result | ? {$_.Name -match $Cat.toString().tolower()}}
                }
            ## View
            ModuleView{ 
                $FullName = ''+$Lang.ToLower()+'/'+$Cat.toString().ToLower()+'/'+$PSBoundParameters.name
                if($Target){
                    $Global:EmpireStrike.Module = $FullName
                    $Global:EmpireStrike.Option = $Global:EmpireList.Module|? Name -eq $FullName | UnpackOptions}
                else{$Result = $Global:EmpireList.Module | ? {$_.Name -eq $FullName}}
                }
            ## Sync
            ModuleSync{Empire-Sync -Module}
            ## Target
            ModuleTarget{
                $Global:EmpireStrike.Module = $PSBoundParameters.name
                $Global:EmpireStrike.Option = $Global:EmpireList.Module|? Name -eq $PSBoundParameters.name | UnpackOptions
                }}}
    ## Return Result
    End{Return $Result}
    }
#end



################################## Empire-Option

<#
.Synopsis
   Strike Module Option
.DESCRIPTION
   Set/View Strike Module Options

   More Info >> Help Option -Examples
.EXAMPLE
   Option
   View All options
.EXAMPLE
   Option <Name> <Value>
   Set Option Value
.NOTES
   Module must be selected first
   Option names tab-complete
   Setting Agent option is not nescessary (passed by Strike command)
#>
Function Empire-Option{
    [CmdletBinding(HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('Option','Opt','Set')]
    Param()
    DynamicParam{
        ## Prep Empty Dico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        ## Name
        # Create Attribute Obj
        $VSet = $Global:EmpireStrike.Option.name
        $Attrb = New-Object Management.Automation.ParameterAttribute
        $Attrb.Mandatory=0
        $Attrb.Position=0
        # Create AttributeCollection
        $Cllct = New-Object Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Collection
        $Cllct.Add($Attrb)
        # Create ValidateSet & add to collection     
        $VldSt=New-Object Management.Automation.ValidateSetAttribute($VSet)
        $Cllct.Add($VldSt)
        # Create Runtine DynParam
        $DynPar = New-Object Management.Automation.RuntimeDefinedParameter('Name',[String],$Cllct)
        # Add dynParam to Dictionary
        $Dico.Add('Name',$DynPar)      
        ## Value
        # Create Attribute Obj for Value
        $Attrb1 = New-Object Management.Automation.ParameterAttribute
        $Attrb1.Mandatory=0
        $Attrb1.Position=1
        # Create AttributeCollection
        $Cllct1 = New-Object Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Collection
        $Cllct1.Add($Attrb1)
        # AllowEmptyString & add to collection     
        $EStr=New-Object Management.Automation.AllowEmptyStringAttribute
        $Cllct1.Add($EStr)
        # Create Runtine DynParam
        $DynVal = New-Object Management.Automation.RuntimeDefinedParameter('Value',[String],$Cllct1)
        # Add dynVal to Dictionary
        $Dico.Add('Value',$DynVal) 
        ## Return Dico
        Return $Dico
        }
    ## Make It So
    Begin{}
    Process{
        # View
        if(-Not$DynPar.IsSet -AND -Not$DynVal.IsSet){$Result = $Global:EmpireStrike.Option}
        # Warning
        if($DynPar.IsSet -AND -Not$DynVal.IsSet){Write-Warning "Specify Option Value"}
        # Set
        if($DynPar.IsSet -AND $DynVal.IsSet){
            ($Global:EmpireStrike.Option|? Name -eq $DynPar.Value).Value = $DynVal.Value
            }}
    ## Return Result
    End{Return $Result}
    }
#end



################################## Empire-Result

<#
.Synopsis
   Empire Result
.DESCRIPTION
   Get Agent Results
   defaults to last result unless -List
.EXAMPLE
   Result
   Get last result from target agent
.EXAMPLE
   Result ABCDEFGH
   Get last result from specified agent
.EXAMPLE
   Result ABCDEFGH -List
   Get all results for specifed agent
.EXAMPLE
   $AgentList | Result
   Get last result from several agents
.NOTES
   Supports agent list over pipeline
#>
function Empire-Result{
    [CmdletBinding(HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('Result')]
    Param([Parameter()][Alias('All')][Switch]$List)
    DynamicParam{Return DynDico -N Name -Type String -Mandat 0 -Pipe 1 -Pos 0 -VSet $Global:EmpireList.AgentName}
    ## Make It So
    Begin{$Result=@()}
    Process{
        if($PSBoundParameters.Name){$Agt = $PSBoundParameters.Name}
        else{$Agt = $Global:EmpireTarget.Agent}
        $Res = (EmpireCall AgentResult -Spec $Agt).AgentResults
        $OldRes = $res
        try{$res = $Res | ConvertFrom-Json -ErrorAction SilentlyContinue}catch{$res = $OldRes}
        if($Res -AND -Not$List){$Res = ($Res[$Res.count -1])}
        $Result += $res
        }
    ## Return Result
    End{if($Result){Return $Result | Select TaskID,Results,Command}}
    }
#end



################################## Empire-Search

<#
.Synopsis
   Search Modules / Agents
.DESCRIPTION
   Search for matching term(s) in
   -Module Name
   -Module Description
   -Module Author
   -Module Comment

   More Info: Help Search -Examples
.EXAMPLE
   Search dll
   Search term in module name
.EXAMPLE
   Search -description dll | select name
   Search term in module description
.EXAMPLE
   Search -Author mattifestation | select name,description
   Search by author
.NOTES
   Search term can be multi word
   Spaces are repalced by wildcard for search
   Ex: search dll jack
#>
function Empire-Search{
    [CmdletBinding(HelpUri='https://github.com/EmpireProject/Empire/wiki',DefaultParameterSetName='SearchName')]
    [Alias('Search','Src')]
    Param(
        # Module Name (No Quotes)
        [Parameter(Mandatory=1,ValueFromRemainingArguments=1,Position=0)][String]$Term,
        # Field to Search
        [Parameter(Mandatory=1,ParameterSetName='SearchDesc')][Switch]$Description,
        [Parameter(Mandatory=1,ParameterSetName='SearchAuth')][Switch]$Author,
        [Parameter(Mandatory=1,ParameterSetName='SearchComm')][Switch]$Comment,
        [Parameter(Mandatory=0,ParameterSetName='SearchName')][Switch]$Name,
        [Parameter(Mandatory=1,ParameterSetName='SearchUser')][Switch]$User,
        [Parameter(Mandatory=1,ParameterSetName='SearchComputer')][Switch]$Computer,
        # Set as Target
        [Parameter(Mandatory=0)][Alias('Tgt','Load','x','Use','Select')][Switch]$Target
        )
        # Term to Regex
        $Rgx = ".*$($Term.replace(' ','.*')).*"
        # If search user
        if($PSCmdlet.ParameterSetName -in 'SearchUser','SearchComputer'){
            $Result = @()
            if($User){$opt='username'}
            if($Computer){$opt='hostname'}
            # for each session in sessin list
            # Add match to result
            foreach($Sess in (Empire-Session -list)){
                empire-agent -list -ID $Sess.ID | where $opt -match "$Rgx" | %{
                    $Result += New-Object PSCustomObject -Prop @{
                        ID = $Sess.ID
                        Name = $_.name
                        UserName = $_.username
                        ComputerName = $_.hostname
                        LastSeen_Time = $_.lastseen_time
                        }
                    }
                }
            if($Target){
                # Switch Result Count
                Switch($Result.name.Count){
                    # No Match
                    0 {Write-Warning "No Match - Can't Target."}
                    # Single Match
                    1 {Empire-Session -Target -ID $($result.ID)
                       Empire-Agent -Target -Name $($result.name)}
                    # Multiple Match
                    Default{Write-Warning "Multiple Match - Can't Target."}
                    }
                }
            $Result = $Result | Select ID,Name,UserName,ComputerName,LastSeen_Time
            }
        # If not search user
        else{
            # Regex
            $Rgx = ".*$($Term.replace(' ','.*')).*"
            # Switch Field
            Switch($PSCmdlet.ParameterSetName){
                SearchDesc {$Result = $Global:EmpireList.Module| ? Description -match $Rgx}
                SearchAuth {$Result = $Global:EmpireList.Module| ? Author -match $Rgx}
                SearchComm {$Result = $Global:EmpireList.Module| ? Comments -match $Rgx}
                SearchName {$Result = $Global:EmpireList.Module| ? Name -match $Rgx}
                }
            # If target
            if($Target){
                # Switch Result Count
                Switch($Result.name.Count){
                # No Match
                0 {Write-Warning "No Match - Can't Target."}
                # Single Match
                1 { $Global:EmpireStrike.Module = $Result.name
                <##>$Global:EmpireStrike.Option = $Global:EmpireList.Module|? Name -eq $Result.name | UnpackOptions| ? name -ne Agent}
                # Multiple Match
                Default{Write-Warning "Multiple Match - Can't Target."}
                }
            }
        }
    ## Return Result
    if($Target -AND $User){return $Result}
    if(-Not$Target){return $Result}
    }
#end




################################# Empire-Session

<#
.Synopsis
   Interact with Session
.DESCRIPTION
   Long Description
.EXAMPLE
   Empire-Session
   View current session
.EXAMPLE
   Session -List
   View all sessions
.EXAMPLE
   Session 1
   View session ID 1
.EXAMPLE
   Session 1 -target
   Switch to session 1

.NOTES
   Notes
#>
Function Empire-Session{
    [CmdletBinding(DefaultParameterSetname='SessionView',HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('Session','Ses')]
    Param(
		# View Session
		[Parameter(Mandatory=0,ParameterSetName='SessionView')][switch]$View,
		# Sync Session Vars
		[Parameter(Mandatory=1,ParameterSetName='SessionSync')][switch]$Sync,
		# List Sessions
		[Parameter(Mandatory=1,ParameterSetName='SessionList')][switch]$List,
		# Target Session
		[Parameter(Mandatory=1,ParameterSetName='SessionTarget')][Alias('Tgt','Select')][switch]$Target,
		# Connect New Session
		[Parameter(Mandatory=0,ParameterSetName='SessionNew')][switch]$New,
		# Server IP
		[Parameter(Mandatory=1,ParameterSetName='SessionNew')][Alias('Srv','Host')][string]$Server,
		# UserName
		[Parameter(Mandatory=0,ParameterSetName='SessionNew')][Alias('Usr','Name')][string]$User,
		# Server Port
		[Parameter(Mandatory=0,ParameterSetName='SessionNew')][int]$Port,
		# No SSL Check
		[Parameter(Mandatory=0,ParameterSetName='SessionNew')][switch]$NoSSL,
        # Remove Session
        [Parameter(Mandatory=1,ParameterSetName='SessionRemove')][switch]$Remove,
        [Parameter(Mandatory=0,ParameterSetName='SessionRemove')][switch]$Fix
        )
    DynamicParam{
        # Filter ParamSet
        if($PSCmdlet.ParameterSetName -in 'SessionTarget','SessionView','SessionRemove'){
            # Return Dico
            return DynDico -Name 'ID' -Type 'Int' -Mandat 0 -Pipe 1 -Pos 0 -VSet (DynSession)    
            }}
    ## Make It So
    Begin{$Result=@()}
    Process{
        if($PSCmdlet.ParameterSetName -in 'SessionTarget','SessionView'){
            if($PSBoundParameters.ID.count){$Sess = $PSBoundParameters.ID}
            else{$Sess = $Global:EmpireTarget.ID}        
            }
        # Switch Action
        Switch($PSCmdlet.ParameterSetName){
            ## View
            SessionView{$Global:EmpireSession | ? ID -eq $Sess | Select ID,Host,Port,Token}
            ## Sync
            SessionSync{Sync -Session}
            ## List
            SessionList{$Global:EmpireSession|Select ID,Host,Port,Token}
            # Target
            SessionTarget{Empire-Target -Session $Sess}
            ## New
            SessionNew{
                $Null = $PSBoundParameters.Remove('New')
                $Result = EmpireConnect @PSBoundParameters
                if($result.Token){AutoSession -ID ($Global:EmpireSession.Count -1)}
                }
            ## Remove
            SessionRemove{
                If(-Not$PSBoundParameters.ID.Count){Write-Warning "Specify Session ID"}
                Else{
                    $Global:EmpireSession.Remove(($Global:EmpireSession |? ID -eq $PSBoundParameters.ID))
                    if($Fix){FixSession; Write-Warning "Target Session set to 0";$Global:EmpireTarget.ID=0}
                    }}}}
    ## Return Result
    End{Return $Result}
    }
#end



################################## Empire-Sniper

<#
.Synopsis
   Empire Sniper
.DESCRIPTION
   SpriptPane Sniper Mode 
   works in ISE and VSCode
.EXAMPLE
   Sniper 4 -Json
.EXAMPLE
   $AgentList | xxx 3,7 -Blind
.NOTES
   Multiline selection adds a semi-colon at end of each line
   Can break syntax on line breaks
#>
Function Empire-Sniper{
    [CmdletBinding(DefaultParameterSetName='Line')]
    [Alias('Sniper','xxx')]
    Param(
        [ValidateCount(1,2)]
        [Parameter(Mandatory=1,Position=0,ParameterSetName='Line')][Int[]]$Line,
        [Parameter(Mandatory=0,ParameterSetName='Select')][Switch][Alias('S')]$Selection,
        [Parameter(Mandatory=0)][Switch]$Blind,
        [Parameter(Mandatory=0)][Switch]$Json
        )
    DynamicParam{
        # Return Dico
        return DynDico -Name Name -Type String -Mandat 0 -Pipe 1 -Pos 1 -VSet ([Array]$Global:EmpireList.AgentName)    
        }
    ## Make It So
    Begin{
        # Empry Collector
        $Result = @()
        # Line To
        if($Line){
            $From = $Line[0]
            if($Line.count -eq 1){$To = $From}
            else{$To=$Line[1]}
            }
        # Get Text
        Switch -Regex($Host.name){
            # If ISE
            'ISE Host'{
                $Editor = $psISE.CurrentFile.Editor
                # If by Line number
                if($Line){
                    $Editor.Select($From,1,$To,$Editor.GetLineLength($To)+1)
                    $psISE.CurrentPowerShellTab.ConsolePane.Focus()
                    $TXT = $Editor.SelectedText
                    }
                # If by Selection
                if($Selection){$TXT = $Editor.SelectedText}
                }
            # If VSCode
            'Visual Studio'{
                $Editor = $psEditor.GetEditorContext()
                # If by Line number
                if($Line){
                    # Highlight
                    $Editor.SetSelection($from,1,$To+1,1)
                    # Get full text
                    if($Line.count -eq 2){$TXT = ($Editor.CurrentFile.GetTextLines())[($from-1)..($to-1)]}
                    else{$TXT = ($Editor.CurrentFile.GetTextLines())[$from-1]}
                    }
                # If by Selection
                if($Selection){}
                }}
        # Text to single String
        $CmdString = ($TXT.split("`n").trim()|?{$_-ne''}|?{$_-notmatch"^#"})-join';'
        if($CmdString -eq ''){$Flag=$true;Write-Warning 'No Command String...'}
        }
    Process{
        if($Flag){Return}
        # Target
        if($PSBoundParameters.Name){$Agt=$PSBoundParameters.Name}
        else{$Agt=$Global:EmpireTarget.Agent}
        $Switchz = $PSBoundParameters
        $Null = ($Switchz).remove('Line')
        $Null = ($Switchz).remove('Name')
        # Blind or not
        if($Blind){Empire-Exec -Command $CmdString -Name $Agt @Switchz}
        else{$Result += Empire-Exec -Command $CmdString -Name $Agt @Switchz}
        }
    ## Return Result
    End{Return $Result}
    }
#End


################################### Empire-Speak

<#
.Synopsis
   Empire Speak
.DESCRIPTION
   Add Speech to Automations
.EXAMPLE
   Say I am Your Father...
.NOTES
   Notes
#>
function Empire-Speak{
    [CmdletBinding(HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('Speak','Say')]
    Param(
        # Message
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0,valuefromremainingarguments=1)]
        [ValidateNotNull()][String[]]$Speech,
        # Return prompt without waiting
        [switch]$Async,
        # Speech Volume
        [ValidateRange(0,100)][int]$Volume=100,
        # Speech Rate
        [ValidateRange(-10,10)][int]$Rate=-1    
        )
    DynamicParam{
        # Get installed voices (name only)
        $ValSet = @()
        (New-Object System.Speech.Synthesis.SpeechSynthesizer).GetInstalledVoices().voiceinfo.name | %{$ValSet += $_.split(' ')[1]}
        ## Dictionary
        # Create runtime Dictionary for this ParameterSet
        $Dico = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Dyn1
        # Create Attribute Object
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $false
        $Attrib.HelpMessage = "Select voice"
        # Create AttributeCollection object for the attribute Object
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add our custom attribute to collection
        $Collection.Add($Attrib)
        # Add Validate Set to attribute collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($ValSet)
        $Collection.Add($ValidateSet)
        # Create Runtime Parameter with matching attribute collection
        $DynP = New-Object System.Management.Automation.RuntimeDefinedParameter('Voice', [String], $Collection)
        # Add Runtime Param to dictionary
		$Dico.Add('Voice',$dynP)
        ## Return Dico
        Return $Dico
        }
    ## Make It So
    Begin{
        # Create speech object
        $SpeechSynth = New-Object System.Speech.Synthesis.SpeechSynthesizer
        # Voice full name
        if($DynP.IsSet){
            $Voice = "Microsoft $($DynP.Value) Desktop"
            }
        Else{$voice=$SpeechSynth.GetInstalledVoices().VoiceInfo.name[0]}
        # Adjust voice settings
        $SpeechSynth.SelectVoice($Voice)
        $SpeechSynth.volume=$Volume
        $SpeechSynth.Rate=$Rate
        }
    Process{
        # if -Async
        if($Async){$SpeechSynth.SpeakAsync($Speech) | Out-Null}
        # else
        else{$SpeechSynth.Speak($Speech) | out-null}
        }
    ## NoOut
    End{<#NoOut#>}
    }
#end



################################## Empire-Stager

<#
.Synopsis
   Interact with Stagers
.DESCRIPTION
   Long Description
.EXAMPLE
   Empire-Stager
   Example Description
.EXAMPLE
   Empire-Stager
   Example Description
.NOTES
   Notes
#>
Function Empire-Stager{
    [CmdletBinding(DefaultParameterSetname='StagerView',HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('Stager','Stg')]
    Param(
		# List Stager
		[Parameter(Mandatory=1,ParameterSetName='StagerList')][switch]$List,
		# View Stager Type
		[Parameter(Mandatory=0,ParameterSetName='StagerView')][switch]$View,
		# Use Stager Type (temp memory)
		[Parameter(Mandatory=1,ParameterSetName='StagerUse')][Alias('Load','Select')][switch]$Use,
		# Set  Stager Option
		[Parameter(Mandatory=1,ParameterSetName='StagerOption')][Alias('Set')][switch]$Option,
		# Generate Stager from Options
		[Parameter(Mandatory=1,ParameterSetName='StagerNew')][Alias('New','X')][switch]$Generate,
		# New Stager to clipboard
		[Parameter(Mandatory=0,ParameterSetName='StagerNew')][Alias('Clip')][switch]$ToClipboard,
		# Sync Stager Type List
		[Parameter(Mandatory=1,ParameterSetName='StagerSync')][switch]$Sync
		)
    DynamicParam{
        # Filter ParamSet
        if($PSCmdlet.ParameterSetName -in 'StagerView','StagerUse'){
            # Return Dico
            return DynDico -Name Type -Type String -Mandat 1 -Pipe 0 -Pos 0 -VSet $Global:EmpireList.StagerType    
            }
      <#if($PSCmdlet.ParameterSetName -eq 'StagerNew'){
            # Return Dico
            return DynDico -Name Type -Type String -Mandat 1 -Pipe 0 -Pos 0 -VSet $Global:EmpireList.ListenerName    
            }#>
        if($PSCmdlet.ParameterSetName -eq 'StagerList'){
            # Return Dico
            return DynDico -Name ID -Type Int -Mandat 0 -Pipe 1 -Pos 0 -VSet (DynSession)
            }
        if($PSCmdlet.ParameterSetName -eq 'StagerOption'){
            ## Prep Empty Dico
            $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
            ## Name
            # Create Attribute Obj
            $VSet = $Global:EmpireList.temp.Name
            $Attrb = New-Object Management.Automation.ParameterAttribute
            $Attrb.Mandatory=0
            $Attrb.Position=0
            # Create AttributeCollection
            $Cllct = New-Object Collections.ObjectModel.Collection[System.Attribute]
            # Add Attribute Obj to Collection
            $Cllct.Add($Attrb)
            # Create ValidateSet & add to collection     
            $VldSt=New-Object Management.Automation.ValidateSetAttribute($VSet)
            $Cllct.Add($VldSt)
            # Create Runtine DynParam
            $DynPar = New-Object Management.Automation.RuntimeDefinedParameter('Name',[String],$Cllct)
            # Add dynParam to Dictionary
            $Dico.Add('Name',$DynPar)      
            ## Value
            # Create Attribute Obj for Value
            $Attrb1 = New-Object Management.Automation.ParameterAttribute
            $Attrb1.Mandatory=0
            $Attrb1.Position=1
            # Create AttributeCollection
            $Cllct1 = New-Object Collections.ObjectModel.Collection[System.Attribute]
            # Add Attribute Obj to Collection
            $Cllct1.Add($Attrb1)
            # AllowEmptyString & add to collection     
            $EStr=New-Object Management.Automation.AllowEmptyStringAttribute
            $Cllct1.Add($EStr)
            # Create Runtine DynParam
            $DynVal = New-Object Management.Automation.RuntimeDefinedParameter('Value',[String],$Cllct1)
            # Add dynVal to Dictionary
            $Dico.Add('Value',$DynVal) 
            ## Return Dico
            Return $Dico
            }}
    ## Make It So
    Begin{$Result=@()}
    Process{
        # Switch Action
        Switch($PSCmdlet.ParameterSetName){
            ## List
            StagerList{
                # Session
                if($PSBoundParameters.ID.Count){$Sess = $PSBoundParameters.ID}
                else{$Sess = $Global:EmpireTarget.ID}
                $Result = EmpireCall StagerList -ID $Sess
                }
            ## View Type
            StagerView{$Result = EmpireCall StagerView $PSBoundParameters.Type}
            # Use (Temp)
            StagerUse{
                $Global:EmpireList.TempType = $PSBoundParameters.Type 
                $Global:EmpireList.Temp = EmpireCall StagerView $PSBoundParameters.Type | UnpackOptions
                }
            ## Option
            StagerOption{
                if(-Not$DynPar.IsSet -and -Not$DynVal.IsSet){$Result = $Global:EmpireList.Temp}
                elseif($DynPar.IsSet -and $DynVal.IsSet){($Global:EmpireList.Temp|? Name -eq $DynPar.Value).Value = $DynVal.Value}
                else{Write-Warning "Please Specify Value"}
                }
            ## New
            StagerNew{
                $Tp = $Global:EmpireList.TempType
                $Obj = New-Object PSCustomObject -Property @{StagerName = $Tp}
                $Global:EmpireList.Temp |Select Name,Value|? Value -ne ''|%{$Obj|Add-Member NoteProperty -Name $_.Name -Value "$($_.Value)"}
                $Result = (EmpireCall StagerNew -Opt $Obj).$Tp.Output
                # If Clipboard
                if($ToClipboard){$Result|Set-ClipBoard; $Result=$Null}
                }
            ## Sync
            StagerSync{$Result = Empire-Sync -Stager}
            }}
    ## Return Result
    End{Return $Result}
    }
#end



################################## Empire-Strike

<#
.Synopsis
   Empire Strike
.DESCRIPTION
   Long Description
.EXAMPLE
   Empire-Strike
   Example Description
.EXAMPLE
   Empire-Strike
   Example Description
.NOTES
   Notes
#>
Function Empire-Strike{
    [CmdletBinding(DefaultParameterSetname='StrikeView',HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('Strike','X')]
    Param(
		# View Strike
		[Parameter(Mandatory=0,ParameterSetName='StrikeView')][switch]$View,
		# View Strike
		[Parameter(Mandatory=0,ParameterSetName='StrikeView')][switch]$Option,
		# Launch Strike
		[Parameter(Mandatory=1,ParameterSetName='StrikeX')][switch]$x,
		# No Reply
		[Parameter(Mandatory=0,ParameterSetName='StrikeX')][Alias('NoReply')][switch]$Blind,
		# No Reply
		[Parameter(Mandatory=0,ParameterSetName='StrikeX')][Alias('Sec')][Int]$MaxWait=30     
		)
    DynamicParam{
        # Filter ParamSet
        if($PSCmdlet.ParameterSetName -eq 'StrikeX'){
            # Return Dico
            return DynDico -Name Name -Type String -Mandat 0 -Pipe 1 -Pos 0 -VSet $Global:EmpireList.AgentName   
            }}
    ## Make It So
    Begin{$Result=@()}
    Process{
        Switch($PSCmdlet.ParameterSetName){
            ## StrikeView
            StrikeView{
                $Result = New-Object PSCustomObject -Property @{
                    ID     = $Global:EmpireTarget.ID
                    Agent  = $Global:EmpireTarget.Agent
                    Module = $Global:EmpireStrike.Module
                    Option = $Global:EmpireStrike.Option
                    } | Select ID,Agent*,Module,Option
                if($Option){$Result=$Result.option}
                Write-Warning "Use -x to Launch Strike..."
                }
            ## Strike X
            StrikeX{
                # Agent
                if($PSBoundParameters.Name){$Agt=$PSBoundParameters.Name}
                else{$Agt=$Global:EmpireTarget.Agent} 
                # Options
                $O = $Global:EmpireStrike.Option |? Name -ne Agent 
                if($O -AND (WarnMissing $O)){Return}
                # Options to Obj
                $Obj = New-Object PSCustomObject -Property @{Agent=$agt}
                $O | Select Name,Value|? Value -ne ''|%{
                    $Obj|Add-Member NoteProperty -Name $_.Name -Value "$($_.Value)"
                    }
                # Call API
                $reply = EmpireCall ModuleExec -Spec $Global:EmpireStrike.Module -Opt $Obj
                if($Reply.success -AND -Not$Blind){
                    Write-Verbose "$($Reply.msg) [TaskID: $($Reply.TaskID)]"
                    # Get Task ID
                    $LastTask = Empire-Event -Type task -Verbose:$False | ? agent -match $Agt | select -last 1
                    #$LastTask = $Task[$Task.count -1]
                    # MaxWait TaskID Result
                    $Loop = 0
                    Write-Verbose "$AGT - Waiting for Job Start [max $MaxWait]"
                    Do{ Sleep 1
                        $LastRes = Empire-Event -Type result -Verbose:$False | ? agent -match $Agt |Select -last 1
                        $Loop ++}Until($LastRes.TaskID -eq $LastTask.TaskID -OR $Loop -eq $MaxWait)
                    # If too long...
                    If($Loop -eq $MaxWait){Write-Warning "$Agt - Skipping Results: Too Slow...";Break}
                    # Else result
                    Else{
                        try{$R = (Empire-Result $Agt -Verbose:$False).results.trim()}catch{}
                        if($R -notmatch " completed!$| executed$|Bye!$"){Write-Verbose "$Agt - $R";Write-Verbose "$Agt - Waiting for Results [max $MaxWait]"}
                        while($R -notmatch " completed!$| executed$|Bye!$"){
                            Sleep 1
                            $R = try{(Empire-Result $Agt -Verbose:$False).results.trim()}catch{}
                            $Loop ++
                            If($Loop -ge $MaxWait){Write-Warning "$Agt - Skipping Results: Too Slow...";Break}
                            }
                        #if($R -match " completed!$"){$R=$R.trim()}
                        $Result += $R
                        }}
                # If Blind or Error
                Else{$Result=$Null}
                }}}
    # Return Result
    End{if($Result){Return $Result}}
    }
#end



#################################### Empire-Sync

<#
.Synopsis
   Sync Session Objects
.DESCRIPTION
   Long Description
.EXAMPLE
   Empire-Sync
   Example Description
.EXAMPLE
   Empire-Sync
   Example Description
.NOTES
   Notes
#>
Function Empire-Sync{
    [CmdletBinding(DefaultParameterSetname='SyncSession',HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('Sync')]
    Param(
		# Sync Sessions
		[Parameter(Mandatory=0,ParameterSetName='SyncSession')][switch]$Session,
		# Sync Modules
		[Parameter(Mandatory=1,ParameterSetName='SyncModule')][switch]$Module,
		# Sync Agents
		[Parameter(Mandatory=1,ParameterSetName='SyncAgent')][Alias('Agt')][switch]$Agent,
		# Sync Listener
		[Parameter(Mandatory=1,ParameterSetName='SyncListener')][Alias('Lst')][switch]$Listener,
        # Sync Stager Types
        [Parameter(Mandatory=1,ParameterSetName='SyncStager')][Alias('Stg')][switch]$Stager
		)
    ## Make It So
    Begin{$ID = $Global:EmpireTarget.ID}
    Process{
        # Action to Bool
        Switch($PSCmdlet.ParameterSetName){
            SyncSession {$SM=$SA=$SL=$SR=$True}
            SyncModule  {$SM=$True}
            SyncAgent   {$SA=$True}
            SyncListener{$SL=$True}
            SyncStager  {$SR=$True}
            }
        if($SM){
            # Sync Session Modules
            [Array]$Global:EmpireList.Module = EmpireCall ModuleList -ID $ID
            [Array]$Global:EmpireList.ModuleName = $Global:EmpireList.Module | Only Name | Sort           
            }
        if($SA){
            # Sync Session Agent Names
            [Array]$Global:EmpireList.AgentName = EmpireCall AgentList -ID $ID | Only Name | Sort
            }
        if($SL){
            # Sync Session Listener Names
            [Array]$Global:EmpireList.ListenerName = EmpireCall ListenerList -ID $ID | Only Name | Sort            
            }       
        if($SR){
            # Sync Session Stager Types
            [Array]$Global:EmpireList.StagerType = EmpireCall StagerList -ID $ID | Only Name | Sort            
            }}
    # No Output
    End{<# NoOut #>}
    }
#end



################################## Empire-Target

<#
.Synopsis
   Set Target
.DESCRIPTION
   Long Description
.EXAMPLE
   Empire-Target
   Example Description
.EXAMPLE
   Empire-Target
   Example Description
.NOTES
   Notes
#>
Function Empire-Target{
    [CmdletBinding(DefaultParameterSetname='TargetAgent',HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('Target','Tgt')]
    Param(
		# Set Target Agent
		[Parameter(Mandatory=0,ParameterSetName='TargetAgent'  )][Alias('Agt')][switch]$Agent,
		# Set Target Session
		[Parameter(Mandatory=1,ParameterSetName='TargetSession')][switch]$Session,
		# Set Target Module (Strike)
        [Parameter(Mandatory=1,ParameterSetName='TargetModule' )][switch]$Module,
		# View Current Target
		[Parameter(Mandatory=1,ParameterSetName='TargetView'   )][switch]$View	
        )
    DynamicParam{
        # Filter ParamSet
        if($PSCmdlet.ParameterSetName -ne 'TargetView'){
            # Populate Vars
            Switch($PSCmdlet.ParameterSetName){
                #SET         { NAME     ; TYPE       ; MAND ; PIPE ; POS  ; VSET
                ######################################################################################...
                TargetSession{ $N='ID'  ; $T='Int'   ; $M=1 ; $L=0 ; $P=0 ; $V= DynSession                          }
                TargetAgent  { $N='Name'; $T='String'; $M=0 ; $L=0 ; $P=0 ; $V= [Array]$Global:EmpireList.AgentName }
                TargetModule { $N='Name'; $T='String'; $M=1 ; $L=0 ; $P=0 ; $V= [Array]$Global:EmpireList.ModuleName}
                }
            # Return Dico
            return DynDico -Name $N -Type $T -Mandat $M -Pipe $L -Pos $P -VSet $V  
            }}
    ## Make It So
    Begin{}
    Process{
        # Switch Action
        Switch($PSCmdlet.ParameterSetName){
            ## Target Session
            TargetSession{$Global:EmpireTarget.ID = $PSBoundParameters.ID; AutoSession -ID $PSBoundParameters.ID}
            ## Target Agent
            TargetAgent{
                if(-Not$PSBoundParameters.Name){$Result = $Global:EmpireTarget}
                else{$Global:EmpireTarget.Agent = $PSBoundParameters.Name}
                }
            ## Target Module
            TargetModule{
                $Global:EmpireStrike.Module = $PSBoundParameters.Name
                $Global:EmpireStrike.Option = $Global:EmpireList.Module |? Name -eq $PSBoundParameters.Name | UnpackOptions
                }
            ## View Target
            TargetView{$Result = $Global:EmpireTarget}
            }}
    ## Return Result
    End{Return $Result}
    }
#end



#################################### Empire-Tune

<#
.Synopsis
   Empire Tune
.DESCRIPTION
   Play Imperial March
   1=Short | 2=Medium | 3=Long
   Defaults to 2
.EXAMPLE
   ImperialMarch 3
.NOTES
   Ta ta ta tatata tatata
#>
function Empire-Tune{
    [Alias('ImperialMarch','Tune','TaTaTaa')]
    Param(
        [ValidateSet('1','2','3')]
        [Parameter()]$v='2'
        )
    if($v){
        [console]::beep(440,500)
        [console]::beep(440,500)
        [console]::beep(440,500)
        [console]::beep(349,350)
        [console]::beep(523,150)
        [console]::beep(440,500)
        }
    if($v -match "2|3"){
        [console]::beep(349,350)
        [console]::beep(523,150)
        [console]::beep(440,1000)
        }
    if($v -eq '3'){
        [console]::beep(659,500)
        [console]::beep(659,500)
        [console]::beep(659,500)
        [console]::beep(698,350)
        [console]::beep(523,150)
        [console]::beep(415,500)
        [console]::beep(349,350)
        [console]::beep(523,150)
        [console]::beep(440,1000)
        }}
#####end



##################################### Empire-Use

<#
.Synopsis
   Use Empire Stuff
.DESCRIPTION
   Use -Module
   Use -Stager
   Use -Listener
.EXAMPLE
   Empire-Use
   Example Description
.EXAMPLE
   Empire-Use
   Example Description
.NOTES
   Listener/Stager uses same temp object
   /!\ Can only use one at a time
   
   Module has his own object
#>
Function Empire-Use{
    [CmdletBinding(DefaultParameterSetName='UseModule',HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('Use')]
    Param(
        [Parameter(Mandatory=1,ParameterSetName='UseStager')][Alias('Stg')][Switch]$Stager,
        [Parameter(Mandatory=1,ParameterSetName='UseListener')][Alias('Lst')][Switch]$Listener,
        [Parameter(Mandatory=1,ParameterSetName='UseListener',Position=0)][listenerType]$Type,
        [Parameter(Mandatory=0,ParameterSetName='UseModule')][Switch]$Module
        )
    DynamicParam{
        # Filter ParamSet
        if($PSCmdlet.ParameterSetName -in 'UseStager','UseModule'){
            Switch($PSCmdlet.ParameterSetName){
                #SET        { NAME     ; TYPE       ; MAND ; PIPE ; POS  ; VSET
                ####################################################################...
                UseStager   { $N='Name'; $T='String'; $M=1 ; $L=0 ; $P=0 ; $V=$Global:EmpireList.StagerType }
                UseModule   { $N='Name'; $T='String'; $M=1 ; $L=0 ; $P=0 ; $V=$Global:EmpireList.ModuleName }
                }
            # Return Dico
            return DynDico -Name $N -Type $T -Mandat $M -Pipe $L -Pos $P -VSet $V    
            }}
    ## Make It So
    Begin{}
    Process{
        # Switch Action
        Switch($PSCmdlet.ParameterSetName){
            # Stager
            UseStager{Empire-Stager -Use $PSBoundParameters.Name}
            # Listener
            UseListener{Empire-Listener -Use $Type.ToString()}
            # Module
            UseModule{
                $Global:EmpireStrike.Module = $PSBoundParameters.Name
                $Global:EmpireStrike.Option = $Global:EmpireList.Module | ? Name -eq $PSBoundParameters.Name | UnpackOptions
                }}}
    # Return Nothing
    End{<#NoOut#>}
    }
#end



#################################### Empire-View

<#
.Synopsis
   View Empire Objects
.DESCRIPTION
   View -Strike
   View -Target
   View -Module
   View -Agent
   View -Stager
   View -Banner
   View -Help
   
.EXAMPLE
   Empire-View
   Example Description
.EXAMPLE
   Empire-View
   Example Description
.NOTES
   Listener/Stager uses same temp object
   Can only use one at a time
   Module has his own object
#>
Function Empire-View{
    [CmdletBinding(DefaultParameterSetname='ViewStrike',HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('View')]
    Param(
		# View Target
		[Parameter(Mandatory=1,ParameterSetName='ViewTarget')][Alias('Tgt')][switch]$Target,
		# View All Sessions
		[Parameter(Mandatory=1,ParameterSetName='ViewSession')][switch]$Session,
		# View All Modules
		[Parameter(Mandatory=1,ParameterSetName='ViewModule')][switch]$Module,
		# View All Agents
		[Parameter(Mandatory=1,ParameterSetName='ViewAgent')][Alias('Agt')][switch]$Agent,
		# View All Listeners
		[Parameter(Mandatory=1,ParameterSetName='ViewListener')][Alias('Lst')][switch]$Listener,
		# View All Listeners
		[Parameter(Mandatory=1,ParameterSetName='ViewStager')][Alias('Stg')][switch]$Stager,
		# View Strike
		[Parameter(Mandatory=0,ParameterSetName='ViewStrike')][Alias('X')][switch]$Strike,
		# View Banner
		[Parameter(Mandatory=1,ParameterSetName='ViewBanner')][switch]$Banner,
        # View Help
        [Parameter(Mandatory=1,ParameterSetName='ViewHelp')][switch]$Help,
        # Full
        [Parameter(Mandatory=0,ParameterSetName='ViewTarget')]
        [Parameter(Mandatory=0,ParameterSetName='ViewAgent')]
        [Parameter(Mandatory=0,ParameterSetName='ViewModule')][switch]$full,
        # Option
        [Parameter(Mandatory=0,ParameterSetName='ViewModule')]
        [Parameter(Mandatory=0,ParameterSetName='ViewListener')]
        [Parameter(Mandatory=0,ParameterSetName='ViewStager')][switch]$option
		)
    DynamicParam{
        # Filter ParamSet
        if($PSCmdlet.ParameterSetName -in 'ViewAgent','ViewStager','ViewListener','ViewModule','ViewSession'){
            # Populate Vars
            Switch($PSCmdlet.ParameterSetName){
                #SET        { NAME     ; TYPE        ; MAND ; PIPE ; POS  ; VSET
                ##################################################################################...
                ViewSession { $N='ID'   ; $T='String'; $M=0 ; $L=1 ; $P=0 ; $V= DynSession                             }
                ViewModule  { $N='Name' ; $T='String'; $M=0 ; $L=1 ; $P=0 ; $V=([Array]$Global:EmpireList.ModuleName)  }
                ViewListener{ $N='Name' ; $T='String'; $M=0 ; $L=1 ; $P=0 ; $V=([Array]$Global:EmpireList.ListenerName)}
                ViewStager  { $N='Type' ; $T='String'; $M=0 ; $L=1 ; $P=0 ; $V=([Array]$Global:EmpireList.StagerType)  }
                ViewAgent   { $N='Name' ; $T='String'; $M=0 ; $L=1 ; $P=0 ; $V=([Array]$Global:EmpireList.AgentName)   }
                }
            # Return Dico
            return DynDico -Name $N -Type $T -Mandat $M -Pipe $L -Pos $P -VSet $V    
            }}
    ## Make It So
    Begin{$Result= @()}
    Process{
        # Switch Action
        Switch($PSCmdlet.ParameterSetName){
            # Target
            ViewTarget{$result=$Global:EmpireTarget}
            # Session
            ViewSession{
                if($PSBoundParameters.ID.Count){$Sess = $PSBoundParameters.ID}
                else{$Sess = $Global:EmpireTarget.ID}
                $result=$Global:EmpireSession |? ID -eq $Sess
                }
            # Module
            ViewModule{
                if($PSBoundParameters.Name){
                    if($Full){$result += $Global:EmpireList.Module|? Name -eq $PSBoundParameters.Name}
                    else{$result += $Global:EmpireList.Module|? Name -eq $PSBoundParameters.Name | Select Name,Description,options}
                    }
                else{$result = $Global:EmpireList.Module|Select name,description,options}
                }
            # Agent
            ViewAgent{
                if($PSBoundParameters.Name){
                    if($Full){$result += EmpireCall -Act AgentView -Spec $PSBoundParameters.Name}
                    else{$Result += EmpireCall -Act AgentView -Spec $PSBoundParameters.Name | Select Name,High_Integrity,Language,Listener,LastSeen_time}
                    }
                else{Empire-Agent -List |Select Name,High_Integrity,Language,Listener,LastSeen_time|sort Name}
                }
            # listener
            ViewListener{
                if($PSBoundParameters.Name){$result = EmpireCall -Act ListenerView -Spec $PSBoundParameters.Name}
                else{$result += Empire-Listener -list | Select ID,name,module | Sort ID}
                }
            # Stager Type
            ViewStager{
                if($PSBoundParameters.Type){$result = EmpireCall StagerView -Spec $PSBoundParameters.Type}
                else{$result += Empire-Stager -list | Select name,description | Sort name}
                }
            # Strike Obj
            ViewStrike{$result = $Global:EmpireStrike}
            # Banner
            ViewBanner{$result = $Script:Banner}
            }}
    # Return Result
    end{if($Option){$Result = $Result | Unpack};Return $result}
    }
#end



##################################### First Load
# SplashScreen on first load
if(!$Global:EmpireSession){Clear;$Banner;Tune ;Sleep -mil 500;Clear}
# Load Speech if not already done
if(-Not([appdomain]::currentdomain.getassemblies().where{$_.fullname -match '^System.Speech'})){Add-Type -AssemblyName System.Speech}


################################################

#endregion #####################################


################################################
##################################### DISCALIMER
#region Disclaimer
################################################
#
#                ¯\_(ツ)_/¯
#
#endregion #####################################


############################################ EOF
#2018@SadProcessor##############################