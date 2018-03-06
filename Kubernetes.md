# Setup kubernetes cluster

## Uitleg bepaalde concepten
Wat zijn

- PODS: Dit is een groep van 1 of meerdere containers dat een image en verdere libraries / dependencies zal runnen . De containers in een pod zijn meer gekoppeld met elkaar dan in tegenstelling tot bij een docker , etc... ze worden gemanaged en gedeployed als één unit.
- NODES: dit is een worker in de kubernetes cluster 
- MASTER: dat is de baas die gaat zeggen tegen de nodes wie wat moet draaien. De master kan ook een node zijn.
- DEPLOYMENTS: dit is een manier om een staat vast te zetten aan meerdere pods zodat je meerdere pods makkelijker kan managen.
- NETWERK: kubernetes werkt met netwerk plugins zodat je een netwerklaag kunt gebruiken opdat je pods met elkaar zullen kunenn verbinden. [Hier](https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-achieve-this/) Kan je alle uitleg vinden en de verschillende plugins die je kan toepassen
- REPLICATIONCONTROLLER: dit is normaal nodig om ervoor de replica's te managen zodat er altijd wel 1 up and running is.
## Voorwaarden
basic image waar kubernetes en docker al is geinstalleerd
## Let's begin
Allereerst zet je de master en de nodes klaar
- Hostnames veranderen
- ip addressen mogen niet dezelfde zijn

Eenmaal dit veranderd is kunnen we beginnen.
### kubeMaster

