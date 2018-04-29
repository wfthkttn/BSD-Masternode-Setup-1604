# BitSend (BSD) Masternode - Build Docker Image
# BitSend Repo : https://github.com/LIMXTEC/BitSend

The Dockerfile will install all required stuff to run a BitSend (BSD) Masternode and is based on script bsdsetup.sh (see: https://github.com/dArkjON/BSD-Masternode-Setup-1604/blob/master/bsdsetup.sh)

## Requirements
- Linux Ubuntu 16.04 LTS
- Running as docker host server (package docker.io installed)
```
apt-get update -y
apt-get upgrade -y
apt-get install docker.io -y
```

## Needed files
- Dockerfile
- bitsend.conf
- bitsend.sv.conf
- start.sh

## Allocating 2GB Swapfile
Create a swapfile to speed up the building process. Recommended if not enough RAM available on your docker host server.
```
dd if=/dev/zero of=/swapfile bs=1M count=2048
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

## Adding firewall rules
Open needed ports on your docker host server.
```
ufw logging on
ufw allow 22/tcp
ufw limit 22/tcp
ufw allow 8886/tcp
ufw default deny incoming 
ufw default allow outgoing 
yes | ufw enable
```

## Build docker image
```
docker build [--build-arg BSDPWD='<bitsend user pwd>'] -t bsd-masternode .
```

## Push docker image to hub.docker
```
docker tag bsd-masternode <repository>/bsd-masternode
docker login -u <repository> -p"<PWD>"
docker push <repository>/bsd-masternode:<tag>
```
