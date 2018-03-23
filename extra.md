# Kubernetes is een snel groeiende technologie

## Beschrijving
In deze documentatie zal ik verder oplichten wat ik zelf nog zou aanpassen aan de Kubernetes / Raspberry pi cluster maar waar ik niet genoeg tijd voor had.
Beste lezen van mijn documentatie neem zeker deze documentatie ook door zodat je misschien deze handige en leuke toepassingen wel kan toevoegen aan jouw cluster.
Daarnaast zal ik een conclusie schrijven over mijn huidige cluster en handige links die je zeker in het oog moet houden.

## Handige links

- https://kubernetes.slack.com/
- https://github.com/kubernetes/kubernetes
- https://github.com/luxas


## Connecteren met je pod

De bedoeling van mijn project is om een zo basic mogelijke kubernetes cluster op te bouwen. Zodat gebruikers op deze cluster kunnen testen en bepaalde applicaties kunnen runnen. Hoe ga je nu connecteren met je pod een paar handige tools en links die ik doorheen mijn research heb gevonden zijn:

- https://github.com/luxas/kubeadm-workshop#deploying-an-ingress-controller-for-exposing-http-services
- https://kubernetes.io/docs/concepts/services-networking/ingress/

## Kubernetes Dashboard

Als je mijn *Kubernetes.md* documentatie hebt bekeken kan je zien hoe ik mijn dashboard heb ingesteld. Ik heb dat op een vrij basic manier gedaan en de uitbreidingen zijn eindeloos. Voor mijn research naar het opzetten van een kubernetes dashboard ben ik terech gekomen bij Joe Beda een enthousiast van kubernetes en de engine ervan. Zijn [Handleiding](https://blog.heptio.com/on-securing-the-kubernetes-dashboard-16b09b1b7aca)  over het opzetten / beveiligen van het dashboard is heel uitgebreid en moet je zeker bekijken als je vind dat het huidige dashboard niet voldoet aan jouw behoeften. Joe heeft niet alleen het artikel geschreven maar heeft de volledige set up in een [video tutorial](https://www.youtube.com/watch?v=od8TnIvuADg) gestoken zodat je kan zien wat hij doet en hij hierover uitleg geeft *TIP: zet de snelheid van youtube op x1,5*. Er zullen ongetwijfeld meerdere tutorials aanwezig zijn. 

Extra's die ik niet heb toegepast op mijn huidige kubernetes dashbaord
- [Let's encrypt](https://blog.heptio.com/how-to-deploy-web-applications-on-kubernetes-with-heptio-contour-and-lets-encrypt-d58efbad9f56): Voor het managen van de signed tokens via de browser
- [O Auth](https://blog.heptio.com/on-securing-the-kubernetes-dashboard-16b09b1b7aca) : Zodat je via een google , github , ... account kunt inloggen ipv een token
- [Ingress nginx controller](https://github.com/heptio/contour): Dat de connectie niet via een NodePort gaat maar via een ingress controller dat veel veiliger is.

Weet dat kubernetes een snel groeiende technologie is dit is niet anders voor het kubernetes dashboard. Mensen zijn volop bezig met aanpassingen aan te vragen aan het kubernetes team. Een mooie aanvraag vond ik van deze [Persoon](https://github.com/kubernetes/dashboard/blob/master/docs/design/access-control.md). Om op een kubernetes dashboard in GUI users toe te voegen en roles aan toe te passen

- [ Officiele kubernetes dashboard github](https://github.com/kubernetes/dashboard)


## Shared storage

Ik ben jammer genoeg niet geraakt tot het storage gedeelte van de kubernetes cluster. Ik heb hiernaar wel onderzoek gedaan welke storages er zijn en waar je ze kan vinden. Hier zijn handige links en technologieën die ik ben tegengekomen om orchestrators voor shared volumes op een kubernetes cluster te laten runnen.
Het is mogelijk om een high available volume toe te passen op een Raspberry pi cluster zoek hier zeker in verder om je Cluster zo high available as possible te maken



- Ceph cluster
	- http://docs.ceph.com/docs/master/rados/
- Rook (dit is een uitbreiding op ceph en heeft een grote community erachter, dit werd ook aangeraden voor een raspberry pi)
	- https://github.com/rook/rook
	- https://rook-slackin.herokuapp.com/  (De rook community op slack is zeer goed opgebouwd en zij zullen je zeker helpen met eventuele problemen die je hebt.)
- Gluster
	- https://www.gluster.org/
	- http://larmog.github.io/2016/02/22/glusterfs-on-kubernetes-arm/
