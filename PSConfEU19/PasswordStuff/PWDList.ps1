function ConvertTo-L33t{
    [Alias('L33t')]
    Param([Parameter(Mandatory=1,ValueFromPipeline=1)][String]$String)
    Process{
        $Out = $String
        try{$Out = $Out.replace('o','0').Replace('O','0')}catch{}
        try{$Out = $Out.replace('i','1').replace('I','1')}catch{}
        try{$Out = $out.replace('e','3').Replace('E','3')}catch{}
        try{$Out = $Out.Replace('a','4').Replace('A','4')}catch{}
        if($Out -notmatch $String){$Out}
        }
    }


function Get-PWDList{
    [Alias('PWDList')]
    Param(
        [Parameter(Mandatory=1,Position=0)][string[]]$List1,
        [Parameter(Mandatory=1,Position=1)][string[]]$List2,
        [Parameter(Mandatory=0,Position=2)][string[]]$List3,
        [Parameter(Mandatory=0,Position=3)][string[]]$List4
        )
    Process{
        foreach($Item1 in $List1){
            foreach($item2 in $List2){
                # Concat items
                $Output2 = $Item1 + $Item2
                ## If List3
                if($List3){
                    foreach($item3 in $List3){
                        # Concat
                        $Output3 = $Output2 + $Item3
                        ### if List4
                        if($List4){
                            foreach($item4 in $List4){
                                # Concat & Output
                                $Output3 + $Item4
                                }}
                        ### if No List4
                        # Output3 / L33t
                        else{$Output3}
                        }}
                ## If No List3
                # Output2
                Else{$Output2}
                }}}}
#############End


<#
Get-PWDList "<CompanyName>" 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec' '19','2019'

$adjectiv = Get-Content .\Adjectiv.txt
$color = Get-Content .\Color.txt
$Animal = Get-Content .\animal.txt

Get-PWDList $color $Animal

Get-PWDList $Adjectiv $Color $Animal

Get-PWDList $Adjectiv $Color $Animal (59..99) | Out-File PasswordList.txt
start-Process PasswordList.txt

gc .\PasswordList.txt | L33t | Out-File PasswordList_L33t.txt
Start-Process .\PasswordList_L33t.txt

#>