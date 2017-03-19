 

<#
.Synopsis
   View  ->  Acsrf  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapAcsrf -NAME
.EXAMPLE
   Get-ZapAcsrf -NAME -ParamName -ParamValue  
#>
Function Get-ZapAcsrf(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Lists the names of all anti CSRF tokens
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionTokensNames')]
[Switch]$OptionTokensNames
)

## If I say...
If($OptionTokensNames){$Name = 'optionTokensNames'}

## Knowing that...
$Component = 'acsrf'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  AjaxSpider  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapAjaxSpider -NAME
.EXAMPLE
   Get-ZapAjaxSpider -NAME -ParamName -ParamValue  
#>
Function Get-ZapAjaxSpider(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_NumberOfResults')]
[Switch]$NumberOfResults,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionBrowserId')]
[Switch]$OptionBrowserId,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionClickDefaultElems')]
[Switch]$OptionClickDefaultElems,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionClickElemsOnce')]
[Switch]$OptionClickElemsOnce,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionEventWait')]
[Switch]$OptionEventWait,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionMaxCrawlDepth')]
[Switch]$OptionMaxCrawlDepth,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionMaxCrawlStates')]
[Switch]$OptionMaxCrawlStates,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionMaxDuration')]
[Switch]$OptionMaxDuration,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionNumberOfBrowsers')]
[Switch]$OptionNumberOfBrowsers,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionRandomInputs')]
[Switch]$OptionRandomInputs,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionReloadWait')]
[Switch]$OptionReloadWait,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Results')]
[Switch]$Results,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Status')]
[Switch]$Status,

[Parameter(Mandatory=$false, ParameterSetName='View_Results')]
[String]$count,

[Parameter(Mandatory=$false, ParameterSetName='View_Results')]
[String]$start
)

## If I say...
If($NumberOfResults){$Name = 'numberOfResults'}
If($OptionBrowserId){$Name = 'optionBrowserId'}
If($OptionClickDefaultElems){$Name = 'optionClickDefaultElems'}
If($OptionClickElemsOnce){$Name = 'optionClickElemsOnce'}
If($OptionEventWait){$Name = 'optionEventWait'}
If($OptionMaxCrawlDepth){$Name = 'optionMaxCrawlDepth'}
If($OptionMaxCrawlStates){$Name = 'optionMaxCrawlStates'}
If($OptionMaxDuration){$Name = 'optionMaxDuration'}
If($OptionNumberOfBrowsers){$Name = 'optionNumberOfBrowsers'}
If($OptionRandomInputs){$Name = 'optionRandomInputs'}
If($OptionReloadWait){$Name = 'optionReloadWait'}
If($Results){$Name = 'results'}
If($Status){$Name = 'status'}
If($count){$Param += @{'count'=$count}}
If($start){$Param += @{'start'=$start}}

## Knowing that...
$Component = 'ajaxSpider'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  Ascan  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapAscan -NAME
.EXAMPLE
   Get-ZapAscan -NAME -ParamName -ParamValue  
#>
Function Get-ZapAscan(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_AlertsIds')]
[Switch]$AlertsIds,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_AttackModeQueue')]
[Switch]$AttackModeQueue,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_ExcludedFromScan')]
[Switch]$ExcludedFromScan,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_MessagesIds')]
[Switch]$MessagesIds,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Policies')]
[Switch]$Policies,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Scanners')]
[Switch]$Scanners,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_ScanPolicyNames')]
[Switch]$ScanPolicyNames,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_ScanProgress')]
[Switch]$ScanProgress,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Scans')]
[Switch]$Scans,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Status')]
[Switch]$Status,

[Parameter(Mandatory=$false, ParameterSetName='View_Policies')]
[Parameter(Mandatory=$false, ParameterSetName='View_Scanners')]
[String]$policyId,

[Parameter(Mandatory=$True, ParameterSetName='View_AlertsIds')]
[Parameter(Mandatory=$True, ParameterSetName='View_MessagesIds')]
[Parameter(Mandatory=$false, ParameterSetName='View_ScanProgress')]
[Parameter(Mandatory=$false, ParameterSetName='View_Status')]
[String]$scanId,

[Parameter(Mandatory=$false, ParameterSetName='View_Policies')]
[Parameter(Mandatory=$false, ParameterSetName='View_Scanners')]
[String]$scanPolicyName
)

## If I say...
If($AlertsIds){$Name = 'alertsIds'}
If($AttackModeQueue){$Name = 'attackModeQueue'}
If($ExcludedFromScan){$Name = 'excludedFromScan'}
If($MessagesIds){$Name = 'messagesIds'}
If($Policies){$Name = 'policies'}
If($Scanners){$Name = 'scanners'}
If($ScanPolicyNames){$Name = 'scanPolicyNames'}
If($ScanProgress){$Name = 'scanProgress'}
If($Scans){$Name = 'scans'}
If($Status){$Name = 'status'}
If($policyId){$Param += @{'policyId'=$policyId}}
If($scanId){$Param += @{'scanId'=$scanId}}
If($scanPolicyName){$Param += @{'scanPolicyName'=$scanPolicyName}}

## Knowing that...
$Component = 'ascan'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  Ascan  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapAscan_O -NAME
.EXAMPLE
   Get-ZapAscan_O -NAME -ParamName -ParamValue  
#>
Function Get-ZapAscan_O(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionAllowAttackOnStart')]
[Switch]$OptionAllowAttackOnStart,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionAttackPolicy')]
[Switch]$OptionAttackPolicy,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionDefaultPolicy')]
[Switch]$OptionDefaultPolicy,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionDelayInMs')]
[Switch]$OptionDelayInMs,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionExcludedParamList')]
[Switch]$OptionExcludedParamList,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionHandleAntiCSRFTokens')]
[Switch]$OptionHandleAntiCSRFTokens,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionHostPerScan')]
[Switch]$OptionHostPerScan,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionInjectPluginIdInHeader')]
[Switch]$OptionInjectPluginIdInHeader,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionMaxChartTimeInMins')]
[Switch]$OptionMaxChartTimeInMins,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionMaxResultsToList')]
[Switch]$OptionMaxResultsToList,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionMaxScansInUI')]
[Switch]$OptionMaxScansInUI,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionPromptInAttackMode')]
[Switch]$OptionPromptInAttackMode,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionPromptToClearFinishedScans')]
[Switch]$OptionPromptToClearFinishedScans,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionRescanInAttackMode')]
[Switch]$OptionRescanInAttackMode,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionShowAdvancedDialog')]
[Switch]$OptionShowAdvancedDialog,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionTargetParamsEnabledRPC')]
[Switch]$OptionTargetParamsEnabledRPC,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionTargetParamsInjectable')]
[Switch]$OptionTargetParamsInjectable,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionThreadPerHost')]
[Switch]$OptionThreadPerHost
)

## If I say...
If($OptionAllowAttackOnStart){$Name = 'optionAllowAttackOnStart'}
If($OptionAttackPolicy){$Name = 'optionAttackPolicy'}
If($OptionDefaultPolicy){$Name = 'optionDefaultPolicy'}
If($OptionDelayInMs){$Name = 'optionDelayInMs'}
If($OptionExcludedParamList){$Name = 'optionExcludedParamList'}
If($OptionHandleAntiCSRFTokens){$Name = 'optionHandleAntiCSRFTokens'}
If($OptionHostPerScan){$Name = 'optionHostPerScan'}
If($OptionInjectPluginIdInHeader){$Name = 'optionInjectPluginIdInHeader'}
If($OptionMaxChartTimeInMins){$Name = 'optionMaxChartTimeInMins'}
If($OptionMaxResultsToList){$Name = 'optionMaxResultsToList'}
If($OptionMaxScansInUI){$Name = 'optionMaxScansInUI'}
If($OptionPromptInAttackMode){$Name = 'optionPromptInAttackMode'}
If($OptionPromptToClearFinishedScans){$Name = 'optionPromptToClearFinishedScans'}
If($OptionRescanInAttackMode){$Name = 'optionRescanInAttackMode'}
If($OptionShowAdvancedDialog){$Name = 'optionShowAdvancedDialog'}
If($OptionTargetParamsEnabledRPC){$Name = 'optionTargetParamsEnabledRPC'}
If($OptionTargetParamsInjectable){$Name = 'optionTargetParamsInjectable'}
If($OptionThreadPerHost){$Name = 'optionThreadPerHost'}

## Knowing that...
$Component = 'ascan'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  Authentication  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapAuthentication -NAME
.EXAMPLE
   Get-ZapAuthentication -NAME -ParamName -ParamValue  
#>
Function Get-ZapAuthentication(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_GetAuthenticationMethod')]
[Switch]$GetAuthenticationMethod,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_GetAuthenticationMethodConfigParams')]
[Switch]$GetAuthenticationMethodConfigParams,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_GetLoggedInIndicator')]
[Switch]$GetLoggedInIndicator,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_GetLoggedOutIndicator')]
[Switch]$GetLoggedOutIndicator,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_GetSupportedAuthenticationMethods')]
[Switch]$GetSupportedAuthenticationMethods,

[Parameter(Mandatory=$True, ParameterSetName='View_GetAuthenticationMethodConfigParams')]
[String]$authMethodName,

[Parameter(Mandatory=$True, ParameterSetName='View_GetAuthenticationMethod')]
[Parameter(Mandatory=$True, ParameterSetName='View_GetLoggedInIndicator')]
[Parameter(Mandatory=$True, ParameterSetName='View_GetLoggedOutIndicator')]
[String]$contextId
)

## If I say...
If($GetAuthenticationMethod){$Name = 'getAuthenticationMethod'}
If($GetAuthenticationMethodConfigParams){$Name = 'getAuthenticationMethodConfigParams'}
If($GetLoggedInIndicator){$Name = 'getLoggedInIndicator'}
If($GetLoggedOutIndicator){$Name = 'getLoggedOutIndicator'}
If($GetSupportedAuthenticationMethods){$Name = 'getSupportedAuthenticationMethods'}
If($authMethodName){$Param += @{'authMethodName'=$authMethodName}}
If($contextId){$Param += @{'contextId'=$contextId}}

## Knowing that...
$Component = 'authentication'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  Autoupdate  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapAutoupdate -NAME
.EXAMPLE
   Get-ZapAutoupdate -NAME -ParamName -ParamValue  
#>
Function Get-ZapAutoupdate(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Returns 'true' if ZAP is on the latest version
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_IsLatestVersion')]
[Switch]$IsLatestVersion,

# Returns the latest version number
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_LatestVersionNumber')]
[Switch]$LatestVersionNumber,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionAddonDirectories')]
[Switch]$OptionAddonDirectories,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionCheckAddonUpdates')]
[Switch]$OptionCheckAddonUpdates,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionCheckOnStart')]
[Switch]$OptionCheckOnStart,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionDayLastChecked')]
[Switch]$OptionDayLastChecked,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionDayLastInstallWarned')]
[Switch]$OptionDayLastInstallWarned,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionDayLastUpdateWarned')]
[Switch]$OptionDayLastUpdateWarned,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionDownloadDirectory')]
[Switch]$OptionDownloadDirectory,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionDownloadNewRelease')]
[Switch]$OptionDownloadNewRelease,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionInstallAddonUpdates')]
[Switch]$OptionInstallAddonUpdates,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionInstallScannerRules')]
[Switch]$OptionInstallScannerRules,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionReportAlphaAddons')]
[Switch]$OptionReportAlphaAddons,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionReportBetaAddons')]
[Switch]$OptionReportBetaAddons,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionReportReleaseAddons')]
[Switch]$OptionReportReleaseAddons
)

## If I say...
If($IsLatestVersion){$Name = 'isLatestVersion'}
If($LatestVersionNumber){$Name = 'latestVersionNumber'}
If($OptionAddonDirectories){$Name = 'optionAddonDirectories'}
If($OptionCheckAddonUpdates){$Name = 'optionCheckAddonUpdates'}
If($OptionCheckOnStart){$Name = 'optionCheckOnStart'}
If($OptionDayLastChecked){$Name = 'optionDayLastChecked'}
If($OptionDayLastInstallWarned){$Name = 'optionDayLastInstallWarned'}
If($OptionDayLastUpdateWarned){$Name = 'optionDayLastUpdateWarned'}
If($OptionDownloadDirectory){$Name = 'optionDownloadDirectory'}
If($OptionDownloadNewRelease){$Name = 'optionDownloadNewRelease'}
If($OptionInstallAddonUpdates){$Name = 'optionInstallAddonUpdates'}
If($OptionInstallScannerRules){$Name = 'optionInstallScannerRules'}
If($OptionReportAlphaAddons){$Name = 'optionReportAlphaAddons'}
If($OptionReportBetaAddons){$Name = 'optionReportBetaAddons'}
If($OptionReportReleaseAddons){$Name = 'optionReportReleaseAddons'}

## Knowing that...
$Component = 'autoupdate'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  Context  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapContext -NAME
.EXAMPLE
   Get-ZapContext -NAME -ParamName -ParamValue  
