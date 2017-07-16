
#!/bin/bash
# This script will install all needed stuff to run a BitSend (BSD) Masternode.
# BitSend Repo : https://github.com/LIMXTEC/BitSend
# !! THIS SCRIPT NEED TO RUN AS ROOT !!
######################################################################

clear
echo "*********** Welcome to the BitSend (BSD) Masternode Setup Script ***********"
echo 'This script will install all required updates & package for Ubuntu 14.04 !'
echo 'Clone & Compile the BSD Wallet also help you on first setup and sync'
echo '****************************************************************************'
sleep 3
echo '*** Step 1/5 ***'
echo '*** Creating 2GB Swapfile ***'
sleep 1
dd if=/dev/zero of=/mnt/mybsdswap.swap bs=2M count=1000
mkswap /mnt/mybsdswap.swap
swapon /mnt/mybsdswap.swap
sleep 1
echo '*** Done 1/5 ***'
sleep 1
echo '*** Step 2/5 ***'
echo '*** Running updates and install required packages ***'
sleep 2
sudo apt-get update -y
sudo apt-get dist-upgrade -y
sudo apt-get install build-essential libtool autotools-dev autoconf pkg-config libssl-dev -y
sudo apt-get install libboost-all-dev git npm nodejs nodejs-legacy libminiupnpc-dev redis-server -y
sudo apt-get install software-properties-common -y
add-apt-repository ppa:bitcoin/bitcoin
apt-get update -y
apt-get install libdb4.8-dev libdb4.8++-dev -y
curl https://raw.githubusercontent.com/creationix/nvm/v0.16.1/install.sh | sh
source ~/.profile
nvm install 0.10.25
nvm use 0.10.25
echo '*** Done 2/5 ***'
