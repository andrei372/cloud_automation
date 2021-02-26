#!/bin/bash


# update repos
apt-get update
aleep 2

# upgrade packages
apt-get upgrade
sleep 2

# install packages
apt-get install tree -y
apt-get install nmap -y
apt-get install sysstat -y
apt-get install apache2 -y
sleep 2
apt-get install puppetmaster -y
sleep 5

# configure puppet master
puppet config --section master set autosign true
systemctl enable  puppet-master.service
systemctl restart  puppet-master.service
sleep 2

# create folder structure for manifests and modules
mkdir -p /etc/puppet/code/environments/production/manifests
touch /etc/puppet/code/environments/production/manifests/site.pp
mkdir -p /etc/puppet/code/environments/production/modules