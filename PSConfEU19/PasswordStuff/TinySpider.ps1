<#
.Synopsis
   Find Tiny files
.DESCRIPTION
   Search input folder for files by max lentgh / Line count / word count
.EXAMPLE
   TinySpider -Folder ~/Desktop -Type txt -Line 1 -Word 1 -length 123
.EXAMPLE
   TinySpider -target TargetOne,TargetTwo -folder $HOME
#>
function Invoke-TinySpider{
    [Alias('TinySpider')]
    Param(
        # Search folder
        [Parameter(Mandatory=0)][String[]]$Folder,
        # File extension
        [Parameter(Mandatory=0)][Alias('Type')][String[]]$Extension=@('txt'),
        # Max Line Count
        [Parameter(Mandatory=0)][Alias('Line')][int]$MaxLineCount=2,
        # Max Word count
        [Parameter(Mandatory=0)][Alias('Word')][int]$MaxWordCount=2,
        # Max file Length
        [Parameter(Mandatory=0)][Alias('Length')][int]$MaxFileLength=200,
        # No Recurse
        [Parameter(Mandatory=0)][Switch]$NoRecurse,
        # Remote Computer
        [Parameter(Mandatory=0,ValuefromPipeline=1)][Alias('Target')][String[]]$ComputerName,
        # Throttle Limit
        [Parameter(Mandatory=0)][int]$Throttle=10
        )
    ## Prepare Suff
    Begin{
        # Local Vars
        [Collections.ArrayList]$ComputerList=@()   
        $Scrptblck = {          
            Try{# Import Vars from Function Params
                $Folder        = $Using:Folder
                $Extension     = $Using:Extension
                $NoRecurse     = $Using:NoRecurse
                $MaxFileLength = $Using:MaxFileLength
                $MaxLineCount  = $Using:MaxLineCount
                $MaxWordCount  = $Using:MaxWordCount
                }Catch{<#Silent Error when not remote#>}
            ## Action [on remote Target] 
            $folder | Get-ChildItem -File -Recurse:(-Not$NoRecurse.IsPresent) |#pipe
            where {$_.extension.TrimStart('.') -in $extension -AND $_.Length -le $MaxFileLength} |#pipe
            Where {try{(Get-Content $_.FullName).split("`r").trim().count -le $MaxLineCount}catch{}}|#pipe
            Where {try{((Get-Content $_.FullName).split("`r").trim().split(' ')|?{$_ -ne ''}).count -le $MaxwordCount}catch{}} |#pipe
            Select-String -Pattern . -Context 0,$MaxLineCount -List | Select * | %{#Foreach
                # Output Object
                [PSCustomObject]@{
                    HostName = $Env:ComputerName
                    FileName = $_.fileName
                    Text     = (($_.line,(($_.Context|select -Expand PostContext)-join"`r`n"))-join"`r`n").trim()
                    Path     = $_.Path
                    }}}<#Scrptblck#>}
    ## Collect All ComputerName
    Process{foreach($Computer in $ComputerName){$Null = $ComputerList.add($Computer)}}
    ## Invoke Command
    End{# If No computerName, Invoke Scriptblock local
        if($ComputerList.Count -eq 0){Invoke-Command -Script $Scrptblck}
        else{# Invoke distributed remote Scriptblock
            $Cred = Get-Credential -User $Env:UserName -Message 'Enter Remote Creds...'
            Invoke-Command -VMName $ComputerList -Cred $Cred -Script $Scrptblck -AsJob -Throttle $Throttle |#Pipe
            Receive-Job -Wait -AutoRemoveJob | select FileName,Text,HostName,Path
            }}}
#########End