###########################################################

# Group List
$GroupList = @(
    <###############| NAME                                       |SID [regex]               #>
    <########################################################################################>
    [PSCustomObject]@{Name='Account Operators'                   ;SID='^S-1-5-32-548$'      }
    [PSCustomObject]@{Name='Administrators'                      ;SID='^S-1-5-32-544$'      }
    [PSCustomObject]@{Name='Allowed RODC Password Replication'   ;SID='^S-1-5-21-.*-571$'   }
    [PSCustomObject]@{Name='Backup Operators'                    ;SID='^S-1-5-32-551$'      }
    [PSCustomObject]@{Name='Certificate Service DCOM Access'     ;SID='^S-1-5-32-574$'      }
    [PSCustomObject]@{Name='Cert Publishers'                     ;SID='^S-1-5-21-.*-517$'   }
    [PSCustomObject]@{Name='Distributed DCOM Users'              ;SID='^S-1-5-32-562$'      }
    [PSCustomObject]@{Name='Domain Admins'                       ;SID='^S-1-5-21-.*-512$'   }
    [PSCustomObject]@{Name='Domain Controllers'                  ;SID='^S-1-5-21-.*-516$'   }
    [PSCustomObject]@{Name='Entreprise Admins'                   ;SID='^S-1-5-32-519$'      }#HeadOnly
    [PSCustomObject]@{Name='Event Log Readers'                   ;SID='^S-1-5-32-573$'      }
    [PSCustomObject]@{Name='Group Policy Creators Owners'        ;SID='^S-1-5-21-.*-520$'   }
    [PSCustomObject]@{Name='Hyper-V Admistrators'                ;SID='^S-1-5-32-578$'      }
    [PSCustomObject]@{Name='Pre-Windows 2000 compatible Access'  ;SID='^S-1-5-32-554$'      }
    [PSCustomObject]@{Name='Print Operators'                     ;SID='^S-1-5-32-550$'      }
    [PSCustomObject]@{Name='Protected Users'                     ;SID='^S-1-5-21-.*-525$'   }
    [PSCustomObject]@{Name='Remote Desktop Users'                ;SID='^S-1-5-32-555$'      }
    [PSCustomObject]@{Name='Schema Admins'                       ;SID='^S-1-5-32-518$'      }#HeadOnly
    [PSCustomObject]@{Name='Server Operators'                    ;SID='^S-1-5-32-549$'      }
    [PSCustomObject]@{Name='Incoming Forest Trust Builders'      ;SID='^S-1-5-32-557$'      }#HeadOnly
    [PSCustomObject]@{Name='Cryptographic Operators'             ;SID='^S-1-5-32-569$'      }
    [PSCustomObject]@{Name='Key Admins'                          ;SID='^S-1-5-21-.*-526$'   }#HeadOnly
    [PSCustomObject]@{Name='Entreprise Key Admins'               ;SID='^S-1-5-21-.*-527$'   }#HeadOnly
    )###################### Add more if needed ##############################################
    


###########################################################

# DataDog Object format
Class DataDog{
    [String]$Group
    [String]$SID
    [String]$Description
    [int]$DirectMbrCount
    [int]$NestedMbrCount
    [int]$PathCount
    [int]$UserPathCount
    [Array]$NodeWeight
    [String[]]$Cypher   
    }

###########################################################

<#
.Synopsis
   BloodHound POST
.DESCRIPTION
   DogPost $Query [$Params] [-expand <prop,prop>]
   Post Cypher Query to BH
.EXAMPLE
    $query="MATCH (n:User) RETURN n"
    DogPost $Query -Expand $Null
#>
function Send-BloodHoundPost{
    [CmdletBinding()]
    [Alias('DogPost')]
    Param(
        [Parameter(Mandatory=1)][string]$Query,
        [Parameter(Mandatory=0)][Hashtable]$Params,
        [Parameter(Mandatory=0)][Alias('x')][String[]]$Expand=@('data','data')
        )
    # Uri 
    $Uri = "http://localhost:7474/db/data/cypher"
    # Header
    $Header=@{'Accept'='application/json; charset=UTF-8';'Content-Type'='application/json'}
    # Body
    if($Params){$Body = @{params=$Params; query=$Query}|Convertto-Json}
    else{$Body = @{query=$Query}|Convertto-Json}
    # Call
    Write-Verbose "[$(Get-date -f h:m:s)] $Query"
    $Reply = Try{Invoke-RestMethod -Uri $Uri -Method Post -Headers $Header -Body $Body -verbose:$false}Catch{$Oops = $Error[0].ErrorDetails.Message}
    # Format obj
    if($Oops){Write-Warning "$((ConvertFrom-Json $Oops).message)";Return}
    if($Expand){$Expand | %{$Reply = $Reply.$_}} 
    # Output Reply
    if($Reply){Return $Reply}
    }
