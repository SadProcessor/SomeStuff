########################################################
## BH_LTI_W64: BloodHound winx64 - Lite Touch Install ##
########################################################

<#
.Synopsis
   BloodHound LTI win64
.DESCRIPTION
   Lite Touch Install (Donut not included)
   
   Can specify alternate install location. (Default: '~/Desktop')
   Can specify versions to intall. (Default: Neo=3.3.2/BH=1.5.1)
   Switch to include sample DB.(Default: no DB)
   
   Script Creates BloodHound folder in specified location 
   Downloads/Unpacks/Installs required stuff.
   Creates bloodhound start/Stop Commands 
   TIP: paste Cmdlets in $profile
   
   Requires Admin (will check)
   Requires Java 64bit (will check)
   Requires user interaction (will wait)
   Stops on Errors
   
.EXAMPLE
   Install-BloodHound
.EXAMPLE
   Install-BloodHound -Location '~/Documents'
   Specify install folder location
   Defaults to Desktop
.EXAMPLE
   Install-BloodHound -BHVersion 'BloodHound-Rolling'
   Specify BloodHound version to install
   Defaults to v1.5.1
.EXAMPLE
   Install-BloodHound -Neo4jVersion '3.2.9'
   Specify Neo4j version to install
   Defaults to v3.3.2
.EXAMPLE
   Install-BloodHound -IncludeSampleDB
   Switch to include BloodHound Sample DB
