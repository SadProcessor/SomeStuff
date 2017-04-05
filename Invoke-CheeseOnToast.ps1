  <#
 .Synopsis
    Priv Esc Finder via WMI
 .DESCRIPTION
    This is a WMI Dub of 'Sherlock' by @_RastaMouse
    Queries local and remote hosts for specific file versions and determines if possible vuln
    Accepts multiple targets at once. List of Targets can be passed over pipeline
    Scans for all by default. Specify Vulns to restrict search
    Returns only found vulns by default. Specify '-ShowAll' for full report
    Shows only basic props by default. Pipe to 'Select *' for full props
    Accepts user/password in plain text (RedTeam) or via Password dialog-box (BlueTeam/Admins)
    Creds used only for remote hosts
    Defaults to current user if not specifed
    Note: if first WMI query to host fails > no other queries to that host 
 .EXAMPLE
    CheeseOnToast
    Runs all tests against localhost
 .EXAMPLE
    CheeseOnToast MS10015,MS16032
    Tests only for specified vulns 
 .EXAMPLE
    CheeseOnToast -Target OtherPC
    Test all on remote target (as current user)
 .EXAMPLE
    CheeseOnToast -Target OtherPC -CredBox
    Specify Creds via CredBox
 .EXAMPLE
    'PC1','PC2','PC3' | CheeseOnToast -ShowAll | select *
    MegaMix
 .EXAMPLE
    23..123 | %{"10.2.3.$_"} | CheeseOnToast -U Bob -P Secret123
    LuckyShot 100 hosts
 .EXAMPLE
    Help CheeseOnToast -Online
    Wheel-Up Selecta !!
 .INPUTS
    Accepts list of Targets via pipeline
 .OUTPUTS
    Basic Object properties as default view
    "-ShowAll"   to view other results than true
    "| select *" to view full props
 .NOTES
    ## Extra Vuln Info ##
    MSBulletin : # MS10-015
    Title      : User Mode to Ring (KiTrap0D)
    CVEID      : 2010-0232
    Link       : https://www.exploit-db.com/exploits/11199/

    MSBulletin : # MS10-092
    Title      : Task Scheduler .XML
    CVEID      : 2010-3338, 2010-3888
    Link       : https://www.exploit-db.com/exploits/19930/

    MSBulletin : MS13-053
    Title      : NTUserMessageCall Win32k Kernel Pool Overflow
    CVEID      : 2013-1300
    Link       : https://www.exploit-db.com/exploits/33213/

    MSBulletin : # MS13-081
    Title      : TrackPopupMenuEx Win32k NULL Page
    CVEID      : 2013-3881
    Link       : https://www.exploit-db.com/exploits/31576/

    MSBulletin : # MS14-058
    Title      : TrackPopupMenu Win32k Null Pointer Dereference
    CVEID      : 2014-4113
    Link       : https://www.exploit-db.com/exploits/35101/

    MSBulletin : MS15-051
    Title      : ClientCopyImage Win32k
    CVEID      : 2015-1701, 2015-2433
    Link       : https://www.exploit-db.com/exploits/37367/

    MSBulletin : # MS15-078
    Title      : Font Driver Buffer Overflow
    CVEID      : 2015-2426, 2015-2433
    Link       : https://www.exploit-db.com/exploits/38222/

    MSBulletin : # MS16-016
    Title      : 'mrxdav.sys' WebDAV
    CVEID      : 2016-0051
    Link       : https://www.exploit-db.com/exploits/40085/

    MSBulletin : # MS16-032
    Title      : Secondary Logon Handle
    CVEID      : 2016-0099
    Link       : https://www.exploit-db.com/exploits/39719/
 .COMPONENT
    Uses WMI queries
    Right requirements based on Target (user/password)
 .FUNCTIONALITY
    Used to assess windows network security
 .LINK
    https://www.youtube.com/watch?v=ASIS_6NC_OE
    
 #>
