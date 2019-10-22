<#Push Whatever Obj to BH DB [per label]#>
function Push-ToNode{
    [Alias('ToNode')]
    Param(
        [ValidateSet('GPO','OU','User','Group','Computer')]
        [Parameter(Mandatory=1,Position=0)][Alias('Label')][String]$type,
        [Parameter(Mandatory=1,ValueFromPipeline=1)][PSCustomObject]$Object
        )
        Begin{}
        Process{
            Foreach($Obj in $Object){
                # Get Name
                $Name = $Obj.name
                if(-Not$Name){Break}
                # Prep Props
                [HashTable]$props=@{}
                foreach($Key in ($Obj|GM|? Membertype -eq noteproperty|? Name -ne 'name').name){
                    $Props.Add($Key,$($_.$Key))
                    }
                # Create node
                NodeCreate $Type $Name -Prop $Props -ea Silent            
                }
            }
        End{}
    }
#End

# Push Node
ATTCK-Tactic    | select Name,ID,Description,Wiki,STIX        | Push-ToNode OU
ATTCK-Technique | Select Name,ID,Description,Wiki,STIX,Tactic | Push-ToNode GPO
ATTCK-Software  | select Name,ID,Description,Wiki,STIX        | Push-ToNode Computer
ATTCK-Group     | Select Name,ID,Description,WIki,STIX        | Push-ToNode Group

#Tactic/TeChnique
foreach ($tactic in @((ATTCK-Tactic).name.replace(' ','-'))){
    foreach($Technique in @((ATTCK-Technique| Where Tactic -Contains $tactic)).name){
        DogPost "MATCH (S:GPO) WHERE S.name='$Technique' MATCH (T:OU) WHERE T.name=~'$($tactic.replace('-',' '))' MERGE (S)-[R:Uses]->(T)"
        }
    }

#Other Rels
$ATTCK.Relationship | ? Edge -eq uses | select Source,Edge,Target | %{
    DogPost "MATCH (S) WHERE S.STIX=~'$($_.Source)' MATCH (T) WHERE T.STIX=~'$($_.Target)' MERGE (S)-[R:Uses]->(T)"
    }