#>
Function Install-BloodHound{
    [CmdletBinding()]
    Param(
        # Specify BloodHound version
        [ValidateSet('BloodHound-Rolling','1.4','1.3','1.5.1')]
        [Parameter(Mandatory=0)][String]$BHVersion='1.5.1',
        # Specify Neo4j Version
        [ValidateSet('3.3.2','3.2.9')]
        [Parameter(Mandatory=0)][String]$Neo4jVersion='3.3.2',
        # Specify Install Path
        [Parameter(Mandatory=0)][String]$Location='~/Desktop',
        # Include Sample Database
        [Parameter(Mandatory=0)][Switch]$IncludeSampleDB
        )

    ## Checks
    # Admin or Exit
    Write-Host "[+] Checking for Admin..." -ForegroundColor Green
    if(-Not(New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){    
        Write-Host "[!] Needs to run as Admin" -ForegroundColor Red
        Write-Host 'Exiting...'
        Return
        }
    # Java64 (Default location) or Info+Exit
    Write-Host "[+] Checking for Java64..." -ForegroundColor Green
    if(-Not(Test-Path "C:\Program Files\Java\jre*\bin\server\jvm.dll")){
        Write-Host "[!] Java not found" -ForegroundColor Red
        # Instructions
        Write-Host "[>] Go to https://java.com/en/download/manual.jsp" -ForegroundColor Yellow
        Write-Host "[>] Download and Install 'Windows Offline 64-bit'" -ForegroundColor Yellow
        Write-Host 'Exiting...'
        Return
        }
   
    ## Prep
    # Got to Install Location
    cd $Location
    ## Make BH Folder
    Write-Host "[+] Creating BloodHound folder..." -ForegroundColor Green
    $folder = "$pwd\BloodHound"
    $Null = mkdir $Folder
    # Go to folder
    cd $folder
    # Prep URLs
    $Neo_Zip    = "https://neo4j.com/artifact.php?name=neo4j-community-$Neo4jVersion-windows.zip"
    $BH_Zip     = "https://github.com/BloodHoundAD/BloodHound/archive/$BHVersion.zip"
    $BH_bin     = "https://github.com/BloodHoundAD/BloodHound/releases/download/$BHVersion/BloodHound-win32-x64.zip"
    $NeoURL     = 'http://localhost:7474/browser'
    $BoltURL    = 'bolt://localhost:7687'
    $ModulePath = "$Folder\Neo4j\*\bin\Neo4j-Management.psd1"
    $BHPath     = "$folder\BloodHound64\BloodHound-win32-x64\BloodHound.exe"

    # Prep Start/Stop Cmdlets
    $Cmdlets=@("########################################################
# Cmdlets to Start/Stop BloodHound & Neo4j Service
# Note: Path are hard coded at install
# Change path if you hange folder location
# Note: requires Admin to Start/Stop Service
########################################################

<#
.Synopsis
   Start BloodHound
.DESCRIPTION
   Start Neo4j Service and BloodHound GUI
.EXAMPLE
   Start-BloodHound
#>
Function Start-BloodHound{
    [CmdletBinding()]
    Param()
    # Start Neo4j
    `$Null = import-Module `"$ModulePath`" -force -ea stop
    `$Null = invoke-Neo4j start -ea stop
    # Start BloodHound GUI
    iex '$BHPath'
    # Set bolt url to clipboard
    '$BoltURL' | Set-ClipBoard
    }
#End

########################################################

<#
.Synopsis
   Stop BloodHound
.DESCRIPTION
   Stops BloodHound GUI and Neo4j Service
.EXAMPLE
   Stop-BloodHound
#>
Function Stop-BloodHound{
    [CmdletBinding()]
    Param()
    # Kill Process BloodHound
    Kill -Name BloodHound -ea silent
    # Stop Neo4j Service
    `$Null = import-Module `"$ModulePath`" -force -ea stop
    `$Null = Invoke-Neo4j Stop
    }
#End

########################################################
#####################################################EOF")

    ## Download Stuff
    Import-Module BitsTransfer -ea Stop
    # Neo4j
    Write-Host "[+] Downloading Neo4j $Neo4jVersion..." -ForegroundColor Green
    Start-BitsTransfer -Source $Neo_Zip -Destination "Neo4j.zip" -ErrorAction Stop
    # BH Zip
    Write-Host "[+] Downloading BloodHound $BHVersion..." -ForegroundColor Green
    Start-BitsTransfer -Source $BH_Zip -Destination "BloodHoundMaster.zip" -ea stop
    # BH Bin
    Write-Host "[+] Downloading BloodHound Win64..." -ForegroundColor Green
    Write-Host "[I] No progess bar, but we're fine. Just relax..." -ForegroundColor Green
    $Output = "$Folder\BloodHound64.zip"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    (New-Object System.Net.WebClient).DownloadFile($BH_bin, "$pwd\BloodHound64.zip")
    # Extract/Clean Stuff
    (gci *.zip).name |% {
        Write-Host "[+] Extracting $_..." -ForegroundColor Green
        Expand-Archive $_ -Destination $($_.split('.')[0])
        write-Host "[-] Removing $_..."  -ForegroundColor Green
        Remove-Item $_
        }

    ## SampleDB (if)
    if($IncludeSampleDB){
        Write-Host "[+] Installing BloodHound Sample DB" -ForegroundColor Green
        #Copy Sample BloodHound DB to Neo4j folder
        $src = "$folder\BloodHoundMaster\BloodHound-$BHVersion\BloodHoundExampleDB.graphdb"
        $dst = "$folder\Neo4j\neo4j-community-$Neo4jVersion\data\databases\"
        Copy-Item -Path $src -Destination $dst -Recurse -Force
        # Set as DB in conf
        $Config = "$Folder\Neo4j\*\conf\neo4j.conf"
        $old = "#dbms.active_database=graph.db"
        $New = "dbms.active_database=BloodHoundExampleDB.graphdb"
        (get-content $Config).Replace($old,$new) | Set-Content $Config -force

        # Allow DB Upgrade in conf
        Write-Host "[+] Allowing DB Upgrade in Conf" -ForegroundColor Green
        $Config = "$Folder\Neo4j\*\conf\neo4j.conf"
        $old = "#dbms.allow_upgrade=true"
        $New = "dbms.allow_upgrade=true"
        (get-content $Config).Replace($old,$new) | Set-Content $Config -force
        }
    else{Write-Host "[+] Skipping Sample DB Install..." -ForegroundColor Green}

    ## Neo4j
    # import Module
    Write-Host "[+] Importing Neo4j Module..."      -ForegroundColor Green
    Import-Module "$ModulePath" -Force -ErrorAction Stop
    # install Service (+verbose)
    Write-Host "[+] Installing Neo4j Service..."    -ForegroundColor Green
    $Null = Invoke-Neo4j install-service -ea stop
    # Start Service (+verbose)
    Write-Host "[+] Starting Neo4j Service..."      -ForegroundColor Green
    $Null = Invoke-Neo4j start -ea stop
    # Wait & Check if running
    Write-Host "[+] Checking Neo4j Service..."      -ForegroundColor Green
    Start-Sleep -Seconds 3
    # If not
    if((Invoke-Neo4j Status) -ne 0){
        Write-Host "[!] Neo4j Service not running..." -ForegroundColor Red
        Write-Host "[!] Unknown Error..."             -ForegroundColor Red
        Write-Host "[>] Check Neo4j docs for debug"   -ForegroundColor Yellow
        Write-Host "[>] https://neo4j.com/docs/operations-manual/current/installation/windows/" -ForegroundColor Yellow
        Write-Host 'Exiting'
        Return
        }

    # If Sample DB
    if($IncludeSampleDB){
        Write-Host "[-] Revomving DB Upgrade from Conf" -ForegroundColor Green
        # Remove DB Upgrade from conf
        $Config = "$Folder\Neo4j\*\conf\neo4j.conf"
        $old = "dbms.allow_upgrade=true"
        $New = "#dbms.allow_upgrade=true"
        (get-content $Config).Replace($old,$new) | Set-Content $Config -force
        }

    ## Set Password
    # Go to Browser
    Write-Host "[+] Opening neo4j Browser..."            -ForegroundColor Green
    Write-Host "[I] Can take a while. It's Ok. Relax..." -ForegroundColor Green
    start-Process "$NeoURL"
    # Default Password to clipboard
    Write-Host "[+] Setting Clipboard: neo4j"     -ForegroundColor Green
    Set-Clipboard 'neo4j'
    # Show Intructions
    Write-Host "[>] 1 - Paste Clipboard in Password field" -ForegroundColor Yellow
    Write-Host "[>] 2 - Click [Connect]"               -ForegroundColor Yellow
    Write-Host "[>] 3 - Choose New Password"           -ForegroundColor Yellow
    Write-Host "[>] 4 - Click [Change Password]"       -ForegroundColor Yellow
    Write-Host "[>] 5 - Close Browser"                -ForegroundColor Yellow
    # Ask if done
    if((Read-Host "Press [ENTER] when done") -ne ''){Return}

    ## BloodHound
    # Write Cmdlets to file
    $File = "$Folder\BH_Cmdlets.ps1"
    Write-Host "[+] Writing Cmdlets to $File"     -ForegroundColor Green
    $Cmdlets | Out-File -FilePath $file
    # Open BloodHound Interface
    Write-Host "[+] Opening BloodHound Interface" -ForegroundColor Green
    iex "$BHPath" -ea Stop
    # Bolt URL to clipboard
    Write-Host "[+] Setting Clipboard: $BoltURL"  -ForegroundColor Green
    Set-clipboard "$BoltURL"
    # Show Instructions
    Write-Host "[>] 1- Paste Clipboard in URL Database field" -ForegroundColor Yellow
    Write-Host "[>] 2- Enter DB Username: neo4j"        -ForegroundColor Yellow
    Write-Host "[>] 3- Enter New DB Password"           -ForegroundColor Yellow
    Write-Host "[>] 4- Click [login]"                   -ForegroundColor Yellow
    Write-Host "[+] Done. Great Job. Enjoy it..."       -ForegroundColor Green   
    ## Done
    }
#End

#########################################################################
######################################################################EOF
