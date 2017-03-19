 <#
.Synopsis
   Query BloodHound DataBase
.DESCRIPTION
   BloodHound API Neo4j Cypher Query
   Returns BloodHound Path|NodeList|NodeData 
.EXAMPLE
   Invoke-CypherDog -GetPath -UserToGroup -From SMULLIN@EXTERNAL.LOCAL -To 'DOMAIN ADMINS@EXTERNAL.LOCAL' | ft
   Return Shortest Path from Node X to Node Y
   
   Step StartNode                             EdgeType   Direction EndNode                              
   ---- ---------                             --------   --------- -------                              
   0    SMULLIN@EXTERNAL.LOCAL                MemberOf   ->        INFORMATIONTECHNOLOGY6@EXTERNAL.LOCAL
   1    INFORMATIONTECHNOLOGY6@EXTERNAL.LOCAL AdminTo    ->        DESKTOP40.EXTERNAL.LOCAL             
   2    DESKTOP40.EXTERNAL.LOCAL              HasSession ->        ABROOKS_A@EXTERNAL.LOCAL             
   3    ABROOKS_A@EXTERNAL.LOCAL              MemberOf   ->        DOMAIN ADMINS@EXTERNAL.LOCAL 
.EXAMPLE
   CypherDog -Path -UserToGroup -Fr SMULLIN@EXTERNAL.LOCAL -To 'DOMAIN ADMINS@EXTERNAL.LOCAL' | ft
   Same as above but a bit shorter... 
  
   Even shorter:
   PS C:\> Neo -Path -UTG SMULLIN@EXTERNAL.LOCAL 'DOMAIN ADMINS@EXTERNAL.LOCAL' | ft
.EXAMPLE
   Neo -GetPath -UTU SMULLIN@EXTERNAL.LOCAL BREYES.ADMIN@INTERNAL.LOCAL -Goofy | ft
   Retrun Path in any direction (?)

   Step StartNode                    EdgeType   Direction EndNode                     
   ---- ---------                    --------   --------- -------                     
      0 SMULLIN@EXTERNAL.LOCAL       MemberOf   ->        DOMAIN USERS@EXTERNAL.LOCAL 
      1 DOMAIN USERS@EXTERNAL.LOCAL  MemberOf   <-        PMARTIN@EXTERNAL.LOCAL      
      2 PMARTIN@EXTERNAL.LOCAL       HasSession <-        FILESERVER6.INTERNAL.LOCAL  
      3 FILESERVER6.INTERNAL.LOCAL   AdminTo    <-        DOMAIN ADMINS@INTERNAL.LOCAL
      4 DOMAIN ADMINS@INTERNAL.LOCAL MemberOf   <-        BREYES.ADMIN@INTERNAL.LOCAL
.EXAMPLE
   Invoke-CypherDog -GetUsers -MemberOf -GroupName 'DOMAIN ADMINS@EXTERNAL.LOCAL'
   Return List of Node with matching relationship to specified target Node
   (Same goes for -GetUsers & -GetComputers)
   
   ABROOKS_A@EXTERNAL.LOCAL
   ACHAVARIN@EXTERNAL.LOCAL
   BGRIFFIN@EXTERNAL.LOCAL
   BREYNOLDS_A@EXTERNAL.LOCAL
   CRATHER@EXTERNAL.LOCAL
   DEDWARDS@EXTERNAL.LOCAL
   GCABINESS@EXTERNAL.LOCAL
   KSUITS@EXTERNAL.LOCAL
   LHEDGECOCK@EXTERNAL.LOCAL
   LLIVERMORE@EXTERNAL.LOCAL
   LSPARR@EXTERNAL.LOCAL
   MLIZARRAGA@EXTERNAL.LOCAL
   MOGORMAN@EXTERNAL.LOCAL
   NYUN@EXTERNAL.LOCAL
   PCARTER_A@EXTERNAL.LOCAL
.EXAMPLE
   Neo -Users -MO 'DOMAIN ADMINS@EXTERNAL.LOCAL' -Degree 1
   Same as above, limiting Query to First Degree Relationship

   ABROOKS_A@EXTERNAL.LOCAL
   BREYNOLDS_A@EXTERNAL.LOCAL
   CRATHER@EXTERNAL.LOCAL
   DEDWARDS@EXTERNAL.LOCAL
   GCABINESS@EXTERNAL.LOCAL
   KSUITS@EXTERNAL.LOCAL
   MOGORMAN@EXTERNAL.LOCAL
   PCARTER_A@EXTERNAL.LOCAL
.EXAMPLE
   Invoke-CypherDog -GetData -UserNode -Name SMULLIN@EXTERNAL.LOCAL
   Return Data of specified Node
   Properties are expanded (Rest of Data in RawData property)

　
   name                   RawData          
   ----                   -------          
   SMULLIN@EXTERNAL.LOCAL {System.Object[]}

   
   
   Short:
   PS C:\> Neo -Data -UN SMULLIN@EXTERNAL.LOCAL

.EXAMPLE
   # The following examples can be used with the BloodHound Sample Database for Demo:
   
   # Shortest Path User to Admin Group
   PS C:\> Invoke-CypherDog -GetPath -UserToGroup -From NYUN@EXTERNAL.LOCAL -To 'DOMAIN ADMINS@INTERNAL.LOCAL' | ft
   
   # Shortest Path Computer to Computer
   PS C:\> CypherDog -Path -ComputerToComputer DESKTOP11.EXTERNAL.LOCAL MANAGEMENT7.INTERNAL.LOCAL
   
   # Shortest Path User to User
   PS C:\> Neo -Path -UTU SMULLIN@EXTERNAL.LOCAL BREYES.ADMIN@INTERNAL.LOCAL | ft
   
   # Goofy Path
   PS C:\> Neo -Path -UTU SMULLIN@EXTERNAL.LOCAL BREYES.ADMIN@INTERNAL.LOCAL -Goofy | ft
   
   # List Computers with session from target User
   PS C:\> Neo -Computers -SessionFrom AMEADORS@EXTERNAL.LOCAL
   
   # List  Users with session on target computer
   PS C:\> Neo -Users -SessionOn DESKTOP11.EXTERNAL.LOCAL
   
   # List Users Member of target Group
   PS C:\> Neo -Users -MemberOf CONTRACTINGH@INTERNAL.LOCAL
   
   # Limit to 1st degree Membership
   PS C:\> Neo -Users -MemberOf CONTRACTINGH@INTERNAL.LOCAL -DegreeMax 1
   
   # List Groups Admin to target Computer
   PS C:\> Neo -Groups -AdminTo DESKTOP11.INTERNAL.LOCAL
   
   # List Computers Admin By target Group
   PS C:\> Neo -Computers -AdminByGroup CONTRACTINGI@INTERNAL.LOCAL

   # Count 1st degree Admins to target Computer
   PS C:\> neo -Users -AdminTo DESKTOP11.EXTERNAL.LOCAL -Degree 1 -count

   # Count 2nd degree Admins to target Computer
   PS C:\> neo -Users -AdminTo DESKTOP11.EXTERNAL.LOCAL -Degree 2 -count
   
   # Get Single User Data
   PS C:\> Neo -Data -UserNode -Name AMEADORS@EXTERNAL.LOCAL
   
   # Get Single Group Data
   PS C:\> Neo -Data -GN CONTRACTINGA@INTERNAL.LOCAL
   
   # Get Single Computer Data
   PS C:\> Neo -Data -CN DESKTOP11.EXTERNAL.LOCAL

   # List Match
   PS C:\> Neo -Match (Neo -GetUsers -MemberOf FINANCE@EXTERNAL.LOCAL) -With (Neo -GetUsers -MemberOf INFORMATIONTECHNOLOGY6@EXTERNAL.LOCAL)
