## SETUP ##

# Title
###########################
$host.UI.RawUI.WindowTitle = '  ¯\_(ツ)_/¯'

# Prompt
enum EmojiName{
    Skull
    Skull2
    Skull3
    Unicorn
    NinjaCat
    AstroCat
    DinoCat
    HackerCat
    HipsterCat
    Crazy
    Clown
    Cowboy
    Cool
    Monkey
    Alien
    UFO
    Poo
    Ghost
    Robot
    Pray
    Kiwi
    Pizza
    Burger
    Beer
    GamePad
    JoyStick
    Pistol
    UpDown
    Happy
    Sad
    Hmmm
    Shock
    Dog
    Cat
    Horns
    Punch
    FingersCrossed
    Alice
    Bob
    }



################################################## Emoji

<#
.Synopsis
   Get Emoji
.DESCRIPTION
   Get Emoji
.EXAMPLE
   Get-Emoji Unicorn
#>
function Get-Emoji{
    [Alias('Emoji')]
    Param(
        [Parameter(Mandatory=1)][EmojiName]$Emoji,
        [Parameter(Mandatory=0)][Switch]$Clip
        )
    $E = Switch($Emoji){
        Skull         {'☠️'}
        Skull2        {'💀'}
        skull3        {'🕱'}
        Unicorn       {'🦄'}
        NinjaCat      {'🐱‍👤'}
        AstroCat      {'🐱‍🚀'}
        DinoCat       {'🐱‍🐉'}
        HackerCat     {'🐱‍💻'}
        HipsterCat    {'🐱‍👓'}
        Crazy         {'🤪'}
        Clown         {'🤡'}
        CowBoy        {'🤠'}
        Cool          {'😎'}
        Monkey        {'🐵'}
        Alien         {'👽'}
        UFO           {'🛸'}
        Poo           {'💩'}
        Ghost         {'👻'}
        Robot         {'🤖'}
        Pray          {'🙏'}
        Kiwi          {'🥝'}
        Pizza         {'🍕'}
        Burger        {'🍔'}
        Beer          {'🍺'}
        GamePad       {'🎮'}
        JoyStick      {'🕹️'}
        Pistol        {'🔫'}
        UpDown        {'🙃'}
        Happy         {'😃'}
        Sad           {'😟'}
        hmmm          {'🤔'}
        Shock         {'😯'}
        Dog           {'🐕'}
        Cat           {'🐈'}
        Horns         {'🤘'}
        Punch         {'👊'}
        FingersCrossed{'🤞'}
        Alice         {'👩'}
        Bob           {'🧑'}
        }
    if($Clip){$E|Set-Clipboard}
    else{Return $E}
    }
#End



######################################### Set-EmojiPrompt

