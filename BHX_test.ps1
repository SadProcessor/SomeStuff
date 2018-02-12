###########################################################
##  CypherDog - PoSh BloodHoundDog Dog Whisperer Module  ##
###########################################################


#region ############################################## Vars

## Banner ASCII
$ASCII= @("

 ____________________________________________
 ______|_____________________________________
 _____||__________________________CYPHERDOG__
 _____||-________...___________________BETA__
 ______||-__--||||||||-._____________________
 _______!||||||||||||||||||--________________
 ________|||||||||||||||||||||-______________
 ________!||||||||||||||||||||||.____________
 _______.||||||||||||||||||||||||-___________
 ______|||!||||!!|||||||||||||||||.__________
 _____|||_.||!___.|||'_!||_'||||||!__________
 ____||___!||____|||____||___|||||.__________
 _____||___||_____||_____||!__!|||'__________
 __________ ||!____||!_______________________
 ____________________________________________

 PoSh BloodHound Cmdlets - @SadProcessor 2018
   
")

## CypherDog Obj
$CypherDog = New-Object PSCustomObject -Property @{
    Host='localhost'
    Port=7474
    UserList=$Null
    GroupList=$Null
    ComputerList=$Null
    DomainList=$List
    }


## EdgeType Enum
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
    }


#endregion ################################################
###########################################################



#region ######################################### Internals

## INTERNALS ##############################################
#
#  DogPost     >  Post Query to REST API
#  CacheNode   >  Cache Node Lists
#  DynP        >  Generate Dynamic Param
#  ToPathObj   >  Unpack Path to Object
#  ClipThis    >  Query To Clipboard
#  Wald0Index  >  Calc Wald0's Pwn Index <----------------------------- /!\ Check Math [use Wald0s SampleDB / compare results]
#
###########################################################


###########################################################
################################################### DogPost

<#
.Synopsis
   Post to API - Internal
.DESCRIPTION
   Post Query (& Params) to API
.EXAMPLE
    DogPost $Query [$Params] [-Raw]

    # Return All Users
    $query="MATCH (n:User) RETURN n"
    DogPost $Query

    # Specific Computer
    $query  = "MATCH (A:Computer {name: {ParamA}}) RETURN A"
    $Params = @{ParamA="APOLLO.EXTERNAL.LOCAL"}
    DogPost $Query $Params

    # Path A to B
    $Query = "MATCH (A:User {name: {ParamA}}), (B:Group {name: {ParamB}}), x=shortestPath((A)-[*1..]->(B)) RETURN x"
    $Params= @{ParamA="ACHAVARIN@EXTERNAL.LOCAL";ParamB="DOMAIN ADMINS@EXTERNAL.LOCAL"}
    DogPost $Query $Params -Raw

#>
function DogPost{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=1)][string]$Query,
        [Parameter(Mandatory=0)][Hashtable]$Params,
        [Parameter()][Switch]$Raw,
        [Parameter()][String]$Server='localhost',
        [Parameter()][int]$Port=7474
        )
    # Uri & header 
    $Uri = "http://$($CypherDog.Host):$($CypherDog.Port)/db/data/cypher"
    $Header=@{'Accept'='application/json; charset=UTF-8';'Content-Type'='application/json'}
    # Body
    if($Params){$Body = @{params=$Params; query=$Query} | Convertto-Json}
    else{$Body = @{query=$Query}|Convertto-Json}
    # Call
    write-verbose $Body.replace(')\u003c-',')<-').replace('-\u003e(','->(')
    $Reply = Try{Invoke-RestMethod -Uri $Uri -Method Post -Headers $Header -Body $Body}Catch{$Oops = $Error[0].Exception}
    # Format
    if($Oops){Write-Warning "$($Oops.message)" ;Return}
    if($Raw){Return $Reply}
    else{Return $Reply.Data.data}
    }
#End



###########################################################
################################################# CacheNode

<#
.Synopsis
   Cache Node Lists - Internal
.DESCRIPTION
   # INTERNAL FUNCTION #
   Cache Node Lists per type
   Used for dynamic Name Params
.EXAMPLE
    CacheNode User
#>
function CacheNode{
    [CmdletBinding()]
    Param(
        # Specify Type (Default All) 
        [ValidateSet('All','User','Group','Computer','Domain')]
        [parameter(Mandatory=0)][string]$NodeType='All'
        )
    # Cache User List
    if($NodeType -match "All|User"){
        $Query = "MATCH (n:User) RETURN n"
        $Script:CypherDog.UserList = (DogPost $Query -verbose:$false).name
        }
    # Cache Group List
    if($NodeType -match "All|Group"){
        $Query = "MATCH (n:Group) RETURN n"
        $Script:CypherDog.GroupList = (DogPost $Query -verbose:$false).name
        }
    # Cache Computer List
    if($NodeType -match "All|Computer"){
        $Query = "MATCH (n:Computer) RETURN n"
        $Script:CypherDog.ComputerList = (DogPost $Query -verbose:$false).name
        }
    # Cache Domain List 
    if($NodeType -match "All|Domain"){
        $Query = "MATCH (n:Domain) RETURN n"
        $Script:CypherDog.DomainList = (DogPost $Query -verbose:$false).name
        }}
#####End

## (re)load
Clear
$ASCII
CacheNode



###########################################################
###################################################### DynP

<#
.Synopsis
   Get Dynamic Param - Internal
.DESCRIPTION
   # INTERNAL FUNCTION #
   Return Single DynParam to be added to dictionnary
.EXAMPLE
    GetDynParam TestParam String -mandatory 1
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



###########################################################
################################################# ToPathObj

<#
.Synopsis
   Parse to Path Object - Internal
.DESCRIPTION
   Description
.EXAMPLE
    Example-One
#>
function ToPathObj{
    [CmdletBinding()]
    [Alias()]
    Param(
        [Parameter(ValueFromPipelineByPropertyName=1)]$Data
        )
    Begin{$Result=@()}
    Process{
        $StepCount = $Data.relationships.count
		# if Steps
        if($StepCount -gt 0){
            $PathObj = @()
            0..($StepCount -1)|%{
                $Props = @{
                    'Step'       = $_
                    'StartNode'  = (irm -Method Get -Headers $header -uri @($Data.nodes)[$_]).data.name 
                    'Edge'       = (irm -Method Get -Headers $header -uri @($Data.relationships)[$_]).type
                    'EndNode'    = (irm -Method Get -Headers $header -uri @($Data.nodes)[$_+1]).data.name
                    'Direction'  = @($Data.directions)[$_]
                    }
                $PathObj += New-Object PSCustomObject -Property $props
                }
            $Result += $PathObj | select 'Step','StartNode','Edge','Direction','EndNode'
            }}
    # Return Result
    End{Return $Result}
    }
#End



###########################################################
################################################## ClipThis

<#
.Synopsis
   Query to ClibOard  - Internal
.DESCRIPTION
   Description
.EXAMPLE
    Example-One
#>
Function ClipThis{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=1)][String]$Query,
        [Parameter(Mandatory=0)][Alias('With')][HashTable]$Params
        )
    if($Params.count){$Params.keys|%{$Query=$Query.replace("{$_}","'$($Params.$_)'")}}
    Write-Verbose "$Query"
    $Query | Set-ClipBoard
    }
#End



###########################################################
################################################ Wald0Index

<#
.Synopsis
   Query to ClibOard  - Internal
.DESCRIPTION
   Description
.EXAMPLE
    Example-One
#>
function Wald0Index{
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline=1,ValueFromPipelineByPropertyName=1)][Alias('TargetGroup')][String]$Name  = "DOMAIN ADMINS@EXTERNAL.LOCAL"
        )
    Begin{
        $Result = @()
        }
    Process{
        # TargetFolder
        $TargetGroup = $Name
        # Split Domain
        $TargetDomain = $TargetGroup.split('@')[1]
        
        # Get User Nodes
        $UserNode = Node -User | WHERE name -match $TargetDomain
        $UserCount = $UserNode.Count
        # Prep empty length collection
        $UserPath = $UserNode.name | Path -UserToGroup -to $TargetGroup
        $UserHopCount = $UserPath.count
        $UserPathCount = ($UserPath |  where step -eq 0).count
        # Calc User avg distance
        $UserAvgHop =  [Math]::Round($UserHopCount/$UserPathCount,2)
        # Calc User Index
        $UserIndex = [Math]::Round(100*$UserPathCount/$($UserCount),2)
        
        # Get Computer Nodes and Paths
        $ComputerNode =  Node -Computer | WHERE name -match $TargetDomain
        $ComputerCount = $computerNode.count
        # Prep empty length collection
        $ComputerPath = $ComputerNode.name | Path -ComputerToGroup -to $TargetGroup
        $ComputerHopCount = $ComputerPath.Count
        $ComputerPathCount = ($ComputerPath | where step -eq 0).count
        # Calc User avg distance
        $ComputerAvgHop = [Math]::Round($ComputerHopCount/$ComputerPathCount,2)
        # Calc User Index
        $ComputerIndex = [Math]::Round(100*$($ComputerPathCount)/$($ComputerCount),2)
        
        # Avg
        $AvgHop   = [Math]::Round($(($UserAvgHop+$ComputerAvgHop)/2),2)
        $AvgIndex = [Math]::Round($(($UserIndex+$ComputerIndex)/2),2)

        # Return Wald0 Index Object
        $Result += New-Object PSCustomObject -Property @{
            Domain  = $TargetDomain
            TargetG = $TargetGroup
            UPath   = $UserIndex
            UHop    = $UserAvgHop
            CPath   = $ComputerIndex
            CHop    = $ComputerAvgHop
            PathAvg = $AvgIndex
            HopAvg  = $AvgHop
            }}
    # Return Result
    End{Return $Result | Select Domain,TargetG,UPath,UHop,CPath,CHop,PathAvg,HopAvg}
    }
#End



#endregion ################################################
###########################################################



#region ######################################### Externals

## EXTERNALS ##############################################
#
#  BloodHound-Node        >  View Node by Name
#  BloodHound-NodeSearch  >  Search Node by Name/Prop/Value
#  BloodHound-NodeCreate  >  Create Node & Node Props
#  BloodHound-NodeUpdate  >  Update Node Props              
#  BloodHound-NodeDelete  >  Delete Node by Name            
#  BloodHound-Edge        >  View Nodes per Edge            <-------------------- /!\ Need BugCheck
#  BloodHound-EdgeReverse >  View Nodes per Reverse Edge    <-------------------- /!\ Need BugFix
#  BloodHound-EdgeCustom  >  View Nodes per Custom Edge     <-------------------- /!\ Need BugFix
#  BloodHound-EdgeCreate  >  Create Edges between Nodes
#  BloodHound-EdgeDelete  >  Delete Edges between Nodes
#  BloodHound-Path        >  View Shotrtest Path
#  BloodHound-PathVia     >  View Shortest Path Via
#  BloodHound-PathCypher  >  Cypher Query Generator         
#
###########################################################


###########################################################
########################################### BloodHound-Node

<#
.Synopsis
   Get BloodHound Node
.DESCRIPTION
   View BloodHound Node (by type) by name
   Returns all Nodes of specified type if name ommitted
   Queries all Node Types if type ommitted
.EXAMPLE
    Node -User ACHAVARIN@EXTERNAL.LOCAL 
    Returns specified Nodes
.EXAMPLE
    Node -User
    Returns all User Nodes
.EXAMPLE
    Node
    Returns all Nodes (All Types)
.EXAMPLE
    Node ACHAVARIN@EXTERNAL.LOCAL
    Query by Name without Node Type
    Same as example1 but less eco-friendly