#>
Function Get-ZapContext(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# List the information about the named context
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Context')]
[Switch]$Context,

# List context names of current session
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_ContextList')]
[Switch]$ContextList,

# Lists the names of all technologies excluded from a context
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_ExcludedTechnologyList')]
[Switch]$ExcludedTechnologyList,

# List excluded regexs for context
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_ExcludeRegexs')]
[Switch]$ExcludeRegexs,

# Lists the names of all technologies included in a context
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_IncludedTechnologyList')]
[Switch]$IncludedTechnologyList,

# List included regexs for context
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_IncludeRegexs')]
[Switch]$IncludeRegexs,

# Lists the names of all built in technologies
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_TechnologyList')]
[Switch]$TechnologyList,

[Parameter(Mandatory=$True, ParameterSetName='View_Context')]
[Parameter(Mandatory=$True, ParameterSetName='View_ExcludedTechnologyList')]
[Parameter(Mandatory=$True, ParameterSetName='View_ExcludeRegexs')]
[Parameter(Mandatory=$True, ParameterSetName='View_IncludedTechnologyList')]
[Parameter(Mandatory=$True, ParameterSetName='View_IncludeRegexs')]
[String]$contextName
)

## If I say...
If($Context){$Name = 'context'}
If($ContextList){$Name = 'contextList'}
If($ExcludedTechnologyList){$Name = 'excludedTechnologyList'}
If($ExcludeRegexs){$Name = 'excludeRegexs'}
If($IncludedTechnologyList){$Name = 'includedTechnologyList'}
If($IncludeRegexs){$Name = 'includeRegexs'}
If($TechnologyList){$Name = 'technologyList'}
If($contextName){$Param += @{'contextName'=$contextName}}

## Knowing that...
$Component = 'context'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  Core  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapCore -NAME
.EXAMPLE
   Get-ZapCore -NAME -ParamName -ParamValue  
#>
Function Get-ZapCore(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Gets the alert with the given ID, the corresponding HTTP message can be obtained with the 'messageId' field and 'message' API method
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Alert')]
[Switch]$Alert,

# Gets the alerts raised by ZAP, optionally filtering by URL and paginating with 'start' position and 'count' of alerts
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Alerts')]
[Switch]$Alerts,

# Gets the regular expressions, applied to URLs, to exclude from the Proxy
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_ExcludedFromProxy')]
[Switch]$ExcludedFromProxy,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_HomeDirectory')]
[Switch]$HomeDirectory,

# Gets the name of the hosts accessed through/by ZAP
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Hosts')]
[Switch]$Hosts,

# Gets the HTTP message with the given ID. Returns the ID, request/response headers and bodies, cookies and note.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Message')]
[Switch]$Message,

# Gets the HTTP messages sent by ZAP, request and response, optionally filtered by URL and paginated with 'start' position and 'count' of messages
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Messages')]
[Switch]$Messages,

# Gets the number of alerts, optionally filtering by URL
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_NumberOfAlerts')]
[Switch]$NumberOfAlerts,

# Gets the number of messages, optionally filtering by URL
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_NumberOfMessages')]
[Switch]$NumberOfMessages,

# Gets the sites accessed through/by ZAP (scheme and domain)
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Sites')]
[Switch]$Sites,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Stats')]
[Switch]$Stats,

# Gets the URLs accessed through/by ZAP
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Urls')]
[Switch]$Urls,

# Gets ZAP version
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Version')]
[Switch]$Version,

[Parameter(Mandatory=$false, ParameterSetName='View_Alerts')]
[Parameter(Mandatory=$false, ParameterSetName='View_Messages')]
[Parameter(Mandatory=$false, ParameterSetName='View_NumberOfAlerts')]
[Parameter(Mandatory=$false, ParameterSetName='View_NumberOfMessages')]
[String]$baseurl,

[Parameter(Mandatory=$false, ParameterSetName='View_Alerts')]
[Parameter(Mandatory=$false, ParameterSetName='View_Messages')]
[String]$count,

[Parameter(Mandatory=$True, ParameterSetName='View_Alert')]
[Parameter(Mandatory=$True, ParameterSetName='View_Message')]
[String]$id,

[Parameter(Mandatory=$false, ParameterSetName='View_Stats')]
[String]$keyPrefix,

[Parameter(Mandatory=$false, ParameterSetName='View_Alerts')]
[Parameter(Mandatory=$false, ParameterSetName='View_Messages')]
[String]$start
)

## If I say...
If($Alert){$Name = 'alert'}
If($Alerts){$Name = 'alerts'}
If($ExcludedFromProxy){$Name = 'excludedFromProxy'}
If($HomeDirectory){$Name = 'homeDirectory'}
If($Hosts){$Name = 'hosts'}
If($Message){$Name = 'message'}
If($Messages){$Name = 'messages'}
If($NumberOfAlerts){$Name = 'numberOfAlerts'}
If($NumberOfMessages){$Name = 'numberOfMessages'}
If($Sites){$Name = 'sites'}
If($Stats){$Name = 'stats'}
If($Urls){$Name = 'urls'}
If($Version){$Name = 'version'}
If($baseurl){$Param += @{'baseurl'=$baseurl}}
If($count){$Param += @{'count'=$count}}
If($id){$Param += @{'id'=$id}}
If($keyPrefix){$Param += @{'keyPrefix'=$keyPrefix}}
If($start){$Param += @{'start'=$start}}

## Knowing that...
$Component = 'core'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  Core  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapCore_O -NAME
.EXAMPLE
   Get-ZapCore_O -NAME -ParamName -ParamValue  
#>
Function Get-ZapCore_O(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionDefaultUserAgent')]
[Switch]$OptionDefaultUserAgent,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionHttpState')]
[Switch]$OptionHttpState,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionHttpStateEnabled')]
[Switch]$OptionHttpStateEnabled,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionProxyChainName')]
[Switch]$OptionProxyChainName,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionProxyChainPassword')]
[Switch]$OptionProxyChainPassword,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionProxyChainPort')]
[Switch]$OptionProxyChainPort,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionProxyChainPrompt')]
[Switch]$OptionProxyChainPrompt,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionProxyChainRealm')]
[Switch]$OptionProxyChainRealm,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionProxyChainSkipName')]
[Switch]$OptionProxyChainSkipName,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionProxyChainUserName')]
[Switch]$OptionProxyChainUserName,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionProxyExcludedDomains')]
[Switch]$OptionProxyExcludedDomains,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionProxyExcludedDomainsEnabled')]
[Switch]$OptionProxyExcludedDomainsEnabled,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionSingleCookieRequestHeader')]
[Switch]$OptionSingleCookieRequestHeader,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionTimeoutInSecs')]
[Switch]$OptionTimeoutInSecs,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionUseProxyChain')]
[Switch]$OptionUseProxyChain,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionUseProxyChainAuth')]
[Switch]$OptionUseProxyChainAuth
)

## If I say...
If($OptionDefaultUserAgent){$Name = 'optionDefaultUserAgent'}
If($OptionHttpState){$Name = 'optionHttpState'}
If($OptionHttpStateEnabled){$Name = 'optionHttpStateEnabled'}
If($OptionProxyChainName){$Name = 'optionProxyChainName'}
If($OptionProxyChainPassword){$Name = 'optionProxyChainPassword'}
If($OptionProxyChainPort){$Name = 'optionProxyChainPort'}
If($OptionProxyChainPrompt){$Name = 'optionProxyChainPrompt'}
If($OptionProxyChainRealm){$Name = 'optionProxyChainRealm'}
If($OptionProxyChainSkipName){$Name = 'optionProxyChainSkipName'}
If($OptionProxyChainUserName){$Name = 'optionProxyChainUserName'}
If($OptionProxyExcludedDomains){$Name = 'optionProxyExcludedDomains'}
If($OptionProxyExcludedDomainsEnabled){$Name = 'optionProxyExcludedDomainsEnabled'}
If($OptionSingleCookieRequestHeader){$Name = 'optionSingleCookieRequestHeader'}
If($OptionTimeoutInSecs){$Name = 'optionTimeoutInSecs'}
If($OptionUseProxyChain){$Name = 'optionUseProxyChain'}
If($OptionUseProxyChainAuth){$Name = 'optionUseProxyChainAuth'}

## Knowing that...
$Component = 'core'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  ForcedUser  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapForcedUser -NAME
.EXAMPLE
   Get-ZapForcedUser -NAME -ParamName -ParamValue  
#>
Function Get-ZapForcedUser(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Gets the user (ID) set as 'forced user' for the given context (ID)
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_GetForcedUser')]
[Switch]$GetForcedUser,

# Returns 'true' if 'forced user' mode is enabled, 'false' otherwise
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_IsForcedUserModeEnabled')]
[Switch]$IsForcedUserModeEnabled,

[Parameter(Mandatory=$True, ParameterSetName='View_GetForcedUser')]
[String]$contextId
)

## If I say...
If($GetForcedUser){$Name = 'getForcedUser'}
If($IsForcedUserModeEnabled){$Name = 'isForcedUserModeEnabled'}
If($contextId){$Param += @{'contextId'=$contextId}}

## Knowing that...
$Component = 'forcedUser'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  HttpSessions  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapHttpSessions -NAME
.EXAMPLE
   Get-ZapHttpSessions -NAME -ParamName -ParamValue  
#>
Function Get-ZapHttpSessions(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Gets the name of the active session for the given site.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_ActiveSession')]
[Switch]$ActiveSession,

# Gets the sessions of the given site. Optionally returning just the session with the given name.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Sessions')]
[Switch]$Sessions,

# Gets the names of the session tokens for the given site.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_SessionTokens')]
[Switch]$SessionTokens,

[Parameter(Mandatory=$false, ParameterSetName='View_Sessions')]
[String]$session,

[Parameter(Mandatory=$True, ParameterSetName='View_ActiveSession')]
[Parameter(Mandatory=$True, ParameterSetName='View_Sessions')]
[Parameter(Mandatory=$True, ParameterSetName='View_SessionTokens')]
[String]$site
)

## If I say...
If($ActiveSession){$Name = 'activeSession'}
If($Sessions){$Name = 'sessions'}
If($SessionTokens){$Name = 'sessionTokens'}
If($session){$Param += @{'session'=$session}}
If($site){$Param += @{'site'=$site}}

## Knowing that...
$Component = 'httpSessions'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  Params  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapParams -NAME
.EXAMPLE
   Get-ZapParams -NAME -ParamName -ParamValue  
#>
Function Get-ZapParams(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Shows the parameters for the specified site, or for all sites if the site is not specified
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Params')]
[Switch]$Params,

[Parameter(Mandatory=$false, ParameterSetName='View_Params')]
[String]$site
)

## If I say...
If($Params){$Name = 'params'}
If($site){$Param += @{'site'=$site}}

## Knowing that...
$Component = 'params'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  Pscan  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapPscan -NAME
.EXAMPLE
   Get-ZapPscan -NAME -ParamName -ParamValue  
#>
Function Get-ZapPscan(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# The number of records the passive scanner still has to scan
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_RecordsToScan')]
[Switch]$RecordsToScan,

# Lists all passive scanners with its ID, name, enabled state and alert threshold.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Scanners')]
[Switch]$Scanners
)

## If I say...
If($RecordsToScan){$Name = 'recordsToScan'}
If($Scanners){$Name = 'scanners'}

## Knowing that...
$Component = 'pscan'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  Reveal  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapReveal -NAME
.EXAMPLE
   Get-ZapReveal -NAME -ParamName -ParamValue  
#>
Function Get-ZapReveal(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Reveal')]
[Switch]$Reveal
)

## If I say...
If($Reveal){$Name = 'reveal'}

## Knowing that...
$Component = 'reveal'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  Script  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapScript -NAME
.EXAMPLE
   Get-ZapScript -NAME -ParamName -ParamValue  
#>
Function Get-ZapScript(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Lists the script engines available
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_ListEngines')]
[Switch]$ListEngines,

# Lists the scripts available, with its engine, name, description, type and error state.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_ListScripts')]
[Switch]$ListScripts
)

## If I say...
If($ListEngines){$Name = 'listEngines'}
If($ListScripts){$Name = 'listScripts'}

## Knowing that...
$Component = 'script'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  Search  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapSearch -NAME
.EXAMPLE
   Get-ZapSearch -NAME -ParamName -ParamValue  
