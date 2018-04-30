# BitSend (BSD) Masternode - Run Docker Image

### (1) Pull docker image
```
docker pull <repository>/bsd-masternode
```

### (2) Run docker container
```
docker run -p 8886:8886 -p 8800:8800 --name bsd-masternode -e MN_KEY='YOUR_MN_KEY' -v /home/bitsend:/home/bitsend:rw -d <repository>/bsd-masternode
docker ps
```

### (3) Debbuging within a container (after start.sh execution)
Please execute "docker run" in (2) before you execute this commands:
```
tail -f /home/bitsend/.bitsend/debug.log

docker ps
docker exec -it bsd-masternode bash
  # you are inside the btx-rpc-server container
  root@container# supervisorctl status bitsendd
  root@container# cat /var/log/supervisor/supervisord.log
  # Change to bitsend user
  root@container# sudo su bitsend
  bitsend@container# cat /home/bitsend/.bitsend/debug.log
  bitsend@container# bitsend-cli getinfo
```

### (4) Debbuging within a container during run (skip start.sh execution)
```
docker run -p 8886:8886 -p 8800:8800 --name bsd-masternode -e MN_KEY='YOUR_MN_KEY' -v /home/bitsend:/home/bitsend:rw --entrypoint bash <repository>/bsd-masternode
```

### (5) Stop docker container
```
docker stop bsd-masternode
docker rm bsd-masternode
```