.EXAMPLE
   # Node Match from two Lists
   PS C:\>$Group1 = CypherDog -GetUsers -MemberOf -GroupName FINANCE@EXTERNAL.LOCAL
   PS C:\>$Group2 = CypherDog -GetUsers -MemberOf -GroupName INFORMATIONTECHNOLOGY6@EXTERNAL.LOCAL 
   PS C:\>CypherDog -FindMatch -ListA $Group1 -ListB $Group2
   
   SMULLIN@EXTERNAL.LOCAL
   
   
   Ninja Style: 
   PS C:\>Neo -Match (Neo -Users -MO FINANCE@EXTERNAL.LOCAL) (Neo -Users -MO INFORMATIONTECHNOLOGY6@EXTERNAL.LOCAL)
.EXAMPLE
   Neo -Computers -SF BREYES.ADMIN@INTERNAL.LOCAL | %{neo -data -CN $_}
   >> BloodHound PoSh Data Ninja!
.EXAMPLE
   Neo -Match (Neo -Match (Neo -Users -AT DESKTOP11.EXTERNAL.LOCAL) -with (Neo -Users -MO INFORMATIONTECHNOLOGY7@EXTERNAL.LOCAL)) -With (Neo -Users -SO NYX.EXTERNAL.LOCAL)
   
   Does any User Admin to Desktop11 & Member of InfoTech7 have a session on NYX.EXTERNAL?

   ACHAVARIN@EXTERNAL.LOCAL

　
   >> BloodHound PoSh Shaolin Data Matching Monk!
.EXAMPLE
   # Refresh $DBDog Object (Lists of Node names)
   PS C:\> Neo -FetchInfo   
   PS C:\> Neo -Refresh
.OUTPUTS
   The '-GetPath' switch returns a PSCustom Object representation of the requested Path
   The '-GetUsers','-GetGroups' ,'-GetComputer' switches return Simple Lists of Node names
   The '-GetData' switch returns a PSCustom Object representation of the targeted Node
.NOTES
   This is a tool to Query bloodhound DB.
   Requires BloodHound running on LocalHost port 7474
   (+Uncomment neo4j.conf: dbms.security.auth_enabled=false)

   For More Info on BloodHound (by @Harmj0y @_Wald0 & @CptJesus )
   visit https://github.com/BloodHoundAD/BloodHound/wiki 
.COMPONENT
   Invoke-CypherDog.ps1
.ROLE
   The Idea would be to connect BloodHound API to Empire API... <---- Work in Progress /!\
   Data returned by -GetData commands is in raw state for now.
   Can also be used by admins to quickly check themselves once in a while.
.FUNCTIONALITY
   This Cmdlet Performs Neo4j Cypher Queries against the Bloodhound Database API
   Returns Simple Node Lists or Custom Node|Path Objects
   BloodHound must be running on LocalHost
.LINK
   https://github.com/BloodHoundAD/BloodHound
.LINK
   https://github.com/BloodHoundAD/BloodHound/wiki
.LINK
   https://blog.cptjesus.com/posts/introtocypher
.LINK
   https://neo4j.com/docs/developer-manual/current/introduction/
.LINK
   https://youtu.be/k6MyxZN-NBI