function Set-Prompt{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=0,Position=0,ParameterSetName='Emoji')][EmojiName]$Emoji,
        [Parameter(Mandatory=1,ParameterSetName='PS')][Alias('PS')][Switch]$PoSh,
        [Parameter(Mandatory=1,ParameterSetName='Path')][Alias('Path')][Switch]$Classic
        )
    Switch($PSCmdlet.ParameterSetName){
        Emoji{$S="$(Get-Emoji $Emoji) > "}
        PS   {$S='PS > '}
        Path {$S='PS $($executionContext.SessionState.Path.CurrentLocation)$(">"*($nestedPromptLevel+1)) '}
        }
    $Null = nmo -sc ($Null=[ScriptBlock]::Create("Function Prompt{`"$S`"}"))
    $Null = & $Function:Prompt
    }
#end
<#
.Synopsis
   Set Prompt
.DESCRIPTION
   Set Emoji Prompt
.EXAMPLE
   Set-Emoji Prompt Unicorn
   Example Description
#>
Function Set-EmojiPrompt{
    [Alias('EmojiPrompt')]
    Param(
        [Parameter(Mandatory=1,Position=0,ParameterSetName='Emoji')][EmojiName]$Name,
        [Parameter(Mandatory=1,ParameterSetName='Random')][Switch]$Random
        )
    if($Random){$Name=Get-random ([Enum]::GetNames([EmojiName]))}
    ## Make It So
    $P = Get-Emoji $Name
    $Null = nmo -sc ($Null=[ScriptBlock]::Create("Function Prompt{'$P > '}"))
    $Null = & $Function:Prompt
    }
#end

# Random Emoji Prompt
# Set-EmojiPrompt -random

# Fixed Emoji Prompt
#function prompt {"☠️ > "}
#New-Alias -Name 'here' -Value (Split-Path -Parent (dir).fullname[0]) -force

# Green Errors
###########################
$Settings = (Get-Host).PrivateData
$Settings.ErrorForegroundColor = "lightGreen"
$Settings.ErrorBackgroundColor = "#FF012456"

# @ PSDrive
###########################
#Try{New-PSDrive '@' -PSProvider FileSystem -Root "C:\Users\SadProcessor\Documents\PoSh" -Description 'Work in Progress' -ea sil | Out-Null}catch{}
#cd '@:' -ea SilentlyContinue

## TROLL ##

# PizzaEmoji
###########################
function Get-Pizza{[Alias('Pizza')]Param()((iwr http://emojipedia.org/search/?q=pizza).Content-split '`n'|sls 'h2.*>(.*)</s').matches.Groups[1].Value}


# add voice stuff
###########################
 function Out-Loud(){
    [Alias('Say')]
    Param(
        #Message
        [Parameter(Mandatory=1,Position=0,ValueFromPipeline=1,ValueFromRemainingArguments=1)]
        [ValidateNotNull()]
        [String[]]$Speech,
        #Voice
        [ValidateSet('Zira','David','Hazel')]
        [Alias('x')][String]$Voice = 'David',
        #Volume
        [ValidateRange(0,100)]
        [int]$Volume=100,
        #Rate
        [ValidateRange(-10,10)]
        [int]$Rate=1,
        #Don't wait for prompt
        [switch]$Async,
        #Print text to screen
        [switch]$Print
        )
    Begin{
        #add speech type and create speech object
        if(-Not$SpeechSynth){
            Add-Type -AssemblyName System.speech
            $Script:SpeechSynth = New-Object System.Speech.Synthesis.SpeechSynthesizer
            }
        #adjust voice settings
        $SpeechSynth.SelectVoice("Microsoft $Voice Desktop")
        $SpeechSynth.volume=$Volume
        $SpeechSynth.Rate=$Rate
        }
    Process{
        # Print text to screen if -Print        
        if($Print){$Speech}
        # Don't wait for prompt if -Async
        if($Async){$Null=$SpeechSynth.SpeakAsync("$Speech")}
        # or just say it...
        else{$SpeechSynth.Speak("$Speech")}
        }
    End{}
    }

#DemoGod
###########################
Function Invoke-DemoGod{
    [Alias('DemoGod','ShowMeWhatYouGot','GiantHead')]
    Param(
        # No Speech
        [Parameter()][Switch]$Silent,
        # Head Only
        [Parameter()][Switch]$NoText
        )
    # Head
    $Head = @("
         ___
     . -^   ``--,
    /# =========``-_ 
   /# (--====___====\
  /#   .- --.  . --.|
 /##   |  * ) (   * ),
 |##   \    /\ \   / |
 |###   ---   \ ---  |
 |####      ___)    #|
 |######           ##|
  \##### ---------- /
   \####           (
    ``\###          |
      \###         |
       \##        |
        \###.    .)
         ``======/

　
　
")
    # Banner
    $Banner = @("
         ___            
     . -^   ``--,       
    /# =========``-_     ____  _  _   __   _  _    _  _  ____
   /# (--====___====\  / ___)/ )( \ /  \ / )( \  ( \/ )(  __)
  /#   .- --.  . --.|  \___ \) __ ((  O )\ /\ /  / \/ \ ) _) 
 /##   |  * ) (   * ), (____/\_)(_/ \__/ (_/\_)  \_)(_/(____)
 |##   \    /\ \   / |                                       
 |###   ---   \ ---  |        _  _  _  _   __  ____          
 |####      ___)    #|       / )( \/ )( \ / _\(_  _)         
 |######           ##|       \ /\ /) __ (/    \ )(           
  \##### ---------- /        (_/\_)\_)(_/\_/\_/(__)          
   \####           (                                         
    ``\###          |    _  _  __   _  _     ___   __  ____  
      \###         |   ( \/ )/  \ / )( \   / __) /  \(_  _)  
       \##        |     )  /(  O )) \/ (  ( (_ \(  O ) )(    
        \###.    .)    (__/  \__/ \____/   \___/ \__/ (__)   
         ``======/                                           

　
　
")

    ## ACTION
    Clear
    sleep -sec 1
    if(!$Silent){
        # Load Voice Stuff
        Try{
            Add-Type -AssemblyName System.speech
            $SpeechSynth = New-Object System.Speech.Synthesis.SpeechSynthesizer
            #adjust voice settings
            $SpeechSynth.volume=90
            $SpeechSynth.Rate=-7
            }
        Catch{Write-Warning 'Could Not Load voice...'}
        }
    If($NoText){$Head}
    Else{$Banner}
    If(!$Silent){
        Start-Sleep -Mil 50
        # Speak
        Try{$SpeechSynth.SpeakAsync("Show Me What You Got") | Out-Null}Catch{}
        }
    }

###### PartyParrot
function Invoke-PartyParrot{
    [Alias('PartyParrot')]
    Param()
######################################### Frame 0
    $Frame_9 = @("
                         .cccc;;cc;';c.           
                      .,:dkdc:;;:c:,:d:.          
                     .loc'.,cc::c:::,..;:.        
                   .cl;....;dkdccc::,...c;        
                  .c:,';:'..ckc',;::;....;c.      
                .c:'.,dkkoc:ok:;llllc,,c,';:.     
               .;c,';okkkkkkkk:;lllll,:kd;.;:,.   
               co..:kkkkkkkkkk:;llllc':kkc..oNc   
             .cl;.,oxkkkkkkkkkc,:cll;,okkc'.cO;   
             ;k:..ckkkkkkkkkkkl..,;,.;xkko:',l'   
            .,...';dkkkkkkkkkkd;.....ckkkl'.cO;   
         .,,:,.;oo:ckkkkkkkkkkkdoc;;cdkkkc..cd,   
      .cclo;,ccdkkl;llccdkkkkkkkkkkkkkkkd,.c;     
     .lol:;;okkkkkxooc::coodkkkkkkkkkkkko'.oc     
   .c:'..lkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkd,.oc     
  .lo;,:cdkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkd,.c;     
,dx:..;lllllllllllllllllllllllllllllllllc'...     
cNO;........................................      
")
######################################### Frame 1
    $Frame_11 = @("
                .ckx;'........':c.                
             .,:c:::::oxxocoo::::,',.             
            .odc'..:lkkoolllllo;..;d,             
            ;c..:o:..;:..',;'.......;.            
           ,c..:0Xx::o:.,cllc:,'::,.,c.           
           ;c;lkXKXXXXl.;lllll;lKXOo;':c.         
         ,dc.oXXXXXXXXl.,lllll;lXXXXx,c0:         
         ;Oc.oXXXXXXXXo.':ll:;'oXXXXO;,l'         
         'l;;kXXXXXXXXd'.'::'..dXXXXO;,l'         
         'l;:0XXXXXXXX0x:...,:o0XXXXx,:x,         
         'l;;kXXXXXXXXXKkol;oXXXXXXXO;oNc         
        ,c'..ckk0XXXXXXXXXX00XXXXXXX0:;o:.        
      .':;..:do::ooookXXXXXXXXXXXXXXXo..c;        
    .',',:co0XX0kkkxxOXXXXXXXXXXXXXXXOc..;l.      
  .:;'..oXXXXXXXXXXXXXXXXXXXXXXXXXXXXXko;';:.     
.ldc..:oOXKXXXXXXKXXKXXXXXXXXXXXXXXXXXXXo..oc     
:0o...:dxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxo,.:,     
cNo........................................;'     
")
######################################### Frame 2
    $Frame_3 = @("
            .cc;.  ...  .;c.                      
         .,,cc:cc:lxxxl:ccc:;,.                   
        .lo;...lKKklllookl..cO;                   
      .cl;.,:'.okl;..''.;,..';:.                  
     .:o;;dkd,.ll..,cc::,..,'.;:,.                
     co..lKKKkokl.':lloo;''ol..;dl.               
   .,c;.,xKKKKKKo.':llll;.'oOxl,.cl,.             
   cNo..lKKKKKKKo'';llll;;okKKKl..oNc             
   cNo..lKKKKKKKko;':c:,'lKKKKKo'.oNc             
   cNo..lKKKKKKKKKl.....'dKKKKKxc,l0:             
   .c:'.lKKKKKKKKKk;....lKKKKKKo'.oNc             
     ,:.'oxOKKKKKKKOxxxxOKKKKKKxc,;ol:.           
     ;c..'':oookKKKKKKKKKKKKKKKKKk:.'clc.         
   ,xl'.,oxo;'';oxOKKKKKKKKKKKKKKKOxxl:::;,.      
  .dOc..lKKKkoooookKKKKKKKKKKKKKKKKKKKxl,;ol.     
  cx,';okKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKl..;lc.   
  co..:dddddddddddddddddddddddddddddddddl::',::.  
  co...........................................   
")
######################################### Frame 3
    $Frame_10 = @("
           .ccccccc.                              
      .,,,;cooolccoo;;,,.                         
     .dOx;..;lllll;..;xOd.                        
   .cdo;',loOXXXXXkll;';odc.                      
  ,ol:;c,':oko:cccccc,...ckl.                     
  ;c.;kXo..::..;c::'.......oc                     
,dc..oXX0kk0o.':lll;..cxxc.,ld,                   
kNo.'oXXXXXXo',:lll;..oXXOo;cOd.                  
KOc;oOXXXXXXo.':lol;..dXXXXl';xc                  
Ol,:k0XXXXXX0c.,clc'.:0XXXXx,.oc                  
KOc;dOXXXXXXXl..';'..lXXXXXo..oc                  
dNo..oXXXXXXXOx:..'lxOXXXXXk,.:; ..               
cNo..lXXXXXXXXXOolkXXXXXXXXXkl,..;:';.            
.,;'.,dkkkkk0XXXXXXXXXXXXXXXXXOxxl;,;,;l:.        
  ;c.;:''''':doOXXXXXXXXXXXXXXXXXXOdo;';clc.      
  ;c.lOdood:'''oXXXXXXXXXXXXXXXXXXXXXk,..;ol.     
  ';.:xxxxxocccoxxxxxxxxxxxxxxxxxxxxxxl::'.';;.   
  ';........................................;l'   
")
######################################### Frame 4
    $Frame_2 = @("
                                                  
        .;:;;,.,;;::,.                            
     .;':;........'co:.                           
   .clc;'':cllllc::,.':c.                         
  .lo;;o:coxdllllllc;''::,,.                      
.c:'.,cl,.'l:',,;;'......cO;                      
do;';oxoc;:l;;llllc'.';;'.,;.                     
c..ckkkkkkkd,;llllc'.:kkd;.':c.                   
'.,okkkkkkkkc;lllll,.:kkkdl,cO;                   
..;xkkkkkkkkc,ccll:,;okkkkk:,co,                  
..,dkkkkkkkkc..,;,'ckkkkkkkc;ll.                  
..'okkkkkkkko,....'okkkkkkkc,:c.                  
c..ckkkkkkkkkdl;,:okkkkkkkkd,.',';.               
d..':lxkkkkkkkkxxkkkkkkkkkkkdoc;,;'..'.,.         
o...'';llllldkkkkkkkkkkkkkkkkkkdll;..'cdo.        
o..,l;'''''';dkkkkkkkkkkkkkkkkkkkkdlc,..;lc.      
o..;lc;;;;;;,,;clllllllllllllllllllllc'..,:c.     
o..........................................;'     
")
######################################### Frame 5
    $Frame_6 = @("
                                                  
           .,,,,,,,,,.                            
         .ckKxodooxOOdcc.                         
      .cclooc'....';;cool.                        
     .loc;;;;clllllc;;;;;:;,.                     
   .c:'.,okd;;cdo:::::cl,..oc                     
  .:o;';okkx;';;,';::;'....,:,.                   
  co..ckkkkkddkc,cclll;.,c:,:o:.                  
  co..ckkkkkkkk:,cllll;.:kkd,.':c.                
.,:;.,okkkkkkkk:,cclll;.ckkkdl;;o:.               
cNo..ckkkkkkkkko,.;loc,.ckkkkkc..oc               
,dd;.:kkkkkkkkkx;..;:,.'lkkkkko,.:,               
  ;:.ckkkkkkkkkkc.....;ldkkkkkk:.,'               
,dc..'okkkkkkkkkxoc;;cxkkkkkkkkc..,;,.            
kNo..':lllllldkkkkkkkkkkkkkkkkkdcc,.;l.           
KOc,c;''''''';lldkkkkkkkkkkkkkkkkkc..;lc.         
xx:':;;;;,.,,...,;;cllllllllllllllc;'.;od,        
cNo.....................................oc        
")
######################################### Frame 6
    $Frame_14 = @("
                                                  
                                                  
                   .ccccccc.                      
               .ccckNKOOOOkdcc.                   
            .;;cc:ccccccc:,:c::,,.                
         .c;:;.,cccllxOOOxlllc,;ol.               
        .lkc,coxo:;oOOxooooooo;..:,               
      .cdc.,dOOOc..cOd,.',,;'....':l.             
      cNx'.lOOOOxlldOc..;lll;.....cO;             
     ,do;,:dOOOOOOOOOl'':lll;..:d:''c,            
     co..lOOOOOOOOOOOl'':lll;.'lOd,.cd.           
     co.'dOOOOOOOOOOOo,.;llc,.,dOOc..dc           
     co..lOOOOOOOOOOOOc.';:,..cOOOl..oc           
   .,:;.'::lxOOOOOOOOOo:'...,:oOOOc.'dc           
   ;Oc..cl'':lldOOOOOOOOdcclxOOOOx,.cd.           
  .:;';lxl''''':lldOOOOOOOOOOOOOOc..oc            
,dl,.'cooc:::,....,::coooooooooooc'.c:            
cNo.................................oc            
")
######################################### Frame 7
    $Frame_4 = @("
                                                  
                                                  
                                                  
                        .cccccccc.                
                  .,,,;;cc:cccccc:;;,.            
                .cdxo;..,::cccc::,..;l.           
               ,do:,,:c:coxxdllll:;,';:,.         
             .cl;.,oxxc'.,cc,.';;;'...oNc         
             ;Oc..cxxxc'.,c;..;lll;...cO;         
           .;;',:ldxxxdoldxc..;lll:'...'c,        
           ;c..cxxxxkxxkxxxc'.;lll:'','.cdc.      
         .c;.;odxxxxxxxxxxxd;.,cll;.,l:.'dNc      
        .:,''ccoxkxxkxxxxxxx:..,:;'.:xc..oNc      
      .lc,.'lc':dxxxkxxxxxxxol,...',lx:..dNc      
     .:,',coxoc;;ccccoxxxxxxxxo:::oxxo,.cdc.      
  .;':;.'oxxxxxc''''';cccoxxxxxxxxxxxc..oc        
,do:'..,:llllll:;;;;;;,..,;:lllllllll;..oc        
cNo.....................................oc        
")
######################################### Frame 8
    $Frame_12 = @("
                                                  
                                                  
                              .ccccc.             
                         .cc;'coooxkl;.           
                     .:c:::c:,,,,,;c;;,.'.        
                   .clc,',:,..:xxocc;'..c;        
                  .c:,';:ox:..:c,,,,,,...cd,      
                .c:'.,oxxxxl::l:.,loll;..;ol.     
                ;Oc..:xxxxxxxxx:.,llll,....oc     
             .,;,',:loxxxxxxxxx:.,llll;.,,.'ld,   
            .lo;..:xxxxxxxxxxxx:.'cllc,.:l:'cO;   
           .:;...'cxxxxxxxxxxxxoc;,::,..cdl;;l'   
         .cl;':,'';oxxxxxxdxxxxxx:....,cooc,cO;   
     .,,,::;,lxoc:,,:lxxxxxxxxxxxo:,,;lxxl;'oNc   
   .cdxo;':lxxxxxxc'';cccccoxxxxxxxxxxxxo,.;lc.   
  .loc'.'lxxxxxxxxocc;''''';ccoxxxxxxxxx:..oc     
olc,..',:cccccccccccc:;;;;;;;;:ccccccccc,.'c,     
Ol;......................................;l'      
")
######################################### Frame 9
    $Frame_13 = @("
                                                  
                              ,ddoodd,            
                         .cc' ,ooccoo,'cc.        
                      .ccldo;...',,...;oxdc.      
                   .,,:cc;.,'..;lol;;,'..lkl.     
                  .dOc';:ccl;..;dl,.''.....oc     
                .,lc',cdddddlccld;.,;c::'..,cc:.  
                cNo..:ddddddddddd;':clll;,c,';xc  
               .lo;,clddddddddddd;':clll;:kc..;'  
             .,c;..:ddddddddddddd:';clll,;ll,..   
             ;Oc..';:ldddddddddddl,.,c:;';dd;..   
           .''',:c:,'cdddddddddddo:,''..'cdd;..   
         .cdc';lddd:';lddddddddddddd;.';lddl,..   
      .,;::;,cdddddol;;lllllodddddddlcldddd:.'l;  
     .dOc..,lddddddddlcc:;'';cclddddddddddd;;ll.  
   .coc,;::ldddddddddddddlcccc:ldddddddddl:,cO;   
,xl::,..,cccccccccccccccccccccccccccccccc:;':xx,  
cNd.........................................;lOc  
")
######################################### Loop
    while(1){
        9,11,3,10,2,6,14,4,12,13|%{
            Clear
            Write-Host (gv -Name $("Frame_$_") -ValueOnly) -ForegroundColor $_
            Sleep -mil 123
            }}}
#########End

## UTILS ##

## Extra Methods Strings 
############################

# Base64 Encode/Decode
#Update-TypeData -TypeName System.String -MemberName "ToB64" -MemberType scriptproperty -Value {[System.Convert]::ToBase64String([System.Text.Encoding]::UNICODE.GetBytes($this))}
#Update-TypeData -TypeName System.String -MemberName "FromB64" -MemberType scriptproperty -Value {[System.Text.Encoding]::UNICODE.GetString([System.Convert]::FromBase64String($this))}

#ToClipBoard
#Update-TypeData -TypeName System.String -MemberName "ToClip" -MemberType scriptproperty -Value {$this | Set-Clipboard}
#ToFile
#Update-TypeData -TypeName System.String -MemberName "ToFile" -MemberType ScriptProperty -Value {New-Item -Path $pwd -Name Payload.txt -ItemType File -Value $this -Force}

# URL Encode/Decode
#[Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null
#Update-TypeData -TypeName System.String -MemberName "ToURL" -MemberType scriptproperty -Value {[System.Web.HttpUtility]::UrlEncode($this)}
#Update-TypeData -TypeName System.String -MemberName "FromURL" -MemberType scriptproperty -Value {[System.Web.HttpUtility]::UrlDecode($this)}
## To remove: Remove-TypeData -TypeName System.String



## OneLiner Split/Make
###########################

# Function to split one-liners at ';'
function SplitOneLiner(){
    $Editor = $psISE.CurrentFile.Editor;
    $Editor.text = $editor.text.replace(';',";`r`n");
}

# Function to split one-liners at ';'
function MakeOneLiner(){
    $Editor = $psISE.CurrentFile.Editor
    $Editor.text = $editor.text.replace("`r`n",'')
}



#================#
#  ScriptMonkey  # + Utils
##########################################
# ObjectCount
function Measure-ObjectCount{
    [Alias('Count')]
    Param(
        [Parameter(ValueFromPipeline=1)][PSObject[]]$Obj
        )
    Begin{[System.Collections.ArrayList]$Collect=@()}
    Process{Foreach($O in $Obj){
        $Null=$Collect.add($O)
        }}
    End{Return ($Collect|Measure).count}
    }
#End

# Name Only
function Select-ObjectNameOnly{
    [Alias('Name')]
    Param(
        [Parameter(ValueFromPipeline=1)][PSObject[]]$Obj
        )
    Begin{}
    Process{Foreach($O in $Obj){
        $O.Name
        }}
    End{}
    }
#End


# Obj > json > clipboard
function Set-ClipboardJson{
    Param(
        [Parameter(ValueFromPipeline=1)][PSObject[]]$Obj
        )
    Begin{[System.Collections.ArrayList]$Collect=@()}
    Process{Foreach($O in $Obj){
        $Null=$Collect.add($O)
        }}
    End{$Collect|ConvertTo-Json|Set-clipBoard}
    }
#End

# Expand Prop
function Expand-ObjectProperty{
    [Alias('Expand')]
    Param(
        [Parameter(Mandatory=1,Position=0)]$PropertyName,
        [Parameter(Mandatory=1,position=1,ValueFromPipeline=1)][PSObject[]]$InputObject
        )
    Process{foreach($Obj in $InputObject){
        $Obj | Select-Object -ExpandProperty $PropertyName
        }}}
#####End


# Match by Prop in Object Collection
function Find-ObjectPropertyMatch{
    [Alias('Match','Find-Match')]
    Param(
        [Parameter(Mandatory=1,Position=0)][Alias('A','In')]$ObjectA,
        [Parameter(Mandatory=1,Position=1)][Alias('B','And')]$ObjectB,
        [Parameter(Mandatory=0,Position=2)][Alias('On')][String]$Property='name',
        [Parameter(Mandatory=0)][Switch]$SimpleMatch,
        [ValidateSet('A','B')]
        [Parameter(Mandatory=0,Position=3)][String[]]$Show
        )
    if($SimpleMatch){$ObjA=$ObjectA;$ObjB=$ObjectB}
    else{$objA = $objectA.$Property;$ObjB = $ObjectB.$Property}
    $Finding = (Compare $ObjA $ObjB -IncludeEqual | Where SideIndicator -eq ==).InputObject
    Switch($Show){
        A{$ObjectA | where $Property -eq $Finding}
        B{$ObjectB | where $Property -eq $Finding}
        $Null{$Finding}
        }}
#####End



#region ###################### MONKEY
# If Script Monkey Object doesn't exist 
if(!$Monkey){
    # Init Script Monkey Object
    $Monkey = New-object PSCustomObject -Property @{
        AST            = $Null
        TOk            = $Null
        ERR            = $Null
        ASTList        = $Null
        TOKList        = $Null
        ERRMsg         = $Null
        FunctList      = $Null
        FocusFunction  = $Null
        ParamList      = $Null
        FocusParam     = $Null
        AttribList     = $Null
        }
    }
#endregion

#region ###################### TREE

<#
.Synopsis
   Parse Code
.DESCRIPTION
   Parse Current Scriptpane
.EXAMPLE
   Parse-Code
#>
function Parse-Code{
    [Alias('Parse','p')]
    param(
        # Path for Source Script
        [Parameter(Mandatory=$false)][String]$Path
        )
    # Determine Workspace
    $Space = $host.name
    # Break if Console Host (need ISE|VSCode)
    If($Space -eq 'ConsoleHost'){Write-Warning "Can't Load ScriptMonkey - Use Editor";Break}    
    
    ## ISE
    If($Space -eq 'Windows PowerShell ISE Host'-AND -not $Path){
        $SourceCode = $psISE.Currentfile.Editor.text
        }
    ## VSCode
    ElseIf($Space -eq 'Visual Studio Code Host' -AND -not $Path){
        $SourceCode = $psEditor.GetEditorContext().CurrentFile.AST.Extent.Text
        }
    # Parse Code to AST/TOK/ERR
    $TOK=$ERR=$null
    $AST = [System.Management.Automation.Language.Parser]::ParseInput($SourceCode,[ref]$TOK,[ref]$ERR)
    # Error warning
    if($ERR.count -gt 0){Write-Warning 'Found Error in Source Code...'}
    # Set Monkey Obj
    $Script:Monkey.AST = $AST
    $Script:Monkey.TOK = $TOK
    $Script:Monkey.ERR = $ERR
    $Script:Monkey.ASTList = $AST.FindAll({$true},$True) | %{$_.gettype().name} | sort -Unique
    $Script:Monkey.TOKList = ($TOK).Kind | Sort -Unique
    Try{$Script:Monkey.ERRMsg  = $Script:Monkey.Error[0].Message}Catch{}
    $Script:Monkey.FunctList = @(($AST.FindAll({$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]},$true)).Name)
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Get-Tree{
    [CmdletBinding()]
    [Alias('Tree')]
    Param(
        # Restrict search to Parent tree
        [Parameter()][System.Management.Automation.Language.Ast]$Parent
        )
    DynamicParam{
        # Prep VSet
        $VSet = @('*')
        $VSet += $Script:Monkey.ASTList
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $true
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)
        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Type', [String], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Type', $DynParam)
        ## Return Dictionary
        return $Dictionary       
        }
    Begin{}
    Process{
        $Dyn = $DynParam.Value
        if($Dyn -eq '*'){$Script:Monkey.ASTList;Break}
        $result = ($Script:Monkey.AST).findAll({$args[0] -is ("System.Management.Automation.Language.$Dyn" -as [Type])},$true)
        if($Parent){$Result = $Result | ?{$_.Extent.StartOffset -gt $Parent.Extent.StartOffset -AND $_.Extent.EndOffset -lt $Parent.Extent.EndOffset}}
        }
    End{Return $Result} 
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Get-Token{
    [CmdletBinding()]
    Param(
        # Restrict search to parent tree
        [Parameter()][System.Management.Automation.Language.AST]$Parent
        )
    DynamicParam{
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $True
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($Script:Monkey.TOKList)
        $Collection.Add($ValidateSet)
        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Kind', [String], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Kind', $DynParam)
        ## Return Dictionary
        return $Dictionary         
        }
    Begin{}
    Process{
        $Result =  $Script:Monkey.TOK | where kind -eq $DynParam.Value
        if($Parent){$Result = $Result | ?{$_.Extent.StartOffset -gt $Parent.Extent.StartOffset -AND $_.Extent.EndOffset -lt $Parent.Extent.EndOffset}}
        }
    End{Return $result}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
Function Get-Error{
    [Alias('Err')]
    Param()
    $er ='-'
    if($Error[0].Errors.Exception -ne $Null){$er = $Error[0].Errors.Exception}
    if($Error[0].Message -ne $Null){$er = $error[0].Message}
    if($Error[0].Exception -ne $Null){$er = $error[0].Exception.Message}
    $L = $Error[0].InvocationInfo.ScriptLineNumber
    $C = $Error[0].InvocationInfo.OffsetInLine
    Write-Host "[$L-$C] $er :(" -ForegroundColor Green
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Get-FunctionTree{
    [CmdletBinding()]
    [Alias('FunctionTree')]
    Param()
    DynamicParam{
        # Prep VSet
        $VSet = @('*')
        #  function names
        $VSet += (Get-Tree -Type FunctionDefinitionAst).name

        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $false
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)
        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [String], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Name', $DynParam)
        ## Return Dictionary
        return $Dictionary       
        }
    Begin{}
    Process{
        $Dyn = $DynParam.Value
        $result = Get-Tree -Type FunctionDefinitionAst
        if($Dyn -eq '*'){$Result = $result.name}
        if($DynParam.IsSet -AND $Dyn -ne '*'){$result = $result | ? {$_.Name -eq $DynParam.Value}}
        }
    End{Return $result}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Get-ParamTree{
    [CmdletBinding()]
    [Alias('ParamTree')]
    Param()
    DynamicParam{
        # Get function names
        $VSet = (Get-Tree -Type ParameterAst -Parent (Get-FunctionTree $Script:Monkey.FocusFunction)).Name.VariablePath.UserPath
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $false
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)
        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [String], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Name', $DynParam)
        ## Return Dictionary
        return $Dictionary       
        }
    Begin{}
    Process{
        $result = Get-Tree -Type ParameterAst -Parent (Get-FunctionTree -Name $Script:Monkey.FocusFunction)
        if($DynParam.IsSet){$result = $result | ? {$_.Name.VariablePath.UserPath -eq $DynParam.Value}}
        Else{$result = $result.name}
        }
    End{Return $result}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
Function Get-Extent{
    [Alias('Extent')]
    Param(
        # Specify target tree
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$True)][System.Management.Automation.Language.AST]$Tree
        )
    # Return Position
    Return $Tree.Extent
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
Function Select-Tree{
    [Alias('TreeSelect','st')]
    Param(
        # Specify target tree
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$True)][System.Management.Automation.Language.AST]$Tree
        )
    # Select Text    
    $Pos = Get-Extent $tree
    #ISE
    if($Host.Name -eq 'Windows PowerShell ISE Host'){        
        $Editor = $psISE.CurrentFile.Editor
        $Editor.select($Pos.StartLineNumber,$Pos.startColumnNumber,$Pos.EndLineNumber,$Pos.EndColumnNumber)
        $psISE.CurrentPowerShellTab.ConsolePane.Focus()
        }
    #VSCode
    ElseIf($Host.Name -eq 'Visual Studio Code Host'){
        $psEditor.GetEditorContext().SetSelection($Pos.StartLineNumber,$Pos.startColumnNumber,$Pos.EndLineNumber,$Pos.EndColumnNumber)
        }
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Get-Selected{
    # ISE
    If($Host.Name -eq 'Windows PowerShell ISE Host'){
        Return $psISE.CurrentFile.Editor.SelectedText
        }
    # VSCode
    ElseIf($Host.Name -eq 'Visual Studio Code Host'){
        # Get Selected range
        $range = $psEditor.GetEditorContext().SelectedRange
        # Return Selected Text
        Return $psEditor.GetEditorContext().CurrentFile.GetText($Range)
        }
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#> 
function Set-Selected{
    [Alias('Insert','i')]
    Param([AllowEmptyString()][Parameter(Mandatory=$true,Position=0)][String]$String)
    # ISE
    If($Host.Name -eq 'Windows PowerShell ISE Host'){
        $psISE.CurrentFile.Editor.InsertText("$String")
        $psISE.CurrentPowerShellTab.ConsolePane.Focus()
        }
    # VSCode
    ElseIf($Host.Name -eq 'Visual Studio Code Host'){
        # Get Range
        $range = $psEditor.GetEditorContext().SelectedRange
        # Insert Text Range
        If($Range -ne $Null){$psEditor.GetEditorContext().CurrentFile.InsertText("$String",$Range)}
        Else{$psEditor.GetEditorContext().CurrentFile.InsertText("$String")}
        }    
    Parse-Code
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Clear-Selected{
    [Alias('Delete')]
    Param()
    Set-Selected ''
    Parse-Code
    } 

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
Function Get-Text{
    Param(
        # Specify target tree
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$True)][System.Management.Automation.Language.AST]$Tree
        )
    # return Tree Text
    Return $tree.Extent.Text
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Get-SubTree{
    [Alias('Sub','gs')]
    Param(
        [ValidateSet(
            'Binding',
            'AliasF',
            'Output',
            'DefaultPSN',
            'ShouldProcess',
            'PosBinding',
            'HelpUri',
            'HelpMess',
            'ConfImpact',
            'NameP',
            'Attrib',
            'AliasP',
            'Type',
            'DefaultVal',
            'Mandatory',
            'Position',
            'ParamSetName',
            'Pipeline',
            'PipelineByProp',
            'RemainingArgs',
            'ValSet',
            'ValLength',
            'ValCount',
            'ValRange',
            'ValPattern',
            'ValScript',
            'ValNotNull',
            'ValNotNullEmpty',
            'AllowNull',
            'AllowEString',
            'AllowECollect')]
        [Parameter(Mandatory=$true)]$Type,
        [Parameter()][String]$PSN
        )
    # Focused FunctionBlock
    $FFTree = Get-FunctionTree $Script:Monkey.FocusFunction
    # focused ParamBlock
    try{$FPTree = Get-ParamTree $Script:Monkey.FocusParam}Catch{}
    # Find sub tree
    Switch($type){
        <# Function #>
        'Binding'          {$SubT = ( Get-Tree ParamBlockAST -Parent $FFtree).Attributes | ? {$_.TypeName.Name -eq 'CmdletBinding'}}
        'AliasF'           {$SubT = ( Get-Tree ParamBlockAST -Parent $FFtree).Attributes | ? {$_.TypeName.Name -eq 'Alias'}}
        'Output'           {$SubT = ( Get-Tree ParamBlockAST -Parent $FFtree).Attributes | ? {$_.TypeName.Name -eq 'OutputType'}}
        'DefaultPSN'       {$SubT = ((Get-Tree ParamBlockAST -Parent $FFtree).Attributes | ? {$_.TypeName.Name -eq 'CmdletBinding'}).NamedArguments | ? {$_.ArgumentName -eq 'DefaultParameterSetName'}}
        'ShouldProcess'    {$SubT = ((Get-Tree ParamBlockAST -Parent $FFtree).Attributes | ? {$_.TypeName.Name -eq 'CmdletBinding'}).NamedArguments | ? {$_.ArgumentName -eq 'SupportsShouldProcess'}}
        'PosBinding'       {$SubT = ((Get-Tree ParamBlockAST -Parent $FFtree).Attributes | ? {$_.TypeName.Name -eq 'CmdletBinding'}).NamedArguments | ? {$_.ArgumentName -eq 'PositionalBinding'}}
        'HelpURI'          {$SubT = ((Get-Tree ParamBlockAST -Parent $FFtree).Attributes | ? {$_.TypeName.Name -eq 'CmdletBinding'}).NamedArguments | ? {$_.ArgumentName -eq 'HelpUri'}}
        'ConfImpact'       {$SubT = ((Get-Tree ParamBlockAST -Parent $FFtree).Attributes | ? {$_.TypeName.Name -eq 'CmdletBinding'}).NamedArguments | ? {$_.ArgumentName -eq 'ConfirmImpact'}}
        <# Param #>
        'NameP'            {$SubT =  $FPTree.Name}
        'Mandatory'        {$SubT = ($FPTree.Attributes  | ? {$_.TypeName.Name -eq 'Parameter'}).NamedArguments | ? {$_.ArgumentName -eq 'Mandatory'}}
        'Position'         {$SubT = ($FPTree.Attributes  | ? {$_.TypeName.Name -eq 'Parameter'}).NamedArguments | ? {$_.ArgumentName -eq 'Position'}}
        'ParamSetname'     {$SubT = ($FPTree.Attributes  | ? {$_.TypeName.Name -eq 'Parameter'}).NamedArguments | ? {$_.ArgumentName -eq 'ParameterSetName'}}
        'Pipeline'         {$SubT = ($FPTree.Attributes  | ? {$_.TypeName.Name -eq 'Parameter'}).NamedArguments | ? {$_.ArgumentName -eq 'ValueFromPipeline'}}
        'PipelineByProp'   {$SubT = ($FPTree.Attributes  | ? {$_.TypeName.Name -eq 'Parameter'}).NamedArguments | ? {$_.ArgumentName -eq 'ValueFromPipelineByPropertyName'}}
        'RemainingArgs'    {$SubT = ($FPTree.Attributes  | ? {$_.TypeName.Name -eq 'Parameter'}).NamedArguments | ? {$_.ArgumentName -eq 'ValueFromRemainingArguments'}}
        'HelpMess'         {$SubT = ($FPTree.Attributes  | ? {$_.TypeName.Name -eq 'Parameter'}).NamedArguments | ? {$_.ArgumentName -eq 'HelpMessage'}}
        'AliasP'           {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'Alias'}}
        'ValSet'           {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'ValidateSet'}}
        'ValLength'        {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'ValidateLength'}}
        'ValRange'         {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'ValidateRange'}}
        'ValPattern'       {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'ValidatePattern'}}
        'ValCount'         {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'ValidateCount'}}
        'ValScript'        {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'ValidateScript'}}
        'ValNotNull'       {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'ValidateNotNull'}}
        'ValNotNullEmpty'  {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'ValidateNotNullOrEmpty'}}
        'AllowNull'        {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'AllowNull'}}
        'AllowEString'     {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'AllowEmptyString'}}
        'AllowECollect'    {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'AllowEmptyCollection'}}
        'Attrib'           {$SubT =  $FPTree.Attributes  | ? {$_.TypeName.Name -eq 'Parameter'}
            If($SubT.count -gt 1 -AND !$PSN){$SubT=$Null;Write-Warning "Multiple PSN - please Specify..."}
            If($PSN){$SubT = (($FPTree.Attributes | ? {$_.TypeName.Name -eq 'Parameter'}).NamedArguments | ? {$_.ArgumentName -eq 'ParameterSetName'} | ?{$_.Argument.Value -eq $PSN}).Parent}}
        'Type'             {$FPTree.Attributes  | ? {($_| GM | ? Membertype -eq 'Property').count -eq 3}}
        'DefaultVal'       {$SubT = $FPTree.DefaultValue}       
        }
    return $SubT
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Nice-Up{
    [Alias('NiceUp')]
    Param(
        [Parameter(Mandatory=$true,Position=0,ValuefromPipeline=$true)][String[]]$String
        )
    Begin{$Result = @()}
    Process{foreach($Str in $String){($Str.split('-')|%{($_[0] -as [String]).toupper()+$_.Substring(1)})-join'-'}}
    End{Return $Result}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Write-Block{
    [CmdletBinding(DefaultParameterSetName='NoString')]
    [Alias('wb')]
    Param(
        [Parameter(Mandatory=$true )][String]$Key,
        [Parameter(Mandatory=$False)][String]$Field,
        [Parameter(Mandatory=$False)][String]$Value,
        [Parameter(Mandatory=$False)][Switch]$Clip,
        [Parameter(Mandatory=$true,ParameterSetName='String',ValueFromPipeline=$true,Position=0)][String]$String
        )
    if($PSCmdlet.ParameterSetName -eq 'String'){
        $Block = [String]$String.trimend().TrimEnd(')]')
        if($field){$Block += ",$field="}
        if($Value){$Block += "$Value"}
        $Block = $Block -replace "\[$Key\(,","[$Key("
        }
    Else{
        $Block = "[$Key("
        if($field){$Block += "$field="}
        if($Value){$Block += "$Value"}
        }
    $block += ')]'
    #if clipboard
    if($Clip){$Block | Clip}
    Return $Block
    }

#endregion

#region ###################### CONTROLS

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function New-Script{
    [Alias('New','n')]
    Param()
    If($host.Name -eq 'Windows PowerShell ISE Host'){
        $Null=$psISE.CurrentPowerShellTab.Files.Add()
        $psISE.CurrentPowerShellTab.ConsolePane.Focus()
        }
    ElseIf($Host.Name -eq 'Visual Studio Code Host'){
        $WS = New-Object -ComObject WScript.Shell
        $WS.SendKeys('^`')
        $WS.SendKeys('^n')
        $WS.SendKeys('^`')
        $WS = $Null
        }
    Try{Parse-Code}Catch{Write-Warning "Empty Scriptpane..."}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
Function Set-Cursor{
    [CmdletBinding()]
    [Alias('Cursor')]
    Param(
        [Parameter(Mandatory=$false,Position=0,ValueFromPipeline=$true)][System.Management.Automation.Language.AST]$Tree=$Script:Monkey.AST,
        [Parameter(Mandatory=$true,ParameterSetName='Top')][Switch]$Top,
        [Parameter(Mandatory=$true,ParameterSetName='Bottom')][Switch]$Bottom
        )
    $T=$tree.Extent
    $LnT=$T.StartLineNumber
    $CnT=$t.StartColumnNumber
    $LnB=$t.EndLineNumber
    $CnB=$t.EndColumnNumber
    If($Host.Name -eq 'Windows PowerShell ISE Host'){
        $Editor = $psISE.CurrentFile.Editor
        try{$Editor.SetCaretPosition($LnB,$cnB)}Catch{}
        if($Top){try{$Editor.SetCaretPosition($LnT,$cnT)}Catch{Write-Warning 'Need to focus...'}}
        $psISE.CurrentPowerShellTab.ConsolePane.Focus()
        }
    ElseIf($Host.Name -eq 'Visual Studio Code Host'){
        Try{$Editor = $psEditor.GetEditorContext()}Catch{}
        Try{GoTo-Line $LnB}Catch{}
        if($Top){GoTo-Line $LnT}
        if($Bottom){try{$Editor.SetSelection($LnB,$cnB,$LnB,$CnB)}Catch{}}
        if($Top){try{$Editor.SetSelection($LnT,$cnT,$LnT,$cnT)}Catch{Write-Warning 'Need to focus...'}}
        }
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function GoTo-Line{ 
    [Alias('GoTo','Line','l')]
    Param(
        [Parameter(Mandatory=$true,Position=1)][int]$Line
        )
    if($Line -gt $Script:Monkey.AST.Extent.EndLineNumber){Write-Warning "Out Of Range";Break}
    if($Host.Name -eq 'Visual Studio Code Host'){
        $WS = New-Object -ComObject WScript.Shell
        $WS.SendKeys('^`')
        $WS.SendKeys("^g")
        foreach($Key in $Line.ToString().Split()){$Ws.SendKeys("$Key")}
        $WS.SendKeys("ENTER")
        $WS.SendKeys('^`')
        $WS = $null
        }
    if($Host.Name -eq 'Windows PowerShell ISE Host'){
        $psISE.CurrentFile.Editor.SetCaretPosition($psISE.CurrentFile.Editor.LineCount,1)
        $psISE.CurrentFile.Editor.SetCaretPosition($Line,1)
        $psISE.CurrentPowerShellTab.ConsolePane.Focus()
        }
    }
    
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function GoTo-Bottom{
    [Alias('b','Bottom')]
    Param()
    Cursor -Bottom
    }
    
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function GoTo-Top{
    [Alias('t','Top')]
    Param()
    Cursor -Top
    } 
    
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
Function Clear-Console{
    [Alias('c','cl')]
    Param()
    Clear
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Undo-Script{
    [Alias('Undo','z','u')]
    Param([ValidateRange(1,10)][Parameter()][int]$time=1)
    $WS = New-Object -ComObject WScript.Shell
    if($Host.Name -eq 'Windows PowerShell ISE Host'){$WS.SendKeys("^i")}
    if($Host.Name -eq 'Visual Studio Code Host'){$WS.SendKeys('^`')}
    0..$time | %{$WS.SendKeys("^z")}
    if($Host.Name -eq 'Windows PowerShell ISE Host'){$Ws.SendKeys("^d")}
    if($Host.Name -eq 'Visual Studio Code Host'){$WS.SendKeys('^`')}
    $WS = $null 
    Parse-code
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Redo-Script{
    [Alias('Redo','zz')]
    Param([ValidateRange(1,10)][Parameter()][int]$time=1)
    $WS = New-Object -ComObject WScript.Shell
    if($Host.Name -eq 'Windows PowerShell ISE Host'){$WS.SendKeys("^i")}
    if($Host.Name -eq 'Visual Studio Code Host'){$WS.SendKeys('^`')}
    0..$time | %{$WS.SendKeys("^y")}
    if($Host.Name -eq 'Windows PowerShell ISE Host'){$Ws.SendKeys("^d")}
    if($Host.Name -eq 'Visual Studio Code Host'){$WS.SendKeys('^`')}
    $WS = $null 
    Parse-code
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Run-Script{
    [Alias('Run','r')]
    Param()
    $WS = New-Object -ComObject WScript.Shell
    $WS.SendKeys("{F5}")
    $WS = $null
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Load-Script{
    [Alias('Load','x')]
    Param()
    Run-Script
    Clear
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function Save-Script{
    [Alias('Save','s')]
    Param()
    $WS = New-Object -ComObject WScript.Shell
    if($Host.Name -eq 'Visual Studio Code Host'){$WS.SendKeys('^`')}
    $WS.SendKeys("^s")
    if($Host.Name -eq 'Visual Studio Code Host'){$WS.SendKeys('^`')}
    if($Host.Name -eq 'Windows PowerShell ISE Host'){$Ws.SendKeys("^d")}
    $WS = $null 
    } 

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
Function View-Syntax{
    [CmdletBinding()]
    [Alias('Syntax','vs','v')]
    Param()
    DynamicParam{
        # Validation values
        $Vset = @('*')
        $VSet += $Script:Monkey.FunctList

        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $False
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)

        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)

        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Function', [String[]], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Function', $DynParam)
        
        ## Return Dictionary
        return $Dictionary    
        }
    Begin{
        $Result=@()
        if($DynParam.IsSet){$dyn =$DynParam.Value}
        else{$Dyn = $Script:Monkey.FocusFunction}
        If($DynParam.Value -eq '*'){$Dyn = Focus-Function}
        }
    Process{
        Foreach($DynP in $Dyn){
            $result += (Get-Help $dynP).Syntax
            }
        }
    End{Return $result}
    }

<#
.Synopsis
   View Help
.DESCRIPTION
   Get Help for specified script function
.EXAMPLE
   Example of how to use this cmdlet
#>
Function View-Help{
    [CmdletBinding(DefaultParameterSetname='Short')]
    [Alias('vh')]
    Param(
        [Parameter(Mandatory=$false,ParametersetName='Short')][Switch]$Short,
        [Parameter(Mandatory=$true,ParametersetName='Full')][Switch]$Full,
        [Parameter(Mandatory=$true,ParametersetName='Description')][Switch]$Description,
        [Parameter(Mandatory=$true,ParametersetName='Parameter')][Switch]$Parameter,
        [Parameter(Mandatory=$true,ParametersetName='Examples')][Switch]$Examples,
        [Parameter(Mandatory=$true,ParametersetName='Detailed')][Switch]$Detailed,
        [Parameter(Mandatory=$true,ParametersetName='Online')][Switch]$Online,
        [Parameter(Mandatory=$true,ParametersetName='ShowWindow')][Switch]$ShowWindow,
        [Parameter(Mandatory=$true,ParametersetName='Synopsis')][Switch]$Synopsis,
        [Parameter(Mandatory=$true,ParametersetName='Syntax')][Switch]$Syntax,
        [Parameter(Mandatory=$true,ParametersetName='Details')][Switch]$Details,
        [Parameter(Mandatory=$true,ParametersetName='Alias')][Switch]$Alias,
        [Parameter(Mandatory=$true,ParametersetName='Memo')][Switch]$Memo
        )
    DynamicParam{
        # Validation values
        $VSet = $Script:Monkey.FunctList

        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $False
        $Attrib.Position = 0
        $Attrib.ValueFromPipeline = $true
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)

        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)

        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Function', [String[]], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Function', $DynParam)
        
        ## Return Dictionary
        return $Dictionary    
        }
    Begin{
        if(!$DynParam.IsSet){$DynParam.Value=$Script:Monkey.FocusFunction}
        # Prep empty res
        $result = @()
        }
    Process{
        foreach($Fn in $DynParam.Value){
            Switch($PSCmdlet.ParameterSetName){
                'Short'       {Get-Help $Fn}
                'Full'        {Get-Help $Fn -full}
                'Description'{(Get-Help $Fn).description}
                'Parameter'   {Get-Help $Fn -Parameter}
                'Examples'    {Get-Help $Fn -Examples}
                'Detailed'    {Get-Help $Fn -Detailed}
                'Online'      {Get-Help $Fn -Online}
                'ShowWindow'  {Get-Help $Fn -ShowWindow}
                'Synopsis'   {(Get-Help $Fn).Synopsis}
                'Syntax'     {(Get-Help $Fn).Syntax}
                'Details'    {(Get-Help $Fn).Details}
                'Alias'      {(Get-Alias -Definition $Fn)}
                'Memo'{
                    $Prm = @((Get-Tree -Type ParameterAst -Parent (Get-FunctionTree -Name $Fn)).Name.VariablePath.UserPath)
                    $Result += New-Object PSCustomObject -Property @{
                        'Function' = $Fn
                        'Alias'    = @($(Gal -Definition $Fn -ErrorAct SilentlyContinue))
                        'Synopsis' = (Get-Help $Fn -ea sil).Synopsis
                        'Parameter'= $Prm
                        }
                    }
                }
            }
        }
    End{if($Result){Return $Result | Select Function,Synopsis,Alias,Parameter}}
    }  

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
 function View-Memo{
    [CmdletBinding()]
    [Alias('Memo','vm','m')]
    Param()
    DynamicParam{
       # Validation values
        $VSet = $Script:Monkey.FunctList
        $VSet += '*'
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $False
        $Attrib.Position = 0
        $Attrib.ValueFromPipeline = $true
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)

        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)

        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Function', [String[]], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Function', $DynParam)
        
        ## Return Dictionary
        return $Dictionary   
    }
    Begin{
        $result = @()
        if(!$DynParam.IsSet){$DynParam.Value=$Script:Monkey.FocusFunction}
        if($dynParam.Value -eq '*'){$dynParam.Value = $Script:Monkey.FunctList}
        }
    Process{
        foreach($Obj in $DynParam.Value){
            $result += $Obj | View-Help -Memo
            }
        }
    End{Return $Result}
    }

