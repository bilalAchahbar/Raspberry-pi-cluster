# Virtuele Raspberry pi 


### Beschrijving
Wanneer je met raspberry pi's werkt wil je voor testing doeleinden niet het risico nemen om je pi of je cluster in gevaar te brengen.Een oplossing om dit te voorkomen is om je raspberry pi virtueel te laten draaien in een emulator. De reden waarom dit ideaal is omdat het op elke OS dat QEMU aankan perfect zal werken , geen hardware setup nodig heeft, snellere feedback krijgt tegenover hardware , en het belangrijkste je kan alles uittesten en opzetten zonder het gevaar je hardware aan te tasten. 

### Welke virtuele omgeving ?
Bij een normale virtualisatie van een linux omgeving is Virtualbox of Vmware ideaal omwille van hun grafische en simpele interface. Maar deze virtualiseren geen ARM processors en zijn dus voor het virtualizeren van een raspberry image niet geschikt.Hiervoor moeten we opzoek naar een virtuele omgeving dat wel geschikt is voor een ARM omgeving en al snel kom je op QEMU(Quick EMUlator) dat een raspberry pi kan virtualizeren..

### Install

Software: 
- [Qemu](https://www.qemu.org/download/)
- [Raspberry-pi download page ](https://www.raspberrypi.org/downloads/raspbian/)
- [Linux kernel voor ARM](https://drive.google.com/file/d/0Bxu8unle-0U0VzR0NzdYNDZ0N0k/view)


1. Eerst zal je een QEMU moeten installeren , om specifieker te zijn een qemu-system-arm. Op de download pagina van qemu zal je zien dat qemu installeerbaar is op de 3 OS'en (windows , linux en mac). 
     1.1 Je moet de installer **NIET**  runnen maar unzippen met een programma als 7zip of winrar
2. Om je raspberri pi te laten draaien zal je een rasbian image nodig hebben. Deze staan volledig ter beschikking op de officiele website van Raspberri pi. (In deze Documentatie zal ik werken met een eigen aangemaakte image **"RasbianCluster.img"**. Zorg er voor dat wanneer je de naam van de image moet meegeven in een commando dat je er ZEKER op let dat je de naamgeving van je eigen image toepast.)
3. Omdat de standaard RPI kernel niet out of the box zit in qemu gaan we een custom kernel downloaden die we in de source map plaatsen van qemu.
4. Het is heel belangrijk om de juiste naamgeving van de Rasbian image en de kernel te weten. Deze zal je later moeten meegeeven in parameters.



### Resizen 

Voor gemak redenen zullen we de image resizen zodat je meer geheugen tot je beschikking hebt dit kan je doen in windows cmd.

- Navigeer naar je qemu folder met de cd commando
- Gebruik volgende commando om de image te resizen
- `qemu-img.exe resize RasbianCluster.img +10G`
- De command runnen zal een warning geven maar wanneer de melding `Image resized`opkomt is het gelukt

### Opstarten
De reden waarom virtualbox and VMware zo populair zijn is door hun simpele en mooie grafische interface. Omdat je in een emulator werkt is dit niet zo een mooie en grafische interface. We moeten via command line het systeem opstarten. Aangezien dit een grote commandline is met veel parameters gaan we dit scripten in een bat file. Alle parameters worden keurig uitgeled zodat je weet welke gegevens je kan aanpassen aan je eigen setup en wat we instellen.



- Open notepad++ of een text editor naar keuze
- En plak er de volgende commando in **_LET OP_** hier gebruik ik mijn eigen image. Als je de standaard image gebruikt of je gebruikt ook een eigen image zorg er dan voor dat je de naamgeving aanpast !
- `qemu-system-arm.exe -kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw init=/bin/bash" -hda RasbianCluster.img`
-->`qemu-system-arm.exe`Dit is de exe file die je systeem zal opstarten
--> `-kernel`Hier geef je de kernel mee die je hebt gedownload en opgeslagen in je source folder
--> `-cpu`Setten van de CPU type
--> `-m` Hier geef je het RAM geheugen van de raspberri pi mee*
--> `-M` Dit set de machine die we gaan virtualizeren , "versatilepb" is de ARM versatile/PB machine
--> `-no-reboot` Geeft mee dat je qemu exit zal uitvoeren in plaats van te rebooten
--> `-serial` Redirect de machine's virtuele seriele port naar onze host's sdio
--> `-append` We geven de boot argumenten mee in de kernel, we gaan meegeven waar het de root filesysteem kan vinden en welke type het is
--> de "init=/bin/sh" parameter geeft aan dat je het zal opstarten in een minimum shell omgeving zal opstarten. dit ga je uitvoeren tijdens de eerste startup zodat je bepaalde config files kan aanpassen om de raspberry pi image omgeving goed in te stellen.
--> `-hda` Hier geven de we image file mee. **Let goed op de naamgeving**

  *Je zal opmerken dat de -m parameter maar 256 MB aan ram zal doorgeven. Dit is heel weinig maar QEMU kan niet meer aan , als je probeert om meer ram te geven geeft dit fouten ([ Dit is een QEMU bug](https://bugs.launchpad.net/ubuntu/+source/rootstock/+bug/570588))
- Om af te sluiten sla je dit bestandje op in de QEMU folder met de bat extension .bat zodat windows het scriptje kan runnen
   _Zorg er zeker voor in je text editor dat je "All files" optie kiest bij opslaan als dat hij zeker geen .txt bestandje aanmaakt_

  ---->Run je bat scriptje en laat de emulator zijn werk doen.
  ---->Laat dit even runnen.
   
   
### Bijna klaar...
Als je emulator is opgestart zal deze opstarten in een command prompt om in jouw img file te kunnen inloggen zal je nog kleine aanpassingen moeten uitvoeren
**OPGEPAST QWERTY TOETSTENBORD**.
- We gaan naar de file ld.so.preload met volgende commando in de text editor nano
   - `nano /etc/ld.so.preload`
    - In de text editor zullen we 1 lijn code zien en die zullen we commenten met een # ervoor te plaatsen
   - Sla deze aanpassinge op
- Vervolgens zullen we een bestand aanmaken om een paar regels toe te passen
    -   `nano /etc/udev/rules.d/90-qemu.rules` zal nano openen met de juiste naamgeving
    -   Voeg volgende 3 lijnen code toe aan dit bestand
        -   `KERNEL=="sda", SYMLINK+="mmcblk0"`
        - `KERNEL=="sda?", SYMLINK+="mmcblk0p%n"`
        - `KERNEL=="sda2", SYMLINK+="root"`

Comment de 2 PUID's in de /etc/fstab anders zal je steeds booten in emergency mode
- `nano /etc/fstab`
- Je zal 3 lijnen zien waarvan de laatste 2 beginnen met `PARTUUID.....`
- Comment de laatste 2 lijnen en sla de file op 
-----> exit de emulator met de commando `exit`

##### Klaar voor een opstart
Ga naar je bat file en verwijder in de append parameter ` init=/bin/bash` **inclusief de spatie voor init**.
Dit is nodig om op te starten in de image file en dus niet in de minimum shell omgeving.
sla de bat file op en de volledige configuratie is voldaan.Als je nu de bat file runt kan je de emulator gebruiken.


  
### Conclusie
De bedoeling van deze setup was om mijn Raspberry pi cluster te virtualizeren .Zodat ik een testomgeving zou hebben waar ik aanpassingen kan uitvoeren zonder de hardware aan te tasten. Nadat ik alles heb opgestart volgends de normen ben ik tot volgende conclusie gekomen. De emulator start enkel op met 256 mb ram geheugen [zie bug pagina](https://bugs.launchpad.net/ubuntu/+source/rootstock/+bug/570588). Omdat het niet mogelijk is om extra geheugen te geven aan de ram geheugen van de ARM versatile/PB machine de emulator kan niet meer aan.
Als je toch meer geheugen toewijst gaat het of weigeren om te laden of u -m parameter(dat de grootte van het ram geheugen) negeren en gwn 256 mb ram geheugen toewijzen.

--> Een oplossing voor dit probeem is om te werken met een swap file 
In linux kan je meer geheugen toewijzen door een deel van je geheugen te gebruiken als RAM dat heet een swap geheugen. Dit is niet de ideale manier van werken omdat dit een hele boel vertraagd. Maar tot nu toe is dit de enige manier dat werkt om te werken met een grotere ram geheugen. 

Hoe ga je te werk
- Standaard is de swap grootte ingesteld op 100 Mb. Dit is natuurlijk niet voldoende voor onze setup omdat onze fysieke raspberry pi een ram geheugen heeft van 1GB gaan we dit toekennen als swap geheugen. 
- Met de commando `free -m` kan je zien dat de swap grootte nog niet is ingesteld
- Open de config files voor de swap geheugen van de raspberri pi
  - `sudo vim /etc/dphys-swapfile`
  - Verander de waarde van `CONF_SWAPSIZE=100` van 100 naar 1024 en sla het bestand op
- Nu de waarde is veranderd moeten we de swap service herstarten
  - `sudo /etc/init.d/dphys-swapfile restart`
- Als je nu de commando `free -m`runt kan je zien dat er nu een swap geheugen word gebruikt van 1GB 


Maar dit is niet haalbaar als je met kubernetes wilt werken. Kubernetes heeft het voordeel om 100 % van de beschikbare grootte te gebruiken en dus geen lags te gebruiken die je krijgt als je met een swap geheugen gaat werken. Voor performante redenen is het (op het moment dat ik deze documentatie schrijf hopelijk verbeterd dit in de toekomst) niet mogelijk om een Raspberry pi cluster in een emulator te plaatsen.




### Bronnenlijst

- https://www.pcsteps.com/1199-raspberry-pi-emulation-for-windows-qemu/
- https://blogs.msdn.microsoft.com/iliast/2016/11/10/how-to-emulate-raspberry-pi/
- https://serverfault.com/questions/881517/why-disable-swap-on-kubernetes

   

