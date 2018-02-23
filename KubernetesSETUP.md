# Setup kubernetes cluster

## Uitleg bepaalde concepten
Wat zijn

- PODS: Dit is een groep of 1 container dat dezelfde netwerk/opslag deelt. De containers in een pod zijn meer gekoppeld met elkaar dan in tegenstelling tot bij een docker swarm , etc... ze worden gemanaged en gedeployed als één unit.
- NODES: dit is een worker in de kubernetes cluster 
- MASTER: dat is de baas die gaat zeggen tegen de nodes wie wat moet draaien. De master kan ook een node zijn.
- DEPLOYMENTS: dit is een manier om een staat vast te zetten aan meerdere pods zodat je meerdere pods makkelijker kan managen.
- NETWERK: kubernetes werkt met netwerk plugins zodat je een netwerklaag kunt gebruiken opdat je pods met elkaar zullen kunenn verbinden. [Hier](https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-achieve-this/) Kan je alle uitleg vinden en de verschillende plugins die je kan toepassen
- REPLICATIONCONTROLLER: **verder bekijken hoe dit werkt**. Maar dit is normaal nodig om ervoor de replica's te managen zodat er altijd wel 1 up and running is.
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

# Wat nog instellen 
- Pods , en services uitproberen 
- Dashboard
- Bekijken of weaver beter is als netwerk plugin dan flannel(dit lijkt een populairdere netwerk technologie)
- Wat gebeurt er als er een pod of nog erger een node uitvalt. 
- Dit tonen via een dashboard.
- Etcd , Ingris concepten bekijken en kijken hoe toe te passen
- Wat met beveiliging over de nodes (ook mss aanpassingen aanbrengen aan pi)
- chaos monkeys of zoals ze dit in de kubernetes wereld noemen  [ Kube monkey](https://github.com/asobti/kube-monkey).

### Bronnenlijst

https://blog.alexellis.io/kubernetes-in-10-minutes/
https://blog.hypriot.com/post/setup-kubernetes-raspberry-pi-cluster/

raspberry pi cluster , met kubernetes 
Belangrijke bron: 
https://blog.yo61.com/kubernetes-on-a-5-node-raspberry-pi-2-cluster/


