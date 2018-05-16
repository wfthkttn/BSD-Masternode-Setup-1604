#!/bin/bash
set -u

DOCKER_REPO="dalijolijo"

#
# Check distro version (TODO)
#
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

if [[ $OS =~ "Ubuntu" ]] && [[ $VER =~ "16" ]] || [[ $OS =~ "ubuntu" ]] && [[ $VER =~ "16" ]]; then
    echo "Installation for $OS ($VER)..."
else
    echo "$OS ($VER) not supported!"
    exit
fi

#
# Set bitsend user pwd and masternode genkey
#
echo '*** Step 0/10 - User input ***'
echo -n "Enter new password for [bitsend] user and Hit [ENTER]: "
read BSDPWD
echo -n "Enter your masternode genkey respond and Hit [ENTER]: "
read MN_KEY

#
# Firewall settings (Ubuntu 16.04)
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
