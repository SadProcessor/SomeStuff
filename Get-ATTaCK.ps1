#############################################
# PowerShell + ATT&CK API - Powered by MITRE 
#############################################

#############################################
#region PrepStuff
#Banner
$Banner = @('
######################################
#...#####..PS> Get-ATTaCKnowledge....#
#..# , , #...........................#
#.# {0,0} #Cmdlet_By_SadProcessor###.#
#.# /)_):.#Powered_By_MITRE_ATT&CK##.#
#..# ""  #...................#######.#
#...#####."Know Your Enemy"..##.####.#
######################################
')

#Home Props (HardCoded by Lazyness)
$HomeProps =@{
    'Name' = 'ATTaCK: Adversarial Tactics, Techniques & Common Knowledge'
    'URL' = 'https://attack.mitre.org/wiki/Main_Page'
    'Description' = 'ATT&CK is a constantly growing common reference for post-compromise techniques that brings greater awareness of what actions may be seen during a network intrusion. It enables a comprehensive evaluation of computer network defense (CND) technologies, processes, and policies against a common enterprise threat model. We do not claim that it is a comprehensive list of techniques, only an approximation of what is publicly known; therefore, it is also an invitation for the community to contribute additional details and information to continue developing the body of knowledge. Contributions could include new techniques, categories of actions, clarifying information, examples, other platforms or environments, methods of detection or mitigation, and data sources. See the Contribute page for instructions on how to get involved. The result will help focus community efforts on areas that are not well understood or covered by current defensive technologies and best practices. Developers of current defensive tools and policies can identify where their value and strengths are in relation to the ATT&CK framework. Likewise, cyber security research can use ATT&CK as a grounded reference point to drive future investigation.'
    }

#Init $ATTaCKnowledge Object
$Props = @{
    'Home' = $HomeProps
    'Tactic' = $Null
    'Technique'= $Null
    'Group'= $Null
    'Software'= $Null
    'Reference'= $Null
    }
$ATTaCKnowledge = New-Object PSCustomObject -Property $Props
#endregion PrepStuff
#############################################


#############################################
#region MainFunction

<#
.Synopsis
   Get Adverserial Tactic, Technique, & Commom Knowledge
.DESCRIPTION
   Interact with MITREs ATT&CK Wiki API
.EXAMPLE
   Get-ATTaCKnowledge -View Technique
   Description:
   ------------
   Returns all Techniques
.EXAMPLE
   Get-ATTaCKnowledge -Select Tactic -Name 'Lateral Movement'
   Description:
   ------------
   Returns Tactic Lateral Movement
.EXAMPLE
   Get-ATTaCKnowledge -Find Software -Proprety Description -Match 'worm'
   Description:
   ------------
   Returns Software with Description containing 'worm'
.EXAMPLE
   Get-ATTaCKnowledge -Online
   Description:
   ------------
   Browse to ATT&CK Homepage
.EXAMPLE
   Get-ATTaCKnowledge -Group -Online
   Description:
   ------------
   Browse to ATT&CK Group Overview
.EXAMPLE
   Get-ATTaCKnowledge -Find Technique -Property Reference -Match Graeber -Online
   Description:
   ------------
   Open technique page matching 'Graeber' in reference
.EXAMPLE
   Get-ATTaCKnowledge -Find Reference -Proprety Key -Match SubTee -Online
   Description:
   ------------
   Open references matching 'SubTee'
.INPUTS
   None
.OUTPUTS
   Custom ATT&CKnowledge Object
.NOTES
   Powered by ATT&CK
.FUNCTIONALITY
   Purple PoSh ATT&CKnowledge
#>
function Get-ATTaCKnowledge(){
    [CmdletBinding(DefaultParameterSetName='NoParam')]
    [Alias('ATTaCK')]
    Param(
        # View
        [Parameter(Mandatory=$true,Position=0,ParameterSetName='ViewCategory')]
        [ValidateSet('Home','Tactic','Technique','Group','Software','Reference')]
        [String]$View,

        # Select
        [Parameter(Mandatory=$true,Position=0,ParameterSetName='SelectItem')]
        [ValidateSet('Home','Tactic','Technique','Group','Software','Reference')]
        [String]$Select,

        # Find
        [Parameter(Mandatory=$true,Position=0,ParameterSetname='FindMatch')]
        [ValidateSet('Home','Tactic','Technique','Group','Software','Reference')]
        [String]$Find,

        # SyncKnowledge
        [Parameter(Mandatory=$true,Position=0,ParameterSetname='SyncKnowledge')]
        [Switch]$SyncKnowledge,

        # Online
        [Parameter(Mandatory=$false)]
        [Switch]$OnLine

        )
    DynamicParam{
        If($Select){
            # Create runtime Dictionary for Param
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            
            ## -Item
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 1
            $Attrib1.HelpMessage = 'Enter Item to Select:'
            # Create Validate Set
            $Values1 = $ATTaCKnowledge.$Select.Name
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($Values1)
            # Add to collection
            $Collection1.Add($Attrib1)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('Name',[String],$Collection1)
                            
            # Add All Runtime Params to dictionary
            $Dictionary.Add('Name', $dynParam1)
            #Return Category Dictionary
            return $Dictionary
            }
        If($Find){
            # Create runtime Dictionary for Param
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
     
            ## -Property
            # Create AttributeCollection object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 1
            # Create Validate Set
            $Values1 = ($ATTaCKnowledge.$find|gm|? Membertype -EQ 'NoteProperty').Name 
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($Values1)
            # Add to collection
            $Collection1.Add($Attrib1)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('Property',[String],$Collection1)

            ## -Match
            # Create AttributeCollection object
            $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Create Attribute Object
            $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib2.Mandatory = $true
            $Attrib2.Position = 2
            # Add  to collection
            $Collection2.Add($Attrib2)
            # Create Runtime Parameter with matching collection
            $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('Match',[String],$Collection2)
            
            # Add All Runtime Params to dictionary
            $Dictionary.Add('Property', $dynParam1)
            $Dictionary.Add('Match', $dynParam2)
            #Return Category Dictionary
            return $Dictionary

            }
        }
    Begin{
        #Prep Obj
        $Obj = $Null
        If($View){$Category = $View}
        If($Select){$Category = $Select}
        If($Find){$Category = $Find}
        $Obj = $ATTaCKnowledge.$Category
        }
    Process{
        # Filter Object
        If($Select){$Obj = $Obj | Where-Object -Property Name -eq "$($DynParam1.value)"}
        If($Find){$Obj = $Obj | where-object -Property $DynParam1.value -Match "$($DynParam2.value)"}

        ##Actions
        If($PSCmdlet.ParameterSetName -eq 'NoParam' -and !$OnLine){Help Get-ATTaCKnowledge}
        If($Online -and !$SyncKnowledge){
            $URL = $Obj.URL
            If($PSCmdlet.ParameterSetName -eq 'NoParam' -and $OnLine){$URL=(Get-ATTaCKnowledge -View Home).URL}
            If($view -eq 'Tactic'){$URL='https://attack.mitre.org/wiki/Technique_Matrix'}
            If($view -eq 'Technique'){$URL='https://attack.mitre.org/wiki/All_Techniques'}
            If($view -eq 'Group'){$URL='https://attack.mitre.org/wiki/Groups'}
            If($view -eq 'Software'){$URL='https://attack.mitre.org/wiki/Software'}
            If($view -eq 'Reference'){$URL='https://attack.mitre.org/wiki/Reference_list'}
            If($Url.count -gt 10){$Url = $URL | select -First 10}
            $Url | foreach{start $_;Start-Sleep -Milliseconds 250}
            Break
            }
        If($SyncKnowledge){SyncKnowledge}
        Else{$Obj}
        }
    End{}
    }##END

#endregion MainFunction
#############################################


#############################################
#region HelperFunction

## Function SyncKnowledge
Function SyncKnowledge(){
<#
.Synopsis
   Helper for Get-ATTaCKnowledge -SyncKnowledgeObj
.DESCRIPTION
   Populate/update properties of $ATTaCKnowledge Obj
.NOTES
   Sub-Function: Internal Only
#>
write-host $Banner -ForegroundColor Cyan
Write-verbose 'Connecting...'
$Script:ATTaCKnowledge.Technique = SyncCategory -Category 'Technique' -ErrorAction SilentlyContinue
Write-verbose 'Synchronizing Techniques... '
$Script:ATTaCKnowledge.Technique = SyncCategory -Category 'Technique'
Write-verbose 'Synchronizing Groups... '
$Script:ATTaCKnowledge.Group = SyncCategory -Category 'Group'
Write-verbose 'Synchronizing Softwares... '
$Script:ATTaCKnowledge.Software = SyncCategory -Category 'Software'
Write-verbose 'Synchronizing Tactics... '
$Script:ATTaCKnowledge.Tactic = SyncCategory -Category 'Tactic'
Write-verbose 'Synchronizing References... '
$Script:ATTaCKnowledge.Reference = SyncCategory -Category 'Reference'
Write-verbose 'Done... '
return $Script:ATTaCKnowledge
}
#End SyncKnowledge

############################################

## Function SyncCategory
function SyncCategory{
<#
.Synopsis
   Sub for SyncKnowledge
.DESCRIPTION
   Updates $ATTaCKnowledge Category
.NOTES
   Sub-Function: Internal Only
#>
    [CmdletBinding()]
    [Alias()]
    [OutputType()]
    Param(
        # Object Collection Category
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateSet('Technique','Group','Software','Tactic','Reference')]
        [String]$Category
        )
    Begin{}
    Process{
        # Queries
        $QueryTactic    = "[[Category:Tactic]]|?Has description|?Citation reference|limit=9999"
        $QuerySoftware  = "[[Category:Software]]|?Has ID|?Has display name|?Has description|?Has technique|?Has platform|?Has software type|?Has software page|?Citation reference|limit=999"
        $QueryGroup     = "[[Category:Group]]|?Has ID|?Has display name|?Has alias|?Has description|?Has technique|?Uses software|?Citation reference|?Has URL|limit=999"
        $QueryTechnique = "[[Category:Technique]]|?Has ID|?Has display name|?Has technical description|?Requires system|?Has mitigation|?Has analytic details|?Has tactic|?Bypasses defense|?Has platform|?Citation reference|limit=999"
        $QueryRef       = "[[Citation text::+]]|?Citation key|?Citation text|?Has title|?Has authors|?Retrieved on|?Has URL|limit=9999"
        
        #Select Query
        if($Category -eq 'Technique'){$Query = $QueryTechnique}
        if($Category -eq 'Group'){    $Query = $QueryGroup}
        if($Category -eq 'Software'){ $Query = $QuerySoftware}
        if($Category -eq 'Tactic'){   $Query = $QueryTactic}
        if($Category -eq 'Reference'){$Query = $QueryRef}
        
        # URL Encode Query
        $EncodedQuery = [System.Web.HttpUtility]::UrlEncode($Query)
        # Base API Call URL
        $URL = 'https://attack.mitre.org/api.php?action=ask&format=json&query='
        # Glue together
        $URLQuery = $URL + $EncodedQuery
        
        # Call
        $Reply = irm $URLQuery
        
        # Filter reply
        # Obj2
        $ObjList1 = ((($reply.query.results | gm) | ?{$_.MemberType -eq 'NoteProperty'}).name | %{$reply.query.results.$_}) | select 'fulltext','Fullurl'
        # Obj2
        $ObjList2 = ((($reply.query.results | gm) | ?{$_.MemberType -eq 'NoteProperty'}).name | %{$reply.query.results.$_}).printouts

        #Check objCount 
        [Bool]$objCountIsEqual = ($ObjList1.count -eq $objList2.count)
        if(!$objCountIsEqual){Write-Host 'Computer Says No: Object Count Error...' -ForegroundColor Cyan;Break}
        # Prep Empty Collection
        $Collection = @()
        ## FOR EACH OBJ in OBJCOUNT
        0..($ObjList1.Count -1) | foreach{
            # get matching Obj
            $Obj1 = $ObjList1[$_]
            $Obj2 = $ObjList2[$_]
            # builb Props / Createobj / Add to collection
            #if cat technique
            if($Category -eq 'Technique'){
                $Props = @{
                    'FullText' = $Obj1.fulltext
                    'URL' = $Obj1.fullurl
                    'ID' = $Obj2.'Has ID'
                    'Name' = $Obj2.'Has display name'
                    'Tactic' = $Obj2.'Has tactic'.fulltext
                    'Description' = $Obj2.'Has technical description'
                    'Bypass' = $Obj2.'Bypasses defense'
                    'Mitigation' = $Obj2.'Has mitigation'
                    'RequiresSystem' = $Obj2.'Requires system'
                    'AnalyticDetails' = $Obj2.'Has analytic details'
                    'Platform' = $Obj2.'Has platform'
                    'Reference' = $Obj2.'Citation reference'
                    }
                $Obj = New-Object PSCustomObject -Property $Props
                $Collection += $Obj
                }
            #if cat Group
            if($Category -eq 'Group'){
                $Props = @{
                    'FullText' = $Obj1.fulltext
                    'URL' = $Obj1.fullurl
                    'ID' = $Obj2.'Has ID'
                    'Name' = $Obj2.'Has display name'
                    'Alias' = $Obj2.'Has alias'
                    'Description' = $Obj2.'Has Description'
                    'Technique' = $Obj2.'Has technique'.fulltext
                    'Reference' = $Obj2.'Citation reference'
                    }
                $Obj = New-Object PSCustomObject -Property $Props
                $Collection += $Obj
                }
            #if cat Software
            if($Category -eq 'Software'){
                $Props = @{
                    'FullText' = $Obj1.fulltext
                    'URL' = $Obj1.fullurl
                    'ID' = $Obj2.'Has ID'
                    'Name' = $Obj2.'Has display name'
                    'Description' = $Obj2.'Has Description'
                    'Technique' = $Obj2.'Has technique'.fulltext
                    'Reference' = $Obj2.'Citation reference'
                    'Type' = $Obj2.'Has software type'
                    }
                $Obj = New-Object PSCustomObject -Property $Props
                $Collection += $Obj
                }
            #if cat Tactic
            if($Category -eq 'Tactic'){
                $Props = @{
                    'Reference' = $Obj2.'Citation reference'
                    'URL' = $Obj1.fullurl
                    'Description' = $Obj2.'Has Description'
                    'Name' = $Obj1.fulltext
                    }
                $Obj = New-Object PSCustomObject -Property $Props
                $Collection += $Obj
                }
            #if cat Ref
            if($Category -eq 'Reference'){
                $QueryRef = '[[Citation text::+]]|?Citation key|?Citation text|?Has title|?Has authors|?Retrieved on|?Has URL|limit=9999' 
                $Props = @{
                    'Fulltext' = $Obj1.fulltext
                    'Key' = $Obj2.'Citation key'
                    'Text' = $Obj2.'Citation text'
                    'Name' = $Obj2.'Has title'
                    'Author' = $Obj2.'Has authors'.fulltext
                    'Date' = $Obj2.'Citation text'.replace('(v=ws.10)','').split('(')[1].split(')')[0]
                    'Year' = $Obj2.'Citation text'.replace('(v=ws.10)','').split('(')[1].split(')')[0].split(',')[0]
                    'Retrieved' = $Obj2.'Retrieved on'.fulltext
                    'URL' = $Obj2.'Has URL'.fulltext
                    }
                $Obj = New-Object PSCustomObject -Property $Props
                IF($Obj.date -notmatch '\d\d\d\d'){$Obj.date = 'n.d.'}
                IF($Obj.Year -notmatch '\d\d\d\d'){$Obj.Year = 'n.d.'}
                $Collection += $Obj
                }
            }
        return $Collection
        }
    End{}
}
#End SyncCategory

#endregion HelperFunction
#############################################


#############################################
#region Init

#############################################
## Init
# Populate Initial $ATTaCKnowledge Obj
$Null = Get-ATTaCKnowledge -SyncKnowledge -Verbose
write-Host 'VERBOSE: ATTaCKnowledge Object Synchronized.' -ForegroundColor Cyan

#endregion Init
#############################################


#############################################
#region Exports
#Export-ModuleMember -Function Get-ATTaCKnowledge
#Export-ModuleMember -Variable $ATTaCKnowledge
#endregion Exports
#############################################

##EndFile##