#>
Function Get-ZapSearch(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_MessagesByHeaderRegex')]
[Switch]$MessagesByHeaderRegex,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_MessagesByRequestRegex')]
[Switch]$MessagesByRequestRegex,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_MessagesByResponseRegex')]
[Switch]$MessagesByResponseRegex,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_MessagesByUrlRegex')]
[Switch]$MessagesByUrlRegex,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_UrlsByHeaderRegex')]
[Switch]$UrlsByHeaderRegex,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_UrlsByRequestRegex')]
[Switch]$UrlsByRequestRegex,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_UrlsByResponseRegex')]
[Switch]$UrlsByResponseRegex,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_UrlsByUrlRegex')]
[Switch]$UrlsByUrlRegex,

[Parameter(Mandatory=$false, ParameterSetName='View_MessagesByHeaderRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_MessagesByRequestRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_MessagesByResponseRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_MessagesByUrlRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_UrlsByHeaderRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_UrlsByRequestRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_UrlsByResponseRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_UrlsByUrlRegex')]
[String]$baseurl,

[Parameter(Mandatory=$false, ParameterSetName='View_MessagesByHeaderRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_MessagesByRequestRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_MessagesByResponseRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_MessagesByUrlRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_UrlsByHeaderRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_UrlsByRequestRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_UrlsByResponseRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_UrlsByUrlRegex')]
[String]$count,

[Parameter(Mandatory=$True, ParameterSetName='View_MessagesByHeaderRegex')]
[Parameter(Mandatory=$True, ParameterSetName='View_MessagesByRequestRegex')]
[Parameter(Mandatory=$True, ParameterSetName='View_MessagesByResponseRegex')]
[Parameter(Mandatory=$True, ParameterSetName='View_MessagesByUrlRegex')]
[Parameter(Mandatory=$True, ParameterSetName='View_UrlsByHeaderRegex')]
[Parameter(Mandatory=$True, ParameterSetName='View_UrlsByRequestRegex')]
[Parameter(Mandatory=$True, ParameterSetName='View_UrlsByResponseRegex')]
[Parameter(Mandatory=$True, ParameterSetName='View_UrlsByUrlRegex')]
[String]$regex,

[Parameter(Mandatory=$false, ParameterSetName='View_MessagesByHeaderRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_MessagesByRequestRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_MessagesByResponseRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_MessagesByUrlRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_UrlsByHeaderRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_UrlsByRequestRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_UrlsByResponseRegex')]
[Parameter(Mandatory=$false, ParameterSetName='View_UrlsByUrlRegex')]
[String]$start
)

## If I say...
If($MessagesByHeaderRegex){$Name = 'messagesByHeaderRegex'}
If($MessagesByRequestRegex){$Name = 'messagesByRequestRegex'}
If($MessagesByResponseRegex){$Name = 'messagesByResponseRegex'}
If($MessagesByUrlRegex){$Name = 'messagesByUrlRegex'}
If($UrlsByHeaderRegex){$Name = 'urlsByHeaderRegex'}
If($UrlsByRequestRegex){$Name = 'urlsByRequestRegex'}
If($UrlsByResponseRegex){$Name = 'urlsByResponseRegex'}
If($UrlsByUrlRegex){$Name = 'urlsByUrlRegex'}
If($baseurl){$Param += @{'baseurl'=$baseurl}}
If($count){$Param += @{'count'=$count}}
If($regex){$Param += @{'regex'=$regex}}
If($start){$Param += @{'start'=$start}}

## Knowing that...
$Component = 'search'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  Selenium  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapSelenium -NAME
.EXAMPLE
   Get-ZapSelenium -NAME -ParamName -ParamValue  
#>
Function Get-ZapSelenium(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Returns the current path to ChromeDriver
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionChromeDriverPath')]
[Switch]$OptionChromeDriverPath,

# Returns the current path to Firefox binary
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionFirefoxBinaryPath')]
[Switch]$OptionFirefoxBinaryPath,

# Returns the current path to IEDriverServer
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionIeDriverPath')]
[Switch]$OptionIeDriverPath,

# Returns the current path to PhantomJS binary
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionPhantomJsBinaryPath')]
[Switch]$OptionPhantomJsBinaryPath
)

## If I say...
If($OptionChromeDriverPath){$Name = 'optionChromeDriverPath'}
If($OptionFirefoxBinaryPath){$Name = 'optionFirefoxBinaryPath'}
If($OptionIeDriverPath){$Name = 'optionIeDriverPath'}
If($OptionPhantomJsBinaryPath){$Name = 'optionPhantomJsBinaryPath'}

## Knowing that...
$Component = 'selenium'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  SessionManagement  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapSessionManagement -NAME
.EXAMPLE
   Get-ZapSessionManagement -NAME -ParamName -ParamValue  
#>
Function Get-ZapSessionManagement(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_GetSessionManagementMethod')]
[Switch]$GetSessionManagementMethod,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_GetSessionManagementMethodConfigParams')]
[Switch]$GetSessionManagementMethodConfigParams,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_GetSupportedSessionManagementMethods')]
[Switch]$GetSupportedSessionManagementMethods,

[Parameter(Mandatory=$True, ParameterSetName='View_GetSessionManagementMethod')]
[String]$contextId,

[Parameter(Mandatory=$True, ParameterSetName='View_GetSessionManagementMethodConfigParams')]
[String]$methodName
)

## If I say...
If($GetSessionManagementMethod){$Name = 'getSessionManagementMethod'}
If($GetSessionManagementMethodConfigParams){$Name = 'getSessionManagementMethodConfigParams'}
If($GetSupportedSessionManagementMethods){$Name = 'getSupportedSessionManagementMethods'}
If($contextId){$Param += @{'contextId'=$contextId}}
If($methodName){$Param += @{'methodName'=$methodName}}

## Knowing that...
$Component = 'sessionManagement'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  Spider  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapSpider -NAME
.EXAMPLE
   Get-ZapSpider -NAME -ParamName -ParamValue  
#>
Function Get-ZapSpider(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_ExcludedFromScan')]
[Switch]$ExcludedFromScan,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_FullResults')]
[Switch]$FullResults,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Results')]
[Switch]$Results,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Scans')]
[Switch]$Scans,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Status')]
[Switch]$Status,

[Parameter(Mandatory=$True, ParameterSetName='View_FullResults')]
[Parameter(Mandatory=$false, ParameterSetName='View_Results')]
[Parameter(Mandatory=$false, ParameterSetName='View_Status')]
[String]$scanId
)

## If I say...
If($ExcludedFromScan){$Name = 'excludedFromScan'}
If($FullResults){$Name = 'fullResults'}
If($Results){$Name = 'results'}
If($Scans){$Name = 'scans'}
If($Status){$Name = 'status'}
If($scanId){$Param += @{'scanId'=$scanId}}

## Knowing that...
$Component = 'spider'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  Spider  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapSpider_O -NAME
.EXAMPLE
   Get-ZapSpider_O -NAME -ParamName -ParamValue  
#>
Function Get-ZapSpider_O(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionDomainsAlwaysInScope')]
[Switch]$OptionDomainsAlwaysInScope,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionDomainsAlwaysInScopeEnabled')]
[Switch]$OptionDomainsAlwaysInScopeEnabled,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionHandleODataParametersVisited')]
[Switch]$OptionHandleODataParametersVisited,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionHandleParameters')]
[Switch]$OptionHandleParameters,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionMaxDepth')]
[Switch]$OptionMaxDepth,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionMaxScansInUI')]
[Switch]$OptionMaxScansInUI,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionParseComments')]
[Switch]$OptionParseComments,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionParseGit')]
[Switch]$OptionParseGit,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionParseRobotsTxt')]
[Switch]$OptionParseRobotsTxt,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionParseSitemapXml')]
[Switch]$OptionParseSitemapXml,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionParseSVNEntries')]
[Switch]$OptionParseSVNEntries,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionPostForm')]
[Switch]$OptionPostForm,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionProcessForm')]
[Switch]$OptionProcessForm,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionRequestWaitTime')]
[Switch]$OptionRequestWaitTime,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionScope')]
[Switch]$OptionScope,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionScopeText')]
[Switch]$OptionScopeText,

# Sets whether or not the 'Referer' header should be sent while spidering
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionSendRefererHeader')]
[Switch]$OptionSendRefererHeader,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionShowAdvancedDialog')]
[Switch]$OptionShowAdvancedDialog,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionSkipURLString')]
[Switch]$OptionSkipURLString,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionThreadCount')]
[Switch]$OptionThreadCount,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionUserAgent')]
[Switch]$OptionUserAgent
)

## If I say...
If($OptionDomainsAlwaysInScope){$Name = 'optionDomainsAlwaysInScope'}
If($OptionDomainsAlwaysInScopeEnabled){$Name = 'optionDomainsAlwaysInScopeEnabled'}
If($OptionHandleODataParametersVisited){$Name = 'optionHandleODataParametersVisited'}
If($OptionHandleParameters){$Name = 'optionHandleParameters'}
If($OptionMaxDepth){$Name = 'optionMaxDepth'}
If($OptionMaxScansInUI){$Name = 'optionMaxScansInUI'}
If($OptionParseComments){$Name = 'optionParseComments'}
If($OptionParseGit){$Name = 'optionParseGit'}
If($OptionParseRobotsTxt){$Name = 'optionParseRobotsTxt'}
If($OptionParseSitemapXml){$Name = 'optionParseSitemapXml'}
If($OptionParseSVNEntries){$Name = 'optionParseSVNEntries'}
If($OptionPostForm){$Name = 'optionPostForm'}
If($OptionProcessForm){$Name = 'optionProcessForm'}
If($OptionRequestWaitTime){$Name = 'optionRequestWaitTime'}
If($OptionScope){$Name = 'optionScope'}
If($OptionScopeText){$Name = 'optionScopeText'}
If($OptionSendRefererHeader){$Name = 'optionSendRefererHeader'}
If($OptionShowAdvancedDialog){$Name = 'optionShowAdvancedDialog'}
If($OptionSkipURLString){$Name = 'optionSkipURLString'}
If($OptionThreadCount){$Name = 'optionThreadCount'}
If($OptionUserAgent){$Name = 'optionUserAgent'}

## Knowing that...
$Component = 'spider'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  Stats  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapStats -NAME
.EXAMPLE
   Get-ZapStats -NAME -ParamName -ParamValue  
#>
Function Get-ZapStats(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Gets all of the site based statistics, optionally filtered by a key prefix
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_AllSitesStats')]
[Switch]$AllSitesStats,

# Returns 'true' if in memory statistics are enabled, otherwise returns 'false'
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionInMemoryEnabled')]
[Switch]$OptionInMemoryEnabled,

# Returns 'true' if a Statsd server has been correctly configured, otherwise returns 'false'
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionStatsdEnabled')]
[Switch]$OptionStatsdEnabled,

# Gets the Statsd service hostname
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionStatsdHost')]
[Switch]$OptionStatsdHost,

# Gets the Statsd service port
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionStatsdPort')]
[Switch]$OptionStatsdPort,

# Gets the prefix to be applied to all stats sent to the configured Statsd service
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_OptionStatsdPrefix')]
[Switch]$OptionStatsdPrefix,

# Gets all of the global statistics, optionally filtered by a key prefix
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_SiteStats')]
[Switch]$SiteStats,

# Statistics
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_Stats')]
[Switch]$Stats,

[Parameter(Mandatory=$false, ParameterSetName='View_AllSitesStats')]
[Parameter(Mandatory=$false, ParameterSetName='View_SiteStats')]
[Parameter(Mandatory=$false, ParameterSetName='View_Stats')]
[String]$keyPrefix,

[Parameter(Mandatory=$True, ParameterSetName='View_SiteStats')]
[String]$site
)

## If I say...
If($AllSitesStats){$Name = 'allSitesStats'}
If($OptionInMemoryEnabled){$Name = 'optionInMemoryEnabled'}
If($OptionStatsdEnabled){$Name = 'optionStatsdEnabled'}
If($OptionStatsdHost){$Name = 'optionStatsdHost'}
If($OptionStatsdPort){$Name = 'optionStatsdPort'}
If($OptionStatsdPrefix){$Name = 'optionStatsdPrefix'}
If($SiteStats){$Name = 'siteStats'}
If($Stats){$Name = 'stats'}
If($keyPrefix){$Param += @{'keyPrefix'=$keyPrefix}}
If($site){$Param += @{'site'=$site}}

## Knowing that...
$Component = 'stats'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   View  ->  Users  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Get-ZapUsers -NAME
.EXAMPLE
   Get-ZapUsers -NAME -ParamName -ParamValue  
#>
Function Get-ZapUsers(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_GetAuthenticationCredentials')]
[Switch]$GetAuthenticationCredentials,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_GetAuthenticationCredentialsConfigParams')]
[Switch]$GetAuthenticationCredentialsConfigParams,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_GetUserById')]
[Switch]$GetUserById,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='View_UsersList')]
[Switch]$UsersList,

[Parameter(Mandatory=$True, ParameterSetName='View_GetAuthenticationCredentials')]
[Parameter(Mandatory=$True, ParameterSetName='View_GetAuthenticationCredentialsConfigParams')]
[Parameter(Mandatory=$false, ParameterSetName='View_GetUserById')]
[Parameter(Mandatory=$false, ParameterSetName='View_UsersList')]
[String]$contextId,

[Parameter(Mandatory=$True, ParameterSetName='View_GetAuthenticationCredentials')]
[Parameter(Mandatory=$false, ParameterSetName='View_GetUserById')]
[String]$userId
)

## If I say...
If($GetAuthenticationCredentials){$Name = 'getAuthenticationCredentials'}
If($GetAuthenticationCredentialsConfigParams){$Name = 'getAuthenticationCredentialsConfigParams'}
If($GetUserById){$Name = 'getUserById'}
If($UsersList){$Name = 'usersList'}
If($contextId){$Param += @{'contextId'=$contextId}}
If($userId){$Param += @{'userId'=$userId}}

