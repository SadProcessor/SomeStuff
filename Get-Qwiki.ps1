<#
.Synopsis
   Quick Wiki Search
.DESCRIPTION
   Get Wikipedia Search. Summary in Console or Full pages Online.
.EXAMPLE
   QWiki
.EXAMPLE
   Qwiki -Search PowerShell
.EXAMPLE
   Qwiki PowerShell -FR
.EXAMPLE
   Qwiki PowerShell,"Jeffrey Snover" -Online
.NOTES
   Page with matching title must exist in selected language
.FUNCTIONALITY
   Queries the Wiki API for summary > in console
   or opens corresponding wiki Page > online
#>
 Function Get-QWiki{
    [Alias('Qwiki')]
    Param([Parameter(Mandatory=$false,Position=0)][Alias('Search')][String[]]$Title = 'Wikipedia',
          [Parameter(Mandatory=$false,ParameterSetName='English')][Alias('EN')][Switch]$English,
          [Parameter(Mandatory=$true,ParameterSetName='Dutch')][Alias('NL')][Switch]$Dutch,
          [Parameter(Mandatory=$true,ParameterSetName='French')][Alias('FR')][Switch]$French,
          [Parameter(Mandatory=$true,ParameterSetName='Italian')][Alias('IT')][Switch]$Italian,
          [Parameter(Mandatory=$true,ParameterSetName='German')][Alias('DE')][Switch]$German,
          [Parameter(Mandatory=$true,ParameterSetName='Swedish')][Alias('SE')][Switch]$Swedish,
          [Parameter(Mandatory=$true,ParameterSetName='Norvegian')][Alias('NO')][Switch]$Norvegian,
          [Parameter(Mandatory=$true,ParameterSetName='Romanian')][Alias('RO')][Switch]$Romanian,
          [Parameter(Mandatory=$true,ParameterSetName='Polish')][Alias('PL')][Switch]$Polish,
          [Parameter(Mandatory=$false)][Alias('Web')][Switch]$Online
          )
    Begin{
        #Lang (Add yours...)
        If($Dutch){$Lang = 'nl'}
        ElseIf($French){$Lang = 'fr'}
        ElseIf($Italian){$Lang = 'it'}
        ElseIf($German){$Lang = 'de'}
        ElseIf($Swedish){$Lang = 'se'}
        ElseIf($Norvegian){$Lang = 'no'}
        ElseIf($Romanian){$Lang = 'ro'}
        ElseIf($Polish){$Lang = 'pl'}
        Else{$Lang = 'en'}

        }
    Process{
        #Call
        $Title|%{
            #Action
            If($Online){Start "https://$Lang.wikipedia.org/wiki/$_"
                }
            Else{$Call = "https://$Lang.wikipedia.org/api/rest_v1/page/summary/${_}?redirect=true"
                #Reply
                $Reply = irm $Call
                ##Format Output
                $reply | Select title, extract | fl
                }
            }
        }
    } 

