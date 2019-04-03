## GreyNoise.io [Public Stuff] ##

# Noise Object
Class NoiseObj{
    [ipaddress]$IP
    [string]$Name
    [datetime]$FirstSeen
    [datetime]$LastUpdated
    [string]$Confidence
    [string]$Intention
    [string]$Category
    [string]$Org
    [string]$Rdns
    [string]$RdnsParent
    [string]$DataCenter
    [string]$ASN
    [string]$OS
    [string]$Link
    [bool]$Tor
    }

# Noise Tag List [-> ValidateSet]
$TagList = @(irm https://api.greynoise.io/v1/query/list | select -Expand tags | Sort)

<#
.Synopsis
   Get Grey Noise
.DESCRIPTION
   Get data from GreyNoise Public API
   See examples for Syntax
.LINK 
   https://greynoise.io/
   https://twitter.com/Andrew___Morris
.EXAMPLE
   GreyNoise -Tag COBALT_STRIKE_SCANNER_HIGH
   Get GreyNoise for specified tag 
.EXAMPLE
   GreyNoise x.x.x.x
   Get GreyNoise data for specified IP
.EXAMPLE
   $IPList | GreyNoise
   Get GreyNoise for list of IPs
#>
function Get-GreyNoise{
    [CmdletBinding(HelpUri='https://greynoise.io/')]
    [Alias("GreyNoise")]
    [OutputType([NoiseObj])]
    Param(
        # Get Noise IP addresse(s)
        [Parameter(Position=0,Mandatory=1,ValueFromPipeline=1,ParameterSetname='ip')][ipaddress]$IP,
        # Get Noise by Tag
        [Parameter(Mandatory=1,ParameterSetName='tag')][Switch]$Tag
        )
    DynamicParam{
        if($PSCmdlet.ParameterSetName -eq 'Tag'){
            ## Prep Dictionnary
            $Dict=New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            ## Prep Dynamic Param
            # Create First Attribute Obj
            $Attrib = New-Object System.Management.Automation.ParameterAttribute
            $Attrib.Mandatory = $True
            $Attrib.Position = 0
            # Create AttributeCollection obj
            $Collect = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            # Add Attribute Obj to Attibute Collection Obj
            $Collect.Add($Attrib)
            # Create Validate Set Obj & add to collection     
            $ValidSet=new-object System.Management.Automation.ValidateSetAttribute($TagList)
            $Collect.Add($ValidSet)
            # Create Runtine DynParam from Collection
            $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Name',[String],$Collect)
            # Add dynamic Param to Dictionary
            $Dict.Add('Name', $DynParam)        
            ## Return Dictionary
            return $Dict   
            }}
    Begin{
        # Prep URI
        $Set= $PSCmdlet.ParameterSetName
        $URI="http://api.greynoise.io:8888/v1/query/$Set"
        }
    Process{
        # Prep Body
        Switch($Set){
            ip {$Body=@{ip=$IP}}
            tag{$Name=$DynParam.Value;$Body=@{tag=$Name}}
            }
        # Get Reply
        $Reply = Invoke-RestMethod -Method POST -Uri $URI -Body $Body | where status -eq 'OK' | select -expand records 
        # foreach - Format obj
        $Reply |foreach{
            # Set IP addr
            if($PScmdlet.ParameterSetName -eq 'IP'){$addr = $IP}
            else{$addr = $_.IP}
            # Output Noise Object
            [NoiseObj]@{
                IP=$addr
                Name        = $_.name
                FirstSeen   = $_.first_seen
                LastUpdated = $_.last_updated
                Confidence  = $_.confidence
                Intention   = $_.intention
                Category    = $_.Category
                Org         = $_.metadata.org
                RDNS        = $_.metadata.rdns
                RDNSParent  = $_.metadata.rdns_parent
                DataCenter  = $_.metadata.datacenter
                ASN         = $_.metadata.asn
                OS          = $_.metadata.os
                Link        = $_.metadata.link
                Tor         = $_.metadata.tor
                }}}
    End{}#######
    }
#End


