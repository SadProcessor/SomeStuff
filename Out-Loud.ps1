 function Out-Loud(){

    Param(
        #Message
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [ValidateNotNull()]
        [String[]]$Speech,

        #Voice
        [ValidateSet('David', 'Zira', 'Hazel')]
        [String]$Voice = 'Zira',

        #Volume
        [ValidateRange(0,100)]
        [int]$Volume=100,

        #Rate
        [ValidateRange(-10,10)]
        [int]$Rate=-1,

        #Don't wait for promt
        [switch]$Async,
        
        #Print text to screen
        [switch]$Print
        )

    Begin{
        #add speech type and create speech object
        Add-Type -AssemblyName System.speech
        $SpeechSynth = New-Object System.Speech.Synthesis.SpeechSynthesizer
        #adjust voice settings
        $SpeechSynth.SelectVoice("Microsoft $voice Desktop")
        $SpeechSynth.volume=$Volume
        $SpeechSynth.Rate=$Rate

        }

    Process{
        # Print text to screen if -Print        
        if($Print){$Speech}
        # Don't wait for prompt if -Async
        if($Async){$SpeechSynth.SpeakAsync($Speech) | Out-Null}
        # or just say it...
        else{$SpeechSynth.Speak($Speech)}
        }

    End{}
}
#create alias for cmdlet
set-alias Say Out-Loud

# 'Hello World' | Out-Loud
#  Say 'Hello World' -Voice David -Volume 100 -Rate -3 -Async 