## Knowing that...
$Component = 'users'
$Type = 'view'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Other  ->  Acsrf  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Invoke-ZapAcsrf -NAME
.EXAMPLE
   Invoke-ZapAcsrf -NAME -ParamName -ParamValue  
#>
Function Invoke-ZapAcsrf(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Generate a form for testing lack of anti CSRF tokens - typically invoked via ZAP
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Other_GenForm')]
[Switch]$GenForm,

[Parameter(Mandatory=$True, ParameterSetName='Other_GenForm')]
[String]$hrefId
)

## If I say...
If($GenForm){$Name = 'genForm'}
If($hrefId){$Param += @{'hrefId'=$hrefId}}

## Knowing that...
$Component = 'acsrf'
$Type = 'other'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Other  ->  Core  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Invoke-ZapCore -NAME
.EXAMPLE
   Invoke-ZapCore -NAME -ParamName -ParamValue  
#>
Function Invoke-ZapCore(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Generates a report in HTML format
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Other_Htmlreport')]
[Switch]$Htmlreport,

# Gets the message with the given ID in HAR format
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Other_MessageHar')]
[Switch]$MessageHar,

# Gets the HTTP messages sent through/by ZAP, in HAR format, optionally filtered by URL and paginated with 'start' position and 'count' of messages
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Other_MessagesHar')]
[Switch]$MessagesHar,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Other_ProxyPac')]
[Switch]$ProxyPac,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Other_Rootcert')]
[Switch]$Rootcert,

# Sends the first HAR request entry, optionally following redirections. Returns, in HAR format, the request sent and response received and followed redirections, if any.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Other_SendHarRequest')]
[Switch]$SendHarRequest,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Other_Setproxy')]
[Switch]$Setproxy,

# Generates a report in XML format
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Other_Xmlreport')]
[Switch]$Xmlreport,

[Parameter(Mandatory=$false, ParameterSetName='Other_MessagesHar')]
[String]$baseurl,

[Parameter(Mandatory=$false, ParameterSetName='Other_MessagesHar')]
[String]$count,

[Parameter(Mandatory=$false, ParameterSetName='Other_SendHarRequest')]
[String]$followRedirects,

[Parameter(Mandatory=$True, ParameterSetName='Other_MessageHar')]
[String]$id,

[Parameter(Mandatory=$True, ParameterSetName='Other_Setproxy')]
[String]$proxy,

[Parameter(Mandatory=$True, ParameterSetName='Other_SendHarRequest')]
[String]$request,

[Parameter(Mandatory=$false, ParameterSetName='Other_MessagesHar')]
[String]$start
)

## If I say...
If($Htmlreport){$Name = 'htmlreport'}
If($MessageHar){$Name = 'messageHar'}
If($MessagesHar){$Name = 'messagesHar'}
If($ProxyPac){$Name = 'proxyPac'}
If($Rootcert){$Name = 'rootcert'}
If($SendHarRequest){$Name = 'sendHarRequest'}
If($Setproxy){$Name = 'setproxy'}
If($Xmlreport){$Name = 'xmlreport'}
If($baseurl){$Param += @{'baseurl'=$baseurl}}
If($count){$Param += @{'count'=$count}}
If($followRedirects){$Param += @{'followRedirects'=$followRedirects}}
If($id){$Param += @{'id'=$id}}
If($proxy){$Param += @{'proxy'=$proxy}}
If($request){$Param += @{'request'=$request}}
If($start){$Param += @{'start'=$start}}

## Knowing that...
$Component = 'core'
$Type = 'other'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Other  ->  Search  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Invoke-ZapSearch -NAME
.EXAMPLE
   Invoke-ZapSearch -NAME -ParamName -ParamValue  
#>
Function Invoke-ZapSearch(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Other_HarByHeaderRegex')]
[Switch]$HarByHeaderRegex,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Other_HarByRequestRegex')]
[Switch]$HarByRequestRegex,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Other_HarByResponseRegex')]
[Switch]$HarByResponseRegex,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Other_HarByUrlRegex')]
[Switch]$HarByUrlRegex,

[Parameter(Mandatory=$false, ParameterSetName='Other_HarByHeaderRegex')]
[Parameter(Mandatory=$false, ParameterSetName='Other_HarByRequestRegex')]
[Parameter(Mandatory=$false, ParameterSetName='Other_HarByResponseRegex')]
[Parameter(Mandatory=$false, ParameterSetName='Other_HarByUrlRegex')]
[String]$baseurl,

[Parameter(Mandatory=$false, ParameterSetName='Other_HarByHeaderRegex')]
[Parameter(Mandatory=$false, ParameterSetName='Other_HarByRequestRegex')]
[Parameter(Mandatory=$false, ParameterSetName='Other_HarByResponseRegex')]
[Parameter(Mandatory=$false, ParameterSetName='Other_HarByUrlRegex')]
[String]$count,

[Parameter(Mandatory=$True, ParameterSetName='Other_HarByHeaderRegex')]
[Parameter(Mandatory=$True, ParameterSetName='Other_HarByRequestRegex')]
[Parameter(Mandatory=$True, ParameterSetName='Other_HarByResponseRegex')]
[Parameter(Mandatory=$True, ParameterSetName='Other_HarByUrlRegex')]
[String]$regex,

[Parameter(Mandatory=$false, ParameterSetName='Other_HarByHeaderRegex')]
[Parameter(Mandatory=$false, ParameterSetName='Other_HarByRequestRegex')]
[Parameter(Mandatory=$false, ParameterSetName='Other_HarByResponseRegex')]
[Parameter(Mandatory=$false, ParameterSetName='Other_HarByUrlRegex')]
[String]$start
)

## If I say...
If($HarByHeaderRegex){$Name = 'harByHeaderRegex'}
If($HarByRequestRegex){$Name = 'harByRequestRegex'}
If($HarByResponseRegex){$Name = 'harByResponseRegex'}
If($HarByUrlRegex){$Name = 'harByUrlRegex'}
If($baseurl){$Param += @{'baseurl'=$baseurl}}
If($count){$Param += @{'count'=$count}}
If($regex){$Param += @{'regex'=$regex}}
If($start){$Param += @{'start'=$start}}

## Knowing that...
$Component = 'search'
$Type = 'other'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  Acsrf  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapAcsrf -NAME
.EXAMPLE
   Set-ZapAcsrf -NAME -ParamName -ParamValue  
#>
Function Set-ZapAcsrf(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Adds an anti CSRF token with the given name, enabled by default
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_AddOptionToken')]
[Switch]$AddOptionToken,

# Removes the anti CSRF token with the given name
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_RemoveOptionToken')]
[Switch]$RemoveOptionToken,

[Parameter(Mandatory=$True, ParameterSetName='Action_AddOptionToken')]
[Parameter(Mandatory=$True, ParameterSetName='Action_RemoveOptionToken')]
[String]$String
)

## If I say...
If($AddOptionToken){$Name = 'addOptionToken'}
If($RemoveOptionToken){$Name = 'removeOptionToken'}
If($String){$Param += @{'String'=$String}}

## Knowing that...
$Component = 'acsrf'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  AjaxSpider  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapAjaxSpider -NAME
.EXAMPLE
   Set-ZapAjaxSpider -NAME -ParamName -ParamValue  
#>
Function Set-ZapAjaxSpider(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Runs the spider against the given URL and/or context, optionally, spidering everything in scope. The parameter 'contextName' can be used to constrain the scan to a Context, the option 'in scope' is ignored if a context was also specified. The parameter 'subtreeOnly' allows to restrict the spider under a site's subtree (using the specified 'url').
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_Scan')]
[Switch]$Scan,

# Runs the spider from the perspective of a User, obtained using the given context name and user name. The parameter 'url' allows to specify the starting point for the spider, otherwise it's used an existing URL from the context (if any). The parameter 'subtreeOnly' allows to restrict the spider under a site's subtree (using the specified 'url').
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_ScanAsUser')]
[Switch]$ScanAsUser,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionBrowserId')]
[Switch]$SetOptionBrowserId,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionClickDefaultElems')]
[Switch]$SetOptionClickDefaultElems,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionClickElemsOnce')]
[Switch]$SetOptionClickElemsOnce,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionEventWait')]
[Switch]$SetOptionEventWait,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionMaxCrawlDepth')]
[Switch]$SetOptionMaxCrawlDepth,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionMaxCrawlStates')]
[Switch]$SetOptionMaxCrawlStates,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionMaxDuration')]
[Switch]$SetOptionMaxDuration,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionNumberOfBrowsers')]
[Switch]$SetOptionNumberOfBrowsers,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionRandomInputs')]
[Switch]$SetOptionRandomInputs,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionReloadWait')]
[Switch]$SetOptionReloadWait,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_Stop')]
[Switch]$Stop,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionClickDefaultElems')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionClickElemsOnce')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionRandomInputs')]
[String]$Boolean,

[Parameter(Mandatory=$false, ParameterSetName='Action_Scan')]
[Parameter(Mandatory=$True, ParameterSetName='Action_ScanAsUser')]
[String]$contextName,

[Parameter(Mandatory=$false, ParameterSetName='Action_Scan')]
[String]$inScope,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionEventWait')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionMaxCrawlDepth')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionMaxCrawlStates')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionMaxDuration')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionNumberOfBrowsers')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionReloadWait')]
[String]$Integer,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionBrowserId')]
[String]$String,

[Parameter(Mandatory=$false, ParameterSetName='Action_Scan')]
[Parameter(Mandatory=$false, ParameterSetName='Action_ScanAsUser')]
[String]$subtreeOnly,

[Parameter(Mandatory=$false, ParameterSetName='Action_Scan')]
[Parameter(Mandatory=$false, ParameterSetName='Action_ScanAsUser')]
[String]$url,

[Parameter(Mandatory=$True, ParameterSetName='Action_ScanAsUser')]
[String]$userName
)

## If I say...
If($Scan){$Name = 'scan'}
If($ScanAsUser){$Name = 'scanAsUser'}
If($SetOptionBrowserId){$Name = 'setOptionBrowserId'}
If($SetOptionClickDefaultElems){$Name = 'setOptionClickDefaultElems'}
If($SetOptionClickElemsOnce){$Name = 'setOptionClickElemsOnce'}
If($SetOptionEventWait){$Name = 'setOptionEventWait'}
If($SetOptionMaxCrawlDepth){$Name = 'setOptionMaxCrawlDepth'}
If($SetOptionMaxCrawlStates){$Name = 'setOptionMaxCrawlStates'}
If($SetOptionMaxDuration){$Name = 'setOptionMaxDuration'}
If($SetOptionNumberOfBrowsers){$Name = 'setOptionNumberOfBrowsers'}
If($SetOptionRandomInputs){$Name = 'setOptionRandomInputs'}
If($SetOptionReloadWait){$Name = 'setOptionReloadWait'}
If($Stop){$Name = 'stop'}
If($Boolean){$Param += @{'Boolean'=$Boolean}}
If($contextName){$Param += @{'contextName'=$contextName}}
If($inScope){$Param += @{'inScope'=$inScope}}
If($Integer){$Param += @{'Integer'=$Integer}}
If($String){$Param += @{'String'=$String}}
If($subtreeOnly){$Param += @{'subtreeOnly'=$subtreeOnly}}
If($url){$Param += @{'url'=$url}}
If($userName){$Param += @{'userName'=$userName}}

## Knowing that...
$Component = 'ajaxSpider'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  Ascan  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapAscan -NAME
.EXAMPLE
   Set-ZapAscan -NAME -ParamName -ParamValue  
#>
Function Set-ZapAscan(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_AddScanPolicy')]
[Switch]$AddScanPolicy,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_ClearExcludedFromScan')]
[Switch]$ClearExcludedFromScan,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_DisableAllScanners')]
[Switch]$DisableAllScanners,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_DisableScanners')]
[Switch]$DisableScanners,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_EnableAllScanners')]
[Switch]$EnableAllScanners,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_EnableScanners')]
[Switch]$EnableScanners,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_ExcludeFromScan')]
[Switch]$ExcludeFromScan,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_Pause')]
[Switch]$Pause,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_PauseAllScans')]
[Switch]$PauseAllScans,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_RemoveAllScans')]
[Switch]$RemoveAllScans,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_RemoveScan')]
[Switch]$RemoveScan,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_RemoveScanPolicy')]
[Switch]$RemoveScanPolicy,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_Resume')]
[Switch]$Resume,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_ResumeAllScans')]
[Switch]$ResumeAllScans,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_Scan')]
[Switch]$Scan,

# Active Scans from the perspective of a User, obtained using the given Context ID and User ID. See 'scan' action for more details.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_ScanAsUser')]
[Switch]$ScanAsUser,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetEnabledPolicies')]
[Switch]$SetEnabledPolicies,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetPolicyAlertThreshold')]
[Switch]$SetPolicyAlertThreshold,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetPolicyAttackStrength')]
[Switch]$SetPolicyAttackStrength,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetScannerAlertThreshold')]
[Switch]$SetScannerAlertThreshold,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetScannerAttackStrength')]
[Switch]$SetScannerAttackStrength,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_Stop')]
[Switch]$Stop,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_StopAllScans')]
[Switch]$StopAllScans,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetPolicyAlertThreshold')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetScannerAlertThreshold')]
[String]$alertThreshold,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetPolicyAttackStrength')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetScannerAttackStrength')]
[String]$attackStrength,

