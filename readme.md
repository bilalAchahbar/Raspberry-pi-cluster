# Kubernetes cluster op een bare metal Raspberry pi cluster

![Setup](/images/XplorianCluster.jpg)

## Maintainer

Bilal Achahbar 

## Beschrijving
Ik heb een raspberry pi cluster gebouwd op een bitscope rack. Dat als doel heeft om te dienen als een kubernetes cluster. Deze cluster zal gebruikt worden om te installeren in het local netwerk. Zodat iedereen die de technologie van kubernetes nodig heeft kan verbinden met de cluster. Om een zo high available manier van werken te garanderen heb ik ook een basic image gemaakt "Xplorian.img". Dit is zodat wanneer er toch iets verkeerd zou lopen je altijd makkelijk kan terugkeren naar een basic setup. Ik heb alles zo goed mogelijk gedocumenteerd in verschillende markdown bestanden. Hier onder zal je een link vinden naar de files en hoe ik elk onderdeel heb opgebouwd of uitgeprobeerd. Zodat moest het nodig zijn om aanpassingen uit te voeren of van scratch te herbeginnen je met mijn documentatie voldoende zou hebben om dit uit te voeren. 

## Hardware

- 4 Raspberry pi 3 
- Bitscope quattro pi cluster
- Server rack case
- Switch 
- 4 geheugen kaarten (16 GB)


## Documentatie

### Setup Basic image
 [link naar  create image file] 
 
- In deze file leg ik volledig uit hoe ik van een lege sd kaart tot mijn basic image ben gekomen. Deze basic image heeft alle nodige aanpassingen en programma's al ingesteld zodat deze direct te gebruiken is voor de Raspberry pi
      

 [link naar  tutorial bitscope rack file] 
 
 - Voor de setup van mijn raspberry pi heb ik gebruik gemaakt van een bitscope quattro pi. Deze hardware is gemaakt om een server rack te maken van raspberry pi's. Hiervoor heb ik een tutorial gemaakt hoe ik de bitscope rack in elkaar heb gestoken.
 
  [link naar  kubernetes cluster file]
  
- Als alles is opgezet en alle raspberry pi's klaar staan kunnen we beginnen met een kubernetes cluster op te zetten. In deze file leg ik uit hoe je een kubernetes master initialiseert en nodes kan toevoegen aan de cluster. Op het einde van deze documentatie heb je een basic kubernetes cluster opgezet. Verder word er ook uitgelegd hoe je een kubernetes dashboard moet opzetten en hoe je bepaalde serviceaccounts met restricted access kan toevoegen.

 [link naar Virtuele Raspberry pi's file] 
 
 - In een wereld waar Edward A. Murphy voorspelde dat wanneer er iets fout kan gebeuren dit ook zal gebeuren moeten we als it'ers dit vaak zien te voorkomen. Om een virtuele testomgeving op te zetten zodat we niet te veel verkeerd kunnen doen aan de hardware .Heb ik geprobeerd om een virtuele raspberry pi cluster op te zetten. Maar de technologie is op het moment dat ik dit heb geschreven nog niet optimaal om een kubernetes cluster op een virtuele raspberry pi cluster op te zetten. Bekijk de documentatie hoe ik dit heb opgezet en waar het verkeerd loopte. En  misschien is op het moment dat je deze readme leest de bug in de virtuele emulator opgelost en kan jij dit wel opzetten.
 
  [link naar  back up file] 
  
  - Er is iets fout gelopen en je moet een node opnieuw instellen. Of je hebt een betere hardwareo kunnen bemachtigen en je wilt een nieuwe raspberry pi toevoegen aan de cluster. In deze documentatie word er uitgelegd hoe simpel het is om de basic image te gebruiken om een node op te zetten.
  
  
## Bronnenlijst
  
 In elke documentatie file heb ik altijd verwezen wat mijn bronnen waren. Maar ik wil in deze readme een paar links geven die de volledige set up die ik heb opgezet hebben gemaakt en die heel handig waren voor mijn onderzoek.

- [Lucas Käldström](https://github.com/luxas) (dit is een kubernetes on arm genie die ik vaak ben tegengekomen tijdens mijn research,  bezoek zeker zijn github als je ergens vast zit)
    - [ Workshop ](https://github.com/luxas/kubeadm-workshop)om kubernetes cluster op te zetten op raspberry pi's met veel extra's die ik niet heb toegepast.
    
- [Kubecloud](https://kubecloud.io/)  (Een paar scandinaviërs hebben als thesis kubernetes op raspberry pi's geschreven en hierover een site gebouwd met vele tutorials)
      - [Kubernetes on arm](https://kubecloud.io/setup-a-kubernetes-1-9-0-raspberry-pi-cluster-on-raspbian-using-kubeadm-f8b3b85bc2d1)
