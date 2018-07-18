###########################################################
##  CypherDog15 - PoSh BloodHound Dog Whisperer [Alpha3] ##
###########################################################

### ToDo
# Test&Debug
# Help&Examples

###########################################################
#region ############################################## VARS


##################################################### ASCII
$ASCII= @("
 _____________________________________________
 ______|______________________________________
 _____||________________________CYPHERDOG1.5__
 _____||-________...__________________Alpha3__
 ______||-__--||||||||-.______________________
 _______!||||||||||||||||||--_________________
 ________|||||||||||||||||||||-_______________
 ________!||||||||||||||||||||||._____________
 _______.||||||!!||||||||||||||||-____________
 ______|||!||||___||||||||||||||||.___________
 _____|||_.||!___.|||'_!||_'||||||!___________
 ____||___!||____|||____||___|||||.___________
 _____||___||_____||_____||!__!|||'___________
 __________ ||!____||!________________________
 _____________________________________________

 BloodHound Dog Whisperer - @SadProcessor 2018
     - v1.5  aka  The 'Good Boy' Edition - 
")
<#   The ShellFather has spoken to me in a vision...
     He told me that I was a "Bad Boy",
     that in the begining was the Approved Verb, 
     and that I shall follow Best Practices.
     Then he added "Make it so..!" 
     ...And so I refactored.
     #>


###################################################### Enum
## NodeType
enum NodeType{
    Computer
    Domain
    Group
    User
    GPO
    OU
    }


## EdgeType - Full
enum EdgeType{
    MemberOf
    AdminTo
    HasSession
    TrustedBy
    ForceChangePassword
    AddMembers
    GenericAll
    GenericWrite
    WriteOwner
    WriteDACL
    AllExtendedRights
    GpLink
    Owns
    Contains
    }

## EdgeType - Basic
enum EdgeBasic{
    MemberOf
    AdminTo
    HasSession
    TrustedBy    
    }

## EdgeType - ACL
enum EdgeACL{
    ForceChangePassword
    AddMembers
    GenericAll
    GenericWrite
    WriteOwner
    WriteDACL
    AllExtendedRights    
    }

## EdgeType GPO/OU
enum EdgeGPO{
    GpLink
    Owns
    Contains
    }

################################################# PathClass

Class BHEdge{
    [int]$ID
    [int]$Step
    [string]$startNode
    [string]$Edge
    [String]$Direction
    [string]$EndNode
    }

################################################# CypherDog
## CypherDog Obj
$CypherDog = [PSCustomObject]@{
    Host         = 'localhost'
    Port         = 7474
    UserList     = $Null
    GroupList    = $Null
    ComputerList = $Null
    DomainList   = $Null
    GPOList      = $Null
    OUList       = $Null
    }



#endregion ################################################



###########################################################
#region ######################################### INTERNALS

#  CacheNode   >  Cache Node Lists
#  DynP        >  Return Dynamic Param
#  GenEdgeStr  >  Return Cypher Edge Block
#  ToPathObj   >  Unpack Path to Object
#  ClipThis    >  Query To Clipboard



################################################# CacheNode

<#
.Synopsis
   Cache Node Lists [Internal]
.DESCRIPTION
   Cache Name Lists per Node type
   All types if none specified
   Use at startup and on Node Create/Delete
   (for Name DynParam lists)
.EXAMPLE
    CacheNode
    Caches Name lists for All Node Types
.EXAMPLE
    CacheNode Computer,User
    Chaches Name Lists of specified node types
#>
function CacheNode{
    [CmdletBinding()]
    Param(
        # Specify Type(s)
        [parameter(Mandatory=0)][NodeType[]]$Type
        )
    # No Type == All
    If($Type -eq $Null){$Type = [Enum]::GetNames([NodeType])}
    # For each type
    foreach($T in $Type){
        Write-Verbose "Caching Node List: $T" 
        # Prep Query
        $Query = "MATCH (n:$T) RETURN n"
        # Cache matching name list
        $Script:CypherDog."${T}List" = (DogPost $Query).name
        }}
#####End



###################################################### DynP

<#
.Synopsis
   Get Dynamic Param [Internal]
.DESCRIPTION
   Return Single DynParam to be added to dictionnary
.EXAMPLE
    DynP TestParam String -mandatory 1
#>
function DynP{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=1)][String]$Name,
        [Parameter(Mandatory=1)][string]$Type,
        [Parameter(Mandatory=0)][bool]$Mandat=0,
        [Parameter(Mandatory=0)][int]$Pos=$Null,
        [Parameter(Mandatory=0)][bool]$Pipe=0,
        [Parameter(Mandatory=0)][bool]$PipeProp=0,
        [Parameter(Mandatory=0)]$VSet=$Null
        )
    # Create Attribute Obj
    $Attrb = New-Object Management.Automation.ParameterAttribute
    $Attrb.Mandatory=$Mandat
    $Attrb.ValueFromPipeline=$Pipe
    $Attrb.ValueFromPipelineByPropertyName=$PipeProp
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
    $DynP = New-Object Management.Automation.RuntimeDefinedParameter("$Name",$($Type-as[type]),$Cllct)
    # Return DynParam
    Return $DynP
    }
#End



################################################ GenEdgeStr

<#
.Synopsis
   Generate Edge String [Internal]
.DESCRIPTION
   Description
.EXAMPLE
    Example-One
#>
function GenEdgeStr{
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        [ValidateSet('All','Basic','NoACL','NoGPO')]
        [Parameter(Mandatory=0)][String]$Type='All',
        [Parameter(Mandatory=0)][Alias('x')][Edgetype[]]$Exclude
        )
    # Select Edges
    Switch($Type){
        All   {$R = [Enum]::GetNames([EdgeType])}
        Basic {$R = [Enum]::GetNames([EdgeBasic])}
        NoACL {$R = (Compare ([Enum]::GetNames([EdgeType])) ([Enum]::GetNames([EdgeACL]))).InputObject}
        NoGPO {$R = (Compare ([Enum]::GetNames([EdgeType])) ([Enum]::GetNames([EdgeGPO]))).InputObject}
        }
    # Remove Exluded
    foreach($x in $Exclude){$R = $R -ne $x}
    # Return String
    Return $R -join '|:'
    }
#end



################################################# ToPathObj

<#
.Synopsis
   Parse to Path Object [Internal]
.DESCRIPTION
   Description
.EXAMPLE
    Example-One
