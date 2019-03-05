###########################################################
# CypherDog2.0 - BloodHound Dog Whisperer - @SadProcessor #
###########################################################

###################################################### ToDo
# - Code       > Check all Aliases                      [X]
# - Code       > CleanUp Stuff                          [~]
# - BloodHound > Update Table                           [X]
# - EdgeInfo   > CopyPaste info stuff                   [ ]
# - HelpPages  > Description/Examples++                 [ ]
# - Doc        > Generate Wiki [+ HelpURI Binding]      [ ]
# - DeBug      > Beta via Slack                         [ ]

###########################################################

###########################################################
#region ############################################## VARS


##################################################### ASCII
$ASCII= @("
 _____________________________________________
 _______|_____________________________________
 ______||_______________________CYPHERDOG2.0__
 ______||-________...__________________ Beta__
 _______||-__--||||||||-._____________________
 ________!||||||||||||||||||--________________
 _________|||||||||||||||||||||-______________
 _________!||||||||||||||||||||||.____________
 ________.||||||!!||||||||||||||||-___________
 _______|||!||||___||||||||||||||||.__________
 ______|||_.||!___.|||'_!||_'||||||!__________
 _____||___!||____|||____||___|||||.__________
 ______||___||_____||_____||!__!|||'__________
 ___________ ||!____||!_______________________
 _____________________________________________

 BloodHound Dog Whisperer - @SadProcessor 2019
")

##################################################### Enums
## NodeType
enum NodeType{
    Computer
    Domain
    Group
    User
    GPO
    OU
    }

## EdgeType
# Full
enum EdgeType{
    # Default
    MemberOf
    HasSession
    AdminTo
    TrustedBy
    # ACL
    AllExtendedRights
    AddMember
    ForceChangePassword
    GenericAll
    GenericWrite
    Owns
    WriteDacl
    WriteOwner
    ReadLAPSPassword
    # GPO
    Contains
    GpLink
    # Special
    CanRDP
    ExecuteDCOM
    AllowedToDelegate
    }
# Default
enum EdgeDef{
    MemberOf
    HasSession
    AdminTo
    TrustedBy  
    }
# ACL
enum EdgeACL{
    AllExtendedRights
    AddMember
    ForceChangePassword
    GenericAll
    GenericWrite
    Owns
    WriteDacl
    WriteOwner
    ReadLAPSPassword    
    }
# GPO/OU
enum EdgeGPO{
    Contains
    GpLink
    }
# Special
enum EdgeSpc{
    CanRDP
    ExecuteDCOM
    AllowedToDelegate
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
#region ############################################## UTIL

# CacheNode
# DynP
# GenEdgeStr
# ToPathObj
# ClipThis
# JoinCypher
# FixPathID

################################################# CacheNode
function CacheNode{
<#
.Synopsis
   Cache Bloodhound Node Lists [Internal]
.DESCRIPTION
   Cache Name Lists per Node type
   All types if none specified
   Use at startup and on Node Create/Delete
.EXAMPLE
    CacheNode
    Caches Name lists for All Node Types
.EXAMPLE
    CacheNode Computer,User
    Caches Name Lists of specified node types
#> 
    [CmdletBinding()]
    Param(
        # Specify Type(s)
        [parameter(Mandatory=0)][NodeType[]]$Type
        )
    # No Type == All
    If($Type -eq $Null){$Type=[Enum]::GetNames([NodeType])}
    # For each type
    foreach($T in $Type){
        Write-Verbose "Caching Node List: $T" 
        # Prep Query
        $Query = "MATCH (n:$T) RETURN n"
        # Cache matching name list
        $Script:CypherDog."${T}List"=(DogPost $Query).name
        }}
#####End

###################################################### DynP
function DynP{
<#
.Synopsis
   Get Dynamic Param [Internal]
.DESCRIPTION
   Return Single DynParam to be added to dictionnary
.EXAMPLE
    DynP TestParam String -mandatory 1
#>
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
function GenEdgeStr{
<#
.Synopsis
   Generate Edge String [Internal]
.DESCRIPTION
   Generate Edge String for Cypher Queries 
.EXAMPLE
   GenEdgeStr NoACL,NoSpc -Include ForceChangePassword
#>
    Param(
        [ValidateSet('NoDef','NoACL','NoGPO','NoSpc')]
        [Parameter(Mandatory=0)][String[]]$Type,
        [Parameter(Mandatory=0)][Edgetype[]]$Exclude,
        [Parameter(Mandatory=0)][Edgetype[]]$Include
        )
    # Start with all
    $R = [Enum]::GetNames([EdgeType])
    # Exclude Category
    Switch -regex ($Type) {
        NoDef {$R = (Compare $R ([Enum]::GetNames([EdgeDef]))).InputObject}
        NoACL {$R = (Compare $R ([Enum]::GetNames([EdgeACL]))).InputObject}
        NoGPO {$R = (Compare $R ([Enum]::GetNames([EdgeGPO]))).InputObject}
        NoSpc {$R = (Compare $R ([Enum]::GetNames([EdgeSpc]))).InputObject}
        }
    # Exclude stuff
    foreach($x in $Exclude){$R = $R -ne $x}
    # Include stuff
    Foreach($y in $Include){$R += $y}
    # Return String
    Return $R -join '|:'
    }
#end

################################################# ToPathObj
function ToPathObj{
<#
.Synopsis
   Parse to Path Object [Internal]
.DESCRIPTION
   Format query result as Path Object
.EXAMPLE
    Example
#>
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
                    } | select 'ID','Step','StartNode','Edge','Direction','EndNode'}
            $ID+=1
            }}}
    End{<#NoOp#>}
    }
#End

