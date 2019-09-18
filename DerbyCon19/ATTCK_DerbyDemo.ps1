### DerbyCon Demo ###
Invoke-ATTCKnowledge -Online
# Import ATT&CK Obj
Invoke-ATTCKnowledge -Sync -verbose


## TACTICS

# List All Tactics
Get-ATTCKTactic
ATTCK-Tactic

# Online
ATTCK-Tactic -Online

# Get Tactic by Name
ATTCK-Tactic Discovery | selecT *

# Full object
ATTCK-Tactic 'Initial Access' | select *

# Online
ATTCK-Tactic 'Command and Control' -Online

# Tactic by ID
ATTCK-Tactic -ID TA0001



## TECHNIQUES

# Get All
Get-ATTCKTechnique
ATTCK-Technique
ATTCK

ATTCK | count

ATTCK -Online

# Get by Name
ATTCK 'Account Manipulation'

ATTCK 'Account Manipulation' | select *

ATTCK 'Account Manipulation' -Online

ATTCK 'Account Manipulation' | select -expand Description | Set-Clipboard

# Reference
ATTCK 'Code Signing' -Reference | fl

ATTCK 'Code Signing' -Reference -Online

# Filter tactic
ATTCK -Filter defense-evasion | select id,name,Description

## Group
ATTCK-Group

ATTCK-Group APT29

ATTCK-Group APT29 | select -expand alias

ATTCK-Group 'Cozy Bear' | select *

ATTCK-Group 'Cozy Bear' -Online

ATTCK-Group APT29 -Reference -Online

## Software
ATTCK-Software

ATTCK-Software -Filter malware

ATTCK-Software Empire

ATTCK-Software Empire -Online -Reference


## Advanced search
ATTCK | ? description -match 'Subtee' | select name,id,description

ATTCK -filter execution | ? Tactic -match 'defense-evasion' | name
 
ATTCK -Filter defense-evasion | ? platform -match windows | ? bypass -match 'Log analysis' | Select -expand name

ATTCK-Software -Filter malware | ? description -match 'C\+\+'

ATTCK-Group | ? Description -match 'russia'

ATTCK-Group | ? alias -match Panda


# ATTCK Trivia
ATTCK | ? reference -match mattifestation | select name,id | sort ID -Descending


## Mapping
# Used CypherDog to push ATTCK Nodes to Graph DB (BH)

# Techniques used by APT28
"MATCH p=((G:Group {name:'APT28'})-[r:Uses*1]->(O:GPO)) RETURN p" | Set-Clipboard

# Tech/Tactic in Mimikatz
"MATCH p=(y:Computer {name:'Mimikatz'})-[s:Uses*2]->(O:OU) RETURN p" | Set-Clipboard
"MATCH p=(y:Computer {name:'Empire'})-[s:Uses*2]->(O:OU) RETURN p" | Set-Clipboard

# Groups using Mimikatz
" MATCH p=(x:Group)-[r:Uses*1]->(y:Computer {name:'Mimikatz'}) RETURN p" | set-clipboard

# Groups using software using Powershell
"MATCH p=(x:Group)-[r:Uses*2]->(y:GPO {name:'PowerShell'})-[s:Uses*1]->(O:OU) RETURN p" | Set-Clipboard


## Atomic Canary

AtomicCanary T1117

ATTCK Regsvr32 | AtomicCanary

ATTCK Regsvcs/Regasm | AtomicCanary | ? tool -eq PowerShell

ATTCK -Filter lateral-movement | AtomicCanary | ? Tool -eq PowerShell

## < Your idea goes here >