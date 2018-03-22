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

# Dashboard

Nu de kubernetes cluster up & running is is het handig om toch nog een visuele pagina te hebben van de cluster zodat we de pods , nodes en nog veel meer andere toepassingen visueel kunnen bekijken. 
Om de kubernetes in te stellen gaan we alsvolgt te werk:

- Om de kubernetes te installeren gaan we volgende commando runnen, je kan deze pod zien in de watch kubectl get pods --all-namespaces zien. Wanneer deze pod de status "Running" heeft draait de kubernetes dashboard!!
- kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard-arm.yaml

- Eenmaal de dashboard runned zou je hem liefst nog kunnen zien op je host machine. Dat is niet even gemakkelijk als het klinkt.
  Ik heb hiervoor een aantal dingen uitgetest maar lang nog niet alles want er zijn heel veel mogelijkheden de ene wat veiliger dan de andere. De manier hoe ik het nu doe is door de kubernetes pod te exporteren via een poort dit doe ik door middel van volgende aanpassing
  
  - De kubernetes dashboard word ingesteld met de instelling "ClusterIp" Deze moeten we veranderen naar NodePort.
  - Als je deze commando uitvoert zal je de instellingen van de kubernetes dashboard te zien moeten krijgen
  - `kubectl -n kube-system edit service kubernetes-dashboard`
  - Localiseer de instelling voor de 'ClusterIp' (derde rij vanonder) en verander dit naar 'NodePort'
  - In de instelling -spec-ports-nodePort zie je de poort waar naar je naartoe zal moeten surfen deze kan je aanpassen voor gemaksredenen
  - Met de commando `kubectl -n kube-system get service kubernetes-dashboard` kan je de ip address en de poort ook altijd ophalen
  - **Dit is niet de meest veilige manier om een kubernetes dashboard naar buiten te exporteren**
  - **Er zijn zeker nog andere manieren om dit te doen. Bekijk zeker volgend artikel om de access naar de kubernetes beter te beveiligen**
  - **Hier word heel goed uitgelegd om een kubernetes dashboard op te zetten en zo veilig mogelijk op te zetten**
  - https://blog.heptio.com/on-securing-the-kubernetes-dashboard-16b09b1b7aca
  
- Als je nu vanuit je hostmachine de dashboard kan ophalen zal je een login scherm te zien krijgen. Nu zal je een admin user aanmaken en ik zal ook even toelichten hoe je nieuwe accounts aanmaakt met beperkte restrictions. 

Kubernetes werkt met service accounts die je dan bepaalde roles kunt geven. Zo kan je een server account aanmaken om hem de cluster-admin role te geven. Nadat je dit gedaan hebt is het gewoon een kwestie van de token van de admin op te halen en in te loggen als administrator

 - In kubernetes kan je alles met yaml files doen , ook service acccounts, roles , clusterroles. Maar we gaan hiervoor gewoon gebruik maken van een commando om dit te doen. 
 - Om een serviceaccount aan te maken voeren we deze commando uit `kubectl create serviceaccount administrator`.
 - Nu de serviceaccount is aangemaakt moeten we nog de administrator role aan toekennen die van toepassing is voor de hele namespaces en dat doen we met volgende commando.
 - `kubectl create clusterrolebinding administrator --clusterrole=cluster-admin --serviceaccount=default:administrator`
 - Oké nu er een service account en een role is aangemaakt voor deze service account hoe kunnen we inloggen in het dashboard.
 - We moeten het token van de service account gaan ophalen, en dat doen we met volgende commando
 - `kubectl get secrets` zal je een lijst tonen van secrets van alle service accounts
 - `kubectl describe secret administrator-token-xxx` zal de token te voorschijn tonen voor de administrator.
 - **Dit is een token die je een root toegang geeft voor het dashboard. Zorg er dan voor dat je de token dus opslaat als een root passwoord**
 
Wanneer je nu surft naar het ip address van de master met de poort die je hebt opgehaald, en de token gebruikt van de administrator serviceaccount die je hebt aangemaakt zal je binnenkunen in je kubernetes dashboard.

### Nieuwe gebruikers

Nu heb je 1 token om in te loggen in je dashboard als administrator. Om andere gebruikers toe te laten tot het dashboard doe je hetzelfde als hierboven om een account aan te maken

1. `kubectl create serviceaccount NAAMGEBRUIKER`
2. `kubectl create clusterrolebinding NAAMGEBRUIKER --clusterrole=ROL --serviceaccount=NAMESPACE:NAAMGEBRRUIKER`
3. `kubectl get secrets`
4. `kubectl describe secret administrator-token-xxx`

Als beheerder van je kubernetes cluster wil je natuurlijk niet dat iedereen hetzelfde kan als jou. Je zou graag willen dat de gebruiker die je toegang geeft maar beperkte rechten heeft. De clusterroles die er al default klaar staan zijn alsvolgt:
- cluster-admin
- admin
- edit
- view
Deze clusterroles zijn voldoende voor standaard beperkingen. In kubernetes kan je natuurlijk alles aanpassen en instellen via yaml files. Zelfs nieuwe beperkingen in te stellen dit gaat zo ver als je zelf wilt. Omdat dit aanpasbaar is aan de gebruiker die je zelf nodig hebt , heb ik dit niet verder toegelicht maar in volgende documentatie zal je zeker vinden wat je nodig hebt om dit zelf in te stellen. Beperk je niet enkel op deze tutorials de sky is the limit met google.
- http://blog.kubernetes.io/2017/10/using-rbac-generally-available-18.html
- https://docs.bitnami.com/kubernetes/how-to/configure-rbac-in-your-kubernetes-cluster/



### Debugging commando's

#### status

Om je pods te bekijken of deze aan het draaien zijn of niet en op welke node deze draaien kan je volgende commando gebruiken
- `kubectl get pods --all-namespaces -o wide`
Als je nu eens dieper wilt bekijken wat een pod aan het doen is en waarom deze de image niet pulled kan je volgende commando gebruiken.
- `kubectl descibe pods NAAMVANPOD`

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

https://blog.heptio.com/on-securing-the-kubernetes-dashboard-16b09b1b7aca
https://github.com/luxas/kubeadm-workshop

