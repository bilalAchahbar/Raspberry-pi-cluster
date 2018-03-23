# Kubernetes cluster op een Raspberry pi cluster

![Setup](/images/XplorianCluster.jpg)

## Maintainer

Bilal Achahbar 

## Beschrijving
Ik heb een Raspberry Pi cluster gebouwd op een Bitscope rack. Dat als doel heeft om te dienen als een Kubernetes cluster. Deze cluster zal gebruikt worden om te installeren in een local netwerk. Zodat iedereen die de technologie van kubernetes nodig heeft, kan verbinden met de cluster. Om een zo high available manier van werken te garanderen heb ik ook een basic mogelijke image gemaakt "Xplorian.img". Dit is zodat wanneer er toch iets verkeerd zou lopen je altijd makkelijk kan terugkeren naar een basic setup. Ik heb alles zo goed mogelijk gedocumenteerd in verschillende markdown bestanden. Hier onder zal je een link vinden naar de tutorials en documentatie die ik heb gemaakt voor dit project hoe ik elk onderdeel heb opgebouwd of uitgeprobeerd. Zodat moest het nodig zijn om aanpassingen uit te voeren of van scratch te herbeginnen je met mijn documentatie voldoende zou hebben om jouw idee uit te voeren. 

## Hardware

- 4 Raspberry pi 3 
- Bitscope quattro pi cluster
- 4 geheugen kaarten (16 GB)


## Documentatie

### ![Setup Basic image](https://github.com/bilalAchahbar/Raspberry-pi-cluster-xplore-group/blob/master/Set%20up%20basic%20image.md)
 
- In deze file leg ik volledig uit hoe ik van een lege sd kaart tot mijn basic image ben gekomen. Deze basic image heeft alle nodige aanpassingen en programma's al ingesteld zodat deze direct te gebruiken is voor de Raspberry pi. 
      

### ![Bitscope setup](/tutorial-bitscope-rack.md)
 
 - Voor de setup van mijn raspberry pi heb ik gebruik gemaakt van een Bitscope quattro pi. Deze hardware is gemaakt om een server rack te maken van raspberry pi's. Hiervoor heb ik een tutorial gemaakt hoe ik de Bitscope rack in elkaar heb gestoken.
 
### ![Setup Kubernetes Cluster](https://github.com/bilalAchahbar/Raspberry-pi-cluster-xplore-group/blob/master/Kubernetes.md)
  
- Als alles is opgezet en alle raspberry pi's klaar staan kunnen we beginnen met een kubernetes cluster op te zetten. In deze file leg ik uit hoe je een kubernetes master initialiseert en nodes kan toevoegen aan de cluster. Op het einde van deze documentatie heb je een basic kubernetes cluster opgezet. Verder word er ook uitgelegd hoe je een kubernetes dashboard moet opzetten en hoe je bepaalde serviceaccounts met restricted access kan toevoegen.

### ![Virtuele omgeving](https://github.com/bilalAchahbar/Raspberry-pi-cluster-xplore-group/blob/master/Tutorial%20%20Bitscope%20Rack.md)
 
 - In een wereld waar Edward A. Murphy voorspelde dat wanneer er iets fout kan gebeuren dit ook zal gebeuren moeten we als it'ers dit vaak zien te voorkomen. Om een virtuele testomgeving op te zetten zodat we niet te veel verkeerd kunnen doen aan de hardware .Heb ik geprobeerd om een virtuele raspberry pi cluster op te zetten. Maar de technologie is op het moment dat ik dit heb geschreven nog niet optimaal om een kubernetes cluster op een virtuele raspberry pi cluster op te zetten. Bekijk de documentatie hoe ik dit heb opgezet en waar het verkeerd loopte. En  misschien is op het moment dat je deze readme leest de bug in de virtuele emulator opgelost en kan jij dit wel opzetten.
 
 
## How to 

Als je alles hebt opgezet volgends mijn documentatie en de raspberry pi's zijn up & running en je kubernetes dashboard draait moet je nog bepaalde aanpassingen uitvoeren.


- SSH keys aanmaken op je host machine
 Dit doe je best voor gemaks redenen zodat je niet telkens de credentials moet ingeven als je wilt verbinden naar de cluster. 
 