#End

###########################################################

<#
.Synopsis
   BloodHound DB Info
.DESCRIPTION
   Get BloodHound DB node and edge count
.EXAMPLE
   DBInfo
#>
function Get-BloodHoundDBInfo{
    [Alias('DBInfo')]
    Param()
    [PSCustomObject]@{
        Nodes     = (DogPost 'MATCH (x)          RETURN COUNT(x)' -expand Data)[0] 
        Edges     = (DogPost 'MATCH (x)-[r]->()  RETURN COUNT(r)' -expand Data)[0]
        Domains   = (DogPost 'MATCH (x:Domain)   RETURN COUNT(x)' -expand Data)[0]
        Users     = (DogPost 'MATCH (x:User)     RETURN COUNT(x)' -expand Data)[0]
        Computers = (DogPost 'MATCH (x:Computer) RETURN COUNT(x)' -expand Data)[0]
        Groups    = (DogPost 'MATCH (x:Group)    RETURN COUNT(x)' -expand Data)[0]
        OUs       = (DogPost 'MATCH (x:OU)       RETURN COUNT(x)' -expand Data)[0]
        GPOs      = (DogPost 'MATCH (x:GPO)      RETURN COUNT(x)' -expand Data)[0]
        }}
#####End

###########################################################

<#
.Synopsis
   BloodHound DataDog
.DESCRIPTION
   BloodHound node metrics on shortest path to specified target group
.EXAMPLE
   DataDog 'DOMAIN ADMINS@DOMAIN.LOCAL','BACKUP OPERATORS@DOMAIN.LOCAL'
