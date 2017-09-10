 <#
.Synopsis
   King Pong - The Ping Kong...
.DESCRIPTION
   Power Ping: Multi-NIC/Auto-Subnet/Multi-Thread.
   Returns only IPs where Success.
   Inspired by a tweet from @Lee_Holmes.
.EXAMPLE
   Pong
.LINK
   https://twitter.com/Lee_Holmes/status/646890380995067904
#>
Function Invoke-KingPong{
    [CmdletBinding()]
    [Alias('Pong')]
    Param()
    Begin{
        ## Subs
        # IP to Num
        function IP2NUM{Param([String]$IP); return [int64]([int64]$IP.split(".")[0]*16777216+[int64]$IP.split(".")[1]*65536+[int64]$IP.split(".")[2]*256+[int64]$IP.split(".")[3])} 
        # Num to IP
        function NUM2IP{Param([Int64]$Num); return (([math]::truncate($Num/16777216)).tostring()+"."+([math]::truncate(($Num%16777216)/65536)).tostring()+"."+([math]::truncate(($Num%65536)/256)).tostring()+"."+([math]::truncate($Num%256)).tostring())}
        ## Prep
        # Prep empty IP list
        $IPList = @()
        # Get NICs
        $NICList = Gwmi win32_networkadapterconfiguration | Where defaultIPGateway -ne $null
        }
    Process{
        # List IPs to Ping
        Foreach($NIC in $NICList){
            # IP & Mask
            $IP   = [Net.IPAddress]::Parse($NIC.ipaddress[0])
            $Mask = [Net.IPAddress]::Parse($NIC.ipsubnet[0])
            # Network & Broadcast
            $Ntwrk  = New-Object net.IPAddress ($Mask.address -band $IP.address)
            $Brdcst = New-Object Net.IPAddress ([Net.IPAddress]::parse("255.255.255.255").address -bxor $Mask.address -bor $Ntwrk.address)
            Write-Verbose "$($Ntwrk.IPAddressToString) / $Mask" 
            # Start & End
            $Start = (IP2NUM -IP $ntwrk.ipaddresstostring)  +1
            $End   = (IP2NUM -IP $brdcst.ipaddresstostring) -1
            # Add IPs to IPList
            For($n=$Start; $n -le $End; $n++){$IPList += NUM2IP -Num $n}
            }
        # Ping IP List
        $Ping = $IPList | sort -Unique | %{(New-Object Net.NetworkInformation.Ping).SendPingAsync($_,250)}
        [Threading.Tasks.Task]::WaitAll($Ping) 
        # Get IPs where Success
        $Success = ($Ping.Result | ? Status -eq Success | Select -ExpandProp address).IPAddressToString
        Write-Verbose "Success: $($Success.count) / $($Ping.Result.count)"
        }
    End{return $Success}
    } 