#>
function BloodHound-Node{
    [CmdletBinding(DefaultParameterSetName='Any')]
    [Alias('Node')]
    Param(
        # Any Node Type (Default)
        [Parameter(Mandatory=0,ParameterSetName='Any')][Switch]$Any,
        # User Node Type
        [Parameter(Mandatory=1,ParameterSetName='User')][Switch]$User,
        # Group Node Type
        [Parameter(Mandatory=1,ParameterSetName='Group')][Switch]$Group,
        # Computer Node Type
        [Parameter(Mandatory=1,ParameterSetName='Computer')][Switch]$Computer,
        # Domain Node Type
        [Parameter(Mandatory=1,ParameterSetName='Domain')][Switch]$Domain
        )
    DynamicParam{
        # Prep Dico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        Switch($PSCmdlet.ParameterSetName){
            'Any'     {$DynNameList += $Script:CypherDog.UserList+$Script:CypherDog.GroupList+$Script:CypherDog.ComputerList+$Script:CypherDog.DomainList}
            'User'    {$DynNameList += $Script:CypherDog.UserList}
            'Group'   {$DynNameList += $Script:CypherDog.GroupList}
            'Computer'{$DynNameList += $Script:CypherDog.ComputerList}
            'Domain'  {$DynNameList += $Script:CypherDog.DomainList}
            }
        # Prep DynP
        $DynName = DynP -Name 'Name' -Type 'String' -Mandat 0 -Pos 0 -Pipe 1 -PipeProp 1 -VSet $DynNameList
        $DynCypher = DynP -Name 'Cypher' -Type 'Switch' -Mandat 0 -Pos 1 -Pipe 0 -PipeProp 0 -VSet $Null
        # DynP to Dico
        $Dico.Add("Name",$DynName)
        $Dico.Add("Cypher",$DynCypher) 
        # Return Dico
        Return $Dico
        }
    Begin{
        # Prep Empty result
        $Result = @()
        # Prep NodeType
        Switch($PScmdlet.ParameterSetName){
            'Any'  {$NodeType=$Null}
            Default{$NodeType=":$($PSCmdlet.ParameterSetName)"}
            }}
    Process{
        # If All Nodes (no INPUT) > Get All 
        if(-Not$DynName.IsSet){
            # Prep Query 
            $Query = "MATCH (x$NodeType) RETURN x"
            $Params = $Null
            }
        # Else (INPUT) > Get Specific 
        Else{
            # Prep Query
            $Query = "MATCH (x$NodeType) WHERE x.name={INPUT} RETURN x"
            $Params = @{INPUT="$($DynName.Value)"}
            }
        # Call Dog
        if(-Not$DynCypher.IsSet){$Result += DogPost $Query -Params $Params}
        }
    End{
        # If Cypher
        if($DynCypher.IsSet){ClipThis $Query -with $Params}
        # Return Result
        else{Return $Result | Sort name}
        }}
#####End



###########################################################
##################################### BloodHound-NodeSearch

<#
.Synopsis
   Synopsis
.DESCRIPTION
   Description
.EXAMPLE
    Example-One
