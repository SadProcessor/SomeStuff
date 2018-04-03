## Invoke-CypherISEr
## Cypher Queries in ISE
## @SadProcessor 2018 

<#
.Synopsis
   PoSh BloodHound CypherISEr
.DESCRIPTION
   Post Cypher Queries to BloodHound API from
   the posh comfort of the ISE scriptpane
   (to do awesome stuff with that data & your PoSh Powers...)
   
   Post query strings (Accepts multi-line queries)
   Post by scriptpane line number or range with -Line
   Post by Selection with [F12] Keyboard shortcut
   (works like [F8], but for BloodHound Cypher...)
   
   Expand object on the fly with -Expand <something>
   Accepts multiple comma-separated values
   Returns Raw Reply with -Expand $false
   Defaults to [-Expand data] if ommitted
   (see last example to make your Cypher life easy...)

   By default calls LocalHost on 7474
   Server & Port can also be past as parameters

   BASIC USAGE:
    - Store queries in vars and call from console with
      PS:\> CypherISEr $Query
    - See examples for more syntax [Help CypherISEr -Example]
    - Also works with simple .txt files opened in ISE
    - See last example for cool Cypher formating trick

    CYPHER TUNNING
    Use -Explain or -Profile for Cypher query execution plan info
    
   MORE INFO:
    # Neo4j Cypher Cheat Sheet
      http://neo4j.com/docs/cypher-refcard/current/
      https://neo4j.com/blog/tuning-cypher-queries/

    # Intro to BloodHound Cypher by @CptJesus [Help CypherISEr -Online]
      https://blog.cptjesus.com/posts/introtocypher

    # DogWhisperer Cypher cheat sheet
      https://github.com/SadProcessor/Cheats/blob/master/DogWhispererV2.md

    # Automated BloodHound PoSh Intall (Win64)
      https://github.com/SadProcessor/SomeStuff/blob/master/BloodHoundw64_LTI.ps1 
.EXAMPLE
   CypherISEr $Query
   Post Query to BloodHound
.EXAMPLE
   CypherISEr $Query -Expand relationships
   Post Query & Expand $Reply.relationships
.EXAMPLE
   CypherISEr $Query -Expand data,data
   Post Query & Expand $Reply.data.data
.EXAMPLE
   CypherISEr $Query -Expand $false
   Return $Reply without expanding
   (Otherwise expands to .data by default)
.EXAMPLE
   CypherISEr -Line 4
   Select from Scriptpane Line 4
.EXAMPLE
   CypherISEr -Line 4,8
   Select from Scriptpane Line 4 to 8
.EXAMPLE
   Help CypherISEr -Online
   Read The esquisite 'Intro to BloodHound Cypher' blogpost by @CptJesus
   A must...
.EXAMPLE
   CypherISEr $Query -Profile
   Returns Query execution info
.EXAMPLE
   .EXAMPLE
   CypherISEr $Query -Explain
   Returns Query execution info
.EXAMPLE
   ############ Cool Cypher Trick ############
   It's possible to return multiple values in a single object
   by using the following cypher syntax. This returns all objects
   in a single column .data (which is default -expand... easy!)

   PS:\> $Query="
   MATCH 
   (U:User)-[r:MemberOf|:AdminTo*1..]->(C:Computer)
   WITH
   U.name as n,
   COUNT(DISTINCT(C)) as c 
   RETURN 
   {Name: n, Count: c} as SingleColumn
   ORDER BY c DESC
   "
   PS:\> CypherISEr $Query

   Cool!!
