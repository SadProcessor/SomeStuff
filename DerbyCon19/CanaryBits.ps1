### AtomicCanary - beta ###

# ASCII
$ASCII = @("
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@                                   @@@@@
@@@@   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*  &@@@
@@@%  @@@@@@&   *@@@@@@@@@@@@@@@@@@@@@@  ,@@@
@@@%  @@@#         @@@@@@@@@@@@@@@@@@@@  ,@@@
@@@%  @@@@@*        #@@@@@@@@@@@@@@@@@@  ,@@@
@@@%  @@@@@@,          @@@@@@@@@@@@@@@@  ,@@@
@@@%  @@@@@@#            @@@@@@@@@@@@@@  ,@@@
@@@%  @@@@@@@             @@@@@@@@@@@@@  ,@@@
@@@%  @@@@@@@,             &@@@@@@@@@@@  ,@@@
@@@%  @@@@@@@@              @@@@@@@@@@@  ,@@@
@@@%  @@@@@@@@@&             @@@@@@@@@@  ,@@@
@@@%  @@@@@@@@@@@@            @@@@@@%    ,@@@
@@@%  @@@@@@@@@@@@@ @@@@@                ,@@@
@@@%  @@@@@@@@@@@ @@@@*         .@@@@@@  ,@@@
@@@%  @@@@@@@@@(         *@@@@    @@@@@  ,@@@
@@@%  @@.         %@@@@@@@@@@@@*   @@@@  ,@@@
@@@%       #@@@@@@@@@@@@@@@@@@@@& ,@@@@  ,@@@
@@@@   @@@@@@@@@@@@@@@@@@@@@@@@@@*@@@@   @@@@
@@@@@                                   @@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ AtomicCanary - beta - SadProcessor 2019 @@
@@@@@@@ Powered by AtomicRedTeam.io @@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
")

# CanaryObj
Class CanaryObj{
    [String]$ID
    [String]$Technique
    [String]$Name
    [String]$Description
    [String[]]$Platform
    [String]$Tool
    [String[]]$Command
    [PSCustomObject]$Argument
    }

################################### ParseAtomicCanary - internal

function ParseAtomicCanary{
<#
.Synopsis
   Parse Atomic Canary
.DESCRIPTION
   internal - yaml to Obj
.EXAMPLE
   ParseAtomicCanary $RawData
#>
    Param(
        [Parameter(Mandatory=1,valuefromPipeline=1)][String]$Canary
        )
    # DATA
    $Data = $Canary.split("`n").TrimEnd() -ne '---' -ne ''
    #Return $Data <#-----------------------------------------------------------------------------------Debug-#>
    $ID = $Data[0].replace("attack_technique: ",'')
    $Technique = $Data[1].replace("display_name: ",'')
    if($Data[2] -notmatch 'atomic_tests:'){Write-Warning "Data could not be parsed - Technique: $ID"; Return}
    # TESTS
    $TestBlock = $Data[3..$Data.length]-join"`n"
    # for each Test Object
    foreach($Test in ($TestBlock-split"(- name:)"-ne"- name:"-ne"")){
        # Split lines
        $Test = $Test.split("`n")
        # Name
        $TName = $Test[0].trim()
        # Index
        $Index = 1
        #Empty Collectors
        [System.Collections.ArrayList]$Tdesc = @()
        [System.Collections.ArrayList]$Tplat = @()
        [System.Collections.ArrayList]$Targ  = @()
        [System.Collections.ArrayList]$Tcmd  = @()
        # Description
        if($Test[$Index] -match "description"){$Index+=1}
        while($Test[$Index] -notmatch "supported_platforms" ){$Tdesc += $Test[$Index].trim();$Index+=1}
        # Platform
        if($Test[$Index] -match "supported_platforms"){$Index+=1}
        while($Test[$Index] -notmatch "input_arguments|executor" ){$Tplat+=$Test[$Index].trim()-replace"^- ",'';$Index+=1}
        # Args
        if($Test[$Index] -match "input_arguments"){$index+=1
            While($Test[$Index] -notmatch "executor"){
                if($test[$index] -notmatch "      description:|      type:|      default:"){ <#Error T1086 "Description" as var <- use whitespace #>
                    # name
                    $Aname = $test[$Index].trim()-replace":$",'';$Index+=1
                    # Desc
                    if($test[$index] -match 'description:'){$Adesc=$test[$Index].replace("description:",'').trim(); $Index+=1}else{$Adesc=$Null}
                    # Type
                    if($test[$index] -match 'type:'){$Atype=$test[$Index].replace("type:",'').trim(); $Index+=1}else{$Atype=$Null}
                    # Default
                    if($test[$index] -match 'default:'){$Adef =$test[$Index].replace("default:",'').trim(); $Index+=1}else{$Adef =$Null}
                    }
                # Add to Args
                $Targ += [PScustomObject]@{
                    Name        = $Aname
                    Description = $Adesc
                    Type        = $Atype
                    Default     = $Adef
                    }}}
        # Cmd ######
        if($Test[$Index] -match "executor"){$index+=1
            $Ttool = $Test[$Index].replace("name: ",'').trim();$Index+=1
            if($Test[$index] -match "command: |"){$index+=1}
            while($Index -ne $Test.count){if($Test[$Index] -ne ''){$Tcmd+=$Test[$index].trim()};$Index+=1} 
            }
        # Output Canary Obj
        [CanaryObj]@{
            ID           = $ID
            Technique    = $Technique
            Name         = $Tname
            Description  = $Tdesc-join"`r`n"
            Platform     = $Tplat
            Tool         = $Ttool
            Command      = $tcmd
            Argument     = $Targ
            }}}
#########End


############################################# Get-AtomicCanary

function Get-AtomicCanary{
<#
.Synopsis
   Get AtomicRedTeam Test
.DESCRIPTION
   Get AtomicRedTeam test objects by ATT&CK Technique ID
   Can be used after pipeline with PoSh_ATTCK ATTCK-Technique Cmdlet.
   Note: Parsing is hacky hacky but didn't want dependencies...
.EXAMPLE
   AtomicCanary T1107
.EXAMPLE
   ATTCK 'File Deletion' | AtomicCanary
#>
    [Alias('AtomicCanary')]
    [OutputType([CanaryObj])]
    Param(
        [Parameter(Mandatory=1,ValueFromPipelineByPropertyName=1)][String]$ID,
        [Parameter(Mandatory=0)][Switch]$Online
        )
    Begin{
        $GitHub_Raw="https://raw.githubusercontent.com/redcanaryco/atomic-red-team/master/atomics"
        $Github_MD ="https://github.com/redcanaryco/atomic-red-team/blob/master/atomics"
        }
    Process{
        $ID=$ID.ToUpper()
        if($Online){Start-Process "$GitHub_MD/$ID/$ID.md"}
        else{
            $Raw = try{irm "$Github_Raw/$ID/$ID.yaml"}catch{Write-Warning "No Atomic Data Found - Technique: $ID"}
            if($Raw){ParseAtomicCanary $raw}
            }}
    End{}###
    }
#End


## On Load
$ASCII

######################################## EOF