### SSH keys aanmaken op je host machine
##### SSH key aanmaken in linux 
In linux is de ssh client  standaard al geinstalleerd. Is dit niet het geval kan je dit doen door `sudo apt-get install openssh-server`Deze zal de server en de client voor je installeren. 
Met de commando `ssh-keygen -t rsa -C comment`_(Geef als comment de naam van jouw pc of jou naam mee zodat je in de raspberry pi later de keys van de verschillende pc’s makkelijker kan achterhalen.)_ ga je de ssh keys genereren. Volg de instructies op het scherm. Je zal gevraagd worden om de keys op te slaan in een map naar keuze of de default home folder. Verder krijg je de vraag om een wachtwoord in te geven , deze dient om de private key te beveiligen.
Bij een succesvolle creatie van een ssh key krijg je soortgelijk scherm te zien

![Linux ssh](/images/linux_ssh.jpg)

Nu zal je de public key van je hostmachine moeten kopiëren om deze in je raspberri pi op te slaan en dat je raspberri pi jouw host machine als authorized host kan zien. Dit kan je doen met volgende commando:
`cat ~/.ssh/id_rsa.pub | ssh Gebruiker@Hostname 'cat >> .ssh/authorized_keys'`
Als je nu inlogt via ssh (met de commando `ssh Gebruiker@Hostname`) zal je direct ingelogd zijn zonder eerst de credentials in te moeten geven.

##### SSH key aanmaken in macOS

Aangezien mac met dezelfde unix terminal werkt als linux zijn de commando’s identiek namelijk: 
-	`ssh-keygen -t rsa -C comment` (Geef als comment de naam van je pc of jouw naam mee).
-	Stel hierna in waar de keys moeten worden opgeslagen.
-	Voor een extra beveiliging kan je een wachtwoord instellen op de private key. *OPTIONEEL*
-	Ten slotte kopieer je de publieke key naar de raspberri pi`cat ~/.ssh/id_rsa.pub | ssh Gebruiker@Hostname 'cat >> .ssh/authorized_keys'`.
-	Je kan verbinden met de raspberry pi vanuit macOS via volgende commando `ssh Gebruiker@Hostname`.

##### SSH key aanmaken Windows

In Windows gebruik je niet de ssh keygen commando maar de Putty Key Generator. Dit is een programma van putty die een publieke en private key zal genereren.Open de putty keygen generator (dit is normaal gezien standaard mee geinstalleerd wanneer je Putty hebt geinstalleerd bekijk de download page van Putty wanneer dit niet het geval is). Daar kies je in het tabblad key voor de optie “SSH-2 RSA key” en klik je op Generate. 

Beweeg je muis over het lege grijze vlak zodat de keygenerator  zijn werk kan uitvoeren en een random key kan genereren. Nadat putty een ssh key heeft uitgevoerd krijg je volgend scherm te zien.. De private key en de public key sla je veilig op je host machine via de 2 onderste knoppen "Save public key" , "Save Private key". De private key zal je later nodig hebben om te verbinden met je raspberri pi. **SLA ZEKER JE KEYS GOED OP**

![Putty keygen](/images/PuttyKeygen.jpg)

De bovenstaande key die je in het textvak kunt zien moet je kopieren en plakken in de authorized_keys file van je raspberry pi **LET OP DE SCROLBAR, KOPIEER ZEKER ALLES MEE**. Hiervoor ga je in putty verbinden (TYP DIT NIET OVER KOPIEER) met de raspberry pi om naar volgende bestand te gaan `~/.ssh/authorized_keys`. Dit bestand kan al andere keys bevatten van andere pc’s je plakt hierin de publiek key van jouw pc op een nieuwe lijn(in Putty kan je plakken vanuit je  windows klembord met de shortkey *SHIFT+INSERT*). Sla het bestand ~/.ssh/authorized_keys op en sluit de editor.

###### **Verbinden met de raspberry vanuit windows host.**

