## Inline B64CMD Converter (Add to PoSh Profile)
##  via System.String Type Custom ScriptProperty Member

# Base64 Encode/Decode
Update-TypeData -TypeName System.String -MemberName "ToB64" -MemberType scriptproperty -Value {[System.Convert]::ToBase64String([System.Text.Encoding]::UNICODE.GetBytes($this))}
Update-TypeData -TypeName System.String -MemberName "FromB64" -MemberType scriptproperty -Value {[System.Text.Encoding]::UNICODE.GetString([System.Convert]::FromBase64String($this))}

# Add iex
Update-TypeData -TypeName System.String -MemberName "AddIEX" -MemberType scriptproperty -Value {"iex (`"$this`")"}

# Add exe
Update-TypeData -TypeName System.String -MemberName "AddEXE" -MemberType scriptproperty -Value {"powershell.exe -enc $this"}

# Run
Update-TypeData -TypeName System.String -MemberName "Run" -MemberType ScriptProperty -Value {powershell.exe -enc $this}
#ToClipBoard
Update-TypeData -TypeName System.String -MemberName "ToClip" -MemberType scriptproperty -Value {$this | Set-Clipboard}
#ToFile
Update-TypeData -TypeName System.String -MemberName "ToFile" -MemberType ScriptProperty -Value {New-Item -Path $pwd -Name Payload.txt -ItemType File -Value $this -Force}


## To remove:
## Remove-TypeData -TypeName System.String


# Where is my #Powershell Calc?
#IEx((help -?).synopsis.split(" ")[4]+(".{0}X{0} -{0}NC "-F"E")+(("Qw"+"Bh"),"Gw","Yw","="-join"A"))

123123123 -and 123456789

