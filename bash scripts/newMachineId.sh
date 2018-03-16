#!/usr/bin/env bash

##### Beschrijving: dit bash script dient om de huidige machine-id te verwijderen en een nieuwe te genereren 
##### Wanneer je een image cloned zal je machine-id dus dezelfde blijven.
##### Voor een normaal gebruik van de OS zal dit niet snel op fouten stoten
##### Maar bij de netwerk laag van kubernetes was dit toch een probleem aangezien hij geen onderscheid kon maken tussen de pi's
##### Geschreven door Bilal Achahbar op 16/03/2018


sudo rm /etc/machine-id
sudo rm /var/lib/dbus/machine-id
sudo dbus-uuidgen --ensure=/etc/machine-id
