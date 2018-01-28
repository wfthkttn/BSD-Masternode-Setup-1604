
#!/bin/bash
# This script will install all required stuff to run a BitSend (BSD) Masternode.
# BitSend Repo : https://github.com/LIMXTEC/BitSend
# !! THIS SCRIPT NEED TO RUN AS ROOT !!
######################################################################
# Options and variables
# exit when any command fails
set -e
# keep track and echo an error message before exiting
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT
# Installation starts
clear
echo "*********** Welcome to the BitSend (BSD) Masternode Setup Script ***********"
echo 'This script will install all required updates & packages for Ubuntu 16.04 !'
echo 'Create specific user to handle masternode, set firewall options and add bitsendd as a service.'
echo '****************************************************************************'
echo 'Checking OS version.'
if [[ -r /etc/os-release ]]; then
		. /etc/os-release
		if [[ "${VERSION_ID}" != "16.04" ]]; then
			echo "This script only supports ubuntu 16.04 LTS, exiting."
			exit 1
		fi
fi
echo '*** Step 0/10 - User input ***'
echo -n "Enter new password for [bitsend] user and Hit [ENTER]: "
read BSDPASSWORD
echo -n "Enter your masternode genkey respond and Hit [ENTER]: "
read mngenkey
echo '*** Step 1/10 - creating bitsend user ***'
adduser --disabled-password --gecos "" bitsend 
usermod -a -G sudo bitsend
echo bitsend:$BSDPASSWORD | chpasswd
echo '*** Done 1/10 ***'
echo '*** Step 2/10 - Allocating 2GB Swapfile ***'
dd if=/dev/zero of=/swapfile bs=1M count=2048
mkswap /swapfile
swapon /swapfile
chmod 600 /swapfile
echo '*** Done 2/10 ***'
echo '*** Step 3/10 - Running updates and installing required packages ***'
apt-get update -y
apt-get dist-upgrade -y
apt-get install build-essential libtool autotools-dev autoconf automake pkg-config -y \
libssl-dev libboost-all-dev git libminiupnpc-dev libevent-dev -y
add-apt-repository ppa:bitcoin/bitcoin -y
apt-get update -y
apt-get upgrade -y
apt-get install libdb4.8-dev libdb4.8++-dev -y
echo '*** Done 3/10 ***'
echo '*** Step 4/10 - Cloning and Compiling BitSend Wallet ***'
cd
git clone --branch v0.14 --depth 1 https://github.com/LIMXTEC/BitSend 
cd BitSend
./autogen.sh
./configure --disable-dependency-tracking --enable-tests=no --without-gui
make
cd
cd BitSend/src
strip bitsendd
cp bitsendd /usr/local/bin
strip bitsend-cli
cp bitsend-cli /usr/local/bin
chmod 775 /usr/local/bin/bitsend*
cd
rm -rf BitSend
echo '*** Done 4/10 ***'
echo '*** Step 5/10 - Adding firewall rules ***'
ufw logging on
ufw allow 22/tcp
ufw limit 22/tcp
ufw allow 8886/tcp
ufw default deny incoming 
ufw default allow outgoing 
yes | ufw enable
echo '*** Done 5/10 ***'
echo '*** Step 6/10 - Configure bitsend.conf ***'
sudo -u bitsend mkdir /home/bitsend/.bitsend
sudo -u bitsend echo -e "rpcuser=bsdmasternode$(openssl rand -base64 32) \nrpcpassword=$(openssl rand -base64 32) \nrpcallowip=127.0.0.1 \nserver=1 \nlisten=1 \ndaemon=1 \nlogtimestamps=1 \nmasternode=1 \npromode=1 \nmasternodeprivkey=$mngenkey \naddnode=107.170.2.241 \naddnode=45.58.51.22 \naddnode=104.207.131.249 \naddnode=68.197.13.94 \naddnode=109.30.168.16 \naddnode=31.41.247.133 \naddnode=37.120.190.76 \n" > /home/bitsend/.bitsend/bitsend.conf
cd /home/bitsend/.bitsend
echo '*** Done 6/10 ***'
echo '*** Step 7/10 - Adding bitsend daemoon as a service ***'
mkdir /usr/lib/systemd/system
echo -e "[Unit]\nDescription=BitSend's distributed currency daemon\nAfter=network.target\n\n[Service]\nUser=bitsend\nGroup=bitsend\n\nType=forking\nPIDFile=/home/bitsend/.bitsend/bitsendd.pid\n\nExecStart=/usr/local/bin/bitsendd -daemon -disablewallet -pid=/home/bitsend/.bitsend/bitsendd.pid \\n          -conf=/home/bitsend/.bitsend/bitsend.conf -datadir=/home/bitsend/.bitsend/\n\nExecStop=-/usr/local/bin/bitsend-cli -conf=/home/bitsend/.bitsend/bitsend.conf \\n         -datadir=/home/bitsend/.bitsend/ stop\n\nRestart=always\nPrivateTmp=true\nTimeoutStopSec=60s\nTimeoutStartSec=2s\nStartLimitInterval=120s\nStartLimitBurst=5\n\n[Install]\nWantedBy=multi-user.target\n" > /usr/lib/systemd/system/bitsendd.service
echo '*** Done 7/10 ***'
echo '*** Step 8/10 - Downloading bootstrap file***'
if [ "$(curl -Is https://www.mybitsend.com/bootstrap.tar.gz | head -n 1 | tr -d '\r\n')" = "HTTP/1.1 200 OK" ] ; then
sudo -u bitsend wget https://www.mybitsend.com/bootstrap.tar.gz
sudo -u bitsend tar -xvzf bootstrap.tar.gz
sudo -u bitsend rm bootstrap.tar.gz
fi
echo '*** Done 8/10 ***'
echo '*** Step 9/10 - Starting Bitsend Service ***'
systemctl enable bitsendd
systemctl start bitsendd
echo 'BitSend Masternode installed! Weeee!'
echo '*** Done 9/10 ***'
echo '*** Step 10/10 - Wait for wallet synchronization!***'
echo 'First reward should appear in 72 hours after you successfuly activate it.'
echo 'To make sure everything working properly you need to reboot server, i advice to wait until wallet synchronization ends.'
echo 'Easiest way to do it, is to catch new block message, where "height=***" is equal to "Current numbers of blocks" in local wallet (help>debug>information)'
echo 'Message example:'
echo '2018-01-32 24:61:61 UpdateTip: new best=0000000001602844h6h46649ab3cc7d66969e80b2cd970773d355a97bb9ac height=407633 version=0x20000000 log2_work=55.377649 tx=570794 date='2017-12-20 16:26:23' progress=1.000000 cache=0.0MiB(188tx)'
echo 'After server restarts - you are free to enable masternode on local wallet.'
sleep 5
echo 'Now go, and visit our telegram channel at t.me/BSD_bitsend, tell us how its going!'
echo ' '
read -p "Press enter to monitor debug.log"
tail -f debug.log