################################################## ClipThis
Function ClipThis{
<#
.Synopsis
   Query to Clipboard  [Internal]
.DESCRIPTION
   Displays resulting query and sets clipboard
.EXAMPLE
   ClipThis $Query [-with $Params]
#>
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

################################################ JoinCypher
function JoinCypher{
<#
.Synopsis
   Cypher Query Union
.DESCRIPTION
   Join Cypher Querie with UNION
.EXAMPLE
   Example
#>
    [Alias('Union')]
    Param(
        [Parameter(ValueFromPipeline=1)][string[]]$Queries
        )
    Begin{$QCollection = @()}
    Process{foreach($Q in $Queries){$QCollection+=$Q}}
    End{$Out=$QCollection-join"`r`nUNION ALL`r`n";$Out|Set-clipboard;Return $Out}
    }
#End

################################################# FixPathID
function FixPathID{
<#
.Synopsis
   Fix Path ID
.DESCRIPTION
   Fix Path ID
.EXAMPLE
   Example
#>
    [Alias('FixID')]
    Param(
        [Parameter(mandatory=1,ValueFromPipeline=1)][BHEdge]$Path
        )
    Begin{$ID=-1}
    Process{foreach($P in $Path){
        if($P.Step -eq 0){$ID+=1}
        $P.ID=$ID
        Return $P
        }}
    End{}
    }
#end

#endregion ################################################


###########################################################
#region ############################################## MISC

# Get-BloodHoundCmdlet
# Send-BloodHoundPost

################################################ BloodHound
function Get-BloodHoundCmdlet{
<#
.Synopsis
   BloodHound RTFM - Get Cmdlet
.DESCRIPTION
   Get Bloodhound [CypherDog] Cmdlets
.EXAMPLE
   BloodHound
.EXAMPLE
   BloodHound -Online
#>
    [CmdletBinding(HelpURI='https://Github.com/SadProcessor')]
    [Alias('BloodHound','CypherDog')]
    Param([Parameter()][Switch]$Online)
    if($Online){Get-Help Get-BloodHoundCmdlet -Online; Return}
    $CmdList = @(
    ######################################################################################################################
    # CMDLET                                 | SYNOPSIS                                        | Alias                   |
    ######################################################################################################################
	@{Cmdlet='Get-BloodHoundCmdlet'          ; Synopsis='BloodHound RTFM - Get Cmdlet'         ; Alias='BloodHound'      }
	@{Cmdlet='Send-BloodHoundPost'           ; Synopsis='BloodHound POST - Cypher to REST API' ; Alias='DogPost'         }
    ######################################################################################################################
	@{Cmdlet='Get-BloodHoundNode'            ; Synopsis='BloodHound Node - Get Node'           ; Alias='Node'            }
	@{Cmdlet='Search-BloodHoundNode'         ; Synopsis='BloodHound Node - Search Node'        ; Alias='NodeSearch'      }
	@{Cmdlet='New-BloodHoundNode'            ; Synopsis='BloodHound Node - Create Node'        ; Alias='NodeCreate'      }
	@{Cmdlet='Set-BloodHoundNode'            ; Synopsis='BloodHound Node - Update Node'        ; Alias='NodeUpdate'      }
	@{Cmdlet='Remove-BloodHoundNode'         ; Synopsis='BloodHound Node - Delete Node'        ; Alias='NodeDelete'      }
	@{Cmdlet='Get-BloodHoundNodeList'        ; Synopsis='BloddHound Node - Get List'           ; Alias='List'            }
	@{Cmdlet='Get-BloodHoundNodeHighValue'   ; Synopsis='BloodHound Node - Get HighValue'      ; Alias='HighValue'       }
	@{Cmdlet='Get-BloodHoundNodeOwned'       ; Synopsis='BloodHound Node - Get Owned'          ; Alias='Owned'           }
	@{Cmdlet='Get-BloodHoundNodeNote'        ; Synopsis='BloodHound Node - Get Notes'          ; Alias='Note'            }
	@{Cmdlet='Set-BloodHoundNodeNote'        ; Synopsis='BloodHound Node - Set Notes'          ; Alias='NoteUpdate'      }
	@{Cmdlet='Get-BloodHoundBlacklist'       ; Synopsis='BloodHound Node - Get Blacklist'      ; Alias='Blacklist'       }
	@{Cmdlet='Set-BloodHoundBlacklist'       ; Synopsis='BloodHound Node - Set Blacklist'      ; Alias='BlacklistAdd'    }
	@{Cmdlet='Remove-BloodHoundBlacklist'    ; Synopsis='BloodHound Node - Remove Blacklist'   ; Alias='BlacklistDelete' }
    ######################################################################################################################
	@{Cmdlet='Get-BloodHoundEdge'            ; Synopsis='BloodHound Edge - Get Target'         ; Alias='Edge'            }
	@{Cmdlet='Get-BloodHoundEdgeReverse'     ; Synopsis='BloodHound Edge - Get Source'         ; Alias='EdgeR'           }
	@{Cmdlet='Get-BloodHoundEdgeCrossDomain' ; Synopsis='BloodHound Edge - Get CrossDomain'    ; Alias='CrossDomain'     }
	@{Cmdlet='Get-BloodHoundEdgeCount'       ; Synopsis='BloodHound Edge - Get Count'          ; Alias='EdgeCount'       }
	@{Cmdlet='Get-BloodHoundEdgeInfo'        ; Synopsis='BloodHound Edge - Get Info'           ; Alias='EdgeInfo'        }
	@{Cmdlet='New-BloodHoundEdge'            ; Synopsis='BloodHound Edge - Create Edge'        ; Alias='EdgeCreate'      }
	@{Cmdlet='Remove-BloodHoundEdge'         ; Synopsis='BloodHound Edge - Delete Edge'        ; Alias='EdgeDelete'      }
    ######################################################################################################################
	@{Cmdlet='Get-BloodHoundPathShort'       ; Synopsis='BloodHound Path - Get Shortest'       ; Alias='Path'            }
	@{Cmdlet='Get-BloodHoundPathAny'         ; Synopsis='BloodHound Path - Get Any'            ; Alias='PathAny'         }
	@{Cmdlet='Get-BloodHoundPathCost'        ; Synopsis='BloodHound Path - Get Cost'           ; Alias='PathCost'        }
	@{Cmdlet='Get-BloodHoundPathCheap'       ; Synopsis='BloodHound Path - Get Cheapest'       ; Alias='PathCheap'       }
	@{Cmdlet='Get-BloodHoundWald0IO'         ; Synopsis='BloodHound Path - Wald0 Index'        ; Alias='Wald0IO'         }
    ######################################################################################################################
    )
    # Return Help Obj
    Return $CmdList | %{New-Object PSCustomObject -Property $_} | Select Cmdlet,Synopsis,Alias,@{n='RTFM';e={"Help $($_.Alias)"}}
    }
#End

################################################### DogPost
function Send-BloodHoundPost{
<#
.Synopsis
   BloodHound POST - Cypher to REST API
.DESCRIPTION
   DogPost $Query [$Params] [-expand <prop,prop>]
   Post Cypher Query to DB REST API
.EXAMPLE
    $query="MATCH (n:User) RETURN n"
    DogPost $Query
.EXAMPLE
    $query  = "MATCH (A:Computer {name: {ParamA}}) RETURN A"
    $Params = @{ParamA="APOLLO.EXTERNAL.LOCAL"}
    DogPost $Query $Params
.EXAMPLE
    $Query = "MATCH (A:User {name: {ParamA}}), (B:Group {name: {ParamB}}), x=shortestPath((A)-[*1..]->(B)) RETURN x"
    $Params= @{ParamA="ACHAVARIN@EXTERNAL.LOCAL";ParamB="DOMAIN ADMINS@EXTERNAL.LOCAL"}
    DogPost $Query $Params -Expand Data | ToPathObj
.EXAMPLE
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

#endregion ################################################


###########################################################
#region ############################################## NODE

# Get-BloodHoundNode
# Search-BloodHoundNode
# New-BloodHoundNode
# Set-BloodHoundNode
# Remove-BloodHoundNode
# Get-BloodHoundNodeList
# Get-BloodHoundNodeHighValue
# Get-BloodHoundNodeOwned
# Get-BloodHoundNodeNote
# Set-BloodHoundNodeNote
# Get-BloodHoundBlacklist
# Set-BloodHoundBlacklist
# Remove-BloodHoundBlacklist

###################################################### Node
function Get-BloodHoundNode{
<#
.Synopsis
   BloodHound Node - Get Node
.DESCRIPTION
   Get BloodHound Node by Type and Name(s)
.EXAMPLE
   Get-BloodhoundNode User
.EXAMPLE
   Node User BRITNI_GIRARDIN@DOMAIN.LOCAL  
#>
    [CmdletBinding()]
    [Alias('Get-Node','Node')]
    Param(
        [Parameter(Mandatory=1,Position=0,ValuefromPipeline=0)][NodeType]$Type,
        [Parameter(Mandatory=0)][Switch]$Label,
        [Parameter(Mandatory=0)][Switch]$Notes,
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
                    if(-Not$Cypher){
                        $Res = DogPost $Query
                        If($Notes){$Res | Select -Expand notes -ea SilentlyContinue}
                        Else{$Res}
                        }}}}}
    End{if($Cypher){ClipThis $Query}}
    }
#End

################################################ NodeSearch
function Search-BloodHoundNode{
<#
.Synopsis
   BloodHound Node - Search Node
.DESCRIPTION
   Search Nodes by partial Name or Properties
.EXAMPLE
   NodeSearch Group admin
.EXAMPLE
   Nodesearch User -Property sensitive -Value $true
#>
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
        # Property/Label doesn't exists
        [Parameter(Mandatory=1,ParameterSetName='LabelNot')]
        [Parameter(Mandatory=1,ParameterSetName='PropNot')][Switch]$NotExist,
        # KeyWord
        [Parameter(Mandatory=1,Position=1,ParameterSetName='Key')][Regex]$Key,
        # Case Sensitive
        [Parameter(Mandatory=0,ParameterSetName='Key')][Switch]$Sensitive,
        # Show Cypher
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    if($Type -ne $null){$T=":$type"}
    if(-Not$Sensitive){$CS='(?i)'}
    # Prep Query
    Switch ($PSCmdlet.ParameterSetName){
        "Key"     {$Query= "MATCH (X$T) WHERE X.name =~ {KEY} RETURN X ORDER BY X.name"        ; $Param= @{KEY="$CS.*$Key.*"}}
        "Label"   {$Query= "MATCH (X$T) WHERE X:$Label RETURN X ORDER BY X.name"               ; $Param= $Null}
        "LabelNot"{$Query= "MATCH (X$T) WHERE NOT X:$Label RETURN X ORDER BY X.name"           ; $Param= $Null}
        "Prop"    {$Query= "MATCH (X$T) WHERE exists(X.$Property) RETURN X ORDER BY X.name"    ; $Param= $Null}
        "PropNot" {$Query= "MATCH (X$T) WHERE NOT exists(X.$Property) RETURN X ORDER BY X.name"; $Param= $Null}
        "PropVal" {
            if(-not($Value -match "true|false" -OR $value -as [int])){$Value = "'$Value'"}
            $Query= "MATCH (X$T) WHERE X.$Property = $Value RETURN X ORDER BY X.name"
            $Param= $Null
            }}
    # Call Dog
    if($Cypher){ClipThis $Query $Param}
    Else{DogPost $Query $Param}
    }
#End