#>
Function Invoke-DataDog{
    [Alias('DataDog')]
    Param(
        [Parameter(ValueFromPipeline=$true)][Alias('Group')][String[]]$Name,
        [Parameter()][Switch]$AllShortest
        )
    Begin{if($AllShortest){$q='allShortestPaths'}Else{$q='shortestPath'}}
    Process{
        Foreach($Obj in $Name){
            # Get Group
            $Grp = Dogpost "MATCH (g:Group {name:'$Obj'}) RETURN g" | select Name,objectsid,description
            # If Group not found
            if(-NOT $Grp.objectsid){
                Write-Warning "[$(Get-date -f h:m:s)] Group Not found: $Obj"
                }
            # If Group found
            else{
                # Name & stuff
                $SD = $Grp.objectsid
                $Nme = $Grp.Name
                $Desc = $Grp.Description
                # Direct Members
                $Cypher1   = "MATCH p=shortestPath((m:User)-[r:MemberOf*1]->(n:Group {name:'$NmE'})) RETURN COUNT(m)"
                $DirectMbr = (DogPost $Cypher1 -expand data -verbose:$False)|Select -first 1
                # Unrolled Members
                $cypher2   = "MATCH p=shortestPath((m:User)-[r:MemberOf*1..]->(n:Group {name:'$NmE'})) RETURN COUNT(m)"
                $UnrollMbr =(DogPost $Cypher2 -expand data)|Select -first 1
                # Shortest Path
                $Cypher3   = "MATCH p=$q((m:User)-[r:MemberOf|HasSession|AdminTo|AllExtendedRights|AddMember|ForceChangePassword|GenericAll|GenericWrite|Owns|WriteDacl|WriteOwner|CanRDP|ExecuteDCOM|AllowedToDelegate|ReadLAPSPassword|AddAllowedToAct|AllowedToAct*1..]->(n:Group {name:'$NmE'})) RETURN p"
                #$Cypher3   = "MATCH p=shortestPath((n:User)-[r*1..]->(u:Group{name: '$NmE'})) WHERE ALL(x in RELS(p) WHERE (TYPE(x)='MemberOf' OR x.isacl=true)) RETURN p"
                $RawData  = DogPost $Cypher3 -expand data
                # User Path Count
                $PathCount = $RawData.count
                $UserCount = ($RawData.start|sort -unique).count
                # Node Weight
                $AllNodeU = $RawData.nodes | Group  | Select name,count
                $NodeWeight = Foreach($x in $AllNodeU){
                    #  Name
                    $Obj=irm $x.Name -Verbose:$false
                    # Dist
                    $Path = $RawData | ? {$_.nodes -match $x.name} | select -first 1
                    $Step = $Path.Nodes.Count-1
                    while($Path.Nodes[$Step] -ne $x.name){$Step-=1}
                    # Calc Weight
                    $W=$X|select -expand Count
                    # Out
                    [PScustomObject]@{
                        Type     = $Obj.metadata.labels[0]
                        Name     = $Obj.data.name
                        Distance = ($Path.Nodes.Count)-$Step-1
                        Weight   = $W
                        Impact   = [Math]::Round($W/$RawData.Count*100,1)
                        }}
                $NodeWeight = $NodeWeight | sort Impact -Descending | sort Distance
                # Cypher
                $Cypher = @(
                    $Cypher1.Replace('COUNT(m)','p')
                    $Cypher1.Replace('COUNT(m)','{Type: "Direct", Name: m.name, SID: m.objectsid} as obj')
                    $Cypher2.Replace('COUNT(m)','p')
                    $Cypher2.Replace('COUNT(m)','{Type: "Nested", Name: m.name, SID: m.objectsid} as obj')
                    $Cypher3
                    $Cypher3.Replace('RETURN p','RETURN {Type: "Path", Name: m.name, SID: m.objectsid} as obj')
                    )           
                # Output DataDog Obj
                [DataDog]@{
                    Group         = $Nme
                    SID           = $SD
                    Description   = $Desc
                    DirectMbrCount= $DirectMbr
                    NestedMbrCount= $UnrollMbr
                    PathCount     = $PathCount
                    UserPathCount = $UserCount
                    NodeWeight    = $NodeWeight
                    Cypher        = $cypher
                    }}}}
    End{}###########
    }
#End

###########################################################

<#
.Synopsis
   BloodHound Watchdog
.DESCRIPTION
   Collect Path Data from default group for specified domain
.EXAMPLE
   WatchDog domain.local
#>
Function Invoke-WatchDog{
    [Alias('WatchDog')]
    [OutputType([Datadog])]
    Param(
        [Parameter()][String[]]$Domain,
        [Parameter()][Switch]$AllShortest,
        [Parameter()][String[]]$ExtraGroup
        )
    # Domain to upper
    $Domain = $Domain.ToUpper()
    ## foreach in list ##
    foreach($Obj in $GroupList){
        # Get Group
        $Grp = Dogpost "MATCH (g:Group {domain:'$Domain'}) WHERE g.objectsid =~ '(?i)$($Obj.SID)' RETURN g" | select Name,objectsid,description
        # If Group not found
        if(-NOT $Grp.objectsid){
            Write-Verbose  "[-] Group Not found: $($Obj.Name)"
            }
        # If Group found
        else{DataDog $Grp.name -AllShortest:$AllShortest}
        }
    ## If Extra ##
    if($ExtraGroup){$ExtraGroup|DataDog -AllShortest:$AllShortest}     
    }
#End

###########################################################

<#
.Synopsis
   Calc Ttl Impact - INTERNAL
.DESCRIPTION
   Calculate Total Impact from Datadog Object Collection
.EXAMPLE
   $Data | TotalImpact
#>
function TotalImpact{
    Param(
        [Parameter(Mandatory=1,ValueFromPipeline=1)][Datadog[]]$Data,
        [Parameter()][Switch]$CYpher
        )
    Begin{[Collections.ArrayList]$Collect=@()}
    Process{foreach($Obj in ($data)){$Null=$Collect.add($Obj)}}
    End{
        # If Cypher
        if($Cypher){
            $Q = ($Collect|%{$_.Cypher[4]})-join"`r`nUNION ALL`r`n"
            $Q|Set-Clipboard
            Return $Q
            }
        #Else
        Else{
            # Total Path Count
            $TtlPC=($Collect|measure -prop PathCount -sum).sum
            # Total Unique User Count
            $TtlUC= (($Collect.NodeWeight|? Type -eq User).name| Sort -Unique ).count
            # Total Object
            $Collect.NodeWeight | ? Impact -ne 100 | Group Name |%{
                $TtlW=($_.Group|Measure-object -Property Weight -sum).sum
                [PSCustomObject]@{
                    Type= $_.Group[0].type
                    Name= $_.Name
                    Hit=$_|Select -expand Count
                    Weight=$TtlW
                    Impact=[Math]::Round($TtlW/$TtlPC*100,1)
                    }
                }
            }
        }
    }
