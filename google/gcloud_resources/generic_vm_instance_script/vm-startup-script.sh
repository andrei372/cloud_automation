#!/bin/bash

# update repos
apt-get update
aleep 2

# upgrade packages
apt-get upgrade
sleep 3

# install packages
apt-get install tree -y
apt-get install apache2 -y
apt-get install puppet -y
sleep 5

# get FQDN of puppet master
# script is given the argument of the IP of the puppet master that was reserved
puppetmaster=$(nslookup "$1" | awk -v ip="$1" '/name/{print substr($NF,1,length($NF)-1)}')

# configure puppet client
puppet config set server $puppetmaster
systemctl enable puppet
systemctl start puppet
sleep 3
puppet agent -v --test
