#!/bin/bash
set -u

BOOTSTRAP='bootstrap.tar.gz'

#
# Set passwd of bitsend user
#
echo bitsend:${BSDPWD} | chpasswd

#
# Set masternode genkey
#
mkdir -p /home/bitsend/.bitsend
chown -R bitsend:bitsend /home/bitsend
sudo -u bitsend cp /tmp/bitsend.conf /home/bitsend/.bitsend/
sed -i "s/^\(masternodeprivkey=\).*/\masternodeprivkey=${MN_KEY}/" /home/bitsend/.bitsend/bitsend.conf

#
# Step 8/10 - Downloading bootstrap file
#
printf "** Step 8/10 - Downloading bootstrap file ***"
cd /home/bitsend/.bitsend/
if [ ! -d /home/bitsend/.bitsend/blocks ] && [ "$(curl -Is https://www.mybitsend.com/${BOOTSTRAP} | head -n 1 | tr -d '\r\n')" = "HTTP/1.1 200 OK" ] ; then \
        sudo -u bitsend wget https://www.mybitsend.com/${BOOTSTRAP}; \
        sudo -u bitsend tar -xvzf ${BOOTSTRAP}; \
        sudo -u bitsend rm ${BOOTSTRAP}; \
fi
printf "*** Done 8/10 ***"

#
# Step 9/10 - Starting BitSend Service
#
# Hint: docker not supported systemd, use of supervisord
printf "*** Step 9/10 - Starting BitSend Service ***"
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