#End

###########################################################

<#
.Synopsis
   WatchDog Report
.DESCRIPTION
   DataDog/WatchDog to readable text report
.EXAMPLE
   $Data | ReportDog
   Will generate report out of Datadog objects
   $Data holds result of WatchDog/DataDog Command
#>
Function Invoke-ReportDog{
    [Alias('ReportDog')]
    Param(
        [Parameter(ValueFromPipeline=1)][DataDog[]]$Data,
        [Parameter()][String]$File,
        [Parameter()][Switch]$NoDBInfo,
        [Parameter()][Switch]$NoTotal
        )
    Begin{
        # Empty Collector
        [Collections.ArrayList]$Total=@()
        # If DB Info [Default]
        if(-Not$NoDBInfo){
            # DB Info
"##############################

------------------------------
# DB Info                    #
------------------------------
$((Get-BloodHoundDBInfo|Out-String).trim())

##############################"
        }}
    Process{
        Foreach($Obj in $Data){
            # Add to Total
            $Null=$Total.Add($Obj)
            # Output
"
##  $($Obj.group) ##

SID: $($Obj.SID)
Description:
$($Obj.description)

User Count
----------
Direct Members : $($Obj.DirectMbrCount)
Nested Members : $($Obj.NestedMbrCount-$Obj.DirectMbrCount)
Users w. Paths : $($Obj.UserPathCount)


Top10 - Impact           
--------------

$(($Obj.NodeWeight|Sort Impact -Descending |Where impact -ne 100 |Select -first 10|ft|Out-String).trim())


Top5 User - Impact           
------------------

$(($Obj.NodeWeight|? type -eq user|Sort Impact -Descending |Select -first 5|ft|Out-String).trim())


Top5 Computer - Impact           
----------------------

$(($Obj.NodeWeight|? type -eq Computer|Sort Impact -Descending |Select -first 5|ft|Out-String).trim())


Top5 Group - Impact           
-------------------

$(($Obj.NodeWeight|? type -eq Group|Sort Impact -Descending|Where impact -ne 100|Select -first 5|ft|Out-String).trim())




##############################"
        }}
    End{# If Total
        if(-Not$NoTotal){
            # Target Count
            $TC = $Total.Count
            # Total Path Count
            $PC = ($Total|measure -prop PathCount -sum).sum
            $TI = $Total|TotalImpact
"
## TOTAL IMPACT ##
------------------


Top10 User - TotalImpact [ $TC : $PC : 100 ]
------------------------

$(($TI|Where Type -eq User|Sort Impact -Descending | Select -First 10 | FT | Out-String).trim())


Top10 Computer - TotalImpact [ $TC : $PC : 100 ]
----------------------------

$(($TI|Where Type -eq Computer |Sort Impact -Descending | Select -First 10 | FT | Out-String).trim())


Top10 Group - TotalImpact [ $TC : $PC : 100 ]
-------------------------

$(($TI|Where Type -eq Group|Sort Impact -Descending | Select -First 10 | FT | Out-String).trim())


Top20 Overall - TotalImpact [ $TC : $PC : 100 ]
---------------------------

$(($TI|Sort Impact -Descending | Select -First 20 | FT | Out-String).trim())


" 
            }
        }
    }
#####End

###########################################################

<# 
## Instructions ##

# Setup
- [stop neo4j service if running]
- uncomment following in neo4j.conf and save change
#dbms.security.auth_enabled=false
[will disable auth for Localhost only]
- start neo4j service
- load watchdog.ps1

# Basic usage
-Single Group:
Datadog <groupname>

-Default Group List:
WatchDog <domainname>

-Text Report:
WatchDog <domainname> | ReportDog 

##
#>