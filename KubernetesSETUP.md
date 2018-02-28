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
Op de master ga je de `kubeadm`initialiseren dit doe je door middel van volgende commando
- `kubeadm init --pod-network-cidr 10.1.0.0/16` 
    - je geeft de netwerk policies mee bij het initialiseren van de master
    
Deze commando gaat even tijd in beslag nemen. Nadat deze commando is afgelopen zie je het volgende scherm te zien

![kuadm init](/images/kubeMasterOutput.JPG)

Zoals je kan zien op het scherm zal je deze 3 stappen moeten uitvoeren alvorens je de cluster kunt runnen
- configuratie files koppieren naar de juiste map
  - Deze files worden aangemaakt tijdens de init commando maar staan nog niet in de juiste map
    - Wanneer je dit niet doet kan je fouten krijgen in de vorm van localhost:8080 refused. dit komt omdat de configuratie files niet in de juiste map zijn geplaatst 
- Netwerk instelllen 
  - Je moet een netwerk instellen zodat je pods en nodes  met elkaar kunnen verbinden.
  - Tot nu toe heb ik gevonden dat enkel de FLANNEL netwerk op het arm systeem kan draaien. Ik zal deze dus eerst testen en later zal ik het verschil uitleggen met de WEAVER en FLANNEL. Om flannel nu in te stellen gebruik je volgende commando's
    - ` export ARCH=arm`
    -  `curl -sSL "https://github.com/coreos/flannel/blob/master/Documentation/kube-flannel.yml?raw=true" | sed "s/amd64/${ARCH}/g" | kubectl create -f - `
    
- Join commando kopieren naar de nodes(en daar uitvoeren)
  - Nu alles is ingesteld op de master kunnen we nodes toevoegen aan de cluster. Op de foto ( de output vand e `kubeadm init` commando zie je hoe dit gebeurd. 
  - Kopieer de meegegeven commando naar de terminal van een node. 
  - Op de master kan je de commando `watch kubectl get nodes` opzetten om te zien wat er gebeurd
  - Wanneer je nu de join commando runt in een node. ga je in de terminal van de master zien dat deze word toegevoegd. de `watch`commando zal contant de output vand e `kubectl get nodes` commando refreshen zodat je alle nodes ziet toegevoegd worden aan de cluster

Als alles goed gaat moet je dit zien bij de commando `kubectl get nodes`
  
**PROBLEEMSTELLING**  
    - Wanneer je dus met de commando `kubectl get nodes` de nodes in de cluster ziet kan het zijn dat deze op "UNREADY" staan. Dit zou normaal gezien na enige tijd moeten veranderen en de nodes zouden up en running moeten zijn. Wanneer dit niet het geval is kan je eens kijken of je een fout hebt gemaakt bij een van de vorige stappen : config folder kopieren , netwerk instellen , join commando.
    - Stel dat je de token niet had opgeslagen en je een nieuwe node wilt toevoegen aan de cluster. De commando `kubeadm token list`gaat de tokens die werden aangemaakt oplijsten.
 
### RESET
Het kan gebeuren dat je opnieuw wilt beginnen door een fout of iets anders. 
De commando `kubeadm reset` zal de cluster verwijderen en kan je dus opnieuw beginnen. Voer dit uit op de node(s) en op de master.

Om bepaalde instellingen te verwijderen die niet default mee verwijderd worden met de reset commando kan je volgende [Cheatsheet](http://khmel.org/?p=1092) gebruiken.

### POD opzetten en scalen over de nodes
Er zijn wel wat aanpassingen gebeurd sinds de vorige keer namelijk , dat we nu werken met de weaver netwerk dit zet je op met volgende commando `sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"`

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

Deze service creer je op dezelfde manier als de replicacontroller `Sudo kubectl create -f naamVanService.yaml`

met de commando `kubectl get services` kan je deze service ophalen. 

#### Probleemstelling
Wanneer je dus de pods up and running zijn en je deze kan zien met de commando `sudo kubectl get pods -o wide` ga je ook zien dat de 3 pods verdeeld worden over de nodes die beschikbaar zijn. 
Probleem stelling is nu dat wanneer je 1 node zal uitschakelen hij wel de pods zal verdelen naar de andere node maar hij hiervoor 4 tot 5 minuten voor nodig heeft. Dat is niet echt productie gericht in een raspberry pi cluster.

#### Mogelijke oplossing
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