Function Invoke-CheeseOnToast{
    [CmdletBinding(DefaultParameterSetname='Dirty')]
    [Alias('CheeseOnToast')]
    Param(
        # Vuln
        [ValidateSet('MS10015','MS10092','MS13053','MS13081','MS14058','MS15051','MS15078','MS16016','MS16032')]
        [Parameter(Position=0,Mandatory=$false)][String[]]$Vuln,
        # Target (defaults to LocalHost)
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)][Alias('Target','T')][String[]]$ComputerName=$env:COMPUTERNAME,
        # UserName (defaults to Current User)
        [Parameter(Mandatory=$false,ParameterSetname='Dirty')][Alias('U')][String]$User=$env:USERNAME,
        # Password
        [Parameter(Mandatory=$false,ParameterSetname='Dirty')][Alias('P')][String]$Pass,
        # CredBox if you prefer
        [Parameter(Mandatory=$true,ParameterSetname='Clean')][Alias('C')][Switch]$CredBox,
        # Show All (by default only return risk -eq $true)
        [Parameter(Mandatory=$false)][Alias('All','A')][Switch]$ShowAll
        )
    # Prep
    Begin{
        # Empty result
        $Result = @()
        # Creds | Password
        $Creds = @{}
        if($PSCmdlet.ParameterSetName -eq 'Clean'){$Creds = Get-Credential -UserName $env:USERNAME -Message 'Please Enter Creds'}
        Else{if($Pass){$Creds['Credential'] = New-Object System.Management.Automation.PSCredential -ArgumentList $User,$(ConvertTo-SecureString $Pass -AsPlainText -Force)}}
        
        # Bool Menu
        switch($Vuln){
            'MS10015'{$MS10015=$true}
            'MS10092'{$MS10092=$true}
            'MS13053'{$MS13053=$true}
            'MS13081'{$MS13081=$true}
            'MS14058'{$MS14058=$true}
            'MS15051'{$MS15051=$true}
            'MS15078'{$MS15078=$true}
            'MS16016'{$MS16016=$true}
            'MS16032'{$MS16032=$true}
             Default {$MS10015=$MS10092=$MS13053=$MS13081=$MS14058=$MS15051=$MS15078=$MS16016=$MS16032=$true}
            }
        }
    # Action
    Process{<#Pipeline In#>
        Foreach($Target in $ComputerName){
            Write-Verbose "TARGET = $Target"
            #Bool Local Query
            $Local = $Null
            if($target -in ($env:COMPUTERNAME,'localhost','127.0.0.1')){$Local=$true;$target=$env:COMPUTERNAME}
            
            # Get Drive & Arch
            $Drive = try{if($local){(Gwmi Win32_OperatingSystem -ea sil).SystemDrive}Else{(Gwmi Win32_OperatingSystem -Computer $target @Creds -ea sil).SystemDrive}}catch{} 
            
            # if connection OK
            if($Drive){
                $OS   = if($Local){(Gwmi Win32_OperatingSystem -ea sil).OSArchitecture}Else{(Gwmi Win32_OperatingSystem -Computer $target @Creds -ea sil).OSArchitecture}
                $Proc = if($local){(Gwmi Win32_Processor -ea sil).addressWidth}Else{(Gwmi Win32_Processor -Computer $target @Creds -ea sil).addressWidth}
                Write-Verbose "Proc = $Proc";Write-Verbose "OS = $OS"
                #### Check For Vuln ####
                
                ## MS10015
                if($MS10015){
                    $Item='MS10-015';$Path='\\Windows\\System32\\';$file='ntoskrnl';$ext='exe'
                    # Get Version
                    $Query   = "SELECT * FROM CIM_DataFile WHERE Drive ='$Drive' AND Path='$Path' AND FileName='$file' AND Extension='$ext'"
                    $Version =  if($Local){(Gwmi -Q $Query).version}Else{(Gwmi -Q $Query -Computer $Target @Creds).version}
                    $Build = $version.split('.')[2]
                    $Rev = $version.split('.')[3]
                    # Translate to risk
                    if($OS -eq '64-bit'){$risk='n/a'}
                    else{
                        $risk=$false
                        if($Build -eq 7600 -AND $rev -le 20591){$risk=$true}
                        }
                    #Create Obj & Add to result
                    Write-Verbose "MS = $Item";Write-Verbose "Version = $Version";Write-Verbose "Risk = $Risk"
                    $Props = @{'Target'=$target;'OS'=$OS;'Proc'=$Proc;'MS'=$Item;'File'="$file.$ext";'Version'=$Version;'Risk'=$Risk}
                    $Result += New-Object PSCustomObject -Prop $Props
                    }

                ## MS10092           
                if($MS10092){
                    $Item='MS10-092';$Path='\\Windows\\System32\\';$file='schedsvc';$ext='dll'
                    # Get Version
                    $Query   = "SELECT * FROM CIM_DataFile WHERE Drive ='$Drive' AND Path='$Path' AND FileName='$file' AND Extension='$ext'"
                    $Version =  if($Local){(Gwmi -Q $Query).version}Else{(Gwmi -Q $Query -Computer $Target @Creds).version}
                    $Build = $version.split('.')[2]
                    $Rev = $version.split('.')[3]
                    # Translate to risk
                    $Risk=$false
                    if($OS -eq '32-bit' -AND $Proc -eq 64){if($Build -eq 7600 -AND $rev -le 20830){$risk=$true}}
                    #if($OS -eq '64-bit' -AND $Proc -eq 32){$risk='red'}
                    #Create Obj & Add to result
                    Write-Verbose "MS = $Item";Write-Verbose "Version = $Version";Write-Verbose "Risk = $Risk"
                    $Props = @{'Target'=$target;'OS'=$OS;'Proc'=$Proc;'MS'=$Item;'File'="$file.$ext";'Version'=$Version;'Risk'=$Risk}
                    $Result += New-Object PSCustomObject -Prop $Props
                    }                
                
                ## MS13053
                if($MS13053){
                    $Item='MS13-053';$Path='\\Windows\\System32\\';$file='win32k';$ext='sys'
                    # Get Version
                    $Query   = "SELECT * FROM CIM_DataFile WHERE Drive ='$Drive' AND Path='$Path' AND FileName='$file' AND Extension='$ext'"
                    $Version =  if($Local){(Gwmi -Q $Query).version}Else{(Gwmi -Q $Query -Computer $Target @Creds).version}
                    $Build = $version.split('.')[2]
                    $Rev = $version.split('.')[3]
                    # Translate to risk
                    $Risk=$false
                    if($OS -eq '64-bit'){$risk='n/a'}
                    else{
                        if($Build -eq 7600 -AND $Rev -ge 17000){$Risk=$true}
                        if($Build -eq 7601 -AND $Rev -le 22348){$Risk=$true}
                        if($Build -eq 9200 -AND $Rev -le 20723){$Risk=$true}
                        }
                    #Create Obj & Add to result
                    Write-Verbose "MS = $Item";Write-Verbose "Version = $Version";Write-Verbose "Risk = $Risk"
                    $Props = @{'Target'=$target;'OS'=$OS;'Proc'=$Proc;'MS'=$Item;'File'="$file.$ext";'Version'=$Version;'Risk'=$Risk}
                    $Result += New-Object PSCustomObject -Prop $Props             
                    }
                
                ## MS13081
                if($MS13081){
                    $Item='MS13-081';$Path='\\Windows\\System32\\';$file='win32k';$ext='sys'
                    # Get Version
                    $Query   = "SELECT * FROM CIM_DataFile WHERE Drive ='$Drive' AND Path='$Path' AND FileName='$file' AND Extension='$ext'"
                    $Version =  if($Local){(Gwmi -Q $Query).version}Else{(Gwmi -Q $Query -Computer $Target @Creds).version}
                    $Build = $version.split('.')[2]
                    $Rev = $version.split('.')[3]
                    # Translate to risk
                    $Risk=$false
                    if($OS -eq '64-bit'){$risk='n/a'}
                    else{
                        if($Build -eq 7600 -AND $Rev -ge "18000"){$Risk=$true}
                        if($Build -eq 7601 -AND $Rev -le "22435"){$Risk=$true}
                        if($Build -eq 9200 -AND $Rev -le "20807"){$Risk=$true}
                        }
                    #Create Obj & Add to result
                    Write-Verbose "MS = $Item";Write-Verbose "Version = $Version";Write-Verbose "Risk = $Risk"
                    $Props = @{'Target'=$target;'OS'=$OS;'Proc'=$Proc;'MS'=$Item;'File'="$file.$ext";'Version'=$Version;'Risk'=$Risk}
                    $Result += New-Object PSCustomObject -Prop $Props               
                    }
                
                ## MS14058
                if($MS14058){
                    $Item='MS14-058';$Path='\\Windows\\System32\\';$file='win32k';$ext='sys'
                    # Get Version
                    $Query   = "SELECT * FROM CIM_DataFile WHERE Drive ='$Drive' AND Path='$Path' AND FileName='$file' AND Extension='$ext'"
                    $Version =  if($Local){(Gwmi -Q $Query).version}Else{(Gwmi -Q $Query -Computer $Target @Creds).version}
                    $Build = $version.split('.')[2]
                    $Rev = $version.split('.')[3]
                    # Translate to risk
                    $Risk=$false
                    if($OS -eq '32-bit' -OR $proc -eq 64){
                        if($Build -eq 7600 -AND $Rev -ge 18000){$Risk=$true}
                        if($Build -eq 7601 -AND $Rev -le 22823){$Risk=$true}
                        if($Build -eq 9200 -AND $Rev -le 21247){$Risk=$true}
                        if($Build -eq 9600 -AND $Rev -le 17353){$Risk=$true}
                        }
                    #Create Obj & Add to result
                    Write-Verbose "MS = $Item";Write-Verbose "Version = $Version";Write-Verbose "Risk = $Risk"
                    $Props = @{'Target'=$target;'OS'=$OS;'Proc'=$Proc;'MS'=$Item;'File'="$file.$ext";'Version'=$Version;'Risk'=$Risk}
                    $Result += New-Object PSCustomObject -Prop $Props            
                    }
                
                ## MS15051
                if($MS15051){
                    $Item='MS15-051';$Path='\\Windows\\System32\\';$file='win32k';$ext='sys'
                    # Get Version
                    $Query   = "SELECT * FROM CIM_DataFile WHERE Drive ='$Drive' AND Path='$Path' AND FileName='$file' AND Extension='$ext'"
                    $Version =  if($Local){(Gwmi -Q $Query).version}Else{(Gwmi -Q $Query -Computer $Target @Creds).version}
                    $Build = $version.split('.')[2]
                    $Rev = $version.split('.')[3]
                    # Translate to risk
                    $Risk=$false
                    if($OS -eq '32-bit' -OR $proc -eq 64){
                        if($Build -eq 7600 -AND $Rev -ge 18000){$Risk=$true}
                        if($Build -eq 7601 -AND $Rev -le 22823){$Risk=$true}
                        if($Build -eq 9200 -AND $Rev -le 21247){$Risk=$true}
                        if($Build -eq 9600 -AND $Rev -le 17353){$Risk=$true}
                        }
                    #Create Obj & Add to result
                    Write-Verbose "MS = $Item";Write-Verbose "Version = $Version";Write-Verbose "Risk = $Risk"
                    $Props = @{'Target'=$target;'OS'=$OS;'Proc'=$Proc;'MS'=$Item;'File'="$file.$ext";'Version'=$Version;'Risk'=$Risk}
                    $Result += New-Object PSCustomObject -Prop $Props               
                    }
                
                ## MS15078
                if($MS15078){
                    $Item='MS15-078';$Path='\\Windows\\System32\\';$file='atmfd';$ext='dll'
                    # Get Version
                    $Query   = "SELECT * FROM CIM_DataFile WHERE Drive ='$Drive' AND Path='$Path' AND FileName='$file' AND Extension='$ext'"
                    $Version =  if($Local){(Gwmi -Q $Query).version}Else{(Gwmi -Q $Query -Computer $Target @Creds).version}
                    $Rev = $Version.split('.')[2]                    
                    # Translate to risk
                    $Risk=$false
                    if($rev -eq 243){$Risk=$true}
                    #Create Obj & Add to result
                    Write-Verbose "MS = $Item";Write-Verbose "Version = $Version";Write-Verbose "Risk = $Risk"
                    $Props = @{'Target'=$target;'OS'=$OS;'Proc'=$Proc;'MS'=$Item;'File'="$file.$ext";'Version'=$Version;'Risk'=$Risk}
                    $Result += New-Object PSCustomObject -Prop $Props             
                    }
                
                ## MS16016
                if($MS16016){
                    $Item='MS16-016';$Path='\\Windows\\System32\\Drivers\\';$file='mrxdav';$ext='sys'
                    # Get Version
                    $Query   = "SELECT * FROM CIM_DataFile WHERE Drive ='$Drive' AND Path='$Path' AND FileName='$file' AND Extension='$ext'"
                    $Version =  if($Local){(Gwmi -Q $Query).version}Else{(Gwmi -Q $Query -Computer $Target @Creds).version}
                    $Build = $version.split('.')[2]
                    $Rev = $version.split('.')[3]
                    # Translate to risk
                    $Risk=$false
                    if($OS -eq '64-bit'){$risk='n/a'}
                    Else{
                        if($Build -eq 7600  -AND $Rev -ge 16000){$Risk=$true}
                        if($Build -eq 7601  -AND $Rev -le 23317){$Risk=$true}
                        if($Build -eq 9200  -AND $Rev -le 21738){$Risk=$true}
                        if($Build -eq 9600  -AND $Rev -le 18189){$Risk=$true}
                        if($Build -eq 10240 -AND $Rev -le 16683){$Risk=$true}
                        if($Build -eq 10586 -AND $Rev -le   103){$Risk=$true}
                        }
                    #Create Obj & Add to result
                    Write-Verbose "MS = $Item";Write-Verbose "Version = $Version";Write-Verbose "Risk = $Risk"
                    $Props = @{'Target'=$target;'OS'=$OS;'Proc'=$Proc;'MS'=$Item;'File'="$file.$ext";'Version'=$Version;'Risk'=$Risk}
                    $Result += New-Object PSCustomObject -Prop $Props
                    #Add to result
                    $Result += $obj                
                    }
                
                ## MS16032
                if($MS16032){
                    $Item='MS16-032';$Path='\\Windows\\System32\\';$file='seclogon';$ext='dll'
                    # Get Version
                    $Query   = "SELECT * FROM CIM_DataFile WHERE Drive ='$Drive' AND Path='$Path' AND FileName='$file' AND Extension='$ext'"
                    $Version =  if($Local){(Gwmi -Q $Query).version}Else{(Gwmi -Q $Query -Computer $Target @Creds).version}
                    $Build = $version.split('.')[2]
                    $Rev = $version.split('.')[3]
                    # Translate to risk
                    $Risk=$false
                    if($OS -eq '32-bit' -or $Proc -eq 64){
                        if($Build -eq 7600  -AND $Rev -ge 16000){$Risk=$true}
                        if($Build -eq 7601  -AND $Rev -le 23348){$Risk=$true}
                        if($Build -eq 9200  -AND $Rev -le 21768){$Risk=$true}
                        if($Build -eq 9600  -AND $Rev -le 18230){$Risk=$true}
                        if($Build -eq 10240 -AND $Rev -le 16724){$Risk=$true}
                        if($Build -eq 10586 -AND $Rev -le   162){$Risk=$true} 
                        }
                    #Create Obj & Add to result
                    Write-Verbose "MS = $Item";Write-Verbose "Version = $Version";Write-Verbose "Risk = $Risk"
                    $Props = @{'Target'=$target;'OS'=$OS;'Proc'=$Proc;'MS'=$Item;'File'="$file.$ext";'Version'=$Version;'Risk'=$Risk}
                    $Result += New-Object PSCustomObject -Prop $Props               
                    }

                ########### End Vulns ###########
                }
            # Else = connection not OK
            else{<# No WMI? No Creds? ... ??#>
                Write-Verbose "ERROR: Can't reach target"
                $Props = @{'Target'=$target;'MS'='?';'OSArch'='?';'ProcArch'='?';'File'='?';'Version'='?';'Risk'='?'}
                $result += New-Object PSCustomObject -Prop $Props
                }
            }
        }
    # Finish
    End{
        ## Default Format ( ... | select * >> display full object)
        # default display set
        $defaultDisplaySet = 'Target','MS','Risk'
        # default property display set
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’,[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        #Give Result typename
        $Result.PSObject.TypeNames.Insert(0,'Test.Result')
        $Result | Add-Member MemberSet PSStandardMembers $PSStandardMembers -EA sil 

        #Return Result
        if(!$ShowAll){$Result = $Result | where Risk -eq $true}
        Return $Result
        }
    }

 