<#
.Synopsis
   View Keyboard Shortcuts
.DESCRIPTION
   List all Keyboard Shortcut commands
   for Scripting Kung-Fu Pandas.
   Powerful stuff. Use with caution.
.EXAMPLE
   k
   List all Keyboard Shortcut commands
#>
Function View-Keyboard{
    [Alias('Key','k')]
    Param()
    # Make It So
    $List = New-object PSCustomObject -Property @{
        p   ='Parse-Code'
        f   ='Get-Focus'
        ff  ='Focus-Function'
        fp  ='Focus-Param'
        n   ='New-Script'
        nf  ='New-Function'
        sf  ='Set-Function'
        np  ='New-Param'
        spm ='Set-Param'
        spv ='Set-ParamValidation'
        a   ='Set-Attribute'
        v   ='View-Syntax'
        h   ='View-Help'
        m   ='View-Memo'
        k   ='View-Keyboard'
        l   ='GoTo-Line'
        b   ='GoTo-Bottom'
        t   ='GoTo-Top'
        c   ='Clear-Console'
        z   ='Undo-Script'
        zz  ='Redo-Script'
        r   ='Run-Script'
        x   ='Load-Script'
        s   ='Save-Script'
        }
    $Result = @()
    foreach($obj in $List|GM|? Membertype -eq NoteProperty){
        $result += New-Object PSCustomObject -Property @{Key=$obj.Name;Function=$List.($Obj.Name)}
        }
    $Result | Sort -Property Function
    }

