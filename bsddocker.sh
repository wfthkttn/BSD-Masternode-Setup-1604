#!/bin/bash
set -u

#
# Set bitsend user pwd and masternode genkey
#
echo '*** Step 0/10 - User input ***'
echo -n "Enter new password for [bitsend] user and Hit [ENTER]: "
read BSDPWD
echo -n "Enter your masternode genkey respond and Hit [ENTER]: "
read MN_KEY

#
# Check distro
#
cat /etc/issue

#
# Installation of docker package
#
apt-get update
apt-get upgrade -y
apt-get install docker.io
docker run -p 8886:8886 -p 8800:8800 --name bsd-masternode -e BSDPWD='${BSDPWD}' -e MN_KEY='${MN_KEY}' -v /home/bitsend:/home/bitsend:rw -d dalijolijo/bsd-masternode