[Parameter(Mandatory=$True, ParameterSetName='Action_ScanAsUser')]
[String]$contextId,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetPolicyAlertThreshold')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetPolicyAttackStrength')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetScannerAlertThreshold')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetScannerAttackStrength')]
[String]$id,

[Parameter(Mandatory=$True, ParameterSetName='Action_DisableScanners')]
[Parameter(Mandatory=$True, ParameterSetName='Action_EnableScanners')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetEnabledPolicies')]
[String]$ids,

[Parameter(Mandatory=$false, ParameterSetName='Action_Scan')]
[String]$inScopeOnly,

[Parameter(Mandatory=$false, ParameterSetName='Action_Scan')]
[Parameter(Mandatory=$false, ParameterSetName='Action_ScanAsUser')]
[String]$method,

[Parameter(Mandatory=$false, ParameterSetName='Action_Scan')]
[Parameter(Mandatory=$false, ParameterSetName='Action_ScanAsUser')]
[String]$postData,

[Parameter(Mandatory=$false, ParameterSetName='Action_Scan')]
[Parameter(Mandatory=$false, ParameterSetName='Action_ScanAsUser')]
[String]$recurse,

[Parameter(Mandatory=$True, ParameterSetName='Action_ExcludeFromScan')]
[String]$regex,

[Parameter(Mandatory=$True, ParameterSetName='Action_Pause')]
[Parameter(Mandatory=$True, ParameterSetName='Action_RemoveScan')]
[Parameter(Mandatory=$True, ParameterSetName='Action_Resume')]
[Parameter(Mandatory=$True, ParameterSetName='Action_Stop')]
[String]$scanId,

[Parameter(Mandatory=$True, ParameterSetName='Action_AddScanPolicy')]
[Parameter(Mandatory=$false, ParameterSetName='Action_DisableAllScanners')]
[Parameter(Mandatory=$false, ParameterSetName='Action_EnableAllScanners')]
[Parameter(Mandatory=$True, ParameterSetName='Action_RemoveScanPolicy')]
[Parameter(Mandatory=$false, ParameterSetName='Action_Scan')]
[Parameter(Mandatory=$false, ParameterSetName='Action_ScanAsUser')]
[Parameter(Mandatory=$false, ParameterSetName='Action_SetPolicyAlertThreshold')]
[Parameter(Mandatory=$false, ParameterSetName='Action_SetPolicyAttackStrength')]
[Parameter(Mandatory=$false, ParameterSetName='Action_SetScannerAlertThreshold')]
[Parameter(Mandatory=$false, ParameterSetName='Action_SetScannerAttackStrength')]
[String]$scanPolicyName,

[Parameter(Mandatory=$True, ParameterSetName='Action_Scan')]
[Parameter(Mandatory=$True, ParameterSetName='Action_ScanAsUser')]
[String]$url,

[Parameter(Mandatory=$True, ParameterSetName='Action_ScanAsUser')]
[String]$userId
)

## If I say...
If($AddScanPolicy){$Name = 'addScanPolicy'}
If($ClearExcludedFromScan){$Name = 'clearExcludedFromScan'}
If($DisableAllScanners){$Name = 'disableAllScanners'}
If($DisableScanners){$Name = 'disableScanners'}
If($EnableAllScanners){$Name = 'enableAllScanners'}
If($EnableScanners){$Name = 'enableScanners'}
If($ExcludeFromScan){$Name = 'excludeFromScan'}
If($Pause){$Name = 'pause'}
If($PauseAllScans){$Name = 'pauseAllScans'}
If($RemoveAllScans){$Name = 'removeAllScans'}
If($RemoveScan){$Name = 'removeScan'}
If($RemoveScanPolicy){$Name = 'removeScanPolicy'}
If($Resume){$Name = 'resume'}
If($ResumeAllScans){$Name = 'resumeAllScans'}
If($Scan){$Name = 'scan'}
If($ScanAsUser){$Name = 'scanAsUser'}
If($SetEnabledPolicies){$Name = 'setEnabledPolicies'}
If($SetPolicyAlertThreshold){$Name = 'setPolicyAlertThreshold'}
If($SetPolicyAttackStrength){$Name = 'setPolicyAttackStrength'}
If($SetScannerAlertThreshold){$Name = 'setScannerAlertThreshold'}
If($SetScannerAttackStrength){$Name = 'setScannerAttackStrength'}
If($Stop){$Name = 'stop'}
If($StopAllScans){$Name = 'stopAllScans'}
If($alertThreshold){$Param += @{'alertThreshold'=$alertThreshold}}
If($attackStrength){$Param += @{'attackStrength'=$attackStrength}}
If($contextId){$Param += @{'contextId'=$contextId}}
If($id){$Param += @{'id'=$id}}
If($ids){$Param += @{'ids'=$ids}}
If($inScopeOnly){$Param += @{'inScopeOnly'=$inScopeOnly}}
If($method){$Param += @{'method'=$method}}
If($postData){$Param += @{'postData'=$postData}}
If($recurse){$Param += @{'recurse'=$recurse}}
If($regex){$Param += @{'regex'=$regex}}
If($scanId){$Param += @{'scanId'=$scanId}}
If($scanPolicyName){$Param += @{'scanPolicyName'=$scanPolicyName}}
If($url){$Param += @{'url'=$url}}
If($userId){$Param += @{'userId'=$userId}}

## Knowing that...
$Component = 'ascan'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  Ascan  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapAscan_O -NAME
.EXAMPLE
   Set-ZapAscan_O -NAME -ParamName -ParamValue  
#>
Function Set-ZapAscan_O(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionAllowAttackOnStart')]
[Switch]$SetOptionAllowAttackOnStart,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionAttackPolicy')]
[Switch]$SetOptionAttackPolicy,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionDefaultPolicy')]
[Switch]$SetOptionDefaultPolicy,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionDelayInMs')]
[Switch]$SetOptionDelayInMs,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionHandleAntiCSRFTokens')]
[Switch]$SetOptionHandleAntiCSRFTokens,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionHostPerScan')]
[Switch]$SetOptionHostPerScan,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionInjectPluginIdInHeader')]
[Switch]$SetOptionInjectPluginIdInHeader,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionMaxChartTimeInMins')]
[Switch]$SetOptionMaxChartTimeInMins,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionMaxResultsToList')]
[Switch]$SetOptionMaxResultsToList,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionMaxScansInUI')]
[Switch]$SetOptionMaxScansInUI,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionPromptInAttackMode')]
[Switch]$SetOptionPromptInAttackMode,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionPromptToClearFinishedScans')]
[Switch]$SetOptionPromptToClearFinishedScans,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionRescanInAttackMode')]
[Switch]$SetOptionRescanInAttackMode,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionShowAdvancedDialog')]
[Switch]$SetOptionShowAdvancedDialog,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionTargetParamsEnabledRPC')]
[Switch]$SetOptionTargetParamsEnabledRPC,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionTargetParamsInjectable')]
[Switch]$SetOptionTargetParamsInjectable,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionThreadPerHost')]
[Switch]$SetOptionThreadPerHost,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionAllowAttackOnStart')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionHandleAntiCSRFTokens')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionInjectPluginIdInHeader')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionPromptInAttackMode')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionPromptToClearFinishedScans')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionRescanInAttackMode')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionShowAdvancedDialog')]
[String]$Boolean,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionDelayInMs')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionHostPerScan')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionMaxChartTimeInMins')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionMaxResultsToList')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionMaxScansInUI')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionTargetParamsEnabledRPC')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionTargetParamsInjectable')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionThreadPerHost')]
[String]$Integer,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionAttackPolicy')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionDefaultPolicy')]
[String]$String
)

## If I say...
If($SetOptionAllowAttackOnStart){$Name = 'setOptionAllowAttackOnStart'}
If($SetOptionAttackPolicy){$Name = 'setOptionAttackPolicy'}
If($SetOptionDefaultPolicy){$Name = 'setOptionDefaultPolicy'}
If($SetOptionDelayInMs){$Name = 'setOptionDelayInMs'}
If($SetOptionHandleAntiCSRFTokens){$Name = 'setOptionHandleAntiCSRFTokens'}
If($SetOptionHostPerScan){$Name = 'setOptionHostPerScan'}
If($SetOptionInjectPluginIdInHeader){$Name = 'setOptionInjectPluginIdInHeader'}
If($SetOptionMaxChartTimeInMins){$Name = 'setOptionMaxChartTimeInMins'}
If($SetOptionMaxResultsToList){$Name = 'setOptionMaxResultsToList'}
If($SetOptionMaxScansInUI){$Name = 'setOptionMaxScansInUI'}
If($SetOptionPromptInAttackMode){$Name = 'setOptionPromptInAttackMode'}
If($SetOptionPromptToClearFinishedScans){$Name = 'setOptionPromptToClearFinishedScans'}
If($SetOptionRescanInAttackMode){$Name = 'setOptionRescanInAttackMode'}
If($SetOptionShowAdvancedDialog){$Name = 'setOptionShowAdvancedDialog'}
If($SetOptionTargetParamsEnabledRPC){$Name = 'setOptionTargetParamsEnabledRPC'}
If($SetOptionTargetParamsInjectable){$Name = 'setOptionTargetParamsInjectable'}
If($SetOptionThreadPerHost){$Name = 'setOptionThreadPerHost'}
If($Boolean){$Param += @{'Boolean'=$Boolean}}
If($Integer){$Param += @{'Integer'=$Integer}}
If($String){$Param += @{'String'=$String}}

## Knowing that...
$Component = 'ascan'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  Authentication  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapAuthentication -NAME
.EXAMPLE
   Set-ZapAuthentication -NAME -ParamName -ParamValue  
#>
Function Set-ZapAuthentication(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetAuthenticationMethod')]
[Switch]$SetAuthenticationMethod,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetLoggedInIndicator')]
[Switch]$SetLoggedInIndicator,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetLoggedOutIndicator')]
[Switch]$SetLoggedOutIndicator,

[Parameter(Mandatory=$false, ParameterSetName='Action_SetAuthenticationMethod')]
[String]$authMethodConfigParams,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetAuthenticationMethod')]
[String]$authMethodName,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetAuthenticationMethod')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetLoggedInIndicator')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetLoggedOutIndicator')]
[String]$contextId,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetLoggedInIndicator')]
[String]$loggedInIndicatorRegex,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetLoggedOutIndicator')]
[String]$loggedOutIndicatorRegex
)

## If I say...
If($SetAuthenticationMethod){$Name = 'setAuthenticationMethod'}
If($SetLoggedInIndicator){$Name = 'setLoggedInIndicator'}
If($SetLoggedOutIndicator){$Name = 'setLoggedOutIndicator'}
If($authMethodConfigParams){$Param += @{'authMethodConfigParams'=$authMethodConfigParams}}
If($authMethodName){$Param += @{'authMethodName'=$authMethodName}}
If($contextId){$Param += @{'contextId'=$contextId}}
If($loggedInIndicatorRegex){$Param += @{'loggedInIndicatorRegex'=$loggedInIndicatorRegex}}
If($loggedOutIndicatorRegex){$Param += @{'loggedOutIndicatorRegex'=$loggedOutIndicatorRegex}}

## Knowing that...
$Component = 'authentication'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  Autoupdate  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapAutoupdate -NAME
.EXAMPLE
   Set-ZapAutoupdate -NAME -ParamName -ParamValue  
#>
Function Set-ZapAutoupdate(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Downloads the latest release, if any
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_DownloadLatestRelease')]
[Switch]$DownloadLatestRelease,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionCheckAddonUpdates')]
[Switch]$SetOptionCheckAddonUpdates,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionCheckOnStart')]
[Switch]$SetOptionCheckOnStart,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionDownloadNewRelease')]
[Switch]$SetOptionDownloadNewRelease,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionInstallAddonUpdates')]
[Switch]$SetOptionInstallAddonUpdates,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionInstallScannerRules')]
[Switch]$SetOptionInstallScannerRules,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionReportAlphaAddons')]
[Switch]$SetOptionReportAlphaAddons,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionReportBetaAddons')]
[Switch]$SetOptionReportBetaAddons,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionReportReleaseAddons')]
[Switch]$SetOptionReportReleaseAddons,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionCheckAddonUpdates')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionCheckOnStart')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionDownloadNewRelease')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionInstallAddonUpdates')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionInstallScannerRules')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionReportAlphaAddons')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionReportBetaAddons')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionReportReleaseAddons')]
[String]$Boolean
)

