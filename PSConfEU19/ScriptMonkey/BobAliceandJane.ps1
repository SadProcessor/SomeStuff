Clear
Bob "Hello PowerShell Conference Europe, my name is bob..."
Bob "I am here today with Alice..."
Alice "Hi folks..."
Bob "And we will show you how to write functions from the prompt in ISE"
Alice "this is going to be awesome..."
Bob "Let's get started..."
Bob "first, I start with the function definition"
Bob "let's call it Invoke Jane"
Demo {New-Function -Name Invoke-Jane -Alias Jane -Synopsis "Invoke Jane Demo" -Template Max}
Alice "Wow! Awesome..."
Bob "I know right?"
Bob "now I add some Parameters..."
bob "First things first, the Text parameter"
bob "this one will be mandatory"
Demo {New-Param -Name Text -Type  String[] -Mandatory True -ValueFromPipeline True -Position '0'}
bob "Next, the Emoji parameter"
Demo {New-Param -Name Emoji -Type EmojiName -Mandatory False}
bob "and I add a default value for it..."
Demo {Set-Param -Name Emoji -DefaultValue 'Alice'}
Alice "Nice! Just like me..."
bob "then, I add a color parameter..."
Demo {New-Param -Name Color -Type ConsoleColor -Mandatory False}
bob "What color should we do Alice?"
Alice "Green? Everybody loves Green..."
bob "ok Alice, let's go for green" 
Demo {Set-Param -Name Color -DefaultValue 'Green'}
Bob "Now I add the Rate parameter..."
Demo {New-Param -Name Rate -Mandatory False}
bob "and with the same technique,I set a validate range and default value for it..."
Set-ParamValidation -ValidateRange @(-10,10) -ParamName Rate
Set-Param -Name Rate -DefaultValue 1
Bob "Finally, I add Some Switches for more control: Voice Only and Async"
New-Param -Name VoiceOnly -Type Switch -Alias x -Mandatory False
New-Param -Name Async -Type Switch -Mandatory False
Bob "and there you go, the base for Invoke-Jane is ready"
Bob "Now all I need to do is add my commands to this function..."
Alice "wow! this is truly awesome..."
Alice "I think we need to celebrate..."
Alice 'How about a party parrot?'
Bob "Hell yeah!"
$psISE.CurrentPowerShellTab.ExpandedScript=$false
PartyParrot

