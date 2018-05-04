#!/bin/bash
set -u

DOCKER_REPO='dalijolijo'

#
# Set bitsend user pwd and masternode genkey
#
echo '*** Step 0/10 - User input ***'
echo -n "Enter new password for [bitsend] user and Hit [ENTER]: "
read PWD
echo -n "Enter your masternode genkey respond and Hit [ENTER]: "
read MN_KEY

#
# Check distro version (TODO)
#
#cat /etc/issue
#echo 'Checking OS version.'
#if [[ -r /etc/os-release ]]; then
#		. /etc/os-release
#		if [[ "${VERSION_ID}" != "16.04" ]]; then
#			echo "This script only supports ubuntu 16.04 LTS, exiting."
#			exit 1
#		fi
#fi

#
# Firewall settings
#
ufw logging on
ufw allow 22/tcp
ufw limit 22/tcp
ufw allow 8886/tcp
ufw allow 8800/tcp
# if other services run on other ports, they will be blocked!
#ufw default deny incoming 
ufw default allow outgoing 
yes | ufw enable

#
# Installation of docker package
#
apt-get update
apt-get upgrade -y
apt-get install docker.io
apt-get install docker.io -y
docker pull ${DOCKER_REPO}/bsd-masternode
docker run -p 8886:8886 -p 8800:8800 --name bsd-masternode -e BSDPWD='${PWD}' -e MN_KEY='${MN_KEY}' -v /home/bitsend:/home/bitsend:rw -d ${DOCKER_REPO}/bsd-masternode