#endregion

#region ###################### MAKEITSO

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Focus-Function{
    [CmdletBinding()]
    [Alias('Function','ff')]
    Param()
    DynamicParam{
        # Prep VSet
        $VSet = $Script:Monkey.FunctList
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $false
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # if functions exist
        if($Script:Monkey.FunctList -ne $Null){
            # Create Validate Set Obj & add to collection     
            $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
            $Collection.Add($ValidateSet)
            }
        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [String], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Name', $DynParam)
        ## Return Dictionary
        return $Dictionary        
        }
    Begin{}
    Process{
        if(!$DynParam.IsSet){Return $Script:Monkey.FunctList}
        # If existing function
        If($Script:Monkey.FunctList -ne $Null){
            # Set focusFunction
            $Script:Monkey.FocusFunction = $DynParam.Value
            # Reset Focus Param
            $Script:Monkey.FocusParam = $Null
            # Set Param List
            $Script:Monkey.ParamList = Try{@((Get-Tree -Type ParameterAst -Parent (Get-FunctionTree $Script:Monkey.FocusFunction)).name.VariablePath.UserPath)}Catch{}
            # Set cursor Top
            Get-FunctionTree $Script:Monkey.FocusFunction | Set-Cursor -Bottom
            Get-FunctionTree $Script:Monkey.FocusFunction | Set-Cursor -Top
            }
        # If no existing function
        Else{
            # Create function
            Write-Warning "Function Not Found"
            }
        }
    End{}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Focus-Param{
    [CmdletBinding()]
    [Alias('Param','fp')]
    Param()
    DynamicParam{
        # Prep VSet
        $VSet = $Script:Monkey.ParamList
        If($VSet -eq $Null){$VSet= @('NoParams')}
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $false
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
    
        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)
        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [String], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Name', $DynParam)
        ## Return Dictionary
        return $Dictionary  
        }
    Begin{}
    Process{
        if(!$DynParam.ISset){Return $Script:Monkey.ParamList}
        if($VSet -match 'NoParam'){Write-Warning "$VSet";Break}
        # If existing Param
        If($Script:Monkey.ParamList -ne $Null){
            # Set focusFunction
            $Script:Monkey.FocusParam = $DynParam.Value
            # Set Attrib List
            $Script:Monkey.AttribList = Try{(Get-Tree -Type AttributeAst -Parent (Get-Tree -type ParameterAst -Parent (Get-FunctionTree $Script:Monkey.FocusFunction)|? {$_.Name.VariablePath.UserPath -eq $Script:Monkey.FocusParam}))}Catch{Write-Warning 'No AttribList...'}
            # Select Text
            Get-ParamTree $Script:Monkey.FocusParam | Select-Tree
            }
        # If no existing Param
        Else{
            # Create function
            Write-Warning "Param Not Found"
            }
        }
    End{}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Get-Focus{
    [CmdletBinding()]
    [Alias('Focus','f')]
    Param()
    DynamicParam{
        $VSet = @('\')
        $VSet += $Script:Monkey.FunctList
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $False
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # if functions exist

        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)

        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Function', [String], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Function', $DynParam)
        ## Return Dictionary
        return $Dictionary        
        }
    Begin{Parse-Code}
    Process{
        if($DynParam.Value -eq '\'){Focus-Function $Script:Monkey.FocusFunction}
        if($DynParam.IsSet -AND $DynParam.Value -ne '\'){Focus-Function -Name $DynParam.Value}
        $Focus = New-Object PSCustomObject -Property @{
            Function = $Script:Monkey.FocusFunction
            Param    = $Script:Monkey.FocusParam
            }
        }
    End{if(-Not $DynParam.IsSet){Return $Focus}}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function New-Function{
    [Alias('FunctionNew','nf','fn','Draft')]
    Param(
        [Parameter()][String[]]$Name='Do-Stuff',
        [Parameter()][String]$Alias,
        [Parameter()][String]$Synopsis='Short-Description',
        [Parameter()][String[]]$Param,
        [ValidateSet('Min','Max','Dyn')]
        [Parameter()][String]$Template='Max',
        [Parameter()][Switch]$NewFile
        )
    Begin{
        # NiceUp
        if($Name){$Name = $Name | NiceUp}
        if($Alias){$Alias = $Alias | NiceUp}
        if($Param){$Param = $Param | NiceUp}
        # Prep Stuffs
        if($Alias){$Alias = "'$Alias'"}
        $ParamBlock =@()
        foreach($P in $Param){
            $ParamBlock += @("`t`t# Add Param Description`r`n`t`t[Parameter()]`$$P,`r`n")
            }
        # Remove last coma
        If($ParamBlock.count -gt 0){
            $ParamBlock[$ParamBlock.count-1]=$ParamBlock[$ParamBlock.count-1].TrimEnd().TrimEnd(',')
            $ParamBlock = "`r`n$ParamBlock`r`n`t`t"
            }
        # if New tab
        if($NewFile){$New = New-Script;ParseCode}
        # Go to bottom of page
        Set-cursor -bottom
        }
    Process{
        if($PSCmdlet.MyInvocation.InvocationName -match "^Draft$"){new-function -Template Min -NewFile;Break}
        # for each function to create
        Foreach($N in $Name){
            # Poplulate TextBlocks
            ## Mini
            if($Template -eq 'Min'){
                $txt=@("
######################################### $N

<#
.Synopsis
   $Synopsis
.DESCRIPTION
   Long Description
.EXAMPLE
   $N
   Example Description
#>
Function $N{
    [Alias($Alias)]
    Param($ParamBlock)
    ## Make It So
    Return `$Object
    }
#end
")
                }
            ## Maxi
            if($Template -eq 'Max'){               
                $txt=@("
######################################### $N

<#
.Synopsis
   $Synopsis
.DESCRIPTION
   Long Description
.EXAMPLE
   $N
   Example Description
.EXAMPLE
   $N
   Example Description
.INPUTS
   Inputs
.OUTPUTS
   Outputs
.NOTES
   Notes
.FUNCTIONALITY
   Functionality
.LINK
   https://github.com/SadProcessor
#>
Function $N{
    [CmdletBinding()]
    [Alias($Alias)]
    Param($ParamBlock)
    ## Make It So
    Begin{}
    Process{}
    End{Return `$Object}
    }
#end
")
                }
            ## Dynamic
            if($Template -eq 'Dyn'){   
                $txt=@("
######################################### $N

<#
.Synopsis
   $Synopsis
.DESCRIPTION
   Long Description
.PARAMETER
   Document Dynnamic Param
.EXAMPLE
   $N
   Example Description
.EXAMPLE
   $N
   Example Description
.INPUTS
   Inputs
.OUTPUTS
   Outputs
.NOTES
   Notes
.FUNCTIONALITY
   Functionality
.LINK
   https://github.com/SadProcessor
#>
Function $N{
    [CmdletBinding()]
    [Alias($Alias)]
    Param($ParamBlock)
    DynamicParam{
        # Validation values
        `$VSet = @('Insert','Values')

        ## Prep Dictionnary
        `$Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        
        ## Prep Dynamic Param
        # Create First Attribute Obj
        `$Attrib = New-Object System.Management.Automation.ParameterAttribute
        `$Attrib.Mandatory = `$False
        `$Attrib.Position = 0
        # Create AttributeCollection obj
        `$Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        `$Collection.Add(`$Attrib)

        # Create Validate Set Obj & add to collection     
        `$ValidateSet=new-object System.Management.Automation.ValidateSetAttribute(`$VSet)
        `$Collection.Add(`$ValidateSet)

        # Create Runtine DynParam from Collection
        `$DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('ItemName', [String], `$Collection)
        # Add dynamic Param to Dictionary
        `$Dictionary.Add('ItemName', `$DynParam)
        
        ## Return Dictionary
        return `$Dictionary    
        }
    ## Make It So
    Begin{
        if(`$DynParam.IsSet){`$dyn =`$DynParam.Value}
        }
    Process{}
    End{Return `$Object}
    }
#end
")
                }
            # Go to bottom
            try{Set-Cursor -Bottom}Catch{}
            #Insert Snippet
            # ISE
            if($Host.Name -eq 'Windows PowerShell ISE Host'){
                $Editor = $psise.CurrentFile.Editor
                if($NewFile){$editor = $New.Editor}
                $Editor.InsertText($txt)
                }
            # VSCODE
            ElseIf($Host.Name -eq 'Visual Studio Code Host'){
                If($NewFile){
                    $Txt | Set-Clipboard
                    $WS = New-Object -ComObject WScript.Shell
                    $WS.SendKeys('^`')
                    $WS.SendKeys('^v')
                    $WS.SendKeys('^`')
                    Save-Script
                    $WS.SendKeys('^`')
                    $WS.SendKeys('^`')                   
                    }
                Else{
                    Try{$psEditor.GetEditorContext().CurrentFile.InsertText("$txt")}Catch{}
                    }
                }
            # Parse & GoTo Bottom
            Try{Parse-Code}Catch{}
            Try{Set-Cursor -Bottom}Catch{}
            }
        }
    End{try{Focus-Function $n}Catch{}}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Set-Function{
    [Cmdletbinding()]
    [Alias('FunctionSet','sf','fs')]
    Param(
        [Parameter()][Alias('DPSN')][String]$DefaultParameterSetname,
        [ValidateSet('True','False')]
        [Parameter()][Alias('ShouldProcess')][String]$SupportsShouldProcess,
        [ValidateSet('True','False')]
        [Parameter()][Alias('PosBinding')][String]$PositionalBinding,
        [Parameter()][Alias('Uri')][String]$HelpUri,
        [ValidateSet('Low','Medium','High')]
        [Parameter()][Alias('Impact')][String]$ConfirmImpact,
        [Parameter()][String]$Alias,
        [Parameter()][Type]$OutputType,
        [Parameter()][String]$NewName
        )
    DynamicParam{
        $VSet = @('NoFunction')
        if($Script:Monkey.FunctList -ne $Null){$VSet = $Script:Monkey.FunctList}
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $False
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # if functions exist

        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)

        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [String], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Name', $DynParam)
        ## Return Dictionary
        return $Dictionary 
        }
    Begin{
        # NiceUp
        if($NewName){$NewName = $NewName | NiceUp}
        if($Alias){$Alias = $Alias | NiceUp}
        # If function other than current focus function > Focus
        If($DynParam.IsSet -AND $DynParam.Value -ne $Script:Monkey.FocusFunction){Focus-Function $DynParam.Value}
        }
    Process{
        # Break if no function
        if($Script:Monkey.FunctList -eq $Null){Write-Warning "No function. Parse/Focus...";Break}
        if($Script:Monkey.FocusFunction -eq $Null){Write-Warning "No Focus Function. Focus...";Break}
        
        # DefaultParameterSetname
        if($DefaultParameterSetname){
            # Find Sub
            $Sub = Get-SubTree DefaultPSN
            # If exist > overwite
            If($Sub){
                # Prep/Select/Insert
                $Sub | Select-tree
                $New = "DefaultParameterSetname='$DefaultParameterSetname'"
                Set-Selected $New
                }
            # Else, if not exist
            Else{
                # Search binding Block
                $Blk = Get-Subtree Binding 
                # If exists
                if($Blk){
                    # Prep/Select/Insert
                    $Blk | Select-tree
                    $Old = Get-Selected
                    $New = $Old | Write-Block -Key CmdletBinding -Field 'DefaultParameterSetname' -Value "'$DefaultParameterSetname'"
                    Set-Selected $New
                    }
                Else{
                    # Select Alias Block
                    $Sub = Get-SubTree AliasF
                    If($Sub){
                        # Select
                        $Sub | Select-Tree
                        $Old = Get-Selected
                        # Prep New
                        $Blk = Write-Block -Key CmdletBinding -Field 'DefaultParameterSetname' -Value "'$DefaultParameterSetname'"
                        # Insert
                        $New = "$Blk`r`n`t$Old"
                        Set-Selected $New
                        } 
                    }
                }
            Parse-Code
            }
        # SupportsShouldProcess
        if($SupportsShouldProcess){
            # Find Sub
            $Sub = Get-SubTree ShouldProcess
            # If exist > overwite
            If($Sub){
                # Prep/Select/Insert
                $Sub | Select-tree
                $New = "SupportsShouldProcess=`$$SupportsShouldProcess"
                Set-Selected $New
                }
            # Else, if not exist
            Else{
                # Search binding Block
                $Blk = Get-Subtree Binding 
                # If exists
                if($Blk){
                    # Prep/Select/Insert
                    $Blk | Select-tree
                    $Old = Get-Selected
                    $New = $Old | Write-Block -Key CmdletBinding -Field 'SupportsShouldProcess' -Value "`$$SupportsShouldProcess"
                    Set-Selected $New
                    }
                Else{
                    # Select Alias Block
                    $Sub = Get-SubTree AliasF
                    If($Sub){
                        # Select
                        $Sub | Select-Tree
                        $Old = Get-Selected
                        # Prep New
                        $Blk = Write-Block -Key CmdletBinding -Field 'SupportsShouldProcess' -Value "`$$SupportsShouldProcess"
                        # Insert
                        $New = "$Blk`r`n`t$Old"
                        Set-Selected $New
                        } 
                    }
                }
            Parse-Code
            }
        # PositionalBinding
        if($PositionalBinding){
            # Find Sub
            $Sub = Get-SubTree PosBinding
            # If exist > overwite
            If($Sub){
                # Prep/Select/Insert
                $Sub | Select-tree
                $New = "PositionalBinding=`$$PositionalBinding"
                Set-Selected $New
                }
            # Else, if not exist
            Else{
                # Search binding Block
                $Blk = Get-Subtree Binding 
                # If exists
                if($Blk){
                    # Prep/Select/Insert
                    $Blk | Select-tree
                    $Old = Get-Selected
                    $New = $Old | Write-Block -Key CmdletBinding -Field 'PositionalBinding' -Value "`$$PositionalBinding"
                    Set-Selected $New
                    }
                Else{
                    # Select Alias Block
                    $Sub = Get-SubTree AliasF
                    If($Sub){
                        # Select
                        $Sub | Select-Tree
                        $Old = Get-Selected
                        # Prep New
                        $Blk = Write-Block -Key CmdletBinding -Field 'PositionalBinding' -Value "`$$PositionalBinding"
                        # Insert
                        $New = "$Blk`r`n`t$Old"
                        Set-Selected $New
                        } 
                    }
                }
            Parse-Code
            }
        # HelpUri
        if($HelpUri){
            # Find Sub
            $Sub = Get-SubTree HelpUri
            # If exist > overwite
            If($Sub){
                # Prep/Select/Insert
                $Sub | Select-tree
                $New = "HelpUri='$HelpUri'"
                Set-Selected $New
                }
            # Else, if not exist
            Else{
                # Search binding Block
                $Blk = Get-Subtree Binding 
                # If exists
                if($Blk){
                    # Prep/Select/Insert
                    $Blk | Select-tree
                    $Old = Get-Selected
                    $New = $Old | Write-Block -Key CmdletBinding -Field 'HelpUri' -Value "'$HelpUri'"
                    Set-Selected $New
                    }
                Else{
                    # Select Alias Block
                    $Sub = Get-SubTree AliasF
                    If($Sub){
                        # Select
                        $Sub | Select-Tree
                        $Old = Get-Selected
                        # Prep New
                        $Blk = Write-Block -Key CmdletBinding -Field 'HelpUri' -Value "'$HelpUri'"
                        # Insert
                        $New = "$Blk`r`n`t$Old"
                        Set-Selected $New
                        } 
                    }
                }
            Parse-Code
            }
        # ConfirmImpact
        if($ConfirmImpact){
            # Find Sub
            $Sub = Get-SubTree ConfImpact
            # If exist > overwite
            If($Sub){
                # Prep/Select/Insert
                $Sub | Select-tree
                $New = "ConfirmImpact='$ConfirmImpact'"
                Set-Selected $New
                }
            # Else, if not exist
            Else{
                # Search binding Block
                $Blk = Get-Subtree Binding 
                # If exists
                if($Blk){
                    # Prep/Select/Insert
                    $Blk | Select-tree
                    $Old = Get-Selected
                    $New = $Old | Write-Block -Key CmdletBinding -Field 'ConfirmImpact' -Value "'$ConfirmImpact'"
                    Set-Selected $New
                    }
                Else{
                    # Select Alias Block
                    $Sub = Get-SubTree AliasF
                    If($Sub){
                        # Select
                        $Sub | Select-Tree
                        $Old = Get-Selected
                        # Prep New
                        $Blk = Write-Block -Key CmdletBinding -Field 'ConfirmImpact' -Value "'$ConfirmImpact'"
                        # Insert
                        $New = "$Blk`r`n`t$Old"
                        Set-Selected $New
                        } 
                    }
                }
            Parse-Code
            }
        # Alias
        if($Alias){
            # Find Sub
            $Sub = Get-SubTree AliasF
            # If exist > overwite
            If($Sub){
                # Prep/Select/Insert
                $Sub | Select-tree
                $New = Write-Block -Key Alias -Value "'$Alias'"
                Set-Selected $New
                }
            # Else, if not exist
            Else{
                # Search Param Block
                $Blk = Get-tree -Type ParamBlockAst -Parent (Get-functionTree $Script:Monkey.FocusFunction) 
                # If exists
                if($Blk){
                    # Select Block
                    $Blk | Select-Tree
                    $Old = Get-Selected
                    # Prep New
                    $New = Write-Block -Key Alias -Value "'$Alias'"
                    # Insert
                    $Str = "$New`r`n`t$Old"
                    Set-Selected $Str
                    }
                Else{Write-Warning "Need Param Block...";Break}
                }
            Parse-Code
            }
        # OutputType
        if($OutputType){
            # Find Sub
            $Sub = Get-SubTree Output
            # If exist > overwite
            If($Sub){
                # Prep/Select/Insert
                $Sub | Select-tree
                $New = Write-Block -Key OutputType -Value "[$OutputType]"
                Set-Selected $New
                }
            # Else, if not exist
            Else{
                # Search Param Block
                $Blk = Get-SubTree AliasF
                # If exists
                if($Blk){
                    # Select Block
                    $Blk | Select-Tree
                    $Old = Get-Selected
                    # Prep New
                    $New = Write-Block -Key OutputType -Value "[$OutputType]"
                    # Insert
                    $Str = "$Old`r`n`t$New"
                    Set-Selected $Str
                    }
                Else{Write-Warning "Need Alias Block...";Break}
                }
            Parse-Code
            }
        # NewName
        if($NewName){
            $FTree = Get-functionTree $Script:Monkey.FocusFunction
            $FTree | Select-tree
            $Old   = Get-Selected
            $New   = $Old -replace "^function.+(\r\n)*{","function $NewName{"
            Set-Selected $New
            Parse-code
            Focus-Function $NewName
            }
        }
    End{}
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function New-Param{
    [Alias('ParamNew','np','pn')]
    Param(
        # names of Parameters to create
        [Parameter(Mandatory=$true,Position=0)][String[]]$Name,
        # Parameter Alias
        [Parameter()][String]$Alias,
        # Parameter Type
        [Parameter()][Type]$Type,
        # Parameter Validation
        [ValidateSet('Set','Range','Pattern','Length','Count','Script','NotNull','NotNullOrEmpty','Null','EmptyString','EmptyCollection')]
        [Parameter()][String[]]$Validate,
        # Attrib Mandatory
        [ValidateSet('True','False')]
        [Parameter()][String]$Mandatory,
        # Attrib Position
        [Parameter()][Int]$Position,
        # Atrrib Value from Pipeline
        [ValidateSet('True','False')]
        [Parameter()][Alias('Pipeline')][String]$ValueFromPipeline,
        # Attrib ParameterSetname
        [Parameter()][Alias('PSN')][String[]]$ParameterSetName,
        # Param Description
        [Parameter()][String]$Description='Param Description'
        )
    Begin{
        # Niceup
        $Name = $Name | NiceUp
        if($Alias){$Alias = $Alias | NiceUp}
        if($ParameterSetName){$ParameterSetName = $ParameterSetName | NiceUp}
        # Prep empty String
        $ParamString = ''
        If($ParameterSetName){
            Foreach($PSN in $ParameterSetName){
                $ParamString += "`r`n`t`t[Parameter("
                if($Mandatory){$paramString += "Mandatory=`$$Mandatory,"}
                if($Position){$paramString += "Position=$Position,"}
                if($ValueFromPipeline){$paramString += "ValueFromPipeline=`$$ValueFromPipeline,"}
                if($ParameterSetName){$paramString += "ParameterSetName='$PSN',"}
                $ParamString = ($ParamString + ')]').replace(',)]',')]')
                }
            }
        Else{
            $ParamString += "`r`n`t`t[Parameter("
            if($Mandatory){$paramString += "Mandatory=`$$Mandatory,"}
            if($Position){$paramString += "Position=$Position,"}
            if($ValueFromPipeline){$paramString += "ValueFromPipeline=`$$ValueFromPipeline,"}
            $ParamString = ($ParamString + ')]').replace(',)]',')]')
            }
        #$paramString += "`r`n`t`t"
        if($Alias){$paramString += "[Alias('$Alias')]"}
        if($Type){$paramString += "[$Type]"}
        if($Validate){
            $ValString = ''
            Foreach($V in $Validate){
                Switch($V){
                    'Set'{$val+="[Validate$V('One','Two')]"}
                    'Range'{$val+="[Validate$V(1,7)]"}
                    'Pattern'{$val+="[Validate$V(`".?`")]"}
                    'Length'{$val+="[Validate$V(0,7)]"}
                    'Count'{$val+="[Validate$V(1,2)]"}
                    'Script'{$val+="[Validate$V({`$_ -eq `$True})]"}
                    'NotNull'{$val+="[Validate$V()]"}
                    'NotNullOrEmpty'{$val+="[Validate$V()]"}
                    'Null'{$Val+="[Allow$V()]"}
                    'EmptyString'{$Val+="[Allow$V()]"}
                    'EmptyCollection'{$Val+="[Allow$V()]"}
                    }
                $ValString += "`r`n`t`t$Val"
                }
            $ParamString = $ValString+$ParamString
            }
        # Add Description
        $ParamString = "`r`n`t`t# $Description" + $ParamString
        }
    Process{
        foreach($N in $Name){
            $String = $paramString + "`$$N"
            # Select Param Block
            $Block = Try{Get-Tree -Type ParamBlockAst -Parent (Get-FunctionTree -Name $Script:Monkey.FocusFunction)}Catch{Write-Warning "Not focused...";Break}
            # Select block
            $Block | Select-Tree
            # Get Selected Text
            $OldText = $Block | Get-Text
            # trim to Append
            $NewText = $Oldtext.TrimEnd().TrimEnd(')').TrimEnd()
            # Add coma if needed
            if($OldText.replace("\s",'') -ne 'Param()'){$NewText += ','}
            # Append
            $NewText  = $NewText + $String + "`r`n`t`t)"
            # Insert
            Set-Selected $newText
            Parse-Code
            Try{Focus-Param $N}Catch{Get-Focus \}
            }
        }
    End{
        # Set Param List
        $Script:Monkey.ParamList = ((Get-Tree -Type ParameterAst -Parent (Get-FunctionTree $Script:Monkey.FocusFunction)).name.VariablePath.UserPath)
        }  
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Set-Param{
    [CmdletBinding()]
    [Alias('ParamSet','spm','ps')]
    Param(
        # Parameter Alias
        [Parameter()][String]$Alias,
        # Parameter Type
        [Parameter()][Type]$Type,
        # Parameter Validation
        [ValidateSet('ValidateSet','ValidateRange','ValidatePattern','ValidateLength','ValidateCount','ValidateScript','ValidateNotNull','ValidateNotNullOrEmpty','AllowNull','AllowEmptyString','AllowEmptyCollection')]
        [Parameter()][String[]]$Validate,
        # Def Value
        [Parameter()][Alias('Value')]$DefaultValue,
        # New Name
        [Parameter()][String]$NewName
        )
    DynamicParam{
        $VSet = 'NoFocusParam'
        if($Script:Monkey.ParamList -ne ''){$VSet = $Script:Monkey.ParamList}
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $False
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # Create Validate Set Obj & add to collection     
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidateSet)
        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [String[]], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('Name', $DynParam)
        ## Return Dictionary
        return $Dictionary 
        }
    Begin{
        # Focus & NiceUp Param
        If($DynParam.IsSet -AND $DynParam.Value -ne $Script:Monkey.FocusParam){
            $Param = $DynParam.Value | NiceUp
            Focus-Param $Param
            }
        Else{$Param = $Script:Monkey.FocusParam}
        # NiceUp DefaultValue
        If($Alias){$Alias = $Alias | NiceUp}
        }
    Process{
        $Main = Get-ParamTree -Name $Param
        # Alias
        If($Alias){
            # Prep new
            $New = Write-block -Key Alias -Value "'$Alias'"
            # Search for Sub
            $Sub = Get-Subtree -Type AliasP
            # If exists > overwite
            if($Sub){
                # Select
                $Sub | Select-tree
                Set-Selected $New
                }
            # Else
            Else{
                # Select Param Var
                (Get-Subtree -Type Attrib)[(Get-Subtree -Type Attrib).count-1] | Select-tree
                $old = Get-Selected
                Set-Selected "$Old$New"
                }
            Parse-Code
            }
        # Type
        if($type){
            $type = $type.name | NiceUp
            # Prep new
            $New = "[$Type]"
            # Search for Sub
            $Sub = Get-Subtree -Type Type
            # If exists > overwite
            if($Sub){
                # Select
                $Pos = $Sub.Extent
                if($Host.Name -eq 'Windows PowerShell ISE Host'){
                    $psISE.CurrentFile.Editor.select($Pos.StartLineNumber,$Pos.StartColumnNumber,$Pos.EndLineNumber,$Pos.EndColumnNumber)
                    }
                if($Host.Name -eq 'Visual Studio Code Host'){}
                Set-Selected $New
                }
            # Else
            Else{
                # Select Param Var
                (Get-Subtree -Type NameP) | Select-tree
                $old = Get-Selected
                Set-Selected "$New$Old"
                }
            Parse-Code
            }
        # Validation
        if($Validate){
            # Prep Stuff
            Switch($Validate){
                'ValidateSet'           {$Key='ValSet'         ; $str="[$Validate('A','B','C')]"}
                'ValidateRange'         {$Key='ValRange'       ; $str="[$Validate(0,100)]"}
                'ValidatePattern'       {$Key='ValPattern'     ; $str="[$Validate(`".+`")]"}
                'ValidateLength'        {$Key='ValLength'      ; $str="[$Validate(0,100)]"}
                'ValidateCount'         {$Key='ValCount'       ; $str="[$Validate(0,100)]"}
                'ValidateScript'        {$Key='ValScript'      ; $str="[$Validate({`$true})]"}
                'ValidateNotNull'       {$Key='ValNotNull'     ; $str="[$Validate()]"}
                'ValidateNotNullOrEmpty'{$Key='ValNotNullEmpty'; $str="[$Validate()]"}
                'AllowNull'             {$Key='AllowNull'      ; $str="[$Validate()]"}
                'AllowEmptyString'      {$Key='AllowEString'   ; $str="[$Validate()]"}
                'AllowEmptyCollection'  {$Key='AllowECollect'  ; $str="[$Validate()]"}
                }
            # Search Validate
            $Sub = Get-SubTree -Type $Key
            # if exists
            if($Sub){
                # Select
                $Sub | Select-tree
                # insert String
                Set-selected $Str
                }
            Else{
                # look for Parameter tree
                $blk = Get-ParamTree $Script:Monkey.focusParam
                # Select
                $blk | Select-tree
                $old = Get-Selected
                # Insert String
                Set-Selected "$Str`r`n`t`t$Old"
                }
            Parse-Code
            }
        # Default Value
        if($DefaultValue){
            # Prep
            if($DefaultValue.getType().Name -eq 'String'){$DefaultValue = "'$DefaultValue'"}
            if($DefaultValue -match ("^\'\$")){$DefaultValue = $DefaultValue.trim("'")}
            # Search if exist
            $Sub = Get-Subtree -Type DefaultVal
            # if exist
            if($Sub){
                # Select
                $Sub | Select-tree
                # Replace
                Set-Selected $DefaultValue
                }
            Else{
                # Get Block
                $Blk = Get-ParamTree $Script:Monkey.focusParam
                # Select
                $Blk | Select-Tree
                # Get Selected
                $Old = Get-Selected
                # Replace
                $New = "$Old=$DefaultValue"
                Set-Selected $New
                }
            parse-Code
            }
        # New Name
        if($NewName){
            # Get Sub
            $Sub = Get-SubTree -Type NameP
            $Sub | Select-Tree
            # Set new
            $NewName = $NewName | NiceUp
            Set-Selected "`$$NewName"
            # Parse
            Parse-Code
            # Set Param List
            $Script:Monkey.ParamList = Try{@((Get-Tree -Type ParameterAst -Parent (Get-FunctionTree $Script:Monkey.FocusFunction)).name.VariablePath.UserPath)}Catch{}
            # Focus
            focus-Param $NewName
            }
        }
    End{}  
    }

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Set-Attribute{
    [CmdletBinding(DefaultParameterSetname='SameBlock')]
    [Alias('Attribute','Attrb','sa','as','a')]
    Param(
        # Attrib Mandatory
        [ValidateSet('True','False')]
        [Parameter()][String]$Mandatory,
        # Attrib Position
        [Parameter()][Int]$Position,
        # Attrib ParameterSetName
        [Parameter()][Alias('ParamSetName')][String]$NewPSN,
        # Atrrib Value from Pipeline
        [ValidateSet('True','False')]
        [Parameter()][Alias('Pipeline')][String]$ValueFromPipeline,
        # Attrib Value by Prop Name
        [ValidateSet('True','False')]
        [Parameter()][Alias('PipelineByProp')][String]$ValueFromPipelineByPropertyName,
        # Attrib Value By Remaining Args
        [ValidateSet('True','False')]
        [Parameter()][Alias('RemainingArgs')][String]$ValueFromRemainingArguments,
        # Attrib Mandatory
        [Parameter()][String]$HelpMessage,
        # New Pram Attrib Block
        [Parameter(Mandatory=$true,ParameterSetName='NewBlock')][Switch]$NewBlock
        )
    DynamicParam{
        # List Param PSN
        [Array]$List = (Get-SubTree -Type ParamSetName).Argument.Value
        IF($List.count -ne 0){$List+='*'}
        Else{$List+='.'}
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $false
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # Create Validate Set Obj & add to collection    
        $ValidateSet=new-object System.Management.Automation.ValidateSetAttribute($List)
        $Collection.Add($ValidateSet)
        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('PSN', [String[]], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('PSN', $DynParam)
        
        ## Return Dictionary
        return $Dictionary 
        }
    Begin{
        # Pos to Str
        if($Position.count){$Posit = $Position -as [String]}
        # List ParameterSet Names
        $List = (Get-SubTree -Type ParamSetName).Argument.Value}
    Process{
        if($NewBlock){
            if(!$NewPSN){Write-Warning 'Please Specify New PSN...';Return}
            # Select Existing Param Attrb Block
            $Sub = Get-SubTree -Type Attrib
            $Sub
            $Sub | Select-tree
            $Old = Get-Selected

            # Create New
            if($Mandatory)                      {$New = $New | Write-Block -Key Parameter -Field Mandatory -Value "`$$Mandatory"}
            if($Posit)                          {$New = $New | Write-Block -Key Parameter -Field Position -Value "$Posit"}
            <# Always ------------------------#> $New = Write-Block -Key Parameter -Field ParameterSetName -Value "'$NewPSN'"
            if($ValueFromPipeline)              {$New = $New | Write-Block -Key Parameter -Field ValueFromPipeline -Value "`$$ValueFromPipeline"}
            if($ValueFromPipelineByPropertyName){$New = $New | Write-Block -Key Parameter -Field ValueFromPipelineByPropertyName -Value "`$$ValueFromPipelineByPropertyName"}
            if($ValueFromRemainingArguments)    {$New = $New | Write-Block -Key Parameter -Field ValueFromRemainingArguments -Value "`$$ValueFromRemainingArguments"}
            if($HelpMessage)                    {$New = $New | Write-Block -Key Parameter -Field HelpMessage -Value "'$HelpMessage'"}
            
            # Add to old
            Set-Selected "$New`r`n`t`t$Old"
            Parse-Code
            }
        Else{
            # If PSN needed and not specified > Break
            if($List.count -gt 1 -AND $DynParam.IsSet -eq $false){Write-Warning 'Please Specify PSN...';Break}
            # If PSN not needed
            if($DynParam.IsSet -eq $false){$Set = @('.')}
            # If PSN Specified
            else{$set = @($DynParam.Value)}
            # If * (All)
            if($Set -contains '*'){$Set = @($List)}
    
            # Foreach PSN/NoPSN
            foreach($Name in $Set){ 
                
                ## Helper SetSub
                function SetSub{
                    # If name is '.'
                    if($Name -eq '.'){
                        # Get Param Attrib Block
                        $Sub = Get-Subtree -Type Attrib
                        }
                    # Any other
                    Else{
                        # Select Specified ParamBlock
                        $Sub = Get-Subtree -Type Attrib -PSN $Name
                        }
                    # If no Sub Found > Break
                    if($Sub.Extent -eq $Null){Write-Warning "Selection Error...";Return}
                    $Sub | Select-Tree
                    }

                ## Mandatory
                if($Mandatory){
                    SetSub
                    # Search Mandatory Field
                    if($Name -eq '.'){$Sel = Get-SubTree -Type Mandatory}
                    Else{
                        $Sel = Get-Tree -type NamedAttributeArgumentAst -Parent $Sub | ? ArgumentName -eq Mandatory
                        $Sel = $Sel |? {$_.Parent.Extent.Text -match "ParameterSetName='$Name'"}
                        }
                    # Found > Change Value
                    if($Sel){
                        $Sel|Select-tree
                        Set-Selected "Mandatory=`$$Mandatory"
                        }
                    # Not Found > Create
                    Else{
                        # Get full Attrib Block
                        $Old = Get-Selected
                        $New = $Old | Write-Block -Key Parameter -Field Mandatory -Value "`$$Mandatory"
                        Set-Selected $New 
                        }
                    Parse-Code
                    }

                ## Position
                if($Posit){
                    SetSub
                    # Search Position Field
                    if($Name -eq '.'){$Sel = Get-SubTree -Type Position}
                    Else{$Sel = Get-Tree -type NamedAttributeArgumentAst -Parent $Sub | ? ArgumentName -eq Position}
                    # Found > Change Value
                    if($Sel){
                        $Sel|Select-tree
                        Set-Selected "Position=$Posit"
                        }
                    # Not Found > Create
                    Else{
                        # Get full Attrib Block
                        $Old = Get-Selected
                        $New = $Old | Write-Block -Key Parameter -Field Position -Value "$Posit"
                        Set-Selected $New 
                        }
                    Parse-Code
                    }
            
                ## ValueFromPipeline
                if($ValueFromPipeline){
                    SetSub
                    # Search ValueFromPipeline Field
                    if($Name -eq '.'){$Sel = Get-SubTree -Type Pipeline}
                    Else{$Sel = Get-Tree -type NamedAttributeArgumentAst -Parent $Sub | ? ArgumentName -eq ValueFromPipeline}
                    # Found > Change Value
                    if($Sel){
                        $Sel|Select-tree
                        Set-Selected "ValueFromPipeline=`$$ValueFromPipeline"
                        }
                    # Not Found > Create
                    Else{
                        # Get full Attrib Block
                        $Old = Get-Selected
                        $New = $Old | Write-Block -Key Parameter -Field ValueFromPipeline -Value "`$$ValueFromPipeline"
                        Set-Selected $New 
                        }
                    Parse-Code
                    }

                ## ValueFromPipelineByPropertyName
                if($ValueFromPipelineByPropertyName){
                    SetSub
                    # Search ValueFromPipelineByPropertyName Field
                    if($Name -eq '.'){$Sel = Get-SubTree -Type PipelineByProp}
                    Else{$Sel = Get-Tree -type NamedAttributeArgumentAst -Parent $Sub | ? ArgumentName -eq ValueFromPipelineByPropertyName}
                    # Found > Change Value
                    if($Sel){
                        $Sel|Select-tree
                        Set-Selected "ValueFromPipelineByPropertyName=`$$ValueFromPipelineByPropertyName"
                        }
                    # Not Found > Create
                    Else{
                        # Get full Attrib Block
                        $Old = Get-Selected
                        $New = $Old | Write-Block -Key Parameter -Field ValueFromPipelineByPropertyName -Value "`$$ValueFromPipelineByPropertyName"
                        Set-Selected $New 
                        }
                    Parse-Code
                    }
            
                ## ValueFromRemainingArguments
                if($ValueFromRemainingArguments){
                    SetSub
                    # Search ValueFromRemainingArguments Field
                    if($Name -eq '.'){$Sel = Get-SubTree -Type RemainingArgs}
                    Else{$Sel = Get-Tree -type NamedAttributeArgumentAst -Parent $Sub | ? ArgumentName -eq ValueFromRemainingArguments}
                    # Found > Change Value
                    if($Sel){
                        $Sel|Select-tree
                        Set-Selected "ValueFromRemainingArguments=`$$ValueFromRemainingArguments"
                        }
                    # Not Found > Create
                    Else{
                        # Get full Attrib Block
                        $Old = Get-Selected
                        $New = $Old | Write-Block -Key Parameter -Field ValueFromRemainingArguments -Value "`$$ValueFromRemainingArguments"
                        Set-Selected $New 
                        }
                    Parse-Code
                    }

                ## HelpMessage
                if($HelpMessage){
                    SetSub
                    # Search HelpMessage Field
                    if($Name -eq '.'){$Sel = Get-SubTree -Type HelpMess}
                    Else{$Sel = Get-Tree -type HelpMessage -Parent $Sub | ? ArgumentName -eq HelpMessage}
                    # Found > Change Value
                    if($Sel){
                        $Sel|Select-tree
                        Set-Selected "HelpMessage='$HelpMessage'"
                        }
                    # Not Found > Create
                    Else{
                        # Get full Attrib Block
                        $Old = Get-Selected
                        $New = $Old | Write-Block -Key Parameter -Field HelpMessage -Value "'$HelpMessage'"
                        Set-Selected $New 
                        }
                    Parse-Code
                    }
            
                ## New ParameterSetName
                if($NewPSN){
                    SetSub
                    
                    # Search ParameterSetName Field
                    $Sel = Get-SubTree -Type ParamSetName
                    if($Name){$Sel = Get-SubTree -Type ParamSetName | ? {$_.Argument.Value -eq $Name}}
                    if($Name -eq '.'){$Sel = Get-SubTree -Type ParamSetName}
                    #Else{$Sel = Get-Tree -type NamedAttributeArgumentAst -Parent $Sub | ? ArgumentName -eq ParameterSetName}
                    
                    # Found > Change Value
                    if($Sel){
                        $Sel|Select-tree
                        Set-Selected "ParameterSetName='$NewPSN'"
                        }
                    # Not Found > Create
                    Else{
                        # Get full Attrib Block
                        $Old = Get-Selected
                        $New = $Old | Write-Block -Key Parameter -Field ParameterSetName -Value "'$NewPSN'"
                        Set-Selected $New
                        }
                    Parse-Code
                    }
               
                }
            }         
        }
    End{}
    }

<#
.Synopsis
   Set Param Validation
.DESCRIPTION
   Set Param Validation
.EXAMPLE
   Set-ParamValidation -ValidateSet A,B,C
.EXAMPLE
   spv -ParamName ParamOne -ValidateSet A,B,C 
#>
Function Set-ParamValidation{
    [Alias('ParamValidation','spv','pv')]
    Param(
        # Target Folder. Defaults to PWD
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$True,ParameterSetName='ValidateSet')][String[]]$ValidateSet,
        [ValidateCount(1,2)]
        [Parameter(Mandatory=$True,ParameterSetName='ValidateCount')][int[]]$ValidateCount,
        [ValidateCount(2,2)]
        [Parameter(Mandatory=$True,ParameterSetName='ValidateRange')][int[]]$ValidateRange,
        [ValidateCount(1,2)]
        [Parameter(Mandatory=$True,ParameterSetName='ValidateLength')][int[]]$ValidateLength,
        [Parameter(Mandatory=$True,ParameterSetName='ValidatePattern')][Regex]$ValidatePattern,
        [Parameter(Mandatory=$True,ParameterSetName='ValidateScript')][ScriptBlock]$ValidateScript,
        [Parameter(Mandatory=$True,ParameterSetName='ValidateNotNull')][Switch]$ValidateNotNull,
        [Parameter(Mandatory=$True,ParameterSetName='ValidateNotNullOrEmpty')][Switch]$ValidateNotNullOrEmpty,
        [Parameter(Mandatory=$True,ParameterSetName='AllowNull')][Switch]$AllowNull,
        [Parameter(Mandatory=$True,ParameterSetName='AllowEmptyString')][Switch]$AllowEmptyString,
        [Parameter(Mandatory=$True,ParameterSetName='AllowEmptyCollection')][Switch]$AllowEmptyCollection
        )
    DynamicParam{
        $VSet = 'NoParam'
        if($Script:Monkey.ParamList -ne ''){$VSet = $Script:Monkey.ParamList}
        ## Prep Dictionnary
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ## Prep Dynamic Param
        # Create First Attribute Obj
        $Attrib = New-Object System.Management.Automation.ParameterAttribute
        $Attrib.Mandatory = $False
        $Attrib.Position = 0
        # Create AttributeCollection obj
        $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        # Add Attribute Obj to Attibute Collection Obj
        $Collection.Add($Attrib)
        # Create Validate Set Obj & add to collection     
        $ValidSet=new-object System.Management.Automation.ValidateSetAttribute($VSet)
        $Collection.Add($ValidSet)
        # Create Runtine DynParam from Collection
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter('ParamName', [String], $Collection)
        # Add dynamic Param to Dictionary
        $Dictionary.Add('ParamName', $DynParam)
        ## Return Dictionary
        return $Dictionary 
        }
    Begin{
        if(-Not$DynParam.IsSet){$DynParam.Value=$Script:Monkey.FocusParam}
        if($DynParam.Value -ne $Script:Monkey.FocusParam){Focus-Param $DynParam.Value}
        $PName = $DynParam.Value
        if($PName -ne $Script:Monkey.FocusParam){Focus-Param $PName}
        $Valid = $PSCmdlet.ParameterSetName
        $Value = GV -Name $PSCmdlet.ParameterSetName -ValueOnly
        }
    Process{
        # Generate String based on Validate type.
        Switch($Valid){
            'ValidateSet'           {$type = 'ValSet';$Value = "'$($Value -join `"','`")'"}
            'ValidateCount'         {$type = 'ValCount';if($Value.count -eq 1){$Value = $value + $value};$Value =  "$($Value -join ',')"}
            'ValidateRange'         {$type = 'ValRange';$Value =  "$($Value -join ',')"}
            'ValidateLength'        {$type = 'ValLength';if($Value.count -eq 1){$Value = $value + $value};$Value =  "$($Value -join ',')"}
            'ValidatePattern'       {$type = 'ValPattern';$Value =  "`"$Value`""}
            'ValidateScript'        {$type = 'ValScript';$Value =  "{$Value}"}
            'ValidateNotNull'       {$type = 'ValNotNull';$Value =  $Null}
            'ValidateNotNullOrEmpty'{$type = 'ValNotNullEmpty';$Value =  $Null}
            'AllowNull'             {$type = 'AllowNull';$Value =  $Null}
            'AllowEmptyString'      {$type = 'AllowEString';$Value =  $Null}
            'AllowEmptyCollection'  {$type = 'AllowECollect';$Value =  $Null}
            }
        $Str = "[$Valid($Value)]"
        # Check if Valid exist
        $Blk = Get-Subtree -Type $type 
        # If exit replace
        if($Blk){
            $Blk | Select-tree
            Set-selected $Str
            }
        # Else Insert
        Else{
            Get-Paramtree -Name $Pname | Select-tree
            $Old = Get-Selected
            Set-Selected "$Str`r`n`t`t$Old"
            }
        Parse-code
        }
    End{}
    }#>

#endregion

#region ###################### CSV

####################### FUNCTION: Invoke-CSVMonkey

<#
.Synopsis
   Generate Cmdlet from CSV Files
.DESCRIPTION
   Long Description
.EXAMPLE
   Invoke-CSVMonkey
   Example Description
#>
Function Invoke-CSVMonkey{
    [Alias('CSVMonkey')]
    Param(
		# Optional Path to Folder
        [ValidateScript({Test-Path $_})]
		[Parameter(Mandatory=$false,Position=0)][String]$TargetFolder=$pwd
		)
    Parse-Code
    # Require fresh scriptpane
    if($Script:Monkey.AST.Extent.Text.trim()){
        Write-Warning "Existing Data. Ninja Combo Required for Safety"
        Write-host "[n][enter][up][up][enter]" -ForegroundColor Green
        return
        }
    ## Check Function file
    $FunctionFile = Get-ChildItem $targetfolder | ? Name -match "^(.+)_F_CSV.csv$"
    # Stop if not found
    If($FunctionFile -eq $Null){Write-Warning "Function File Not Found. Exiting.";Return}
    # Import CSV / Stop if invalid Headers
    $FunctionCSV = Import-CSV $FunctionFile | ? FunctionName -ne ''
    # Headers
    $HeadList = 'FunctionName','Alias','Synopsis','Outputype','DefaultPSN','HelpURI'
    $Headers = ($FunctionCSV |GM|? Membertype -eq NoteProperty).name
    # Stop if mismatch
    If(Compare-Object -ref $HeadList -dif $Headers){Write-Warning 'Invalid Function CSV. Exiting';Return}

    ## FUNCTION ##
    # Get function list
    $FunctionList = $FunctionCSV.FunctionName
    # Foreach function
    foreach($F in $FunctionList){
        Write-Verbose "`r`n# FUNCTION $F"
        # Get Row
        $Row = $FunctionCSV |? FunctionName -eq $F
        # Prep CMD
        $CMD = "New-Function -Name $F"
        if($Row.Alias)     {$CMD += ' -Alias '      + $row.Alias}
        if($Row.Synopsis)  {$CMD += " -Synopsis '"  + $row.Synopsis +"'"}
        # Exec CMD
        Write-Verbose $CMD
        IEX $CMD
        # Extra
        if($Row.OutputType -OR $Row.DefaultPSN -OR $Row.HelpURI){
            # Prep CMD
            $CMD = "Set-Function -Name $F"
            if($Row.OutputType){$CMD += ' -OutputType '+$row.OutputType}
            if($Row.DefaultPSN){$CMD += ' -DefaultParameterSetname '+$row.DefaultPSN}
            if($Row.HelpURI)   {$CMD += ' -HelpURI '+$row.HelpURI}
            # Exec CMD
            Write-Verbose $CMD
            IEX $CMD
            }
        ## Check PSN file
        $ParamSetFile = Get-ChildItem $TargetFolder | ? Name -match "^(.+)_S_CSV.csv$"
        # Stop if not found
        If($ParamSetFile -eq $Null){Write-Warning "ParamSet File Not Found.";Return}        
        Else{
            # Import CSV / Stop if invalid Headers
            $ParamSetCSV = Import-CSV $ParamSetFile | ? FunctionName -eq $F 
            # Compare headers
            $HeadList = 'FunctionName','MandatoryParam','OptionalParam','ParameterSetName'
            $Headers = ($ParamSetCSV |GM|? Membertype -eq NoteProperty).name
            If(Compare-Object -ref $HeadList -dif $Headers){Write-Warning 'Invalid ParamSet CSV.';Return}        
            }
        ## Check Param file
        $ParamFile = Get-ChildItem $TargetFolder | ? Name -match "^(.+)_P_CSV.csv$"
        # Stop if not found
        If($ParamFile -eq $Null){Write-Warning "Param File Not Found. Exiting.";Return}        
        Else{
            # Import CSV / Stop if invalid Headers
            $ParamCSV = Import-CSV $ParamFile | ? FunctionName -eq $F 
            # Compare headers
            $HeadList = 'FunctionName','ParamName','Type','Defaultvalue','Description','ValidateSet','Validaterange','ValidateCount','ValidateLength','ValidatePattern','ValidateScript','ValidateNotNull','ValidayeNotNullOrEmpty','AllowNull','AllowEmptyString','AllowEmptyCollection'
            $Headers = ($ParamCSV |GM|? Membertype -eq NoteProperty).name
            If(Compare-Object -ref $HeadList -dif $Headers){Write-Warning 'Invalid Param CSV.';Return}        
            }
        # Foreach Param in CSV
        Foreach($ParamObj in $ParamCSV){
            ## Prep data
            $Pname = $ParamObj.ParamName
            # List mandatory PSNs for this param
            [Array]$ListPSN_M = ($ParamSetCSV | ?{[Array]$_.MandatoryParam.trim().Split(' ').trim() -contains $Pname}).ParameterSetName
            # list optional PSNs for this param
            [Array]$ListPSN_O = ($ParamSetCSV | ?{[Array]$_.OptionalParam.trim().Split(' ').trim() -contains $Pname}).ParameterSetName
            # Group data
            $ParamObj | Add-Member -MemberType NoteProperty -Name PSN_M -Value $ListPSN_M
            $ParamObj | Add-Member -MemberType NoteProperty -Name PSN_O -Value $ListPSN_O
            # make full list
            [Array]$FullList = $ListPSN_M + $ListPSN_O
            ## Prep command
            # full list to string
            $FLS = ($FullList -join "','").trim() -replace "','$",''
            # String command to Create All Param/PSN with Mandatory True
            $CMD = "New-Param -name $Pname -Mandatory True -ParameterSetname '$FLS'"
            # Append other if needed
            if($ParamObj.Type){$CMD += " -Type '"+$ParamObj.Type+"'"}
            if($ParamObj.Alias){$CMD += " -Alias '"+$ParamObj.Alias+"'"}
            if($ParamObj.Position){$CMD += ""+$ParamObj.Position}
            if($ParamObj.ValueFromPipeline){$CMD += " -ValueFromPipeline $"+$ParamObj.ValueFromPipeline}
            if($ParamObj.Description){$CMD += " -Description '"+$ParamObj.Description+"'"}
            ## Run Command
            Write-Verbose $CMD
            IEX $CMD
            # Add Default value if needed
            if($ParamObj.DefaultValue){
                ## prep data
                $Val = $ParamObj.DefaultValue
                If($Val -match "True|False"){$Val = "`$$Val"}
                ElseIf($Val -is [String]){$Val = "'$Val'"}
                ## prep command
                $CMD = "Set-Param -name $Pname -DefaultValue $Val"
                ## Run Command
                Write-Verbose $CMD
                IEX $CMD
                }
            Focus-Param $Pname
            # Set Mandatory to false where needed
            foreach($S in $ListPSN_O){
                # Prep and run
                $CMD = "Set-Attribute -Mandatory False -PSN $S"
                Write-Verbose $CMD
                IEX $CMD
                Parse-Code <# TMPFIX - MISSING SOMEWHERE IN IN SET-ATTRIBUE CMDLET? or NEED FOCUS-FUNCTION SOMEWHERE? or ?? #>
                }
            # Set Parameter Validation
            ## Run if needed
            if($ParamObj.ValidateSet){
                $Val = $ParamObj.ValidateSet.trim().split(' ') -join "','"
                Set-ParamValidation -ValidateSet "$Val"
                }
            if($ParamObj.ValidateCount){
                $Val = $ParamObj.ValidateCount.trim().split(' ') -join ','
                Set-ParamValidation -ValidateCount $Val
                }
            if($ParamObj.ValidateRange){
                $Val = $ParamObj.ValidateRange.trim().split(' ')  -join ','
                Set-ParamValidation -ValidateRange $val
                }
            if($ParamObj.ValidateLength){
                $Val = $ParamObj.ValidateLength.trim().split(' ') -join ','
                Set-ParamValidation -ValidateLength $val
                }
            if($ParamObj.ValidatePattern){
                $Val = $ParamObj.ValidatePattern.trim()
                Set-ParamValidation -ValidatePattern "$Val"
                }
            if($ParamObj.ValidateScript){
                $Val = $ParamObj.ValidateScript
                Set-ParamValidation -ValidateScript {$Val}
                }
            if($ParamObj.ValidateNotNull){Set-ParamValidation -ValidateNotNull}
            if($ParamObj.ValidateNotNullOrEmpty){Set-ParamValidation -ValidateNotNullOrEmpty}
            if($ParamObj.AllowNull){Set-ParamValidation -AllowNull}
            if($ParamObj.AllowEmptyString){Set-ParamValidation -AllowEmptyString}
            if($ParamObj.AllowEmptyCollection){Set-ParamValidation -AllowEmptyCollection}
            }#EndForEach Param
        }#EndForEach Function
    Focus-Function $FunctionList[0]
    }## EOFunction

#endregion 

###################################EOF Monkey


### WEM
<#
.Synopsis
   Write Empire Module
.DESCRIPTION
   Auto Generate Empire Module files from PowerShell Script/Functions.
   Parses input Code using AST (Posh 3+).
   Extracts function/Parameters/Attributes needed to generate module file.
   Generates folder on desktop containing
   - ClonedPowerShell.ps1
   - MatchingPython.py.txt
   - ReadMe.txt
   Works against scriptpane (ISE & VSCode) or specified file.
   Must specify -SourceFile when console host.
   Uses AST iso Regex. Should work against various writing styles.
   Works with Empire 2.1
   
   If no -SourceFile specified, uses current scriptPane (ISE|VSCode).
   If no -Function specified, uses last non-nested one (bottom).
   If no functions in script, creates Invoke-CustomScript (and no parameters).
   
   Use -Function to run against specific function from script
   Add -Only to only extract specified as code .ps1 (vs. full source)

   Following metadata defaults are used if nothing specified:
   
     Field               Default
     -----               -------
     Category            Custom
     Author              Unknown
     Description         No Description
     Background          true
     OutputExtention     None
     NeedsAdmin          false
     OpsecSafe           false
     MinPSVersion        2
     Comments            No Comments

   All parameters are optional (metadata uses default unless specified)
   
   
   # Notes: 
   SourceFile accepts single pipeline Input 
   (use '$List|%{WEM $_}' for multiple)
   
   # Python Option Parameters: 
   Description -> Only found if in #Comment above each parameter (not in help)
   Required    -> Incorrect true/false if multiple ParameterSets in function

   # Tips: 
   Set own name as default author iso unknown (line 113)
   Create/use 'custom' folders in Empire for DIY stuff
   Module.py  -> empire/lib/module/powershell/custom/
   Code.ps1   -> empire/data/module_source/custom/
.EXAMPLE
   WEM
   Uses current scriptpane (ISE|VSCode). 
   Throws error in console (specify source)
   Uses last non-nested function when several (bottom main)
.EXAMPLE
   WEM -SourceFile $FilePath
   Uses specified source
   Uses last non-nested function
   Works in ISE|VSCode & Console
.EXAMPLE
   WEM -Function Do-Thing
   Uses specified function and associated parameters
.EXAMPLE
   WEM -Function Do-Thing -Only
   Uses specified function and associated parameters
   Extracts only this code as .ps1 file for module source
.EXAMPLE
   WEM -Category Recon -Author SadProcessor -OpsecSafe True
   Uses specifed params for module metadata iso defaults

   Following module metadata can be set

   Category | Author |Description | Background | OutputExtention
   NeedsAdmin | OpsecSafe | MinPSVersion | Comments

   All have default values if not specified
.EXAMPLE
   WEM -Massage '| ConvertTo-Json'
   Appends massage string to module
.INPUTS
   Scriptpane (ISE|VSCode) content or Sourcefile
   Must specify -SourceFile when working in console host
.OUTPUTS
   Python module file -> ModuleFile.py.txt
   Posh source code   -> SourceCode.ps1
   Text Read-Me       -> ReadMe.txt
.NOTES
   Empire is an Open-Source Post-Exploitation Framework
   designed by @harmj0y & Crew
   
   More Info:
   https://github.com/EmpireProject/Empire/wiki/ 
.LINK
   https://github.com/EmpireProject/Empire/wiki/Module-Development
#>
function Write-EmpireModule{
    [CmdletBinding(DefaultParametersetname='Scriptpane')]
    [Alias('WEM','Modulizer')]
    Param(
        # Specify Function to use
        [Parameter(Mandatory=$true,ParameterSetName='Function')][String]$Function,
        # Specified function text only
        [Parameter(ParameterSetName='Function')][Switch]$Only,
        # Specify Category (folder)
        [ValidateSet('Code_Execution','Collection','Collection/Vaults','Credentials','Exfil','Exploitation',
                     'Lateral_Movement','Management','Persistence','PrivEsc','Recon','Situational_Awareness/Host',
                     'Situational_Awareness/Network','TrollSploit','Custom')]
        [Parameter()][String]$Category='Custom',
        # Specify Module Author(s)
        [Parameter()][String[]]$Author='Unknown',
        # Specify Module Description
        [Parameter()][String[]]$Description='No Module Description',
        # Specify if runs in background
        [ValidateSet('True','False')]
        [Parameter()][String]$Background='True',
        # Specify output extension
        [Parameter()][String]$OutExt='None',
        # Specify if requires Admin
        [ValidateSet('True','False')]
        [Parameter()][String]$NeedsAdmin='False',
        # Specify if Opsec Safe
        [ValidateSet('True','False')]
        [Parameter()][String]$OpsecSafe='False',
        # Specify minimum PowerShell version
        [ValidateSet('2','3','4','5')]
        [Parameter()][String]$MinPSVersion='2',
        # Specify Comments
        [Parameter()][String[]]$Comments='No Comments',
        # Specify extra massage Command
        [ValidatePattern("^\s?\|\s?\w+")]
        [Parameter()][String]$Massage,
        # Specify source file
        [Parameter(Position=0,ValueFromPipeline=$true)][Alias('Path')][String]$SourceFile
        )
    Begin{
        Write-Verbose "Host is $($Host.Name)..."
        }
    Process{
        $input = $Null
        # If No source file specified
        if(!$SourceFile){
            Write-Verbose "No Source File Specified..."
            switch($host.Name){
                # if Console -> Break
                'ConsoleHost'{Write-Warning 'Must specify Source File...'; Break}
                # if ISE -> use psISE obj
                'Windows PowerShell ISE Host'{$Input = $psISE.CurrentFile.Editor.Text}
                # if VSCode -> use psEditor obj
                'Visual Studio Code Host'{$Input = $psEditor.GetEditorContext().CurrentFile.AST.Extent.Text}
                }
            Write-Verbose "Reading from current script pane..."
            }
        # Else, get file content (if exist)
        Else{
            if(Test-Path $SourceFile){$Input = Get-Content $SourceFile -Raw}
            else{Write-Warning 'File not found...';Break}
            }

        # Parse Input (AST)
        Write-Verbose "Parsing input..."
        if($Input){$Tok=$Err=$Null; $AST = [System.Management.Automation.Language.Parser]::ParseInput($Input,[ref]$Tok,[ref]$Err)}
        Else{Write-Warning 'Empty Script Content...'; Break}
        # If empty AST -> Break
        if($AST.Extent.text -eq ''){Write-Warning 'Empty Script Content...'; Break}
        # If error in input > Break
        if($Err -ne $Null){Write-Warning 'Invalid Source code...';Break}

        # Select $posh (for later)
        $Posh = $Input
        # Get all functions from AST
        $AllFunctAST = $AST.FindAll({$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]},$true)
        # if function specified
        if($Function){
            Write-Verbose "Searching function '$Function'..."        
            # Select in All Function
            $FunctAST = $AllFunctAST | ? Name -eq $Function
            # if not found
            if(!$FunctAST){Write-Warning 'Function not found...';Break}
            }
        # if no function specifed -> use last non-nested one
        if(!$Function){
            Write-Verbose "No specified function..."
            Write-Verbose "Searching function..."
            # find all non-nested function and select last one
            $FunctAST = $AllFunctAST | ? {$_.Parent.Parent.Parent -eq $Null} | select -last 1
            # if no function exist -> use Invoke-Script
            if(!$FunctAST){
                $Name = 'Invoke-CustomScript'
                Write-Verbose "No functions found "
                Write-Warning "Using '$Name' & No Params..."
                }
            }

        # If no function exist
        if(!$FunctAST){
            # format script
            $Posh = @("function $Name{`r`n$($Input.trim())`r`n}")
            $ParamSnippet = $Null
            }
        # Else
        if($FunctAST){
            # Get function name
            $Name = $FunctAST.name
            write-Verbose "Found Function '$Name'..."
            #Look for function Params (ParamblockAST)
            $ParamBlockAST = $FunctAST.findall({$args[0] -is [System.Management.Automation.Language.ParamBlockAst]},$true) | Where {$_.Parent.Parent.name -eq $Name}
            # if found get param tree
            if($ParamBlockAST){
                Write-Verbose "Found Parameters..."
                $ParamSnippet = @("")
                $ParamAST = $ParamBlockAST.findAll({$args[0] -is [System.Management.Automation.Language.ParameterAst]},$true)
                $ParamCollection=@{}
                # Generate Param Snippet
                foreach($Param in $ParamAST){
                    # Prep vars
                    # Name
                    $PName = $Param.Name.VariablePath.UserPath
                    # Description
                    $ParamLine = $Param.extent.StartLineNumber
                    $CommentTok = $Tok | ? Kind -eq Comment | ?{$_.Extent.StartlineNumber -eq ($ParamLine -1)}
                    $PDescription = ($CommentTok.text -replace "^#",'').Trim()
                    if($PDescription -eq ''){$PDescription = 'No description for this parameter'}
                    # Required
                    $PRequired = 'False'
                    if(($Param.Attributes.NamedArguments | ? ArgumentName -eq 'Mandatory').Argument.VariablePath.UserPath -eq 'true'){$PRequired='True'}
                    # Value
                    $PValue = $Param.DefaultValue.Value
                    # If Mandatory false and value is set
                    # Mandatory is True (for empire)
                    if($PRequired -eq 'False' -and $PValue.count){$PRequired='True'}
                    # Append to snippet  
                    $ParamSnippet += @("          '$PName' : {
                'Description'   :   '$PDescription',
                'Required'      :   $PRequired,
                'Value'         :   '$PValue'
            },
 ")
                    }
                $ParamSnippet[$ParamSnippet.count -1] = $ParamSnippet[$ParamSnippet.count -1].ToString().TrimEnd().TrimEnd(",") + "`r`n"
                }
            # else (if no params in function)
            Else{$ParamSnippet = $Null; Write-Warning "No Parameters found in function..."}
            }
        
        ## Prepare text Blocks
        Write-verbose "Generating Python Module..."
        # prep vars
        $Category = $Category.ToLower()
        If($Massage){$MassageString = @("`r`n`tscriptEnd += `"$Massage`"`r`n")}
        # Top
        $HeadSnippet = @("import base64
from lib.common import helpers

class Module:

    def __init__(self, mainMenu, params=[]):

        self.info = {
            'Name': '$Name',

            'Author': ['$($Author -join `"','`")'],

            'Description': ('$($Description -join `"',`r`n`t`t`t`t`t`t`t'`")'),

            'Background' : $Background,

            'OutputExtension' : $OutExt,

            'NeedsAdmin' : $NeedsAdmin,

            'OpsecSafe' : $OpsecSafe,

            'Language' : 'powershell',

            'MinLanguageVersion' : '$MinPSVersion',

            'Comments': [
                '$($Comments -join `"',`r`n`t`t'`")'
            ]
        }
")
        # Option
        $OptionSnippet = @("       # any options needed by the module, settable during runtime
        self.options = {
            # format:
            #   value_name : {description, required, default_value}
            'Agent' : {
                'Description'   :   'Agent to run module on.',
                'Required'      :   True,
                'Value'         :   ''
            },
")
        # Bottom
        $FootSnippet = @("       }

        # save off a copy of the mainMenu object to access external functionality
        #   like listeners/agent handlers/etc.
        self.mainMenu = mainMenu

        for param in params:
            # parameter format is [Name, Value]
            option, value = param
            if option in self.options:
                self.options[option]['Value'] = value

    def generate(self, obfuscate=False, obfuscationCommand=`"`"):

        # read in the common module source code
        moduleSource = self.mainMenu.installPath + `"/data/module_source/$Category/$Name.ps1`"
        if obfuscate:
            helpers.obfuscate_module(moduleSource=moduleSource, obfuscationCommand=obfuscationCommand)
            moduleSource = moduleSource.replace(`"module_source`", `"obfuscated_module_source`")
        try:
            f = open(moduleSource, 'r')
        except:
            print helpers.color(`"[!] Could not read module source path at: `" + str(moduleSource))
            return `"`"

        moduleCode = f.read()
        f.close()

        script = moduleCode

        scriptEnd = `"\n$Name`"

        # showAll = self.options['ShowAll']['Value'].lower()

        for option,values in self.options.iteritems():
            if option.lower() != `"agent`" and option.lower() != `"showall`":
                if values['Value'] and values['Value'] != '':
                    if values['Value'].lower() == `"true`":
                        # if we're just adding a switch
                        scriptEnd += `" -`" + str(option)
                    else:
                        scriptEnd += `" -`" + str(option) + `" `" + str(values['Value'])
$MassageString
        if obfuscate:
            scriptEnd = helpers.obfuscate(psScript=scriptEnd, obfuscationCommand=obfuscationCommand)
        script += scriptEnd
        return script
")

        ## Prep output files
        # Prep Python
        $Python = $HeadSnippet+$OptionSnippet+$ParamSnippet+$FootSnippet
        
        # if -only > extract this function only (overwrites previous $PoSh)
        if($Only){
            # Select only function text
            if($FunctAST){$Posh = $FunctAST.Extent.Text}
            }
        Write-verbose "Copying PowerShell Source code..."
        
        # Set some vars
        $InstallPath = "/data/module_source/$Category/$Name.ps1"
        If($Name -match '-'){$PythonFile = ($Name.split("-")[1]).toLower()}
        Else{$PythonFile = $Name.tolower()}
        $ModuleFolder = "/lib/modules/powershell/$Category"
        $Date = (Get-Date).ToShortDateString()
        $Time = (Get-Date).ToShortTimeString()
        # Prep Read-Me
        Write-verbose "Generating Read-Me..."
        $ReadMe = @("
###########################################
# Empire : $Category 
# Module : $Name
# Author : $Author
###########################################
#
# ## Install:
#
# # Copy Files to Empire Folders:
# empire$InstallPath
# empire$ModuleFolder/$PythonFile.py 
#
# # [Re]Start Empire
#
# # Test & Tweak
#
# # Enjoy & Share...
#
###########################################
# Extracted from PoSh Tree - 99% Pure AST 
# $date @ $time 
###########################################
")
        # Check for folder
        $OutFolder = Join-Path (Join-Path $home "desktop") $Name.replace('-','')
        if(!(test-Path $OutFolder)){$Null = mkdir $OutFolder;Write-Verbose "Creating Folder on desktop..."}
        # Output to files (overwrites existing module files)
        $Null = New-Item -Path $OutFolder -Name "$name.ps1" -ItemType File -Value "$posh" -Force
        If($Host.name -eq 'ConsoleHost'){$Python = $Python -replace "`n","`r`n"}
        $Null = New-Item -Path $OutFolder -Name "$PythonFile.py.txt" -ItemType File -Value "$Python" -Force
        $Null = New-Item -Path $OutFolder -Name "ReadMe.txt" -ItemType File -Value "$ReadMe" -Force 
        Write-Verbose "Saved to $OutFolder...`r`nDone!"
        # open folder
        explorer $OutFolder
        # show ReadMe
        $readMe
        }
    End{}
    }

######################################################EOF WEM

<#
.Synopsis
   Get Example
.DESCRIPTION
   Get Cmdlet examples / example list / syntax
.EXAMPLE
   Get-Example Get-Date -List
.EXAMPLE
   Example Get-Date -number 1
.EXAMPLE
   Ex Get-Date -syntax
#>
Function Get-Example{
    [Alias('Example','ex')]
    Param(
        [Parameter(Mandatory=1,Position=0,ValuefromPipeline=1)][string]$Cmdlet,
        [Parameter(Mandatory=0,Position=1,ParameterSetName='Number')][int]$Number=1,
        [Parameter(Mandatory=1,ParameterSetName='List')][Switch]$List,
        [Parameter(Mandatory=1,ParameterSetName='Syntax')][Switch]$Syntax
        )
    # Get Examples
    $ExampleList = Get-Help $Cmdlet -ea sil | Select -Expand Examples -ea sil  
    # If Examples doesnt exist
    if(-Not$ExampleList){Write-Warning 'Examples not found...';Return}
    # If Syntax
    if($Syntax){Return (Get-Help $Cmdlet -ea Sil).syntax}
    # If List
    if($List){Return $ExampleList.example.Title}
    # If Number
    if($Number){Return $ExampleList.example[$Number-1]}
    }

################################################## EOF Examples

<#
.Synopsis
   Search History
.DESCRIPTION
   Search history by partial term 
.EXAMPLE
   Searh-History date
.EXAMPLE
   sh date | ch 
#>
function Search-History{
    [Alias('sh')]
    Param(
        # Specify Search Term
        [Parameter(Mandatory=1,ValueFromRemainingArguments=1)][String]$Term
        )
    # Return matching History Items
    Return Get-History | Where Commandline -Match $Term
    }
#End


<#
.Synopsis
   Copy History
.DESCRIPTION
   History item to ClipBoard by ID
.EXAMPLE
   Example of how to use this cmdlet
#>
function Copy-History{
    [Alias('ch')]
    Param(
        # Specify history Item ID
        [Parameter(Mandatory=1,ValueFromPipelineByPropertyName=1)][Int]$ID
        )
    # Get Item
    $Selection = (Get-History | Where ID -eq $ID)
    # Copy To Clipboard
    $Selection[$Selection.count -1].CommandLine | Set-Clipboard
    }
#End

set-alias -Name h -Value get-history -ea SilentlyContinue
set-alias -Name xh -Value invoke-history -ea SilentlyContinue

################################################################## EOF



function Out-MDTable{
    Param(
        [Parameter(Mandatory=1,ValueFromPipeline=1)][PSObject]$Object
        )
    Begin{
        $Body = @()
        }
    Process{
        $String = '|'
        $PropList = ($Object | Get-Member | ? MemberType -eq NoteProperty).name
        $PropList | % -begin{
            $String = '|'
            }<#######>-Process{
            $String += " $($Object.$_) |"
            }<#######>-end{
            $String+="`n"
            }
        $Body += $String
        }
    End{
        $PropList | % -Begin{
            $Head = '|'
            }<#######>-Process{
            $Head += " $_ |"
            }<#######>-End{
            $Head+="`n|"
            }
        1..$PropList.Count | %{
            $Head += ' --- |'
            }
        $Head+="`r`n"
        Return ($Head+$Body).Split("`n").trim()
        }}
#####End

##############################################################################


 <#
.Synopsis
   King Pong - The Ping Kong...
.DESCRIPTION
   Subnet Ping: Multi-NIC/Auto-Subnet/Multi-Thread.
   Returns only IPs where Success
   By default only one ping (max 5)
   From a tweet by @Lee_Holmes.
.EXAMPLE
   Pong
.EXAMPLE
   Pong 5
.LINK
   https://twitter.com/Lee_Holmes/status/646890380995067904
#>
Function Invoke-KingPong{
    [CmdletBinding()]
    [Alias('Pong')]
    Param(
        # Ping Count (Default=1/Max=5)
        [ValidateRange(1,5)][Parameter()][int]$Count=1
        )
    Begin{
        ## Subs
        # IP to Num
        function IP2NUM{Param([String]$IP); return [int64]([int64]$IP.split(".")[0]*16777216+[int64]$IP.split(".")[1]*65536+[int64]$IP.split(".")[2]*256+[int64]$IP.split(".")[3])} 
        # Num to IP
        function NUM2IP{Param([Int64]$Num); return (([math]::truncate($Num/16777216)).tostring()+"."+([math]::truncate(($Num%16777216)/65536)).tostring()+"."+([math]::truncate(($Num%65536)/256)).tostring()+"."+([math]::truncate($Num%256)).tostring())}
        ## Prep
        # Prep Empte result
        $Result =@()
        # Prep empty IP list
        $IPList = @()
        # Get NICs
        $NICList = Gwmi win32_networkadapterconfiguration | Where defaultIPGateway -ne $null
        }
    Process{
        # List IPs to Ping for each nic
        Foreach($NIC in $NICList){
            # IP & Mask
            $IP     = [Net.IPAddress]::Parse($NIC.ipaddress[0])
            $Mask   = [Net.IPAddress]::Parse($NIC.ipsubnet[0])
            # Network & Broadcast
            $Ntwrk  = New-Object net.IPAddress ($Mask.address -band $IP.address)
            $Brdcst = New-Object Net.IPAddress ([Net.IPAddress]::parse("255.255.255.255").address -bxor $Mask.address -bor $Ntwrk.address)
            Write-Verbose "Net: $($Ntwrk.IPAddressToString) | Mask: $Mask" 
            # Start & End Num
            $Start  = (IP2NUM -IP $ntwrk.ipaddresstostring)  +1
            $End    = (IP2NUM -IP $brdcst.ipaddresstostring) -1
            # Num to IP to IPList
            For($n=$Start; $n -le $End; $n++){$IPList += NUM2IP -Num $n}
            }
        # For each count
        1..$Count | %{
            # Ping IP List a la Lee Holmes
            $Ping = $IPList | sort -Unique | %{(New-Object Net.NetworkInformation.Ping).SendPingAsync($_,250)}
            [Threading.Tasks.Task]::WaitAll($Ping) 
            # Get IPs where Success
            $Success = ($Ping.Result | ? Status -eq Success | Select -ExpandProp address).IPAddressToString
            Write-Verbose "$($Success.count)/$($Ping.Result.count)"
            $Result += $Success
            }}
    End{return $Result | Sort -Unique}
    } 
#End


#############################################

# Start/Pause VMs
function Resume-Lab{[Alias('Start-Lab')]Param()Get-vm | where state -eq paused | Resume-VM}
function Suspend-Lab{[Alias('Pause-Lab')]Param()Get-VM | Where state -eq running | Suspend-VM}


#############################################

function Get-LastErrorMessage{
    [Alias('_')]
    Param()
    $E = $error[0]
    if($E.message){$E.Message}
    elseif($E.Errors.message){$E.Errors[0].Message}
    elseif($E.exception){($E.exception)[0].message}
    elseif($E.ErrorDetails){($E.ErrorDetails)[0]}
    else{"$($E.CategoryInfo.category) - $($E.CategoryInfo.Reason)"}
    }
#End


function Wait-Voice{
    While($SpeechSynth.State -ne 'Ready'){Start-Sleep -m 500}
    }