## If I say...
If($DownloadLatestRelease){$Name = 'downloadLatestRelease'}
If($SetOptionCheckAddonUpdates){$Name = 'setOptionCheckAddonUpdates'}
If($SetOptionCheckOnStart){$Name = 'setOptionCheckOnStart'}
If($SetOptionDownloadNewRelease){$Name = 'setOptionDownloadNewRelease'}
If($SetOptionInstallAddonUpdates){$Name = 'setOptionInstallAddonUpdates'}
If($SetOptionInstallScannerRules){$Name = 'setOptionInstallScannerRules'}
If($SetOptionReportAlphaAddons){$Name = 'setOptionReportAlphaAddons'}
If($SetOptionReportBetaAddons){$Name = 'setOptionReportBetaAddons'}
If($SetOptionReportReleaseAddons){$Name = 'setOptionReportReleaseAddons'}
If($Boolean){$Param += @{'Boolean'=$Boolean}}

## Knowing that...
$Component = 'autoupdate'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  Break  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapBreak -NAME
.EXAMPLE
   Set-ZapBreak -NAME -ParamName -ParamValue  
#>
Function Set-ZapBreak(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_AddHttpBreakpoint')]
[Switch]$AddHttpBreakpoint,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_Break')]
[Switch]$Break,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_RemoveHttpBreakpoint')]
[Switch]$RemoveHttpBreakpoint,

[Parameter(Mandatory=$True, ParameterSetName='Action_AddHttpBreakpoint')]
[Parameter(Mandatory=$True, ParameterSetName='Action_RemoveHttpBreakpoint')]
[String]$ignorecase,

[Parameter(Mandatory=$True, ParameterSetName='Action_AddHttpBreakpoint')]
[Parameter(Mandatory=$True, ParameterSetName='Action_RemoveHttpBreakpoint')]
[String]$inverse,

[Parameter(Mandatory=$True, ParameterSetName='Action_AddHttpBreakpoint')]
[Parameter(Mandatory=$True, ParameterSetName='Action_RemoveHttpBreakpoint')]
[String]$location,

[Parameter(Mandatory=$True, ParameterSetName='Action_AddHttpBreakpoint')]
[Parameter(Mandatory=$True, ParameterSetName='Action_RemoveHttpBreakpoint')]
[String]$match,

[Parameter(Mandatory=$True, ParameterSetName='Action_Break')]
[String]$scope,

[Parameter(Mandatory=$True, ParameterSetName='Action_Break')]
[String]$state,

[Parameter(Mandatory=$True, ParameterSetName='Action_AddHttpBreakpoint')]
[Parameter(Mandatory=$True, ParameterSetName='Action_RemoveHttpBreakpoint')]
[String]$string,

[Parameter(Mandatory=$True, ParameterSetName='Action_Break')]
[String]$type
)

## If I say...
If($AddHttpBreakpoint){$Name = 'addHttpBreakpoint'}
If($Break){$Name = 'break'}
If($RemoveHttpBreakpoint){$Name = 'removeHttpBreakpoint'}
If($ignorecase){$Param += @{'ignorecase'=$ignorecase}}
If($inverse){$Param += @{'inverse'=$inverse}}
If($location){$Param += @{'location'=$location}}
If($match){$Param += @{'match'=$match}}
If($scope){$Param += @{'scope'=$scope}}
If($state){$Param += @{'state'=$state}}
If($string){$Param += @{'string'=$string}}
If($type){$Param += @{'type'=$type}}

## Knowing that...
$Component = 'break'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  Context  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapContext -NAME
.EXAMPLE
   Set-ZapContext -NAME -ParamName -ParamValue  
#>
Function Set-ZapContext(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Excludes all built in technologies from a context
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_ExcludeAllContextTechnologies')]
[Switch]$ExcludeAllContextTechnologies,

# Excludes technologies with the given names, separated by a comma, from a context
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_ExcludeContextTechnologies')]
[Switch]$ExcludeContextTechnologies,

# Add exclude regex to context
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_ExcludeFromContext')]
[Switch]$ExcludeFromContext,

# Exports the context with the given name to a file. If a relative file path is specified it will be resolved against the "contexts" directory in ZAP "home" dir.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_ExportContext')]
[Switch]$ExportContext,

# Imports a context from a file. If a relative file path is specified it will be resolved against the "contexts" directory in ZAP "home" dir.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_ImportContext')]
[Switch]$ImportContext,

# Includes all built in technologies in to a context
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_IncludeAllContextTechnologies')]
[Switch]$IncludeAllContextTechnologies,

# Includes technologies with the given names, separated by a comma, to a context
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_IncludeContextTechnologies')]
[Switch]$IncludeContextTechnologies,

# Add include regex to context
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_IncludeInContext')]
[Switch]$IncludeInContext,

# Creates a new context with the given name in the current session
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_NewContext')]
[Switch]$NewContext,

# Removes a context in the current session
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_RemoveContext')]
[Switch]$RemoveContext,

# Sets a context to in scope (contexts are in scope by default)
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetContextInScope')]
[Switch]$SetContextInScope,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetContextInScope')]
[String]$booleanInScope,

[Parameter(Mandatory=$True, ParameterSetName='Action_ExportContext')]
[Parameter(Mandatory=$True, ParameterSetName='Action_ImportContext')]
[String]$contextFile,

[Parameter(Mandatory=$True, ParameterSetName='Action_ExcludeAllContextTechnologies')]
[Parameter(Mandatory=$True, ParameterSetName='Action_ExcludeContextTechnologies')]
[Parameter(Mandatory=$True, ParameterSetName='Action_ExcludeFromContext')]
[Parameter(Mandatory=$True, ParameterSetName='Action_ExportContext')]
[Parameter(Mandatory=$True, ParameterSetName='Action_IncludeAllContextTechnologies')]
[Parameter(Mandatory=$True, ParameterSetName='Action_IncludeContextTechnologies')]
[Parameter(Mandatory=$True, ParameterSetName='Action_IncludeInContext')]
[Parameter(Mandatory=$True, ParameterSetName='Action_NewContext')]
[Parameter(Mandatory=$True, ParameterSetName='Action_RemoveContext')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetContextInScope')]
[String]$contextName,

[Parameter(Mandatory=$True, ParameterSetName='Action_ExcludeFromContext')]
[Parameter(Mandatory=$True, ParameterSetName='Action_IncludeInContext')]
[String]$regex,

[Parameter(Mandatory=$True, ParameterSetName='Action_ExcludeContextTechnologies')]
[Parameter(Mandatory=$True, ParameterSetName='Action_IncludeContextTechnologies')]
[String]$technologyNames
)

## If I say...
If($ExcludeAllContextTechnologies){$Name = 'excludeAllContextTechnologies'}
If($ExcludeContextTechnologies){$Name = 'excludeContextTechnologies'}
If($ExcludeFromContext){$Name = 'excludeFromContext'}
If($ExportContext){$Name = 'exportContext'}
If($ImportContext){$Name = 'importContext'}
If($IncludeAllContextTechnologies){$Name = 'includeAllContextTechnologies'}
If($IncludeContextTechnologies){$Name = 'includeContextTechnologies'}
If($IncludeInContext){$Name = 'includeInContext'}
If($NewContext){$Name = 'newContext'}
If($RemoveContext){$Name = 'removeContext'}
If($SetContextInScope){$Name = 'setContextInScope'}
If($booleanInScope){$Param += @{'booleanInScope'=$booleanInScope}}
If($contextFile){$Param += @{'contextFile'=$contextFile}}
If($contextName){$Param += @{'contextName'=$contextName}}
If($regex){$Param += @{'regex'=$regex}}
If($technologyNames){$Param += @{'technologyNames'=$technologyNames}}

## Knowing that...
$Component = 'context'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  Core  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapCore -NAME
.EXAMPLE
   Set-ZapCore -NAME -ParamName -ParamValue  
#>
Function Set-ZapCore(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_ClearExcludedFromProxy')]
[Switch]$ClearExcludedFromProxy,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_ClearStats')]
[Switch]$ClearStats,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_DeleteAllAlerts')]
[Switch]$DeleteAllAlerts,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_ExcludeFromProxy')]
[Switch]$ExcludeFromProxy,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_GenerateRootCA')]
[Switch]$GenerateRootCA,

# Loads the session with the given name. If a relative path is specified it will be resolved against the "session" directory in ZAP "home" dir.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_LoadSession')]
[Switch]$LoadSession,

# Creates a new session, optionally overwriting existing files. If a relative path is specified it will be resolved against the "session" directory in ZAP "home" dir.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_NewSession')]
[Switch]$NewSession,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_RunGarbageCollection')]
[Switch]$RunGarbageCollection,

# Saves the session with the name supplied, optionally overwriting existing files. If a relative path is specified it will be resolved against the "session" directory in ZAP "home" dir.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SaveSession')]
[Switch]$SaveSession,

# Sends the HTTP request, optionally following redirections. Returns the request sent and response received and followed redirections, if any.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SendRequest')]
[Switch]$SendRequest,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetHomeDirectory')]
[Switch]$SetHomeDirectory,

# Shuts down ZAP
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_Shutdown')]
[Switch]$Shutdown,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SnapshotSession')]
[Switch]$SnapshotSession,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetHomeDirectory')]
[String]$dir,

[Parameter(Mandatory=$false, ParameterSetName='Action_SendRequest')]
[String]$followRedirects,

[Parameter(Mandatory=$True, ParameterSetName='Action_ClearStats')]
[String]$keyPrefix,

[Parameter(Mandatory=$True, ParameterSetName='Action_LoadSession')]
[Parameter(Mandatory=$false, ParameterSetName='Action_NewSession')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SaveSession')]
[String]$name,

[Parameter(Mandatory=$false, ParameterSetName='Action_NewSession')]
[Parameter(Mandatory=$false, ParameterSetName='Action_SaveSession')]
[String]$overwrite,

[Parameter(Mandatory=$True, ParameterSetName='Action_ExcludeFromProxy')]
[String]$regex,

[Parameter(Mandatory=$True, ParameterSetName='Action_SendRequest')]
[String]$request
)

## If I say...
If($ClearExcludedFromProxy){$Name = 'clearExcludedFromProxy'}
If($ClearStats){$Name = 'clearStats'}
If($DeleteAllAlerts){$Name = 'deleteAllAlerts'}
If($ExcludeFromProxy){$Name = 'excludeFromProxy'}
If($GenerateRootCA){$Name = 'generateRootCA'}
If($LoadSession){$Name = 'loadSession'}
If($NewSession){$Name = 'newSession'}
If($RunGarbageCollection){$Name = 'runGarbageCollection'}
If($SaveSession){$Name = 'saveSession'}
If($SendRequest){$Name = 'sendRequest'}
If($SetHomeDirectory){$Name = 'setHomeDirectory'}
If($Shutdown){$Name = 'shutdown'}
If($SnapshotSession){$Name = 'snapshotSession'}
If($dir){$Param += @{'dir'=$dir}}
If($followRedirects){$Param += @{'followRedirects'=$followRedirects}}
If($keyPrefix){$Param += @{'keyPrefix'=$keyPrefix}}
If($name){$Param += @{'name'=$name}}
If($overwrite){$Param += @{'overwrite'=$overwrite}}
If($regex){$Param += @{'regex'=$regex}}
If($request){$Param += @{'request'=$request}}

## Knowing that...
$Component = 'core'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  Core  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapCore_O -NAME
.EXAMPLE
   Set-ZapCore_O -NAME -ParamName -ParamValue  
#>
Function Set-ZapCore_O(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionDefaultUserAgent')]
[Switch]$SetOptionDefaultUserAgent,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionHttpStateEnabled')]
[Switch]$SetOptionHttpStateEnabled,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionProxyChainName')]
[Switch]$SetOptionProxyChainName,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionProxyChainPassword')]
[Switch]$SetOptionProxyChainPassword,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionProxyChainPort')]
[Switch]$SetOptionProxyChainPort,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionProxyChainPrompt')]
[Switch]$SetOptionProxyChainPrompt,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionProxyChainRealm')]
[Switch]$SetOptionProxyChainRealm,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionProxyChainSkipName')]
[Switch]$SetOptionProxyChainSkipName,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionProxyChainUserName')]
[Switch]$SetOptionProxyChainUserName,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionSingleCookieRequestHeader')]
[Switch]$SetOptionSingleCookieRequestHeader,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionTimeoutInSecs')]
[Switch]$SetOptionTimeoutInSecs,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionUseProxyChain')]
[Switch]$SetOptionUseProxyChain,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionUseProxyChainAuth')]
[Switch]$SetOptionUseProxyChainAuth,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionHttpStateEnabled')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionProxyChainPrompt')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionSingleCookieRequestHeader')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionUseProxyChain')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionUseProxyChainAuth')]
[String]$Boolean,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionProxyChainPort')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionTimeoutInSecs')]
[String]$Integer,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionDefaultUserAgent')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionProxyChainName')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionProxyChainPassword')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionProxyChainRealm')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionProxyChainSkipName')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionProxyChainUserName')]
[String]$String
)