################################################ NodeCreate
function New-BloodHoundNode{
<#
.Synopsis
   BloodHound Node - Create Node
.DESCRIPTION
   Create New Node by type
.EXAMPLE
   New-BloodHoundNode -Type User -name Bob
.EXAMPLE
   NodeCreate User Bob 
#>
    [CmdletBinding(DefaultParameterSetName="Other")]
    [Alias('New-Node','NodeCreate')]
    Param(
        # Node Type [Mandatory]
        [Parameter(Mandatory=1,Position=0)][NodeType]$Type,
        # Node Name [Mandatory]
        [Parameter(Mandatory=1,Position=1,ValueFromPipeline=1)][String[]]$Name,
        # Specify Node Properties [Option]
        [Parameter(Mandatory=0,Position=2,ParameterSetName='Props')][Hashtable]$Property,
        # Clone similar Node Properties [Option]
        [Parameter(Mandatory=1,ParameterSetName='Clone')][Switch]$Clone,
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
            # Refresh cache
            CacheNode $Type
            # If Props
            if($Property.Count){$P=$Property}
            # If Clone
            if($Clone){
                [HashTable]$P=@{}
                (Node $Type | Get-Member | Where MemberType -eq Noteproperty).name -ne 'name' | %{$P.add($_,'tbd')}
                }
            foreach($N in $Name){
                $Splat = @{
                    Type=$type
                    Name=$Name
                    }
                if($P.count){
                    $Splat.add('Property',$P)
                    NodeUpdate @Splat
                    }}}}
    # If Cypher ####
    End{if($Cypher){
            $FullQ="$Query`r`n$(NodeUpdate @Splat -Cypher)"
            ClipThis $FullQ $Param
            }}}
#########End

