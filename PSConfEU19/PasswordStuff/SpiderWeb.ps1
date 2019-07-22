#ToDo
# - Move Regex out of scriptblock
# - Move output format out of scriptblock

function Invoke-RemoteRegexSpider{
    [Alias('SpiderWeb')]
    Param(
        # Target ComputerName
        [Parameter(Mandatory=0,ValueFromPipeline=1,ValueFromPipelineByPropertyName=1)][Alias('Target')][String[]]$ComputerName,
        # Input Object
        [Parameter(Mandatory=0)][Alias('FullName')][String[]]$InputObject='~\Documents',
        # Recurse
        [Parameter(Mandatory=0)][Alias('Crawl')][Switch]$Recurse,
        # Search Item
        [ValidateSet('UserName','Password','Email','IPv4','Site','PCP_PrivKey')]        
        [Parameter(Mandatory=0)][Alias('ItemType')][String[]]$Search,
        # Search Extension
        [ValidateSet('txt','ps1','csv')]
        [parameter(Mandatory=0)][Alias('FileType')][String[]]$Extension=@('txt','ps1','csv'),
        # Custom Regex
        [Parameter(Mandatory=0)][Alias('Regex')][String[]]$Pattern,
        # PreContext lines
        [Parameter(Mandatory=0)][Alias('LineBefore')][int]$PreContext=0,
        # PostContext lines
        [Parameter(Mandatory=0)][Alias('LineAfter')][int]$PostContext=0,
        # File Change Days
        [Parameter(Mandatory=0)][Alias('MaxMod')][int]$LastChange=0,
        # Throttle limit
        [Parameter(Mandatory=0)][Int]$Throttle=123
        )
    ## Prep Stuff
    Begin{
        # Prep Empty Target List
        [Collections.ArrayList]$ComputerList=@()
        # Prep ScriptBlock
        $Script = {
            Try{# Import Function Params 
            $InputObject = $using:InputObject
            $Recurse     = $using:Recurse
            $Search      = $using:Search
            $Extension   = $using:Extension
            $Pattern     = $using:Pattern
            $PreContext  = $using:PreContext
            $PostContext = $using:PostContext
            $LastChange  = $using:LastChange
            }Catch{<#Silent Erroe if not remote#>}
            # Regex Collection
            $SpiderRegex = (
                [PSCustomObject]@{Item='UserName'          ; pattern='[u][s][e]?[r][n]?[a]?[m]?[e]?[\:]?[\=]?'},
                [PSCustomObject]@{Item='Password'          ; pattern='[p][a]?[s]?[s]?[w][o]?[r]?[d][\:]?[\=]?'},
                [PSCustomObject]@{Item="email"             ; Pattern="[a-z0-9\.\-+_]+@[a-z0-9\.\-+_]+\.[a-z]+"},
                [PSCustomObject]@{Item="ipv4"              ; Pattern="[0-9]+(?:\.[0-9]+){3}"},
                [PSCustomObject]@{Item="site"              ; Pattern="https?://(?:[-\w.]|(?:%[\da-fA-F]{2}))+"},
                [PSCustomObject]@{Item="phone"             ; Pattern="^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}$"},
                [PSCustomObject]@{Item="Facebook_Oauth"    ; Pattern="[f|F][a|A][c|C][e|E][b|B][o|O][o|O][k|K].*['|\`"][0-9a-f]{32}['|\`"]"},
                [PSCustomObject]@{Item="Twitter_Oauth"     ; Pattern="[t|T][w|W][i|I][t|T][t|T][e|E][r|R].*['|\`"][0-9a-zA-Z]{35,44}['|\`"]"},
                [PSCustomObject]@{Item="Slack_Token"       ; Pattern="(xox[p|b|o|a]-[0-9]{12}-[0-9]{12}-[0-9]{12}-[a-z0-9]{32})"},
                [PSCustomObject]@{Item="GitHub"            ; Pattern="[g|G][i|I][t|T][h|H][u|U][b|B].*[['|\`"]0-9a-zA-Z]{35,40}['|\`"]"},
                [PSCustomObject]@{Item="Google_Oauth"      ; Pattern='(\"client_secret\":\"[a-zA-Z0-9-_]{24}\")'},
                [PSCustomObject]@{Item="Heroku_API_Key"    ; Pattern="[h|H][e|E][r|R][o|O][k|K][u|U].*[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}"},
                [PSCustomObject]@{Item="AWS_API_Key"       ; Pattern="AKIA[0-9A-Z]{16}"},
                [PSCustomObject]@{Item="PGP_Privkey"       ; Pattern="-----BEGIN PGP PRIVATE KEY BLOCK-----"},
                [PSCustomObject]@{Item="RSA_Privkey"       ; Pattern="-----BEGIN RSA PRIVATE KEY-----"},
                [PSCustomObject]@{Item="SSH_DSA_Privkey"   ; Pattern="-----BEGIN DSA PRIVATE KEY-----"},
                [PSCustomObject]@{Item="SSH_EC_Privkey"    ; Pattern="-----BEGIN EC PRIVATE KEY-----"},
                [PSCustomObject]@{Item="SSH_OPNSSH_PrivKey"; Pattern="-----BEGIN OPENSSH PRIVATE KEY-----"},
                [PSCustomObject]@{Item="GenericSecret"     ; Pattern="[s|S][e|E][c|C][r|R][e|E][t|T].*['|\`"][0-9a-zA-Z]{32,45}['|\`"]"}
                )
            # Prep Vars
            $ThisHost = $env:COMPUTERNAME
            if($Recurse){$Rcrs=@{Recurse=$true}}
            $FileList=@()
            # Prep Regex List
            if(    $Pattern.count -AND -Not$Search.Count){$RegexList=@($Pattern)}
            if(-Not$Pattern.count -AND -Not$Search.Count){$RegexList=@($SpiderRegex.Pattern)}
            if(-Not$Pattern.count -AND     $Search.Count){$RegexList=@(($SpiderRegex|where{$_.Item -in @($search)}).Pattern)}
            if(    $Pattern.count -AND     $Search.Count){$RegexList=@(($SpiderRegex|where{$_.Item -in @($search)}).Pattern)+$Pattern}
            # For each input obj
            foreach($Thing in $InputObject){
                # Test if File or Folder
                if(Test-Path $Thing){
                    Switch -Regex((Get-item $Thing).Attributes){
                        # If Folder
                        Directory{
                            # Filter Extension
                            $File = (Get-ChildItem $Thing @Rcrs -File |where {$_.extension.TrimStart('.') -In $Extension})
                            # Filter Last Change
                            if($LastChange -ne 0){$File = $File | where LastWriteTime -lt (Get-Date).adddays(-$LastChange)}
                            # Add to List
                            $FileList += $File
                            }
                        # IF File, add to List
                        Archive{$FileList += Get-Item $Thing}
                        }}}
            # Select-String
            $FileList | Select-String -Pattern $RegexList -Context $PreContext,$PostContext -AllMatches | select * |%{
                # Get matching item name
                if($_.Pattern -in $SpiderRegex.Pattern){$ThisItem = ($SpiderRegex |? Pattern -eq $_.Pattern).Item}
                Else{$ThisItem = 'Custom'}
                [PSCustomObject]@{
                    FileName = $_.fileName
                    Line     = $_.LineNumber
                    Item     = $ThisItem
                    Match    = $_.Matches.Value
                    Pattern  = $_.Pattern
                    Host     = $ThisHost
                    FullName = $_.Path
                    Context  = (((($_.Context|select -Expand PreContext)-join"`r`n"),$_.line,(($_.Context|select -Expand PostContext)-join"`r`n"))-join"`r`n").trim()                                
                    }}
            }<#EndScript#>
        }
    ## Collect Pipeline Computernames
    Process{foreach($Cmptr in $ComputerName){$Null = $ComputerList.Add($Cmptr)}}
    End{## Invoke Scriptblock
        if($ComputerList.Count){
            # Ask for Creds
            $Cred = Get-Credential -Message 'Enter Creds for Remote Computers' -UserName $env:USERNAME
            Invoke-Command -VMName $ComputerList -Cred $Cred -Script $Script -AsJob -Throttle $Throttle |#Pipe
            Receive-Job -Wait -AutoRemoveJob | select FileName,Line,Item,Match,Pattern,Host,Fullname,Context
            }
        else{Invoke-Command -ScriptBlock $Script}
        }}
#####End


Invoke-RemoteRegexSpider -InputObject ~\desktop -Recurse -Search Password