Wanneer je nu wilt verbinden met de Raspberry pi vanuit je windows host ga je de private key meegeven in Putty dit doe je door in Putty het volgende in te stellen. Bij opstart van Putty kies je in het linkerscherm voor -->SSH-->Auth daar zie je de Browse knop en  moet je de private key meegeven  die je daarnet in de Putty Key Generator hebt opgeslagen(niet de key die je hebt gekopieerd in ~/.ssh/authorized_keys file maar de key die je hebt opgeslagen in de keygenerator met de kop "Save private key" .

![Putty geef private key mee](/images/PuttySshPrivatekey.jpg)

Wanneer je nu verbind met je raspberry zal je niet gevraagd worden om het wachtwoord in te geven want hij bevestig jouw machine door de ssh key. Je kan zelf de default gebruikersnaam instellen in putty zodat hij je ook niet zal vragen achter jouw gebruikersnaam. Door in het tabblad Connection--> Date de auto-login username in te stellen. Zo zal je bij je volgende sessie direct verbonden zijn met je raspberry pi. Vergeet zeker niet om deze instellingen in putty  op te slaan zodat je niet steeds de keys en de default gebruikersnaam moet meegeven.


## Handige tools

In de basic image staan er al bepaalde bash scripts klaar zodat je handig bepaalde instellingen kunt uitvoeren. De bash scripts die handig zijn om te gebruiken eenmaal je alles hebt opgezet zijn `xplore` en `update`. Deze 2 bash scripts staan al in de /usr/local/bin folder dus kan je overal oproepen. Zie de documentatie "Set up basic image" waar een uitgebreide uitleg staat over deze 2 bach scripts.

### Oeps er is iets fout gelopen

Stel dat er toch nog iets fout is gelopen bij een raspberry pi is dat zeker niet het einde van de wereld. Daarvoor heb ik ook een basic image aangemaakt zodat dit makkelijk en snel kan verholpen worden. Hoe ga je te werk:

- Brand de basic image op een nieuwe sd kaart 
- Zoek eerst uit welke ip address de dhcp aan jouw raspberry pi heeft gegeven
- SSH naar je Raspberry pi
- Verander de ip address  naar een static ip address
- Verander host name door middel van een bash script die al klaar staat `changeHostname.sh`(Ook deze kan je overal oproepen aangezien deze is opgeslagen in de /usr/local/bin folder)


Voor een node die je opnieuw moet instellen of wilt bij toevoegen: 
 - Kopieer de joinKey.txt vanuit de master naar de nieuwe node.
 - Voer deze commando uit zodat je node word toegevoegd aan de cluster.

Als de master is weg gevallen zal je de volledige cluster opnieuw op moeten zetten maar dat is zo gebeurd.
  - Nadat je dus de static ip en de hostname hebt veranderd moet je de kubeConfig.yaml kopieren naar de master pi.
  - Volg dan de documentatie van de kubernetes die ik heb gemaakt om de kubernetes cluster op te zetten ( 5 commando's)
  - **Zorg er zeker voor dat je de commando `sudo kubeadm reset` uitvoert op de nodes dat deze de gegevens van de vorig master verwijderd**
  - **Verwijder dan ook de joinkey.txt van de vorige kubernetes cluster die nog in de node aanwezig is. Zodat je een nieuwe joinKey van de nieuwe kubernetes cluster kan kopieren.**
  
## Bronnenlijst
  
 In elke documentatie file heb ik altijd verwezen wat mijn bronnen waren. Maar ik wil in deze readme een paar links geven die de volledige set up die ik heb opgezet hebben gemaakt en die heel handig waren voor mijn onderzoek.

- [Lucas Käldström](https://github.com/luxas) (dit is een kubernetes on arm genie die ik vaak ben tegengekomen tijdens mijn research,  bezoek zeker zijn github als je ergens vast zit)
    - [ Workshop ](https://github.com/luxas/kubeadm-workshop)om kubernetes cluster op te zetten op raspberry pi's met veel extra's die ik niet heb toegepast.
    
- [Kubecloud](https://kubecloud.io/)  (Een paar scandinaviërs hebben als thesis kubernetes op raspberry pi's geschreven en hierover een site gebouwd met vele tutorials)
      - [Kubernetes on arm](https://kubecloud.io/setup-a-kubernetes-1-9-0-raspberry-pi-cluster-on-raspbian-using-kubeadm-f8b3b85bc2d1)
