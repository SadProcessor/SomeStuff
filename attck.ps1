<#
.Synopsis
   Get ATT&CK Knowledge
.DESCRIPTION
   A tool to fetch info from ATT&CK Knowledge base
   Tool uses Dynamic Parameterts so SYNTAX above is not complete.
   See examples for full syntax (Help ATTCK -Examples)

   # Note: 
   Current REST API will soon be changed, 
   this tool will become obsolete somewhere in 2018.
   
   Still wanted to add tab completion & Pipeline for references 
   + handle error on non existing pages,
   but I'll wait for new version and fully refactor.
   
   # Info: 
   https://attack.mitre.org/wiki/Main_Page 
.EXAMPLE
   ATTCK -List Tactic
   Returns all Tactics
.EXAMPLE
   ATTCK -Tactic Collection | FL
   Returns info on specified tactic formated as list
.EXAMPLE
   ATTCK -List Group -Match Bear
   Returns list of Group (Name & ID) matching 'Bear'
.EXAMPLE   
   ATTCK -Group apt29
   Returns info on specified group
.EXAMPLE
   ATTCK -Group apt29 | select -expand technique
   Returns list of techniques used by specified group
.EXAMPLE
   ATTCK -Group apt29 -ShowRef
   List reference titles for specified group
.EXAMPLE
   ATTCK -Group apt29 -ShowRef | %{ATTCK -Reference $_}
   List reference titles for specified group
.EXAMPLE
   ATTCK -List Technique -Match DLL | ATTCK -Technique | Select Name,Description | FL
   Returns Name and Description of all techniques with name matching DLL, formated as list
.EXAMPLE
   ATTCK -List Group -Match Panda | ATTCK -Group | Select -expand Reference | %{ATTCK -Reference $_ -OnLine}
   Everything you need to know about Pandas -> Online
