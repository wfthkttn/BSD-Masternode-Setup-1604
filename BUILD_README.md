# BitSend (BSD) Masternode - Build Docker Image

The Dockerfile will install all required stuff to run a BitSend (BSD) Masternode and is based on script bsdsetup.sh (see: https://github.com/dArkjON/BSD-Masternode-Setup-1604/blob/master/bsdsetup.sh)

## Requirements
- Linux Ubuntu 16.04 LTS
- Running as docker host server (package docker.io installed)
```
apt-get update
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
