
#!/bin/bash
# This script will install all required stuff to run a BitSend (BSD) Masternode.
# BitSend Repo : https://github.com/LIMXTEC/BitSend
# !! THIS SCRIPT NEED TO RUN AS ROOT !!
######################################################################

clear
echo "*********** Welcome to the BitSend (BSD) Masternode Setup Script ***********"
echo 'This script will install all required updates & package for Ubuntu 16.04 !'
echo 'Clone & Compile the BSD Wallet also help you on first setup and sync'
echo '****************************************************************************'
sleep 3
echo '*** Step 1/5 ***'
echo -n "Please Enter new password for [bitsend] user and Hit [ENTER]: "
read BSDPASSWORD
adduser --disabled-password --gecos "" bitsend 
usermod -a -G sudo bitsend
echo bitsend:$BSDPASSWORD | chpasswd
echo '*** Creating 2GB Swapfile ***'
sleep 1
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048
sudo mkswap /swapfile
sudo swapon /swapfile
sudo chmod 600 /swapfile
sleep 1
echo '*** Done 1/5 ***'
sleep 1
echo '*** Step 2/5 ***'
echo '*** Running updates and install required packages ***'
sleep 2
sudo apt-get update -y
sudo apt-get dist-upgrade -y
sudo apt-get install build-essential libtool autotools-dev autoconf automake pkg-config libssl-dev -y
sudo apt-get install libboost-all-dev git npm nodejs nodejs-legacy libminiupnpc-dev redis-server -y
sudo apt-get install software-properties-common -y
sudo apt-get install libevent-dev -y
sudo add-apt-repository ppa:bitcoin/bitcoin
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y
echo '*** Done 2/5 ***'
sleep 1
echo '*** Step 3/5 ***'
echo '*** Cloning and Compiling BitSend Wallet ***'
cd
git clone https://github.com/LIMXTEC/BitSend
cd BitSend
./autogen.sh
./configure
make

cd
cd BitSend/src
strip bitsendd
cp bitsendd /usr/local/bin
strip bitsend-cli
sudo cp bitsend-cli /usr/local/bin
sudo chmod 775 /usr/local/bin/bitsend*
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow 8886/tcp
sudo ufw default deny incoming 
sudo ufw default allow outgoing 
sudo ufw enable -y
cd

echo '*** Done 3/5 ***'
sleep 2
echo '*** Step 4/5 ***'
echo '*** Configure bitsend.conf and download and import bootstrap file ***'
sleep 2
bitsendd
sleep 3
echo -e "[Unit]\nDescription=BitSend's distributed currency daemon\nAfter=network.target\n\n[Service]\nUser=bitsend\nGroup=bitsend\n\nType=forking\nPIDFile=/home/bitsend/.bitsend/bitsendd.pid\n\nExecStart=/usr/local/bin/bitsendd -daemon -disablewallet -pid=/home/bitsend/.bitsend/bitsendd.pid \\n          -conf=/home/bitsend/.bitsend/bitsend.conf -datadir=/home/bitsend/.bitsend/\n\nExecStop=-/usr/local/bin/bitsend-cli -conf=/home/bitsend/.bitsend/bitsend.conf \\n         -datadir=/home/bitsend/.bitsend/ stop\n\nRestart=always\nPrivateTmp=true\nTimeoutStopSec=60s\nTimeoutStartSec=2s\nStartLimitInterval=120s\nStartLimitBurst=5\n\n[Install]\nWantedBy=multi-user.target\n" > /usr/lib/systemd/system/bitsendd.service
sleep 2
echo -n "Please Enter your masternode genkey respond and Hit [ENTER]: "
read mngenkey
echo -e "rpcuser=bsdmasternode$(openssl rand -base64 32) \nrpcpassword=$(openssl rand -base64 32) \nrpcallowip=127.0.0.1 \nserver=1 \nlisten=1 \ndaemon=1 \nlogtimestamps=1 \nmasternode=1 \npromode=1 \nmasternodeprivkey=$mngenkey \naddnode=107.170.2.241 \naddnode=45.58.51.22 \naddnode=104.207.131.249 \naddnode=68.197.13.94 \naddnode=109.30.168.16 \naddnode=31.41.247.133 \naddnode=37.120.190.76 \n" > ~/.bitsend/bitsend.conf
cd .bitsend

wget https://www.mybitsend.com/bootstrap.tar.gz

tar -xvzf bootstrap.tar.gz
echo '*** Done 4/5 ***'
sleep 2
echo '*** Step 5/5 ***'
echo '*** Last Server Start also Wallet Sync ***'
echo 'After 1 minute you will see the 'getinfo' output from the RPC Server...'
systemctl start bitsendd
sleep 60
bitsend-cli getinfo
sleep 2
echo 'Have fun with your Masternode !'
sleep 2
echo '*** Done 5/5 ***'