#>
 function Get-ATTCK{    
    [CmdletBinding()]
    [Alias('ATTCK')]    
    Param(
        # List Names per Category 
        [ValidateSet('Technique','Tactic','Software','Group')]
        [Parameter(Mandatory=1,ParameterSetName='List')][Alias('Search')][String]$List,
        # View Tactic per name
        [Parameter(Mandatory=1,ParameterSetName='Tactic')][Switch]$Tactic,
        # View Technique per name
        [Parameter(Mandatory=1,ParameterSetName='Technique')][Switch]$Technique,
        # View Software per name
        [Parameter(Mandatory=1,ParameterSetName='Software')][Switch]$Software,
        # View Group per name
        [Parameter(Mandatory=1,ParameterSetName='Group')][Switch]$Group,
        # View per ID (All category)
        [Parameter(Mandatory=1,ParameterSetName='ID')][Switch]$ID,
        # View Reference per name
        [Parameter(Mandatory=1,ParameterSetName='Reference',ValueFromPipeline=1)][String[]]$Reference,
        # Visit Online
        [Parameter(Mandatory=0,ParameterSetName='Tactic')]
        [Parameter(Mandatory=0,ParameterSetName='Technique')]
        [Parameter(Mandatory=0,ParameterSetName='Software')]
        [Parameter(Mandatory=0,ParameterSetName='Group')]
        [Parameter(Mandatory=0,ParameterSetName='ID')]
        [Parameter(Mandatory=0,ParameterSetName='Reference')][Switch]$OnLine,
        # Restrict List to matching Keywork
        [Parameter(Mandatory=0,Position=0,ParameterSetName='List')][String]$Match,
        # Refresh ATTCK Object 
        [ValidateSet('*','Technique','Tactic','Software','Group')]
        [Parameter(Mandatory=1,ParameterSetName='Refresh')][String]$Refresh
        )    
    DynamicParam{
        # if Technique|Tactic|Software|Group|ID 
        If($PScmdlet.ParameterSetName -notin 'Refresh','List','Reference'){
            # Select List based on ParamSetName
            Switch($PScmdlet.ParameterSetName){
                'Technique'{$Set=$Script:ATTCK.Technique.name}
                'Tactic'   {$Set=$Script:ATTCK.Tactic.name}
                'Software' {$Set=$Script:ATTCK.Software.name}
                'Group'    {$Set=$Script:ATTCK.Group.name}
                'ID'       {$Set=$Script:ATTCK.Technique.ID+$Script:ATTCK.Software.ID+$Script:ATTCK.Group.ID| sort -unique}
                }          
            ## Dictionary
            # Create runtime Dictionary for this ParameterSet
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            ## Name
            # Create Attribute Object
            $Attrib1 = New-Object System.Management.Automation.ParameterAttribute
            $Attrib1.Mandatory = $true
            $Attrib1.Position = 0
            $Attrib1.ValueFromPipeline=$true
            $Attrib1.ValueFromPipelineByPropertyName=$true
            $Attrib1.HelpMessage = "Enter Name"
            # Create AttributeCollection object for the attribute Object
            $Collection1 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add our custom attribute to collection
            $Collection1.Add($Attrib1)
            # Add Validate Set to attribute collection     
            $ValidateSet1=new-object System.Management.Automation.ValidateSetAttribute($Set)
            $Collection1.Add($ValidateSet1)
            # Create Runtime Parameter with matching attribute collection
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [String[]], $Collection1)
		    # Add Runtime Param to dictionary
		    $Dictionary.Add('Name',$dynParam1)
            ## ShowRef
            If($PScmdlet.ParameterSetName -in 'Technique','Software','Group'){
                # Create Attribute Object
                $Attrib2 = New-Object System.Management.Automation.ParameterAttribute
                $Attrib2.Mandatory = $false
                # Create AttributeCollection object for the attribute Object
                $Collection2 = new-object System.Collections.ObjectModel.Collection[System.Attribute]
                # Add our custom attribute to collection
                $Collection2.Add($Attrib2)
                # Create Runtime Parameter with matching attribute collection
                $DynParam2 = New-Object System.Management.Automation.RuntimeDefinedParameter('ShowRef', [Switch], $Collection2)
		        # Add Runtime Param to dictionary
		        $Dictionary.Add('ShowRef',$dynParam2)                
                }
		    #return Dictionary
		    return $Dictionary
            }}    
    Begin{
        ## Prep Vars
        # Base URL
        $BaseURL = 'https://attack.mitre.org/api.php?action=ask&format=json&query='
        # Property Lists per Category
        $TechProps = "|%3FHas+display+name|%3FHas+technical+description|%3FHas+ID|%3FHas+tactic|%3FHas+platform|%3FHas+data+source|%3FRequires+permissions|%3FRequires+system|%3FHas+mitigation|%3FHas+analytic+details|%3FBypasses+defense|%3FCitation+reference"
        $TactProps = "|%3FHas+description"
        $SoftProps = "|%3FHas+ID|%3FHas+display+name|%3FHas+description|%3FHas+technique|%3FHas+platform|%3FHas+software+type|%3FHas+software+page|%3FCitation+reference"
        $GrpProps  = "|%3FHas+display+name|%3FHas+description|%3FHas+ID|%3FHas+alias|%3FHas+technique|%3FUses+software|%3FCitation+reference|%3FHas+URL"
        $RefProps  = "|%3FCitation+key|%3FCitation+text|%3FHas+title|%3FHas+authors|%3FRetrieved+on|%3FHas+URL"
        # ShowRef Y/N
        if($DynParam2.IsSet){$ShowRef=$true}
        # Init $Result
        $Result = @()
        }
    Process{
        ## REFRESH
        If($PSCmdlet.ParameterSetname -eq 'Refresh'){
            # Value to Bools
            Switch($Refresh){
                'Technique'{$BoolTech=$true}
                'Tactic'   {$BoolTact=$true}
                'Software' {$BoolSoft=$true}
                'Group'    {$BoolGrp =$true}
                '*'        {$BoolTech=$true;$BoolTact=$true;$BoolSoft=$true;$BoolGrp=$true}
                }
            # If no Object > Create empty $ATTCK object
            if(!$Script:ATTCK){$Script:ATTCK = New-Object PSCustomObject -Property @{Technique=@();Tactic=@();Software=@();Group=@()}}            
            # Refresh Technique List
            if($BoolTech){
                Write-Verbose "Getting Technique List..."
                # Clear old values
                $Script:ATTCK.Technique=@()
                # Call API
                $Reply = irm "$baseURL[[Category:Technique]]" -verbose:$False
                # Format
                $techList = $Reply.query.results | GM | ? -Property MemberType -eq NoteProperty | Select Name
                $techCollection = @()
                $techList.name | %{
                    $Props = @{
                        ID = $_.split('/')[1]
                        Name = $Reply.query.results.$_.displaytitle
                        }
                    $techCollection += New-Object PSCustomObject -Property $Props
                    }
                # Store in ATTCK object
                $Script:ATTCK.Technique = $TechCollection
                }
            # Refresh Tactic List
            if($BoolTact){
                Write-Verbose "Getting Tactic List..."
                # Clear old values
                $Script:ATTCK.Tactic=@()
                # Call API
                $Reply = irm "$baseURL[[Category:Tactic]]$TactProps" -verbose:$False
                # Format 
                $TactList = $Reply.query.results | GM | ? -Property MemberType -eq NoteProperty | Select name
                $TactCollection = @()
                $TactList.name | %{
                    $Props = @{
                        Name = $_
                        Description = $Reply.query.results."$_".printouts | Select 'Has description' -ExpandProperty 'Has description' 
                        URL = $Reply.query.results."$_".fullurl
                        }
                    $TactCollection += New-Object PSCustomObject -Property $Props
                    }
                $Script:ATTCK.Tactic=$TactCollection | select Name,Description,URL
                }            
            # Refresh Software List
            if($BoolSoft){
                Write-Verbose "Getting Software List..."
                # Clear old values
                $Script:ATTCK.Software=@()
                # Call API
                $Reply = irm "$baseURL[[Category:Software]]" -verbose:$False
                # Format 
                $SoftList = $Reply.query.results | GM | ? -Property MemberType -eq NoteProperty | Select name
                $SoftCollection = @()
                $SoftList.name | %{
                    $SynList = $Reply.query.results.$_.displaytitle.replace('Software: ','').replace(' ...','').Split(',').trim()
                    $Split = $_.split('/')[1]
                    $SynList | %{
                        if($_ -ne ''){
                            $Props = @{
                                ID = $Split
                                Name = $_
                                }
                            $SoftCollection += New-Object PSCustomObject -Property $Props
                            }}}
                $Script:ATTCK.Software = $SoftCollection                
                }
            # Refresh Group List
            if($BoolGrp){
                Write-Verbose "Getting Group List..."
                # Clear old values
                $Script:ATTCK.Group=@()
                # Call API
                $Reply = irm "$baseURL[[Category:Group]]" -verbose:$False
                # Format 
                $GroupList = $Reply.query.results | GM | ? -Property MemberType -eq NoteProperty | Select name
                $GroupCollection = @()
                $GroupList.name | %{
                    $SynList = $Reply.query.results.$_.displaytitle.replace('Group: ','').replace(' ...','').Split(',').trim()
                    $Split = $_.split('/')[1]
                    $SynList | %{
                        if($_ -ne ''){
                            $Props = @{
                                ID = $Split
                                Name = $_
                                }
                            $GroupCollection += New-Object PSCustomObject -Property $Props
                            }}}
                $Script:ATTCK.Group= $GroupCollection 
                }}
        ## LIST
        ElseIf($PSCmdlet.ParameterSetname -eq 'List'){
            Write-Verbose "Searching List..."
            $SelectedList = $Script:ATTCK.$List
            if($match){$result = $SelectedList | ? Name -match "$match"}
            Else{$result = $SelectedList}
            if($List -eq 'Tactic'){$result = $result | select Name}
            }
        ## REFERENCE
        ElseIf($PSCmdlet.ParameterSetName -eq 'Reference'){
            Write-Verbose "Searching Reference..."
            foreach($ref in $reference){
                $URL = "$BaseURL[[Citation+key::$Ref]]$refProps"
                $reply = (irm $URL).query.results
                $reply = $reply.(($reply | Gm | ? Membertype -eq NoteProperty).name).printouts
                $Props = @{
                    Tilte = $reply | select 'Has title' -ExpandProperty 'Has title'
                    Key = $reply | select 'Citation key' -ExpandProperty 'Citation key'
                    Author = ($reply | select 'Has authors' -ExpandProperty 'Has authors').fulltext
                    URL = ($reply | select 'Has URL' -ExpandProperty 'Has URL').fulltext.replace(' ','_')
                    Date = ($reply | select 'Retrieved on' -ExpandProperty 'Retrieved on').fulltext
                    Text = $reply | select 'Citation text' -ExpandProperty 'Citation text'
                    }
                $result += New-Object PSCustomObject -Property $Props
                }}
        ## ELSE (TACTIC|TECHNIQUE|GROUP|SOFTWARE)
        Else{
            $Category = $PScmdlet.ParameterSetName
            Switch($Category){
                'Technique'{$PropString = $TechProps}
                'Tactic'{$PropString = $TactProps}
                'Software'{$PropString = $SoftProps}
                'Group'{$PropString = $GrpProps}
                }
            Write-Verbose "Searching $Category..."
            foreach($Item in $DynParam1.Value){
                # if Tactic (Name)
                If($Category -eq 'Tactic'){$result += $Script:ATTCK.Tactic | ? Name -eq $Item}
                Else{
                    # Get matching ID Code
                    $Code = ($ATTCK.$Category | ? Name -EQ $Item).ID
                    # correct for ID
                    if($Category -eq 'ID'){
                        $Code = $Item
                        Switch($Item[0]){
                            'T'{$PropString = $techProps}
                            'S'{$PropString = $SoftProps}
                            'G'{$PropString = $GrpProps}
                            }}
                    # Prep Url
                    $URL = "$BaseURL[[Has+ID::$Code]]$PropString"
                    # Make call
                    $Reply = (irm $URL).query.results
                    # Format
                    $Data = $reply.(($reply|GM|? Membertype -eq NoteProperty).name).printouts
                    $URL = $reply.(($reply|GM|? Membertype -eq NoteProperty).name).fullurl
                    # if Technique (Name or ID)
                    if($Category -eq 'technique' -OR ($Category -eq 'ID' -AND $Item[0] -eq 'T')){
                        $Props = @{
                            ID = $Data | select 'Has ID' -ExpandProperty 'Has ID'
                            Name = $Data | select 'Has display name' -ExpandProperty 'Has display name'
                            Description = $data | select 'Has technical description' -ExpandProperty 'Has technical description' 
                            Tactic = ($Data | select 'Has tactic' -ExpandProperty 'Has tactic').fulltext
                            Platform = $Data | select 'Has platform' -ExpandProperty 'Has platform'
                            DataSource = $Data | select 'Has data source' -ExpandProperty 'Has data source'
                            RequiresPermission = $Data | select 'Requires permissions' -ExpandProperty 'Requires permissions'
                            RequiresSystem = $Data | select 'Requires system' -ExpandProperty 'Requires system'
                            Mitigation = $Data | select 'Has mitigation' -ExpandProperty 'Has mitigation'
                            Analytic = $Data | select 'Has analytic details' -ExpandProperty 'Has analytic details'
                            BypassDefense = $Data | select 'Bypasses defense' -ExpandProperty 'Bypasses defense'
                            Reference = $Data | select 'Citation reference' -ExpandProperty 'Citation reference'
                            URL=$URL
                            }
                        $result += New-object PSCustomObject -Property $Props
                        }
                    # if Software (Name or ID)
                    ElseIf($Category -eq 'Software' -OR ($Category -eq 'ID' -AND $Item[0] -eq 'S')){
                        $Props = @{
                            URL = $URL
                            ID = $Data | select 'Has ID' -ExpandProperty 'Has ID'
                            Name = $Data | select 'Has display name' -ExpandProperty 'Has display name'
                            Description = $Data | select 'Has description' -ExpandProperty 'Has description'
                            Technique = ($Data | select 'Has technique' -ExpandProperty 'Has technique' ).displaytitle
                            Platform = $Data | select 'Has platform' -ExpandProperty 'Has platform'
                            Type = $Data | select 'Has software type' -ExpandProperty 'Has software type'
                            Reference = $Data | select 'Citation reference' -ExpandProperty 'Citation reference'
                            }
                        $result += New-Object PScustomObject -Property $Props
                        }
                    # if Group (Name or ID)
                    ElseIf($Category -eq 'Group' -OR ($Category -eq 'ID' -AND $Item[0] -eq 'G')){
                        $Props = @{
                            URL = $URL
                            Name = $Data | select 'Has display name' -ExpandProperty 'Has display name'
                            Description = $Data | select 'Has description' -ExpandProperty 'Has description'
                            ID = $Data | select 'Has ID' -ExpandProperty 'Has ID'
                            Alias = $Data | select 'Citation reference' -ExpandProperty 'Has alias'
                            Technique = ($Data | select 'Has Technique' -ExpandProperty 'Has technique').displaytitle
                            Software = ($Data | select 'Uses software' -ExpandProperty 'Uses software').displaytitle.replace('Software: ','')
                            Reference = $Data | select 'Citation reference' -ExpandProperty 'Citation reference'
                            }
                        $result += New-object PSCustomObject -Property $Props
                        }}}}
        # ShowRef
        if($ShowRef){$result = $Result.reference}
        }
    End{
        # OnLine
        if($Online){foreach($U in $result.URL){try{Start $U}catch{start 'https://attack.mitre.org/wiki/Technique_Matrix'}}}
        # Showref
        if($ShowRef -OR $Category -eq 'Reference'){return $result}
        # Else
        Else{Return $result}
        }}
#####End


#################################################################################
#Initialize List Object if doesn't exist

$Banner = @('
######### Adversarial #
#  , ,  # Tactics #####
# {@,@} # Techniques ##
# /)_)  # & Common #### 
###""#### Knowledge ###
Get-ATTCK @SadProcessor

Powered by attack.mitre.org
')
# first load
if(!$Script:ATTCK){
    Write-Host $Banner -ForegroundColor Cyan
    ATTCK -Refresh * -Verbose
    }

#################################################################################
Break
# CleanUp if needed
Remove-variable -Name ATTCK -Force 


#EOF