## If I say...
If($SetOptionDefaultUserAgent){$Name = 'setOptionDefaultUserAgent'}
If($SetOptionHttpStateEnabled){$Name = 'setOptionHttpStateEnabled'}
If($SetOptionProxyChainName){$Name = 'setOptionProxyChainName'}
If($SetOptionProxyChainPassword){$Name = 'setOptionProxyChainPassword'}
If($SetOptionProxyChainPort){$Name = 'setOptionProxyChainPort'}
If($SetOptionProxyChainPrompt){$Name = 'setOptionProxyChainPrompt'}
If($SetOptionProxyChainRealm){$Name = 'setOptionProxyChainRealm'}
If($SetOptionProxyChainSkipName){$Name = 'setOptionProxyChainSkipName'}
If($SetOptionProxyChainUserName){$Name = 'setOptionProxyChainUserName'}
If($SetOptionSingleCookieRequestHeader){$Name = 'setOptionSingleCookieRequestHeader'}
If($SetOptionTimeoutInSecs){$Name = 'setOptionTimeoutInSecs'}
If($SetOptionUseProxyChain){$Name = 'setOptionUseProxyChain'}
If($SetOptionUseProxyChainAuth){$Name = 'setOptionUseProxyChainAuth'}
If($Boolean){$Param += @{'Boolean'=$Boolean}}
If($Integer){$Param += @{'Integer'=$Integer}}
If($String){$Param += @{'String'=$String}}

## Knowing that...
$Component = 'core'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  ForcedUser  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapForcedUser -NAME
.EXAMPLE
   Set-ZapForcedUser -NAME -ParamName -ParamValue  
#>
Function Set-ZapForcedUser(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Sets the user (ID) that should be used in 'forced user' mode for the given context (ID)
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetForcedUser')]
[Switch]$SetForcedUser,

# Sets if 'forced user' mode should be enabled or not
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetForcedUserModeEnabled')]
[Switch]$SetForcedUserModeEnabled,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetForcedUserModeEnabled')]
[String]$boolean,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetForcedUser')]
[String]$contextId,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetForcedUser')]
[String]$userId
)

## If I say...
If($SetForcedUser){$Name = 'setForcedUser'}
If($SetForcedUserModeEnabled){$Name = 'setForcedUserModeEnabled'}
If($boolean){$Param += @{'boolean'=$boolean}}
If($contextId){$Param += @{'contextId'=$contextId}}
If($userId){$Param += @{'userId'=$userId}}

## Knowing that...
$Component = 'forcedUser'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  HttpSessions  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapHttpSessions -NAME
.EXAMPLE
   Set-ZapHttpSessions -NAME -ParamName -ParamValue  
#>
Function Set-ZapHttpSessions(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Adds the session token to the given site.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_AddSessionToken')]
[Switch]$AddSessionToken,

# Creates an empty session for the given site. Optionally with the given name.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_CreateEmptySession')]
[Switch]$CreateEmptySession,

# Removes the session from the given site.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_RemoveSession')]
[Switch]$RemoveSession,

# Removes the session token from the given site.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_RemoveSessionToken')]
[Switch]$RemoveSessionToken,

# Renames the session of the given site.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_RenameSession')]
[Switch]$RenameSession,

# Sets the given session as active for the given site.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetActiveSession')]
[Switch]$SetActiveSession,

# Sets the value of the session token of the given session for the given site.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetSessionTokenValue')]
[Switch]$SetSessionTokenValue,

# Unsets the active session of the given site.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_UnsetActiveSession')]
[Switch]$UnsetActiveSession,

[Parameter(Mandatory=$True, ParameterSetName='Action_RenameSession')]
[String]$newSessionName,

[Parameter(Mandatory=$True, ParameterSetName='Action_RenameSession')]
[String]$oldSessionName,

[Parameter(Mandatory=$false, ParameterSetName='Action_CreateEmptySession')]
[Parameter(Mandatory=$True, ParameterSetName='Action_RemoveSession')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetActiveSession')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetSessionTokenValue')]
[String]$session,

[Parameter(Mandatory=$True, ParameterSetName='Action_AddSessionToken')]
[Parameter(Mandatory=$True, ParameterSetName='Action_RemoveSessionToken')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetSessionTokenValue')]
[String]$sessionToken,

[Parameter(Mandatory=$True, ParameterSetName='Action_AddSessionToken')]
[Parameter(Mandatory=$True, ParameterSetName='Action_CreateEmptySession')]
[Parameter(Mandatory=$True, ParameterSetName='Action_RemoveSession')]
[Parameter(Mandatory=$True, ParameterSetName='Action_RemoveSessionToken')]
[Parameter(Mandatory=$True, ParameterSetName='Action_RenameSession')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetActiveSession')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetSessionTokenValue')]
[Parameter(Mandatory=$True, ParameterSetName='Action_UnsetActiveSession')]
[String]$site,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetSessionTokenValue')]
[String]$tokenValue
)

## If I say...
If($AddSessionToken){$Name = 'addSessionToken'}
If($CreateEmptySession){$Name = 'createEmptySession'}
If($RemoveSession){$Name = 'removeSession'}
If($RemoveSessionToken){$Name = 'removeSessionToken'}
If($RenameSession){$Name = 'renameSession'}
If($SetActiveSession){$Name = 'setActiveSession'}
If($SetSessionTokenValue){$Name = 'setSessionTokenValue'}
If($UnsetActiveSession){$Name = 'unsetActiveSession'}
If($newSessionName){$Param += @{'newSessionName'=$newSessionName}}
If($oldSessionName){$Param += @{'oldSessionName'=$oldSessionName}}
If($session){$Param += @{'session'=$session}}
If($sessionToken){$Param += @{'sessionToken'=$sessionToken}}
If($site){$Param += @{'site'=$site}}
If($tokenValue){$Param += @{'tokenValue'=$tokenValue}}

## Knowing that...
$Component = 'httpSessions'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  Pscan  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapPscan -NAME
.EXAMPLE
   Set-ZapPscan -NAME -ParamName -ParamValue  
#>
Function Set-ZapPscan(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Disables all passive scanners
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_DisableAllScanners')]
[Switch]$DisableAllScanners,

# Disables all passive scanners with the given IDs (comma separated list of IDs)
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_DisableScanners')]
[Switch]$DisableScanners,

# Enables all passive scanners
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_EnableAllScanners')]
[Switch]$EnableAllScanners,

# Enables all passive scanners with the given IDs (comma separated list of IDs)
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_EnableScanners')]
[Switch]$EnableScanners,

# Sets whether or not the passive scanning is enabled
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetEnabled')]
[Switch]$SetEnabled,

# Sets the alert threshold of the passive scanner with the given ID, accepted values for alert threshold: OFF, DEFAULT, LOW, MEDIUM and HIGH
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetScannerAlertThreshold')]
[Switch]$SetScannerAlertThreshold,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetScannerAlertThreshold')]
[String]$alertThreshold,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetEnabled')]
[String]$enabled,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetScannerAlertThreshold')]
[String]$id,

[Parameter(Mandatory=$True, ParameterSetName='Action_DisableScanners')]
[Parameter(Mandatory=$True, ParameterSetName='Action_EnableScanners')]
[String]$ids
)

## If I say...
If($DisableAllScanners){$Name = 'disableAllScanners'}
If($DisableScanners){$Name = 'disableScanners'}
If($EnableAllScanners){$Name = 'enableAllScanners'}
If($EnableScanners){$Name = 'enableScanners'}
If($SetEnabled){$Name = 'setEnabled'}
If($SetScannerAlertThreshold){$Name = 'setScannerAlertThreshold'}
If($alertThreshold){$Param += @{'alertThreshold'=$alertThreshold}}
If($enabled){$Param += @{'enabled'=$enabled}}
If($id){$Param += @{'id'=$id}}
If($ids){$Param += @{'ids'=$ids}}

## Knowing that...
$Component = 'pscan'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  Reveal  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapReveal -NAME
.EXAMPLE
   Set-ZapReveal -NAME -ParamName -ParamValue  
#>
Function Set-ZapReveal(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetReveal')]
[Switch]$SetReveal,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetReveal')]
[String]$reveal
)

## If I say...
If($SetReveal){$Name = 'setReveal'}
If($reveal){$Param += @{'reveal'=$reveal}}

## Knowing that...
$Component = 'reveal'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  Script  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapScript -NAME
.EXAMPLE
   Set-ZapScript -NAME -ParamName -ParamValue  
#>
Function Set-ZapScript(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Disables the script with the given name
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_Disable')]
[Switch]$Disable,

# Enables the script with the given name
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_Enable')]
[Switch]$Enable,

# Loads a script into ZAP from the given local file, with the given name, type and engine, optionally with a description
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_Load')]
[Switch]$Load,

# Removes the script with the given name
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_Remove')]
[Switch]$Remove,

# Runs the stand alone script with the give name
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_RunStandAloneScript')]
[Switch]$RunStandAloneScript,

[Parameter(Mandatory=$True, ParameterSetName='Action_Load')]
[String]$fileName,

[Parameter(Mandatory=$false, ParameterSetName='Action_Load')]
[String]$scriptDescription,

[Parameter(Mandatory=$True, ParameterSetName='Action_Load')]
[String]$scriptEngine,

[Parameter(Mandatory=$True, ParameterSetName='Action_Disable')]
[Parameter(Mandatory=$True, ParameterSetName='Action_Enable')]
[Parameter(Mandatory=$True, ParameterSetName='Action_Load')]
[Parameter(Mandatory=$True, ParameterSetName='Action_Remove')]
[Parameter(Mandatory=$True, ParameterSetName='Action_RunStandAloneScript')]
[String]$scriptName,

[Parameter(Mandatory=$True, ParameterSetName='Action_Load')]
[String]$scriptType
)

## If I say...
If($Disable){$Name = 'disable'}
If($Enable){$Name = 'enable'}
If($Load){$Name = 'load'}
If($Remove){$Name = 'remove'}
If($RunStandAloneScript){$Name = 'runStandAloneScript'}
If($fileName){$Param += @{'fileName'=$fileName}}
If($scriptDescription){$Param += @{'scriptDescription'=$scriptDescription}}
If($scriptEngine){$Param += @{'scriptEngine'=$scriptEngine}}
If($scriptName){$Param += @{'scriptName'=$scriptName}}
If($scriptType){$Param += @{'scriptType'=$scriptType}}

## Knowing that...
$Component = 'script'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  Selenium  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapSelenium -NAME
.EXAMPLE
   Set-ZapSelenium -NAME -ParamName -ParamValue  
#>
Function Set-ZapSelenium(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Sets the current path to ChromeDriver
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionChromeDriverPath')]
[Switch]$SetOptionChromeDriverPath,

# Sets the current path to Firefox binary
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionFirefoxBinaryPath')]
[Switch]$SetOptionFirefoxBinaryPath,

# Sets the current path to IEDriverServer
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionIeDriverPath')]
[Switch]$SetOptionIeDriverPath,

# Sets the current path to PhantomJS binary
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionPhantomJsBinaryPath')]
[Switch]$SetOptionPhantomJsBinaryPath,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionChromeDriverPath')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionFirefoxBinaryPath')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionIeDriverPath')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionPhantomJsBinaryPath')]
[String]$String
)

## If I say...
If($SetOptionChromeDriverPath){$Name = 'setOptionChromeDriverPath'}
If($SetOptionFirefoxBinaryPath){$Name = 'setOptionFirefoxBinaryPath'}
If($SetOptionIeDriverPath){$Name = 'setOptionIeDriverPath'}
If($SetOptionPhantomJsBinaryPath){$Name = 'setOptionPhantomJsBinaryPath'}
If($String){$Param += @{'String'=$String}}

## Knowing that...
$Component = 'selenium'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  SessionManagement  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapSessionManagement -NAME
.EXAMPLE
   Set-ZapSessionManagement -NAME -ParamName -ParamValue  
#>
Function Set-ZapSessionManagement(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetSessionManagementMethod')]
[Switch]$SetSessionManagementMethod,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetSessionManagementMethod')]
[String]$contextId,

[Parameter(Mandatory=$false, ParameterSetName='Action_SetSessionManagementMethod')]
[String]$methodConfigParams,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetSessionManagementMethod')]
[String]$methodName
)

## If I say...
If($SetSessionManagementMethod){$Name = 'setSessionManagementMethod'}
If($contextId){$Param += @{'contextId'=$contextId}}
If($methodConfigParams){$Param += @{'methodConfigParams'=$methodConfigParams}}
If($methodName){$Param += @{'methodName'=$methodName}}

## Knowing that...
$Component = 'sessionManagement'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  Spider  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapSpider -NAME
.EXAMPLE
   Set-ZapSpider -NAME -ParamName -ParamValue  
