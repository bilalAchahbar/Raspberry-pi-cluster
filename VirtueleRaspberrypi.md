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
2. Om je raspberri pi te laten draaien zal je een rasbian image nodig hebben. Deze staan volledig ter beschikking op de officiele website van Raspberri pi. (In deze Documentatie zal ik werken met een eigen aangemaakte image **"RasbianCluster.img"**. Zorg er voor dat wanneer je de naam van de image moet meegeven in een commando dat je er ZEKER op let dat je de naamgeving van je eigen image toepast.)
3. Omdat de standaard RPI kernel niet out of the box zit in qemu gaan we een custom kernel downloaden die we in de source map plaatsen van qemu.


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
--> `-hda` Hier geven de we image file mee. **Let goed op de naamgeving**

  *Je zal opmerken dat de -m parameter maar 256 MB aan ram zal doorgeven. Dit is heel weinig maar QEMU kan niet meer aan , als je probeert om meer ram te geven geeft dit fouten ([ Dit is een QEMU bug](https://bugs.launchpad.net/ubuntu/+source/rootstock/+bug/570588))
- Om af te sluiten sla je dit bestandje op in de QEMU folder met de bat extension .bat zodat windows het scriptje kan runnen
   _Zorg er zeker voor in je text editor dat je "All files" optie kiest bij opslaan als dat hij zeker geen .txt bestandje aanmaakt_

  ---->Run je bat scriptje en laat de emulator zijn werk doen.
  ---->Laat dit even runnen.
   
   
### Bijna klaar...
Voordat we kunnen beginnen moeten we nog instellingen aanpassen in de etc folder 
**OPGEPAST QWERTY TOETSTENBORD**.
- We gaan naar de 



### Bronnenlijst
- https://blog.agchapman.com/using-qemu-to-emulate-a-raspberry-pi/
- https://www.pcsteps.com/1199-raspberry-pi-emulation-for-windows-qemu/
- 
- 
   

