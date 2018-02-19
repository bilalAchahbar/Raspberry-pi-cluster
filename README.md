# Raspberry pi basic image set-up 

## Beschrijving
Dit is een readme van de basic image die werd geconfigureerd voor xplore group. Deze image heeft een Raspian stretch lite besturingsysteem en werd geconfigureerd met de nodige programma’s en de nodige configuraties voor een basic omgeving voor een kubernetes omgeving. Met als doel deze image te clonen en te gebruiken op elke kubernetes node, master 

## Basic credentials
Wanneer je de stretch lite OS download zijn dit de basic credentials.
**Let op standaard toetsenbord is qwerty**
- Gebruikersnaam: ip
- Wachwoord: raspberry

Voor dit project heb ik de gebruikersnaam , wachtwoord en hostname veranderd.  In deze readme zal ik voor security redenen deze naamgeving gebruiken maar deze gebruikers en hostnames bestaan niet dus kopieer deze niet over gebruik je eigen credentials wanneer je deze naamgeving tegenkomt.
 - Gebruikersnaam: Gebruiker
 - Wachtwoord: supersecretpassword
 - hostname: Hostname

## Prerequisites
-	Te installeren software op host machine
   [Raspberry download page](https://www.raspberrypi.org/downloads/  )
   [Etcher om de image te burnen](https://etcher.io/)
   [Putty voor een ssh verbinding vanuit windows](https://www.putty.org/)
   [Win32diskimager voor de image te creëren](https://sourceforge.net/projects/win32diskimager/)

-  Bash scripts die gebruikt zijn voor het automatiseren van bepaalde instellingen.
   `init.sh`
    `xplore`
    `update`
#### Keuze image
Ik heb hier gekozen voor een Raspberri pi stretch lite .Tijdens het schrijven van deze README is dit nog de Raspberry pi stretch lite dit kan in de toekomst veranderen maar er zal steeds een lite versie bestaan van de nieuwe update van Rasbian.
De reden dat ik de lite versie heb gebruikt is omdat dit de ideale os is voor een server omgeving. Bij de gewone Rasbian (met GUI) zijn er te veel utilities die we zowiezo niet nodig hebben (Deze programma's zijn perfect wanneer je een raspberri pi gebruikt voor andere doeleinden zoals leren programmeren of   waar je een grafische interface voor nodig hebt) . Ookal kan je in de Rasbian image opstarten in command line is de lite versie veel kleiner. Al deze benodigdheden die we niet nodig hebben zijn al weggehaald door Raspberry zelf in een mooie gui loze omgeving: lite versie van de huidige Rasbian versie.

#### SD kaart opzetten voor eerste startup

Voor de setup heb je de Rasbian stretch lite nodig die je vind in de downloads pagina van raspberry. Om deze rasbian stretch lite image te burnen op een sd kaart gebruik je etcher. Dit is een programma dat in Linux , macOS en windows kan draaien. Je selecteert je image en je sd kaart en etcher zal al het werk verichten van flashen tot burnen en unmounten van je sd kaart. Wanneer je via een windows host machine werkt en geen linux of mac kan je putty gebruiken om te connecteren via ssh. Voor het burnen van een gepersonaliseerde image voor xplore group gebruikte ik het programma win32diskimager(later hierover meer).

#### Init scripts
Er is een bash script  `init.sh`voorzien die de nodige updates , installs en configuraties zal uitvoeren om je image klaar te maken voor ssh , docker , kubeadm , en alle configuraties voor een kubernetes image. Voer dit script uit nadat je raspberri pi  is opgestart zodat al je configuraties ingesteld zijn voordat je kan beginnen. 
Het 2de script `xplore`is een script met als doel een extra veiligheid in te stellen door passwoord authenticatie uit te schakelen na een ssh verbinding. Later word dit in detail besproken. 
De `update` script is een klein script dat je systeem zal updaten. Om niet steeds de 3 commando's (update , upgrade , dist-upgrade) uit te voeren kan je dit met 1 bashscript rechtstreeks uitvoeren. Deze updates worden in de init script ook uitgevoerd maar voor veiligheidsredenen is het van groot belang om steeds jouw OS up to date te houden. 
#### Configuratie menu

In de raspberry linux distribution is er een configuratie menu waar je bepaalde instellingen in een mooie interface kan aanpassen. Deze is handig om bvb je hostname , keyboard instellingen etc snel aant te passen.
Je kan aan deze menu opvragen door volgende commando in te geven `sudo raspi-config`
We zullen alvast 2 aanpassingen doen in het menu 
- Veranderen van keyboard layout
   - Localisation options
   - Change keyboard Layout
- Veranderen van hostname
    - Network options
    - Change hostname
    - *Na een reboot zal je hostname pas aangepast worden*.

#### Gebruikersnaam , wachtwoord intellen

Omdat je in je basic image al een gebruikernaam , wachtwoord  ingesteld wilt hebben. Kan je de standaard naamgeving voor deze instelling als volgt veranderen.
1.	Om dit te doen activeer je de root gebruiker.Dat doe je door het commando `sudo passwd root` in te geven. Dit is nodig omdat je ingelogd bent in de pi user en je in linux je eigen naam niet kan veranderen als je ingelogd bent.
2.	Volg vervolgens de instructies op het scherm om een wachtwoord toe te kennen aan de root gebruiker **vergeet dit wachtwoord niet**.
3.	Nadat je alles succesvol hebt uitgevoerd ga je uitloggen uit de gebruiker pi dit doe je met de commando `logout`.
4.	Je logt terug in als de gebruiker root door de credentials gebruikersnaam “root” en het wachtwoord die je net hebt ingesteld in te geven. 
5.	Met de commando `usermod -l Gebruiker pi` zal je een nieuwe naam geven aan de pi user. (Gebruiker is mijn eigen naamgeving voor de nieuwe gebruiker. Pas dit aan aan jouw eigen naamgeving)
6.	In linux voldoet het niet om de naam van de gebruiker alleen te veranderen je zal de naam van de home directory ook moeten aanpassen. 
7.	Dit doe je met de commando `usermod -m -d /home/Gebruiker Gebruiker`. 

Nu kan je inloggen met de nieuwe gebruikersnaam. Weet dat je nog steeds de default wachtwoord raspberry gebruikt. 
- Deze pas je aan door de commando `passwd` toe te passen (dit kan wel als je ingelogd bent dus log gerust in met je nieuwe gebruikersnaam en pas dit binnen je login sessie aan) en de instructies op het scherm te volgen.
- Kijk **ZEKER** na of je nieuwe gebruiker nog steeds administrator rechten heeft door een sudo commando uit te voeren.

##### Sudo rechten toekennen
In Linux word elke user dat je toegevoegd aan de sudo groep, een sudo user en krijgt dus alle sudo rechten
1. Nieuwe user toevoegen aan sudo group
   - `sudo adduser Gebruiker sudo`
2. Bestaande gebruiker aanpassen
   - `Usermod -aG sudo Gebruiker`
  
#### SSH verbinding
Om de ssh service automatisch op te starting tijdens de boot voer je volgende commando uit. Deze zal een link maken in de boot folder naar de ```/etc/init.d/servicenaam```.Zo hoef je niet elke keer handmatig de service op te starten. (Deze instelling word ingesteld in het `ìnit.sh`script).
   - `sudo update-rc.d ssh defaults`

   
Als je ssh verbinding is opgestart kan je proberen verbinden vanuit je host naar de raspberry pi. Om nu SSH keys te gebruiken vanuit linux , windows of macOS zal je volgende stappen moeten volgen. Zie zeker dat je de `init.sh`script hebt uitgevoerd in het begin om de mappen en bestanden die nodig zijn voor de ssh keys op te slaan op je raspberry pi aan te maken.

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
![Putty keygen](/images/PuttyKeygen.img)
De bovenstaande key die je in het textvak kunt zien moet je kopieren en plakken in de authorized_keys file van je raspberry pi **LET OP DE SCROLBAR, KOPIEER ZEKER ALLES MEE**. Hiervoor ga je in putty verbinden (TYP DIT NIET OVER KOPIEER) met de raspberry pi om naar volgende bestand te gaan `~/.ssh/authorized_keys`. Dit bestand kan al andere keys bevatten van andere pc’s je plakt hierin de publiek key van jouw pc op een nieuwe lijn(in Putty kan je plakken vanuit je  windows klembord met de shortkey *SHIFT+INSERT*). Sla het bestand ~/.ssh/authorized_keys op en sluit de editor.

###### **Verbinden met de raspberry vanuit windows host.**

Wanneer je nu wilt verbinden met de Raspberry pi vanuit je windows host ga je de private key meegeven in Putty dit doe je door in Putty het volgende in te stellen. Bij opstart van Putty kies je in het linkerscherm voor -->SSH-->Auth daar zie je de Browse knop en  moet je de private key meegeven  die je daarnet in de Putty Key Generator hebt opgeslagen(niet de key die je hebt gekopieerd in ~/.ssh/authorized_keys file maar de key die je hebt opgeslagen in de keygenerator met de kop "Save private key" .
![Putty geef private key mee](/images/PuttySshPrivatekey.img)
Wanneer je nu verbind met je raspberry zal je niet gevraagd worden om het wachtwoord in te geven want hij bevestig jouw machine door de ssh key. Je kan zelf de default gebruikersnaam instellen in putty zodat hij je ook niet zal vragen achter jouw gebruikersnaam. Door in het tabblad Connection--> Date de auto-login username in te stellen. Zo zal je bij je volgende sessie direct verbonden zijn met je raspberry pi. Vergeet zeker niet om deze instellingen in putty  op te slaan zodat je niet steeds de keys en de default gebruikersnaam moet meegeven.

#### Extra beveiliging
##### Wachtwoord uitschakelen na SSH verbinding
Om je beveiliging te verbeteren ga je het wachtwoord uitschakelen nadat je verbonden bent met je ssh zodat enkel de pc’s die verbonden zijn met de ssh key kunnen verbinden. Er zijn hiervoor 3 lijnen in het configuratie bestand dat je hiervoor moet aanpassen.Sla zeker de veranderingen op. Restart de ssh service nadat je het bestand hebt opgeslagen zodat de veranderingen toegepast worden.
Config file : `/etc/ssh/sshd_config`
-	ChallengeResponseAuthentication no
-	PasswordAuthentication no
-	UsePAM no

###### **Root login uitschakelen via ssh**
Als extra beveiliging is het zeker van belang dat  je niet kan inloggen met root in je ssh. Deze instelling staat default uit. Wanneer je toch wilt instellen dat de je wel met de root credentials kunt inloggen via ssh  (wat niet aangeraden is) moet je de lijn PermitRootLogin veranderen naar yes. Dan zal je met root kunnen inloggen. Aangezien deze lijn niet in de default configuratie zit word er dit default uitgeschakeld.
     - De configuratie gebeurt in de config file van ssh
    - `/etc/ssh/sshd_config`
###### **Automatiseren**

Om dit nu telkens handmatig te veranderen nadat je bent ingelogd is wat veel werk daarom is er een script voorzien dat dit voor jou gaat doen. In de home folder zit er een bash script `xplore`. Dit bash script zal de 3 lijnen die  nodig zijn voor het wachtwoord uit te schakelen voor zijn werk nemen. Het heeft 2 parameters genaamd *lock* en *unlock*. Lock zal de configuratie gegevens veranderen zodat je wachtwoord wordt uitgeschakeld. Je kan deze terugzetten naar default instellingen door de parameter unlock mee te geven. Zie wel dat je deze bash script met sudo runt aangezien je bezig bent in de /etc/ folder en het de service ssh opnieuw opstart.  



##### Wees altijd up-to-date
Wanneer je er een gewoonte van maakt om je raspberry op een regelmatige basis te updaten zorg je er ook voor dat je de nodige beveiliging fixes van linux meekrijgt. Voor linux zijn hiervoor 3 commando’s voorzien.
-	Sudo apt-get update
-	Sudo apt-get upgrade
-	Sudo apt-get dis-upgrade

Omdat deze 3 commando’s op een regelmatige basis moeten worden uitgevoerd is er hiervoor een bash script `update` voorzien in de home folder. Dit script bevat de 3 commando’s om je systeem up te daten en kan op een latere tijdstip altijd worden aangevuld of worden aangepast om het automatiseren van updates te vervolledigen.

#### Programma's die geinstalleerd worden op de basic image
In het `init.sh`script werden bepaalde programma's geinstalleerd om een basic image te creeren voor je kubernetes image. Zodat je enkel de image moet branden op een sd kaart en direct vertrokken bent om een nieuwe node in te stellen.
de programma's die werden geinstalleerd zijn
- VI en nano zijn al geinstalleerd maar ik vind vim iets makkelijker om mee te werken dus heb ik vim  geinstalleerd in het `init.sh`script. 
-	Docker 
    - installeren 
    - toevoegen aan groep via usermod
-	Swap uitschakelen 
    -	De reden waarom we swap uitschakelen is omdat we kubernetes gaan gebruiken en we er willen voor zorgen dat we de volledige geheugen gaan gebruiken. Maar wanneer het swap geheugen nog actief is zal dit  voor problemen zorgen waardoor het nodig is swap uit te schakelen in een linux omgeving
-	Control groups of Cgroups 
     - Cgroups zorgen voor het managen van resources zoals CPU  , system memory(RAM) , netwerk bandwith of een combinatie   van deze resources.
        - Cgroups in kubernetes 
        - Met Cgroups kan je instellen hoeveel cpu en hoeveel Ram geheugen elke container/ node nodig ga hebben. Hiervoor moet je dit wel aanzetten in het boot bestand
-	Kubernetes
     - Aangezien kubeadm op elke node word geinstalleerd is het handig dat dit al is gebeurt in de basic os
     - Het initialiseren van de master en de nodes gaan we later instellen want dit gebeurt nadat je de basic image hebt opgestart zodat je onderscheid kan maken van een master en van een node
     
#### Image clonen / back-uppen

Via het programma “Win32 Disk imager” (zie “te installeren software”) kan je de OS waarmee je nu alle instellingen hebt ingesteld clonen naar een image. Zodat je deze image met jouw instellingen altijd bij de hand hebt voor een back-up of om een nieuwe kubernetes node toe te voegen. 
Als je het programma opent ga je in het zoekveld een pad en naam geven aan de image die je wilt maken (De eerste keer zal hij zeggen dat deze image niet bestaat en gaat hij zelf de image aanmaken) zorg er zeker voor dat de schijfletter rechtsboven klopt met de schijfletter van de sd kaart. Klik vervolgens op “Lezen” en het programma zal je sd kaart clonen naar een image bestand.
![Image clonen](/images/Win32DiskImager.img)

#### Extra veiligheidsopties voor betere security (optioneel)
 Deze instellingen heb ik niet in mijn basic image ingesteld omdat ik een image zal maken die voor zowel de node als de master dezelfde gaat zijn. De veiligheidsopties moeten nie op elke node worden geinstalleerd. Voor te bekijken hoe je deze instellingen toepast bekijk je de [beveiligingsopties pagina](https://www.raspberrypi.org/documentation/configuration/security.md) in de raspberry documentatie.



###### **Ervoor zorgen dat sudo steeds een wachtwoord vraagt**
Wanneer je sudo gebruikt ben je een superuser en default heb je hiervoor geen wachtwoord voor nodig. Dit is voor normale gebruik en gemak geen probleem. Maar dit word een probleem wanneer een onbevoegd persoon toegang krijgt tot jouw systeem.  Om dit te vermijden kan je ervoor zorgen dat je bij elke keer dat je sudo gaat intypen er een wachtwoord word aangevraagd. 
###### **Firewall installeren**
Dit zit niet in de basic image omdat een firewall niet voor elke node en voor de master hetzelfde moet zijn. De firewall moet worden toegepast om een globale methode. 

###### **Installeren van fail2ban**
Dit is een optie nadat je de firewall hebt ingesteld. Omdat je u Raspberry Pi gebruikt als een server en deze toegankelijk is voor mensen die ermee verbinden met ssh hebben gebruikers toegang aan de Raspberry Pi. Fail2ban is een scanner dat de log files gaat bekijken en nakijken op ongewone activiteiten. Het zal aangeven wanneer er bijvoorbeeld meerdere brute force pogingen hebben plaats gevonden  om in te loggen in je pi. En heeft zelf de mogelijkheid om elke firewall die is ingesteld in te stellen dat bepaalde ip-addressen niet meer mogen inloggen. Dit is een automatische tool dat word aangeboden zodat de gebruiker niet steeds de log bestanden moet bekijken voor ongewone aanmeldingen. Het grijpt ook in na een ongewone situatie zodat jij dit zelf niet manueel meer hoeft te doen.



#### Bronnenlijst

-	Installeren van raspberry os en clonen van os in windows.
https://www.makeuseof.com/tag/install-operating-system-raspberry-pi/
https://www.raspberrypi.org/magpi/pi-sd-etcher/

-	SSG keys instellen via putty en putty key gen.
https://devops.profitbricks.com/tutorials/use-ssh-keys-with-putty-on-windows/
https://www.raspberrypi.org/forums/viewtopic.php?f=36&t=181846
https://www.ssh.com/ssh/putty/windows/puttygen
-	Wachtwoord uitschakelen na ssh verbinding.
https://www.cyberciti.biz/faq/how-to-disable-ssh-password-login-on-linux/
http://support.hostgator.com/articles/specialized-help/technical/how-to-disable-password-authentication-for-ssh
https://stackoverflow.com/questions/20898384/ssh-disable-password-authentication
https://lani78.com/2008/08/08/generate-a-ssh-key-and-disable-password-authentication-on-ubuntu-server/
-	Initialisatie script.
https://kubecloud.io/setup-a-kubernetes-1-9-0-raspberry-pi-cluster-on-raspbian-using-kubeadm-f8b3b85bc2d1
https://stackoverflow.com/questions/21612980/why-is-usr-bin-env-bash-superior-to-bin-bash

-	Beveiliging van de raspberry pi (extra veiligheidsopties).
https://www.raspberrypi.org/documentation/configuration/security.md





