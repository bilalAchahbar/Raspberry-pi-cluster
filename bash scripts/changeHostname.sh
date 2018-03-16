#!/usr/bin/env bash

##### Beschrijving: Dit bash script dient om gemakkelijk de hostname te veranderen van je user 




#De huidige hostnaam opvragen
hostn=$(cat /etc/hostname)

echo "De hostname die nu is ingesteld is:  $hostn"

#Vraag een nieuwe hostnaam aan de gebruiker 
echo "Geef een nieuwe hostnaam: "
read newhost

#Verander hostnaam in /etc/hosts & /etc/hostname
sudo sed -i "s/$hostn/$newhost/g" /etc/hosts
sudo sed -i "s/$hostn/$newhost/g" /etc/hostname

#Display de nieuwe hostnaam
echo "De nieuwe hostnaam is $newhost"



