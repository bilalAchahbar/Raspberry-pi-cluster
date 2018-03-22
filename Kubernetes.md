# Setup kubernetes cluster

## Uitleg bepaalde concepten
Wat zijn

- PODS: Dit is een groep van 1 of meerdere containers dat een image en verdere libraries / dependencies zal runnen . De containers in een pod zijn meer gekoppeld met elkaar dan in tegenstelling tot bij een docker , etc... ze worden gemanaged en gedeployed als één unit.
- NODES: dit is een worker in de kubernetes cluster 
- MASTER: dat is de baas die gaat zeggen tegen de nodes wie wat moet draaien. De master kan ook een node zijn.
- NETWERK: kubernetes werkt met netwerk plugins zodat je een netwerklaag kunt gebruiken opdat je pods met elkaar zullen kunenn verbinden. [Hier](https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-achieve-this/) Kan je alle uitleg vinden en de verschillende plugins die je kan toepassen

## Voorwaarden
Basic image waar kubernetes en docker al is geinstalleerd. 
*Zie Readme.md*
## Let's begin
Allereerst zet je de master en de nodes klaar

- Zorg ervoor dat de ip addressen static zijn aangezien we niet willen dat de dhcp ons nieuwe ip addressen geeft eenmaal de cluster in een server rack zit.
     - Hiervoor moeten we de file `/etc/dhcpcd.conf`aanpassen
     - Als je met je cursor tot het einde van de file navigeert , zal je volgende lijnen te zien krijgen
     
            - "#Example static ip configuration"
            
      - Daar na zie je een hoop configuraties voor je eth0 in te stellen. verwijder de '#' comment  character om  deze lijnen te activeren  en verander de addressen naar jouw static ip.
```
    interface eth0
    static ip_address=xx.xx.xx.xx/24
    static routers=xx.xx.xx.xx
    static domain_name_servers=xx.xx.xx.xx
```

- Hostnames veranderen
     - Hiervoor staat er al een script klaar `changeHostname.sh` 
     - Dit script zal je systeem rebooten **Let op als je opnieuw ssh'ed dat je naar de nieuwe ip address gaat**


### kubeMaster

Omdat de basic image bedoeld is om basic te zijn zodat je hiermee zowel een node als een master mee kunt opstarten met bovenstaande aanpassingen mis je nog 1 file om de kubernetes master te initialiseren.

De file die je moet kopiëren naar de master is `kubeConfig.yaml` Dit zijn extra configuraties die bedoeld zijn om een lagere downtime van een pod en node te garanderen. 
```
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
controllerManagerExtraArgs:
        pod-eviction-timeout: 10s
        node-monitor-grace-period: 10s
node-monitor-period: 2s
```

Deze file staat in de Github folder en kan je dus scp naar de kubemaster.
En kan je kopieren met de volgende commando:
- `scp kubeConfig.yaml xplore@10.1.88.203:/home/xplore`

#### INIT
```
Initialiseren van kubernetes master
```
- `kubeadm init --config kubeConfig.yaml`
  - Wanneer je deze commando runt gaat de kubernetes van alles uitvoeren. 
  - Dit kan een tijdje duren aangezien hij images moet pullen om dit te laten werken. Eenmaal het gedaan is krijg je een scherm (zie onderstaande foto) met 3 commando's en een joinkey.
  - **BELANGRIJK**: sla de join key zeker goed op zodat wanneer een nieuwe node of een node gereset word dat je deze makkelijk kan toevoegen. omdat je jezelf beter niet moet vertrouwen kan je deze key beter in een text documentje zetten zodat je deze altijd kan ophalen. Met de commando `echo KEYDIEJEOPHETSCHERMZIET >> joinKey.txt`
- Voer daarna de 3 commando's uit om de map aan te maken in je home folder , de config file te kopieeren en deze rechten te geven. 
![kuadm init](/images/kubeMasterOutput.JPG)

   **Probleemstelling1**
