#!/bin/bash

# update repos
apt-get update
aleep 2

# upgrade packages
apt-get upgrade
sleep 2

# install packages
apt-get install tree -y
apt-get install sysstat -y
apt-get install apache2 -y
apt-get install puppet -y
sleep 5

# get FQDN of puppet master

	# ip variable is being provided by the python script and written into the sh script 
	# before running it on the cloud instance

ip=10.21.10.100

puppetmaster=$(nslookup "$ip" | awk -v ip="$ip" '/name/{print substr($NF,1,length($NF)-1)}')
sleep 2

# configure puppet client
puppet config set server $puppetmaster
systemctl enable puppet
systemctl start puppet
sleep 3
puppet agent -v --test