#>
function Invoke-CypherDog{
    ##BINDING
    [CmdletBinding(HelpURI='https://github.com/BloodHoundAD/BloodHound',DefaultParameterSetName='NoParam')]
    [Alias('CypherDog','Neo')]
    ##PARAM
    Param(
        #Request shorthest path from Node A to Node B
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='UserToUser')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='UserToGroup')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='UserToComputer')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='GroupToUser')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='GroupToGroup')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='GroupToComputer')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='ComputerToUser')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='ComputerToGroup')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='ComputerToComputer')][Alias('Path')][Switch]$GetPath,
        
        #Request list of Users with matching relationship to target Node
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='UsersMemberOf')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='UsersAdminTo')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='UsersWithSession')][Alias('Users')][Switch]$GetUsers,
        #Request list of Groups with matching relationship to target Node
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='GroupsMemberOf')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='GroupsAdminTo')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='ParentOfUser')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='ParentOfGroup')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='ParentOfComputer')][Alias('Groups')][Switch]$GetGroups,
        #Request list of Computers with matching relationship to target Node
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='ComputersMemberOf')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='ComputersWithSession')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='AdminByUser')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='AdminByGroup')][Alias('Computers')][Switch]$GetComputers,
        #Request Data for specified Node
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='UserData')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='GroupData')]
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='ComputerData')][Alias('Data')][Switch]$GetData,
        
        #Compare Lists
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='FindMatch')][Alias('Match')][Switch]$FindMatch,
        
        #Refresh Node Lists ($DbDog)
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='Refresh')][Alias('Refresh')][Switch]$FetchInfo,
        
        #Request Path from User to Group
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='UserToGroup')][Alias('UTG')][Switch]$UserToGroup,
        #Request Path from User to User
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='UserToUser')][Alias('UTU')][Switch]$UserToUser,
        #Request Path from User to Computer
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='UserToComputer')][Alias('UTC')][Switch]$UserToComputer,
        #Request Path from Group to User
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='GroupToUser')][Alias('GTU')][Switch]$GroupToUser,
        #Request Path from Group to Group
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='GroupToGroup')][Alias('GTG')][Switch]$GroupToGroup,
        #Request Path from Group to Computer
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='GroupToComputer')][Alias('GTC')][Switch]$GroupToComputer,
        #Request Path from Computer to User
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='ComputerToUser')][Alias('CTU')][Switch]$ComputerToUser,
        #Request Path from Computer to Group
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='ComputerToGroup')][Alias('CTG')][Switch]$ComputerToGroup,
        #Request Path from Computer to computer
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='ComputerToComputer')][Alias('CTC')][Switch]$ComputerToComputer,
        
        #Request Users|Groups|Computers Member(=Children) of Group X
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='UsersMemberOf')]
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='GroupsMemberOf')]
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='ComputersMemberOf')][Alias('MO')][Switch]$MemberOf,
        #Request Users|Groups Admin to Computer X
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='UsersAdminTo')]
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='GroupsAdminTo')][Alias('AT')][Switch]$AdminTo,
        #Request Computers with Session from user X
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='ComputersWithSession')][Alias('SF')][Switch]$SessionFrom,
        #Request Groups Parent of user X
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='ParentOfUser')][Alias('PU')][Switch]$ParentOfUser,
        #Request Groups Parent of Group X
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='ParentOfGroup')][Alias('PG')][Switch]$ParentOfGroup,
        #Request Groups Parent of Computer X
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='ParentOfComputer')][Alias('PC')][Switch]$ParentOfComputer,
        #Request Computers admin by User X
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='AdminByUser')][Alias('AU')][Switch]$AdminByUser,
        #Request Computers admin by Group X
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='AdminByGroup')][Alias('AG')][Switch]$AdminByGroup,
        #Request Users with session on Computer X
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='UsersWithSession')][Alias('SO')][Switch]$SessionOn,
        #Request data for User X
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='UserData')][Alias('UN')][Switch]$UserNode,
        #Request Data for Group X
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='GroupData')][Alias('GN')][Switch]$GroupNode,
        #Request Data for Computer X
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='ComputerData')][Alias('CN')][Switch]$ComputerNode,

        # First List to Match  
        [Parameter(Position=1,Mandatory=$true,ParameterSetname='FindMatch')][Alias('List')]$ListA,
        # Second List to Match
        [Parameter(Position=2,Mandatory=$true,ParameterSetname='FindMatch')][Alias('With')]$ListB
        )
    ##DYNPARAM
    DynamicParam{
        # Get Lists for ValidateSets
        $UserList = $DBDog.User
        $GroupList = $DBDog.Group
        $ComputerList = $DBDog.Computer
        #Generate Dynamic Params for each ParamSet
        If($PSCmdlet.ParameterSetName -eq 'UserToUser'){
            ## From 
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            #$Attrib1.ParameterSetname = 'PathGroupComputer'
            $Attrib1.HelpMessage = "Enter start Node"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection     
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($UserList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('From', [String], $Collection1)
            ## To
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $true
            $Attrib2.Position = 3
            $Attrib2.HelpMessage = "Enter end Node"
            # Create AttributeCollection object for the attribute Object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection2.Add($Attrib2)
            # Add Validate Set     
            $ValidateSet2=new-object System.Management.Automation.ValidateSetAttribute($UserList)
            $Collection2.Add($ValidateSet2)
            # Create Runtime Parameter with matching attribute collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('To', [String], $Collection2)
            ## Path Style
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 4
            $Attrib3.HelpMessage = "Select Style: Goofy|Snoopy"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Add Validate Set     
            #$ValidateSet3=new-object System.Management.Automation.ValidateSetAttribute('Goofy','Snoopy')
            #$Collection3.Add($ValidateSet3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Goofy', [Switch], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('From', $dynParam1)
            $Dictionary.Add('To', $dynParam2)
            $Dictionary.Add('Goofy', $dynParam3)
            # Return Dictionary
            return $Dictionary
            }
        If($PSCmdlet.ParameterSetName -eq 'UserToGroup'){
            ## From 
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            #$Attrib1.ParameterSetname = 'PathGroupComputer'
            $Attrib1.HelpMessage = "Enter start Node"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection     
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($UserList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('From', [String], $Collection1)
            ## To
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $true
            $Attrib2.Position = 3
            $Attrib2.HelpMessage = "Enter end Node"
            # Create AttributeCollection object for the attribute Object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection2.Add($Attrib2)
            # Add Validate Set     
            $ValidateSet2=new-object System.Management.Automation.ValidateSetAttribute($GroupList)
            $Collection2.Add($ValidateSet2)
            # Create Runtime Parameter with matching attribute collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('To', [String], $Collection2)
            ## Path Style
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 4
            $Attrib3.HelpMessage = "Select Style: Goofy|Snoopy"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Add Validate Set     
            #$ValidateSet3=new-object System.Management.Automation.ValidateSetAttribute('Goofy','Snoopy')
            #$Collection3.Add($ValidateSet3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Goofy', [Switch], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('From', $dynParam1)
            $Dictionary.Add('To', $dynParam2)
            $Dictionary.Add('Goofy', $dynParam3)
            # Return Dictionary
            return $Dictionary
            }
        If($PSCmdlet.ParameterSetName -eq 'UserToComputer'){
            ## From 
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            #$Attrib1.ParameterSetname = 'PathGroupComputer'
            $Attrib1.HelpMessage = "Enter start Node"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection     
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($UserList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('From', [String], $Collection1)
            ## To
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $true
            $Attrib2.Position = 3
            $Attrib2.HelpMessage = "Enter end Node"
            # Create AttributeCollection object for the attribute Object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection2.Add($Attrib2)
            # Add Validate Set     
            $ValidateSet2=new-object System.Management.Automation.ValidateSetAttribute($ComputerList)
            $Collection2.Add($ValidateSet2)
            # Create Runtime Parameter with matching attribute collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('To', [String], $Collection2)
            ## Path Style
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 4
            $Attrib3.HelpMessage = "Select Style: Goofy|Snoopy"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Add Validate Set     
            $ValidateSet3=new-object System.Management.Automation.ValidateSetAttribute('Goofy','Snoopy')
            $Collection3.Add($ValidateSet3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Style', [String], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('From', $dynParam1)
            $Dictionary.Add('To', $dynParam2)
            $Dictionary.Add('Style', $dynParam3)
            # Return Dictionary
            return $Dictionary
            }
        If($PSCmdlet.ParameterSetName -eq 'GroupToUser'){
            ## From 
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            #$Attrib1.ParameterSetname = 'PathGroupComputer'
            $Attrib1.HelpMessage = "Enter start Node"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection     
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($GroupList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('From', [String], $Collection1)
            ## To
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $true
            $Attrib2.Position = 3
            $Attrib2.HelpMessage = "Enter end Node"
            # Create AttributeCollection object for the attribute Object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection2.Add($Attrib2)
            # Add Validate Set     
            $ValidateSet2=new-object System.Management.Automation.ValidateSetAttribute($UserList)
            $Collection2.Add($ValidateSet2)
            # Create Runtime Parameter with matching attribute collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('To', [String], $Collection2)
            ## Path Style
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 4
            $Attrib3.HelpMessage = "Select Style: Goofy|Snoopy"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Add Validate Set     
            $ValidateSet3=new-object System.Management.Automation.ValidateSetAttribute('Goofy','Snoopy')
            $Collection3.Add($ValidateSet3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Style', [String], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('From', $dynParam1)
            $Dictionary.Add('To', $dynParam2)
            $Dictionary.Add('Style', $dynParam3)
            # Return Dictionary
            return $Dictionary
            }
        If($PSCmdlet.ParameterSetName -eq 'GroupToGroup'){
            ## From 
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            #$Attrib1.ParameterSetname = 'PathGroupComputer'
            $Attrib1.HelpMessage = "Enter start Node"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection     
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($GroupList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('From', [String], $Collection1)
            ## To
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $true
            $Attrib2.Position = 3
            $Attrib2.HelpMessage = "Enter end Node"
            # Create AttributeCollection object for the attribute Object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection2.Add($Attrib2)
            # Add Validate Set     
            $ValidateSet2=new-object System.Management.Automation.ValidateSetAttribute($GroupList)
            $Collection2.Add($ValidateSet2)
            # Create Runtime Parameter with matching attribute collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('To', [String], $Collection2)
            ## Path Style
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 4
            $Attrib3.HelpMessage = "Select Style: Goofy|Snoopy"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Add Validate Set     
            $ValidateSet3=new-object System.Management.Automation.ValidateSetAttribute('Goofy','Snoopy')
            $Collection3.Add($ValidateSet3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Style', [String], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('From', $dynParam1)
            $Dictionary.Add('To', $dynParam2)
            $Dictionary.Add('Style', $dynParam3)
            # Return Dictionary
            return $Dictionary
            }
        If($PSCmdlet.ParameterSetName -eq 'GroupToComputer'){
            ## From 
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            #$Attrib1.ParameterSetname = 'PathGroupComputer'
            $Attrib1.HelpMessage = "Enter start Node"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection     
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($GroupList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('From', [String], $Collection1)
            ## To
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $true
            $Attrib2.Position = 3
            $Attrib2.HelpMessage = "Enter end Node"
            # Create AttributeCollection object for the attribute Object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection2.Add($Attrib2)
            # Add Validate Set     
            $ValidateSet2=new-object System.Management.Automation.ValidateSetAttribute($ComputerList)
            $Collection2.Add($ValidateSet2)
            # Create Runtime Parameter with matching attribute collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('To', [String], $Collection2)
            ## Path Style
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 3
            $Attrib3.HelpMessage = "Select Style: Goofy|Snoopy"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Add Validate Set     
            $ValidateSet3=new-object System.Management.Automation.ValidateSetAttribute('Goofy','Snoopy')
            $Collection3.Add($ValidateSet3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Style', [String], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('From', $dynParam1)
            $Dictionary.Add('To', $dynParam2)
            $Dictionary.Add('Style', $dynParam3)
            # Return Dictionary
            return $Dictionary
            }
        If($PSCmdlet.ParameterSetName -eq 'ComputerToUser'){
            ## From 
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            #$Attrib1.ParameterSetname = 'PathGroupComputer'
            $Attrib1.HelpMessage = "Enter start Node"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection     
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($ComputerList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('From', [String], $Collection1)
            ## To
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $true
            $Attrib2.Position = 3
            $Attrib2.HelpMessage = "Enter end Node"
            # Create AttributeCollection object for the attribute Object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection2.Add($Attrib2)
            # Add Validate Set     
            $ValidateSet2=new-object System.Management.Automation.ValidateSetAttribute($UserList)
            $Collection2.Add($ValidateSet2)
            # Create Runtime Parameter with matching attribute collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('To', [String], $Collection2)
            ## Path Style
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 3
            $Attrib3.HelpMessage = "Select Style: Goofy|Snoopy"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Add Validate Set     
            $ValidateSet3=new-object System.Management.Automation.ValidateSetAttribute('Goofy','Snoopy')
            $Collection3.Add($ValidateSet3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Style', [String], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('From', $dynParam1)
            $Dictionary.Add('To', $dynParam2)
            $Dictionary.Add('Style', $dynParam3)
            # Return Dictionary
            return $Dictionary
            }
        If($PSCmdlet.ParameterSetName -eq 'ComputerToGroup'){
            ## From 
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            #$Attrib1.ParameterSetname = 'PathGroupComputer'
            $Attrib1.HelpMessage = "Enter start Node"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection     
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($ComputerList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('From', [String], $Collection1)
            ## To
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $true
            $Attrib2.Position = 3
            $Attrib2.HelpMessage = "Enter end Node"
            # Create AttributeCollection object for the attribute Object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection2.Add($Attrib2)
            # Add Validate Set     
            $ValidateSet2=new-object System.Management.Automation.ValidateSetAttribute($GroupList)
            $Collection2.Add($ValidateSet2)
            # Create Runtime Parameter with matching attribute collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('To', [String], $Collection2)
            ## Path Style
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 4
            $Attrib3.HelpMessage = "Select Style: Goofy|Snoopy"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Add Validate Set     
            #$ValidateSet3=new-object System.Management.Automation.ValidateSetAttribute('Goofy','Snoopy')
            #$Collection3.Add($ValidateSet3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Goofy', [Switch], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('From', $dynParam1)
            $Dictionary.Add('To', $dynParam2)
            $Dictionary.Add('Goofy', $dynParam3)
            # Return Dictionary
            return $Dictionary
            }
        If($PSCmdlet.ParameterSetName -eq 'ComputerToComputer'){
            ## From 
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            $Attrib1.HelpMessage = "Enter start Node"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection     
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($ComputerList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('From', [String], $Collection1)
            ## To
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $true
            $Attrib2.Position = 3
            $Attrib2.HelpMessage = "Enter end Node"
            # Create AttributeCollection object for the attribute Object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection2.Add($Attrib2)
            # Add Validate Set     
            $ValidateSet2=new-object System.Management.Automation.ValidateSetAttribute($ComputerList)
            $Collection2.Add($ValidateSet2)
            # Create Runtime Parameter with matching attribute collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('To', [String], $Collection2)
            ## Path Style
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 4
            $Attrib3.HelpMessage = "Select Style: Goofy|Snoopy"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Goofy', [Switch], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('From', $dynParam1)
            $Dictionary.Add('To', $dynParam2)
            $Dictionary.Add('Goofy', $dynParam3)
            # Return Dictionary
            return $Dictionary
            }
        If($PSCmdlet.ParameterSetName -eq 'UsersMemberOf'){
            ## Group
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            $Attrib1.HelpMessage = "Enter target Group Name"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($GroupList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('GroupName', [String], $Collection1)
            ## DegreeMax
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $false
            $Attrib2.Position = 3
            $Attrib2.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection2.Add($Attrib2)
            # Create Runtime Parameter with matching attribute collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('DegreeMax', [UInt16], $Collection2)
            ## Count
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 4
            $Attrib3.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Count', [Switch], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('GroupName', $dynParam1)
            $Dictionary.Add('DegreeMax', $dynParam2)
            $Dictionary.Add('Count',$dynParam3)
            # Return Dictionary
            return $Dictionary
            }
        If($PSCmdlet.ParameterSetName -eq 'GroupsMemberOf'){
            ## Group
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            $Attrib1.HelpMessage = "Enter target Group Name"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($GroupList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('GroupName', [String], $Collection1)
            ## DegreeMax
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $false
            $Attrib2.Position = 3
            $Attrib2.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection2.Add($Attrib2)
            # Create Runtime Parameter with matching attribute collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('DegreeMax', [UInt16], $Collection2)
            ## Count
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 4
            $Attrib3.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Count', [Switch], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('GroupName', $dynParam1)
            $Dictionary.Add('DegreeMax', $dynParam2)
            $Dictionary.Add('Count', $dynParam3)
            # Return Dictionary
            return $Dictionary
            }
        If($PSCmdlet.ParameterSetName -eq 'ComputersMemberOf'){
            ## Group
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            $Attrib1.HelpMessage = "Enter target Group Name"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($GroupList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('GroupName', [String], $Collection1)
            ## DegreeMax
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $false
            $Attrib2.Position = 3
            $Attrib2.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection2.Add($Attrib2)
            # Create Runtime Parameter with matching attribute collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('DegreeMax', [UInt16], $Collection2)
            ## Count
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 4
            $Attrib3.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Count', [Switch], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('GroupName', $dynParam1)
            $Dictionary.Add('DegreeMax', $dynParam2)
            $Dictionary.Add('Count', $dynParam3)
            # Return Dictionary
            return $Dictionary
            }      
        If($PSCmdlet.ParameterSetName -eq 'UsersAdminTo'){
            ## Computer
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            $Attrib1.HelpMessage = "Enter target Computer Name"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($ComputerList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('ComputerName', [String], $Collection1)
            ## DegreeMax
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $false
            $Attrib2.Position = 3
            $Attrib2.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection2.Add($Attrib2)
            # Create Runtime Parameter with matching attribute collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('DegreeMax', [UInt16], $Collection2)
            ## Count
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 4
            $Attrib3.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Count', [Switch], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('ComputerName', $dynParam1)
            $Dictionary.Add('DegreeMax', $dynParam2)
            $Dictionary.Add('Count', $dynParam3)
            # Return Dictionary
            return $Dictionary
            }
        If($PSCmdlet.ParameterSetName -eq 'GroupsAdminTo'){
            ## Computer
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            $Attrib1.HelpMessage = "Enter target Computer Name"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($ComputerList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('ComputerName', [String], $Collection1)
            ## DegreeMax
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $false
            $Attrib2.Position = 3
            $Attrib2.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection2.Add($Attrib2)
            # Create Runtime Parameter with matching attribute collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('DegreeMax', [UInt16], $Collection2)
            ## Count
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 4
            $Attrib3.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Count', [Switch], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('ComputerName', $dynParam1)
            $Dictionary.Add('DegreeMax', $dynParam2)
            $Dictionary.Add('Count', $dynParam3)
            # Return Dictionary
            return $Dictionary
            }
        If($PSCmdlet.ParameterSetName -eq 'ComputersWithSession'){
            ## User
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            $Attrib1.HelpMessage = "Enter target User Name"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($UserList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('UserName', [String], $Collection1)
            ## Count
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 3
            $Attrib3.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Count', [Switch], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('UserName', $dynParam1)
            $Dictionary.Add('Count', $dynParam3)
            # Return Dictionary
            return $Dictionary
            }
        If($PSCmdlet.ParameterSetName -eq 'ParentOfUser'){
            ## User
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            $Attrib1.HelpMessage = "Enter target User Name"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($UserList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('UserName', [String], $Collection1)
            ## DegreeMax
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $false
            $Attrib2.Position = 3
            $Attrib2.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection2.Add($Attrib2)
            # Create Runtime Parameter with matching attribute collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('DegreeMax', [UInt16], $Collection2)
            ## Count
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 4
            $Attrib3.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Count', [Switch], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('UserName', $dynParam1)
            $Dictionary.Add('DegreeMax', $dynParam2)
            $Dictionary.Add('Count', $dynParam3)
            # Return Dictionary
            return $Dictionary
            }
        If($PSCmdlet.ParameterSetName -eq 'ParentOfGroup'){
            ## Group
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            $Attrib1.HelpMessage = "Enter target Group Name"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($GroupList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('GroupName', [String], $Collection1)
            ## DegreeMax
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $false
            $Attrib2.Position = 3
            $Attrib2.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection2.Add($Attrib2)
            # Create Runtime Parameter with matching attribute collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('DegreeMax', [UInt16], $Collection2)
            ## Count
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 4
            $Attrib3.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Count', [Switch], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('GroupName', $dynParam1)
            $Dictionary.Add('DegreeMax', $dynParam2)
            $Dictionary.Add('Count', $dynParam3)
            # Return Dictionary
            return $Dictionary          
            }
        If($PSCmdlet.ParameterSetName -eq 'ParentOfComputer'){
            ## Computer
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            $Attrib1.HelpMessage = "Enter target Computer Name"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($ComputerList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('ComputerName', [String], $Collection1)
            ## DegreeMax
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $false
            $Attrib2.Position = 3
            $Attrib2.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection2.Add($Attrib2)
            # Create Runtime Parameter with matching attribute collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('DegreeMax', [UInt16], $Collection2)
            ## Count
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 4
            $Attrib3.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Count', [Switch], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('ComputerName', $dynParam1)
            $Dictionary.Add('DegreeMax', $dynParam2)
            $Dictionary.Add('Count', $dynParam3)
            # Return Dictionary
            return $Dictionary
            }    
        If($PSCmdlet.ParameterSetName -eq 'AdminByUser'){
            ## User
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            $Attrib1.HelpMessage = "Enter target User Name"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($UserList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('UserName', [String], $Collection1)
            ## DegreeMax
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $false
            $Attrib2.Position = 3
            $Attrib2.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection2.Add($Attrib2)
            # Create Runtime Parameter with matching attribute collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('DegreeMax', [UInt16], $Collection2)
            ## Count
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 4
            $Attrib3.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Count', [Switch], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('UserName', $dynParam1)
            $Dictionary.Add('DegreeMax', $dynParam2)
            $Dictionary.Add('Count', $dynParam3)
            # Return Dictionary
            return $Dictionary           
            }
        If($PSCmdlet.ParameterSetName -eq 'AdminByGroup'){
            ## Group
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            $Attrib1.HelpMessage = "Enter target Group Name"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($GroupList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('GroupName', [String], $Collection1)
            ## DegreeMax
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $false
            $Attrib2.Position = 3
            $Attrib2.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection2.Add($Attrib2)
            # Create Runtime Parameter with matching attribute collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('DegreeMax', [UInt16], $Collection2)
            ## Count
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 4
            $Attrib3.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Count', [Switch], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('GroupName', $dynParam1)
            $Dictionary.Add('DegreeMax', $dynParam2)
            $Dictionary.Add('Count', $dynParam3)
            # Return Dictionary
            return $Dictionary
            }
        If($PSCmdlet.ParameterSetName -eq 'UsersWithSession'){
            ## Computer
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            $Attrib1.HelpMessage = "Enter target Computer Name"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($ComputerList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('ComputerName', [String], $Collection1)
            ## Count
            # Create Attribute Object
            $Attrib3 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib3.Mandatory = $false
            $Attrib3.Position = 3
            $Attrib3.HelpMessage = "Enter Relationship Max Degree"
            # Create AttributeCollection object for the attribute Object
            $Collection3 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute
            $Collection3.Add($Attrib3)
            # Create Runtime Parameter with matching attribute collection
            $DynParam3 = New-Object System.Management.Automation.RuntimeDefinedParameter('Count', [Switch], $Collection3)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('ComputerName', $dynParam1)
            $Dictionary.Add('Count', $dynParam3)
            # Return Dictionary
            return $Dictionary
            }
        If($PSCmdlet.ParameterSetName -eq 'UserData'){
            ## User
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            $Attrib1.HelpMessage = "Enter target User Name"
            #$Attrib1.ValueFromPipeline=$true
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($UserList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [String], $Collection1)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('Name', $dynParam1)
            # Return Dictionary
            return $Dictionary  
            }
        If($PSCmdlet.ParameterSetName -eq 'GroupData'){
            ## Group
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            $Attrib1.HelpMessage = "Enter target Group Name"
            #$Attrib1.ValueFromPipeline=$true
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($GroupList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [String], $Collection1)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('Name', $dynParam1)
            # Return Dictionary
            return $Dictionary
            }
        If($PSCmdlet.ParameterSetName -eq 'ComputerData'){
            ## Computer
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 2
            $Attrib1.HelpMessage = "Enter target Computer Name"
            #$Attrib1.ValueFromPipeline=$true
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($ComputerList)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [String], $Collection1)
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Add all Runtime Params to dictionary
            $Dictionary.Add('Name', $dynParam1)
            # Return Dictionary
            return $Dictionary
            }
        }
    ##BEGINBLOCK
    Begin{
        # Prepare API Cypher Query
        $addr = 'http://localhost:7474/db/data/cypher'
        $head = @{"Accept"="application/json; charset=UTF-8";"Content-Type"="application/json"}

        Write-Verbose "ParameterSetName: $($PSCmdlet.ParameterSetName)"
        # If No param, show syntax
        if($PSCmdlet.ParameterSetName -eq 'NoParam'){
            (Help Invoke-CypherDog).syntax
            "For Help:`r`nPS C:\> Get-Help CypherDog -Full"
            "`r`nFor Examples:`r`nPS C:\> Help Neo -Examples"
            Break
            }

        ##PATH
        # Path User to User
        If($PSCmdlet.ParameterSetName -eq 'UserToUser'){
            $Query = "MATCH (A:User {name: {ParamA}}), (B:User {name: {ParamB}}), x=shortestPath((A)-[*1..]->(B)) RETURN x"
            if($DynParam3.Value -eq $true){$Query = "MATCH (A:User {name: {ParamA}}), (B:User {name: {ParamB}}), x=shortestPath((A)-[*1..]-(B)) RETURN x"}
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamA`" : `"$($DynParam1.value)`", `"ParamB`" : `"$($DynParam2.value)`" }}"
            }
        # Path User to Group
        If($PSCmdlet.ParameterSetName -eq 'UserToGroup'){
            $Query = "MATCH (A:User {name: {ParamA}}), (B:Group {name: {ParamB}}), x=shortestPath((A)-[*1..]->(B)) RETURN x"
            if($DynParam3.Value -eq $true){$Query = "MATCH (A:User {name: {ParamA}}), (B:Group {name: {ParamB}}), x=shortestPath((A)-[*1..]-(B)) RETURN x"}
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamA`" : `"$($DynParam1.value)`", `"ParamB`" : `"$($DynParam2.value)`" }}"
            }
        # Path User to Computer
        If($PSCmdlet.ParameterSetName -eq 'UserToComputer'){
            $Query = "MATCH (A:User {name: {ParamA}}), (B:Computer {name: {ParamB}}), x=shortestPath((A)-[*1..]->(B)) RETURN x"
            if($DynParam3.Value -eq $true){$Query = "MATCH (A:User {name: {ParamA}}), (B:Computer {name: {ParamB}}), x=shortestPath((A)-[*1..]-(B)) RETURN x"}
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamA`" : `"$($DynParam1.value)`", `"ParamB`" : `"$($DynParam2.value)`" }}"           
            }
        # Path Group to User
        If($PSCmdlet.ParameterSetName -eq 'GroupToUser'){
            $Query = "MATCH (A:Group {name: {ParamA}}), (B:User {name: {ParamB}}), x=shortestPath((A)-[*1..]->(B)) RETURN x"
            if($DynParam3.Value -eq $true){$Query = "MATCH (A:Group {name: {ParamA}}), (B:User {name: {ParamB}}), x=shortestPath((A)-[*1..]-(B)) RETURN x"}
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamA`" : `"$($DynParam1.value)`", `"ParamB`" : `"$($DynParam2.value)`" }}"   
            }
        # Path Group to Group
        If($PSCmdlet.ParameterSetName -eq 'GroupToGroup'){
            $Query = "MATCH (A:Group {name: {ParamA}}), (B:Group {name: {ParamB}}), x=shortestPath((A)-[*1..]->(B)) RETURN x"
            if($DynParam3.Value -eq $true){$Query = "MATCH (A:Group {name: {ParamA}}), (B:Group {name: {ParamB}}), x=shortestPath((A)-[*1..]-(B)) RETURN x"}
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamA`" : `"$($DynParam1.value)`", `"ParamB`" : `"$($DynParam2.value)`" }}"   
            }
        # Path Group to Computer
        If($PSCmdlet.ParameterSetName -eq 'GroupToComputer'){
            $Query = "MATCH (A:Group {name: {ParamA}}), (B:Computer {name: {ParamB}}), x=shortestPath((A)-[*1..]->(B)) RETURN x"
            if($DynParam3.Value -eq $true){$Query = "MATCH (A:Group {name: {ParamA}}), (B:Computer {name: {ParamB}}), x=shortestPath((A)-[*1..]-(B)) RETURN x"}
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamA`" : `"$($DynParam1.value)`", `"ParamB`" : `"$($DynParam2.value)`" }}"   
            }
        # Path Computer to User
        If($PSCmdlet.ParameterSetName -eq 'ComputerToUser'){
            $Query = "MATCH (A:Computer {name: {ParamA}}), (B:User {name: {ParamB}}), x=shortestPath((A)-[*1..]->(B)) RETURN x"
            if($DynParam3.Value -eq $true){$Query = "MATCH (A:Computer {name: {ParamA}}), (B:User {name: {ParamB}}), x=shortestPath((A)-[*1..]-(B)) RETURN x"}
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamA`" : `"$($DynParam1.value)`", `"ParamB`" : `"$($DynParam2.value)`" }}"
            }
        # Path Computer to Group
        If($PSCmdlet.ParameterSetName -eq 'ComputerToGroup'){
            $Query = "MATCH (A:Computer {name: {ParamA}}), (B:Group {name: {ParamB}}), x=shortestPath((A)-[*1..]->(B)) RETURN x"
            if($DynParam3.Value -eq $true){$Query = "MATCH (A:Computer {name: {ParamA}}), (B:User {name: {ParamB}}), x=shortestPath((A)-[*1..]-(B)) RETURN x"}
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamA`" : `"$($DynParam1.value)`", `"ParamB`" : `"$($DynParam2.value)`" }}"   
            }
        # Path Computer to Computer
        If($PSCmdlet.ParameterSetName -eq 'ComputerToComputer'){
            $Query = "MATCH (A:Computer {name: {ParamA}}), (B:Computer {name: {ParamB}}), x=shortestPath((A)-[*1..]->(B)) RETURN x"
            if($DynParam3.value -eq $true){$Query = "MATCH (A:Computer {name: {ParamA}}), (B:Computer {name: {ParamB}}), x=shortestPath((A)-[*1..]-(B)) RETURN x"}
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamA`" : `"$($DynParam1.value)`", `"ParamB`" : `"$($DynParam2.value)`" }}"   
            }
        
        ## LIST
        # Users Member Of Group X
        If($PSCmdlet.ParameterSetName -eq 'UsersMemberOf'){
            $Query = "MATCH (A:User),(B:Group {name: {ParamB}}) MATCH p=(A)-[r:MemberOf*1..$($DynParam2.value)]->(B) RETURN A"
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamB`" : `"$($DynParam1.value)`" }}" 
            } 
        # Groups Member Of Group X
        If($PSCmdlet.ParameterSetName -eq 'GroupsMemberOf'){
            $Query = "MATCH (A:Group),(B:Group {name: {ParamB}}) MATCH p=(A)-[r:MemberOf*1..$($DynParam2.value)]->(B) RETURN A"
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamB`" : `"$($DynParam1.value)`" }}" 
            }
        # Computers Member Of Group X
        If($PSCmdlet.ParameterSetName -eq 'ComputersMemberOf'){
            $Query = "MATCH (A:Computer),(B:Group {name: {ParamB}}) MATCH p=(A)-[r:MemberOf*1..$($DynParam2.value)]->(B) RETURN A"
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamB`" : `"$($DynParam1.value)`" }}" 
            }   
        # Users Admin to Computer X  (Users>Groups>Computer)
        If($PSCmdlet.ParameterSetName -eq 'UsersAdminTo'){
            $Query = "MATCH (A:Group),(B:Computer {name: {ParamB}}) MATCH p=(A)-[r:AdminTo*1..1]->(B) RETURN A"
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamB`" : `"$($DynParam1.value)`" }}"            
            }
        # Groups admin to computer X
        If($PSCmdlet.ParameterSetName -eq 'GroupsAdminTo'){
            $Query = "MATCH (A:Group),(B:Computer {name: {ParamB}}) MATCH p=(A)-[r:AdminTo*1..$($DynParam2.value)]->(B) RETURN A"
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamB`" : `"$($DynParam1.value)`" }}"               
            }
        # Computers with Session user X
        If($PSCmdlet.ParameterSetName -eq 'ComputersWithSession'){
            $Query = "MATCH (A:Computer),(B:User {name: {ParamB}}) MATCH p=(A)-[r:HasSession]->(B) RETURN A"
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamB`" : `"$($DynParam1.value)`" }}"            
            }
        # Groups Parent of User X
        If($PSCmdlet.ParameterSetName -eq 'ParentOfUser'){
            $Query = "MATCH (A:Group),(B:User {name: {ParamB}}) MATCH p=(A)<-[r:MemberOf*1..$($DynParam2.value)]-(B) RETURN A"
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamB`" : `"$($DynParam1.value)`" }}"             
            }
        # Groups Parent of Group X
        If($PSCmdlet.ParameterSetName -eq 'ParentOfGroup'){
             $Query = "MATCH (A:Group),(B:Group {name: {ParamB}}) MATCH p=(A)<-[r:MemberOf*1..$($DynParam2.value)]-(B) RETURN A"
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamB`" : `"$($DynParam1.value)`" }}"            
            }
        # Groups Parent of Computer X
        If($PSCmdlet.ParameterSetName -eq 'ParentOfComputer'){
            $Query = "MATCH (A:Group),(B:Computer {name: {ParamB}}) MATCH p=(A)<-[r:MemberOf*1..$($DynParam2.value)]-(B) RETURN A"
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamB`" : `"$($DynParam1.value)`" }}"             
            }    
        # Computers Admin By User X (Computers>Groups>Users)
        If($PSCmdlet.ParameterSetName -eq 'AdminByUser'){
            $Query = "MATCH (A:Group),(B:User {name: {ParamB}}) MATCH p=(A)<-[r:MemberOf*1..$($DynParam2.value)]-(B) RETURN A"
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamB`" : `"$($DynParam1.value)`" }}"              
            }
        # Computers Admin By Group X
        If($PSCmdlet.ParameterSetName -eq 'AdminByGroup'){
            $Query = "MATCH (A:Computer),(B:Group {name: {ParamB}}) MATCH p=(A)<-[r:AdminTo*0..$($DynParam2.value)]-(B) RETURN A"
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamB`" : `"$($DynParam1.value)`" }}"              
            }
        # Users with Session on computer X
        If($PSCmdlet.ParameterSetName -eq 'UsersWithSession'){
            $Query = "MATCH (A:User),(B:Computer {name: {ParamB}}) MATCH p=(A)<-[r:HasSession]-(B) RETURN A"
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamB`" : `"$($DynParam1.value)`" }}"              
            }
        
        ## DATA
        # If User Data
        If($PSCmdlet.ParameterSetName -eq 'UserData'){
            $Query = "MATCH (A:User {name: {ParamA}}) RETURN A"
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamA`" : `"$($DynParam1.value)`" }}"            
            }
        # If Group Data
        If($PSCmdlet.ParameterSetName -eq 'GroupData'){
            $Query = "MATCH (A:Group {name: {ParamA}}) RETURN A"
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamA`" : `"$($DynParam1.value)`" }}"             
            }
        # If Computer Data
        If($PSCmdlet.ParameterSetName -eq 'ComputerData'){
            $Query = "MATCH (A:Computer {name: {ParamA}}) RETURN A"
            $Body = "{`"query`" : `"$Query`",`"params`" : { `"ParamA`" : `"$($DynParam1.value)`" }}"             
            }
        }
    #PROCESSBLOCK
    Process{
        #If refresh
        If($PSCmdlet.ParameterSetName -eq 'Refresh'){
            $Script:DBDog = New-Object PSCustomObject
            write-verbose "Fetching Node Names"
            #For Each Item
            'User','Group','Computer','Domain' |%{
                Write-Verbose "NodeType: $_"
                #Prep Query
                $Body = "{`"query`":`"MATCH (X:$_) RETURN X`"}"
                Write-Verbose "Body: $Body"
                #Query BloodHound DB
                $Results = Invoke-restmethod -Uri $addr -Method Post -Headers $head -body $Body
                # Set DBDog Prop
                $Script:DBDog | Add-Member –MemberType NoteProperty -Name "$_" -Value ($Results.data.data.name | sort -Unique)
                }
            $FinalObj =  $script:DBDog       
            }
        IF($PSCmdlet.ParameterSetName -eq 'FindMatch'){
            Write-Verbose "List 1: $ListA"
            Write-Verbose "List 2: $ListB"
            $FinalObj = ((Compare-Object $ListA $ListB -IncludeEqual) | where -Property sideIndicator -eq '==').InputObject
            }
        #Otherwise
        Else{
            If(!$FetchInfo){
                if($dynParam1.value){Write-Verbose "Param: $($dynParam1.Name) = $($dynParam1.value)"}
                if($dynParam2.value){Write-Verbose "Param: $($dynParam2.Name) = $($dynParam2.value)"}
                if($dynParam3.value){Write-Verbose "Param: $($dynParam3.Name) = $($dynParam3.value)"}
                Write-Verbose "Cypher: $Query"
                write-Verbose "Body: $(($Body -split '"params"')[0])"
                write-Verbose "Body: $(' "params" ' + ($Body -split ',"params"')[1])"
                }
            ## Query BloodHound DB
            $Reply = Invoke-restmethod -Uri $addr -Method Post -Headers $head -body $Body
            
            # If Reply
            If($Reply.data){
                
                ## Reply Type
                # If Path
                If($GetPath){
                $FinalObj = @()
                0..($Reply.data.relationships.count -1)|%{
                    $Props = @{
                        'Step'       = $_
                        'StartNode'  = (irm -uri $Reply.data.nodes[$_] -Method Get -Headers $head).data.name 
                        'Edge'   = (irm -uri $Reply.data.relationships[$_] -Method Get -Headers $head).type
                        'Direction'  = $Reply.data.directions[$_]
                        'EndNode'    = (irm -uri $Reply.data.nodes[$_+1] -Method Get -Headers $head).data.name
                        }
                    $FinalObj += New-Object PSCustomObject -Property $props
                    }
                $FinalObj = $FinalObj | select 'Step','StartNode','Edge','Direction','EndNode'
                }
                
                # If NodeLists
                If($GetUsers -or $GetGroups -or $GetComputers){
                    $FinalObj = $reply.data.data.name | sort -unique
                    If($PSCmdlet.ParameterSetName -eq 'UsersAdminTo'){
                        $FinalObj = $FinalObj | %{Neo -GetUsers -MemberOf $_ -DegreeMax $dynParam2.Value} | sort -Unique
                        }
                    If($PSCmdlet.ParameterSetName -eq 'AdminByUser'){
                        $FinalObj = $FinalObj | %{Neo -GetComputers -AdminByGroup $_ -DegreeMax 1} | sort -Unique               
                        }
                    If($DynParam3.value -eq $true){$FinalObj = $FinalObj.count}
                    }
                
                # If Data
                If($GetData){
                    $RawData = $reply.data
                    $Obj = irm -uri $RawData.properties -Method Get -Headers $head
                    $obj | Add-Member –MemberType NoteProperty –Name 'RawData' –Value $RawData
                    $FinalObj = $Obj
                    }

                }
            Elseif(!$Reply.data){$FinalObj = $Null}
            }
        }
    ##ENDBLOCK
    End{
        # Return Obj
        Write-Verbose "Result : $FinalObj"
        return $FinalObj
        }
    } 
#EndFunction

#Fetch Initial Node Lists
if(!$DBDog){Neo -FetchInfo} 