#>
function ToPathObj{
    [CmdletBinding()]
    [OutputType([BHEdge])]
    [Alias()]
    Param(
        [Parameter(ValueFromPipeline=1)][Object[]]$Data
        )
    Begin{$ID=0;$Result=@()}
    Process{
        foreach($D in $Data){
        $StepCount = $D.relationships.count
		# if Steps
        if($StepCount -gt 0){
            $PathObj = @()
            0..($StepCount -1)|%{
                [BHEdge]@{
                    'ID'         = $ID
                    'Step'       = $_
                    'StartNode'  = (irm -Method Get -Headers $header -uri @($D.nodes)[$_]).data.name 
                    'Edge'       = (irm -Method Get -Headers $header -uri @($D.relationships)[$_]).type
                    'EndNode'    = (irm -Method Get -Headers $header -uri @($D.nodes)[$_+1]).data.name
                    'Direction'  = @($D.directions)[$_]
                    } | select 'ID','Step','StartNode','Edge','Direction','EndNode'
                }
            $ID+=1
            }}}
    End{<#NoOp#>}
    }
#End



################################################## ClipThis

<#
.Synopsis
   Query to Clipboard  [Internal]
.DESCRIPTION
   Displays resulting query and sets clipboard
.EXAMPLE
   ClipThis $Query [-with $Params]
#>
Function ClipThis{
    [CmdletBinding()]
    Param(
        # Query
        [Parameter(Mandatory=1)][String]$Query,
        # Params
        [Parameter(Mandatory=0)][Alias('With')][HashTable]$Params
        )
    # If Params
    if($Params.count){$Params.keys|%{$Query=$Query.replace("{$_}","'$($Params.$_)'")}}
    # Verbose
    Write-Verbose "$Query"
    # Clipboard
    $Query | Set-ClipBoard
    # Return Query
    Return $Query
    }
#End



#endregion ################################################



###########################################################
#region ######################################### EXTERNALS
#                                                                            -DEV-
#  Send-BloodHoundPost          >  Post Cypher             [DogPost]    <----- Ok
#
#  Get-BloodHoundNode           >  View Node               [Node]       <----- Ok
#  Search-BloodHoundNode        >  Search Key/Prop/Value   [NodeSearch] <----- Ok
#  New-BloodHoundNode           >  Create Node/Props       [NodeCreate] <----- Ok
#  Remove-BloodHoundNode        >  Delete Node             [NodeDelete] <----- Ok
#  Set-BloodHoundNode           >  Update Node Props       [NodeUpdate] <----- Ok
#
#  Get-BloodHoundEdge           >  Nodes per Edge          [Edge]       <----- Ok
#  Get-BloodHoundEdgeReverse    >  Nodes per Reverse Edge  [EdgeRev]    <----- Ok
#  New-BloodHoundEdge           >  Create Edge             [EdgeCreate] <----- Ok
#  Remove-BloodHoundEdge        >  Delete Edge             [EdgeDelete] <----- Ok
#
#  Get-BloodHoundPath           >  Get (all)Shortest Path  [Path]       <----- Ok
#  Get-BloodHoundPathAny        >  Get Any Path            [PathAny]    <----- Ok
#  Get-BloodHoundPathCheapest   >  Get Cheapest Path       [PathCheapest]<---- Ok
#
#  Get-TopNodeCount [TopNode]
#  Get-UserSessionList [SessionList]
#  Get-ComputerLogonList [LogonList]
#  Get-ComputerAdminList [AdminList]
#  Get-CrossDomainRelationship [CrossDomain]
#
#  Get-BloodHoundWald0IndexIO   >  Experimental            [Wald0IO]    <----- Ok (Requires Domain Prop on Nodes)
#
## /!\ Test|Debug|Examples|Help /!\ ##                                  <----- ToDo

###########################################################



################################################### DogPost

<#
.Synopsis
   Post to rest API
.DESCRIPTION
   Post CYpher Query to API
   DogPost $Query [$Params] [-expand <prop,prop>]
.EXAMPLE
    # Return All Users
    $query="MATCH (n:User) RETURN n"
    DogPost $Query
.EXAMPLE
    # Specific Computer
    $query  = "MATCH (A:Computer {name: {ParamA}}) RETURN A"
    $Params = @{ParamA="APOLLO.EXTERNAL.LOCAL"}
    DogPost $Query $Params
.EXAMPLE
    # Path A to B
    $Query = "MATCH (A:User {name: {ParamA}}), (B:Group {name: {ParamB}}), x=shortestPath((A)-[*1..]->(B)) RETURN x"
    $Params= @{ParamA="ACHAVARIN@EXTERNAL.LOCAL";ParamB="DOMAIN ADMINS@EXTERNAL.LOCAL"}
    DogPost $Query $Params -Expand Data | ToPathObj
.EXAMPLE
    # Metrics - Top10 Admins 
    $Query="MATCH 
       (U:User)-[r:MemberOf|:AdminTo*1..]->(C:Computer)
       WITH
       U.name as n,
       COUNT(DISTINCT(C)) as c 
       RETURN 
       {Name: n, Count: c} as SingleColumn
       ORDER BY c DESC
       LIMIT 10"
    DogPost $Query -x Data
    #>
function Send-BloodHoundPost{
    [CmdletBinding()]
    [Alias('DogPost')]
    Param(
        [Parameter(Mandatory=1)][string]$Query,
        [Parameter(Mandatory=0)][Hashtable]$Params,
        [Parameter(Mandatory=0)][Alias('x')][String[]]$Expand=@('data','data'),
        [Parameter(Mandatory=0)][Switch]$Profile
        )
    # Uri 
    $Uri = "http://$($CypherDog.Host):$($CypherDog.Port)/db/data/cypher"
    # Header
    $Header=@{'Accept'='application/json; charset=UTF-8';'Content-Type'='application/json'}
    # Query
    if($Profile){$QUery="PROFILE "+$Query;$Expand='plan'}
    # Body
    if($Params){$Body = @{params=$Params; query=$Query}|Convertto-Json}
    else{$Body = @{query=$Query}|Convertto-Json}
    # Call
    write-verbose $Body.replace(')\u003c-',')<-').replace('-\u003e(','->(').replace('\r','').replace('\n',' ').replace('\u0027',"'")
    $Reply = Try{Invoke-RestMethod -Uri $Uri -Method Post -Headers $Header -Body $Body}Catch{$Oops = $Error[0].Exception}
    # Format obj
    if($Oops){Write-Warning "$($Oops.message)" ;Return}
    if($Expand){$Expand | %{$Reply = $Reply.$_}} 
    if($Profile){
        $Output = @(); $Step = 0; $Obj = $Reply
        while($Step -eq 0 -OR $Obj.children){
            if($Obj){
                [HashTable]$Props = @{}
                $Props.add('Step',"$Step")
                $Props.add('Name',"$($Obj.name)")
                $Argum = $Obj.args
                $Argum | GM | ? MemberType -eq NoteProperty | %{ 
                    $Key = $_.name; $Value = $Argum.$Key 
                    $Props.add("$Key","$Value")
                    }
                $Output += New-Object PSCustomObject -Property $Props
                }
            $Obj = $Obj.children; $Step += 1; $Reply = $Output
            }}
    # Output Reply
    if($Reply){Return $Reply}
    }
#End


## ISE Add-On [F12]
if($psISE){
    # Shortcut function
    function CypherShortcut{
        # Editor
        $E=$psISE.CurrentFile.Editor
        # If Selected Text
        $Q = $E.SelectedText
        # Else select current line
        if($Q -eq ''){$Q = $E.CaretLineText}
        # Call
        DogPost $Q -Expand Data 
        }
    # Remove existing
    try{$Null = $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Remove($ShortCut)}Catch{}
    # Add To ISE
    try{$ShortCut = $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("BloodHound Cypher", {CypherShortcut}, "F12")}Catch{}
    }
#End



###################################################### Node

<#
.Synopsis
   Syn
.DESCRIPTION
   Desc
.EXAMPLE
   Ex
#>
function Get-BloodHoundNode{
    [CmdletBinding()]
    [Alias('Get-Node','Node')]
    Param(
        [Parameter(Mandatory=1,Position=0,ValuefromPipeline=0)][NodeType]$Type,
        [Parameter(Mandatory=0)][Switch]$Label,
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynNameList = @($Script:CypherDog."${Type}List")
        # Prep DynP
        $DynName = DynP -Name 'Name' -Type 'String[]' -Mandat 0 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $DynNameList
        # DynP to Dico
        $Dico.Add("Name",$DynName)
        # Return Dico
        Return $Dico
        }
    Begin{<#NoOp#>}
    Process{
        ## If No Name 
        If(-Not$DynName.IsSet){
            # Query
            if($Label){Write-Warning "Must specify Name(s) when requesting Labels...";Return}
            else{$Query = "MATCH (n:$Type) RETURN n ORDER BY n.name"}
            if(-Not$Cypher){DogPost $Query}
            }
        ## Else, for each name
        Else{Foreach($Name in $DynName.Value){
                # If Label
                if($Label){
                    $Query = "MATCH (n:$Type {name: '$Name'}) RETURN LABELS(n)"
                    if(-Not$Cypher){
                        $L= DogPost $Query -expand data | Select -ExpandProperty SyncRoot
                        New-Object PSCustomObject -Property @{Name="$Name";Label=@($L)}
                        }}
                else{$Query = "MATCH (n:$Type {name: '$Name'}) RETURN n"
                    if(-Not$Cypher){DogPost $Query}
                    }}}}
    End{if($Cypher){ClipThis $Query}}
    }
#End



################################################ NodeSearch

<#
.Synopsis
   Syn
.DESCRIPTION
   Desc
.EXAMPLE
   Ex
#>
function Search-BloodHoundNode{
    [CmdletBinding(DefaultParameterSetName='Key')]
    [Alias('Search-Node','NodeSearch')]
    Param(
        # Node Type
        [Parameter(Mandatory=0,Position=0,ParameterSetName='Key')]
        [Parameter(Mandatory=0,Position=0,ParameterSetName='PropNot')]
        [Parameter(Mandatory=0,Position=0,ParameterSetName='PropVal')]
        [Parameter(Mandatory=0,Position=0,ParameterSetName='Prop')]
        [Parameter(Mandatory=0,Position=0,ParameterSetName='LabelNot')]
        [Parameter(Mandatory=0,Position=0,ParameterSetName='Label')][NodeType]$Type,
        # Property Name
        [Parameter(Mandatory=1,ParameterSetName='PropNot')]
        [Parameter(Mandatory=1,ParameterSetName='PropVal')]
        [Parameter(Mandatory=1,ParameterSetName='Prop')][String]$Property,
        # Label
        [Parameter(Mandatory=1,ParameterSetName='LabelNot')]
        [Parameter(Mandatory=1,ParameterSetName='Label')][String]$Label,
        # Property Name & Value
        [Parameter(Mandatory=1,ParameterSetName='PropVal')][String]$Value,
        # Property Name / Label doesn't exists
        [Parameter(Mandatory=1,ParameterSetName='LabelNot')]
        [Parameter(Mandatory=1,ParameterSetName='PropNot')][Switch]$NotExist,
        # KeyWord
        [Parameter(Mandatory=1,Position=1,ParameterSetName='Key')][Regex]$Key,
        [Parameter(Mandatory=0,ParameterSetName='Key')][Switch]$Sensitive,
        # Show Cypher
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    if($Type -ne $null){$T=":$type"}
    if(-Not$Sensitive){$CS='(?i)'}
    # Prep Query
    Switch ($PSCmdlet.ParameterSetName){
        "Key"     {$Query= "MATCH (X$T) WHERE X.name =~ {KEY} RETURN X ORDER BY X.name"        ; $Param= @{KEY="$CS.*$Key.*"}}
        "Prop"    {$Query= "MATCH (X$T) WHERE exists(X.$Property) RETURN X ORDER BY X.name"    ; $Param= $Null}
        "PropNot" {$Query= "MATCH (X$T) WHERE NOT exists(X.$Property) RETURN X ORDER BY X.name"; $Param= $Null}
        "PropVal" {$Query= "MATCH (X$T) WHERE X.$Property = {VALUE} RETURN X ORDER BY X.name"  ; $Param= @{VALUE="$Value"}}
        "Label"   {$Query= "MATCH (X$T) WHERE X:$Label RETURN X ORDER BY X.name"               ; $Param= $Null}
        "LabelNot"{$Query= "MATCH (X$T) WHERE NOT X:$Label RETURN X ORDER BY X.name"           ; $Param= $Null}
        }
    # Call Dog
    if($Cypher){ClipThis $Query $Param}
    Else{DogPost $Query $Param}
    }
#End



################################################ NodeCreate

<#
.Synopsis
   Syn
.DESCRIPTION
   Desc
.EXAMPLE
   Ex
#>
function New-BloodHoundNode{
    [CmdletBinding()]
    [Alias('New-Node','NodeCreate')]
    Param(
        # Node Type [Mandatory]
        [Parameter(Mandatory=1,Position=0)][NodeType]$Type,
        # Node Name [Mandatory]
        [Parameter(Mandatory=1,Position=1,ValueFromPipeline=1)][String[]]$Name,
        # Node Properties [Option]
        [Parameter(Mandatory=0,Position=2)][Hashtable]$Property,
        # Cypher [Option]
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    Begin{$Query = "MERGE (X:$Type {name: {NAME}})"}
    Process{
        Foreach($N in $Name){
            $Param = @{NAME="$N"}
            if(-Not$Cypher){DogPost $Query $Param}
            }
        # Cache Updated Type
        if(-Not$Cypher){
            CacheNode $Type
            # If Props
            if($Property.Count){Foreach($N in $Name){
                    # Update Node Props
                    $Splat = @{
                        Type     = $Type
                        Name     = $N
                        Property = $Property
                        }
                    NodeUpdate @Splat
                    }}}}
    # If Cypher ####
    End{if($Cypher){ClipThis $Query $Param}}
    }
#End



################################################ NodeUpdate

<#
.Synopsis
   Syn
.DESCRIPTION
   Desc
.EXAMPLE
   Ex
#>
function Set-BloodHoundNode{
    [CmdletBinding(DefaultParameterSetName='UpdateProp')]
    [Alias('Set-Node','NodeUpdate')]
    Param(
        [Parameter(Mandatory=1,Position=0,ParameterSetName='DeleteLabel')]
        [Parameter(Mandatory=1,Position=0,ParameterSetName='UpdateLabel')]
        [Parameter(Mandatory=1,Position=0,ParameterSetName='UpdateProp')]
        [Parameter(Mandatory=1,Position=0,ParameterSetName='DeleteProp')][NodeType]$Type,
        [Parameter(Mandatory=1,ParameterSetName='DeleteLabel')]
        [Parameter(Mandatory=1,ParameterSetName='DeleteProp')][Switch]$Delete,
        [Parameter(Mandatory=0,ParameterSetName='DeleteLabel')]
        [Parameter(Mandatory=0,ParameterSetName='UpdateLabel')]
        [Parameter(Mandatory=0,ParameterSetName='DeleteProp')]
        [Parameter(Mandatory=0,ParameterSetName='UpdateProp')][Switch]$Cypher,
        [Parameter(Mandatory=1,ParameterSetName='DeleteLabel')]
        [Parameter(Mandatory=1,ParameterSetName='UpdateLabel')][Switch]$Label
        )
    DynamicParam{
        # Prep Dico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynNameList = $Script:CypherDog."${Type}List"
        # Prep DynP
        $DynName = DynP -Name 'Name' -Type 'String[]' -Mandat 1 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $DynNameList
        $Dico.Add('Name',$DynName)
        # If Delete Prop
        if($PSCmdlet.ParameterSetName -eq 'DeleteProp'){
            $DynProp = DynP -Name 'Property' -Type 'String[]'-Mandat 1 -Pos 2 -Pipe 0 -PipeProp 0 -VSet $Null
            $Dico.Add('Property',$DynProp)
            }
        # If Update Prop
        if($PSCmdlet.ParameterSetName -eq 'UpdateProp'){
            $DynProp = DynP -Name 'Property' -Type 'HashTable'-Mandat 1 -Pos 2 -Pipe 0 -PipeProp 0 -VSet $Null
            $Dico.Add('Property',$DynProp)
            }
        # If Label Update/delete
        if($PSCmdlet.ParameterSetName -in 'UpdateLabel','DeleteLabel'){
            $DynLabel = DynP -Name 'LabelName' -Type 'String[]' -Mandat 1 -Pos 2 -Pipe 0 -PipeProp 0 -VSet $Null
            $Dico.Add('LabelName',$DynLabel)
            } 
        # Return Dico
        Return $Dico
        }
    Begin{<#NoOp#>}
    Process{foreach($Name in @($DynName.Value)){
            # Set Name Param
            $Param = @{NAME="$Name"}
            # If Delete props
            if($PSCmdlet.ParameterSetName -eq 'DeleteProp'){
                # Query
                $Query="MATCH (X:$Type) WHERE X.name = {NAME} REMOVE"
                # Append each Prop Names
                $DynProp.Value|%{$Query += " X.$_,"}
                }
            # If Update Props
            if($PSCmdlet.ParameterSetName -eq 'UpdateProp'){
                # Query
                $Query = "MATCH (X:$Type) WHERE X.name = {NAME} SET"
                # For each Prop
                $DynProp.Value.Keys|%{
                    # Append Prop to Query
                    $Query+=" X.$_={$_},"
                    # Add to Param
                    $Param += @{$_="$($DynProp.Value.$_)"}
                    }}
            # If Update Label
            if($PSCmdlet.ParameterSetName -eq 'UpdateLabel'){
                # Query
                $Query = "MATCH (X:$Type) WHERE X.name = {NAME} SET"
                # For each Prop
                $DynLabel.Value|%{
                    # Append Prop to Query
                    $Query+=" X:$_,"
                    }}               
            # If Delete Label
            if($PSCmdlet.ParameterSetName -eq 'DeleteLabel'){
                # Query
                $Query = "MATCH (X:$Type) WHERE X.name = {NAME} REMOVE"
                # For each Prop
                $DynLabel.Value|%{
                    # Append Prop to Query
                    $Query+=" X:$_,"
                    }}
            # Query
            $Query=$Query.trimEnd(',')
            # If Not Cypher
            if(-Not$Cypher){DogPost $Query $Param}
            }}
    End{if($Cypher){ClipThis $Query $Param}}
    }
#End



################################################ NodeDelete

<#
.Synopsis
   Syn
.DESCRIPTION
   Desc
.EXAMPLE
   Ex
#>
function Remove-BloodHoundNode{
    [CmdletBinding(SupportsShouldProcess=1,ConfirmImpact='High')]
    [Alias('Remove-Node','NodeDelete')]
    Param(
        # Node Type [Mandatory]
        [Parameter(Mandatory=1,Position=0)][NodeType]$Type,
        # Force (Skip Confirm)
        [Parameter(Mandatory=0)][Alias('x')][Switch]$Force,
        # Force (Skip Confirm)
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    DynamicParam{
        # Prep Dico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynNameList = $Script:CypherDog."${Type}List"
        # Prep DynP
        $DynName = DynP -Name 'Name' -Type 'String[]' -Mandat 1 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $DynNameList
        $Dico.Add('Name',$DynName)
        # Return Dico
        Return $Dico
        }
    Begin{$Query = "MATCH (X:$Type {name: {NAME}}) DETACH DELETE X"}
    Process{
        Foreach($N in $DynName.Value){
            $Param = @{NAME="$N"}
            if($Cypher){ClipThis $Query $Param}
            # Else
            Else{
                # If Force
                if($Force){DogPost $Query $Param}
                # Else Confirm
                else{if($PSCmdlet.ShouldProcess($N,'DELETE NODE')){
                        # Call Dog
                        DogPost $Query $Param
                        }}}}}
    # Cache Node Type ##
    End{if(-Not$Cypher){CacheNode $Type}}
    }
#End



###################################################### Edge

<#
.Synopsis
   Get Node per Edge
.DESCRIPTION
   Specify Target Name / Return Source
.EXAMPLE
   Edge User MemberOf Group <GroupName>
#>
function Get-BloodHoundEdge{
    [CmdletBinding()]
    [Alias('Get-Edge','Edge')]
    Param(
        [Parameter(Mandatory=1,Position=0,ValuefromPipeline=0)][NodeType]$SourceType,
        [Parameter(Mandatory=1,Position=1,ValuefromPipeline=0)][EdgeType]$EdgeType,
        [Parameter(Mandatory=1,Position=2,ValuefromPipeline=0)][NodeType]$TargetType
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynNameList = @($Script:CypherDog."${TargetType}List")
        # Prep DynP
        $DynName   = DynP -Name 'Name'   -Type 'String[]' -Mandat 1 -Pos 3 -Pipe 1 -PipeProp 1 -VSet $DynNameList
        $DynMax    = DynP -Name 'Degree' -Type 'String'   -Mandat 0 -Pos 4 -Pipe 0 -PipeProp 0 -VSet @('1','2','3','4','5','6','7','8','9','*')
        $DynCypher = DynP -Name 'Cypher' -Type 'Switch'   -Mandat 0 -Pos 5 -Pipe 0 -PipeProp 0 -VSet $Null
        # DynP to Dico
        $Dico.Add("Name"   ,$DynName)
        $Dico.Add("Degree" ,$DynMax)
        $Dico.Add("Cypher" ,$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{
        # if Max
        If($DynMax.IsSet){
            if($DynMax.Value -eq '*'){$Max='..'}
            else{$Max=".."+(([int]$DynMax.Value))}
            }
        Else{$Max=$Null}
        # EdgeString
        If($EdgeType -ne 'MemberOf' -AND $DynMax.Value){
            $Query  = "MATCH (A:$SourceType), (B:$TargetType {name: {NAME}}), p=shortestPath((A)-[r:${EdgeType}|:MemberOf*1$Max]->(B)) RETURN DISTINCT(A) ORDER BY A.name"
            }
        Else{$Query = "MATCH (A:$SourceType), (B:$TargetType {name: {NAME}}), p=(A)-[r:${EdgeType}*1$Max]->(B) RETURN DISTINCT(A) ORDER BY A.name"}
        }
    Process{Foreach($Name in $DynName.Value){
            $Param = @{NAME="$Name"}
            if(-Not$DynCypher.IsSet){DogPost $Query $Param}
            }}
    End{if($DynCypher.IsSet){ClipThis $Query $Param}}
    }
#End



##################################################### EdgeR

<#
.Synopsis
   Get Reverse Edge
.DESCRIPTION
   Specify Source Name / Return Target
.EXAMPLE
   EdgeR User <UserName> MemberOf Group
#>
function Get-BloodHoundEdgeReverse{
    [CmdletBinding()]
    [Alias('Get-EdgeRev','EdgeR')]
    Param(
        [Parameter(Mandatory=1,Position=0,ValuefromPipeline=0)][NodeType]$SourceType
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynNameList = @($Script:CypherDog."${SourceType}List")
        # Prep DynP
        $DynName   = DynP -Name 'Name'       -Type 'String[]' -Mandat 1 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $DynNameList
        $DynEdge   = DynP -Name 'EdgeType'   -Type 'EdgeType' -Mandat 1 -Pos 2 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynTarget = DynP -Name 'TargetType' -Type 'NodeType' -Mandat 1 -Pos 3 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynMax    = DynP -Name 'Degree'     -Type 'String'   -Mandat 0 -Pos 4 -Pipe 0 -PipeProp 0 -VSet @('1','2','3','4','5','6','7','8','9','*')
        $DynCypher = DynP -Name 'Cypher'     -Type 'Switch'   -Mandat 0 -Pos 5 -Pipe 0 -PipeProp 0 -VSet $Null
        # DynP to Dico
        $Dico.Add("Name"      ,$DynName)
        $Dico.Add("EdgeType"  ,$DynEdge)
        $Dico.Add("TargetType",$DynTarget)
        $Dico.Add("Degree"    ,$DynMax)
        $Dico.Add("Cypher"    ,$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{
        $TargetType = $DynTarget.Value
        $EdgeType   = $DynEdge.Value 
        # Max Max
        If($DynMax.Value){
            If($DynMax.Value -eq '*'){$Max='..'}
            else{$Max=".."+(([int]$DynMax.Value))}
            }
        Else{$Max=$Null}    
        # If Max and not MemberOf
        If($DynMax.Value -AND $EdgeType -ne 'MemberOf'){
            # Query
            $Query = "MATCH (A:$TargetType), (B:$SourceType {name: {NAME}}), p=shortestPath((A)<-[r*1$Max]-(B)) RETURN DISTINCT(A) ORDER BY A.name"
            }
        Else{# Query
            $Query = "MATCH (A:$TargetType), (B:$SourceType {name: {NAME}}), p=(A)<-[r:$EdgeType*1$Max]-(B) RETURN DISTINCT(A) ORDER BY A.name"
            }}
    Process{
        Foreach($SourceName in $DynName.Value){
            $Param = @{NAME="$SourceName"}
            if(-Not$DynCypher.IsSet){DogPost $Query $Param}
            }}
    End{if($DynCypher.IsSet){ClipThis $Query $Param}}
    }
#End



################################################ EdgeCreate

<#
.Synopsis
   Syn
.DESCRIPTION
   Desc
.EXAMPLE
   Ex
#>
function New-BloodHoundEdge{
    [CmdletBinding()]
    [Alias('New-Edge','EdgeCreate')]
    Param(
        [Parameter(Mandatory=1,Position=0,ValuefromPipeline=0)][NodeType]$SourceType,
        [Parameter(Mandatory=1,Position=1,ValuefromPipeline=0)][EdgeType]$EdgeType,
        [Parameter(Mandatory=1,Position=2,ValuefromPipeline=0)][NodeType]$TargetType
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynSourceList = @($Script:CypherDog."${SourceType}List")
        $DynTargetList = @($Script:CypherDog."${TargetType}List")
        # Prep DynP
        $DynSource = DynP -Name 'Name'  -Type 'String[]' -Mandat 1 -Pos 3 -Pipe 1 -PipeProp 1 -VSet $DynSourceList
        $DynTarget = DynP -Name 'To'    -Type 'string[]' -Mandat 1 -Pos 4 -Pipe 0 -PipeProp 0 -VSet $DynTargetList
        $DynCypher = DynP -Name 'Cypher'-Type 'Switch'   -Mandat 0 -Pos 5 -Pipe 0 -PipeProp 0 -VSet $Null
        # DynP to Dico
        $Dico.Add("Name"  ,$DynSource)
        $Dico.Add("To"    ,$DynTarget)
        $Dico.Add("Cypher",$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{
        $Query = "MATCH (A:$SourceType) WHERE A.name = {SRC} MATCH (B:$TargetType) WHERE B.name = {TGT} MERGE (A)-[R:$EdgeType]->(B)"
        }
    Process{
        Foreach($SourceName in $DynSource.Value){
            Foreach($TargetName in $DynTarget.Value){
                $Param = @{
                    SRC = "$SourceName"
                    TGT = "$TargetName"
                    }}
            if(-Not$DynCypher.IsSet){DogPost $Query $Param}
            }}
    End{if($DynCypher.IsSet){ClipThis $Query $Param}}
    }
#End



################################################ EdgeRemove

<#
.Synopsis
   Syn
.DESCRIPTION
   Desc
.EXAMPLE
   Ex
#>
function Remove-BloodHoundEdge{
    [CmdletBinding(SupportsShouldProcess=1,ConfirmImpact='High')]
    [Alias('Remove-Edge','EdgeDelete')]
    Param(
        [Parameter(Mandatory=1,Position=0,ValuefromPipeline=0)][NodeType]$SourceType,
        [Parameter(Mandatory=1,Position=1,ValuefromPipeline=0)][EdgeType]$EdgeType,
        [Parameter(Mandatory=1,Position=2,ValuefromPipeline=0)][NodeType]$TargetType
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynSourceList = @($Script:CypherDog."${SourceType}List")
        $DynTargetList = @($Script:CypherDog."${TargetType}List")
        # Prep DynP
        $DynSource = DynP -Name 'Name'  -Type 'String[]' -Mandat 1 -Pos 3 -Pipe 1 -PipeProp 1 -VSet $DynSourceList
        $DynTarget = DynP -Name 'To'    -Type 'string[]' -Mandat 1 -Pos 4 -Pipe 0 -PipeProp 0 -VSet $DynTargetList
        $DynCypher = DynP -Name 'Cypher'-Type 'Switch'   -Mandat 0 -Pos 5 -Pipe 0 -PipeProp 0 -VSet $Null
        # DynP to Dico
        $Dico.Add("Name"  ,$DynSource)
        $Dico.Add("To"    ,$DynTarget)
        $Dico.Add("Cypher",$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{$Query = "MATCH (A:$SourceType) WHERE A.name = {SRC} MATCH (B:$TargetType) WHERE B.name = {TGT} MATCH (A)-[R:$EdgeType]->(B) DELETE R"}
    Process{
        Foreach($SourceName in $DynSource.Value){
            Foreach($TargetName in $DynTarget.Value){
                $Param = @{
                    SRC = "$SourceName"
                    TGT = "$TargetName"
                    }}
            if(-Not$DynCypher.IsSet){DogPost $Query $Param}
            }}
    End{if($DynCypher.IsSet){ClipThis $Query $Param}}
    }
#End



################################################### PathAny

<#
.Synopsis
   Syn
.DESCRIPTION
   Desc
.EXAMPLE
   Ex
#>
function Get-BloodHoundPathAny{
    [Cmdletbinding()]
    [OutputType([BHEdge])]
    [Alias('Get-PathAny','PathAny')]
    Param(
        [Parameter(Mandatory=1,Position=0)][NodeType]$SourceType,
        [Parameter(Mandatory=1,Position=1)][NodeType]$TargetType
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynSourceList = @($Script:CypherDog."${SourceType}List")
        $DynTargetList = @($Script:CypherDog."${TargetType}List")
        # Prep DynP
        $DynSource = DynP -Name 'Name'   -Type 'String[]'  -Mandat 1 -Pos 2 -Pipe 1 -PipeProp 1 -VSet ($DynSourceList+'*')
        $DynTarget = DynP -Name 'To'     -Type 'string[]'  -Mandat 1 -Pos 3 -Pipe 0 -PipeProp 0 -VSet ($DynTargetList+'*')
        $DynEdge   = DynP -Name 'Edge'   -Type 'string'    -Mandat 0 -Pos 4 -Pipe 0 -PipeProp 0 -VSet @('All','Basic','NoACL','NoGPO')
        $DynExclude= DynP -Name 'Exclude'-Type 'EdgeType[]'-Mandat 0 -Pos 5 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynMax    = DynP -Name 'MaxHop' -Type 'Int'       -Mandat 0 -Pos 6 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynCypher = DynP -Name 'Cypher' -Type 'Switch'    -Mandat 0 -Pos 7 -Pipe 0 -PipeProp 0 -VSet $Null
        # DynP to Dico
        $Dico.Add("Name"   ,$DynSource)
        $Dico.Add("To"     ,$DynTarget)
        $Dico.Add("Edge"   ,$DynEdge)
        $Dico.Add("Exclude",$DynExclude)
        $Dico.Add("MaxHop" ,$DynMax)
        $Dico.Add("Cypher" ,$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{
        # EdgeString
        if(-Not$DynEdge.Value -AND $DynExclude.Value){$E = ':'+ (GenEdgeStr All -Exclude $DynExclude.Value)}
        if($DynEdge.Value){$E = ':'+ (GenEdgeStr $DynEdge.Value -Exclude $DynExclude.Value)}
        # Max Hop
        $M=$DynMax.Value
        }
    Process{foreach($SRC in $DynSource.Value){foreach($TGT in $DynTarget.Value){
                #  Any Source -  Any Target
                if($SRC -eq '*' -AND $TGT -eq '*'){
                    if(!$M){Write-Warning "Heavy Query - Setting MaxHop to 3";$M=3}
                    $Query = "MATCH (A:$SourceType) MATCH (B:$TargetType) MATCH p=(A)-[R$E*1..$M]->(B) RETURN DISTINCT(p)"
                    if(-Not$DynCypher.IsSet){DogPost $Query -Expand Data | ToPathObj}
                    }
                #  Any Source - Spec Target
                if($SRC -eq '*' -AND $TGT -ne '*'){
                    if(!$M){Write-Warning "Heavy Query - Setting MaxHop to 7"; $M=7}
                    $Query = "MATCH (A:$SourceType) MATCH (B:$TargetType {name: {TGT}}) MATCH p=(A)-[R$E*1..$M]->(B) RETURN DISTINCT(p)"
                    $Param=@{TGT="$TGT"}
                    if(-Not$DynCypher.IsSet){DogPost $Query $Param -Expand Data | ToPathObj}
                    }
                # Spec Source -  Any Target 
                if($SRC -ne '*' -AND $TGT -eq '*'){
                    if(!$M){Write-Warning "Heavy Query - Setting MaxHop to 7";$M=7}
                    $Query = "MATCH (A:$SourceType {name: {SRC}) MATCH (B:$TargetType) MATCH p=(A)<-[R$E*1..$M]-(B) RETURN DISTINCT(p)"
                    $Param=@{SRC="$SRC"}
                    if(-Not$DynCypher.IsSet){DogPost $Query $Param -Expand Data | ToPathObj}
                    }
                # Spec Source - Spec Source
                if($SRC -ne '*' -AND $TGT -ne '*'){
                    if(!$M){Write-Warning "Heavy Query - Setting MaxHop to 9";$M=9}
                    $Query = "MATCH (A:$SourceType {name: {SRC}}), (B:$TargetType  {name: {TGT}}), p=(A)-[r$E*1..$M]->(B) RETURN DISTINCT(p)"
                    $Param=@{
                        SRC="$SRC"
                        TGT="$TGT"
                        }
                    if(-Not$DynCypher.IsSet){DogPost $Query $Param -Expand Data | ToPathObj}
                    }}}}
    End{if($DynCypher.IsSet){clipThis $Query $Param}}
    }
#End


################################################# PathShort

<#
.Synopsis
   Syn
.DESCRIPTION
   Desc
.EXAMPLE
   Ex
#>
function Get-BloodHoundPathShort{
    [Cmdletbinding()]
    [OutputType([BHEdge])]
    [Alias('Get-PathShort','Path')]
    Param(
        [Parameter(Mandatory=1,Position=0)][NodeType]$SourceType,
        [Parameter(Mandatory=1,Position=1)][NodeType]$TargetType
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynSourceList = @($Script:CypherDog."${SourceType}List")
        $DynTargetList = @($Script:CypherDog."${TargetType}List")
        # Prep DynP
        $DynSource = DynP -Name 'Name'   -Type 'String[]'  -Mandat 1 -Pos 2 -Pipe 1 -PipeProp 1 -VSet ($DynSourceList+'*')
        $DynTarget = DynP -Name 'To'     -Type 'string[]'  -Mandat 1 -Pos 3 -Pipe 0 -PipeProp 0 -VSet ($DynTargetList+'*')
        $DynEdge   = DynP -Name 'Edge'   -Type 'string'    -Mandat 0 -Pos 5 -Pipe 0 -PipeProp 0 -VSet @('All','Basic','NoACL','NoGPO')
        $DynExclude= DynP -Name 'Exclude'-Type 'EdgeType[]'-Mandat 0 -Pos 6 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynCypher = DynP -Name 'Cypher' -Type 'Switch'    -Mandat 0 -Pos 7 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynMax    = DynP -Name 'MaxHop' -Type 'Int'       -Mandat 0 -Pos 8 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynAll    = DynP -Name 'All'    -Type 'Switch'    -Mandat 0 -Pos 9 -Pipe 0 -PipeProp 0 -VSet $Null
        # DynP to Dico
        $Dico.Add("Name"   ,$DynSource)
        $Dico.Add("To"     ,$DynTarget)
        $Dico.Add("Edge"   ,$DynEdge)
        $Dico.Add("Exclude",$DynExclude)
        $Dico.Add("MaxHop" ,$DynMax)
        $Dico.Add("Cypher" ,$DynCypher)
        $Dico.Add("All"    ,$DynAll)
        # Return Dico
        Return $Dico
        }
    Begin{
        # Path Type
        if($DynAll.IsSet){$PType = 'allShortestPaths'}
        else{$PType = 'shortestPath'}       
        # EdgeString
        if(-Not$DynEdge.Value -AND $DynExclude.Value){$E = ':'+ (GenEdgeStr All -Exclude $DynExclude.Value)}
        if($DynEdge.Value){$E = ':'+ (GenEdgeStr $DynEdge.Value -Exclude $DynExclude.Value)}
        # Max Hop
        $M=$DynMax.Value
        }
    Process{foreach($SRC in $DynSource.Value){foreach($TGT in $DynTarget.Value){
                #  Any Source -  Any Target
                if($SRC -eq '*' -AND $TGT -eq '*'){
                    Write-Warning "Heavy Q - No Names Specified"
                    $Query = "MATCH (A:$SourceType), (B:$TargetType), p=$PType((A)-[r$E*1..$M]->(B)) RETURN DISTINCT(p)"
                    if(-Not$DynCypher.IsSet){DogPost $Query -Expand Data | ToPathObj}
                    }
                #  Any Source - Spec Target
                if($SRC -eq '*' -AND $TGT -ne '*'){
                    $Query = "MATCH (A:$SourceType), (B:$TargetType {name: {TGT}}), p=$PType((A)-[r$E*1..$M]->(B)) RETURN DISTINCT(p)"
                    $Param=@{TGT="$TGT"}
                    if(-Not$DynCypher.IsSet){DogPost $Query $Param -Expand Data | ToPathObj}
                    }
                # Spec Source -  Any Target 
                if($SRC -ne '*' -AND $TGT -eq '*'){
                    $Query = "MATCH (A:$SourceType {name: {SRC}}), (B:$TargetType), p=$PType((A)-[r$E*1..$M]->(B)) RETURN p"
                    $Param=@{SRC="$SRC"}
                    if(-Not$DynCypher.IsSet){DogPost $Query $Param -Expand Data | ToPathObj}
                    }
                # Spec Source - Spec Source
                if($SRC -ne '*' -AND $TGT -ne '*'){
                    $Query = "MATCH (A:$SourceType {name: {SRC}}), (B:$TargetType  {name: {TGT}}), p=$PType((A)-[r$E*1..$M]->(B)) RETURN DISTINCT(p)"
                    $Param=@{
                        SRC="$SRC"
                        TGT="$TGT"
                        }
                    if(-Not$DynCypher.IsSet){DogPost $Query $Param -Expand Data | ToPathObj}
                    }}}}
    End{if($DynCypher.IsSet){clipThis $Query $Param}}
    }
#End



##################################################### Memo

function Get-BloodHoundCmdlets{
    [CmdletBinding()]
    [Alias('BloodHound')]
    Param()
    $CmdList = @(
    # CMDLET                                 | SYNOPSIS                                           | Alias               |
    #####################################################################################################################
    @{Cmdlet='Get-BloodHoundCmdlet'          ; Synopsis='MEMO - View CyberDog Cmdlet Memo'        ; Alias='BloodHound'  }
    @{Cmdlet='Get-BloodHoundNode'            ; Synopsis='NODE - View by Type & Name'              ; Alias='Node'        }
    @{Cmdlet='Search-BloodHoundNode'         ; Synopsis='NODE - Search by Key|Prop|PropValue'     ; Alias='NodeSearch'  }
    @{Cmdlet='New-BloodHoundNode'            ; Synopsis='NODE - Add New Node to DB'               ; Alias='NodeCreate'  }
    @{Cmdlet='Set-BloodHoundNode'            ; Synopsis='NODE - Update Node Properties'           ; Alias='NodeUpdate'  }
    @{Cmdlet='Remove-BloodHoundNode'         ; Synopsis='NODE - Remove Node from DB'              ; Alias='NodeDelete'  }
    @{Cmdlet='Get-BloodHoundEdge'            ; Synopsis='EDGE - Get Node by Edge'                 ; Alias='Edge'        }
    @{Cmdlet='Get-BloodHoundEdgeReverse'     ; Synopsis='EDGE - Get Node by Reverse Edge'         ; Alias='EdgeR'       }
    @{Cmdlet='New-BloodHoundEdge'            ; Synopsis='EDGE - Create Edge between Nodes'        ; Alias='EdgeCreate'  }
    @{Cmdlet='Remove-BloodHoundEdge'         ; Synopsis='EDGE - Remove Edge between Nodes'        ; Alias='EdgeDelete'  }
    @{Cmdlet='Get-BloodHoundPathShort'       ; Synopsis='PATH - [All]Shortest'                    ; Alias='Path'        }
    @{Cmdlet='Get-BloodHoundPathAny'         ; Synopsis='PATH - Any - /!\ MaxHop'                 ; Alias='PathAny'     }
    @{Cmdlet='Get-BloodHoundPathCheap'       ; Synopsis='PATH - Cheapest (MemberOf cost 0)'       ; Alias='PathCheap'   }
    @{Cmdlet='Get-BloodHoundPathCost'        ; Synopsis='PATH - Measure Path Cost over pipeline'  ; Alias='PathCost'    }
    @{Cmdlet='Get-BloodHoundWald0Index'      ; Synopsis='PATH - Measure Wald0Index over Pipeline' ; Alias='Wald0IO'     }
    @{Cmdlet='Send-BloodHoundPost'           ; Synopsis='POST - Send Cypher to REST API'          ; Alias='DogPost'     }
    @{Cmdlet='Get-BHTopNodeCount'            ; Synopsis='LIST - Count Top Member/Admin/Logon/...' ; Alias='TopNode'     }
    @{Cmdlet='Get-BHCrossDomainRelationShip' ; Synopsis='LIST - Cross Domain Member/Session'      ; Alias='CrossDomain' }
    @{Cmdlet='Get-BHComputerSessionUser'     ; Synopsis='LIST - Computers with Session of User X' ; Alias='SessionList' }
    @{Cmdlet='Get-BHUserSessionComputer'     ; Synopsis='LIST - Users with session on Computer X' ; Alias='LogonList'   }
    @{Cmdlet='Get-BHUserAdminComputer'       ; Synopsis='LIST - Users Admin to Computer X'        ; Alias='AdminList'   }
    @{Cmdlet='Get-BHUserMemberGroup'         ; Synopsis='LIST - Users Member of Group X'          ; Alias='MemberList'  }
    @{Cmdlet='Get-BHGroupMemberUser'         ; Synopsis='LIST - Group Membership User X'          ; Alias='GroupList'   }
    @{Cmdlet='Join-BHCypherQuery'            ; Synopsis='MISC - Join Multiple Cypher Queries'     ; Alias='Union'       }
    #####################################################################################################################
    )
    # Return Help Obj
    Return $CmdList | %{New-Object PSCustomObject -Property $_} | Select Cmdlet,Synopsis,Alias
    }
#End



#endregion ################################################



###########################################################
#region ############################################ EXTRAS


################################################ Wald0Index


function Get-BHCrossDomainRelationShip{
    [CmdletBinding()]
    [Alias('BHCrossDomainRelationShip','CrossDomain')]
    Param(
        [Validateset('Session','Member')]
        [Parameter(Mandatory=1)][String]$Type,
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    # Prep vars
    Switch($Type){
        Member  {$Source='User'    ;$target='Group';$Edge='MemberOf'}
        Session {$Source='Computer';$target='User' ;$Edge='HasSession'}
        }
    $PathQ = "MATCH p=((S:$Source)-[r:$Edge*1]->(T:$Target)) 
WHERE NOT S.domain = T.domain"
    if($Cypher){$Clip =  "$PathQ`r`nRETURN p"; Set-Clipboard $Clip; Return $Clip}
    #Call
    dogpost "$PathQ
WITH p,
S.name AS Sname,
S.domain AS Sdomain,
T.name AS Tname,
T.domain AS Tdomain
RETURN {
From:   Sdomain,
To:     Tdomain,
Source: Sname,
Target: Tname
} as Obj" -Expand Data |
    Select -expand Syncroot | 
    Add-Member -MemberType NoteProperty -Name Edge -Value $Edge -PassThru | 
    Select From,to,Source,Edge,Target | Sort From,To,Target
    }
#End



function Get-BHTopNodeCount{
    [CmdletBinding()]
    [Alias('BHTopNodeCount','TopNode')]
    Param(
        [ValidateSet('Admin','Session','Logon','group','Member')]
        [Parameter(Mandatory=1,Position=0)][String]$type,
        [Parameter(Mandatory=0,Position=1)][Alias('Limit')][Int]$Count=5,
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    DynamicParam{
        # DynDico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynParam
        $DynDom = DynP -Name 'Domain' -Type 'String' -Mandat 0 -Pos 2 -VSet @($Script:CypherDog.DomainList)
        $Dico.Add('Domain',$DynDom)
        # Return Dico
        Return $Dico
        }
    Process{
        if($DynDom.Value){$Dom=" {domain: '$($DynDom.Value)'}"}
        if($Count -eq '0'){$Lim = $Null}Else{$Lim = "LIMIT $Count"}
        # Admin
        if($type -eq 'Admin'){
            $Q1 = "MATCH p=((S:User$Dom)-[r:MemberOf|:AdminTo*1..]->(T:Computer))"
            $Q2 = "$Q1
WITH
S.name as s,
COUNT(DISTINCT(T)) as t
RETURN {Name: s, Count: t} as SingleColumn
ORDER BY t DESC
$Lim"
            }
        # Session
        if($Type -eq 'Session'){
        $Q1 = "MATCH (U:User$Dom)<-[r:HasSession*1..]-(C:Computer)"
        $Q2 = "$Q1
WITH
U.name as n,
COUNT(DISTINCT(C)) as c 
RETURN {Name: n, Count: c} as SingleColumn
ORDER BY c DESC
$Lim"
            }
        # Logon
        if($Type -eq 'Logon'){
            $Q1 = "MATCH p=shortestPath((A:User)<-[r:HasSession*1]-(B:Computer$Dom))" 
            $Q2 = "$Q1
WITH B.name as n,
COUNT(DISTINCT(A)) as c   
RETURN {Name: n, Count: c} as SingleColumn
ORDER BY c DESC
$Lim"
            }
        # Group
        if($Type -eq 'Group'){
            $Q1 = "MATCH p=shortestPath((A:User$Dom)-[r:MemberOf*1..]->(B:Group))" 
            $Q2 = "$Q1
WITH A.name as n,
COUNT(DISTINCT(B)) as c   
RETURN {Name: n, Count: c} as SingleColumn
ORDER BY c DESC
$Lim"
            }
        # Group
        if($Type -eq 'Member'){
            $Q1 = "MATCH p=shortestPath((A:User)-[r:MemberOf*1..]->(B:Group$Dom))" 
            $Q2 = "$Q1
WITH B.name as n,
COUNT(DISTINCT(A)) as c   
RETURN {Name: n, Count: c} as SingleColumn
ORDER BY c DESC
$Lim"
            }
        # Outout
        If($cypher){$Q = "$Q1 RETURN p";Set-clipBoard $Q;Return $Q}
        Else{
            DogPost $Q2 -Expand Data| Select -Expand SyncRoot
            }}}
#########End


function Get-BHUserSessionComputer{
    [CmdletBinding()]
    [Alias('BHUserSessionComputer','BHUserLogonComputer','LogonList')]
    Param(
        [Parameter()][Switch]$Cypher
        )
    DynamicParam{
        # DynDico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynParam
        $DynComp = DynP -Name 'Name' -Type 'String[]' -Mandat 1 -Pos 0 -Pipe 1 -PipeProp 1 -VSet @($Script:CypherDog.ComputerList)
        $Dico.Add('Name',$DynComp)
        # Return Dico
        Return $Dico
        }
    Process{Foreach($U in @($DynComp.Value)){
            $Q="MATCH p=((U:User)<-[r:HasSession*1]-(B:Computer {name: '$U'}))"
            If($Cypher){$Q1 = "$Q RETURN p";Set-Clipboard $Q1;Return $Q1}
            else{DogPost "$Q RETURN U" -Expand Data,data | sort Name}
            }}}
#########End





function Get-BHComputerSessionUser{
    [CmdletBinding()]
    [Alias('BHComputerSessionUser','SessionList')]
    Param(
        [Parameter()][Switch]$Cypher
        )
    DynamicParam{
        # DynDico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynParam
        $DynUser = DynP -Name 'Name' -Type 'String[]' -Mandat 1 -Pos 0 -Pipe 1 -PipeProp 1 -VSet @($Script:CypherDog.UserList)
        $Dico.Add('Name',$DynUser)
        # Return Dico
        Return $Dico
        }
    Process{Foreach($U in @($DynUser.Value)){
            $Q="MATCH p=((C:Computer)-[r:HasSession*1]->(U:User {name: '$U'}))"
            If($Cypher){$Q1 = "$Q RETURN p";Set-Clipboard $Q1;Return $Q1}
            else{DogPost "$Q RETURN DISTINCT(C)" -Expand Data,data | sort Name}
            }}}
#########End

function Get-BHUserAdminComputer{
    [CmdletBinding()]
    [Alias('BHUserAdminComputer','AdminListTo')]
    Param(
        [Parameter()][Switch]$Cypher
        )
    DynamicParam{
        # DynDico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynParam
        $DynComp = DynP -Name 'Name' -Type 'String[]' -Mandat 1 -Pos 0 -Pipe 1 -PipeProp 1 -VSet @($Script:CypherDog.ComputerList)
        $Dico.Add('Name',$DynComp)
        # Return Dico
        Return $Dico
        }
    Process{Foreach($C in @($DynComp.Value)){
            $Q="MATCH p=((U:User)-[r:MemberOf|:AdminTo*1..]->(C:Computer {name: '$C'}))"
            If($Cypher){$Q1 = "$Q RETURN p";Set-Clipboard $Q1;Return $Q1}
            else{DogPost "$Q RETURN DISTINCT(U)" -Expand Data,data | Sort Name}
            }}}
#########End

function Get-BHComputerAdminUser{
    [CmdletBinding()]
    [Alias('BHComputerAdminUser','AdminListBy')]
    Param(
        [Parameter()][Switch]$Cypher
        )
    DynamicParam{
        # DynDico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynParam
        $DynUser= DynP -Name 'Name' -Type 'String[]' -Mandat 1 -Pos 0 -Pipe 1 -PipeProp 1 -VSet @($Script:CypherDog.UserList)
        $Dico.Add('Name',$DynUser)
        # Return Dico
        Return $Dico
        }
    Process{Foreach($U in @($DynUser.Value)){
            $Q="MATCH (C:Computer)<-[r:MemberOf|:AdminTo*1..]-(U:User {name: '$U'})"
            If($Cypher){$Q1 = "$Q RETURN p";Set-Clipboard $Q1;Return $Q1}
            else{DogPost "$Q RETURN DISTINCT(C)" -Expand Data,data | Sort Name}
            }}}
#########End

function Get-BHUserMemberGroup{
    [CmdletBinding()]
    [Alias('BHUserMemberGroup','MemberList')]
    Param(
        [Parameter()][Switch]$Cypher
        )
    DynamicParam{
        # DynDico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynParam
        $DynComp = DynP -Name 'Name' -Type 'String[]' -Mandat 1 -Pos 0 -Pipe 1 -PipeProp 1 -VSet @($Script:CypherDog.GroupList)
        $Dico.Add('Name',$DynComp)
        # Return Dico
        Return $Dico
        }
    Process{Foreach($G in @($DynComp.Value)){
            $Q="MATCH p=((U:User)-[r:MemberOf*1..]->(G:Group {name: '$G'}))"
            If($Cypher){$Q1 = "$Q RETURN p";Set-Clipboard $Q1;Return $Q1}
            else{DogPost "$Q RETURN DISTINCT(U)" -Expand Data,data | Sort Name}
            }}}
#########End


function Get-BHGroupMemberUser{
    [CmdletBinding()]
    [Alias('BHGroupMemberUser','GroupList')]
    Param(
        [Parameter()][Switch]$Cypher
        )
    DynamicParam{
        # DynDico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynParam
        $DynComp = DynP -Name 'Name' -Type 'String[]' -Mandat 1 -Pos 0 -Pipe 1 -PipeProp 1 -VSet @($Script:CypherDog.UserList)
        $Dico.Add('Name',$DynComp)
        # Return Dico
        Return $Dico
        }
    Process{Foreach($U in @($DynComp.Value)){
            $Q="MATCH p=((U:User {name: '$U'})-[r:MemberOf*1..]->(G:Group))"
            If($Cypher){$Q1 = "$Q RETURN p";Set-Clipboard $Q1;Return $Q1}
            else{DogPost "$Q RETURN DISTINCT(G)" -Expand Data,data | Sort Name}
            }}}
#########End


<#
.Synopsis
   Wald0 Index
.DESCRIPTION
   Calculate wald0 Index for specified Group
.EXAMPLE
   Ex
#>
function Get-BloodHoundWald0IO{
    [CmdletBinding()]
    [Alias('Get-Wald0IO','Wald0IO')]
    Param(
        [Parameter(ValueFromPipeline=1,ValueFromPipelineByPropertyName=1,Mandatory=0,Position=0)][Alias('TargetGroup')][String]$Name,
        [ValidateSet('Inbound','Outbound')]
        [Parameter(Mandatory=0)][String]$Direction,
        [ValidateSet('User','Computer')]
        [Parameter(Mandatory=0)][String]$Type,
        [Parameter(Mandatory=0)][Switch]$NoACL,
        [Parameter(Mandatory=0)][Switch]$NoGPO,
        [Parameter(Mandatory=0)][Switch]$DomainOnly,
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    Begin{
        if($NoACL -AND $NoGPO){$EdgeStr = ':MemberOf|:HasSession|:AdminTo'}
        elseif($NoACL -AND -Not$NoGPO){$EdgeStr = ':MemberOf|:HasSession|:AdminTo|:GpLink|:Contains|:Owns'}
        elseif(-Not$NoACL -AND $NoGPO){$EdgeStr = ':MemberOf|:HasSession|:AdminTo|:ForceChangePassword|:AddMembers|:GenericAll|:GenericWrite|:WriteOwner|:WriteDACL|:AllExtendedRights'}
        else{$EdgeStr = $Null}
        }
    Process{
        $Splat = @{} 
        $PSBoundParameters.Keys -notmatch "Name|direction|Type" | %{$Splat.Add($_,$true)}
        if(-Not$Type -AND -Not$Direction){
            Get-Wald0IO -Name $Name -Direction Inbound -Type User @Splat
            Get-Wald0IO -Name $Name -Direction Outbound -Type Computer @Splat
            }
        elseif($Direction -AND -Not$Type){
            Get-Wald0IO -Name $Name -Direction $Direction -Type User @Splat
            Get-Wald0IO -Name $Name -Direction $Direction -Type Computer @Splat
            }
        elseif($Type -AND -Not$Direction){
            Get-Wald0IO -Name $Name -Direction Inbound -Type $Type @Splat
            Get-Wald0IO -Name $Name -Direction Outbound -Type $type @Splat
            }
        ## ACTION ##
        elseif($Type -AND $Direction){
            # TargetFolder
            $TargetGroup = $Name
            # Split Domain
            $TargetDomain = $Name.split('@')[1]
            # Dom
            if($DomainOnly){
                $Dom=" {domain: '$TargetDomain'}"
                $Scope = "$TargetDomain"
                }
            else{$Scope='*'}
            # Query Parts Inbound|Outbound
            if($Direction -eq 'Inbound'){
                $Q1 = "p = shortestPath((x:$Type$Dom)-[r$EdgeStr*1..]->(g:Group {name:'$TargetGroup'}))"}
                $Q2 = "MATCH (tx:$type$Dom), $Q1" 
            if($Direction -eq 'Outbound'){
                $Q1 = "p = shortestPath((g:Group {name:'$TargetGroup'})-[r$EdgeStr*1..]->(x:$type$Dom))"
                $Q2 = "MATCH (tx:$type$Dom), $Q1"
                }
            # Full Cypher Query
            $Wald0IO = "$Q2
WITH
g.name as G,
COUNT(DISTINCT(tx)) as TX,
COUNT(DISTINCT(x)) as X,
ROUND(100*AVG(LENGTH(RELATIONSHIPS(p))))/100 as H,
ROUND(100*AVG(LENGTH(FILTER(z IN EXTRACT(r IN RELATIONSHIPS(p)|TYPE(r)) WHERE z<>'MemberOf'))))/100 AS C,
ROUND(100*AVG(LENGTH(FILTER(y IN EXTRACT(n IN NODES(p)|LABELS(n)[0]) WHERE y='Computer'))))/100 AS T
WITH G,TX,X,H,C,T,
ROUND(100*(100.0*X/TX))/100 as P
RETURN {
TotalCount: TX,
PathCount:   X,
Percent:     P,
HopAvg:      H,
CostAvg:     C,
TouchAvg:    T
} AS Wald0IndexIO"
            # If Cypher > Set Clipboard
            if($Cypher){$Q = "MATCH $Q1 RETURN p";Set-Clipboard $Q; Return $Q}
            # Else Return Object
            else{
                # Call
                $Data = DogPost $Wald0IO -x data | Select -Expand Syncroot | select PathCount,TotalCount,Percent,HopAvg,CostAvg,TouchAvg
                Return [PScustomObject]@{
                    Domain     = $Scope
                    Type       = $Type
                    Total      = $Data.TotalCount
                    Direction  = $Direction
                    Target     = $TargetGroup                    
                    Count      = $Data.PathCount
                    Percent    = $Data.Percent
                    Hop        = $Data.HopAvg
                    Touch      = $Data.TouchAvg
                    Cost       = $Data.CostAvg
                    }}}}
    End{if($Cypher){}}
    }
#End



################################################# PathCost

function Get-BloodHoundPathCost{
    [Alias('PathCost')]
    Param(
        [Parameter(Mandatory=1,ValueFromPipeline=1)][BHEdge]$Path
        )
    Begin{$Collection=@()}
    Process{$Collection += $Path}
    End{
        $Result = $Collection | group Id | %{
            [PSCustomObject]@{
                ID=$_.name
                Cost=($_.Group.Edge | Where {$_ -notmatch 'MemberOf'}).count
                Hop=$_.Count
                Path=$_.Group
                }}
        Return $Result | Sort Cost,Hop
        }}

################################################# PathCheap

<#
.Synopsis
   Syn
.DESCRIPTION
   Desc
.EXAMPLE
   Ex
#>
function Get-BloodHoundPathCheap{
    [Cmdletbinding()]
    [OutputType([BHEdge])]
    [Alias('Get-PathCheap','PathCheap')]
    Param(
        [Parameter(Mandatory=1,Position=0)][NodeType]$SourceType,
        [Parameter(Mandatory=1,Position=1)][NodeType]$TargetType
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynSourceList = @($Script:CypherDog."${SourceType}List")
        $DynTargetList = @($Script:CypherDog."${TargetType}List")
        # Prep DynP
        $DynSource = DynP -Name 'Name'   -Type 'String'  -Mandat 1 -Pos 2 -Pipe 1 -PipeProp 1 -VSet ($DynSourceList)
        $DynTarget = DynP -Name 'To'     -Type 'string'  -Mandat 1 -Pos 3 -Pipe 0 -PipeProp 0 -VSet ($DynTargetList)
        $DynEdge   = DynP -Name 'Edge'   -Type 'string'    -Mandat 0 -Pos 5 -Pipe 0 -PipeProp 0 -VSet @('All','Basic','NoACL','NoGPO')
        $DynExclude= DynP -Name 'Exclude'-Type 'EdgeType[]'-Mandat 0 -Pos 6 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynCypher = DynP -Name 'Cypher' -Type 'Switch'    -Mandat 0 -Pos 7 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynExpand = DynP -Name 'Expand' -Type 'Int'       -Mandat 0 -Pos 8 -Pipe 0 -PipeProp 0 -VSet @(1,2,3)
        # DynP to Dico
        $Dico.Add("Name"   ,$DynSource)
        $Dico.Add("To"     ,$DynTarget)
        $Dico.Add("Edge"   ,$DynEdge)
        $Dico.Add("Exclude",$DynExclude)
        $Dico.Add("Cypher" ,$DynCypher)
        $Dico.Add('Expand', $DynExpand)
        # Return Dico
        Return $Dico
        }
    Begin{     
        # EdgeString
        if(-Not$DynEdge.Value -AND $DynExclude.Value){$E = ':'+ (GenEdgeStr All -Exclude $DynExclude.Value)}
        if($DynEdge.Value){$E = ':'+ (GenEdgeStr $DynEdge.Value -Exclude $DynExclude.Value)}
        }
    Process{
        # Get length Cheapest
        $Q = "MATCH (S:$SourceType {name: '$($DynSource.Value)'}), (T:$TargetType {name: '$($DynTarget.Value)'}), p=shortestPath((S)-[r$E*1..]->(T)) RETURN LENGTH(p)" 
        try{$Max = (DogPost $Q -Expand data)[0]}catch{}
        # if expand 
        if($Max){$Max += $DynExpand.value
            # Query Cheapest all path max length
            $Q = "MATCH (S:$SourceType {name: '$($DynSource.Value)'}), 
(T:$TargetType {name: '$($DynTarget.Value)'}), 
p=((S)-[r$E*1..$Max]->(T)) 
WITH p,
LENGTH(FILTER(x IN EXTRACT(r in RELATIONSHIPS(p)|TYPE(r)) WHERE x <>'MemberOf')) as Cost
RETURN p
ORDER BY Cost 
LIMIT 1"
            if(-Not$DynCypher.IsSet){DogPost $Q -Expand Data | TopathObj} 
            }}
    End{if($DynCypher.IsSet){clipThis $Q $Param}}
    }
#End

#endregion ################################################



###########################################################
###################################################### INIT
$ASCII
cachenode

####################################################### EOF
###########################################################

function Join-BHCypher{
    [Alias('Union')]
    Param(
        [Parameter(ValueFromPipeline=1)][string[]]$Queries
        )
    Begin{$QCollection = @()}
    Process{foreach($Q in $Queries){$QCollection+=$Q}}
    End{$Out=$QCollection-join"`r`nUNION ALL`r`n";$Out|Set-clipboard;Return $Out}
    }

function Find-NameMatch{
    [Alias('NameMatch')]
    Param(
        [Parameter(Mandatory=1,Position=0)][Array]$In,
        [Parameter(Mandatory=1,Position=1)][Array]$And
        )
    Compare $In.name $And.name -IncludeEqual | Where SideIndicator -eq == | Select -ExpandProperty InputObject
    }

# Member of MIGRATIONB@INTERNAL with Session on FILESERVER1.INTERNAL.LOCAL?
#Node User (NameMatch (MemberList MIGRATIONB@INTERNAL.LOCAL) -And (LogonList FILESERVER1.INTERNAL.LOCAL))