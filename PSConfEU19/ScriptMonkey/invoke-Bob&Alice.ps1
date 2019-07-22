function Set-ISEPrompt{
    [Alias('ISEPrompt')]
    Param(
        [Parameter(Mandatory=0,Position=0,ParameterSetName='Emoji')][EmojiName]$Emoji,
        [Parameter(Mandatory=1,ParameterSetName='PS')][Alias('PS')][Switch]$Mini,
        [Parameter(Mandatory=1,ParameterSetName='Path')][Alias('Path')][Switch]$Classic
        )
    Switch($PSCmdlet.ParameterSetName){
        Emoji  {$S="$(Get-Emoji $Emoji) > "}
        Mini   {$S='$Null'}
        Path   {$S='PS $($executionContext.SessionState.Path.CurrentLocation)$(">"*($nestedPromptLevel+1)) '}
        }
    $Null = nmo -sc ($Null=[ScriptBlock]::Create("Function Prompt{`"$S`"}"))
    $Null = & $Function:Prompt
    }

Function Set-ISEConsoleColor{
    [Alias('Color')]
    Param(
        [Parameter(Mandatory=0)][Windows.Media.Color]$Color="#FF012456"
        )
    $PSIse.Options.ConsolePaneBackgroundColor=$Color
    $PSIse.Options.ConsolePaneTextBackgroundColor=$Color
    $PSIse.Options.ErrorBackgroundColor=$Color
    $PsISe.Options.WarningBackgroundColor=$Color
    #$Color.ToString()
    }

Function Set-ISEConsoleText{
    [Alias('Text')]
    Param(
        [Parameter(Mandatory=0)][Windows.Media.Color]$Color='white'
        )
    $PSIse.Options.ConsolePaneForegroundColor=$Color.ToString()
    }

function Set-ISEClassic{
    [Alias('Classic')]
    Param()
    Set-ISEConsoleColor
    Set-ISEConsoleText white
    Clear-Host
    Set-Prompt -Classic
    }

Function Set-ISEKiwi{
    [Alias('Kiwi')]
    Param()
    Set-ISEHoodie -Shade Black -Text LightGreen -Emoji Kiwi
    }


function Set-ISEHoodie{
    [CmdletBinding(DefaultParameterSetName='ON')]
    [Alias('Hoodie')]
    Param(
        [ValidateSet('Black','DarkGray','LighGray')]
        [Parameter(mandatory=0,Position=0,ParameterSetname='ON')][String]$Shade='DarkGray',
        [ValidateSet('White','LightGreen')]
        [Parameter(mandatory=0,Position=1,ParameterSetname='ON')][String]$Text='White',
        [Parameter(mandatory=0,Position=2,ParameterSetName='ON')][EmojiName]$Emoji='Skull',
        [Parameter(Mandatory=0,ParameterSetName='ON')][Switch]$OFF,
        [Parameter(Mandatory=1,ParameterSetname='OFF')][Switch]$ON
        )
    if($OFF){Set-ISEClassic;Return}
    $C = Switch($Shade){
        Black    {'#FF000000'}
        DarkGray {'#FF303030'}
        LightGray{'#FF505050'}
        }
    Set-ISEConsoleColor $C
    Set-ISEConsoleText $Text
    Clear-Host
    Set-EmojiPrompt $Emoji
    }


function Invoke-Bob{
    [Alias('Bob')]
    Param(
        [Parameter(Mandatory=1,Position=1,ValueFromPipeline=1,ValueFromRemainingArguments=1)][String[]]$Text,
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=0)][EmojiName]$Emoji='Bob',
        [Parameter(Mandatory=0)][ConsoleColor]$Color='Cyan',
        [ValidateRange(-10,10)][Parameter(Mandatory=0)]$Rate=1,
        [Parameter(Mandatory=0)][Alias('x')][Switch]$VoiceOnly,
        [Parameter(Mandatory=0)][Switch]$Async
        )
    Begin{}
    Process{
        if(-Not$voiceOnly){
            if($Emoji){$Prmpt = "$(Emoji $Emoji) : "}
            Write-Host "$Prmpt$Text" -ForegroundColor $Color
            }
        say -voice David $Text -Rate $Rate -Async:$Async
        }
    End{}
    }
#End

function Invoke-Alice{
    [Alias('Alice')]
    Param(
        [Parameter(Mandatory=1,Position=1,ValueFromPipeline=1,ValueFromRemainingArguments=1)][String]$Text,
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=0)][EmojiName]$Emoji='Alice',
        [Parameter(Mandatory=0)][ConsoleColor]$Color='Magenta',
        [ValidateRange(-10,10)][Parameter(Mandatory=0)][int]$Rate=1,
        [Parameter(Mandatory=0)][Alias('x')][Switch]$VoiceOnly,
        [Parameter(Mandatory=0)][Switch]$Async
        )
    Begin{}
    Process{
        if(-Not$voiceOnly){
            if($Emoji){$Prmpt = "$(Emoji $Emoji) : "}
            Write-Host "$Prmpt$Text" -ForegroundColor $Color
            }
        say -Voice Zira $Text -Rate $Rate -Async:$Async
        }
    End{}
    }
#End

function Write-Demo{
    [Alias('Demo')]
    Param(
        [Parameter(Mandatory=0,ValueFromPipeline)][ScriptBlock]$ScriptBlock,
        [ValidateSet('Bob','Alice')]
        [Parameter(Mandatory=0)][String]$Voice='Bob',
        # Add color & Prompt
        [Parameter(Mandatory=0)][Switch]$NoResult,
        [Parameter(Mandatory=0)][Switch]$NoVoice
        )
    Begin{''
        $v=$(Switch($Voice){Bob{'David'}Alice{'Zira'}})
        }
    Process{
        Write-Host $(prompt) -NoNewline
        Sleep 1
        foreach($line in $ScriptBlock.ToString().trim().split("(`r`n)")-ne''){
            foreach($Part in ($line.split(' ')-ne'')){
                if(-Not$NoVoice){Say (Readable $Part) -voice $v -Async}
                #start-sleep -m 300             
                write-Host "$Part " -NoNewline
                if(-Not$NoVoice){Wait-Voice}
                }
            If($NoResult){Write-Host "`r`n"}
            if(-Not$NoResult){
                if(-Not$NoVoice){Say 'and hit ENTER' -voice $v}
                start-sleep -m 500
                #Write-Host "`r`n"
                Write-DemoResult $ScriptBlock
                }}}
    End{}<#-----#>
    }
#End




function Write-DemoResult{
    [Alias('Run')]
    Param(
        [Parameter()][Scriptblock]$ScriptBlock
        )
    ""
    $ScriptBlock.Invoke()
    }




function Get-ReadableCommand{
    [Alias('Readable')]
    Param(
        [Parameter()][String]$Text
        )
    $Replace = @{
        " -" = ' wack '
        '|'  =  'pipe to'

        }
    foreach($Thing in $Replace.Keys){$text=$text.replace($thing,$Replace.$Thing)}
    Return $Text
    }



Function Clear-PoShDemo{
    Write-PoShDemo {Clear} -NoVoice
    }

break
Clear-Host;start-sleep 1
$Command = 'Node User GARY_CATANIA@SUB.DOMAIN.LOCAL'
bob 'In this demo, I will show you how to do something'