```
Initialiseren van kubernetes master
Voor de code van de configfile ZIE oplossing2
```
- `kubeadm init --config CONFIGFILE.yaml`
  - Wanneer je deze commando runt gaat de kubernetes van alles uitvoeren. 
  - Net zoals een vrouw moet je deze gewoon met rust laten en laten doen. Op het einde krijg je ook bevelen die je best opvolgt. (3 commando's uitvoeren en join commando)
  - BELANGRIJK: sla de join key zeker goed op zodat wanneer een nieuwe node of een node gereset word dat je deze makkelijk kan toevoegen. omdat je jezelf beter niet moet vertrouwen kan je deze key beter in een text documentje zetten zodat je deze altijd kan ophalen. Met de commando `echo KEYDIEJEOPHETSCHERMZIET >> key.txt`
- Voer daarna de 3 commando's uit om de map aan te maken in je home folder , de config file te kopieeren en deze rechten te geven. 
![kuadm init](/images/kubeMasterOutput.JPG)

   **Probleemstelling1**
Wanneer je deze stappen uitvoert en direct na de initialisatie de commando `kubectl get nodes`uitvoert zorg er dan ZEKER voor dat je hierbij geen sudo gebruikt. sudo op zich moet je al zo min mogelijk gebruiken tenzij hij bij een van de vorige stappen zegt dat je geen toegang krijgt. anders gebruik je best zo min mogelijk sudo. Het is me dus voorgevallen dat ik exact dezelfde stappen uitvoer (kubeadm init , 3 commmando's , joinkey opgeslagen) en daarna voerde ik `sudo kubectl get nodes`uit. Dit gaf problemen omdat de gebruiker (die niet root is) verward is waar de config file nu eigenlijk gelocaliseerd is. Wanneer je sudo kubectl get nodes uitvoert dan logt sudo in en gaat hij de commando `kubectl get nodes`uitvoeren in de sudo omgeving. 

  Stel dat je alsnog de commando wilt uitvoeren met sudo om een of andere reden. Zorg er dan voor dat de sudo gebruiker weet waar hij de configuratie file moet gaan halen. Dit doe je door in te loggen in de sudo gebruiker en daar deze commando in te voeren `export KUBECONFIG=/etc/kubernetes/admin.conf` dan zal elke keer je sudo gebruikt om de nodes of de pods te gaan zien of te verwijderen de sudo gebruiker zeker aan de configuratie bestand aan kan
- Pod netwerk instellen.
Er zijn heel veel verschillende netwerk plugins voor kubernetes . **Ik heb weaver uitgeprobeerd maar dat gaf nog veel errors**

  - Zonder een netwerk dat ervoor gaat zorgen dat de pods en de nodes met elkaar kunnen verbinden dan ga je nooit kunnen verbinden met elkaar. De commando is `kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"`
  
Oké nu is de master geconfigureerd en kan je beginnen met ndoes toevoegen.
*Een tip voer volgende commando uit `watch kubectl get nodes`deze gaat de commando get nodes om de x aantal seconden blijven uitvoeren en zo kan je op je master terminal zien dat er nieuwe nodes zijn toegevoegd en runnen.*

**WEAVER NETWORK screenshot** 

```
Initialiseren van de node
```

Als je de basic image hebt gebruikt zijn alle programma's al geinstalleerd voor je node. Het enige dat je moet doen de node toe te voegen is de join commando in te voeren. Deze commando is dus HEEL BELANGRIJK aangezien je telkens je een node wilt toevoegen je deze commando nodig hebt. Zorg er dan ook voor dat je deze join commando met de belangrijke token ergens veilig opslaat. Zodat telkens je een nieuwe node of een node reset je steeds de commando ter beschikking hebt.

`kubeadm join --token TOKENKEY IPmaster:6443 --discovery-token-ca-cert-hash sha256:HASHKEY`

Als je deze commando invoert krijg je een melding terug "this node has joined the cluster". Als je mijn tip hebt gebruikt voor de master met de watch commando zal je bij elke node die je hebt toegevoegd kunnen zien dat ze worden toegevoegd aan de cluster. GEEN schrik als je ziet dat de status nog op "unready" staat kubernetes heeft nog even tijd nodig om het netwerk in te stellen . Als je na 5 minuten nog steeds unready ziet dan is er wel iets mis en dan moet je gaan debuggen.  

```
Succesvol master aangemaakt en nodes toegevoegd
```

Wanneer je alle stappen succesvol hebt uitgevoerd zou de commando `kubectl get nodes` dit scherm moeten tonen. 
Daar kan je zien welke nodes er zijn toegevoegd en welke de master is. hier kan je ook zien wat de status is van elke node.
**get nodes afbeelding**

```
De kubernetes testen
``` 
We kunnen een pod handmatig aanmaken , en daarin een container inzetten door middel van een image te pullen. Maar je kan dit net zoals in docker volledig uitvoeren met een automatisatiescriptje namelijk de yaml file. 

Voor de test/ presentatie yaml file heb ik een standaard yaml file opgezet die een nginx image zal pullen en deze zal zetten in een Replication controller die er voor gaat zorgen dat de container gerepliceerd word en gemanaged word. De yaml file ziet er als volgt uit
```
apiVersion: v1
kind: ReplicationController
metadata:
 name: nginx-controller
spec:
 replicas: 3
 selector:
   name: nginx
 template:
   metadata:
     labels:
       name: nginx
   spec:
     containers:
       - name: nginx
         image: nginx
         ports:
           - containerPort: 80
```

Deze yaml file gaat dus 1 container aanmaken die de nginx image zal pullen (van waar juist weet ik niet Docker hub???) deze zal ook 3 replica's maken zodat je steeds 3 pods klaar hebt staan. 
je runt deze yaml file met deze commando `kubectl create -f naamVanYAML.yml`
Kubernetes zit zo goed in elkaar dat wanneer je dit instelt dat er 3 pods moeten draaien er zeker van gaat zijn dat er 3 pods gaan draaien. Wanneer je dus 1 pod uitschakelt het automatisch een pod zal restarten.
Deze pods zullen ook worden gescaled op de available nodes.

Met de commando `kubcetl get nodes -o wide` kan je zien welke ip addressen bij welke pod horen en hoe je er dus zo aangeraakt. 

In deze test omgeving heb ik dus een nginx image opgehaald en in een container gezet en hiervan 2 kopieen aangemaakt. Deze hebben nu 3 individuele ip addressen waar je naar toe kan surfen. Om dit proces te vereenvoudigen ga je werken met een loadbalancer en dus maar surfen naar 1 address en de eerste de beste pod nemen. De gebruiker maakt het niet uit welke pod dit is zolang de webserver maar werkt. Ook hier heeft kubernetes over nagedacht namelijk SERVICES. 

Net zoals alles kan je een service ook in een yaml file declareren dat deze de parameters in een bestand opsomt en runt met 1 kleine commando.
De service yaml file ziet er als volgt uit


```
kind: Service
apiVersion: v1
metadata:
  name: web-service
spec:
  selector:
    name: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

Deze service creer je op dezelfde manier als de replicacontroller `kubectl create -f naamVanService.yaml`

met de commando `kubectl get services` kan je deze service ophalen. 





#### Probleemstelling2
Wanneer je dus de pods up and running zijn en je deze kan zien met de commando `sudo kubectl get pods -o wide` ga je ook zien dat de 3 pods verdeeld worden over de nodes die beschikbaar zijn. 
Probleem stelling is nu dat wanneer je 1 node zal uitschakelen hij wel de pods zal verdelen naar de andere node maar hij hiervoor 4 tot 5 minuten voor nodig heeft. Dat is niet echt productie gericht in een raspberry pi cluster.

#### Oplossing2
De kube-controller-manager heeft een parameter genaamd pod-eviction-timeout. Deze staat standaard op 5 minuten en moet veranderd worden naar een zo min mogelijke overgangstijd. Aangezien we alles zoveel mogelijk willen automatiseren gaan we de kubeadm initialiseren met een configuratie file. 
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
# High available
WAT WERKT ER AL
- Wanneer een pod word gekilled zal er automatisch een andere pod worden opgezet (replicationcontroller fixt dees)
- Wanneer je een node afzet gaat de pod die daarop draaide op "unready" worden gezet en een nieuwe pod worden aangemaakt op de available node. 
  - Er moet nog worden gezien om de pod die draaide op de node die is uitgevellen te terminaten. Want dit gebeurd enkel als de node terug is opgestart.

WAT MOET NOG WORDEN GEDAAN
- Wanneer een nieuwe node wordt toegevoegd aan de cluster moet kubernetes dit automatisch zelf detecteren (Kijk naar auto horizontal scaling). 
- Wanneer de master uitvalt moet niet heel de boel plat liggen (2 raspberry's als master en node gebruiken)
- kube monkeys: wanneer een pod word gekilled zal er een nieuwe worden aangemaakt . Maar dit is bij een manuele kill. Wat gebeurd er bij een automatische kill.
- storage high available maken (ceph). eens bekijken
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
De commando `kubeadm reset` zal de cluster verwijderen en kan je dus opnieuw beginnen. Voer dit uit op de node(s) en op de master.

Om bepaalde instellingen te verwijderen die niet default mee verwijderd worden met de reset commando kan je volgende [Cheatsheet](http://khmel.org/?p=1092) gebruiken.


### Bronnenlijst

https://blog.alexellis.io/kubernetes-in-10-minutes/
https://blog.hypriot.com/post/setup-kubernetes-raspberry-pi-cluster/

raspberry pi cluster , met kubernetes 
Belangrijke bron: 
https://blog.yo61.com/kubernetes-on-a-5-node-raspberry-pi-2-cluster/


volledige kubernetes opzet
https://kubecloud.io/setup-a-kubernetes-1-9-0-raspberry-pi-cluster-on-raspbian-using-kubeadm-f8b3b85bc2d1
de yaml files voor de replication controller en de service
https://blog.jetstack.io/blog/k8s-getting-started-part3/