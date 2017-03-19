function Invoke-GeoIP{
    [Alias('Geo')]
    Param(
        #External IPs to request
        [Parameter(Mandatory=$False,Position=0)][Alias('IP')][IPAddress[]]$ExternalIP,
        #Open in Google Map
        [Parameter(Mandatory=$False)][Alias('Web')][Switch]$ShowMap
        )
    Begin{
        #Specific IP
        If($ExternalIP){$url =  "http://ip-api.com/json/$ExternalIP"}
        #Host
        Else{$url =  'http://ip-api.com/json'}
        }
    Process{
        #Call API
        $Obj = irm $Url
        }
    End{
        #If ShowMap >> Google maps
        if($ShowMap){start "https://www.google.com/maps/place/google+map+$($Obj.lat)+$($Obj.lon)"}
        #Else >> return Object
        Else{return $obj}
        }
    }
##EndFunction 
