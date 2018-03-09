#!/usr/bin/env bash

##### Beschrijving: Dit bash script dient om de nodige software die nodig is voor elke raspberri pi te initialiseren in de basic image
##### Het gaat het volgende installeren: Docker , kubeadm. 
##### Ook zal het volgende configuratie aanpassen: Swap uitschakelen , cgroup enablen in boot 
##### Geschreven door Bilal Achahbar op 14/02/2018
##### Bron config and install docker , cgroup , swap , kubeadm: https://kubecloud.io/setup-a-kubernetes-1-9-0-raspberry-pi-cluster-on-raspbian-using-kubeadm-f8b3b85bc2d1


#CPU/GPU split
sudo sh -c "echo 'gpu_mem=16' >> /boot/config.txt"

#bluetooth en wifi uitschakelen
sudo sh -c " echo 'dtoverlay=pi3-disable-wifi' >> /boot/config.txt"
sudo sh -c " echo 'dtoverlay=pi3-disable-bt' >> /boot/config.txt"



#user toevoegen aan sudo group

sudo adduser xplore sudo
sudo usermod -aG sudo xplore



#Omdat dit een initialisatie script is en runt voor de eerste keer gaan we het huidig systeem updaten en upgraden
sudo apt-get update -y && upgrade -y && dist-upgrade -y

#installtie van vim voor iets betere gemak dan vi of nano
sudo apt-get install -y vim

#Zet ssh verbinding op auto start 
sudo update-rc.d ssh defaults

#aanmaken van ssh folder in home folder met authorized file en de nodige permissies
mkdir ~/.ssh
touch ~/.ssh/authorized_keys
#Geef voldoende rechten zodat ssh aan de keys aan kan
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

	

#installeren van docker en user toevoegen aan docker group
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker xplore

#Swap uitschakelen
sudo dphys-swapfile swapoff && \
sudo dphys-swapfile uninstall && \
sudo update-rc.d dphys-swapfile remove

#cgroup je gaat 2 parameters toevoegen aan het boot bestand , zodat je met cgroups kan werken voor de cpu en voor het ram geheugen
#je gaat deze folder voor de veiligheid ook backuppen zodat je later nog steeds aan de default instellingen kunt
echo Adding " cgroup_enable=cpuset cgroup_enable=memory" to /boot/cmdline.txt
sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt

# cgroup_memory=1 zou in principe perfect moeten werken wanneer dit toch fouten geeft kan je 
#cgroup_enable=memory gebruiken. De reden dat ik toch cgroup_memory=1 gebruik is wegens een kernel probleem (zie bron)
orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1"
echo $orig | sudo tee /boot/cmdline.txt

#kubeadm installeren
#de repo voor de kubeadm toevoegen aan je repolist
#repo updaten
# installeren van kubeadm
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
  sudo apt-get update -q && \
sudo apt-get install -qy kubeadm