################################################ NodeUpdate
function Set-BloodHoundNode{
<#
.Synopsis
   BloodHound Node - Update Node
.DESCRIPTION
   Update BloodHound Node Properties
.EXAMPLE
   Set-BloodHoundNode User Bob @{MyProp='This'}
#>
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
                    $Param += @{$_=$($DynProp.Value.$_)}
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
function Remove-BloodHoundNode{
<#
.Synopsis
   BloodHound Node - Delete Node
.DESCRIPTION
   Delete Bloodhound Node from Database
.EXAMPLE
   Remove-BloodhoundNode Remove-BloodHoundNode -Type User -Name Bob
.EXAMPLE
   NodeDelete User Bob -Force
#>
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

###################################################### List
Function Get-BloodHoundNodeList{
<#
.Synopsis
   BloodHound Node - Get List
.DESCRIPTION
   List BloodHound nodes per Edge
.EXAMPLE
   List Membership ALBINA_BRASHEAR@DOMAIN.LOCAL
#>
    [Cmdletbinding()]
    [Alias('NodeList','List')]
    Param(
        [ValidateSet('logon','Session','AdminTo','AdminBy','Member','Membership')]
        [Parameter(Mandatory=1,Position=0)][String]$Type
        )
    DynamicParam{
        # Prep Name List
        Switch($Type){
            Logon      {$NameList = $CypherDog.UserList    }
            Session    {$NameList = $CypherDog.ComputerList}
            AdminTo    {$NameList = $CypherDog.ComputerList}
            AdminBy    {$NameList = $CypherDog.UserList    }
            Member     {$NameList = $CypherDog.GroupList   }
            Membership {$NameList = $CypherDog.UserList    }
            }
        # DynDico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # DynName
        $DynName   = DynP -Name 'Name' -Type 'String' -Mandat 1 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $NameList
        $Dico.Add('Name',$DynName)
        # DynSub
        $Pos=2
        if($PSBoundParameters.Type -match "AdminTo|AdminBy"){
            $DynSub=DynP -Name 'SubType' -Type 'String' -Mandat 0 -Pos $Pos -Pipe 0 -PipeProp 0 -VSet @('Direct','Delegated','Derivative')
            $Dico.Add('SubType',$DynSub)
            $Pos+=1
            }
        # DynDom
        $DynDom = DynP -Name 'Domain' -Type 'String' -Pos $Pos -Mandat 0 -VSet @($Script:CypherDog.DomainList)
        $Dico.Add('Domain',$DynDom)
        $Pos+=1
        # DynCypher
        $DynCypher = DynP -Name 'Cypher' -Type 'Switch' -Mandat 0 -Pos $Pos -Pipe 0 -PipeProp 0 -VSet $Null
        $Dico.Add('Cypher',$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{
        # Edge string
        Switch ($DynSub.Value){
            Direct    {$E=':AdminTo*1'}
            Delegated {$E=':MemberOf*1..]->(g:Group)-[r2:AdminTo'}
            Derivative{$E=':MemberOf|:AdminTo|:HasSession*1..'}
            Default   {$E=':MemberOf|:AdminTo|:HasSession*1..'}
            }
        # Domain
        if($DynDom.Value){$D=" {domain: '$($DynDom.Value)'}"}
        }
    Process{
        $N=$DynName.Value
        Switch($Type){
            Logon      {$M="p=shortestPath((C:Computer$D)-[r:HasSession*1]->(U:User {name: '$N'}))" ;$R="DISTINCT(C) ORDER BY C.name"}
            Session    {$M="p=shortestPath((C:Computer {name: '$N'})-[r:HasSession*1]->(U:User$D))" ;$R="DISTINCT(U) ORDER BY U.name"}
            AdminTo    {$M="p=((U:User$D)-[r$E]->(C:Computer {name: '$N'}))"            ;$R="DISTINCT(U) ORDER BY U.name"}
            AdminBy    {$M="p=((U:User {name: '$N'})-[r$E]->(C:Computer$D))"                        ;$R="DISTINCT(C) ORDER BY C.name"}
            Member     {$M="p=shortestPath(((U:User$D)-[r:MemberOf*1..]->(G:Group {name: '$N'})))"  ;$R="DISTINCT(U) ORDER BY U.name"}
            Membership {$M="p=shortestPath(((U:User {name: '$N'})-[r:MemberOf*1..]->(G:Group$D)))"  ;$R="DISTINCT(G) ORDER BY G.name"}
            }
        if($DynCypher.IsSet){clipThis "MATCH $M RETURN p"}
        else{DogPost "MATCH $M RETURN $R"}
        }
    End{}
    }
#End

################################################# HighValue
Function Get-BloodHoundNodeHighValue{
<#
.Synopsis
   BloodHound Node - Get HighValue
.DESCRIPTION
   Get Bloodhound HighValueNode
.EXAMPLE
   HighValue User
#>
    [Alias('Get-NodeHighValue','HighValue')]
    Param(
        [ValidateSet('User','Computer','Group')]
        [Parameter(Mandatory=0,Position=0)][String]$Type="User"
        )
    DynamicParam{
        # DynDico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynParam
        $DynDom = DynP -Name 'Domain' -Type 'String' -Mandat 0 -Pos 1 -VSet @($Script:CypherDog.DomainList)
        $Dico.Add('Domain',$DynDom)
        # Return Dico
        Return $Dico
        }
    Begin{
        $Type = $type.ToString().Replace($Type[0],$Type[0].ToString().toUpper())
        If($Domain){$Dom=" {domain: '$Domain'}"}
        }
    Process{
        $Query = "MATCH (X:$type$Dom) WHERE X.highvalue=True RETURN X"
        DogPost $Query
        }
    End{}
    }
#End

##################################################### Owned
Function Get-BloodHoundNodeOwned{
<#
.Synopsis
   BloodHound Node - Get Owned
.DESCRIPTION
   Get BloodHound Owned Nodes per type
.EXAMPLE
   Owned Computer
#>
    [Alias('Get-NodeOwned','Owned')]
    Param(
        [ValidateSet('User','Computer','Group')]
        [Parameter(Mandatory=0,Position=0)][String]$Type='Computer'
        )
    DynamicParam{
        # DynDico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynParam
        $DynDom = DynP -Name 'Domain' -Type 'String' -Mandat 0 -Pos 1 -VSet @($Script:CypherDog.DomainList)
        $Dico.Add('Domain',$DynDom)
        # Return Dico
        Return $Dico
        }
    Begin{
        $Type = $type.ToString().Replace($Type[0],$Type[0].ToString().toUpper())
        If($Domain.IsSet){$Dom=" {domain: '$($Domain.Value)'}"}
        }
    Process{
        $Query = "MATCH (X:$type$Dom) WHERE X.owned=True RETURN X"
        DogPost $Query
        }
    End{}
    }
#End

###################################################### Note
function Get-BloodHoundNodeNote{
<#
.Synopsis
   BloodHound Node - Get Note
.DESCRIPTION
   Get BloodHound Node Notes
.EXAMPLE
   note user ALBINA_BRASHEAR@DOMAIN.LOCAL
#>
    [CmdletBinding()]
    [Alias('NodeNote','Note')]
    Param(
        [Parameter(Mandatory=1,Position=0,ValuefromPipeline=0)][NodeType]$Type,
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynNameList = @($Script:CypherDog."${Type}List")
        # Prep DynP
        $DynName = DynP -Name 'Name' -Type 'String[]' -Mandat 1 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $DynNameList
        # DynP to Dico
        $Dico.Add("Name",$DynName)
        # Return Dico
        Return $Dico
        }
    Begin{<#NoOp#>}
    Process{
        Foreach($N in $DynName.Value){
            $Query = "MATCH (n:$Type {name: '$N'}) RETURN n.notes"
            if(-Not$Cypher){DogPost $Query -Expand Data}
            }}
    End{if($Cypher){ClipThis $Query}}
    }
#End

################################################ NoteUpdate
function Set-BloodHoundNodeNote{
<#
.Synopsis
   BloodHound Node - Set Notes
.DESCRIPTION
   Set BloodHound Node Notes
.EXAMPLE
   NoteUpdate user ALBINA_BRASHEAR@DOMAIN.LOCAL 'HelloWorld'
#>
    [CmdletBinding(DefaultParameterSetname='Set')]
    [Alias('Set-NodeNote','NoteUpdate')]
    Param(
        # Node Type [Mandatory]
        [Parameter(Mandatory=1,Position=0)][NodeType]$Type,
        # Overwrite
        [Parameter(ParameterSetname='Set',Mandatory=0)][Switch]$Overwrite,
        # Stamp
        [Parameter(ParameterSetname='Set',Mandatory=0)][Switch]$Stamp,
        # Cypher
        [Parameter(ParameterSetname='Clear',Mandatory=1)][Switch]$Clear,
        # Cypher
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    DynamicParam{
        # Prep Dico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynP
        $DynName = DynP -Name 'Name' -Type 'String[]' -Mandat 1 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $Script:CypherDog."${Type}List"
        $Dico.Add('Name',$DynName)
        # If Set Text
        if($PSCmdlet.ParameterSetName -eq 'Set'){
            $DynText = DynP -Name 'Text' -Type 'String' -Mandat 1 -Pos 2 -Pipe 0 -PipeProp 0
            $Dico.Add('Text',$DynText)
            }
        # Return Dico
        Return $Dico
        }
    Begin{
        # Query0
        $Query0 = "MATCH (X:$Type) WHERE X.name = {NAME} Return X.notes"
        }
    Process{
        Foreach($N in $DynName.Value){
            # If Clear
            if($PSCmdlet.ParameterSetName -eq 'Clear'){
            $Query = "MATCH (X:$Type) WHERE X.name = '$N' SET X.notes=''"
            }
            # If Set
            else{
                $Param = @{NAME="$N"}
                # If Stamp
                if($Stamp){$New = "=== $(Get-date) - $enV:USERNAME ===`r`n$($DynText.Value)"}
                else{$New=$DynText.Value}
                # Get Old Text
                if(-Not$Overwrite){
                    $Old = DogPost $Query0 $Param -Expand data
                    if($Old){$New = ("$Old",$New)-join"`r`n"}
                    }
                # Prep Query1
                $Query = "MATCH (X:$Type) WHERE X.name = {NAME} SET X.notes='$New'"
                }
            if($Cypher){ClipThis $Query $Param}
            # Else
            Else{DogPost $Query $Param}
            }}
    End{<#NoOp#>}
    }
#End

################################################# Blacklist
function Get-BloodHoundBlacklist{
<#
.Synopsis
   BloodHound Node - Get Blacklist
.DESCRIPTION
   Get BloodHound Node Blacklist
.EXAMPLE
   Blacklist User  
#>
    [Alias('Get-Blacklist','Blacklist')]
    Param(
        [Parameter(Mandatory=1,Position=0)][Nodetype]$Type
        )
    DogPost "MATCH (x:$type) WHERE x:Blacklist RETURN x ORDER BY x.name"
    }
#End

########################################### BlacklistUpdate
function Set-BloodHoundBlacklist{
<#
.Synopsis
   BloodHound Node - Set Blacklist
.DESCRIPTION
   Set BloodHound Blacklist Node
.EXAMPLE
   BlacklistUpdate User Bob  
#>
    [Alias('Set-Blacklist','BlacklistAdd')]
    Param(
        [Parameter(Mandatory=1,Position=0)][Nodetype]$Type
        )
    DynamicParam{
        # DynDico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynParam
        $DynName   = DynP -Name 'Name'   -Type 'String[]' -Mandat 0 -Pos 1 -Pipe 1 -PipeProp 1 -VSet @($Script:CypherDog."${type}List")
        $DynCypher = DynP -Name 'Cypher' -Type 'Switch'   -Mandat 0 -Pos 2 -Pipe 0 -PipeProp 0 -VSet $Null
        $Dico.Add('Name',$DynName)
        $Dico.Add('Cypher',$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{}
    Process{foreach($N in $DynName.Value){
                $Q="MATCH (x:$Type) WHERE x.name='$N' SET x:Blacklist"
                if(-Not$DynCypher.IsSet){DogPost $Q}
                }}
    End{if($DynCypher.IsSet){ClipThis $Q}}
    }
#End

########################################### BlacklistDelete
function Remove-BloodHoundBlacklist{
<#
.Synopsis
   BloodHound Node - Remove Blacklist
.DESCRIPTION
   Remove Node from blacklist
.EXAMPLE
   BlacklistDelete User Bob
#>
    [Alias('Remove-Blacklist','BlacklistDelete')]
    Param(
        [Parameter(Mandatory=1,Position=0)][Nodetype]$Type
        )
    DynamicParam{
        # DynDico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynParam
        [Array]$VSet=(Get-BloodHoundBlacklist $type).name
        $VSet += "*" 
        $DynName   = DynP -Name 'Name'   -Type 'String[]' -Mandat 0 -Pos 1 -Pipe 1 -PipeProp 1 -VSet @($Vset)
        $DynCypher = DynP -Name 'Cypher' -Type 'Switch'   -Mandat 0 -Pos 2 -Pipe 0 -PipeProp 0 -VSet $Null
        $Dico.Add('Name',$DynName)
        $Dico.Add('Cypher',$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{}
    Process{
        foreach($N in ($DynName.Value)){
            if($DynName.Value -eq "*"){$Q="MATCH (x:$Type) WHERE x:Blacklist REMOVE x:Blacklist"}
            else{$Q="MATCH (x:$Type) WHERE x.name='$N' REMOVE x:Blacklist"}
            if(-Not$DynCypher.IsSet){DogPost $Q}
            }}
    End{if($DynCypher.IsSet){ClipThis $Q}}
    }
#End

#endregion ################################################


###########################################################
#region ############################################## EDGE

# Get-BloodHoundEdge
# Get-BloodHoundEdgeReverse
# Get-BloodHoundEdgecrossDomain
# Get-BloodHoundEdgeCount
# Get-BloodHoundEdgeInfo
# New-BloodHoundEdge
# Remove-BloodHoundEdge


###################################################### Edge
function Get-BloodHoundEdge{
<#
.Synopsis
   BloodHound Edge - Get Target
.DESCRIPTION
   Specify Source Name / Return Target
.EXAMPLE
   Edge user ALBINA_BRASHEAR@DOMAIN.LOCAL MemberOf Group
#>
    [CmdletBinding()]
    [Alias('Get-Edge','Edge','WhereTo')]
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
        $max   
        # If Max and not MemberOf
        If($DynMax.Value -AND $EdgeType -ne 'MemberOf'){
            # Query
            if($Max -ne $null){
                #$Query = "MATCH (A:$TargetType), (B:$SourceType {name: {NAME}}), p=shortestPath((B)-[r:MemberOf*1$max]->(X:Group)-[r2:$EdgeType*1]->(A)) RETURN DISTINCT(A) ORDER BY A.name"
                $Query = "MATCH (A:$TargetType), (B:$SourceType {name: {NAME}}), p=shortestPath((B)-[r:MemberOf|:$EdgeType*1$Max]->(A)) RETURN DISTINCT(A) ORDER BY A.name"
                }
            else{$Query = "MATCH (A:$TargetType), (B:$SourceType {name: {NAME}}), p=shortestPath((B)-[r:$EdgeType*1$Max]->(A)) RETURN DISTINCT(A) ORDER BY A.name"}
            }
        Else{# Query
            $Query = "MATCH (A:$TargetType), (B:$SourceType {name: {NAME}}), p=(B)-[r:$EdgeType*1$Max]->(A) RETURN DISTINCT(A) ORDER BY A.name"
            }}
    Process{
        Foreach($SourceName in $DynName.Value){
            $Param = @{NAME="$SourceName"}
            if(-Not$DynCypher.IsSet){DogPost $Query $Param}
            }}
    End{if($DynCypher.IsSet){ClipThis ($Query-replace"RETURN.+$",'RETURN p') $Param}}
    }
#End

##################################################### EdgeR
function Get-BloodHoundEdgeReverse{
<#
.Synopsis
   BloodHound Edge - Get Source
.DESCRIPTION
   Specify Target Name / Return Source
.EXAMPLE
   EdgeR User MemberOf Group ADMINISTRATORS@SUB.DOMAIN.LOCAL
#>
    [CmdletBinding()]
    [Alias('Get-EdgeR','EdgeR','What')]
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
    End{if($DynCypher.IsSet){ClipThis ($Query-replace"RETURN.+$",'RETURN p') $Param}}
    }
#End

############################################### CrossDomain
function Get-BloodHoundEdgeCrossDomain{
<#
.Synopsis
   BloodHound Edge - Get CrossDomain
.DESCRIPTION
   Get BloodHound Cross Domain Member|Session Relationships
.EXAMPLE
   Get-BloodHoundCrossDomain Session
.EXAMPLE
   CrossDomain Member
#>
    [CmdletBinding()]
    [Alias('CrossDomain')]
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

################################################# EdgeCount
function Get-BloodHoundEdgeCount{
<#
.Synopsis
   BloodHound Edge - Get Count
.DESCRIPTION
   Get Top Nodes By Edge Count
.EXAMPLE
   EdgeCount Membership
#>
    [CmdletBinding()]
    [Alias('EdgeCount','TopNode')]
    Param(
        [ValidateSet('AdminTo','AdminBy','Session','Logon','Member','Membership')]
        [Parameter(Mandatory=1,Position=0)][String]$type,
        [Parameter(Mandatory=0)][Int]$Limit=5,
        [Parameter(Mandatory=0)][Switch]$Cypher 
        )
    DynamicParam{
        # DynDico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        $Pos=1
        # Prep DynParam
        if($type -match "AdminTo|AdminBy"){
            $DynSub=DynP -Name 'SubType' -Type 'String' -Mandat 0 -Pos $Pos -VSet @('Direct','Delegated','Derivative')
            $Dico.add('SubType',$DynSub)
            $Pos=2
            }
        $DynDom = DynP -Name 'Domain' -Type 'String' -Pos $Pos -Mandat 0 -VSet @($Script:CypherDog.DomainList)
        $Dico.Add('Domain',$DynDom)
        # Return Dico
        Return $Dico
        }
    Process{
        Switch ($DynSub.Value){
            Direct    {$E=':AdminTo*1'}
            Delegated {$E=':MemberOf*1..]->(g:Group)-[r2:AdminTo'}
            Derivative{$E=':MemberOf|:AdminTo|:HasSession*1..'}
            Default   {$E=':MemberOf|:AdminTo|:HasSession*1..'}
            }        
        if($DynDom.Value){$Dom=" {domain: '$($DynDom.Value)'}"}
        if($Limit -eq '0'){$Lim = $Null}Else{$Lim = "LIMIT $Limit"}
        # AdminBy
        if($type -eq 'AdminTo'){
            $Q1 = "MATCH p=((U:User)-[r$E]->(C:Computer$Dom))"
            $Q2 = "$Q1
WITH
C.name as c,
COUNT(DISTINCT(U)) as t
RETURN {Name: c, Count: t} as SingleColumn
ORDER BY t DESC
$Lim"
            }
        # AdminTo
        if($type -eq 'AdminBy'){
            $Q1 = "MATCH p=((S:User$Dom)-[r$E]->(T:Computer))"
            $Q2 = "$Q1
WITH
S.name as s,
COUNT(DISTINCT(T)) as t
RETURN {Name: s, Count: t} as SingleColumn
ORDER BY t DESC
$Lim"
            }
        # Session
        if($Type -eq 'Logon'){
        $Q1 = "MATCH p=shortestPath((U:User$Dom)<-[r:HasSession*1..]-(C:Computer))"
        $Q2 = "$Q1
WITH
U.name as n,
COUNT(DISTINCT(C)) as c 
RETURN {Name: n, Count: c} as SingleColumn
ORDER BY c DESC
$Lim"
            }
        # Logon
        if($Type -eq 'Session'){
            $Q1 = "MATCH p=shortestPath((A:User)<-[r:HasSession*1]-(B:Computer$Dom))" 
            $Q2 = "$Q1
WITH B.name as n,
COUNT(DISTINCT(A)) as c   
RETURN {Name: n, Count: c} as SingleColumn
ORDER BY c DESC
$Lim"
            }
        # Group
        if($Type -eq 'Membership'){
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
        # Output
        If($cypher){$Q = "$Q1 RETURN p";Set-clipBoard $Q;Return $Q}
        Else{
            DogPost $Q2 -Expand Data| Select -Expand SyncRoot
            }}}
#########End

################################################## EdgeInfo
function Get-BloodHoundEdgeInfo{
<#
.Synopsis
   BloodHound Edge - Get Info
.DESCRIPTION
   Get BloodHound Edge Info [online]
.EXAMPLE
   EdgeInfo MemberOf
.EXAMPLE
   EdgeInfo MemberOf -Online 
#>
    [Alias('Get-EdgeInfo','EdgeInfo')]
    Param(
        [Parameter(Mandatory=1)][Edgetype]$Type,
        [Parameter(Mandatory=0)][Switch]$Online
        )
    Switch($Type){
#################################################################################        
MemberOf{
#
$Info='Groups in active directory grant their members any privileges the group itself has.
If a group has rights to another principal, users/computers in the group as well as other groups inside the group inherit those permissions.'
#
$Abuse='No abuse is necessary. 
This edge simply indicates that a principal belongs to a security group.'
#
$Opsec='No opsec considerations apply to this edge.'
#
$Ref=@(
'https://adsecurity.org/?tag=ad-delegation'
'https://www.itprotoday.com/management-mobility/view-or-remove-active-directory-delegated-permissions'
)
}
#################################################################################       
AdminTo{
#
$Info='By default, administrators have several ways to perform remote code execution on Windows systems,
including via RDP, WMI, WinRM, the Service Control Manager, and remote DCOM execution.
Further, administrators have several options for impersonating other users logged onto the system,
including plaintext password extraction, token impersonation, and injecting into processes running as another user.
Finally, administrators can often disable host-based security controls that would otherwise prevent the aforementioned techniques'
#
$Abuse="There are several ways to pivot to a Windows system. 
If using Cobalt Strike's beacon, check the help info for the commands 'psexec', 'psexec_psh', 'wmi', and 'winrm'.
With Empire, consider the modules for Invoke-PsExec, Invoke-DCOM, and Invoke-SMBExec. 
With Metasploit, consider the modules 'exploit/windows/smb/psexec', 'exploit/windows/winrm/winrm_script_exec', and 'exploit/windows/local/ps_wmi_exec'.
Additionally, there are several manual methods for remotely executing code on the machine, including via RDP, 
with the service control binary and interaction with the remote machine's service control manager, and remotely instantiating DCOM objects.
For more information about these lateral movement techniques, see the References tab."
#
$Opsec='There are several forensic artifacts generated by the techniques described above. 
For instance, lateral movement via PsExec will generate 4697 events on the target system.
If the target organization is collecting and analyzing those events, they may very easily detect lateral movement via PsExec. 
Additionally, an EDR product may detect your attempt to inject into lsass and alert a SOC analyst.
There are many more opsec considerations to keep in mind when abusing administrator privileges.
For more information, see the References tab.'
#
$Ref=@(
'https://attack.mitre.org/wiki/Lateral_Movement'
'http://blog.gentilkiwi.com/mimikatz'
'https://github.com/gentilkiwi/mimikatz'
'https://adsecurity.org/?page_id=1821'
'https://attack.mitre.org/wiki/Credential_Access'
'https://labs.mwrinfosecurity.com/assets/BlogFiles/mwri-security-implications-of-windows-access-tokens-2008-04-14.pdf'
'https://github.com/PowerShellMafia/PowerSploit/blob/master/Exfiltration/Invoke-TokenManipulation.ps1'
'https://attack.mitre.org/wiki/Technique/T1134'
'https://blog.netspi.com/10-evil-user-tricks-for-bypassing-anti-virus/'
'https://www.blackhillsinfosec.com/bypass-anti-virus-run-mimikatz/'
'https://blog.cobaltstrike.com/2017/06/23/opsec-considerations-for-beacon-commands/'
)
}
#################################################################################       
HasSession{
#
$Info="When users authenticate to a computer, they often leave credentials exposed on the system, which can be retrieved through LSASS injection, token manipulation/theft, or injecting into a user's process.
Any user that is an administrator to the system has the capability to retrieve the credential material from memory if it still exists.
Note: A session does not guarantee credential material is present, only possible."
#
$Abuse="# Password Theft
When a user has a session on the computer, you may be able to obtain credentials for the user via credential dumping or token impersonation. You must be able to move laterally to the computer, have administrative access on the computer, and the user must have a non-network logon session on the computer.
Once you have established a Cobalt Strike Beacon, Empire agent, or other implant on the target, you can use mimikatz to dump credentials of the user that has a session on the computer. While running in a high integrity process with SeDebugPrivilege, execute one or more of mimikatz's credential gathering techniques (e.g.: sekurlsa::wdigest, sekurlsa::logonpasswords, etc.), then parse or investigate the output to find clear-text credentials for other users logged onto the system.
You may also gather credentials when a user types them or copies them to their clipboard! Several keylogging capabilities exist, several agents and toolsets have them built-in. For instance, you may use meterpreter's 'keyscan_start' command to start keylogging a user, then 'keyscan_dump' to return the captured keystrokes. Or, you may use PowerSploit's Invoke-ClipboardMonitor to periodically gather the contents of the user's clipboard.

# Token Impersonation
You may run into a situation where a user is logged onto the system, but you can't gather that user's credential. This may be caused by a host-based security product, lsass protection, etc. In those circumstances, you may abuse Windows' token model in several ways. First, you may inject your agent into that user's process, which will give you a process token as that user, which you can then use to authenticate to other systems on the network. Or, you may steal a process token from a remote process and start a thread in your agent's process with that user's token. For more information about token abuses, see the References tab.
User sessions can be short lived and only represent the sessions that were present at the time of collection. A user may have ended their session by the time you move to the computer to target them. However, users tend to use the same machines, such as the workstations or servers they are assigned to use for their job duties, so it can be valuable to check multiple times if a user session has started."
#
$Opsec="An EDR product may detect your attempt to inject into lsass and alert a SOC analyst. There are many more opsec considerations to keep in mind when stealing credentials or tokens. For more information, see the References tab."
#
$Ref=@("http://blog.gentilkiwi.com/mimikatz"
"https://github.com/gentilkiwi/mimikatz"
"https://adsecurity.org/?page_id=1821"
"https://attack.mitre.org/wiki/Credential_Access"
"https://labs.mwrinfosecurity.com/assets/BlogFiles/mwri-security-implications-of-windows-access-tokens-2008-04-14.pdf"
"https://github.com/PowerShellMafia/PowerSploit/blob/master/Exfiltration/Invoke-TokenManipulation.ps1"
"https://attack.mitre.org/wiki/Technique/T1134")
}

#################################################################################
TrustedBy{Return}

#################################################################################     
ForceChangePassword{
#
$Info="The capability to change the user password without knowing that user's current password."
#
$Abuse="There are at least two ways to execute this attack. The first and most obvious is by using the built-in net.exe binary in Windows (e.g.: net user dfm.a Password123! /domain). 
See the opsec considerations tab for why this may be a bad idea. 
The second, and highly recommended method, is by using the Set-DomainUserPassword function in PowerView. 
This function is superior to using the net.exe binary in several ways. 
For instance, you can supply alternate credentials, instead of needing to run a process as or logon as the user with the ForceChangePassword privilege. 
Additionally, you have much safer execution options than you do with spawning net.exe (see the opsec tab).
To abuse this privilege with PowerView's Set-DomainUserPassword, first import PowerView into your agent session or into a PowerShell instance at the console. You may need to authenticate to the Domain Controller as a member of DC_3.DOMAIN.LOCAL if you are not running a process as a member. To do this in conjunction with Set-DomainUserPassword, first create a PSCredential object (these examples comes from the PowerView help documentation):

`$SecPassword = ConvertTo-SecureString 'Password123!' -AsPlainText -Force
`$Cred = New-Object System.Management.Automation.PSCredential('TESTLABdfm.a', `$SecPassword)

Then create a secure string object for the password you want to set on the target user:

`$UserPassword = ConvertTo-SecureString 'Password123!' -AsPlainText -Force

Finally, use Set-DomainUserPassword, optionally specifying `$Cred if you are not already running a process as DC_3.DOMAIN.LOCAL:

Set-DomainUserPassword -Identity andy -AccountPassword `$UserPassword -Credential `$Cred

Now that you know the target user's plain text password, you can either start a new agent as that user, or use that user's credentials in conjunction with PowerView's ACL abuse functions, or perhaps even RDP to a system the target user has access to. For more ideas and information, see the references tab"
#
$Opsec="Executing this abuse with the net binary will necessarily require command line execution. If your target organization has command line logging enabled, this is a detection opportunity for their analysts. 

Regardless of what execution procedure you use, this action will generate a 4724 event on the domain controller that handled the request. This event may be centrally collected and analyzed by security analysts, especially for users that are obviously very high privilege groups (i.e.: Domain Admin users). Also be mindful that PowerShell v5 introduced several key security features such as script block logging and AMSI that provide security analysts another detection opportunity. You may be able to completely evade those features by downgrading to PowerShell v2. 

Finally, by changing a service account password, you may cause that service to stop functioning properly. This can be bad not only from an opsec perspective, but also a client management perspective. Be careful!"
#
$Ref=@("https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1"
"https://www.youtube.com/watch?v=z8thoG7gPd0"
"https://www.sixdub.net/?p=579"
"https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4724")
}
        
#################################################################################
AddMember{
#
$Info=''
#
$Abuse=''
#
$Opsec=''
#
$Ref=@()
}

#################################################################################       
GenericAll{
$Info=''
$Abuse=''
$Opsec=''
$Ref=@()
}

#################################################################################       
GenericWrite{
$Info=''
$Abuse=''
$Opsec=''
$Ref=@()
}

#################################################################################
WriteOwner{
#
$Info=''
#
$Abuse=''
#
$Opsec=''
#
$Ref=@()
}

#################################################################################       
WriteDacl{
#
$Info=''
#
$Abuse=''
#
$Opsec=''
#
$Ref=@()
}
       

#################################################################################
AllExtendedRights{
#
$Info=''
$Abuse=''
$Opsec=''
$Ref=@()
}

#################################################################################       
GpLink{
$Info=''
$Abuse=''
$Opsec=''
$Ref=@()
}

#################################################################################
Owns{
$Info=''
$Abuse=''
$Opsec=''
$Ref=@()
}
        
#################################################################################
Contains{
$Info=''
$Abuse=''
$Opsec=''
$Ref=@()
}

#################################################################################
ReadLAPSPassword{
$Info=''
$Abuse=''
$Opsec=''
$Ref=@()
}

#################################################################################
CanRDP{
$Info=''
$Abuse=''
$Opsec=''
$Ref=@()
}

#################################################################################
ExecuteDCOM{
$Info=''
$Abuse=''
$Opsec=''
$Ref=@()
}

#################################################################################
AllowedToDelegate{
$Info =''
$Abuse=''
$Opsec=''
$Ref=@()
}
#########
        }
    if($Online){$ref|%{Start-Process $_}}
    else{Return [PSCustomObject]@{
        Edge  = $type
        Info  = $Info
        Abuse = $Abuse
        Opsec = $Opsec
        Ref   = $Ref
        }}    
    }
#End

################################################ EdgeCreate
function New-BloodHoundEdge{
<#
.Synopsis
   BloodHound Edge - Create Edge
.DESCRIPTION
   Create Edges Between nodes
.EXAMPLE
   EdgeCreate User MemberOf Group ALBINA_BRASHEAR@DOMAIN.LOCAL ADMINISTRATORS@DOMAIN.LOCAL
#>
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
function Remove-BloodHoundEdge{
<#
.Synopsis
   BloodHound Edge - Delete Edge
.DESCRIPTION
   Remove Edge between nodes
.EXAMPLE
   EdgeDelete User MemberOf Group ALBINA_BRASHEAR@DOMAIN.LOCAL ADMINISTRATORS@DOMAIN.LOCAL
#>
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

#endregion ################################################


###########################################################
#region ############################################## PATH

# Get-BloodHoundPathShort
# Get-BloodHoundPathAny
# Get-BloodHoundPathCost
# Get-BloodHoundPathCheap
# Get-BloodHoundWald0IO

################################################# PathShort
function Get-BloodHoundPathShort{
<#
.Synopsis
   BloodHound Path - Get Shortest
.DESCRIPTION
   Get BloodHound Shortest/AllShortest Path
.EXAMPLE
   Path user Group ALBINA_BRASHEAR@DOMAIN.LOCAL 'SCHEMA ADMINS@DOMAIN.LOCAL'
#>
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
        $DynSource  = DynP -Name 'Name'   -Type 'String[]'  -Mandat 1 -Pos 2  -Pipe 1 -PipeProp 1 -VSet ($DynSourceList+'*')
        $DynTarget  = DynP -Name 'To'     -Type 'string[]'  -Mandat 1 -Pos 3  -Pipe 0 -PipeProp 0 -VSet ($DynTargetList+'*')
        $DynEdge    = DynP -Name 'Edge'   -Type 'string[]'  -Mandat 0 -Pos 4  -Pipe 0 -PipeProp 0 -VSet @('NoDef','NoACL','NoGPO','NoSpc')
        $DynExclude = DynP -Name 'Exclude'-Type 'EdgeType[]'-Mandat 0 -Pos 5  -Pipe 0 -PipeProp 0 -VSet $Null
        $DynInclude = DynP -Name 'Include'-Type 'EdgeType[]'-Mandat 0 -Pos 6  -Pipe 0 -PipeProp 0 -VSet $Null
        $DynBlackL  = DynP -Name 'BlackL' -Type 'Switch'    -Mandat 0 -Pos 7  -Pipe 0 -PipeProp 0 -VSet $Null
        $DynMax     = DynP -Name 'MaxHop' -Type 'Int'       -Mandat 0 -Pos 8  -Pipe 0 -PipeProp 0 -VSet $Null
        $DynAll     = DynP -Name 'All'    -Type 'Switch'    -Mandat 0 -Pos 9  -Pipe 0 -PipeProp 0 -VSet $Null
        $DynCypher  = DynP -Name 'Cypher' -Type 'Switch'    -Mandat 0 -Pos 10 -Pipe 0 -PipeProp 0 -VSet $Null
        # DynP to Dico
        $Dico.Add("Name"   ,$DynSource)
        $Dico.Add("To"     ,$DynTarget)
        $Dico.Add("Edge"   ,$DynEdge)
        $Dico.Add("Exclude",$DynExclude)
        $Dico.Add("Include",$DynInclude)
        $Dico.Add("MaxHop" ,$DynMax)
        $Dico.Add("BlackL" ,$DynBlackL)
        $Dico.Add("All"    ,$DynAll)
        $Dico.Add("Cypher" ,$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{
        # Path Type
        if($DynAll.IsSet){$PType = 'allShortestPaths'}
        else{$PType = 'shortestPath'}       
        # EdgeString
        if(-Not$DynEdge.Value){$E = ':'+(GenEdgeStr -Exclude $DynExclude.Value -Include $DynInclude.Value)}
        else{$E = ':'+(GenEdgeStr $DynEdge.Value -Exclude $DynExclude.Value -Include $DynInclude.Value)}
        if($E -eq ':'){$E=$null}
        # Max Hop
        $M=$DynMax.Value
        # Blacklist
        If($DynBlackL.IsSet){$BL = " WHERE NONE(x in NODES(p) WHERE x:Blacklist)"}Else{$BL=$Null}
        }
    Process{foreach($SRC in $DynSource.Value){foreach($TGT in $DynTarget.Value){
                #  Any Source -  Any Target
                if($SRC -eq '*' -AND $TGT -eq '*'){
                    Write-Warning "Heavy Q - No Names Specified"
                    $Query = "MATCH (A:$SourceType), (B:$TargetType), p=$PType((A)-[r$E*1..$M]->(B))$BL RETURN DISTINCT(p)"
                    if(-Not$DynCypher.IsSet){DogPost $Query -Expand Data | ToPathObj}
                    }
                #  Any Source - Spec Target
                if($SRC -eq '*' -AND $TGT -ne '*'){
                    $Query = "MATCH (A:$SourceType), (B:$TargetType {name: {TGT}}), p=$PType((A)-[r$E*1..$M]->(B))$BL RETURN DISTINCT(p)"
                    $Param=@{TGT="$TGT"}
                    if(-Not$DynCypher.IsSet){DogPost $Query $Param -Expand Data | ToPathObj}
                    }
                # Spec Source -  Any Target 
                if($SRC -ne '*' -AND $TGT -eq '*'){
                    $Query = "MATCH (A:$SourceType {name: {SRC}}), (B:$TargetType), p=$PType((A)-[r$E*1..$M]->(B))$BL RETURN p"
                    $Param=@{SRC="$SRC"}
                    if(-Not$DynCypher.IsSet){DogPost $Query $Param -Expand Data | ToPathObj}
                    }
                # Spec Source - Spec Source
                if($SRC -ne '*' -AND $TGT -ne '*'){
                    $Query = "MATCH (A:$SourceType {name: {SRC}}), (B:$TargetType  {name: {TGT}}), p=$PType((A)-[r$E*1..$M]->(B))$BL RETURN DISTINCT(p)"
                    $Param=@{
                        SRC="$SRC"
                        TGT="$TGT"
                        }
                    if(-Not$DynCypher.IsSet){DogPost $Query $Param -Expand Data | ToPathObj}
                    }}}}
    End{if($DynCypher.IsSet){clipThis $Query $Param}}
    }
#End

################################################### PathAny
function Get-BloodHoundPathAny{
<#
.Synopsis
   BloodHound Path - Get Any
.DESCRIPTION
   Get 'Any' Path
.EXAMPLE
   PathAny user Group ALBINA_BRASHEAR@DOMAIN.LOCAL 'SCHEMA ADMINS@DOMAIN.LOCAL'
#>
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
        $DynEdge   = DynP -Name 'Edge'   -Type 'string[]'  -Mandat 0 -Pos 4 -Pipe 0 -PipeProp 0 -VSet @('NoDef','NoACL','NoGPO','NoSpc')
        $DynExclude= DynP -Name 'Exclude'-Type 'EdgeType[]'-Mandat 0 -Pos 5 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynInclude= DynP -Name 'Include'-Type 'EdgeType[]'-Mandat 0 -Pos 6 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynMax    = DynP -Name 'MaxHop' -Type 'Int'       -Mandat 0 -Pos 7 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynBlackL = DynP -Name 'BlackL' -Type 'Switch'    -Mandat 0 -Pos 8 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynCypher = DynP -Name 'Cypher' -Type 'Switch'    -Mandat 0 -Pos 9 -Pipe 0 -PipeProp 0 -VSet $Null
        # DynP to Dico
        $Dico.Add("Name"   ,$DynSource)
        $Dico.Add("To"     ,$DynTarget)
        $Dico.Add("Edge"   ,$DynEdge)
        $Dico.Add("Exclude",$DynExclude)
        $Dico.Add("Include",$DynInclude)
        $Dico.Add("MaxHop" ,$DynMax)
        $Dico.Add("BlackL" ,$DynBlackL)
        $Dico.Add("Cypher" ,$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{
        # EdgeString
        if(-Not$DynEdge.Value){$E = ':'+ (GenEdgeStr -Exclude $DynExclude.Value -Include $DynInclude.Value)}
        else{$E = ':'+ (GenEdgeStr $DynEdge.Value -Exclude $DynExclude.Value -Include $DynInclude.Value)}
        # Max Hop
        $M=$DynMax.Value
        # Blacklist
        If($DynBlackL.IsSet){$BL = " WHERE NONE(x in NODES(p) WHERE x:Blacklist)"}
        }
    Process{foreach($SRC in $DynSource.Value){foreach($TGT in $DynTarget.Value){
                #  Any Source -  Any Target
                if($SRC -eq '*' -AND $TGT -eq '*'){
                    if(!$M){Write-Warning "Heavy Query - Setting MaxHop to 3";$M=3}
                    $Query = "MATCH (A:$SourceType) MATCH (B:$TargetType) MATCH p=((A)-[R$E*1..$M]->(B))$BL RETURN DISTINCT(p)"
                    if(-Not$DynCypher.IsSet){DogPost $Query -Expand Data | ToPathObj}
                    }
                #  Any Source - Spec Target
                if($SRC -eq '*' -AND $TGT -ne '*'){
                    if(!$M){Write-Warning "Heavy Query - Setting MaxHop to 7"; $M=7}
                    $Query = "MATCH (A:$SourceType) MATCH (B:$TargetType {name: {TGT}}) MATCH p=((A)-[R$E*1..$M]->(B))$BL RETURN DISTINCT(p)"
                    $Param=@{TGT="$TGT"}
                    if(-Not$DynCypher.IsSet){DogPost $Query $Param -Expand Data | ToPathObj}
                    }
                # Spec Source -  Any Target 
                if($SRC -ne '*' -AND $TGT -eq '*'){
                    if(!$M){Write-Warning "Heavy Query - Setting MaxHop to 7";$M=7}
                    $Query = "MATCH (A:$SourceType {name: {SRC}}) MATCH (B:$TargetType) MATCH p=((A)-[R$E*1..$M]->(B))$BL RETURN DISTINCT(p)"
                    $Param=@{SRC="$SRC"}
                    if(-Not$DynCypher.IsSet){DogPost $Query $Param -Expand Data | ToPathObj}
                    }
                # Spec Source - Spec Source
                if($SRC -ne '*' -AND $TGT -ne '*'){
                    if(!$M){Write-Warning "Heavy Query - Setting MaxHop to 9";$M=9}
                    $Query = "MATCH (A:$SourceType {name: {SRC}}), (B:$TargetType  {name: {TGT}}), p=((A)-[r$E*1..$M]->(B))$BL RETURN DISTINCT(p)"
                    $Param=@{
                        SRC="$SRC"
                        TGT="$TGT"
                        }
                    if(-Not$DynCypher.IsSet){DogPost $Query $Param -Expand Data | ToPathObj}
                    }}}}
    End{if($DynCypher.IsSet){clipThis $Query $Param}}
    }
#End

################################################## PathCost
function Get-BloodHoundPathCost{
<#
.Synopsis
   BloodHound Path - Get Cost
.DESCRIPTION
   Get BloodHound Path Cost
.EXAMPLE
   path user group GARY_CATANIA@SUB.DOMAIN.LOCAL 'RDS ENDPOINT SERVERS@DOMAIN.LOCAL' -all | pathcost
#>
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
#####End

################################################# PathCheap
function Get-BloodHoundPathCheap{
<#
.Synopsis
   BloodHound Path - Get Cheapest
.DESCRIPTION
   Get BloodHound Cheapest Path
.EXAMPLE
   pathcheap user group GARY_CATANIA@SUB.DOMAIN.LOCAL 'RDS ENDPOINT SERVERS@DOMAIN.LOCAL'
#>
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
        $DynSource = DynP -Name 'Name'   -Type 'String'    -Mandat 1 -Pos 2  -Pipe 1 -PipeProp 1 -VSet ($DynSourceList)
        $DynTarget = DynP -Name 'To'     -Type 'string'    -Mandat 1 -Pos 3  -Pipe 0 -PipeProp 0 -VSet ($DynTargetList)
        $DynEdge   = DynP -Name 'Edge'   -Type 'string[]'  -Mandat 0 -Pos 5  -Pipe 0 -PipeProp 0 -VSet @('NoDef','NoACL','NoGPO','NoSpc')
        $DynExclude= DynP -Name 'Exclude'-Type 'EdgeType[]'-Mandat 0 -Pos 6  -Pipe 0 -PipeProp 0 -VSet $Null
        $DynInclude= DynP -Name 'Include'-Type 'EdgeType[]'-Mandat 0 -Pos 7  -Pipe 0 -PipeProp 0 -VSet $Null
        $DynBlackL = DynP -Name 'BlackL' -Type 'Switch'    -Mandat 0 -Pos 8  -Pipe 0 -PipeProp 0 -VSet $Null
        $DynExpand = DynP -Name 'Expand' -Type 'Int'       -Mandat 0 -Pos 9  -Pipe 0 -PipeProp 0 -VSet @(1..9)
        $DynCypher = DynP -Name 'Cypher' -Type 'Switch'    -Mandat 0 -Pos 10 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynLimit  = DynP -Name 'Limit'  -Type 'Int'       -Mandat 0 -Pos 11 -Pipe 0 -PipeProp 0 -VSet $Null
        # DynP to Dico
        $Dico.Add("Name"   ,$DynSource)
        $Dico.Add("To"     ,$DynTarget)
        $Dico.Add("Edge"   ,$DynEdge)
        $Dico.Add("Exclude",$DynExclude)
        $Dico.Add("Include",$DynInclude)
        $Dico.Add('Expand', $DynExpand)
        $Dico.Add("BlackL" ,$DynBlackL)
        $Dico.Add("Cypher" ,$DynCypher)
        $Dico.Add("Limit"  ,$DynLimit)
        # Return Dico
        Return $Dico
        }
    Begin{     
        # EdgeString
        if(-Not$DynEdge.Value){$E = ':'+ (GenEdgeStr -Exclude $DynExclude.Value -Include $DynInclude.Value)}
        else{$E = ':'+ (GenEdgeStr $DynEdge.Value -Exclude $DynExclude.Value -Include $DynInclude.Value)}
        # Blacklist
        if($DynBlackL.IsSet){$BL = " WHERE NONE(x in NODES(p) WHERE x:Blacklist)"}Else{$BL=$Null}
        if($DynLimit.Value){$L=$DynLimit.Value}else{$L=1}
        }
    Process{
        # Get length Cheapest
        $Q = "MATCH (S:$SourceType {name: '$($DynSource.Value)'}), (T:$TargetType {name: '$($DynTarget.Value)'}), p=shortestPath((S)-[r$E*1..]->(T))$BL RETURN LENGTH(p)" 
        try{$Max = (DogPost $Q -Expand data)[0]}catch{}
        # if expand 
        if($Max){$Max += $DynExpand.value
            # Query Cheapest all path max length
            $Q = "MATCH (S:$SourceType {name: '$($DynSource.Value)'}), 
(T:$TargetType {name: '$($DynTarget.Value)'}), 
p=((S)-[r$E*1..$Max]->(T))$BL 
WITH p,
LENGTH(FILTER(x IN EXTRACT(r in RELATIONSHIPS(p)|TYPE(r)) WHERE x <>'MemberOf')) as Cost
RETURN p
ORDER BY Cost 
LIMIT $L"
            if(-Not$DynCypher.IsSet){DogPost $Q -Expand Data | TopathObj} 
            }}
    End{if($DynCypher.IsSet){clipThis $Q $Param}}
    }
#End

################################################### Wald0IO
function Get-BloodHoundWald0IO{
<#
.Synopsis
   BloodHound Path - Get Wald0 Index
.DESCRIPTION
   Calculate wald0 Index for specified Group
.EXAMPLE
   Node Group ADMINISTRATORS@DOMAIN.LOCAL | Wlad0IO
#>
    [CmdletBinding()]
    [Alias('Get-Wald0IO','Wald0IO')]
    Param(
        [Parameter(ValueFromPipeline=1,ValueFromPipelineByPropertyName=1,Mandatory=0,Position=0)][Alias('TargetGroup')][String]$Name,
        [ValidateSet('Inbound','Outbound')]
        [Parameter(Mandatory=0,Position=1)][String]$Direction,
        [ValidateSet('User','Computer')]
        [Parameter(Mandatory=0,Position=2)][String]$Type,
        [ValidateSet('NoDef','NoACL','NoGPO','NoSpc')]
        [Parameter(Mandatory=0,Position=3)][String[]]$Edge,
        [Parameter(Mandatory=0)][EdgeType[]]$Exclude,
        [Parameter(Mandatory=0)][EdgeType[]]$Include,
        [Parameter(Mandatory=0)][Switch]$DomainOnly,
        [Parameter(Mandatory=0)][Switch]$BlackL,
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    Begin{
        # EdgeString
        if($Edge.count -eq 0){$E = ':'+(GenEdgeStr -Exclude $Exclude -Include $Include)}
        else{$E = ':'+(GenEdgeStr $Edge -Exclude $Exclude -Include $Include)}
        if($E -eq ':'){$E=$null}
        # BlackL
        If($BlackL){$BL = " WHERE NONE(x in NODES(p) WHERE x:Blacklist)"}
        }
    Process{
        $Splat = @{} 
        $PSBoundParameters.Keys -notmatch "Name|Direction|Type" | %{$Splat.add($_,$PSBoundParameters.$_)}
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
                $Q1 = "p = shortestPath((x:$Type$Dom)-[r$E*1..]->(g:Group {name:'$TargetGroup'}))$BL"
                $Q2 = "MATCH (tx:$type$Dom), $Q1"
                }
            if($Direction -eq 'Outbound'){
                $Q1 = "p = shortestPath((g:Group {name:'$TargetGroup'})-[r$E*1..]->(x:$type$Dom))$BL"
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
            if($Cypher){ClipThis "MATCH $Q1 RETURN p";Return}
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
    End{}###########
    }
#End

#endregion ################################################


###########################################################
###################################################### INIT
$ASCII
CacheNode

###########################################################
####################################################### EOF
