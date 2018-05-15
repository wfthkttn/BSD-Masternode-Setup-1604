#!/bin/bash
set -u

DOCKER_REPO="dalijolijo"

#
# Set bitsend user pwd and masternode genkey
#
echo '*** Step 0/10 - User input ***'
echo -n "Enter new password for [bitsend] user and Hit [ENTER]: "
read BSDPWD
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
# Installation of docker-ce package (Ubuntu 16.04)
#
apt-get update
sudo apt-get remove -y docker \
                       docker-engine \
                       docker.io
sudo apt-get install -y apt-transport-https \
                        ca-certificates \
                        curl \
                        software-properties-common
cd /root
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce -y

#
# Pull docker images and run the docker container
#
docker pull ${DOCKER_REPO}/bsd-masternode
docker run --rm -p 8886:8886 -p 8800:8800 --name bsd-masternode -e BSDPWD="${BSDPWD}" -e MN_KEY="${MN_KEY}" -v /home/bitsend:/home/bitsend:rw ${DOCKER_REPO}/bsd-masternode
