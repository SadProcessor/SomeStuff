<##>
function Invoke-PXECheck{
    Param(
        # MAC Address String
        [Parameter(Mandatory=0)][String]$MAC="AA:BB:CC:DD:EE:FF",
        # UUID String
        [Parameter(Mandatory=0)][String]$UUID="AABBCCDD-AABB-AABB-AABB-AABBCCDDEEFF",
        # Proc Architecture [0:x86-x64Bios|6:x86UEFI|7:x64UEFI|9:xEFIBC]
        [ValidateSet(0,6,7,9)]
        [Parameter(Mandatory=0)][int]$Arch =0, 
        # Discovery timeout
        [Parameter(Mandatory=0)][Byte]$TimeOut=60,
        # Show DHCP Reply
        [Parameter(Mandatory=0)][Switch]$ShowObj
        )
    
    #### INTERNALS ####
    
    ## Vars
    [string]$Opt60String = "PXEClient"

    ## DHCP Discover Packet 
    Function NewDiscoPack{
        Param([String]$MAC = "AA:BB:CC:DD:EE:FF")
        # Generate Transaction ID
        $XID = New-Object Byte[] 4
        $Random = New-Object Random
        $Random.NextBytes($XID)
        # MAC String to Byte Array
        $MAC = $MAC -Replace "-|:" 
        $MACAdrs = [BitConverter]::GetBytes(([UInt64]::Parse($MAC,[Globalization.NumberStyles]::HexNumber)))
        # Reverse MAC Array
        [Array]::Reverse($MACAdrs)
        # Create the Byte Array
        $DHDisco = New-Object Byte[] 243
        # Copy Transaction ID Bytes
        [Array]::Copy($XID,0,$DHDisco,4,4) 
        # Copy MacAddress Bytes
        [Array]::Copy($MACAdrs,2,$DHDisco,28,6) 
        # OP Code = BOOTREQUEST
        $DHDisco[0]   = 1
        # Hardware Adrs Type = ehternet
        $DHDisco[1]   = 1
        # Hardware Adrs Length (bytes)
        $DHDisco[2]   = 6
        # Broadcast Flag
        $DHDisco[10]  = 128
        # Magic Cookie
        $DHDisco[236] = 99
        $DHDisco[237] = 130
        $DHDisco[238] = 83
        $DHDisco[239] = 99
        # Message Type
        $DHDisco[240] = 53
        $DHDisco[241] = 1
        $DHDisco[242] = 1
        # Set Opt 60
        $DHD_Opt60    = New-Object Byte[] 2
        $DHD_Opt60[0] = 60
        $DHD_Opt60[1] = [System.Text.Encoding]::ASCII.GetBytes($Opt60String).Length
        $Opt60Array   = [System.Text.Encoding]::ASCII.GetBytes($Opt60String)
        $DHD_Opt60   += $Opt60Array
        $DHDisco     += $DHD_Opt60
        # Set Opt 93
        $DHD_Opt93 = New-Object Byte[] 4
        $DHD_Opt93[0] = 93
        $DHD_Opt93[1] = 2
        $DHD_Opt93[2] = 0
        $DHD_Opt93[3] = $Arch
        $DHDisco     += $DHD_Opt93
        # Set the Option #97
        $DHD_Opt97    = New-Object Byte[] 2
        $DHD_Opt97[0] = 97
        $DHD_Opt97[1] = 36 #Length of UUID
        $UUIDarray    = [System.Text.Encoding]::ASCII.GetBytes($UUID)
        $DHD_Opt97   += $UUIDarray
        $DHDisco     += $DHD_Opt97
        # Return Disco
        Return $DHDisco
        }
    #End

    ## Read DHCP response 
    Function ReadPack([Byte[]]$Packet){
        # Reader Obj
        $R = New-Object IO.BinaryReader(New-Object IO.MemoryStream(@(,$Packet)))
        # DHCP Response Obj
        $DHResp = New-Object Object
        # Translate Op code
        $DHResp | Add-Member NoteProperty Op $R.ReadByte()
        if($DHResp.Op -eq 1){$DHResp.Op = "BootRequest"} 
        else{$DHResp.Op = "BootResponse"}
        # Props
        $DHResp | Add-Member NoteProperty HType -Value $R.ReadByte()
    
        if($DHResp.HType -eq 1){$DHResp.HType = "Ethernet"}
    
        $DHResp | Add-Member NoteProperty HLen  $R.ReadByte()
        $DHResp | Add-Member NoteProperty Hops  $R.ReadByte()
        $DHResp | Add-Member NoteProperty XID   $R.ReadUInt32()
        $DHResp | Add-Member NoteProperty Secs  $R.ReadUInt16()
        $DHResp | Add-Member NoteProperty Flags $R.ReadUInt16()
    
        # Broadcast flag only (other bits are reserved)
        if ($DHResp.Flags -BAnd 128){$DHResp.Flags = @("Broadcast")}
    
        $DHResp | Add-Member NoteProperty CIAddr $("$($R.ReadByte()).$($R.ReadByte()).$($R.ReadByte()).$($R.ReadByte())")    
        $DHResp | Add-Member NoteProperty YIAddr $("$($R.ReadByte()).$($R.ReadByte()).$($R.ReadByte()).$($R.ReadByte())")
        $DHResp | Add-Member NoteProperty SIAddr $("$($R.ReadByte()).$($R.ReadByte()).$($R.ReadByte()).$($R.ReadByte())")
        $DHResp | Add-Member NoteProperty GIAddr $("$($R.ReadByte()).$($R.ReadByte()).$($R.ReadByte()).$($R.ReadByte())")
 
        $MACBytes = New-Object Byte[] 16
        [Void]$R.Read($MACBytes, 0, 16)
        $MACAdrs = [String]::Join(":", $($MACBytes[0..5] | %{ [String]::Format('{0:X2}', $_) }))
    
        $DHResp | Add-Member NoteProperty CHAddr $MACAdrs
        $DHResp | Add-Member NoteProperty SName $([String]::Join("", $R.ReadChars(64)).Trim())    
        $DHResp | Add-Member NoteProperty File $([String]::Join("", $R.ReadChars(128)).Trim()) 
        $DHResp | Add-Member NoteProperty MagicCookie $("$($R.ReadByte()).$($R.ReadByte()).$($R.ReadByte()).$($R.ReadByte())")
 
        # Read Options
        $DHResp | Add-Member NoteProperty Options @()
        While ($R.BaseStream.Position -lt $R.BaseStream.Length){
            $Opt = New-Object Object
            $Opt | Add-Member NoteProperty OptionCode $R.ReadByte()
            $Opt | Add-Member NoteProperty OptionName ""
            $Opt | Add-Member NoteProperty Length 0
            $Opt | Add-Member NoteProperty OptionValue ""
            # if OptCode not 0|255
            If($Opt.OptionCode -ne 0 -And $Opt.OptionCode -ne 255){$Opt.Length = $R.ReadByte()}
            # Switch OptCode
            Switch ($Opt.OptionCode){
                # Pad
                0 { $Opt.OptionName  = "PadOption" }
                # SubNet
                1 { $Opt.OptionName  = "SubnetMask"
                    $Opt.OptionValue = $("$($R.ReadByte()).$($R.ReadByte()).$($R.ReadByte()).$($R.ReadByte())")
                    }
                # Router
                3 { $Opt.OptionName  = "Router"
                    $Opt.OptionValue = $("$($R.ReadByte()).$($R.ReadByte()).$($R.ReadByte()).$($R.ReadByte())")
                    }
                # DNS
                6 { $Opt.OptionName  = "DomainNameServer"
                    $Opt.OptionValue = @()
                    For ($i = 0; $i -lt ($Opt.Length / 4); $i++){ 
                        $Opt.OptionValue += $("$($R.ReadByte()).$($R.ReadByte()).$($R.ReadByte()).$($R.ReadByte())")
                        }}
                # Domain Name
                15 {$Opt.OptionName  = "DomainName"
                    $Opt.OptionValue = [String]::Join("", $R.ReadChars($Opt.Length))
                    }
                # Lease Time
                51 {$Opt.OptionName = "IPAddressLeaseTime"
                    # Read as Big Endian
                    $Value = ($R.ReadByte() * [Math]::Pow(256, 3))+($R.ReadByte() * [Math]::Pow(256, 2))+($R.ReadByte() * 256)+$R.ReadByte()
                    $Opt.OptionValue = $(New-TimeSpan -Seconds $Value)
                    }
                # DHCP Message Type
                53 {$Opt.OptionName = "DhcpMessageType"
                    Switch ($R.ReadByte()){
                        1 { $Opt.OptionValue = "DHCPDISCOVER" }
                        2 { $Opt.OptionValue = "DHCPOFFER"    }
                        3 { $Opt.OptionValue = "DHCPREQUEST"  }
                        4 { $Opt.OptionValue = "DHCPDECLINE"  }
                        5 { $Opt.OptionValue = "DHCPACK"      }
                        6 { $Opt.OptionValue = "DHCPNAK"      }
                        7 { $Opt.OptionValue = "DHCPRELEASE"  }
                        }}
                # DHCP Server Identifier
                54 {$Opt.OptionName  = "DhcpServerIdentifier"
                    $Opt.OptionValue = $("$($R.ReadByte()).$($R.ReadByte()).$($R.ReadByte()).$($R.ReadByte())")
                    }
                # Renewal Time
                58 {$Opt.OptionName  = "RenewalTime"
                    $Value = ($R.ReadByte()*[Math]::Pow(256, 3))+($R.ReadByte()*[Math]::Pow(256,2))+($R.ReadByte()*256)+$R.ReadByte()
                    $Opt.OptionValue = $(New-TimeSpan -Seconds $Value)
                    }
                # Rebinding Time
                59 {$Opt.OptionName  = "RebindingTime"
                    $Value = ($R.ReadByte()*[Math]::Pow(256, 3))+($R.ReadByte()*[Math]::Pow(256,2))+($R.ReadByte()*256)+$R.ReadByte()
                    $Opt.OptionValue = $(New-TimeSpan -Seconds $Value)
                    }
                # Vendor
                67 {$Opt.OptionName = "vendor-class-identifier"
                    $Value = ($R.ReadByte()*[Math]::Pow(256, 3))+($R.ReadByte()*[Math]::Pow(256,2))+($R.ReadByte()*256)+$R.ReadByte()
                    $Opt.OptionValue = $(New-TimeSpan -Seconds $Value)
                    }
                # End Option
                255 {$Opt.OptionName = "EndOption"}
                # All Other
                default {$Opt.OptionName = "NoOptionDecode"
                    $Buffer = New-Object Byte[] $Opt.Length
                    [Void]$R.Read($Buffer, 0, $Opt.Length)
                    $Opt.OptionValue = $Buffer
                    }}
            # Override ToString method
            $Opt | Add-Member ScriptMethod ToString {Return "$($this.OptionName) ($($this.OptionValue))"} -Force
            $DHResp.Options += $Opt
            }
        Return $DHResp 
        }
    #End
 
    ## Create Socket
    Function NewSock{
        # Prep Socket
        $SendTO    = 5000
        $ReceiveTO = 5000
        $AdrsFam   = [Net.Sockets.AddressFamily]::InterNetwork
        $SockType  = [Net.Sockets.SocketType]::Dgram
        $Proto     = [Net.Sockets.ProtocolType]::Udp
        $UDPSock = New-Object Net.Sockets.Socket($AdrsFam,$SockType,$Proto)
        $UDPSock.EnableBroadcast     = $True
        $UDPSock.ExclusiveAddressUse = $False
        $UDPSock.SendTimeOut         = $SendTO
        $UDPSock.ReceiveTimeOut      = $ReceiveTO
        # Return Socket
        Return $UDPSock
        }
    #End
 
    ## Remove Socket
    Function KillSock{
        Param([Net.Sockets.Socket]$Sock)
        $Sock.Shutdown("Both")
        $Sock.Close()
        }
    #End

    #### ACTION  ####
 
    # Prep Message
    $Msg     = NewDiscoPack
    # Prep Socket
    $UDPSock = NewSock
    # Prep Result
    $Reply   = @()
    $Result  = @()
    # Listen Port 68
    $EndPoint = [Net.EndPoint](New-Object Net.IPEndPoint($([Net.IPAddress]::Any, 68)))
    $UDPSock.Bind($EndPoint)
    # Send DHCPDiscover Port 67
    $EndPoint = [Net.EndPoint](New-Object Net.IPEndPoint($([Net.IPAddress]::Broadcast, 67)))
    # Send the DHCPDISCOVER packet
    $BytesSent = $UDPSock.SendTo($Msg, $EndPoint)
    # Begin receiving
    $NoTimeOut = $True
    # Get Date 
    $Start = Get-Date
    # Loop while true
    While($NoTimeOut){
        $BytesIn = 0
        Try{
            # Placeholder EndPoint for the Sender
            $Sender = [Net.EndPoint](New-Object Net.IPEndPoint($([Net.IPAddress]::Any, 0)))
            # Receive Buffer
            $BufferIn = New-Object Byte[] 1024
            $BytesIn = $UDPSock.ReceiveFrom($BufferIn, [Ref]$Sender)
            }<##>`
        Catch [Net.Sockets.SocketException]{
            $NoTimeOut = $False
            }
        # If Bytes Received
        If($BytesIn -gt 0){$Reply += ReadPack $BufferIn[0..$BytesIn]}
        # If TimeOut
        If((Get-Date) -gt $Start.AddSeconds($TimeOut)){$NoTimeOut = $False}
        }
    # Remove Socket
    KillSock $UDPSock

    #### RESULT ####
    if($ShowObj){Return $reply}
    else{
        Switch($Reply.count){
            1 {Return New-Object PSCustomObject -Property @{
                DHCP = "$($Reply[0].SIAddr)"
                PXE  = 'x'
                File = 'x'
                }|Select DHCP,PXE,File
                }
            2 {Return New-Object PSCustomObject -Property @{
                DHCP = "$($Reply[0].SIAddr)"
                PXE  = "$($Reply[1].Sname)"
                File = "$($Reply[1].File)"
                }|Select DHCP,PXE,File
                }
            Default{Write-Warning 'Ooops! Something went wrong...'}
            }}}
#########End