Wanneer je deze stappen uitvoert en direct na de initialisatie de commando `kubectl get nodes`uitvoert zorg er dan ZEKER voor dat je hierbij geen sudo gebruikt. sudo op zich moet je al zo min mogelijk gebruiken tenzij hij bij een van de vorige stappen zegt dat je geen toegang krijgt. anders gebruik je best zo min mogelijk sudo. Het is me dus voorgevallen dat ik exact dezelfde stappen uitvoer (kubeadm init , 3 commmando's , joinkey opgeslagen) en daarna voerde ik `sudo kubectl get nodes`uit. Dit gaf problemen omdat de gebruiker (die niet root is) verward is waar de config file nu eigenlijk gelocaliseerd is. Wanneer je sudo kubectl get nodes uitvoert dan logt sudo in en gaat hij de commando `kubectl get nodes`uitvoeren in de sudo omgeving. 

  Stel dat je alsnog de commando wilt uitvoeren met sudo om een of andere reden. Zorg er dan voor dat de sudo gebruiker weet waar hij de configuratie file moet gaan halen. Dit doe je door in te loggen in de sudo gebruiker en daar deze commando in te voeren `export KUBECONFIG=/etc/kubernetes/admin.conf` dan zal elke keer je sudo gebruikt om de nodes of de pods te gaan zien of te verwijderen de sudo gebruiker zeker aan de configuratie bestand aan kan
  
#### Pod netwerk instellen.
Er zijn heel veel verschillende netwerk plugins voor kubernetes . Voor mijn setup gebruik ik de weave network plugin.

  - Zonder een netwerk dat ervoor gaat zorgen dat de pods en de nodes met elkaar kunnen verbinden dan ga je nooit kunnen verbinden met elkaar. De commando is `kubectl apply -f https://git.io/weave-kube-1.6`
  
Oké nu is de master geconfigureerd en kan je beginnen met nodes toevoegen.
*Een tip voer volgende commando uit `watch kubectl get nodes`deze gaat de commando get nodes om de x aantal seconden blijven uitvoeren en zo kan je op je master terminal zien dat er nieuwe nodes zijn toegevoegd en runnen.*

![weave network](/images/weave-network.png)

```
Initialiseren van de node
```

Als je de basic image hebt gebruikt zijn alle programma's al geinstalleerd voor je node. Het enige dat je moet doen is de node toe te voegen aan de cluster door middel van de join commando. Deze commando is dus HEEL BELANGRIJK aangezien je telkens je een node wilt toevoegen je deze commando nodig hebt. Zorg er dan ook voor dat je deze join commando met de belangrijke token ergens veilig opslaat. Zodat telkens je een nieuwe node of een node reset je steeds de commando ter beschikking hebt.
 - Als je de master goed hebt geconfigureerd staat daar een file genaamd `joinKey.txt`. 
 - Deze kan je kopieëren naar de node door middel van de `scp`commando , dat kopieert over ssh. 
 - Als je nu naar de node gaat kan je zien dat de joinKey.txt commando in de home folder aanwezig is. 
 - Voer de inhoud van dit text bestandje uit en de node zal worden toegevoegd aan de cluster
 
![cluster](/images/nodeJoin.png)

Als je deze commando invoert krijg je een melding terug "this node has joined the cluster". Als je mijn tip hebt gebruikt voor de master met de watch commando zal je bij elke node die je hebt toegevoegd kunnen zien dat ze worden toegevoegd aan de cluster. GEEN schrik als je ziet dat de status nog op "unready" staat kubernetes heeft nog even tijd nodig om het netwerk in te stellen . Als je na 5 minuten nog steeds unready ziet dan is er wel iets mis en dan moet je gaan debuggen.  

```
Succesvol master aangemaakt en nodes toegevoegd
```

Wanneer je alle stappen succesvol hebt uitgevoerd zou de commando `kubectl get nodes` dit scherm moeten tonen. 
Daar kan je zien welke nodes er zijn toegevoegd en welke de master is. hier kan je ook zien wat de status is van elke node.

Verder kan je met de commando `kubectl get pods --all-namespaces -o wide` alle pods zien die op de kubernetes cluster staat. Wanneer deze allemaal de status "Running" hebben is de basic kubernetes cluster volledig opgebouwd. 

#Dashboard

#### Probleemstelling2
Wanneer je dus de pods up and running zijn en je deze kan zien met de commando `sudo kubectl get pods -o wide` ga je ook zien dat de 3 pods verdeeld worden over de nodes die beschikbaar zijn. 
Probleem stelling is nu dat wanneer je 1 node zal uitschakelen hij wel de pods zal verdelen naar de andere node maar hij hiervoor 4 tot 5 minuten voor nodig heeft. Dat is niet echt productie gericht in een raspberry pi cluster.

#### Oplossing2
De kube-controller-manager heeft een parameter genaamd pod-eviction-timeout. Deze staat standaard op 5 minuten en moet veranderd worden naar een zo min mogelijke overgangstijd. Aangezien we alles zoveel mogelijk willen automatiseren gaan we de kubeadm initialiseren met een configuratie file. (Dit is de file dat je hebt gebruikt om je kubernetes master te initialiseren)
Die het volgende bevat 

```
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
controllerManagerExtraArgs:
  pod-eviction-timeout: 10s
  node-monitor-grace-period: 10s.
  node-monitor-period: 2s
```

de pod-eviction-timeout gaat wachten op de node om de controller manager up te daten. , de node grace period geeft de node de tijd om unresponsive te zijn. de node monitor period is de tijd dat de node de status gaat syncing met de node controller. 

Als je de kubeadm initialiseert met deze configuratiefile met de commando `sudo kubeadm init --config naamConfFile.yaml` zal je de kubernetes cluster instellen met de juiste configuraties voor zo high available mogelijke uitkomst. Nu zal kubernetes binnen de 10 seconden reageren wanneer een node uitvalt en dat is meer high available dan de default 5 minuten. 


# Wat nog instellen 
- Dashboard
- Wat gebeurt er als er een pod of nog erger een node uitvalt. 
  - Hier heb ik al een aardige goede begin maar moet en kan nog beter 
- Dit tonen via een dashboard.
   - Dit zou mooi zijn op een presentatie maar is geen vereiste
- Etcd , Ingris concepten bekijken en kijken hoe toe te passen
- Wat met beveiliging over de nodes (ook mss aanpassingen aanbrengen aan pi)
- chaos monkeys of zoals ze dit in de kubernetes wereld noemen  [ Kube monkey](https://github.com/asobti/kube-monkey).

### Debugging commando's
#### Logs

- `kubectl describe pods(deze geeft weer wat de pods allemaal doen)`
-  `kubectl get events`
-  `journalctl -u kubelet`
#### Reset
Het kan gebeuren dat je opnieuw wilt beginnen door een fout of iets anders. 
De commando `kubeadm reset` zal de cluster verwijderen en kan je dus opnieuw beginnen. Voer dit uit op de node(s) en op de master. Je kan op de master best ook de .`/kube` folder verwijderen zodat je zeker geen verwarringen krijgt met de nieuwe kubeadm conf file

Om bepaalde instellingen te verwijderen die niet default mee verwijderd worden met de reset commando kan je volgende [Cheatsheet](http://khmel.org/?p=1092) gebruiken.


### Bronnenlijst

https://blog.alexellis.io/kubernetes-in-10-minutes/
https://blog.hypriot.com/post/setup-kubernetes-raspberry-pi-cluster/

raspberry pi cluster , met kubernetes 
Belangrijke bron: 

https://blog.yo61.com/kubernetes-on-a-5-node-raspberry-pi-2-cluster/


volledige kubernetes opzet

https://kubecloud.io/setup-a-kubernetes-1-9-0-raspberry-pi-cluster-on-raspbian-using-kubeadm-f8b3b85bc2d1

De yaml files voor de pods en de service

https://blog.jetstack.io/blog/k8s-getting-started-part3/