#>
Function Set-ZapSpider(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_ClearExcludedFromScan')]
[Switch]$ClearExcludedFromScan,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_ExcludeFromScan')]
[Switch]$ExcludeFromScan,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_Pause')]
[Switch]$Pause,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_PauseAllScans')]
[Switch]$PauseAllScans,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_RemoveAllScans')]
[Switch]$RemoveAllScans,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_RemoveScan')]
[Switch]$RemoveScan,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_Resume')]
[Switch]$Resume,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_ResumeAllScans')]
[Switch]$ResumeAllScans,

# Runs the spider against the given URL. Optionally, the 'maxChildren' parameter can be set to limit the number of children scanned, the 'recurse' parameter can be used to prevent the spider from seeding recursively and the parameter 'contextName' can be used to constrain the scan to a Context.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_Scan')]
[Switch]$Scan,

# Runs the spider from the perspective of a User, obtained using the given Context ID and User ID. See 'scan' action for more details.
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_ScanAsUser')]
[Switch]$ScanAsUser,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_Stop')]
[Switch]$Stop,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_StopAllScans')]
[Switch]$StopAllScans,

[Parameter(Mandatory=$True, ParameterSetName='Action_ScanAsUser')]
[String]$contextId,

[Parameter(Mandatory=$false, ParameterSetName='Action_Scan')]
[String]$contextName,

[Parameter(Mandatory=$false, ParameterSetName='Action_Scan')]
[Parameter(Mandatory=$false, ParameterSetName='Action_ScanAsUser')]
[String]$maxChildren,

[Parameter(Mandatory=$false, ParameterSetName='Action_Scan')]
[Parameter(Mandatory=$false, ParameterSetName='Action_ScanAsUser')]
[String]$recurse,

[Parameter(Mandatory=$True, ParameterSetName='Action_ExcludeFromScan')]
[String]$regex,

[Parameter(Mandatory=$True, ParameterSetName='Action_Pause')]
[Parameter(Mandatory=$True, ParameterSetName='Action_RemoveScan')]
[Parameter(Mandatory=$True, ParameterSetName='Action_Resume')]
[Parameter(Mandatory=$false, ParameterSetName='Action_Stop')]
[String]$scanId,

[Parameter(Mandatory=$True, ParameterSetName='Action_Scan')]
[Parameter(Mandatory=$True, ParameterSetName='Action_ScanAsUser')]
[String]$url,

[Parameter(Mandatory=$True, ParameterSetName='Action_ScanAsUser')]
[String]$userId
)

## If I say...
If($ClearExcludedFromScan){$Name = 'clearExcludedFromScan'}
If($ExcludeFromScan){$Name = 'excludeFromScan'}
If($Pause){$Name = 'pause'}
If($PauseAllScans){$Name = 'pauseAllScans'}
If($RemoveAllScans){$Name = 'removeAllScans'}
If($RemoveScan){$Name = 'removeScan'}
If($Resume){$Name = 'resume'}
If($ResumeAllScans){$Name = 'resumeAllScans'}
If($Scan){$Name = 'scan'}
If($ScanAsUser){$Name = 'scanAsUser'}
If($Stop){$Name = 'stop'}
If($StopAllScans){$Name = 'stopAllScans'}
If($contextId){$Param += @{'contextId'=$contextId}}
If($contextName){$Param += @{'contextName'=$contextName}}
If($maxChildren){$Param += @{'maxChildren'=$maxChildren}}
If($recurse){$Param += @{'recurse'=$recurse}}
If($regex){$Param += @{'regex'=$regex}}
If($scanId){$Param += @{'scanId'=$scanId}}
If($url){$Param += @{'url'=$url}}
If($userId){$Param += @{'userId'=$userId}}

## Knowing that...
$Component = 'spider'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  Spider  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapSpider_O -NAME
.EXAMPLE
   Set-ZapSpider_O -NAME -ParamName -ParamValue  
#>
Function Set-ZapSpider_O(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionHandleODataParametersVisited')]
[Switch]$SetOptionHandleODataParametersVisited,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionHandleParameters')]
[Switch]$SetOptionHandleParameters,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionMaxDepth')]
[Switch]$SetOptionMaxDepth,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionMaxScansInUI')]
[Switch]$SetOptionMaxScansInUI,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionParseComments')]
[Switch]$SetOptionParseComments,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionParseGit')]
[Switch]$SetOptionParseGit,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionParseRobotsTxt')]
[Switch]$SetOptionParseRobotsTxt,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionParseSitemapXml')]
[Switch]$SetOptionParseSitemapXml,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionParseSVNEntries')]
[Switch]$SetOptionParseSVNEntries,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionPostForm')]
[Switch]$SetOptionPostForm,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionProcessForm')]
[Switch]$SetOptionProcessForm,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionRequestWaitTime')]
[Switch]$SetOptionRequestWaitTime,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionScopeString')]
[Switch]$SetOptionScopeString,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionSendRefererHeader')]
[Switch]$SetOptionSendRefererHeader,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionShowAdvancedDialog')]
[Switch]$SetOptionShowAdvancedDialog,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionSkipURLString')]
[Switch]$SetOptionSkipURLString,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionThreadCount')]
[Switch]$SetOptionThreadCount,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionUserAgent')]
[Switch]$SetOptionUserAgent,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionHandleODataParametersVisited')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionParseComments')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionParseGit')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionParseRobotsTxt')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionParseSitemapXml')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionParseSVNEntries')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionPostForm')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionProcessForm')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionSendRefererHeader')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionShowAdvancedDialog')]
[String]$Boolean,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionMaxDepth')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionMaxScansInUI')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionRequestWaitTime')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionThreadCount')]
[String]$Integer,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionHandleParameters')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionScopeString')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionSkipURLString')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionUserAgent')]
[String]$String
)

## If I say...
If($SetOptionHandleODataParametersVisited){$Name = 'setOptionHandleODataParametersVisited'}
If($SetOptionHandleParameters){$Name = 'setOptionHandleParameters'}
If($SetOptionMaxDepth){$Name = 'setOptionMaxDepth'}
If($SetOptionMaxScansInUI){$Name = 'setOptionMaxScansInUI'}
If($SetOptionParseComments){$Name = 'setOptionParseComments'}
If($SetOptionParseGit){$Name = 'setOptionParseGit'}
If($SetOptionParseRobotsTxt){$Name = 'setOptionParseRobotsTxt'}
If($SetOptionParseSitemapXml){$Name = 'setOptionParseSitemapXml'}
If($SetOptionParseSVNEntries){$Name = 'setOptionParseSVNEntries'}
If($SetOptionPostForm){$Name = 'setOptionPostForm'}
If($SetOptionProcessForm){$Name = 'setOptionProcessForm'}
If($SetOptionRequestWaitTime){$Name = 'setOptionRequestWaitTime'}
If($SetOptionScopeString){$Name = 'setOptionScopeString'}
If($SetOptionSendRefererHeader){$Name = 'setOptionSendRefererHeader'}
If($SetOptionShowAdvancedDialog){$Name = 'setOptionShowAdvancedDialog'}
If($SetOptionSkipURLString){$Name = 'setOptionSkipURLString'}
If($SetOptionThreadCount){$Name = 'setOptionThreadCount'}
If($SetOptionUserAgent){$Name = 'setOptionUserAgent'}
If($Boolean){$Param += @{'Boolean'=$Boolean}}
If($Integer){$Param += @{'Integer'=$Integer}}
If($String){$Param += @{'String'=$String}}

## Knowing that...
$Component = 'spider'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  Stats  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapStats -NAME
.EXAMPLE
   Set-ZapStats -NAME -ParamName -ParamValue  
#>
Function Set-ZapStats(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
# Clears all of the statistics
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_ClearStats')]
[Switch]$ClearStats,

# Sets whether in memory statistics are enabled
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionInMemoryEnabled')]
[Switch]$SetOptionInMemoryEnabled,

# Sets the Statsd service hostname, supply an empty string to stop using a Statsd service
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionStatsdHost')]
[Switch]$SetOptionStatsdHost,

# Sets the Statsd service port
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionStatsdPort')]
[Switch]$SetOptionStatsdPort,

# Sets the prefix to be applied to all stats sent to the configured Statsd service
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetOptionStatsdPrefix')]
[Switch]$SetOptionStatsdPrefix,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionInMemoryEnabled')]
[String]$Boolean,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionStatsdPort')]
[String]$Integer,

[Parameter(Mandatory=$false, ParameterSetName='Action_ClearStats')]
[String]$keyPrefix,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionStatsdHost')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetOptionStatsdPrefix')]
[String]$String
)

## If I say...
If($ClearStats){$Name = 'clearStats'}
If($SetOptionInMemoryEnabled){$Name = 'setOptionInMemoryEnabled'}
If($SetOptionStatsdHost){$Name = 'setOptionStatsdHost'}
If($SetOptionStatsdPort){$Name = 'setOptionStatsdPort'}
If($SetOptionStatsdPrefix){$Name = 'setOptionStatsdPrefix'}
If($Boolean){$Param += @{'Boolean'=$Boolean}}
If($Integer){$Param += @{'Integer'=$Integer}}
If($keyPrefix){$Param += @{'keyPrefix'=$keyPrefix}}
If($String){$Param += @{'String'=$String}}

## Knowing that...
$Component = 'stats'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Action  ->  Users  
.DESCRIPTION
   PoSh WebApp ZapBot...
   See OWASP ZAP documentation for more info.

.EXAMPLE
   Set-ZapUsers -NAME
.EXAMPLE
   Set-ZapUsers -NAME -ParamName -ParamValue  
#>
Function Set-ZapUsers(){
[CmdletBinding(HelpUri ='https://github.com/zaproxy/zaproxy/wiki/ApiGen_Index')]
# ParamBlock
Param(
[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_NewUser')]
[Switch]$NewUser,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_RemoveUser')]
[Switch]$RemoveUser,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetAuthenticationCredentials')]
[Switch]$SetAuthenticationCredentials,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetUserEnabled')]
[Switch]$SetUserEnabled,

[Parameter(Position=0, Mandatory=$true, ParameterSetName='Action_SetUserName')]
[Switch]$SetUserName,

[Parameter(Mandatory=$false, ParameterSetName='Action_SetAuthenticationCredentials')]
[String]$authCredentialsConfigParams,

[Parameter(Mandatory=$True, ParameterSetName='Action_NewUser')]
[Parameter(Mandatory=$True, ParameterSetName='Action_RemoveUser')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetAuthenticationCredentials')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetUserEnabled')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetUserName')]
[String]$contextId,

[Parameter(Mandatory=$True, ParameterSetName='Action_SetUserEnabled')]
[String]$enabled,

[Parameter(Mandatory=$True, ParameterSetName='Action_NewUser')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetUserName')]
[String]$name,

[Parameter(Mandatory=$True, ParameterSetName='Action_RemoveUser')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetAuthenticationCredentials')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetUserEnabled')]
[Parameter(Mandatory=$True, ParameterSetName='Action_SetUserName')]
[String]$userId
)

## If I say...
If($NewUser){$Name = 'newUser'}
If($RemoveUser){$Name = 'removeUser'}
If($SetAuthenticationCredentials){$Name = 'setAuthenticationCredentials'}
If($SetUserEnabled){$Name = 'setUserEnabled'}
If($SetUserName){$Name = 'setUserName'}
If($authCredentialsConfigParams){$Param += @{'authCredentialsConfigParams'=$authCredentialsConfigParams}}
If($contextId){$Param += @{'contextId'=$contextId}}
If($enabled){$Param += @{'enabled'=$enabled}}
If($name){$Param += @{'name'=$name}}
If($userId){$Param += @{'userId'=$userId}}

## Knowing that...
$Component = 'users'
$Type = 'action'

## Make It So

# Get Property collection objects
IF($Param){$Param = $Param.GetEnumerator()} 

# Build URL
$URLStart = "localHost:8080/JSON/$Component/$Type/$Name"
$URLMid ="/?zapapiformat=JSON"
$URLEnd = ''

# Append param and value 
foreach($Obj in $Param){$URLEnd += "&" + $Obj.Name + "=" + $Obj.value}
$URLEnd = $URLEnd.replace(' ','+') 
$URL = $URLstart+$URLMid+$URLEnd

# write-verbose
Write-Verbose "API Call: $URL"

#Invoke-RestMethod
$Result = invoke-RestMethod "http://$URL"
return $Result

## Done

# EndFunction
}

　
　
<#
.Synopsis
   Get Zap Menu
.DESCRIPTION
   Show list of available Zap Commands and matching Help Page
.EXAMPLE
   Get-Zap
.EXAMPLE
   Zap
#>
function Get-Zap{
    [CmdletBinding()]
    [Alias("Zap")]
    Param()
    
    #Banner
    $Banner = @("
   ___     _       _____            
  / _ \___| |_    / _  / __ _ _ __  
 / /_\/ _ \ __|___\// / / _`` | '_ \ 
/ /_\\  __/ ||_____/ //\ (_| | |_) |
\____/\___|\__|   /____/\__,_| .__/.ps1 
##PoSh#Cmdlets#For#OWASP#Zap#|_|v1#####
#By SadProcessor
")
    # Action
    $Output = @()
    $List = Get-Help *Zap*
    Foreach($Item in $List){
        $Props = @{ "Name" = $Item.Name
                "Synopsis" = $Item.Synopsis
                "TFM" = "Help $($Item.Name)"
                }
        $Obj = New-Object PSCustomObject -Property $Props
        $Output += $Obj
    }

　
    $Banner
    Return $Output | Select -prop Synopsis,Name,TFM
}
Clear
 