#>
function BloodHound-NodeSearch{
    [CmdletBinding()]
    [Alias('NodeSearch')]
    Param(
        # Search User
        [Parameter(Mandatory=1,ParameterSetName='UserByPropertyValue')]
        [Parameter(Mandatory=1,ParameterSetName='UserByPropertyNot')]
        [Parameter(Mandatory=1,ParameterSetName='UserByProperty')]
        [Parameter(Mandatory=1,ParameterSetName='UserByPartialName')][Switch]$User,
        # Search Group
        [Parameter(Mandatory=1,ParameterSetName='GroupByPropertyValue')]
        [Parameter(Mandatory=1,ParameterSetName='GroupByPropertyNot')]
        [Parameter(Mandatory=1,ParameterSetName='GroupByProperty')]
        [Parameter(Mandatory=1,ParameterSetName='GroupByPartialName')][Switch]$Group,
        # Search Computer
        [Parameter(Mandatory=1,ParameterSetName='ComputerByPropertyValue')]
        [Parameter(Mandatory=1,ParameterSetName='ComputerByPropertyNot')]
        [Parameter(Mandatory=1,ParameterSetName='ComputerByProperty')]
        [Parameter(Mandatory=1,ParameterSetName='ComputerByPartialName')][Switch]$Computer,
        # Search Domain
        [Parameter(Mandatory=1,ParameterSetName='DomainByPropertyValue')]
        [Parameter(Mandatory=1,ParameterSetName='DomainByPropertyNot')]
        [Parameter(Mandatory=1,ParameterSetName='DomainByProperty')]
        [Parameter(Mandatory=1,ParameterSetName='DomainByPartialName')][Switch]$Domain,
        # Search By Keyword (Partial name)
        [Parameter(Mandatory=1,Position=0,ValueFromPipeline=1,ParameterSetName='UserByPartialName')]
        [Parameter(Mandatory=1,Position=0,ValueFromPipeline=1,ParameterSetName='GroupByPartialName')]
        [Parameter(Mandatory=1,Position=0,ValueFromPipeline=1,ParameterSetName='ComputerByPartialName')]
        [Parameter(Mandatory=1,Position=0,ValueFromPipeline=1,ParameterSetName='DomainByPartialName')][String]$Key,
        # Search By Property (exists)
        [Parameter(Mandatory=1,ParameterSetName='UserByPropertyNot')]
        [Parameter(Mandatory=1,ParameterSetName='GroupByPropertyNot')]
        [Parameter(Mandatory=1,ParameterSetName='ComputerByPropertyNot')]
        [Parameter(Mandatory=1,ParameterSetName='DomainByPropertyNot')][Switch]$NotExist,
        # Search By Property (exists)
        [Parameter(Mandatory=1,ParameterSetName='UserByProperty')]
        [Parameter(Mandatory=1,ParameterSetName='GroupByProperty')]
        [Parameter(Mandatory=1,ParameterSetName='ComputerByProperty')]
        [Parameter(Mandatory=1,ParameterSetName='DomainByProperty')]
        [Parameter(Mandatory=1,ParameterSetName='UserByPropertyNot')]
        [Parameter(Mandatory=1,ParameterSetName='GroupByPropertyNot')]
        [Parameter(Mandatory=1,ParameterSetName='ComputerByPropertyNot')]
        [Parameter(Mandatory=1,ParameterSetName='DomainByPropertyNot')]
        [Parameter(Mandatory=1,ParameterSetName='UserByPropertyValue')]
        [Parameter(Mandatory=1,ParameterSetName='GroupByPropertyValue')]
        [Parameter(Mandatory=1,ParameterSetName='ComputerByPropertyValue')]
        [Parameter(Mandatory=1,ParameterSetName='DomainByPropertyValue')][String]$Property,
        # Search By Property Value
        [Parameter(Mandatory=1,ParameterSetName='UserByPropertyValue')]
        [Parameter(Mandatory=1,ParameterSetName='GroupByPropertyValue')]
        [Parameter(Mandatory=1,ParameterSetName='ComputerByPropertyValue')]
        [Parameter(Mandatory=1,ParameterSetName='DomainByPropertyValue')][String]$Value,
        # Clip
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    Begin{
        # Prep Vars
        $Result=@()
        $PSN = $PSCmdlet.ParameterSetName
        $NodeType = $PSN.replace('By','*').split('*')[0]
        # Prep Query
        Switch -Regex ($PSN){
            "Name$"    {$Query = "MATCH (X:$NodeType) WHERE X.name =~ {REGEX} RETURN X"}
            "Property$"{$Query = "MATCH (X:$NodeType) WHERE exists(X.$Property) RETURN X"}
            "Not$"     {$Query = "MATCH (X:$NodeType) WHERE NOT exists(X.$Property) RETURN X"}
            "Value$"   {$Query = "MATCH (X:$NodeType) WHERE X.$Property = {VALUE} RETURN X"}
            }}
    Process{
        # Prep Params
        Switch -Regex ($PSN){
            "Name$"    {$Params = @{REGEX="(?i).*$Key.*"}}
            "Value$"   {$Params = @{VALUE="$Value"}}
            Default    {$Params = $Null}
            }
        # Call Dog
        $Result += DogPost $Query -Params $Params
        }
    # Return Result
    End{
        # If Cypher
        if($Cypher){ClipThis $Query -with $Params}
        # Else Result
        else{Return $Result | Sort name}
        }}
#####End



###########################################################
##################################### BloodHound-NodeCreate

<#
.Synopsis
   Create Nodes
.DESCRIPTION
   Add Nodes to DB
   Must specify Type and name
   Can also set porperties (via HashTable)
.EXAMPLE
    NodeCreate -User -Name Bob
.EXAMPLE
    NodeCreate -User Bob -Property @{Age=23,City='London'}
#>
function BloodHound-NodeCreate{
    [CmdletBinding()]
    [Alias('NodeCreate')]
    Param(
        # Create User Node
        [Parameter(Mandatory=1,ParameterSetName='User')][Switch]$User,
        # Create Group Node 
        [Parameter(Mandatory=1,ParameterSetName='Group')][Switch]$Group,
        # Create Computer Node
        [Parameter(Mandatory=1,ParameterSetName='Computer')][Switch]$Computer,
        # Create Domain Node
        [Parameter(Mandatory=1,ParameterSetName='Domain')][Switch]$Domain,
        # Specify Name
        [Parameter(Mandatory=1,Position=0,ValueFromPipeline=1)][String]$Name,
        # Set Node Properties (optional)
        [Parameter(Mandatory=0,Position=1)][Hashtable]$Properties,
        # Cypher
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    Begin{
        # Prep Vars
        $NodeType=$PSCmdlet.ParameterSetName
        $Query = "MERGE (X:$NodeType {name: {NAME}})" 
        }
    Process{
        # Set Param
        $Params = @{NAME="$Name"}
        # if Not Cypher
        if(-Not$Cypher){
            # Call the Dog
            DogPost $Query -Params $Params
            # Refresh Cache
            CacheNode $NodeType
            # Update Props
            if($Properties){
                $Splat = @{
                    $NodeType = $true
                    Name = $Name
                    Properties = $Properties
                    }
                NodeUpdate @Splat -verbose
                }}
        # Else Clip
        Else{ClipThis $Query -with $Params}
        }
    # Return Nothing
    End{<#NoOut#>}
    }
#End



###########################################################
##################################### BloodHound-NodeUpdate

<#
.Synopsis
   Synopsis
.DESCRIPTION
   Description
.EXAMPLE
   Example-One
#>
function BloodHound-NodeUpdate{
    [CmdletBinding()]
    [Alias('NodeUpdate')]
    Param(
        # Update User Node
        [Parameter(Mandatory=1,ParameterSetName='DeletePropUser')]
        [Parameter(Mandatory=1,ParameterSetName='User')][Switch]$User,
        # Update Group Node
        [Parameter(Mandatory=1,ParameterSetName='DeletePropGroup')] 
        [Parameter(Mandatory=1,ParameterSetName='Group')][Switch]$Group,
        # Update Computer Node
        [Parameter(Mandatory=1,ParameterSetName='DeletePropComputer')]
        [Parameter(Mandatory=1,ParameterSetName='Computer')][Switch]$Computer,
        # Update Domain Node
        [Parameter(Mandatory=1,ParameterSetName='DeletePropDomain')]
        [Parameter(Mandatory=1,ParameterSetName='Domain')][Switch]$Domain,
        # Delete Node Properties
        [Parameter(Mandatory=1,ParameterSetName='DeletePropDomain')]
        [Parameter(Mandatory=1,ParameterSetName='DeletePropComputer')]
        [Parameter(Mandatory=1,ParameterSetName='DeletePropGroup')]
        [Parameter(Mandatory=1,ParameterSetName='DeletePropUser')][Switch]$Delete,
        # Cypher
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    DynamicParam{
        # Prep Dico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        Switch($PSCmdlet.ParameterSetName){
            'User'    {$DynNameList += $Script:CypherDog.UserList}
            'Group'   {$DynNameList += $Script:CypherDog.GroupList}
            'Computer'{$DynNameList += $Script:CypherDog.ComputerList}
            'Domain'  {$DynNameList += $Script:CypherDog.DomainList}
            }
        # Prep DynP
        $DynName = DynP -Name 'Name' -Type 'String' -Mandat 1 -Pos 0 -Pipe 1 -PipeProp 1 -VSet $DynNameList
        if($PSCmdlet.ParameterSetName -match 'Delete'){
            $DynProps = DynP -Name 'PropertyName' -Type 'String[]'-Mandat 1 -Pos 1 -Pipe 0 -PipeProp 0 -VSet $Null
            $Dico.Add('PropertyName',$DynProps)
            }
        Else{$DynProps = DynP -Name 'Properties' -Type 'HashTable'-Mandat 1 -Pos $Null -Pipe 0 -PipeProp 0 -VSet $Null
            $Dico.Add('Properties',$DynProps)
            }
        # DynP to Dico
        $Dico.Add('Name',$DynName) 
        # Return Dico
        Return $Dico
        }
    Begin{
        # Set var
        $NodeType = $PSCmdlet.ParameterSetName.replace('DeleteProp','')
        }
    Process{
        # Prep Query
        if($Delete){$Query="MATCH (X:$NodeType) WHERE X.name = {NAME} REMOVE"}
        else{$Query = "MATCH (X:$NodeType) WHERE X.name = {NAME} SET"}
        # Add Name to Params
        $Params = @{NAME="$($DynName.Value)"}
        # If Delete props
        if($Delete){
            $DynProps.Value|%{$Query += " X.$_,"}
            $Query=$Query.TrimEnd(',')
            }
        # If Update Props
        else{
            # For each Prop
            $DynProps.Value.Keys|%{
                # Append to Query
                $Query+=" X.$_={$_},"
                # Add to Param
                $Params += @{$_="$($DynProps.Value.$_)"}
                }
            $Query=$Query.trimEnd(',')
            }
        # Call Dog
        if(-Not$Cypher){DogPost $Query -Params $Params}
        # or clip
        else{ClipThis $Query -with $Params}
        }
    # Return Nothing
    End{<#NoOut#>}
    }
#End



###########################################################
##################################### BloodHound-NodeDelete

<#
.Synopsis
   Delete Nodes
.DESCRIPTION
   Delete Nodes from DB
.EXAMPLE
    Example-One
#>
function BloodHound-NodeDelete{
    [CmdletBinding()]
    [Alias('NodeDelete')]
    Param(
        # Delete User Node
        [Parameter(Mandatory=1,ParameterSetName='User')][Switch]$User,
        # Delete Group Node 
        [Parameter(Mandatory=1,ParameterSetName='Group')][Switch]$Group,
        # Delete Computer Node
        [Parameter(Mandatory=1,ParameterSetName='Computer')][Switch]$Computer,
        # Delete Domain Node
        [Parameter(Mandatory=1,ParameterSetName='Domain')][Switch]$Domain
        )
    DynamicParam{
        # Prep Dico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        Switch($PSCmdlet.ParameterSetName){
            'User'    {$DynNameList += $Script:CypherDog.UserList}
            'Group'   {$DynNameList += $Script:CypherDog.GroupList}
            'Computer'{$DynNameList += $Script:CypherDog.ComputerList}
            'Domain'  {$DynNameList += $Script:CypherDog.DomainList}
            }
        # Prep DynP
        $DynName = DynP -Name 'Name' -Type 'String' -Mandat 1 -Pos 0 -Pipe 1 -PipeProp 1 -VSet $DynNameList
        $DynCypher = DynP -Name 'Cypher' -Type 'Switch' -Mandat 0 -Pos 1 -Pipe 0 -PipeProp 0 -VSet $Null 
        # DynP to Dico
        $Dico.Add('Name',$DynName)
        $Dico.Add('Cypher',$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{
        # Prep Query
        $NodeType = $PSCmdlet.ParameterSetname
        $Query = "MATCH (X:$NodeType {name: {NAME}}) DETACH DELETE X"
        }
    Process{
        # Set Params
        $Params = @{NAME="$($DynName.Value)"}
        if($DynCypher.IsSet){ClipThis $Query -with $Params}
        else{
        # Call Dog
        DogPost $Query -Params $Params
        # Cache Nodes
        CacheNode $NodeType
        }}
    # Return nothing
    End{<#NoOut#>}
    }
#End



###########################################################
########################################### BloodHound-Edge

<#
.Synopsis
   View Nodes per Edge
.DESCRIPTION
   View Nodes of specifed type with specified 
   relationship to specified target
.EXAMPLE
   Edge      
#>
function BloodHound-Edge{
	[CmdletBinding()]
	[Alias('Edge')]
	param(
		# MemberOfGroup (Input: G - Return: U|G|C)
		[Parameter(Mandatory=$True,ParameterSetname='MemberOfGroup')][Switch]$MemberOfGroup,
		# AdminToComputer (Input: C - Return: U|G|C)
		[Parameter(Mandatory=$True,ParameterSetname='AdminToComputer')][Switch]$AdminToComputer,
		# SessionFromUser (Input: U - Return: C)
		[Parameter(Mandatory=$True,ParameterSetname='SessionFromUser')][Switch]$SessionFromUser,
		# SetPasswordOfUser (Input: U - Return: U|G|C)
		[Parameter(Mandatory=$True,ParameterSetname='SetPasswordOfUser')][Switch]$SetPasswordOfUser,
		# AddMemberToGroup (Input: G - Return: U|G|C)
		[Parameter(Mandatory=$True,ParameterSetname='AddMemberToGroup')][Switch]$AddMemberToGroup,
		# AllExtendedOnUser (Input: U - Return: U|G|C)
		[Parameter(Mandatory=$True,ParameterSetname='AllExtendedOnUser')][Switch]$AllExtendedOnUser,
		# AllExtendedOnGroup (Input: G - Return: U|G|C)
		[Parameter(Mandatory=$True,ParameterSetname='AllExtendedOnGroup')][Switch]$AllExtendedOnGroup,
		# AllGenericOnUser (Input: U - Return: U|G|C)
		[Parameter(Mandatory=$True,ParameterSetname='AllGenericOnUser')][Switch]$AllGenericOnUser,
		# AllGenericOnGroup (Input: G - Return: U|G|C)
		[Parameter(Mandatory=$True,ParameterSetname='AllGenericOnGroup')][Switch]$AllGenericOnGroup,
		# WriteGenericOnUser (Input: U - Return: U|G|C)
		[Parameter(Mandatory=$True,ParameterSetname='WriteGenericOnUser')][Switch]$WriteGenericOnUser,
		# WriteGenericOnGroup (Input: G - Return: U|G|C)
		[Parameter(Mandatory=$True,ParameterSetname='WriteGenericOnGroup')][Switch]$WriteGenericOnGroup,
		# WriteOwnerOnUser (Input: U - Return: U|G|C)
		[Parameter(Mandatory=$True,ParameterSetname='WriteOwnerOnUser')][Switch]$WriteOwnerOnUser,
		# WriteOwnerOnGroup (Input: G - Return: U|G|C)
		[Parameter(Mandatory=$True,ParameterSetname='WriteOwnerOnGroup')][Switch]$WriteOwnerOnGroup,
		# WriteDACLOnUser (Input: U - Return: U|G|C)
		[Parameter(Mandatory=$True,ParameterSetname='WriteDACLOnUser')][Switch]$WriteDACLOnUser,
		# WriteDACLOnGroup (Input: G - Return: U|G|C)
		[Parameter(Mandatory=$True,ParameterSetname='WriteDACLOnGroup')][Switch]$WriteDACLOnGroup,
		# TrustedByDomain (Input: D - Return: D)
		[Parameter(Mandatory=$True,ParameterSetname='TrustedByDomain')][Switch]$TrustedByDomain
		)
	DynamicParam{
		# Select ValidateSets for Dynamic Parameters
		Switch($PSCmdlet.ParameterSetName){
            # PSN                | NAME                                   | TARGET                            |
            #-------------------------------------------------------------------------------------------------|
			'MemberOfGroup'      {$VSet = $Script:CypherDog.GroupList;    $VRet = 'Users','Groups','Computers'}
			'AdminToComputer'    {$VSet = $Script:CypherDog.ComputerList; $VRet = 'Users','Groups','Computers'}
			'SessionFromUser'    {$VSet = $Script:CypherDog.UserList;     $VRet = 'Computers'                 }
			'SetPasswordOfUser'  {$VSet = $Script:CypherDog.UserList;     $VRet = 'Users','Groups','Computers'}
			'AddMemberToGroup'   {$VSet = $Script:CypherDog.GroupList;    $VRet = 'Users','Groups','Computers'}
			'AllExtendedOnUser'  {$VSet = $Script:CypherDog.UserList;     $VRet = 'Users','Groups','Computers'}
			'AllExtendedOnGroup' {$VSet = $Script:CypherDog.GroupList;    $VRet = 'Users','Groups','Computers'}
			'AllGenericOnUser'   {$VSet = $Script:CypherDog.UserList;     $VRet = 'Users','Groups','Computers'}
			'AllGenericOnGroup'  {$VSet = $Script:CypherDog.GroupList;    $VRet = 'Users','Groups','Computers'}
			'WriteGenericOnUser' {$VSet = $Script:CypherDog.UserList;     $VRet = 'Users','Groups','Computers'}
			'WriteGenericOnGroup'{$VSet = $Script:CypherDog.GroupList;    $VRet = 'Users','Groups','Computers'}
			'WriteOwnerOnUser'   {$VSet = $Script:CypherDog.UserList;     $VRet = 'Users','Groups','Computers'}
			'WriteOwnerOnGroup'  {$VSet = $Script:CypherDog.GroupList;    $VRet = 'Users','Groups','Computers'}
			'WriteDACLOnUser'    {$VSet = $Script:CypherDog.UserList;     $VRet = 'Users','Groups','Computers'}
			'WriteDACLOnGroup'   {$VSet = $Script:CypherDog.GroupList;    $VRet = 'Users','Groups','Computers'}
			'TrustedByDomain'    {$VSet = $Script:CypherDog.DomainList;   $VRet = 'Domains'                   }
			}
		# Dico
		$Dico = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        # DynName
        $DynName = DynP -Name 'Name' -Type string -Mandat 1 -Pos 0 -Pipe 1 -PipeProp 1 -VSet $VSet
        $Dico.Add('Name',$DynName)
		# DynReturn (ex DynParam2)
        $DynReturn = DynP -Name 'Return' -Type String -Mandat 1 -Pos 2 -Pipe 0 -PipeProp 0 -VSet $VRet
        $Dico.add('Return',$DynReturn)
        # if MemberOf
        If($PSCmdlet.ParameterSetName -match "MemberOf"){
            ## Max Degree (ex DynParam3)
            # Attribute
            $Attrib = New-Object System.Management.Automation.ParameterAttribute
            $Attrib.Mandatory = $false
            # AttributeCollection
            $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection.Add($Attrib)
            # Validate Pattern    
		    $VPat=new-object System.Management.Automation.ValidatePatternAttribute('^\d$|\*')
		    $Collection.Add($VPat)
            # Create Runtime Parameter with matching attribute collection
            $DynMax = New-Object System.Management.Automation.RuntimeDefinedParameter('Degree', [String], $Collection)
            # Add to dico
            $Dico.Add('Degree',$dynMax)
            }
        # DynCypher
        $DynCypher = DynP -Name 'Cypher' -Type Switch -Mandat 0 -Pos 3 -Pipe 0 -PipeProp 0 -VSet $null
        $Dico.add('Cypher',$DynCypher)
		#return Dico
		return $Dico
		}
	Begin{
        # Fix DynMax
        if($PScmdlet.ParameterSetName -match 'MemberOf' -AND -Not$DynMax.IsSet){$DynMax.Value=1}
        if($PScmdlet.ParameterSetName -match 'MemberOf' -AND $DynMax.Value -eq '*'){$DynMax.Value=$Null}
		# Populate Query vars
		Switch($PSCmdlet.ParameterSetName){
            # PSN                | EDGE                      | TARGET               |
            #-----------------------------------------------------------------------|
			'MemberOfGroup'      {$Edge='MemberOf'           ;$TargetType='Group'   }
			'AdminToComputer'    {$Edge='AdminTo'            ;$TargetType='Computer'}
			'SessionFromUser'    {$Edge='HasSession'         ;$TargetType='User'    }
			'SetPasswordOfUser'  {$Edge='ForceChangePassword';$TargetType='User'    }
			'AddMemberToGroup'   {$Edge='AddMembers'         ;$TargetType='Group'   }
			'AllExtendedOnUser'  {$Edge='AllExtendedRights'  ;$TargetType='User'    }
			'AllExtendedOnGroup' {$Edge='AllExtendedRights'  ;$TargetType='Group'   }
			'AllGenericOnUser'   {$Edge='GenericAll'         ;$TargetType='User'    }
			'AllGenericOnGroup'  {$Edge='GenericAll'         ;$TargetType='Group'   }
			'WriteGenericOnUser' {$Edge='GenericWrite'       ;$TargetType='User'    }
			'WriteGenericOnGroup'{$Edge='GenericWrite'       ;$TargetType='Group'   }
			'WriteOwnerOnUser'   {$Edge='WriteOwner'         ;$TargetType='User'    }
			'WriteOwnerOnGroup'  {$Edge='WriteOwner'         ;$TargetType='Group'   }
			'WriteDACLOnUser'    {$Edge='WriteDACL'          ;$TargetType='User'    }
			'WriteDACLOnGroup'   {$Edge='WriteDACL'          ;$TargetType='Group'   }
			'TrustedByDomain'    {$Edge='TrustedBy'          ;$TargetType='Domain'  }
			}
		# Fix OutputType
        $ReturnType=$dynReturn.Value.trimEnd('s')
        # MaxHop
        if($DynMax.IsSet){$MaxHop = $DynMax.value}
        Else{$MaxHop=$Null}
        # Min Hop (domain=1)
        if($PSCmdlet.ParameterSetName -eq 'TrustedByDomain'){$MinHop=0}
        else{$MinHop=1}
        # Admin
        #if($Edge='AdminTo' -AND $MaxHop -gt 1){$Edge='AdminTo|:MemberOf'}
        # Query
        $Query = "MATCH (A:$ReturnType), (B:$TargetType {name: {target}}), p=(A)-[r:$Edge*$MinHop..$MaxHop]->(B) RETURN A"
        # Empty Result
        $Result = @()
		}
	Process{
        #  Set TargetName
        $Targetname = $DynName.Value
        $Params = @{target="$TargetName"}
        # If ClipBoard
        if($DynCypher.Isset){ClipThis $Query -with $Params}
        # Else
        else{
            # If User Group MemberShip
            if($PSCmdlet.ParameterSetName -eq 'MemberOf' -AND $ReturnType -ne 'Group'){
                $Query0="MATCH (A:Group), (B:Group {name: {target}}), p=(A)-[r:$Edge*0..$MaxHop]->(B) RETURN A"
                $Result += DogPost $Query0 -Params $Params | Edge -MemberOfGroup -Return $dynReturn.Value
                $Result += Edge -MemberOfGroup "$TargetName" -return $dynReturn.Value
                }
		    else{$Result += DogPost $Query -Params $Params}
            }}
    # Return Result	
    End{if(-Not$DynCypher.Isset){Return $Result | Sort name -unique}}
    }
#End



###########################################################
#################################### BloodHound-EdgeReverse

<#
.Synopsis
   Synopsis
.DESCRIPTION
   Description
.EXAMPLE
    Example-One
#>
function BloodHound-EdgeReverse{
	[CmdletBinding()]
	[Alias('EdgeReverse')]
	param(
		# ParentOfUser (in: U - out: G)
		[Parameter(Mandatory=1,ParameterSetname='ParentOfUser')][Switch]$ParentOfUser,
		# ParentOfGroup (in: G - out: G)
		[Parameter(Mandatory=1,ParameterSetname='ParentOfGroup')][Switch]$ParentOfGroup,
		# ParentOfComputer (in: C - out: G)
		[Parameter(Mandatory=1,ParameterSetname='ParentOfComputer')][Switch]$ParentOfComputer,
		# AdminByUser (in: U - out: C)
		[Parameter(Mandatory=1,ParameterSetname='AdminByUser')][Switch]$AdminByUser,
		# AdminByGroup (in: G - out: C)
		[Parameter(Mandatory=1,ParameterSetname='AdminByGroup')][Switch]$AdminByGroup,
		# AdminByComputer (in: C - out: C)
		[Parameter(Mandatory=1,ParameterSetname='AdminByComputer')][Switch]$AdminByComputer,
		# SessionOnComputer (in: C - out: U)
		[Parameter(Mandatory=1,ParameterSetname='SessionOnComputer')][Switch]$SessionOnComputer,
		# PasswordSetByUser (in: U - out: U)
		[Parameter(Mandatory=1,ParameterSetname='PasswordSetByUser')][Switch]$PasswordSetByUser,
		# PasswordSetByGroup (in: G - out: U)
		[Parameter(Mandatory=1,ParameterSetname='PasswordSetByGroup')][Switch]$PasswordSetByGroup,
		# PasswordSetByComputer (in: C - out: U)
		[Parameter(Mandatory=1,ParameterSetname='PasswordSetByComputer')][Switch]$PasswordSetByComputer,
		# MemberAddByUser (in: U - out: G)
		[Parameter(Mandatory=1,ParameterSetname='MemberAddByUser')][Switch]$MemberAddByUser,
		# MemberAddByGroup (in: G - out: G)
		[Parameter(Mandatory=1,ParameterSetname='MemberAddByGroup')][Switch]$MemberAddByGroup,
		# MemberAddByComputer (in: C - out: G)
		[Parameter(Mandatory=1,ParameterSetname='MemberAddByComputer')][Switch]$MemberAddByComputer,
		# ExtendedAllByUser (in: U - out: U|G)
		[Parameter(Mandatory=1,ParameterSetname='ExtendedAllByUser')][Switch]$ExtendedAllByUser,
		# ExtendedAllByGroup (in: G - out: U|G)
		[Parameter(Mandatory=1,ParameterSetname='ExtendedAllByGroup')][Switch]$ExtendedAllByGroup,
		# ExtendedAllByComputer (in: C - out: U|G)
		[Parameter(Mandatory=1,ParameterSetname='ExtendedAllByComputer')][Switch]$ExtendedAllByComputer,
		# GenericAllByUser (in: U - out: U|G)
		[Parameter(Mandatory=1,ParameterSetname='GenericAllByUser')][Switch]$GenericAllByUser,
		# GenericAllByGroup (in: G - out: U|G)
		[Parameter(Mandatory=1,ParameterSetname='GenericAllByGroup')][Switch]$GenericAllByGroup,
		# GenericAllByComputer (in: C - out: U|G)
		[Parameter(Mandatory=1,ParameterSetname='GenericAllByComputer')][Switch]$GenericAllByComputer,
		# GenericWriteByUser (in: U - out: U|G)
		[Parameter(Mandatory=1,ParameterSetname='GenericWriteByUser')][Switch]$GenericWriteByUser,
		# GenericWriteByGroup (in: G - out: U|G)
		[Parameter(Mandatory=1,ParameterSetname='GenericWriteByGroup')][Switch]$GenericWriteByGroup,
		# GenericWriteByComputer (in: C - out: U|G)
		[Parameter(Mandatory=1,ParameterSetname='GenericWriteByComputer')][Switch]$GenericWriteByComputer,
		# OwnerWriteByUser (in: U - out: U|G)
		[Parameter(Mandatory=1,ParameterSetname='OwnerWriteByUser')][Switch]$OwnerWriteByUser,
		# OwnerWriteByGroup (in: G - out: U|G)
		[Parameter(Mandatory=1,ParameterSetname='OwnerWriteByGroup')][Switch]$OwnerWriteByGroup,
		# OwnerWriteByComputer (in: C - out: U|G)
		[Parameter(Mandatory=1,ParameterSetname='OwnerWriteByComputer')][Switch]$OwnerWriteByComputer,
		# DACLWriteByUser (in: U - out: U|G)
		[Parameter(Mandatory=1,ParameterSetname='DACLWriteByUser')][Switch]$DACLWriteByUser,
		# DACLWriteByGroup (in: G - out: U|G)
		[Parameter(Mandatory=1,ParameterSetname='DACLWriteByGroup')][Switch]$DACLWriteByGroup,
		# DACLWriteByComputer (in: C - out: U|G)
		[Parameter(Mandatory=1,ParameterSetname='DACLWriteByComputer')][Switch]$DACLWriteByComputer,
		# TrustingDomain (in: D - out: D)
		[Parameter(Mandatory=1,ParameterSetname='TrustingDomain')][Switch]$TrustingDomain
		)
	DynamicParam{
		# Prep Lists
		$UserList     = $Global:CypherDog.UserList
		$GroupList    = $Global:CypherDog.GroupList
		$ComputerList = $Global:CypherDog.ComputerList
		$DomainList   = $Global:CypherDog.DomainList
		# ValidateSets
		Switch($PSCmdlet.ParameterSetName){
            # PSN                    | TARGET               | RETRUN                  |
            #------------------------|----------------------|-------------------------|
			'ParentOfUser'           {$VTgt = $UserList     ; $VRet = 'Groups'        }
			'ParentOfGroup'          {$VTgt = $GroupList    ; $VRet = 'Groups'        }
			'ParentOfComputer'       {$VTgt = $ComputerList ; $VRet = 'Groups'        }
			'AdminByUser'            {$VTgt = $UserList     ; $VRet = 'Computers'     }
			'AdminByGroup'           {$VTgt = $GroupList    ; $VRet = 'Computers'     }
			'AdminByComputer'        {$VTgt = $ComputerList ; $VRet = 'Computers'     }
			'SessionOnComputer'      {$VTgt = $ComputerList ; $VRet = 'Users'         }
			'PasswordSetByUser'      {$VTgt = $UserList     ; $VRet = 'Users'         }
			'PasswordSetByGroup'     {$VTgt = $GroupList    ; $VRet = 'Users'         }
			'PasswordSetByComputer'  {$VTgt = $ComputerList ; $VRet = 'Users'         }
			'MemberAddByUser'        {$VTgt = $UserList     ; $VRet = 'Groups'        }
			'MemberAddByGroup'       {$VTgt = $GroupList    ; $VRet = 'Groups'        }
			'MemberAddByComputer'    {$VTgt = $ComputerList ; $VRet = 'Groups'        }
			'ExtendedAllByUser'      {$VTgt = $UserList     ; $VRet = 'Users','Groups'}
			'ExtendedAllByGroup'     {$VTgt = $GroupList    ; $VRet = 'Users','Groups'}
			'ExtendedAllByComputer'  {$VTgt = $ComputerList ; $VRet = 'Users','Groups'}
			'GenericAllByUser'       {$VTgt = $UserList     ; $VRet = 'Users','Groups'}
			'GenericAllByGroup'      {$VTgt = $GroupList    ; $VRet = 'Users','Groups'}
			'GenericAllByComputer'   {$VTgt = $ComputerList ; $VRet = 'Users','Groups'}
			'GenericWriteByUser'     {$VTgt = $UserList     ; $VRet = 'Users','Groups'}
			'GenericWriteByGroup'    {$VTgt = $GroupList    ; $VRet = 'Users','Groups'}
			'GenericWriteByComputer' {$VTgt = $ComputerList ; $VRet = 'Users','Groups'}
			'OwnerWriteByUser'       {$VTgt = $UserList     ; $VRet = 'Users','Groups'}
			'OwnerWriteByGroup'      {$VTgt = $GroupList    ; $VRet = 'Users','Groups'}
			'OwnerWriteByComputer'   {$VTgt = $ComputerList ; $VRet = 'Users','Groups'}
			'DACLWriteByUser'        {$VTgt = $UserList     ; $VRet = 'Users','Groups'}
			'DACLWriteByGroup'       {$VTgt = $GroupList    ; $VRet = 'Users','Groups'}
			'DACLWriteByComputer'    {$VTgt = $ComputerList ; $VRet = 'Users','Groups'}
			'TrustingDomain'         {$VTgt = $DomainList   ; $VRet = 'Domains'       }
			}
		# Dico
		$Dico = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        # DynP
        $DynTarget = DynP -Name 'Name'   -Type String -Mandat 1 -Pos 0 -Pipe 1 -PipeProp 1 -VSet $VTgt
        $DynReturn = DynP -Name 'Return' -Type String -Mandat 1 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $VRet
		$Dico.Add('Name',$dynTarget)
		$Dico.Add('Return',$dynReturn)
        ## Degree
        If($PSCmdlet.ParameterSetName -match "ParentOf"){     
            # Attribs
            $Attrib = New-Object System.Management.Automation.ParameterAttribute
            $Attrib.Mandatory = 0
            $Attrib.Position = 2
            # Collection
            $Collect = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add attribs
            $Collect.Add($Attrib)
            # Validate Pattern     
		    $VPat=new-object System.Management.Automation.ValidatePatternAttribute('^\d$|\*')
		    $Collect.Add($VPat)
            # DynParam
            $DynDegree = New-Object System.Management.Automation.RuntimeDefinedParameter('Degree', [string], $Collect)
            # Add to Dico
            $Dico.Add('Degree',$dynDegree)
            }
        # DynCypher
        $DynCypher = DynP -Name 'Cypher' -Type Switch -Mandat 0 -Pos 3 -Pipe 0 -PipeProp 0 -VSet $null
        $Dico.add('Cypher',$DynCypher)    
        #return Dico
		return $Dico
		}
	Begin{
        if($PScmdlet.ParameterSetName -match 'ParentOf' -AND !$DynDegree.IsSet){$DynDegree.Value=1}
        if($PScmdlet.ParameterSetName -match 'ParentOf' -AND  $DynDegree.Value -eq '*'){$DynDegree.Value=$Null}
		# Query vars
		Switch($PSCmdlet.ParameterSetName){
            # ParmeterSetName       | EdgeName                       | InputType            |
            #-----------------------|--------------------------------|----------------------|
			'ParentOfUser'          {$EdgeName='MemberOf'            ; $InputType='User'    }
			'ParentOfGroup'         {$EdgeName='MemberOf'            ; $InputType='Group'   }
			'ParentOfComputer'      {$EdgeName='MemberOf'            ; $InputType='Computer'}
			'AdminByUser'           {$EdgeName='AdminTo'             ; $InputType='User'    }
			'AdminByGroup'          {$EdgeName='AdminTo'             ; $InputType='Group'   }
			'AdminByComputer'       {$EdgeName='AdminTo'             ; $InputType='Computer'}
			'SessionOnComputer'     {$EdgeName='HasSession'          ; $InputType='Computer'}
			'PasswordSetByUser'     {$EdgeName='ForceChangePassword' ; $InputType='User'    }
			'PasswordSetByGroup'    {$EdgeName='ForceChangePassword' ; $InputType='Group'   }
			'PasswordSetByComputer' {$EdgeName='ForceChangePassword' ; $InputType='Computer'}
			'MemberAddByUser'       {$EdgeName='AddMembers'          ; $InputType='User'    }
			'MemberAddByGroup'      {$EdgeName='AddMembers'          ; $InputType='Group'   }
			'MemberAddByComputer'   {$EdgeName='AddMembers'          ; $InputType='Computer'}
			'ExtendedAllByUser'     {$EdgeName='AllExtendedRights'   ; $InputType='User'    }
			'ExtendedAllByGroup'    {$EdgeName='AllExtendedRights'   ; $InputType='Group'   }
			'ExtendedAllByComputer' {$EdgeName='AllExtendedRights'   ; $InputType='Computer'}
			'GenericAllByUser'      {$EdgeName='GenericAll'          ; $InputType='User'    }
			'GenericAllByGroup'     {$EdgeName='GenericAll'          ; $InputType='Group'   }
			'GenericAllByComputer'  {$EdgeName='GenericAll'          ; $InputType='Computer'}
			'GenericWriteByUser'    {$EdgeName='GenericWrite'        ; $InputType='User'    }
			'GenericWriteByGroup'   {$EdgeName='GenericWrite'        ; $InputType='Group'   }
			'GenericWriteByComputer'{$EdgeName='GenericWrite'        ; $InputType='Computer'}
			'OwnerWriteByUser'      {$EdgeName='WriteOwner'          ; $InputType='User'    }
			'OwnerWriteByGroup'     {$EdgeName='WriteOwner'          ; $InputType='Group'   }
			'OwnerWriteByComputer'  {$EdgeName='WriteOwner'          ; $InputType='Computer'}
			'DACLWriteByUser'       {$EdgeName='WriteDACL'           ; $InputType='User'    }
			'DACLWriteByGroup'      {$EdgeName='WriteDACL'           ; $InputType='Group'   }
			'DACLWriteByComputer'   {$EdgeName='WriteDACL'           ; $InputType='Computer'}
			'TrustingDomain'        {$EdgeName='TrustedBy'           ; $InputType='Domain'  }
			}
		# Outputype
		$OutputType=$dynReturn.Value.trimEnd('s')
		# Empty Result
        $Result = @()
        }
	Process{
        foreach($Target in $DynTarget.Value){
		    # Prep Query
		    $Query ="MATCH (A:$OutputType),(B:$InputType {name: {name}}) MATCH p=(A)<-[r:$EdgeName*1..$($DynDegree.value)]-(B) RETURN A"
            $Params = @{name = "$($DynTarget.Value)"}
            # Call Dog
            if(-Not$DynCypher.IsSet){$Result += DogPost $Query -Params $Params}
            }}
    # Return Result or cypher
	End{
        # If Cypher
        if($DynCypher.IsSet){ClipThis $Query -with $Params}
        # if not, Return Result
		else{Return $Result | sort -unique}
		}}
#####End



###########################################################
##################################### BloodHound-EdgeCustom

<#
.Synopsis
   Synopsis
.DESCRIPTION
   Description
.EXAMPLE
    Example-One
#>
function BloodHound-EdgeCustom{
    [CmdletBinding()]
    [Alias('EdgeCustom')]
    Param(
        [Parameter(Mandatory=1,Position=0,ParameterSetName='ToUser')][Switch]$ToUser,
        [Parameter(Mandatory=1,Position=0,ParameterSetName='toGroup')][Switch]$ToGroup,
        [Parameter(Mandatory=1,Position=0,ParameterSetName='ToComputer')][Switch]$ToComputer,
        [Parameter(Mandatory=1,Position=0,ParameterSetName='FromUser')][Switch]$FromUser,
        [Parameter(Mandatory=1,Position=0,ParameterSetName='FromGroup')][Switch]$FromGroup,
        [Parameter(Mandatory=1,Position=0,ParameterSetName='FromComputer')][Switch]$FromComputer
        )
    DynamicParam{
        # Dico
		$Dico = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        # Vset
        If($PScmdlet.ParameterSetName -match "User")    {$Vset=$Script:CypherDog.UserList    }
        If($PScmdlet.ParameterSetName -match "Group")   {$Vset=$Script:CypherDog.GroupList   }
        If($PScmdlet.ParameterSetName -match "Computer"){$Vset=$Script:CypherDog.ComputerList}  
        # DynP
        $Dynname   = dynP -Name 'Name' -Type String -Mandat 1 -Pos 0 -Pipe 1 -PipeProp 1 -VSet $VSet 
        $DynEdge   = dynP -Name 'Edge' -Type EdgeType[] -Mandat 0 -Pos 1 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynCustom = dynP -Name 'Custom' -Type String[] -Mandat 0 -Pos 2 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynReturn = dynP -Name 'Return' -Type String -Mandat 0 -Pos 3 -Pipe 0 -PipeProp 0 -VSet @('User','Group','Computer')
        $DynMaxHop = dynP -Name 'MaxHop' -Type int -Mandat 0 -Pos 4 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynMinHop = dynP -Name 'MinHop' -Type int -Mandat 0 -Pos 5 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynCypher = dynP -Name 'Cypher' -Type Switch -Mandat 0 -Pos 6 -Pipe 0 -PipeProp 0 -VSet $Null
        # Add to Dico
        $Dico.Add('Name'  ,$dynName  )
        $Dico.Add('Edge'  ,$dynEdge  )
        $Dico.Add('Custom',$dynCustom)
        $Dico.Add('Return',$dynReturn)
        $Dico.Add('MaxHop',$dynMaxHop)
        $Dico.Add('MinHop',$dynMinHop)
        $Dico.Add('Cypher',$dynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{
        # Prep vars
        $result = @()
        $PSN = $PScmdlet.ParameterSetName
        $ReturnType = $DynReturn.Value
        $TargetName = $DynName.Value
        $TargetType = "$($PScmdlet.ParameterSetName)".replace('From','').replace('To','')
        if($DynMinHop.IsSet){$Min = $DynMinHop.Value}
        else{$Min=1}
        if($DynMaxHop.IsSet){$Max = $DynMaxHop.Value}
        else{$Max=$Null}
        if($DynEdge.IsSet){$Estr = ':' + ($DynEdge.Value -join '|:')}
        if($DynCustom.IsSet -AND -NOT$DynEdge.IsSet){
            $Estr = ':' + ([enum]::GetNames([EdgeType]) -join '|:')
            }
        if($DynCustom.IsSet){
            $Cstr = $DynCustom.Value -join '|:'
            }
        if($Estr -AND -Not$Cstr){$E = $Estr}
        if($Cstr -AND -Not$Cstr){$E = $Cstr}
        if($Estr -AND $Cstr){$E = @($Estr,$Cstr) -join '|:'} 
        # If To
        if($PSN -match '^To'){
            $Query = "MATCH (A:$ReturnType), (B:$TargetType {name: {target}}), p=(A)-[R$E*$Min..$Max]->(B) RETURN A"
            }
        # If From
        if($PSN -match '^From'){
            $Query = "MATCH (A:$ReturnType), (B:$TargetType {name: {target}}), p=(A)<-[R$E*$Min..$Max]-(B) RETURN A"
            }
        # Fix Query
        $Query = $Query.replace('|:*','*')
        }
    Process{
        # Set Params
        $Params = @{target="$TargetName"}
        # Call Dog
        if(-Not$DynCypher.IsSet){$Result += DogPost $Query -Params $Params}
        }
    # Return Result
    End{
        # Cypher
        if($DynCypher.IsSet){ClipThis $Query -with $Params}
        # Result
        else{Return $Result}
        }}
#####End


###########################################################
##################################### BloodHound-EdgeCreate

<#
.Synopsis
   Synopsis
.DESCRIPTION
   Description
.EXAMPLE
    Example-One
#>
function BloodHound-EdgeCreate{
    [CmdletBinding()]
    [Alias('EdgeCreate')]
    Param(
        # UserToUser
        [Parameter(Mandatory=1,ParameterSetName='CustomUserToUser')]
        [Parameter(Mandatory=1,ParameterSetName='RegularUserToUser')][Switch]$UserToUser,
        # UserToGroup
        [Parameter(Mandatory=1,ParameterSetName='CustomUserToGroup')]
        [Parameter(Mandatory=1,ParameterSetName='RegularUserToGroup')][Switch]$UserToGroup,
        # UserToComputer
        [Parameter(Mandatory=1,ParameterSetName='CustomUserToComputer')]
        [Parameter(Mandatory=1,ParameterSetName='RegularUserToComputer')][Switch]$UserToComputer,
        # GroupToUser
        [Parameter(Mandatory=1,ParameterSetName='CustomGroupToUser')]
        [Parameter(Mandatory=1,ParameterSetName='RegularGroupToUser')][Switch]$GroupToUser,
        # GroupToGroup
        [Parameter(Mandatory=1,ParameterSetName='CustomGroupToGroup')]
        [Parameter(Mandatory=1,ParameterSetName='RegularGroupToGroup')][Switch]$GroupToGroup,
        # GroupToComputer
        [Parameter(Mandatory=1,ParameterSetName='CustomGroupToComputer')]
        [Parameter(Mandatory=1,ParameterSetName='RegularGroupToComputer')][Switch]$GroupToComputer,
        # ComputerToUser
        [Parameter(Mandatory=1,ParameterSetName='CustomComputerToUser')]
        [Parameter(Mandatory=1,ParameterSetName='RegularComputerToUser')][Switch]$ComputerToUser,
        # ComputerToGroup
        [Parameter(Mandatory=1,ParameterSetName='CustomComputerToGroup')]
        [Parameter(Mandatory=1,ParameterSetName='RegularComputerToGroup')][Switch]$ComputerToGroup,
        # ComputerToComputer
        [Parameter(Mandatory=1,ParameterSetName='CustomComputerToComputer')]
        [Parameter(Mandatory=1,ParameterSetName='RegularComputerToComputer')][Switch]$ComputerToComputer,
        # DomainToDomain
        [Parameter(Mandatory=1,ParameterSetName='CustomDomainToDomain')]
        [Parameter(Mandatory=1,ParameterSetName='RegularDomainToDomain')][Switch]$DomainToDomain,
        # Regular Edge type
        [Parameter(Mandatory=1,ParameterSetName='RegularUserToUser')]
        [Parameter(Mandatory=1,ParameterSetName='RegularUserToGroup')]
        [Parameter(Mandatory=1,ParameterSetName='RegularUserToComputer')]
        [Parameter(Mandatory=1,ParameterSetName='RegularGroupToUser')]
        [Parameter(Mandatory=1,ParameterSetName='RegularGroupToGroup')]
        [Parameter(Mandatory=1,ParameterSetName='RegularGroupToComputer')]
        [Parameter(Mandatory=1,ParameterSetName='RegularComputerToUser')]
        [Parameter(Mandatory=1,ParameterSetName='RegularComputerToGroup')]
        [Parameter(Mandatory=1,ParameterSetName='RegularComputerToComputer')]
        [Parameter(Mandatory=1,ParameterSetName='RegularDomainToDomain')][EdgeType]$Edge,
        # Custom Edge Type
        [Parameter(Mandatory=1,ParameterSetName='CustomUserToUser')]
        [Parameter(Mandatory=1,ParameterSetName='CustomUserToGroup')]
        [Parameter(Mandatory=1,ParameterSetName='CustomUserToComputer')]
        [Parameter(Mandatory=1,ParameterSetName='CustomGroupToUser')]
        [Parameter(Mandatory=1,ParameterSetName='CustomGroupToGroup')]
        [Parameter(Mandatory=1,ParameterSetName='CustomGroupToComputer')]
        [Parameter(Mandatory=1,ParameterSetName='CustomComputerToUser')]
        [Parameter(Mandatory=1,ParameterSetName='CustomComputerToGroup')]
        [Parameter(Mandatory=1,ParameterSetName='CustomComputerToComputer')]
        [Parameter(Mandatory=1,ParameterSetName='CustomDomainToDomain')][String]$CustomEdge,
        # Cypher
        [Parameter(Mandatory=0)][Switch]$Cypher     
        )
    DynamicParam{
        $SplitPSN = $PSCmdlet.ParameterSetName.replace('Regular','').replace('Custom','').replace('To','*').split('*')
        $VSetFrom = $Script:CypherDog."$($SplitPSN[0])List"
        $VSetTo = $Script:CypherDog."$($SplitPSN[1])List"
        # Prep Dico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynP
        $DynFrom = DynP -Name 'From' -Type String -Mandat 1 -Pos 1 -Pipe 0 -PipeProp 0 -VSet $VsetFrom
        $DynTo   = DynP -Name 'To' -Type String -Mandat 1 -Pos 2 -Pipe 1 -PipeProp 1 -VSet $VsetTo
        # DynP to Dico
        $Dico.Add("From",$DynFrom)
        $Dico.add("To",$DynTo)
        # Return Dico
        Return $Dico
        }
    Begin{
        $PSN = $PSCmdlet.ParameterSetName
        if($PSN -match 'Regular'){$E=$Edge -as [string]}
        if($PSN -match 'Custom') {$E=$CustomEdge}
        $SplitPSN = $PSN.replace('Regular','').replace('Custom','').replace('To','*').split('*')
        $FromType = $SplitPSN[0]
        $ToType = $SplitPSN[1]
        $Query = "MATCH (A:$fromType) WHERE A.name = {src} MATCH (B:$ToType) WHERE B.name = {tgt} MERGE (A)-[R:$E]->(B)"
        }
    Process{
        # Set param
        $Params = @{src="$($DynFrom.Value)";tgt="$($DynTo.Value)"}
        # Clip Cypher
        if($Cypher){ClipThis $Query -with $Params}
        # or Call Dog
        else{DogPost $Query -Params $Params}
        }
    # Return Nothing
    End{<#NoOut#>}
    }
#End



###########################################################
##################################### BloodHound-EdgeDelete

<#
.Synopsis
   Synopsis
.DESCRIPTION
   Description
.EXAMPLE
    Example-One
#>
function BloodHound-EdgeDelete{
    [CmdletBinding()]
    [Alias('EdgeDelete')]
    Param(
        # UserToUser
        [Parameter(Mandatory=1,ParameterSetName='CustomUserToUser')]
        [Parameter(Mandatory=1,ParameterSetName='RegularUserToUser')][Switch]$UserToUser,
        # UserToGroup
        [Parameter(Mandatory=1,ParameterSetName='CustomUserToGroup')]
        [Parameter(Mandatory=1,ParameterSetName='RegularUserToGroup')][Switch]$UserToGroup,
        # UserToComputer
        [Parameter(Mandatory=1,ParameterSetName='CustomUserToComputer')]
        [Parameter(Mandatory=1,ParameterSetName='RegularUserToComputer')][Switch]$UserToComputer,
        # GroupToUser
        [Parameter(Mandatory=1,ParameterSetName='CustomGroupToUser')]
        [Parameter(Mandatory=1,ParameterSetName='RegularGroupToUser')][Switch]$GroupToUser,
        # GroupToGroup
        [Parameter(Mandatory=1,ParameterSetName='CustomGroupToGroup')]
        [Parameter(Mandatory=1,ParameterSetName='RegularGroupToGroup')][Switch]$GroupToGroup,
        # GroupToComputer
        [Parameter(Mandatory=1,ParameterSetName='CustomGroupToComputer')]
        [Parameter(Mandatory=1,ParameterSetName='RegularGroupToComputer')][Switch]$GroupToComputer,
        # ComputerToUser
        [Parameter(Mandatory=1,ParameterSetName='CustomComputerToUser')]
        [Parameter(Mandatory=1,ParameterSetName='RegularComputerToUser')][Switch]$ComputerToUser,
        # ComputerToGroup
        [Parameter(Mandatory=1,ParameterSetName='CustomComputerToGroup')]
        [Parameter(Mandatory=1,ParameterSetName='RegularComputerToGroup')][Switch]$ComputerToGroup,
        # ComputerToComputer
        [Parameter(Mandatory=1,ParameterSetName='CustomComputerToComputer')]
        [Parameter(Mandatory=1,ParameterSetName='RegularComputerToComputer')][Switch]$ComputerToComputer,
        # DomainToDomain
        [Parameter(Mandatory=1,ParameterSetName='CustomDomainToDomain')]
        [Parameter(Mandatory=1,ParameterSetName='RegularDomainToDomain')][Switch]$DomainToDomain,
        # Regular Edge type
        [Parameter(Mandatory=1,ParameterSetName='RegularUserToUser')]
        [Parameter(Mandatory=1,ParameterSetName='RegularUserToGroup')]
        [Parameter(Mandatory=1,ParameterSetName='RegularUserToComputer')]
        [Parameter(Mandatory=1,ParameterSetName='RegularGroupToUser')]
        [Parameter(Mandatory=1,ParameterSetName='RegularGroupToGroup')]
        [Parameter(Mandatory=1,ParameterSetName='RegularGroupToComputer')]
        [Parameter(Mandatory=1,ParameterSetName='RegularComputerToUser')]
        [Parameter(Mandatory=1,ParameterSetName='RegularComputerToGroup')]
        [Parameter(Mandatory=1,ParameterSetName='RegularComputerToComputer')]
        [Parameter(Mandatory=1,ParameterSetName='RegularDomainToDomain')][EdgeType]$Edge,
        # Custom Edge Type
        [Parameter(Mandatory=1,ParameterSetName='CustomUserToUser')]
        [Parameter(Mandatory=1,ParameterSetName='CustomUserToGroup')]
        [Parameter(Mandatory=1,ParameterSetName='CustomUserToComputer')]
        [Parameter(Mandatory=1,ParameterSetName='CustomGroupToUser')]
        [Parameter(Mandatory=1,ParameterSetName='CustomGroupToGroup')]
        [Parameter(Mandatory=1,ParameterSetName='CustomGroupToComputer')]
        [Parameter(Mandatory=1,ParameterSetName='CustomComputerToUser')]
        [Parameter(Mandatory=1,ParameterSetName='CustomComputerToGroup')]
        [Parameter(Mandatory=1,ParameterSetName='CustomComputerToComputer')]
        [Parameter(Mandatory=1,ParameterSetName='CustomDomainToDomain')][String]$CustomEdge,
        # Cypher
        [Parameter(Mandatory=0)][Switch]$Cypher      
        )
    DynamicParam{
        $SplitPSN = $PSCmdlet.ParameterSetName.replace('Regular','').replace('Custom','').replace('To','*').split('*')
        $VSetFrom = $Script:CypherDog."$($SplitPSN[0])List"
        $VSetTo   = $Script:CypherDog."$($SplitPSN[1])List"
        # Prep Dico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynP
        $DynFrom = DynP -Name 'From' -Type String -Mandat 1 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $VsetFrom
        $DynTo   = DynP -Name 'To' -Type String -Mandat 1 -Pos 2 -Pipe 0 -PipeProp 0 -VSet $VsetTo
        # DynP to Dico
        $Dico.Add("From",$DynFrom)
        $Dico.add("To",$DynTo) 
        # Return Dico
        Return $Dico
        }
    Begin{
        # PSN
        $PSN = $PSCmdlet.ParameterSetName
        # Edge String
        if($PSN -match 'Regular'){$E=$Edge -as [string]}
        if($PSN -match 'Custom') {$E=$CustomEdge}
        if($E -eq '*'){$E=$Null}
        else{$E = ':'+$E}
        # From/To Type
        $SplitPSN = $PSN.replace('Regular','').replace('Custom','').replace('To','*').split('*')
        $FromType = $SplitPSN[0]
        $ToType = $SplitPSN[1]
        # Prep Query
        $Query = "MATCH (A:$fromType) WHERE A.name = {src} MATCH (B:$ToType) WHERE B.name = {tgt} MATCH (A)-[R$E]->(B) DELETE R"
        }
    Process{
        # Set param
        $Params = @{src="$($DynFrom.Value)";tgt="$($DynTo.Value)"}
        # Call Dog or clip Cypher
        if(-Not$Cypher){DogPost $Query -Params $Params}
        Else{ClipThis $Query -with $Params}
        }
    # Return Nothing
    End{<#NoOut#>}
    }
#End



###########################################################
########################################### BloodHound-Path

<#
.Synopsis
   Bloodhound Path
.DESCRIPTION
   Retrieve Bloodhound Path
.EXAMPLE
   Path -UserToGroup -From ACHAVARIN@EXTERNAL.LOCAL -To 'DOMAIN ADMINS@INTERNAL.LOCAL'
#>
function BloodHound-Path{
    [CmdletBinding()]
    [Alias('Path')]
    Param(
        # User to Group
        [Parameter(Mandatory=1,ParameterSetname='UserToGroup')][Alias('UTG')][Switch]$UserToGroup,
        # User to User
        [Parameter(Mandatory=1,ParameterSetname='UserToUser')][Alias('UTU')][Switch]$UserToUser,
        # User to Computer
        [Parameter(Mandatory=1,ParameterSetname='UserToComputer')][Alias('UTC')][Switch]$UserToComputer,
        # Group to User
        [Parameter(Mandatory=1,ParameterSetname='GroupToUser')][Alias('GTU')][Switch]$GroupToUser,
        # Group to Group
        [Parameter(Mandatory=1,ParameterSetname='GroupToGroup')][Alias('GTG')][Switch]$GroupToGroup,
        # Group to Computer
        [Parameter(Mandatory=1,ParameterSetname='GroupToComputer')][Alias('GTC')][Switch]$GroupToComputer,
        # Computer to User
        [Parameter(Mandatory=1,ParameterSetname='ComputerToUser')][Alias('CTU')][Switch]$ComputerToUser,
        # Computer to Group
        [Parameter(Mandatory=1,ParameterSetname='ComputerToGroup')][Alias('CTG')][Switch]$ComputerToGroup,
        # Computer to computer
        [Parameter(Mandatory=1,ParameterSetname='ComputerToComputer')][Alias('CTC')][Switch]$ComputerToComputer,
        # Domain to Domain
        [Parameter(Mandatory=1,ParameterSetname='DomainToDomain')][Alias('DTD')][Switch]$DomainToDomain,
        # Exclude ACL Edges
        [Parameter(Mandatory=0)][Switch]$NoACL
        )
    DynamicParam{
        # VSets
        Switch($PSCmdlet.ParameterSetName){
            # PSN               | FROM                                   | TO                                   |
            #---------------------------------------------------------------------------------------------------|
            'UserToUser'        {$VFrom = $Script:CypherDog.UserList     ; $VTo = $Script:CypherDog.UserList    }
            'UserToGroup'       {$VFrom = $Script:CypherDog.UserList     ; $VTo = $Script:CypherDog.GroupList   }
            'UserToComputer'    {$VFrom = $Script:CypherDog.UserList     ; $VTo = $Script:CypherDog.ComputerList}
            'GroupToUser'       {$VFrom = $Script:CypherDog.GroupList    ; $VTo = $Script:CypherDog.UserList    }
            'GroupToGroup'      {$VFrom = $Script:CypherDog.GroupList    ; $VTo = $Script:CypherDog.GroupList   }
            'GroupToComputer'   {$VFrom = $Script:CypherDog.GroupList    ; $VTo = $Script:CypherDog.ComputerList}
            'ComputerToUser'    {$VFrom = $Script:CypherDog.ComputerList ; $VTo = $Script:CypherDog.UserList    }
            'ComputerToGroup'   {$VFrom = $Script:CypherDog.ComputerList ; $VTo = $Script:CypherDog.GroupList   }
            'ComputerToComputer'{$VFrom = $Script:CypherDog.ComputerList ; $VTo = $Script:CypherDog.ComputerList}
            'DomainToDomain'    {$VFrom = $Script:CypherDog.DomainList   ; $VTo = $Script:CypherDog.DomainList  }
            }
        # Dico
        $Dico = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        # DynP
        $DynFrom    = DynP -Name 'From'    -Type String     -Mandat 1 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $VFrom
        $DynTo      = DynP -Name 'To'      -Type String     -Mandat 1 -Pos 2 -Pipe 0 -PipeProp 0 -VSet $VTo
        $DynInclude = DynP -Name 'Include' -Type EdgeType[] -Mandat 0 -Pos 3 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynCustom  = DynP -Name 'Custom'  -Type String[]   -Mandat 0 -Pos 4 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynCypher  = DynP -Name 'Cypher'  -Type Switch   -Mandat 0 -Pos 5 -Pipe 0 -PipeProp 0 -VSet $Null
        # Add all Runtime Params to dictionary
        $Dico.Add('From', $DynFrom)
        $Dico.Add('To', $DynTo)
        $Dico.Add('Include',$DynInclude)
        $Dico.Add('Custom',$DynCustom)
        $Dico.Add('Cypher',$DynCypher)
        # Return Dico
        return $Dico
        }
    Begin{
        # Prep Vars
        $Result = @()
        $SplitPSN = $PSCmdlet.ParameterSetName.replace('To','*').split('*')
        $FromType = $SplitPSN[0]
        $ToType = $SplitPSN[1]
        # Prep Edge List
        $EdgeList = [enum]::GetNames([EdgeType])
        if($NoACL){$EdgeList = @('AdminTo','MemberOf','HasSession','TrustedBy')}
        if($DynInclude.Isset){$EdgeList = $DynInclude.Value}
        if($DynCustom.IsSet){$EdgeList += $DynCustom.Value}
        # No spec = any
        if(-Not$NoACL -AND -Not$DynInclude.IsSet -AND -Not$DynCustom.IsSet){$EdgeList=$Null}
        $E = $EdgeList -join '|:'
        # Prep Query
        $Query = "MATCH (A:$FromType {name: {from}}), (B:$ToType {name: {to}}), P=shortestPath((A)-[R:$E*1..]->(B)) RETURN P"
        $Query = $query.replace('[R:*1..]','[R*1..]')
        }
	Process{
        # Set Params
        $Params = @{from="$($DynFrom.Value)";to="$($DynTo.Value)"}
        # Call Dog
        if(-Not$DynCypher.IsSet){
            $Reply = DogPost $Query -Params $Params -Raw
            if($Reply.data.relationships.count -gt 0){$Result += $Reply | ToPathObj}
            }}
    # Return Result	
    End{
        if($DynCypher.IsSet){ClipThis $Query -with $Params}
        else{Return $Result}
        }
    }
#End


###########################################################
######################################## BloodHound-PathVia

<#
.Synopsis
   Bloodhound Path
.DESCRIPTION
   Retrieve Bloodhound Path
.EXAMPLE
   PathVia -UserToGroup -ViaUser -From ACHAVARIN@EXTERNAL.LOCAL -To 'DOMAIN ADMINS@INTERNAL.LOCAL' -ViaNode AMEADORS@EXTERAL.LOCAL -NoACL
#>
function BloodHound-PathVia{
    [CmdletBinding()]
    [Alias('PathVia')]
    Param(
        # User to Group
        [Parameter(Mandatory=1,ParameterSetname='UserToGroupViaComputer')]
        [Parameter(Mandatory=1,ParameterSetname='UserToGroupViaGroup')]
        [Parameter(Mandatory=1,ParameterSetname='UserToGroupViaUser')][Alias('UTG')][Switch]$UserToGroup,
        # User to User
        [Parameter(Mandatory=1,ParameterSetname='UserToUserViaComputer')]
        [Parameter(Mandatory=1,ParameterSetname='UserToUserViaGroup')]
        [Parameter(Mandatory=1,ParameterSetname='UserToUserViaUser')][Alias('UTU')][Switch]$UserToUser,
        # User to Computer
        [Parameter(Mandatory=1,ParameterSetname='UserToComputerViaComputer')]
        [Parameter(Mandatory=1,ParameterSetname='UserToComputerViaGroup')]
        [Parameter(Mandatory=1,ParameterSetname='UserToComputerViaUser')][Alias('UTC')][Switch]$UserToComputer,
        # Group to User
        [Parameter(Mandatory=1,ParameterSetname='GroupToUserViaComputer')]
        [Parameter(Mandatory=1,ParameterSetname='GroupToUserViaGroup')]
        [Parameter(Mandatory=1,ParameterSetname='GroupToUserViaUser')][Alias('GTU')][Switch]$GroupToUser,
        # Group to Group
        [Parameter(Mandatory=1,ParameterSetname='GroupToGroupViaComputer')]
        [Parameter(Mandatory=1,ParameterSetname='GroupToGroupViaGroup')]
        [Parameter(Mandatory=1,ParameterSetname='GroupToGroupViaUser')][Alias('GTG')][Switch]$GroupToGroup,
        # Group to Computer
        [Parameter(Mandatory=1,ParameterSetname='GroupToComputerViaComputer')]
        [Parameter(Mandatory=1,ParameterSetname='GroupToComputerViaGroup')]
        [Parameter(Mandatory=1,ParameterSetname='GroupToComputerViaUser')][Alias('GTC')][Switch]$GroupToComputer,
        # Computer to User
        [Parameter(Mandatory=1,ParameterSetname='ComputerToUserViaComputer')]
        [Parameter(Mandatory=1,ParameterSetname='ComputerToUserViaGroup')]
        [Parameter(Mandatory=1,ParameterSetname='ComputerToUserViaUser')][Alias('CTU')][Switch]$ComputerToUser,
        # Computer to Group
        [Parameter(Mandatory=1,ParameterSetname='ComputerToGroupViaComputer')]
        [Parameter(Mandatory=1,ParameterSetname='ComputerToGroupViaGroup')]
        [Parameter(Mandatory=1,ParameterSetname='ComputerToGroupViaUser')][Alias('CTG')][Switch]$ComputerToGroup,
        # Computer to computer
        [Parameter(Mandatory=1,ParameterSetname='ComputerToComputerViaComputer')]
        [Parameter(Mandatory=1,ParameterSetname='ComputerToComputerViaGroup')]
        [Parameter(Mandatory=1,ParameterSetname='ComputerToComputerViaUser')][Alias('CTC')][Switch]$ComputerToComputer,
      
        # Via User
        [Parameter(Mandatory=1,ParameterSetname='UserToGroupViaUser')]
        [Parameter(Mandatory=1,ParameterSetname='UserToUserViaUser')]
        [Parameter(Mandatory=1,ParameterSetname='UserToComputerViaUser')]
        [Parameter(Mandatory=1,ParameterSetname='GroupToUserViaUser')]
        [Parameter(Mandatory=1,ParameterSetname='GroupToGroupViaUser')]
        [Parameter(Mandatory=1,ParameterSetname='GroupToComputerViaUser')]
        [Parameter(Mandatory=1,ParameterSetname='ComputerToUserViaUser')]
        [Parameter(Mandatory=1,ParameterSetname='ComputerToGroupViaUser')]
        [Parameter(Mandatory=1,ParameterSetname='ComputerToComputerViaUser')][Alias('VU')][Switch]$ViaUser,
        # Via Group
        [Parameter(Mandatory=1,ParameterSetname='UserToGroupViaGroup')]
        [Parameter(Mandatory=1,ParameterSetname='UserToUserViaGroup')]
        [Parameter(Mandatory=1,ParameterSetname='UserToComputerViaGroup')]
        [Parameter(Mandatory=1,ParameterSetname='GroupToUserViaGroup')]
        [Parameter(Mandatory=1,ParameterSetname='GroupToGroupViaGroup')]
        [Parameter(Mandatory=1,ParameterSetname='GroupToComputerViaGroup')]
        [Parameter(Mandatory=1,ParameterSetname='ComputerToUserViaGroup')]
        [Parameter(Mandatory=1,ParameterSetname='ComputerToGroupViaGroup')]
        [Parameter(Mandatory=1,ParameterSetname='ComputerToComputerViaGroup')][Alias('VG')][Switch]$ViaGroup,
        # Via Computer
        [Parameter(Mandatory=1,ParameterSetname='UserToGroupViaComputer')]
        [Parameter(Mandatory=1,ParameterSetname='UserToUserViaComputer')]
        [Parameter(Mandatory=1,ParameterSetname='UserToComputerViaComputer')]
        [Parameter(Mandatory=1,ParameterSetname='GroupToUserViaComputer')]
        [Parameter(Mandatory=1,ParameterSetname='GroupToGroupViaComputer')]
        [Parameter(Mandatory=1,ParameterSetname='GroupToComputerViaComputer')]
        [Parameter(Mandatory=1,ParameterSetname='ComputerToUserViaComputer')]
        [Parameter(Mandatory=1,ParameterSetname='ComputerToGroupViaComputer')]
        [Parameter(Mandatory=1,ParameterSetname='ComputerToComputerViaComputer')][Alias('VC')][Switch]$ViaComputer,                
               
        # Exclude ACL Edges
        [Parameter(Mandatory=0)][Switch]$NoACL
        )
    DynamicParam{
        $UserList = $Script:CypherDog.UserList
        $GroupList = $Script:CypherDog.GroupList
        $ComputerList = $Script:CypherDog.ComputerList
        # VSets
        Switch($PSCmdlet.ParameterSetName){
            # PSN                          | FROM                  | TO                   | VIA                  |
            #----------------------------------------------------------------------------------------------------|
            'UserToUserViaUser'            {$VFrom = $UserList     ; $VTo = $UserList     ; $VVia = $UserList    }
            'UserToUserViaGroup'           {$VFrom = $UserList     ; $VTo = $UserList     ; $VVia = $GroupList   }
            'UserToUserViaComputer'        {$VFrom = $UserList     ; $VTo = $UserList     ; $VVia = $ComputerList}
            'UserToGroupViaUser'           {$VFrom = $UserList     ; $VTo = $GroupList    ; $VVia = $UserList    }
            'UserToGroupViaGroup'          {$VFrom = $UserList     ; $VTo = $GroupList    ; $VVia = $GroupList   }
            'UserToGroupViaComputer'       {$VFrom = $UserList     ; $VTo = $GroupList    ; $VVia = $ComputerList}
            'UserToComputerViaUser'        {$VFrom = $UserList     ; $VTo = $ComputerList ; $VVia = $UserList    }
            'UserToComputerViaGroup'       {$VFrom = $UserList     ; $VTo = $ComputerList ; $VVia = $GroupList   }
            'UserToComputerViaComputer'    {$VFrom = $UserList     ; $VTo = $ComputerList ; $VVia = $ComputerList}
            'GroupToUserViaUser'           {$VFrom = $GroupList    ; $VTo = $UserList     ; $VVia = $UserList    }
            'GroupToUserViaGroup'          {$VFrom = $GroupList    ; $VTo = $UserList     ; $VVia = $GroupList   }
            'GroupToUserViaComputer'       {$VFrom = $GroupList    ; $VTo = $UserList     ; $VVia = $ComputerList}
            'GroupToGroupViaUser'          {$VFrom = $GroupList    ; $VTo = $GroupList    ; $VVia = $UserList    }
            'GroupToGroupViaGroup'         {$VFrom = $GroupList    ; $VTo = $GroupList    ; $VVia = $GroupList   }
            'GroupToGroupViaComputer'      {$VFrom = $GroupList    ; $VTo = $GroupList    ; $VVia = $ComputerList}
            'GroupToComputerViaUser'       {$VFrom = $GroupList    ; $VTo = $ComputerList ; $VVia = $UserList    }
            'GroupToComputerViaGroup'      {$VFrom = $GroupList    ; $VTo = $ComputerList ; $VVia = $GroupList   }
            'GroupToComputerViaComputer'   {$VFrom = $GroupList    ; $VTo = $ComputerList ; $VVia = $ComputerList}
            'ComputerToUserViaUser'        {$VFrom = $ComputerList ; $VTo = $UserList     ; $VVia = $UserList    }
            'ComputerToUserViaGroup'       {$VFrom = $ComputerList ; $VTo = $UserList     ; $VVia = $GroupList   }
            'ComputerToUserViaComputer'    {$VFrom = $ComputerList ; $VTo = $UserList     ; $VVia = $ComputerList}
            'ComputerToGroupViaUser'       {$VFrom = $ComputerList ; $VTo = $GroupList    ; $VVia = $UserList    }
            'ComputerToGroupViaGroup'      {$VFrom = $ComputerList ; $VTo = $GroupList    ; $VVia = $GroupList   }
            'ComputerToGroupViaComputer'   {$VFrom = $ComputerList ; $VTo = $GroupList    ; $VVia = $ComputerList}
            'ComputerToComputerViaUser'    {$VFrom = $ComputerList ; $VTo = $ComputerList ; $VVia = $UserList    }
            'ComputerToComputerViaGroup'   {$VFrom = $ComputerList ; $VTo = $ComputerList ; $VVia = $GroupList   }
            'ComputerToComputerViaComputer'{$VFrom = $ComputerList ; $VTo = $ComputerList ; $VVia = $ComputerList}
            }
        # Dico
        $Dico = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        # DynP
        $DynFrom          = DynP -Name 'From'          -Type String     -Mandat 1 -Pos 1 -Pipe 0 -PipeProp 0 -VSet $VFrom
        $DynTo            = DynP -Name 'To'            -Type String     -Mandat 1 -Pos 2 -Pipe 0 -PipeProp 0 -VSet $VTo
        $DynVia           = DynP -Name 'ViaNode'       -Type String     -Mandat 1 -Pos 3 -Pipe 1 -PipeProp 1 -VSet $VVia
        $DynInclude       = DynP -Name 'Include'       -Type EdgeType[] -Mandat 0 -Pos 4 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynIncludeCustom = DynP -Name 'IncludeCustom' -Type String[]   -Mandat 0 -Pos 5 -Pipe 0 -PipeProp 0 -VSet $Null 
        # Add all Runtime Params to dictionary
        $Dico.Add('From', $DynFrom)
        $Dico.Add('To', $DynTo)
        $Dico.Add('ViaNode', $DynVia)
        $Dico.Add('Include',$DynInclude)
        $Dico.Add('IncludeCustom',$DynIncludeCustom)
        # Return Dico
        return $Dico
        }
    Begin{
        # Prep Vars
        $Result = @()
        $SplitPSN = $PSCmdlet.ParameterSetName.replace('To','*').replace('Via','+').split('*').split('+')
        $FromType = $SplitPSN[0]
        $ToType   = $SplitPSN[1]
        $ViaType  = $SplitPSN[2]
        # Prep Allowed Edges
        $EdgeList = [enum]::GetNames([EdgeType])
        if($NoACL){$EdgeList = @('AdminTo','MemberOf','HasSession','TrustedBy')}
        if($DynInclude.Isset){$EdgeList += $DynInclude.Value}
        if($DynIncludeCustom.IsSet){$EdgeList += $DynIncludeCustom.Value}
        $E = $EdgeList -join '|:'
        # Prep Query
        $Query1 = "MATCH (A:$FromType {name: {from}}), (B:$ViaType {name: {via}}), P=shortestPath((A)-[R:$E*1..]->(B)) RETURN P"
        $Query2 = "MATCH (A:$ViaType  {name: {via}}),  (B:$ToType {name: {to}}),   P=shortestPath((A)-[R:$E*1..]->(B)) RETURN P"
        }
	Process{
            # Set Params
            $Params1 = @{from="$($DynFrom.Value)";via="$($DynVia.Value)"}
            $Params2 = @{via="$($DynVia.Value)";to="$($DynTo.Value)"}
            # Call Dog
            $Reply1 = DogPost $Query1 -Params $Params1 -Raw
            # If both reply ok
            $Reply2 = DogPost $Query2 -Params $Params2 -Raw
            if($Reply1.data.relationships.count -gt 0 -AND $Reply2.data.relationships.count -gt 0){
                # Create single obj
                $Obj1 = $Reply1 | ToPathObj
                $Obj1Count = $Obj1.count
                $Obj2 = $Reply2 | ToPathObj
                $Obj2 | %{$_.Step += $Obj1Count}
                $Obj  = ($Obj1 + $Obj2) | Sort Step
                # Add to Result
                $Result += $Obj
                }}
    # Return Result	
    End{Return $Result|ft}
    }
#End


###########################################################
##################################### BloodHound-PathCypher

<#
.Synopsis
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    Example of how to use this cmdlet
.EXAMPLE
    Another example of how to use this cmdlet
#>
function BloodHound-PathCypher{
    [CmdletBinding()]
    [Alias('PathCypher','Cypher')]
    Param(
        # From-To Selector
        [Parameter(Mandatory=1,ParameterSetName='UserToUser')][Alias('UTU')][Switch]$UserToUser,
        [Parameter(Mandatory=1,ParameterSetName='UserToGroup')][Alias('UTG')][Switch]$UserToGroup,
        [Parameter(Mandatory=1,ParameterSetName='UserToComputer')][Alias('UTC')][Switch]$UserToComputer,
        [Parameter(Mandatory=1,ParameterSetName='GroupToUser')][Alias('GTU')][Switch]$GroupToUser,
        [Parameter(Mandatory=1,ParameterSetName='GroupToGroup')][Alias('GTG')][Switch]$GroupToGroup,
        [Parameter(Mandatory=1,ParameterSetName='GroupToComputer')][Alias('GTC')][Switch]$GroupToComputer,
        [Parameter(Mandatory=1,ParameterSetName='ComputerToUser')][Alias('CTU')][Switch]$ComputerToUser,
        [Parameter(Mandatory=1,ParameterSetName='ComputerToGroup')][Alias('CTG')][Switch]$ComputerToGroup,
        [Parameter(Mandatory=1,ParameterSetName='ComputerToComputer')][Alias('CTC')][Switch]$ComputerToComputer,
        # Wald0 Index
        [Parameter(Mandatory=1,ParameterSetName='Wald0Index')][Switch]$Wald0Index,
        # Unions
        [Parameter(Mandatory=1,ParameterSetName='UnionAB')]
        [Parameter(Mandatory=1,ParameterSetName='UnionC')][Switch]$Union,
        [Parameter(Mandatory=1,ParameterSetName='UnionAB')][String]$QueryA,
        [Parameter(Mandatory=1,ParameterSetName='UnionAB')][String]$QueryB,
        [Parameter(Mandatory=1,ParameterSetName='UnionC',ValueFromPipeline=1)][Array]$QueryCollection
        )
    DynamicParam{
        if($PScmdlet.ParameterSetName -notmatch 'Union'){
            # VSets
            Switch($PSCmdlet.ParameterSetName){
                # PSN               | FROM                                   | TO                                   |
                #---------------------------------------------------------------------------------------------------|
                'UserToUser'        {$VFrom = $Script:CypherDog.UserList     ; $VTo = $Script:CypherDog.UserList    }
                'UserToGroup'       {$VFrom = $Script:CypherDog.UserList     ; $VTo = $Script:CypherDog.GroupList   }
                'UserToComputer'    {$VFrom = $Script:CypherDog.UserList     ; $VTo = $Script:CypherDog.ComputerList}
                'GroupToUser'       {$VFrom = $Script:CypherDog.GroupList    ; $VTo = $Script:CypherDog.UserList    }
                'GroupToGroup'      {$VFrom = $Script:CypherDog.GroupList    ; $VTo = $Script:CypherDog.GroupList   }
                'GroupToComputer'   {$VFrom = $Script:CypherDog.GroupList    ; $VTo = $Script:CypherDog.ComputerList}
                'ComputerToUser'    {$VFrom = $Script:CypherDog.ComputerList ; $VTo = $Script:CypherDog.UserList    }
                'ComputerToGroup'   {$VFrom = $Script:CypherDog.ComputerList ; $VTo = $Script:CypherDog.GroupList   }
                'ComputerToComputer'{$VFrom = $Script:CypherDog.ComputerList ; $VTo = $Script:CypherDog.ComputerList}
                'Wald0Index'        {$VGrp  = $Script:CypherDog.GroupList    }
                }
            # Dico
            $Dico = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # DynP
            if($PScmdlet.ParameterSetName -eq 'Wald0Index'){
                # DynP
                $DynTarget = DynP -Name 'Group' -Type String -Mandat 0 -Pos 0 -Pipe 1 -PipeProp 1 -VSet $VGrp
                # Add to dico
                $Dico.Add('Group', $DynTarget)
                }
            else{
                # DynP
                $DynFrom     = DynP -Name 'From'    -Type String     -Mandat 1 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $VFrom
                $DynTo       = DynP -Name 'To'      -Type String     -Mandat 1 -Pos 2 -Pipe 0 -PipeProp 0 -VSet $VTo
                $DynPathType = DynP -Name 'PathType'-Type String     -Mandat 0 -Pos 3 -Pipe 0 -PipeProp 0 -VSet @('Shortest','AllShortest','All')
                $DynEdge     = DynP -Name 'Edges'   -Type EdgeType[] -Mandat 0 -Pos 4 -Pipe 0 -PipeProp 0 -VSet $Null
                $DynCustom   = DynP -Name 'Custom'  -Type String[]   -Mandat 0 -Pos 5 -Pipe 0 -PipeProp 0 -VSet $Null
                $DynMaxHop   = DynP -Name 'MaxHop'  -Type Int        -Mandat 0 -Pos 6 -Pipe 0 -PipeProp 0 -VSet $Null
                $DynReverse  = DynP -Name 'Reverse' -Type switch     -Mandat 0 -Pos 7 -Pipe 0 -PipeProp 0 -VSet $Null
                # Add to dico
                $Dico.Add('From', $DynFrom)
                $Dico.Add('To', $DynTo)
                $Dico.Add('PathType',$DynPathType)
                $Dico.Add('Edges',$DynEdge)
                $Dico.Add('Custom',$DynCustom)
                $Dico.Add('MaxHop',$DynMaxHop)
                $Dico.Add('Reverse',$DynReverse)
                }
            # Return Dico
            return $Dico
            }}
    Begin{}
    Process{
        # Wald0Index
        if($PSCmdlet.ParameterSetName -match 'Wald0Index'){
            Wald0Index "$($DynTarget.Value)"
            }
        # Union
        Elseif($PSCmdlet.ParameterSetName -match 'Union'){
            # from Collection
            if($QueryCollection){               
                $Query = $QueryCollection -join "`r`nUNION`r`n"
                }
            # Two Queries only
            else{               
                $Query = "$QueryA`r`nUNION`r`n$QueryB" 
                }}
        # Cypher
        Else{
            # Path Type
            Switch($DynPathType.Value){
                'AllShortest'{$PT='allShortestPaths'}
                'All'     {$PT=$Null}
                Default   {$PT='shortestPath'}
                }
            $Split   = $PSCmdlet.ParameterSetName.Replace('To','*').split('*')
            $SrcType = $Split[0]
            $Src     = $DynFrom.Value
            $TgtType = $Split[1]
            $tgt     = $DynTo.Value
            $MH      = $DynMaxHop.Value
            if($DynEdge.IsSet -OR $DynCustom.IsSet){
                if($DynEdge.IsSet)  {$E = @($DynEdge.Value)  -join'|:'}
                if($DynCustom.IsSet){$C = @($DynCustom.Value)-join'|:'}
                $EdgeString = ':'+ (@($E,$C)-join'|:')
                }
            if($DynReverse.IsSet){$FWD=$Null;$Rew='<'}
            else{$FWD='>';$Rew=$Null}
            $Result = "MATCH`r`n(A:$SrcType {name: '$Src'}),`r`n(B:$TgtType {name: '$Tgt'}),`r`nP=$PT((A)$REW-[r$EdgeString*1..$MH]-$FWD(B))`r`nRETURN P"
            if(-Not$PT){
                $Result = $Result.replace('((A)','(A)').replace('(B))','(B)')
                $Result = $result -replace "RETURN P","WITH P,`r`ncount(r) as rCount order by rCount desc LIMIT 10`r`nRETURN P"}
            # Set Clipboard
            $Result|Set-clipboard
            }}
    # Return Query
    End{Return $Result}
    }
#End



#endregion ################################################
###########################################################



Break #####################################################
####################################################### EOF