#>
function Invoke-CypherISEr{
    [CmdletBinding(DefaultParameterSetName='ExpandQuery',HelpUri='https://blog.cptjesus.com/posts/introtocypher')]
    [Alias('CypherISEr')]
    Param(
        # Query
        [Parameter(Mandatory=1,Position=0,ParameterSetName='ProfileQuery')]
        [Parameter(Mandatory=1,Position=0,ParameterSetName='ExplainQuery')]
        [Parameter(Mandatory=1,Position=0,ParameterSetName='ExpandQuery')][string]$Query,
        # Line
        [ValidateCount(1,2)]
        [Parameter(Mandatory=1,Position=0,ParameterSetName='ProfileLine')]
        [Parameter(Mandatory=1,Position=0,ParameterSetName='ExplainLine')]
        [Parameter(Mandatory=1,ParameterSetName='ExpandLine')][int[]]$Line,
        # Expand
        [Parameter(Mandatory=0,ParameterSetName='ExpandQuery')]
        [Parameter(Mandatory=0,ParameterSetName='ExpandLine')][Object[]]$Expand='data',
        # Explain
        [Parameter(Mandatory=1,ParameterSetName='ExplainQuery')]
        [Parameter(Mandatory=1,ParameterSetName='ExplainLine')][Switch]$Explain,
        # Profile
        [Parameter(Mandatory=1,ParameterSetName='ProfileQuery')]
        [Parameter(Mandatory=1,ParameterSetName='ProfileLine')][Switch]$Profile,
        # Server
        [Parameter(Mandatory=0)][String]$Server='localhost',
        # Port
        [Parameter(Mandatory=0)][int]$Port=7474
        )
    # If by Line
    if($PSCmdlet.ParameterSetName -match 'Line$'){
        # Select Line(s)
        $Console = $psISE.CurrentPowerShellTab.ConsolePane
        $Editor=$psISE.CurrentFile.Editor
        if($Line.count -eq 1){$Editor.Select($Line,1,$Line+1,1)}
        if($Line.Count -eq 2){$Editor.Select($Line[0],1,$Line[1]+1,1)}
        # Get Query
        $Query = $Editor.SelectedText
        # Back To Console
        $Console.focus()
        }
    if($PSCmdlet.ParameterSetName -match "^Explain"){$Expand='Plan';$Query = "EXPLAIN " + $Query}
    if($PSCmdlet.ParameterSetName -match "^Profile"){$Expand='Plan';$Query = "PROFILE " + $Query}
    # Uri & header 
    $Uri = "http://${Server}:$Port/db/data/cypher"
    $Header=@{'Accept'='application/json; charset=UTF-8';'Content-Type'='application/json'}
    # if Verbose
    write-verbose $Query
    # Query to OneLiner
    $Query = $Query.replace("`r`n",' ').replace('  ',' ')
    # Body
    $Body = @{query=$Query}|Convertto-Json
    # Call API
    $Result = Invoke-RestMethod -Uri $Uri -Method Post -Headers $Header -Body $Body -ea SilentlyContinue -ErrorVar $Ooooops
    # If Error
    if($Ooooops){Write-Warning "$($Ooooops.message)" ;Return}
    # Format
    if($Expand){$Expand|%{$Result=$Result.$_}}
    # Explain/Profile
    if($PSCmdlet.ParameterSetName -match "^Explain|^Profile"){
        $Output = @()
        $Step = 0
        $Obj = $Result
        while($Step -eq 0 -OR $Obj.children){
            if($Obj){
                [HashTable]$Props = @{}
                $Props.add('Step',"$Step")
                $Props.add('Name',"$($Obj.name)")
                $Argum = $Obj.args
                $Argum | GM | ? MemberType -eq NoteProperty | %{ 
                    $Key = $_.name
                    $Value = $Argum.$Key 
                    $Props.add("$Key","$Value")
                    }
                $Output += New-Object PSCustomObject -Property $Props
                }
            $Obj = $Obj.children
            $Step += 1
            }

        if($PSCmdlet.ParameterSetName -match "^Profile"){
            $result = $Output <#| select Step,Name,* -ea sil#> | sort Step -Descending
            }
        if($PSCmdlet.ParameterSetName -match "^Explain"){
            $result = $Output <#| select Step,Name,EstimatedRows,* -ea sil#> | sort Step -Descending
            }
        }
    # Result
    Return $Result
    }
#End


## ISE Add-On [F12] 
## run selection on current cursor line

# Shortcut function
function CypherShortcut{
    # Editor
    $E=$psISE.CurrentFile.Editor
    # If Selected Text
    $Q = $E.SelectedText
    # Else select current line
    if($Q -eq ''){$Q = $E.CaretLineText}
    # Call
    Invoke-CypherISEr $Q 
    }

# Remove if existing
try{
    $Null = $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Remove($ShortCut)
    }Catch{<#nothing#>}
# Add To ISE
try{
    $ShortCut = $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add(“BloodHound Cypher”, {CypherShortcut}, “F12”)
    }Catch{Write-Warning 'Keyboard Shortcut Not Loaded...'}


###EOF