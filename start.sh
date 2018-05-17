#!/bin/bash
set -u

BOOTSTRAP='bootstrap.tar.gz'

#
# Set passwd of bitsend user
#
echo bitsend:${BSDPWD} | chpasswd

#
# Set rpcuser, rpcpassword and masternode genkey
#
printf "** Set rpcuser, rpcpassword and masternode genkey ***"
mkdir -p /home/bitsend/.bitsend
chown -R bitsend:bitsend /home/bitsend
sudo -u bitsend cp /tmp/bitsend.conf /home/bitsend/.bitsend/
sed -i "s/^\(rpcuser=\).*/\rpcuser=bsdmasternode$(openssl rand -base64 32)/" /home/bitsend/.bitsend/bitsend.conf
sed -i "s/^\(rpcpassword=\).*/\rpcpassword=$(openssl rand -base64 32)/" /home/bitsend/.bitsend/bitsend.conf
sed -i "s/^\(masternodeprivkey=\).*/\masternodeprivkey=${MN_KEY}/" /home/bitsend/.bitsend/bitsend.conf

#
# Downloading bootstrap file
#
printf "** Downloading bootstrap file ***"
cd /home/bitsend/.bitsend/
if [ ! -d /home/bitsend/.bitsend/blocks ] && [ "$(curl -Is https://www.mybitsend.com/${BOOTSTRAP} | head -n 1 | tr -d '\r\n')" = "HTTP/1.1 200 OK" ] ; then \
        sudo -u bitsend wget https://www.mybitsend.com/${BOOTSTRAP}; \
        sudo -u bitsend tar -xvzf ${BOOTSTRAP}; \
        sudo -u bitsend rm ${BOOTSTRAP}; \
fi

#
# Step Starting BitSend Service
#
# Hint: docker not supported systemd, use of supervisord
printf "*** Starting BitSend Service ***"
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
